import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';

type Material = {
  name: string;
  amount: number;
  icon_state?: string | null;
  icon?: string | null;
  id: string;
  value?: number;
};

type DiskDesign = {
  name: string;
  index: number;
  canupload: BooleanLike;
};

type User = {
  cash: number;
  name: string;
};

type Data = {
  disconnected: string | null;
  materials: Material[];
  alloys: Material[] | null;
  unclaimedPoints: number;
  user: User | null;
  // AQUILA: dysk z projektami stopów
  hasDisk: BooleanLike;
  diskDesigns: DiskDesign[];
};

type Category = 'material' | 'alloy';

type Entry = {
  material: Material;
  category: Category;
};

export function OreRedemptionMachine(props) {
  const [compact, setCompact] = useState(false);
  const [searchItem, setSearchItem] = useState('');

  return (
    <Window title="Maszyna wymiany rudy" width={435} height={560}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <IDSection compact={compact} setCompact={setCompact} />
          </Stack.Item>
          <Stack.Item>
            <PointsSection />
          </Stack.Item>
          <NoticeBox info mb={0}>
            Maszyna przyjmuje tylko rudę. Gibtonit i żużel nie są przyjmowane.
          </NoticeBox>
          <Stack.Item>
            <DiskSection />
          </Stack.Item>
          <Stack.Item mb={-1}>
            <MaterialSearchHeader
              searchItem={searchItem}
              setSearchItem={setSearchItem}
            />
          </Stack.Item>
          <Stack.Item grow>
            <MaterialSection compact={compact} searchItem={searchItem} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

type MaterialRowProps = {
  compact: boolean;
  material: Material;
  onRelease: (amount: string | number) => void;
};

function MaterialRow(props: MaterialRowProps) {
  const { compact, material, onRelease } = props;

  const sheet_amounts = Math.floor(material.amount);
  const print_amount = 5;
  const max_sheets = 50;

  return (
    <Table.Row className="candystripe">
      {!compact && (
        <Table.Cell collapsing>
          {material.icon ? (
            <DmIcon
              height="18px"
              width="18px"
              icon={material.icon}
              icon_state={material.icon_state || ''}
              fallback={<Icon name="spinner" spin />}
            />
          ) : (
            <Icon name="cube" />
          )}
        </Table.Cell>
      )}
      <Table.Cell>{toTitleCase(material.name).replace('Alloy', '')}</Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Box color="label">{formatSiUnit(sheet_amounts, 0)} ark.</Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Button
          color="transparent"
          disabled={sheet_amounts < 1}
          tooltip={material.value ? `${material.value} cr` : 'Bez kosztów'}
          onClick={() => onRelease(1)}
        >
          x1
        </Button>
        <Button
          color="transparent"
          disabled={sheet_amounts < 1}
          tooltip={
            material.value
              ? `${material.value * print_amount} cr`
              : 'Bez kosztów'
          }
          onClick={() => onRelease(print_amount)}
        >
          x{print_amount}
        </Button>
        <Button.Input
          buttonText={`[Maks.: ${Math.min(sheet_amounts, max_sheets)}]`}
          color="transparent"
          disabled={sheet_amounts < 1}
          onCommit={onRelease}
        />
      </Table.Cell>
    </Table.Row>
  );
}

type IDSectionProps = {
  compact: boolean;
  setCompact: (compact: boolean) => void;
};

function IDSection(props: IDSectionProps) {
  const { data } = useBackend<Data>();
  const { user } = data;

  const { compact, setCompact } = props;

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Icon name="id-card" size={3} mr={1} color={user ? 'green' : 'red'} />
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Imię">
              {user?.name || 'Nie wykryto karty'}
            </LabeledList.Item>
            <LabeledList.Item label="Punkty na karcie">
              {user ? user.cash : 'Brak'}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Button
            color={compact ? 'red' : 'green'}
            onClick={() => setCompact(!compact)}
          >
            Kompaktowo
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function PointsSection(props) {
  const { act, data } = useBackend<Data>();
  const { disconnected, unclaimedPoints } = data;

  return (
    <Section>
      <Stack fill>
        <Stack.Item grow>
          <Icon name="coins" color="gold" />
          <Box inline color="label" ml={1}>
            Nieodebrane punkty:
          </Box>
          {` ${unclaimedPoints}`}
        </Stack.Item>
        <Stack.Item>
          <Button
            ml={2}
            disabled={unclaimedPoints === 0}
            onClick={() => act('Claim')}
          >
            Odbierz
          </Button>
        </Stack.Item>
      </Stack>
      {!!disconnected && (
        <Box mt={1} color="average">
          <Icon name="triangle-exclamation" mr={1} />
          {disconnected}
        </Box>
      )}
    </Section>
  );
}

/** AQUILA: wgrywanie projektów stopów z dysku */
function DiskSection(props) {
  const { act, data } = useBackend<Data>();
  const { hasDisk, diskDesigns = [] } = data;

  if (!hasDisk) {
    return (
      <Button icon="save" onClick={() => act('diskInsert')}>
        Włóż dysk z projektami
      </Button>
    );
  }

  return (
    <Section
      title="Dysk z projektami"
      buttons={
        <Button icon="eject" onClick={() => act('diskEject')}>
          Wyjmij dysk
        </Button>
      }
    >
      {diskDesigns.length === 0 && <Box color="label">Dysk jest pusty.</Box>}
      <Table>
        {diskDesigns.map((design) => (
          <Table.Row key={design.index}>
            <Table.Cell>
              Plik {design.index}: {design.name}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                disabled={!design.canupload}
                onClick={() =>
                  act('diskUpload', {
                    design: design.index,
                  })
                }
              >
                Wgraj
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

type MaterialSectionProps = {
  compact: boolean;
  searchItem: string;
};

function MaterialSection(props: MaterialSectionProps) {
  const { act, data } = useBackend<Data>();
  const { materials = [], alloys } = data;

  const { compact, searchItem } = props;

  const [tab] = useSharedState<Category>('tab', 'material');

  const all: Entry[] = [
    ...materials.map((material): Entry => ({ material, category: 'material' })),
    ...(alloys || []).map(
      (material): Entry => ({ material, category: 'alloy' }),
    ),
  ];

  const search = createSearch(
    searchItem,
    (entry: Entry) => entry.material.name,
  );
  const filtered =
    searchItem.length > 0
      ? all.filter(search)
      : all.filter((entry) => !!entry.material && entry.category === tab);

  return (
    <Section fill scrollable>
      <Table>
        {filtered.map(({ material, category }) => (
          <MaterialRow
            compact={compact}
            key={material.id}
            material={material}
            onRelease={(amount) => {
              if (category === 'material') {
                act('Release', {
                  id: material.id,
                  sheets: amount,
                });
              } else {
                act('Smelt', {
                  id: material.id,
                  sheets: amount,
                });
              }
            }}
          />
        ))}
      </Table>
    </Section>
  );
}

type SearchProps = {
  searchItem: string;
  setSearchItem: (searchItem: string) => void;
};

function MaterialSearchHeader(props: SearchProps) {
  const { searchItem, setSearchItem } = props;

  const [tab, setTab] = useSharedState<Category>('tab', 'material');

  return (
    <Section>
      <Stack>
        <Stack.Item grow>
          <Tabs>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'material'}
              onClick={() => {
                setTab('material');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              Materiały
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'alloy'}
              onClick={() => {
                setTab('alloy');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              Stopy
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <SearchBar
            expensive
            style={{ height: '23px' }}
            query={searchItem}
            placeholder="Szukaj materiału..."
            onSearch={(value) => {
              setSearchItem(value);
              if (value.length > 0) {
                setTab('material');
              }
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
