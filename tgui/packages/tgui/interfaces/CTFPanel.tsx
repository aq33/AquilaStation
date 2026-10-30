import { Box, Button, Flex, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Team = {
  name: string;
  color: string;
  score: number;
  team_size: number;
  refs: string;
};

type CTFPanelData = {
  /** AQUILA: admin może włączyć/wyłączyć CTF z okna (zamiast alertu) */
  is_admin: BooleanLike;
} & (
  | {
      teams: Team[];
    }
  | {
      voters: number;
      voters_required: number;
      voted: BooleanLike;
    }
);

/** Nazwy drużyn z DM (White/Red/Blue) */
const TEAM_NAMES: Record<string, string> = {
  White: 'Biali',
  Red: 'Czerwoni',
  Blue: 'Niebiescy',
};

const plural = (count: number, one: string, few: string, many: string) => {
  if (count === 1) {
    return one;
  }
  const lastDigit = count % 10;
  const lastTwo = count % 100;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14)) {
    return few;
  }
  return many;
};

export const CTFPanel = (props) => {
  const { act, data } = useBackend<CTFPanelData>();

  return (
    <Window title="Zdobądź flagę" width={700} height={600}>
      <Window.Content scrollable>
        {!!data.is_admin && (
          <Section>
            <Button
              icon="flag"
              color={'teams' in data ? 'bad' : 'good'}
              onClick={() => act('toggle_ctf')}
            >
              {'teams' in data ? 'Wyłącz CTF' : 'Włącz CTF'}
            </Button>
          </Section>
        )}
        {'teams' in data ? (
          <Flex align="center" wrap="wrap" textAlign="center" m={-0.5}>
            {data.teams.map((team) => (
              <Flex.Item key={team.name} width="49%" m={0.5} mb={8}>
                <Section
                  title={`Drużyna: ${TEAM_NAMES[team.color] || team.color}`}
                >
                  <Stack fill mb={1}>
                    <Stack.Item grow>
                      <Box>
                        <b>{team.team_size}</b>{' '}
                        {plural(team.team_size, 'gracz', 'graczy', 'graczy')}
                      </Box>
                    </Stack.Item>

                    <Stack.Item grow>
                      <Box>
                        <b>{team.score}</b>{' '}
                        {plural(team.score, 'punkt', 'punkty', 'punktów')}
                      </Box>
                    </Stack.Item>
                  </Stack>

                  <Button
                    fontSize="18px"
                    fluid
                    color={team.color.toLowerCase()}
                    onClick={() =>
                      act('jump', {
                        refs: team.refs,
                      })
                    }
                  >
                    Skocz
                  </Button>

                  <Button
                    fontSize="18px"
                    fluid
                    color={team.color.toLowerCase()}
                    onClick={() =>
                      act('join', {
                        refs: team.refs,
                      })
                    }
                  >
                    Dołącz
                  </Button>
                </Section>
              </Flex.Item>
            ))}
          </Flex>
        ) : (
          <Stack fill align="center" justify="center" vertical>
            <Stack.Item mb={5}>
              <Box fontSize="90px" textAlign="center">
                {data.voters}/{data.voters_required}
              </Box>
              <br />
              <Box fontSize="30px" textAlign="center">
                Chętnych do CTF
              </Box>
            </Stack.Item>

            <Stack.Item>
              <Button
                fontSize="24px"
                color={data.voted ? 'bad' : 'good'}
                onClick={() => {
                  if (data.voted) {
                    act('unvote');
                  } else {
                    act('vote');
                  }
                }}
              >
                {data.voted ? 'Wycofaj głos' : 'Zagłosuj za CTF'}
              </Button>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
