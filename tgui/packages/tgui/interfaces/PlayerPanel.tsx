import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Player = {
  ref: string;
  name: string;
  real_name: string;
  key: string;
  ckey: string;
  job: string;
  ip: string;
  old_names: string;
  antag: boolean;
  cyborg: boolean;
  connected: boolean;
};

type Data = {
  players: Player[];
};

const PlayerActions = (props: { player: Player }) => {
  const { act } = useBackend<Data>();
  const { player } = props;
  const ref = player.ref;
  return (
    <Box style={{ whiteSpace: 'nowrap' }}>
      <Button tooltip="Panel gracza" onClick={() => act('pp', { ref })}>
        PP
      </Button>
      <Button
        tooltip="Notatki"
        onClick={() => act('notes', { ckey: player.ckey })}
      >
        N
      </Button>
      <Button tooltip="Zmienne" onClick={() => act('vv', { ref })}>
        VV
      </Button>
      <Button tooltip="Panel zdrajcy" onClick={() => act('tp', { ref })}>
        TP
      </Button>
      {!!player.cyborg && (
        <Button tooltip="Panel borga" onClick={() => act('bp', { ref })}>
          BP
        </Button>
      )}
      <Button
        tooltip="Prywatna wiadomość"
        onClick={() => act('pm', { ckey: player.ckey })}
      >
        PM
      </Button>
      <Button tooltip="Subtelna wiadomość" onClick={() => act('sm', { ref })}>
        SM
      </Button>
      <Button tooltip="Obserwuj" onClick={() => act('flw', { ref })}>
        FLW
      </Button>
      <Button tooltip="Logi" onClick={() => act('logs', { ref })}>
        LOGI
      </Button>
    </Box>
  );
};

export const PlayerPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { players = [] } = data;
  const [search, setSearch] = useState('');
  const [expanded, setExpanded] = useState<string | null>(null);

  const filter = search.toLowerCase();
  const shown = filter
    ? players.filter((player) =>
        [
          player.name,
          player.real_name,
          player.key,
          player.job,
          player.old_names,
        ]
          .join(' ')
          .toLowerCase()
          .includes(filter),
      )
    : players;

  return (
    <Window title="Panel graczy" theme="admin" width={720} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Input
                    fluid
                    autoFocus
                    placeholder="Szukaj (imię, klucz, stanowisko, dawne imiona)..."
                    value={search}
                    onChange={(value) => setSearch(value)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="user-secret"
                    onClick={() => act('check_antagonists')}
                  >
                    Antagoniści
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="door-open"
                    color="bad"
                    tooltip="Wyrzuć z lobby wszystkich graczy"
                    onClick={() => act('kick_lobby', { afk: false })}
                  >
                    Wyrzuć z lobby
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="bed"
                    color="average"
                    tooltip="Wyrzuć z lobby tylko graczy AFK"
                    onClick={() => act('kick_lobby', { afk: true })}
                  >
                    AFK
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title={`Gracze (${shown.length})`}>
              {shown.length === 0 && <NoticeBox>Brak wyników.</NoticeBox>}
              <Table>
                {shown.map((player) => (
                  <Table.Row key={player.ref} className="candystripe">
                    <Table.Cell p={0.5}>
                      <Box
                        style={{ cursor: 'pointer' }}
                        onClick={() =>
                          setExpanded(
                            expanded === player.ref ? null : player.ref,
                          )
                        }
                      >
                        <Box
                          inline
                          bold
                          color={player.antag ? 'bad' : undefined}
                        >
                          {player.name}
                        </Box>
                        {player.real_name !== player.name &&
                          ` (${player.real_name})`}
                        {' - '}
                        <Box inline color={player.connected ? 'good' : 'grey'}>
                          {player.key}
                        </Box>
                        <Box inline color="label">
                          {' '}
                          ({player.job})
                        </Box>
                      </Box>
                      {expanded === player.ref && (
                        <Box mt={0.5} ml={1} color="label">
                          <Box>
                            {player.job} {player.name}, prawdziwe imię:{' '}
                            {player.real_name}
                          </Box>
                          <Box>
                            Gra: {player.key} ({player.ip || 'brak IP'})
                          </Box>
                          {!!player.old_names && (
                            <Box>Dawne imiona: {player.old_names}</Box>
                          )}
                          {!!player.antag && (
                            <Button
                              mt={0.5}
                              color="bad"
                              icon="user-secret"
                              onClick={() => act('check_antagonists')}
                            >
                              Antagonista
                            </Button>
                          )}
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell collapsing p={0.5}>
                      <PlayerActions player={player} />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
