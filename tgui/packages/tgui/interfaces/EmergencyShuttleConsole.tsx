import { Box, Button, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  authorizations_remaining: number;
  authorizations: Authorization[];
  emagged: BooleanLike;
  enabled: BooleanLike;
  engines_started: BooleanLike;
  timer_str: string;
};

type Authorization = {
  job: string;
  name: string;
};

export function EmergencyShuttleConsole(props) {
  const { act, data } = useBackend<Data>();
  const {
    authorizations = [],
    authorizations_remaining,
    emagged,
    enabled,
    engines_started,
    timer_str,
  } = data;

  return (
    <Window width={400} height={350}>
      <Window.Content>
        <Section>
          <Box bold fontSize="40px" textAlign="center" fontFamily="monospace">
            {timer_str}
          </Box>
          <Box textAlign="center" fontSize="16px" mb={1}>
            <Box inline bold>
              SILNIKI:
            </Box>
            <Box inline color={engines_started ? 'good' : 'average'} ml={1}>
              {engines_started ? 'Uruchomione' : 'Bezczynne'}
            </Box>
          </Box>
          <Section
            title="Zgoda na wcześniejszy start"
            buttons={
              <Button
                color="bad"
                disabled={!enabled}
                icon="times"
                onClick={() => act('abort')}
              >
                Cofnij wszystkie
              </Button>
            }
          >
            <Stack>
              <Stack.Item grow>
                <Button
                  color="good"
                  disabled={!enabled}
                  fluid
                  icon="exclamation-triangle"
                  onClick={() => act('authorize')}
                >
                  AUTORYZUJ
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  disabled={!enabled}
                  fluid
                  icon="minus"
                  onClick={() => act('repeal')}
                >
                  COFNIJ
                </Button>
              </Stack.Item>
            </Stack>
            <Section
              title="Autoryzacje"
              minHeight="150px"
              buttons={
                <Box inline bold color={emagged ? 'bad' : 'good'}>
                  {emagged ? 'BŁĄD' : `Pozostało: ${authorizations_remaining}`}
                </Box>
              }
            >
              {authorizations.length === 0 ? (
                <Box bold textAlign="center" fontSize="16px" color="average">
                  Brak aktywnych autoryzacji
                </Box>
              ) : (
                authorizations.map((authorization) => (
                  <Box
                    key={authorization.name}
                    bold
                    fontSize="16px"
                    className="candystripe"
                  >
                    {authorization.name} ({authorization.job})
                  </Box>
                ))
              )}
            </Section>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
}
