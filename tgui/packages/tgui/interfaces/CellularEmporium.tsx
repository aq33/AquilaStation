import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: wygląd z tg na danych naszego cellular_emporium.dm (zakup po nazwie,
// kategorie: żądła i reszta zdolności)

// ==========
// Types
// ==========
type Ability = {
  name: string;
  desc: string;
  helptext: string;
  owned: BooleanLike;
  dna_cost: number;
  can_purchase: BooleanLike;
  req_dna: number;
  req_absorbs: number;
  chemical_cost: number;
  icon: string;
  icon_state: string;
  bg_icon: string;
  bg_icon_state: string;
  category: string;
};

type CellularEmporiumContext = {
  abilities: Ability[];
  can_readapt: BooleanLike;
  genetic_points_remaining: number;
  absorbed_dna_count: number;
  true_absorbs: number;
};

const CATEGORY_ORDER = ['abilities', 'stings'];

const CATEGORY_NAMES = {
  abilities: 'Zdolności',
  stings: 'Żądła',
};

// ==========
// Main Component
// ==========
export const CellularEmporium = (props) => {
  const { act, data } = useBackend<CellularEmporiumContext>();
  const { abilities = [], can_readapt, genetic_points_remaining } = data;

  const [searchText, setSearchText] = useState('');
  const [compactMode, setCompactMode] = useState(false);

  const allCategories = Array.from(
    new Set(abilities.map((a) => a.category || 'abilities')),
  );
  const sortedCategories = [
    ...CATEGORY_ORDER.filter((cat) => allCategories.includes(cat)),
    ...allCategories.filter((cat) => !CATEGORY_ORDER.includes(cat)),
  ];
  const [selectedCategory, setSelectedCategory] = useState(
    sortedCategories[0] || 'abilities',
  );

  const filteredItems = (
    searchText
      ? abilities.filter((item) =>
          [item.name, item.desc, item.helptext]
            .join(' ')
            .toLowerCase()
            .includes(searchText.toLowerCase()),
        )
      : abilities.filter(
          (item) => (item.category || 'abilities') === selectedCategory,
        )
  ).sort((a, b) => a.name.localeCompare(b.name));

  const handleBuy = (ability: Ability) => {
    act('evolve', { name: ability.name });
  };

  return (
    <Window width={900} height={520}>
      <Window.Content
        scrollable={false}
        style={{
          backgroundImage: "url('tgui-core/assets/bg-nanotrasen.svg')",
          backgroundSize: 'cover',
          backgroundRepeat: 'no-repeat',
          backgroundColor: '#1A1A1A',
          overflowY: 'auto',
        }}
      >
        <Section
          fill
          scrollable={false}
          title={
            <Stack fill>
              <Stack.Item fontSize="16px" color="#DD66DD" ml={1}>
                <Icon name="dna" /> {genetic_points_remaining} pkt genetycznych
              </Stack.Item>
              <Stack.Item grow />
              <Stack.Item>
                <Button
                  icon="undo"
                  color="good"
                  disabled={!can_readapt}
                  tooltip={
                    can_readapt
                      ? 'Cofnij ewolucję wszystkich zdolności i odzyskaj punkty genetyczne.'
                      : 'Aby przystosować się na nowo, musisz najpierw kogoś wchłonąć.'
                  }
                  onClick={() => act('readapt')}
                >
                  Przystosuj się na nowo
                </Button>
              </Stack.Item>
            </Stack>
          }
        >
          <Stack fill>
            <Stack.Item width="180px">
              <Stack vertical fill>
                <Stack.Item>
                  <Input
                    autoFocus
                    value={searchText}
                    placeholder="Szukaj..."
                    onChange={setSearchText}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    lineHeight={2}
                    textAlign="center"
                    icon={compactMode ? 'maximize' : 'minimize'}
                    tooltip={compactMode ? 'Widok szczegółowy' : 'Widok zwarty'}
                    onClick={() => setCompactMode(!compactMode)}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Tabs vertical fill>
                    {sortedCategories.map((category) => (
                      <Tabs.Tab
                        key={category}
                        selected={category === selectedCategory}
                        onClick={() => {
                          setSelectedCategory(category);
                          if (searchText) setSearchText('');
                        }}
                        mt={1}
                      >
                        {CATEGORY_NAMES[category] || category}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item grow>
              <Box height="100%" pr={1} mr={-1}>
                {filteredItems.length === 0 ? (
                  <NoticeBox>
                    {searchText
                      ? 'Nie znaleziono zdolności.'
                      : 'Brak zdolności w tej kategorii.'}
                  </NoticeBox>
                ) : (
                  <ItemList
                    compactMode={searchText.length > 0 || compactMode}
                    items={filteredItems}
                    handleBuy={handleBuy}
                  />
                )}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

// ==========
// ItemList Component
// ==========
type ItemListProps = {
  compactMode: BooleanLike;
  items: Ability[];
  handleBuy: (item: Ability) => void;
};

const ItemList = (props: ItemListProps) => {
  const { compactMode, items, handleBuy } = props;

  const iconSize = compactMode ? '32px' : '64px';

  return (
    <Section fill scrollable>
      <Stack vertical mt={compactMode ? 0.5 : 0}>
        {items.map((ability) => {
          const owned = !!ability.owned;
          const canAfford = !owned && !!ability.can_purchase;

          const requirementTooltip = [
            `${ability.dna_cost} pkt genetycznych`,
            ...(ability.req_absorbs > 0
              ? [`wchłonięcia: ${ability.req_absorbs}`]
              : []),
            ...(ability.req_dna > 0 ? [`zebrane DNA: ${ability.req_dna}`] : []),
            ...(ability.chemical_cost > 0
              ? [`zużywa ${ability.chemical_cost} chemikaliów`]
              : []),
          ].join(', ');

          const costDisplay = `Koszt: ${ability.dna_cost} pkt`;

          return (
            <Stack.Item key={ability.name} mt={compactMode ? 0.5 : 1}>
              <Section fitted={!!compactMode}>
                <Stack>
                  <Stack.Item>
                    <Box ml={2}>
                      <Box
                        width={iconSize}
                        height={iconSize}
                        position="relative"
                        m={compactMode ? '2px' : 0}
                        mr={1}
                      >
                        <DmIcon
                          position="absolute"
                          top="0"
                          left="0"
                          icon={ability.bg_icon}
                          icon_state={ability.bg_icon_state}
                          width={iconSize}
                          fallback={null}
                        />
                        <DmIcon
                          position="absolute"
                          top="0"
                          left="0"
                          icon={ability.icon}
                          icon_state={ability.icon_state}
                          width={iconSize}
                          fallback={<Icon name="question-circle" size={3} />}
                        />
                      </Box>
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    {compactMode ? (
                      <Stack>
                        <Stack.Item
                          bold
                          grow
                          lineHeight="36px"
                          style={{
                            overflow: 'hidden',
                            whiteSpace: 'nowrap',
                            textOverflow: 'ellipsis',
                            opacity: owned ? '0.5' : '1',
                          }}
                        >
                          {owned ? (
                            <Box color="#44bd46">
                              <Icon mr="8px" name="check" />
                              {ability.name}
                            </Box>
                          ) : (
                            ability.name
                          )}
                        </Stack.Item>
                        <Stack.Item>
                          <Tooltip content={ability.helptext || ability.desc}>
                            <Icon name="info-circle" lineHeight="36px" />
                          </Tooltip>
                        </Stack.Item>
                        <Stack.Item>
                          <Tooltip content={requirementTooltip}>
                            <Button
                              m="8px"
                              color={canAfford ? 'average' : 'bad'}
                              disabled={owned || !canAfford}
                              onClick={() => handleBuy(ability)}
                            >
                              {costDisplay}
                            </Button>
                          </Tooltip>
                        </Stack.Item>
                      </Stack>
                    ) : (
                      <Section
                        title={
                          <Box>
                            {ability.name}
                            {owned && (
                              <Box color="#44bd46" inline ml={1}>
                                (posiadana)
                              </Box>
                            )}
                          </Box>
                        }
                        buttons={
                          <Tooltip content={requirementTooltip}>
                            <Box mt={-3}>
                              <Button
                                disabled={owned || !canAfford}
                                color={
                                  owned ? 'good' : canAfford ? 'average' : 'bad'
                                }
                                onClick={() => handleBuy(ability)}
                              >
                                {costDisplay}
                              </Button>
                            </Box>
                          </Tooltip>
                        }
                      >
                        <Box opacity={0.8}>{ability.desc}</Box>
                        {!!ability.helptext && (
                          <Box color="#44bd46" mt={0.5}>
                            {ability.helptext}
                          </Box>
                        )}
                      </Section>
                    )}
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};
