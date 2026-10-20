import {
  AnimatedNumber,
  Box,
  Button,
  NumberInput,
  Section,
  Table,
} from 'tgui-core/components';
import { round, toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerSectionDisplay, legacyBeaker } from './Chemistry/BeakerDisplay';
import type { BeakerReagent } from './common/BeakerDisplay';

type Data = {
  targetTemp: number;
  isActive: BooleanLike;
  currentTemp: number | null;
  isBeakerLoaded: BooleanLike;
  beakerCurrentVolume: number | null;
  beakerMaxVolume: number | null;
  beakerContents: BeakerReagent[];
  hasBeakerInHand: BooleanLike;
};

export const ChemHeater = (props) => {
  const { act, data } = useBackend<Data>();
  const { targetTemp, isActive, currentTemp, hasBeakerInHand } = data;
  const beaker = legacyBeaker(
    data.isBeakerLoaded,
    data.beakerCurrentVolume,
    data.beakerMaxVolume,
    data.beakerContents,
  );

  return (
    <Window width={350} height={350}>
      <Window.Content scrollable>
        <Section
          title="Sterowanie"
          buttons={
            <Button
              icon={isActive ? 'power-off' : 'times'}
              selected={isActive}
              onClick={() => act('power')}
            >
              {isActive ? 'Wł.' : 'Wył.'}
            </Button>
          }
        >
          <Table>
            <Table.Row>
              <Table.Cell collapsing color="label">
                Cel:
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  tickWhileDragging
                  width="65px"
                  unit="K"
                  step={10}
                  stepPixelSize={3}
                  value={round(targetTemp, 0.1)}
                  minValue={0}
                  maxValue={1000}
                  onChange={(value) =>
                    act('temperature', {
                      target: value,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell collapsing color="label">
                Odczyt:
              </Table.Cell>
              <Table.Cell color="default">
                <Box width="60px" textAlign="right">
                  {(!!beaker && (
                    <AnimatedNumber
                      value={currentTemp || 0}
                      format={(value) => `${toFixed(value)} K`}
                    />
                  )) ||
                    '—'}
                </Box>
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
        <BeakerSectionDisplay
          beaker={beaker}
          showInsertButton
          hasBeakerInHand={hasBeakerInHand}
        />
      </Window.Content>
    </Window>
  );
};
