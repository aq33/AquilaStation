// AQUILA - statystyki postaci między rundami (aquila/code/modules/character_stats/character_stats.dm)
import { useState } from 'react';
import {
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Character = {
  name: string;
  stats: Record<string, number>;
};

type Data = {
  characters: Character[];
  current?: string;
};

type StatGroup = {
  title: string;
  stats: [string, string][];
};

const STAT_GROUPS: StatGroup[] = [
  {
    title: 'Ogólne',
    stats: [
      ['rounds', 'Rozegrane rundy'],
      ['survived', 'Przeżyte rundy'],
      ['escaped', 'Ewakuacje'],
      ['deaths', 'Zgony'],
      ['first_death', 'Pierwsza śmierć rundy'],
      ['missions_won', 'Wykonane misje statku'],
      ['crew_objectives', 'Wykonane cele załogi'],
    ],
  },
  {
    title: 'Antagonista',
    stats: [
      ['antag_rounds', 'Rundy jako antagonista'],
      ['antag_objectives', 'Wykonane cele antagonisty'],
    ],
  },
  {
    title: 'Praca',
    stats: [
      ['surgeries', 'Udane operacje'],
      ['revives', 'Reanimacje defibrylatorem'],
      ['ore_mined', 'Wykopana ruda'],
      ['arrests', 'Zakucia w kajdanki'],
      ['fines_issued', 'Wystawione grzywny'],
      ['restaurant_orders', 'Obsłużeni goście restauracji'],
      ['ships_destroyed', 'Zniszczone okręty wroga'],
      ['shots_fired', 'Oddane strzały'],
    ],
  },
  {
    title: 'Pieniądze',
    stats: [
      ['earnings_total', 'Zarobki łącznie (kr)'],
      ['earnings_best', 'Najlepsza runda (kr)'],
    ],
  },
];

export const CharacterStats = (props) => {
  const { data } = useBackend<Data>();
  const { characters = [], current } = data;
  const startIndex = Math.max(
    0,
    characters.findIndex((character) => character.name === current),
  );
  const [selected, setSelected] = useState(startIndex);
  const character = characters[selected];

  return (
    <Window title="Statystyki postaci" width={520} height={620}>
      <Window.Content scrollable>
        {characters.length === 0 ? (
          <NoticeBox>
            Nie ma jeszcze statystyk. Zapisują się na koniec każdej rundy, w
            której grałeś postacią.
          </NoticeBox>
        ) : (
          <Stack vertical>
            {characters.length > 1 && (
              <Stack.Item>
                <Tabs fluid>
                  {characters.map((entry, index) => (
                    <Tabs.Tab
                      key={entry.name}
                      selected={index === selected}
                      onClick={() => setSelected(index)}
                    >
                      {entry.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Stack.Item>
            )}
            {!!character &&
              STAT_GROUPS.map((group) => (
                <Stack.Item key={group.title}>
                  <Section title={group.title}>
                    <LabeledList>
                      {group.stats.map(([key, label]) => (
                        <LabeledList.Item key={key} label={label}>
                          {character.stats[key] || 0}
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  </Section>
                </Stack.Item>
              ))}
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
