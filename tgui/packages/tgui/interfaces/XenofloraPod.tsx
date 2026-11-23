// AQUILA: okno kapsuły ksenoflory, przepisane z XenofloraPod.jsx z PR tgstation/tgstation#82089 (Smartkar, SELFHELL)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

const T0C = 273.15;

type Plant = {
  name: string;
  health: number;
  growth: number;
  fruits: number;
  requirements: string[];
  missing: string[];
};

type Gas = {
  id: string;
  name: string;
  amount: number;
};

type Chemical = {
  name: string;
  color: string;
  amount: number;
};

type Data = {
  on: BooleanLike;
  working: BooleanLike;
  dome: BooleanLike;
  temperature: number;
  target_temperature: number;
  min_temperature: number;
  max_temperature: number;
  plants: Plant[];
  gases: Gas[];
  total_moles: number;
  chemicals: Chemical[];
  total_volume: number;
  max_volume: number;
};

export const XenofloraPod = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    working,
    dome,
    temperature,
    target_temperature,
    min_temperature,
    max_temperature,
    plants = [],
    gases = [],
    total_moles,
    chemicals = [],
    total_volume,
    max_volume,
  } = data;
  return (
    <Window width={520} height={620}>
      <Window.Content scrollable>
        <Section
          title="Kapsuła"
          buttons={
            <>
              <Button
                icon={on ? 'power-off' : 'times'}
                selected={on}
                onClick={() => act('power')}
              >
                {on ? 'Wł.' : 'Wył.'}
              </Button>
              <Button
                icon="tree"
                selected={dome}
                disabled={!working}
                onClick={() => act('dome')}
              >
                {dome ? 'Kopuła zamknięta' : 'Kopuła otwarta'}
              </Button>
            </>
          }
        >
          {!working && (
            <NoticeBox>
              Kapsuła nie działa: włącz ją i podłącz zasilanie.
            </NoticeBox>
          )}
          <LabeledList>
            <LabeledList.Item label="Temperatura">
              {toFixed(temperature - T0C, 1)} °C ({toFixed(temperature, 1)} K)
            </LabeledList.Item>
            <LabeledList.Item label="Temperatura docelowa">
              <NumberInput
                value={Math.round(target_temperature - T0C)}
                unit="°C"
                width="70px"
                minValue={Math.round(min_temperature - T0C)}
                maxValue={Math.round(max_temperature - T0C)}
                step={1}
                stepPixelSize={3}
                onChange={(value) =>
                  act('target', {
                    target: value + T0C,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Rośliny">
          {plants.length === 0 && (
            <Box color="label">W kapsule nic nie rośnie.</Box>
          )}
          <Stack vertical>
            {plants.map((plant, index) => (
              <Stack.Item key={index}>
                <Box bold mb={1}>
                  {plant.name}
                </Box>
                <LabeledList>
                  <LabeledList.Item label="Zdrowie">
                    <ProgressBar
                      value={plant.health}
                      minValue={0}
                      maxValue={100}
                      ranges={{
                        bad: [0, 40],
                        average: [40, 70],
                        good: [70, 100],
                      }}
                    >
                      {plant.health + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Wzrost">
                    <ProgressBar
                      value={plant.growth}
                      minValue={0}
                      maxValue={100}
                      color="good"
                    >
                      {plant.growth + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Owoce do zebrania">
                    {plant.fruits}
                  </LabeledList.Item>
                  {plant.requirements.length > 0 && (
                    <LabeledList.Item label="Wymagania">
                      {plant.requirements.join(', ')}
                    </LabeledList.Item>
                  )}
                  {plant.missing.length > 0 && (
                    <LabeledList.Item label="Brakuje" color="bad">
                      {plant.missing.join(', ')}
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
        <Section title={dome ? 'Gazy pod kopułą' : 'Gazy w pomieszczeniu'}>
          {gases.length === 0 && <Box color="label">Brak gazów.</Box>}
          <LabeledList>
            {gases.map((gas) => (
              <LabeledList.Item
                key={gas.id}
                label={getGasLabel(gas.id, gas.name)}
              >
                <ProgressBar
                  color={getGasColor(gas.id)}
                  value={gas.amount}
                  minValue={0}
                  maxValue={Math.max(1, total_moles)}
                >
                  {toFixed(gas.amount, 2) + ' mol'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Zbiornik odczynników">
          {chemicals.length === 0 && (
            <Box color="label">Zbiornik jest pusty.</Box>
          )}
          <LabeledList>
            <LabeledList.Item label="Objętość">
              {toFixed(total_volume, 1)}/{max_volume} j.
            </LabeledList.Item>
            {chemicals.map((chemical) => (
              <LabeledList.Item key={chemical.name} label={chemical.name}>
                <ProgressBar
                  color={chemical.color}
                  value={chemical.amount}
                  minValue={0}
                  maxValue={Math.max(1, max_volume)}
                >
                  {toFixed(chemical.amount, 1) + ' j.'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
