// AQUILA - okno pieca łukowego kuźni amunicji (zamiast form odlewniczych): wyrób, materiał albo stop, klasa,
// koszt z silosu i właściwości wyrobu.

import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Product = {
  id: string;
  name: string;
};

type Group = {
  name: string;
  items: Product[];
};

type Quality = {
  level: number;
  roman: string;
  name: string;
};

type Material = {
  id: string;
  name: string;
  sheets: number;
};

type Cost = {
  name: string;
  need: number;
  have: number;
};

type Stat = {
  name: string;
  value: string;
};

type Data = {
  groups: Group[];
  qualities: Quality[];
  connected: boolean;
  silo: boolean;
  operating: boolean;
  produced: string | null;
  working_part: string | null;
  working_heat: number | null;
  selected_product: string;
  selected_material: string;
  selected_alloy: string | null;
  selected_quality: number;
  uses_material: boolean;
  locked: string[];
  materials: Material[];
  cost: Cost[];
  can_cast: boolean;
  stats: Stat[];
  rough: boolean;
  empty: boolean;
};

export const MunitionsForge = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    groups = [],
    qualities = [],
    materials = [],
    cost = [],
    stats = [],
    locked = [],
  } = data;
  const current = materials.find((m) => m.id === data.selected_material);
  const alloyOptions = [
    'bez stopu',
    ...materials
      .filter((m) => m.id !== data.selected_material)
      .map((m) => m.name),
  ];
  const alloyName =
    materials.find((m) => m.id === data.selected_alloy)?.name || 'bez stopu';
  return (
    <Window width={720} height={560} title="Piec łukowy">
      <Window.Content>
        {!data.connected && (
          <NoticeBox danger>
            Piec nie jest połączony z magazynem materiałów.
          </NoticeBox>
        )}
        {!!data.empty && (
          <NoticeBox>
            {data.silo
              ? 'Silos rudy jest pusty. Włóż arkusze do pieca (trafią do silosu) albo poproś górników i zaopatrzenie o rudę.'
              : 'Zapas pieca jest pusty. Włóż do niego arkusze materiałów.'}
          </NoticeBox>
        )}
        <Stack fill>
          <Stack.Item width="34%">
            <Section fill scrollable title="Wyrób">
              {groups.map((group) => (
                <Box key={group.name} mb={1}>
                  <Box color="label" mb={0.5}>
                    {group.name}
                  </Box>
                  {group.items.map((item) => (
                    <Button
                      key={item.id}
                      fluid
                      selected={item.id === data.selected_product}
                      disabled={locked.includes(item.id)}
                      tooltip={
                        locked.includes(item.id)
                          ? 'Wymaga zbadania głowic torped w R&D.'
                          : undefined
                      }
                      onClick={() => act('select_product', { id: item.id })}
                    >
                      {item.name}
                    </Button>
                  ))}
                </Box>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item width="33%">
            <Section fill scrollable title="Materiał i klasa">
              {data.uses_material ? (
                <>
                  {materials.map((mat) => (
                    <Button
                      key={mat.id}
                      fluid
                      selected={mat.id === data.selected_material}
                      onClick={() => act('select_material', { id: mat.id })}
                    >
                      {`${mat.name} (${mat.sheets} ark.)`}
                    </Button>
                  ))}
                  <Box color="label" mt={1} mb={0.5}>
                    Stop: drugi składnik po połowie
                  </Box>
                  <Dropdown
                    width="100%"
                    selected={alloyName}
                    options={alloyOptions}
                    onSelected={(value) =>
                      act('select_alloy', {
                        id:
                          materials.find((m) => m.name === value)?.id || '',
                      })
                    }
                  />
                </>
              ) : (
                <Box color="label">
                  Wypełnienia i zapalniki odlewa się zawsze z żelaza.
                </Box>
              )}
              <Box color="label" mt={1} mb={0.5}>
                Klasa jakości
              </Box>
              <Stack>
                {qualities.map((quality) => (
                  <Stack.Item key={quality.level}>
                    <Button
                      selected={quality.level === data.selected_quality}
                      tooltip={quality.name}
                      onClick={() =>
                        act('select_quality', { level: quality.level })
                      }
                    >
                      {quality.roman}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
              <Box mt={1} color={data.rough ? 'average' : 'good'}>
                {data.rough
                  ? 'Klasa I: młot wykuje ją sam, ale amunicja szybciej zużywa broń i może ją zaciąć.'
                  : 'Wyższą klasę trzeba wykuć ręcznie pod młotem; pudła obniżają klasę.'}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="Odlew">
              <LabeledList>
                {cost.map((item) => (
                  <LabeledList.Item key={item.name} label={item.name}>
                    <Box color={item.have >= item.need ? undefined : 'bad'}>
                      {`${item.need} / ${item.have} ark.`}
                    </Box>
                  </LabeledList.Item>
                ))}
                {stats.map((stat) => (
                  <LabeledList.Item key={stat.name} label={stat.name}>
                    {stat.value}
                  </LabeledList.Item>
                ))}
              </LabeledList>
              <Button
                fluid
                mt={1}
                icon="fire"
                disabled={!data.can_cast}
                onClick={() => act('cast')}
              >
                {data.operating ? 'Odlewanie...' : 'Odlej'}
              </Button>
              {!!data.produced && (
                <Button fluid mt={1} icon="hand" onClick={() => act('take')}>
                  {`Wyjmij: ${data.produced}`}
                </Button>
              )}
              {!!data.working_part && (
                <Box mt={1}>
                  <Box color="label">{`W piecu: ${data.working_part}`}</Box>
                  <Button
                    fluid
                    mt={0.5}
                    icon="temperature-high"
                    disabled={data.operating}
                    onClick={() => act('reheat')}
                  >
                    Dogrzej
                  </Button>
                </Box>
              )}
              {!current && (
                <Box mt={1} color="bad">
                  Wybierz materiał.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
