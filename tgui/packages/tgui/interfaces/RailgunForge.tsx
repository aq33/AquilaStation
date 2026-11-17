// NSV13

import {
  Box,
  Button,
  Dropdown,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: podgląd kutego pocisku (aquila/code/modules/munitions_forge/railgun_preview.dm)
type Preview = {
  damage: number;
  penetration: number;
  velocity: number;
  burn: number;
  light: boolean;
};

type PreviewData = {
  slug: Preview;
  canister: Preview;
  plain_damage: number;
  uranium_damage: number;
};

type Data = {
  preview: PreviewData | null;
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

// AQUILA: liczby pocisku i kanistru przed wykuciem, przy pełnym wyrównaniu szyn
const ForgePreview = (props: { preview: PreviewData | null }) => {
  const { preview } = props;
  if (!preview) {
    return (
      <Section title="Podgląd">
        <Box color="label">
          Wybierz materiał obu zbiorników, żeby zobaczyć wynik.
        </Box>
      </Section>
    );
  }
  const { slug, canister } = preview;
  const slugColor =
    slug.damage < preview.plain_damage
      ? 'bad'
      : slug.damage >= preview.uranium_damage
        ? 'good'
        : undefined;
  return (
    <Section title="Podgląd (pełne wyrównanie szyn)">
      <LabeledList>
        <LabeledList.Item label="Pocisk 400 mm">
          <Box color={slugColor}>
            {`${slug.damage} obrażeń, przebicie ${slug.penetration}, prędkość ${slug.velocity}`}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Kanister 800 mm">
          {`${canister.damage} obrażeń bez gazu, przebicie ${canister.penetration}, prędkość ${canister.velocity}`}
        </LabeledList.Item>
        <LabeledList.Item label="Dla porównania">
          {`zwykły pocisk ${preview.plain_damage}, uranowy ${preview.uranium_damage}`}
        </LabeledList.Item>
      </LabeledList>
      {slug.damage < preview.plain_damage && (
        <Box mt={1} color="bad">
          Ta para materiałów da pocisk słabszy niż zwykły.
        </Box>
      )}
      {!!slug.burn && (
        <Box mt={1} color="average">
          Plazma: pocisk podpala cel, ale może sam wybuchnąć.
        </Box>
      )}
      {!!slug.light && (
        <Box mt={1} color="average">
          Bananium: lekki pocisk bez przebicia.
        </Box>
      )}
    </Section>
  );
};

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
    preview,
  } = data;
  return (
    <Window width={460} height={500}>
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
        <ForgePreview preview={preview} />
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
