import { useState } from 'react';
import {
  Box,
  Button,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: terminal S.R.O.K.A. złomiarzy (u Goona M4GP13): skup złomu i sklep za punkty (motyw „salvager”).
type ShopItem = {
  path: string;
  name: string;
  desc: string;
  price: number;
  category: string;
  icon: string;
};

type Held = {
  name: string;
  value: number;
  icon: string;
};

type Data = {
  points: number;
  earned: number;
  crew_points: number;
  goal: number;
  held: Held | null;
  categories: string[];
  shop: ShopItem[];
};

const SalvagerSprite = (props: { icon: string; size: number }) => (
  <img
    className="Salvager__sprite"
    src={`data:image/png;base64,${props.icon}`}
    style={{ width: `${props.size}px`, height: `${props.size}px` }}
  />
);

export const SalvagerTrader = () => {
  const { act, data } = useBackend<Data>();
  const {
    points,
    earned,
    crew_points,
    goal,
    held,
    categories = [],
    shop = [],
  } = data;
  const [category, setCategory] = useState(categories[0] ?? '');
  const shown = shop.filter((item) => item.category === category);

  return (
    <Window width={620} height={720} theme="salvager">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Box className="Salvager__hazard" />
            <Stack align="center" mt={1}>
              <Stack.Item grow>
                <Box
                  fontSize="22px"
                  bold
                  color="#e0902c"
                  style={{ letterSpacing: '0.2em', fontFamily: 'Consolas' }}
                >
                  S.R.O.K.A.
                </Box>
                <Box color="label" fontSize="11px">
                  System Rozliczeń Odzysku i Kupna Asortymentu
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box className="Salvager__display" textAlign="right">
                  <Box fontSize="20px">{points} pkt</Box>
                  <Box fontSize="10px">zarobione: {earned}</Box>
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section title="Cel załogi">
              <ProgressBar
                value={crew_points}
                maxValue={goal || 1}
                ranges={{
                  good: [goal, Infinity],
                  average: [-Infinity, goal],
                }}
              >
                {crew_points} / {goal} pkt
              </ProgressBar>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Skup">
              {held ? (
                <Stack align="center">
                  <Stack.Item>
                    <SalvagerSprite icon={held.icon} size={48} />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box bold>{held.name}</Box>
                    <Box color={held.value ? 'good' : 'label'}>
                      {held.value
                        ? `Wartość: ${held.value} pkt`
                        : 'Bez wartości dla kupca'}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="coins"
                      fontSize="14px"
                      disabled={!held.value}
                      onClick={() => act('sell')}
                    >
                      Sprzedaj
                    </Button>
                  </Stack.Item>
                </Stack>
              ) : (
                <Box color="label">
                  Weź przedmiot do aktywnej ręki albo uderz nim terminal, żeby
                  go wycenić.
                </Box>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Sklep">
              <Tabs>
                {categories.map((name) => (
                  <Tabs.Tab
                    key={name}
                    selected={name === category}
                    onClick={() => setCategory(name)}
                  >
                    {name}
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Box
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(3, 1fr)',
                  gap: '6px',
                }}
              >
                {shown.map((item) => {
                  const afford = points >= item.price;
                  return (
                    <Box
                      key={item.path}
                      className={
                        afford
                          ? 'Salvager__card Salvager__card--afford'
                          : 'Salvager__card'
                      }
                    >
                      <SalvagerSprite icon={item.icon} size={48} />
                      <Box fontSize="11px" bold style={{ minHeight: '28px' }}>
                        {item.name}
                      </Box>
                      <Button
                        fluid
                        mt={0.5}
                        disabled={!afford}
                        tooltip={item.desc}
                        onClick={() => act('buy', { path: item.path })}
                      >
                        {item.price} pkt
                      </Button>
                    </Box>
                  );
                })}
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
