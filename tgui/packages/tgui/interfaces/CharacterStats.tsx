// AQUILA - okno „Statystyki”: statystyki postaci między rundami i ranking zarobków
// (aquila/code/modules/character_stats/character_stats.dm)
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
import { EarningsRanking, LeaderboardEntry } from './EconomyLeaderboard';

type Character = {
  name: string;
  stats: Record<string, number>;
};

type Data = {
  characters: Character[];
  current?: string;
  // liczniki tej rundy, jeszcze niezapisane
  round_stats?: Record<string, number>;
  leaderboard?: LeaderboardEntry[];
  my_ckey?: string;
};

type StatGroup = {
  title: string;
  stats: [string, string][];
};

const WORK_STATS = 2;

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
  const { leaderboard = [], my_ckey } = data;
  const [page, setPage] = useState('characters');

  return (
    <Window title="Statystyki" width={560} height={640}>
      <Window.Content scrollable>
        <Tabs fluid>
          <Tabs.Tab
            icon="user"
            selected={page === 'characters'}
            onClick={() => setPage('characters')}
          >
            Moje postacie
          </Tabs.Tab>
          <Tabs.Tab
            icon="coins"
            selected={page === 'earnings'}
            onClick={() => setPage('earnings')}
          >
            Ranking zarobków
          </Tabs.Tab>
        </Tabs>
        {page === 'characters' ? (
          <CharacterPage />
        ) : (
          <EarningsRanking leaderboard={leaderboard} myCkey={my_ckey} />
        )}
      </Window.Content>
    </Window>
  );
};

const CharacterPage = (props) => {
  const { data } = useBackend<Data>();
  const { characters = [], current, round_stats = {} } = data;
  const roundStats = STAT_GROUPS[WORK_STATS].stats.filter(
    ([key]) => round_stats[key],
  );
  const startIndex = Math.max(
    0,
    characters.findIndex((character) => character.name === current),
  );
  const [selected, setSelected] = useState(startIndex);
  const character = characters[selected];

  return (
    <>
      {roundStats.length > 0 && (
        <Section title="W tej rundzie (zapis na koniec rundy)">
          <LabeledList>
            {roundStats.map(([key, label]) => (
              <LabeledList.Item key={key} label={label}>
                {round_stats[key]}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}
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
    </>
  );
};
