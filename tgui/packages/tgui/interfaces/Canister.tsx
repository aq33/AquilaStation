import {
  Box,
  Button,
  Flex,
  Icon,
  Knob,
  LabeledControls,
  LabeledList,
  RoundGauge,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const formatPressure = (value: number) => {
  if (value < 10000) {
    return `${toFixed(value)} kPa`;
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

// AQUILA: nasze kanistry nie pękają od ciśnienia (brak pressure_limit z tg),
// więc skala wskaźnika jest stała: 40 atm, 80 atm, 100 atm.
const CANISTER_GAUGE_MAX = 10132.5;
const CANISTER_GAUGE_AVERAGE = 4053;
const CANISTER_GAUGE_BAD = 8106;

type HoldingTank = {
  name: string;
  tankPressure: number;
};

type Data = {
  portConnected: BooleanLike;
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  valveOpen: BooleanLike;
  hasHoldingTank: BooleanLike;
  holdingTank: HoldingTank;
  holdingTankLeakPressure: number;
  holdingTankFragPressure: number;
  // AQUILA: prototypowy kanister z blokadą dostępu
  isPrototype: BooleanLike;
  restricted: BooleanLike;
};

export const Canister = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    hasHoldingTank,
    holdingTank,
    valveOpen,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    portConnected,
    holdingTankFragPressure = 4053,
    holdingTankLeakPressure = 3040,
    isPrototype,
    restricted,
  } = data;
  const gaugeMax = Math.max(CANISTER_GAUGE_MAX, tankPressure);

  return (
    <Window width={350} height={300}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item mb={1}>
            <Section
              title="Kanister"
              buttons={
                <>
                  {!!isPrototype && (
                    <Button
                      icon={restricted ? 'lock' : 'unlock'}
                      color="caution"
                      content={restricted ? 'Inżynieria' : 'Publiczny'}
                      tooltip="Ograniczenie dostępu do prototypu"
                      onClick={() => act('restricted')}
                    />
                  )}
                  <Button
                    icon="pencil-alt"
                    content="Zmień etykietę"
                    onClick={() => act('relabel')}
                  />
                </>
              }
            >
              <LabeledControls>
                <LabeledControls.Item minWidth="66px" label="Ciśnienie">
                  <RoundGauge
                    size={1.75}
                    value={tankPressure}
                    minValue={0}
                    maxValue={gaugeMax}
                    alertAfter={CANISTER_GAUGE_BAD}
                    ranges={{
                      good: [0, CANISTER_GAUGE_AVERAGE],
                      average: [CANISTER_GAUGE_AVERAGE, CANISTER_GAUGE_BAD],
                      bad: [CANISTER_GAUGE_BAD, gaugeMax],
                    }}
                    format={formatPressure}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Regulator">
                  <Box position="relative" left="-8px">
                    <Knob
                      tickWhileDragging
                      size={1.25}
                      color={!!valveOpen && 'yellow'}
                      value={releasePressure}
                      unit="kPa"
                      minValue={minReleasePressure}
                      maxValue={maxReleasePressure}
                      step={5}
                      stepPixelSize={1}
                      onChange={(e, value) =>
                        act('pressure', {
                          pressure: value,
                        })
                      }
                    />
                    <Button
                      fluid
                      position="absolute"
                      top="-2px"
                      right="-20px"
                      color="transparent"
                      icon="fast-forward"
                      tooltip="Maksimum"
                      onClick={() =>
                        act('pressure', {
                          pressure: maxReleasePressure,
                        })
                      }
                    />
                    <Button
                      fluid
                      position="absolute"
                      top="16px"
                      right="-20px"
                      color="transparent"
                      icon="undo"
                      tooltip="Domyślne"
                      onClick={() =>
                        act('pressure', {
                          pressure: defaultReleasePressure,
                        })
                      }
                    />
                  </Box>
                </LabeledControls.Item>
                <LabeledControls.Item label="Zawór">
                  <Button
                    my={0.5}
                    width="64px"
                    lineHeight={2}
                    fontSize="11px"
                    color={
                      valveOpen ? (hasHoldingTank ? 'caution' : 'danger') : null
                    }
                    content={valveOpen ? 'Otwarty' : 'Zamknięty'}
                    onClick={() => act('valve')}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item mr={1} label="Port">
                  <Tooltip
                    content={portConnected ? 'Podłączony' : 'Odłączony'}
                    position="top"
                  >
                    <Box position="relative">
                      <Icon
                        size={1.25}
                        name={portConnected ? 'plug' : 'times'}
                        color={portConnected ? 'good' : 'bad'}
                      />
                    </Box>
                  </Tooltip>
                </LabeledControls.Item>
              </LabeledControls>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section
              height="100%"
              title="Włożony zbiornik"
              buttons={
                !!hasHoldingTank && (
                  <Button
                    icon="eject"
                    color={valveOpen && 'danger'}
                    content="Wyjmij"
                    onClick={() => act('eject')}
                  />
                )
              }
            >
              {!!hasHoldingTank && (
                <LabeledList>
                  <LabeledList.Item label="Nazwa">
                    {holdingTank.name}
                  </LabeledList.Item>
                  <LabeledList.Item label="Ciśnienie">
                    <RoundGauge
                      value={holdingTank.tankPressure}
                      minValue={0}
                      maxValue={holdingTankFragPressure * 1.15}
                      alertAfter={holdingTankLeakPressure}
                      ranges={{
                        good: [0, holdingTankLeakPressure],
                        average: [
                          holdingTankLeakPressure,
                          holdingTankFragPressure,
                        ],
                        bad: [
                          holdingTankFragPressure,
                          holdingTankFragPressure * 1.15,
                        ],
                      }}
                      format={formatPressure}
                      size={1.75}
                    />
                  </LabeledList.Item>
                </LabeledList>
              )}
              {!hasHoldingTank && <Box color="average">Brak zbiornika</Box>}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
