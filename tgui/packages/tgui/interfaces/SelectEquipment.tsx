import { sortBy, uniq } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Image,
  Input,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type OutfitEntry = {
  category: string;
  name: string;
  priority: boolean;
  // zwykłe stroje mają ścieżkę typu, własne stroje admina mają REF
  path?: string;
  ref?: string;
};

type Data = {
  name: string;
  icon64: string;
  current_outfit: string;
  outfits: OutfitEntry[];
  custom_outfits: OutfitEntry[];
};

// Kategoria własnych strojów (nazwa wysyłana z DM)
const CUSTOM_CATEGORY = 'Własne';

// here's an important mental define:
// custom outfits give a ref keyword instead of path
function getOutfitKey(outfit: OutfitEntry) {
  return outfit.path || outfit.ref || '';
}

export function SelectEquipment(props) {
  const { data } = useBackend<Data>();
  const { name, icon64, current_outfit } = data;

  const outfits = [...(data.outfits || []), ...(data.custom_outfits || [])];

  // even if no custom outfits were sent, we still want to make sure there's
  // at least a custom tab so the button to create a new one pops up
  const categories = uniq([
    ...outfits.map((entry) => entry.category),
    CUSTOM_CATEGORY,
  ]);
  const [tab, setTab] = useState(categories[0]);
  const [searchText, setSearchText] = useState('');
  const searchFilter = createSearch(
    searchText,
    (entry: OutfitEntry) => entry.name + (entry.path || ''),
  );

  const visibleOutfits = sortBy(
    outfits.filter((entry) => entry.category === tab).filter(searchFilter),
    [(entry) => !entry.priority, (entry) => entry.name],
  );

  const currentOutfitEntry = outfits.find(
    (outfit) => getOutfitKey(outfit) === current_outfit,
  );

  return (
    <Window width={650} height={415} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <Stack fill vertical>
              <Stack.Item>
                <Input
                  fluid
                  autoFocus
                  placeholder="Szukaj"
                  value={searchText}
                  onChange={setSearchText}
                />
              </Stack.Item>
              <Stack.Item>
                <DisplayTabs
                  categories={categories}
                  tab={tab}
                  onSelect={setTab}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <OutfitDisplay entries={visibleOutfits} currentTab={tab} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack fill vertical>
              <Stack.Item>
                <Section>
                  <CurrentlySelectedDisplay entry={currentOutfitEntry} />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill title={name} textAlign="center">
                  <Image
                    m={0}
                    src={`data:image/png;base64,${icon64}`}
                    height="100%"
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

type DisplayTabsProps = {
  categories: string[];
  tab: string;
  onSelect: (category: string) => void;
};

function DisplayTabs(props: DisplayTabsProps) {
  const { categories, tab, onSelect } = props;

  return (
    <Tabs textAlign="center">
      {categories.map((category) => (
        <Tabs.Tab
          key={category}
          selected={tab === category}
          onClick={() => onSelect(category)}
        >
          {category}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
}

type OutfitDisplayProps = {
  entries: OutfitEntry[];
  currentTab: string;
};

function OutfitDisplay(props: OutfitDisplayProps) {
  const { act, data } = useBackend<Data>();
  const { current_outfit } = data;
  const { entries, currentTab } = props;

  return (
    <Section fill scrollable>
      {entries.map((entry) => (
        <Button
          key={getOutfitKey(entry)}
          fluid
          ellipsis
          tooltip={entry.path || entry.name}
          selected={getOutfitKey(entry) === current_outfit}
          onClick={() =>
            act('preview', {
              path: getOutfitKey(entry),
            })
          }
          onDoubleClick={() =>
            act('applyoutfit', {
              path: getOutfitKey(entry),
            })
          }
        >
          {entry.name}
        </Button>
      ))}
      {currentTab === CUSTOM_CATEGORY && (
        <Button
          color="transparent"
          icon="plus"
          fluid
          onClick={() => act('customoutfit')}
        >
          Utwórz własny strój...
        </Button>
      )}
    </Section>
  );
}

type CurrentlySelectedDisplayProps = {
  entry?: OutfitEntry;
};

function CurrentlySelectedDisplay(props: CurrentlySelectedDisplayProps) {
  const { act, data } = useBackend<Data>();
  const { current_outfit } = data;
  const { entry } = props;

  return (
    <Stack align="center">
      <Stack.Item grow basis={0}>
        <Box color="label">Wybrany strój:</Box>
        <Tooltip content={entry?.path}>
          <Box
            style={{
              overflow: 'hidden',
              whiteSpace: 'nowrap',
              textOverflow: 'ellipsis',
            }}
          >
            {entry?.name}
          </Box>
        </Tooltip>
      </Stack.Item>
      <Stack.Item>
        <Button
          mr={0.8}
          lineHeight={2}
          color="green"
          onClick={() =>
            act('applyoutfit', {
              path: current_outfit,
            })
          }
        >
          Załóż
        </Button>
      </Stack.Item>
    </Stack>
  );
}
