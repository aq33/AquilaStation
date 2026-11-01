// NSV13

import {
  Button,
  Dropdown,
  Flex,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  t1_alloy_lock: any;
  t1_material: any;
  t1_processing: any;
  t1_volume: any;
  t2_alloy_lock: any;
  t2_material: any;
  t2_processing: any;
  t2_volume: any;
};

// AQUILA: wartości idą do DM (t1_list/t2_list), tłumaczymy tylko napis
const MATERIALS = [
  { value: 'Iron', displayText: 'Żelazo' },
  { value: 'Silver', displayText: 'Srebro' },
  { value: 'Gold', displayText: 'Złoto' },
  { value: 'Diamond', displayText: 'Diament' },
  { value: 'Uranium', displayText: 'Uran' },
  { value: 'Plasma', displayText: 'Plazma' },
  { value: 'Bluespace', displayText: 'Bluespace' },
  { value: 'Bananium', displayText: 'Bananium' },
  { value: 'Titanium', displayText: 'Tytan' },
  { value: 'Copper', displayText: 'Miedź' },
];

const materialName = (value: string) =>
  MATERIALS.find((material) => material.value === value)?.displayText || value;

export const RailgunForge = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    t1_volume,
    t1_alloy_lock,
    t1_processing,
    t1_material,
    t2_volume,
    t2_alloy_lock,
    t2_processing,
    t2_material,
  } = data;
  return (
    <Window width={460} height={350}>
      <Window.Content scrollable>
        <Section>
          <Button
            content="Drukuj pocisk"
            icon="paperclip"
            onClick={() => act('print_slug')}
          />
          <Button
            content="Drukuj pocisk z kanistrem"
            icon="tg-air-tank"
            onClick={() => act('print_canister')}
          />
        </Section>
        <br />
        <Section title="Zbiornik powłoki">
          <Flex>
            <Flex.Item>
              <Dropdown
                overflow-y="scroll"
                selected={t1_material}
                displayText={materialName(t1_material)}
                options={MATERIALS}
                onSelected={(value) => act('t1_list', { value })}
              />
            </Flex.Item>
            Zapełnienie zbiornika:
            <Flex.Item width="200px">
              <ProgressBar
                value={data.t1_volume / 100}
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.25, 0.75],
                  bad: [-Infinity, 0.25],
                }}
              />
            </Flex.Item>
          </Flex>
          <Button
            content="Ustaw materiał zbiornika powłoki"
            icon="exclamation-triangle"
            color={data.t1_alloy_lock && 'good'}
            onClick={() => act('t1_set_material')}
          />
          <Button
            content="Przetwarzaj zbiornik 1"
            icon="exclamation-triangle"
            color={data.t1_processing && 'good'}
            onClick={() => act('t1_set_processing')}
          />
          <Button
            content="Opróżnij zbiornik 1"
            icon="exclamation-triangle"
            color={'bad'}
            onClick={() => act('purge_t1')}
          />
        </Section>
        <Section title="Zbiornik rdzenia">
          <Flex>
            <Flex.Item>
              <Dropdown
                overflow-y="scroll"
                selected={t2_material}
                displayText={materialName(t2_material)}
                options={MATERIALS}
                onSelected={(value) => act('t2_list', { value })}
              />
            </Flex.Item>
            Zapełnienie zbiornika:
            <Flex.Item width="200px">
              <ProgressBar
                value={data.t2_volume / 100}
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.25, 0.75],
                  bad: [-Infinity, 0.25],
                }}
              />
            </Flex.Item>
          </Flex>
          <Button
            content="Ustaw materiał zbiornika rdzenia"
            icon="exclamation-triangle"
            color={data.t2_alloy_lock && 'good'}
            onClick={() => act('t2_set_material')}
          />
          <Button
            content="Przetwarzaj zbiornik 2"
            icon="exclamation-triangle"
            color={data.t2_processing && 'good'}
            onClick={() => act('t2_set_processing')}
          />
          <Button
            content="Opróżnij zbiornik 2"
            icon="exclamation-triangle"
            color={'bad'}
            onClick={() => act('purge_t2')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
