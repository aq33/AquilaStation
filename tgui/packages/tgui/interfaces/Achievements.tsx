import { useState } from 'react';
import { Box, Flex, Icon, Table, Tabs, Tooltip } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: string[];
  achievements: Achievement[];
  // Nasz DM: "highscore", a wyniki jako słownik ckey -> wartość.
  highscore: Highscore[];
  user_key: string;
};

type Achievement = {
  name: string;
  desc: string;
  category: string;
  icon_class: string;
  value: number;
  score: BooleanLike;
  achieve_info?: string;
  achieve_tooltip?: string;
};

type Highscore = {
  name: string;
  scores: Record<string, number>;
};

type Score = {
  ckey: string;
  value: number;
};

const HIGH_SCORES = 'High Scores';

// Kategorie przychodzą z DM po angielsku — tłumaczymy tylko etykiety.
const CATEGORY_NAMES: Record<string, string> = {
  Bosses: 'Bossowie',
  Misc: 'Różne',
  Scores: 'Wyniki',
};

export const Achievements = (props) => {
  const { data } = useBackend<Data>();
  const { categories = [] } = data;
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  return (
    <Window title="Osiągnięcia" width={540} height={680}>
      <Window.Content scrollable>
        <Tabs>
          {categories.map((category) => (
            <Tabs.Tab
              key={category}
              selected={selectedCategory === category}
              onClick={() => setSelectedCategory(category)}
            >
              {CATEGORY_NAMES[category] || category}
            </Tabs.Tab>
          ))}
          <Tabs.Tab
            selected={selectedCategory === HIGH_SCORES}
            onClick={() => setSelectedCategory(HIGH_SCORES)}
          >
            Najlepsze wyniki
          </Tabs.Tab>
        </Tabs>
        {(selectedCategory === HIGH_SCORES && <HighScoreTable />) || (
          <AchievementTable category={selectedCategory} />
        )}
      </Window.Content>
    </Window>
  );
};

const AchievementTable = (props) => {
  const { data } = useBackend<Data>();
  const { achievements = [] } = data;
  const { category } = props;
  const filtered_achievements = achievements.filter(
    (x) => x.category === category,
  );
  return (
    <Table>
      {filtered_achievements.map((achievement) => (
        <Table.Row key={achievement.name}>
          <Table.Cell collapsing>
            <Box m={1} className={achievement.icon_class} />
          </Table.Cell>
          <Table.Cell verticalAlign="top">
            <h1>{achievement.name}</h1>
            {achievement.desc}
            {(achievement.score && (
              <Box color={achievement.value > 0 ? 'good' : 'bad'}>
                {achievement.value > 0
                  ? `Zdobyte ${achievement.value} razy`
                  : 'Zablokowane'}
              </Box>
            )) || (
              <Box color={achievement.value ? 'good' : 'bad'}>
                {achievement.value ? 'Odblokowane' : 'Zablokowane'}
              </Box>
            )}
            {!!achievement.achieve_info && (
              <Tooltip position="bottom" content={achievement.achieve_tooltip}>
                <Box fontSize={0.9} opacity={0.8}>
                  {achievement.achieve_info}
                </Box>
              </Tooltip>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const HighScoreTable = () => {
  const { data } = useBackend<Data>();
  const { highscore: highscores, user_key } = data;
  const [highScoreIndex, setHighScoreIndex] = useState(0);
  if (!highscores || highscores.length === 0) {
    return <Box p={1}>Nikt jeszcze nie ustanowił rekordu.</Box>;
  }
  const highscore = highscores[highScoreIndex];
  const scores: Score[] = Object.keys(highscore.scores || {}).map((key) => ({
    ckey: key,
    value: highscore.scores[key],
  }));
  return (
    <Flex>
      <Flex.Item>
        <Tabs vertical>
          {highscores.map((highscore, i) => (
            <Tabs.Tab
              key={highscore.name}
              selected={highScoreIndex === i}
              onClick={() => setHighScoreIndex(i)}
            >
              {highscore.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Table>
          <Table.Row header>
            <Table.Cell textAlign="center">#</Table.Cell>
            <Table.Cell textAlign="center">Gracz</Table.Cell>
            <Table.Cell textAlign="center">Wynik</Table.Cell>
          </Table.Row>
          {scores.map((score, i) => (
            <Table.Row key={score.ckey} className="candystripe" m={2}>
              <Table.Cell color="label" textAlign="center">
                {i + 1}
              </Table.Cell>
              <Table.Cell
                color={score.ckey === user_key ? 'green' : undefined}
                textAlign="center"
              >
                {i === 0 && <Icon name="crown" color="yellow" mr={2} />}
                {score.ckey}
                {i === 0 && <Icon name="crown" color="yellow" ml={2} />}
              </Table.Cell>
              <Table.Cell textAlign="center">{score.value}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Flex.Item>
    </Flex>
  );
};
