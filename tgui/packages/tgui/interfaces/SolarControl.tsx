import {
  Box,
  Button,
  Chart,
  Icon,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  supply: number;
  capacity: number;
  angle: number;
  tracking_rate: number;
  tracking_state: number;
  connected_panels: number;
  connected_tracker: BooleanLike;
  history: History;
};

type History = {
  supply: number[];
  capacity: number[];
};

export const SolarControl = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    supply,
    capacity,
    angle,
    tracking_rate,
    tracking_state,
    connected_panels,
    connected_tracker,
    history,
  } = data;
  const supplyHistory = history?.supply || [];
  const capacityHistory = history?.capacity || [];
  const supplyData = supplyHistory.map((value, i) => [i, value]);
  const capacityData = capacityHistory.map((value, i) => [i, value]);
  const maxValue = Math.max(1, ...capacityHistory, ...supplyHistory);

  return (
    <Window width={330} height={330}>
      <Window.Content>
        <Section title="Stan">
          <Box
            mb={1}
            position="relative"
            overflow="visible"
            height="64px"
            backgroundColor={'black'}
          >
            <Chart.Line
              p={1}
              fillPositionedParent
              data={capacityData}
              rangeX={[0, capacityData.length - 1]}
              rangeY={[0, maxValue]}
              strokeColor="rgba(150, 117, 39, 1)"
              fillColor="rgba(150, 117, 39, 0.5)"
            />
            <Chart.Line
              p={1}
              fillPositionedParent
              data={supplyData}
              rangeX={[0, supplyData.length - 1]}
              rangeY={[0, maxValue]}
              strokeColor="rgba(235, 210, 52, 1)"
              fillColor="rgba(235, 210, 52, 0.5)"
            />
          </Box>
          <Stack>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Moc wyjściowa">
                  <ProgressBar
                    value={capacity > 0 ? supply / capacity : 0}
                    minValue={0}
                    maxValue={1}
                    ranges={{
                      good: [0.66, Infinity],
                      average: [0.33, 0.66],
                      bad: [-Infinity, 0.33],
                    }}
                  >
                    {capacity > 0
                      ? `${formatPower(supply)} z ${formatPower(
                          capacity,
                        )} (${Math.round((100 * supply) / capacity)}%)`
                      : formatPower(0)}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item
                  label="Panele słoneczne"
                  color={connected_panels > 0 ? 'good' : 'bad'}
                >
                  {connected_panels}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Tracker słoneczny"
                  color={connected_tracker ? 'good' : 'bad'}
                >
                  {connected_tracker ? 'OK' : 'Brak'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="Sterowanie"
          buttons={
            <Button icon="sync" onClick={() => act('refresh')}>
              Szukaj nowego sprzętu
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Śledzenie">
              <Button
                icon="times"
                selected={tracking_state === 0}
                onClick={() => act('tracking', { mode: 0 })}
              >
                Wył.
              </Button>
              <Button
                icon="clock-o"
                selected={tracking_state === 1}
                onClick={() => act('tracking', { mode: 1 })}
              >
                Czasowe
              </Button>
              <Button
                icon="sync"
                selected={tracking_state === 2}
                disabled={!connected_tracker}
                onClick={() => act('tracking', { mode: 2 })}
              >
                Auto
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Azymut">
              <Icon mr={1} name="arrow-up" rotation={angle} />
              {(tracking_state === 0 || tracking_state === 1) && (
                <NumberInput
                  tickWhileDragging
                  width="52px"
                  unit="°"
                  step={1}
                  stepPixelSize={2}
                  minValue={-360}
                  maxValue={+720}
                  value={angle}
                  format={(value) => String(Math.round(360 + value) % 360)}
                  onChange={(value) => act('angle', { value })}
                />
              )}
              {tracking_state === 1 && (
                <NumberInput
                  tickWhileDragging
                  width="80px"
                  unit="°/h"
                  step={5}
                  stepPixelSize={2}
                  minValue={-7200}
                  maxValue={7200}
                  value={tracking_rate}
                  format={(rate) => {
                    const sign = Math.sign(rate) > 0 ? '+' : '-';
                    return sign + toFixed(Math.abs(rate));
                  }}
                  onChange={(value) => act('rate', { value })}
                />
              )}
              {tracking_state === 2 && (
                <Box inline color="label" mt="3px">
                  {`${angle} °`} (auto)
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
