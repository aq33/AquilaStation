import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';

type Data = {
  beaker: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  biomass: number;
  can_process: BooleanLike;
  categories: Category[];
  processing: BooleanLike;
  reagent_color: string | null;
};

type Category = {
  items: Design[] | null;
  name: string;
};

type Design = {
  /** Our DM keys designs by id, tg by type path. */
  id: string;
  /** Biomass per unit, already divided by the machine's efficiency. */
  cost: number;
  is_reagent: BooleanLike;
  name: string;
};

/** The most the machine makes in one order, from the clamp in ui_act. */
const MAX_OUTPUT = 10;

/** AQUILA: the search bar shows at most this many results. */
const MAX_SEARCH_RESULTS = 25;

export function Biogenerator(props) {
  const { data } = useBackend<Data>();
  const {
    beaker,
    beakerCurrentVolume,
    beakerMaxVolume,
    categories = [],
  } = data;

  const [selectedCategory, setSelectedCategory] = useState(categories[0]?.name);
  const [searchText, setSearchText] = useState('');

  const testSearch = createSearch(searchText, (item: Design) => item.name);

  const items =
    searchText.length > 0
      ? // AQUILA: search through every category at once
        categories
          .flatMap((category) => category.items || [])
          .filter(testSearch)
          .slice(0, MAX_SEARCH_RESULTS)
      : categories.find((category) => category.name === selectedCategory)
          ?.items || [];

  const space = beaker ? beakerMaxVolume - beakerCurrentVolume : 1;

  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Controls />
          </Stack.Item>
          <Stack.Item>
            <SearchBar
              query={searchText}
              onSearch={setSearchText}
              placeholder="Szukaj produktów..."
            />
          </Stack.Item>
          {searchText.length === 0 && (
            <Stack.Item>
              <Tabs fluid>
                {categories.map(({ name }) => (
                  <Tabs.Tab
                    align="center"
                    key={name}
                    selected={name === selectedCategory}
                    onClick={() => setSelectedCategory(name)}
                  >
                    {name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill scrollable>
              {items.length === 0 && (
                <NoticeBox>
                  {searchText.length === 0
                    ? 'Brak produktów w tej kategorii.'
                    : 'Nic nie znaleziono.'}
                </NoticeBox>
              )}
              <Table>
                {items.map((item) => (
                  <Item key={item.id} item={item} space={space} />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function Controls() {
  const { act, data } = useBackend<Data>();
  const {
    beaker,
    beakerCurrentVolume,
    beakerMaxVolume,
    biomass,
    can_process,
    processing,
    reagent_color,
  } = data;

  return (
    <Section fill>
      <LabeledList>
        <LabeledList.Item
          label="Biomasa"
          buttons={
            <Button
              width={7}
              lineHeight={2}
              icon="cog"
              iconSpin={!!processing}
              disabled={!can_process || !!processing}
              onClick={() => act('activate')}
            >
              Przetwórz
            </Button>
          }
        >
          {/* Our biogenerator has no biomass cap, so a plain counter instead of tg's bar. */}
          <Box lineHeight={2} bold color={biomass > 0 ? 'good' : 'bad'}>
            {`${parseFloat(biomass.toFixed(2))} jednostek`}
          </Box>
        </LabeledList.Item>
        {!!beaker && (
          <LabeledList.Item
            label="Pojemnik"
            buttons={
              <Button
                width={7}
                lineHeight={2}
                align="center"
                icon="eject"
                onClick={() => act('detach')}
              >
                Wysuń
              </Button>
            }
          >
            <ProgressBar
              value={beakerCurrentVolume}
              minValue={0}
              height={2}
              maxValue={beakerMaxVolume}
              color={reagent_color || 'good'}
            >
              <Box
                lineHeight={1.9}
                style={{
                  textShadow: '1px 1px 0 black',
                }}
              >
                {`${beakerCurrentVolume} z ${beakerMaxVolume} jednostek`}
              </Box>
            </ProgressBar>
          </LabeledList.Item>
        )}
        {!beaker && (
          <LabeledList.Item label="Pojemnik">
            <NoticeBox m={0} height={2}>
              Brak pojemnika na płyny
            </NoticeBox>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

type Props = {
  item: Design;
  space: number;
};

function Item(props: Props) {
  const { item, space } = props;
  const { cost, id, is_reagent, name } = item;

  const { act, data } = useBackend<Data>();
  const { biomass, beaker, processing } = data;

  const minAmount = is_reagent ? Math.min(Math.max(space, 1), MAX_OUTPUT) : 1;

  const [amount, setAmount] = useState(minAmount);

  // Our biogenerator needs a container in for every product, not only reagents.
  const disabled =
    !!processing ||
    !beaker ||
    (!!is_reagent && space < amount) ||
    biomass < cost * amount;

  const maxPossible = cost > 0 ? Math.floor(biomass / cost) : MAX_OUTPUT;
  const maxAmount = Math.max(1, Math.min(MAX_OUTPUT, maxPossible));

  return (
    <Table.Row>
      <Table.Cell>
        <span
          className={classes(['design32x32', id])}
          style={{
            verticalAlign: 'middle',
          }}
        />{' '}
        <b>{name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          value={amount}
          step={1}
          width="40px"
          minValue={1}
          maxValue={maxAmount}
          onChange={(value) => setAmount(value)}
        />
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          width={5}
          icon="leaf"
          iconPosition="right"
          textAlign="right"
          disabled={disabled}
          onClick={() =>
            act('create', {
              id: id,
              amount: amount,
            })
          }
        >
          {parseFloat((cost * amount).toFixed(2))}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
}
