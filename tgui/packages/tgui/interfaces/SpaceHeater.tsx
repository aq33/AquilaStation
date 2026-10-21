import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  currentTemp: number | string;
  hasPowercell: BooleanLike;
  maxTemp: number;
  minTemp: number;
  mode: string;
  on: BooleanLike;
  open: BooleanLike;
  powerLevel: number;
  targetTemp: number;
};

const MODE_NAMES = {
  auto: 'Automatyczny',
  heat: 'Grzanie',
  cool: 'Chłodzenie',
};

// AQUILA: bez wersji chemicznej z tg (chemHacked/beaker) - nie mamy tej mechaniki.
export const SpaceHeater = (props) => {
  const { act, data } = useBackend<Data>();
  const currentTemp = Number(data.currentTemp);
  const tempDiff = Number.isNaN(currentTemp)
    ? 0
    : Math.abs(data.targetTemp - currentTemp);
  return (
    <Window width={400} height={305}>
      <Window.Content>
        <Section
          title="Zasilanie"
          buttons={
            <>
              <Button
                icon="eject"
                content="Wyjmij ogniwo"
                disabled={!data.hasPowercell || !data.open}
                onClick={() => act('eject')}
              />
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'Wł.' : 'Wył.'}
                selected={data.on}
                disabled={!data.hasPowercell}
                onClick={() => act('power')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Ogniwo"
              color={!data.hasPowercell ? 'bad' : undefined}
            >
              {(data.hasPowercell && (
                <ProgressBar
                  value={data.powerLevel / 100}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }}
                >
                  {`${data.powerLevel}%`}
                </ProgressBar>
              )) ||
                'Brak'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Termostat">
          <LabeledList>
            <LabeledList.Item label="Obecna temperatura">
              <Box
                fontSize="18px"
                color={
                  tempDiff > 50 ? 'bad' : tempDiff > 20 ? 'average' : 'good'
                }
              >
                {Number.isNaN(currentTemp) ? 'b.d.' : `${currentTemp}°C`}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Temperatura docelowa">
              {(data.open && (
                <NumberInput
                  animated
                  value={data.targetTemp}
                  width="65px"
                  unit="°C"
                  step={1}
                  minValue={data.minTemp}
                  maxValue={data.maxTemp}
                  onChange={(value) =>
                    act('target', {
                      target: value,
                    })
                  }
                />
              )) ||
                `${data.targetTemp}°C`}
            </LabeledList.Item>
            <LabeledList.Item label="Tryb">
              {(!data.open && (MODE_NAMES[data.mode] || data.mode)) || (
                <>
                  <Button
                    icon="thermometer-half"
                    content="Auto"
                    selected={data.mode === 'auto'}
                    onClick={() =>
                      act('mode', {
                        mode: 'auto',
                      })
                    }
                  />
                  <Button
                    icon="fire-alt"
                    content="Grzanie"
                    selected={data.mode === 'heat'}
                    onClick={() =>
                      act('mode', {
                        mode: 'heat',
                      })
                    }
                  />
                  <Button
                    icon="fan"
                    content="Chłodzenie"
                    selected={data.mode === 'cool'}
                    onClick={() =>
                      act('mode', {
                        mode: 'cool',
                      })
                    }
                  />
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Divider />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
