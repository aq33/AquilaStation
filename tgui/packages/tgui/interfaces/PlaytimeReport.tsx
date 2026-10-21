import { useState } from 'react';
import { Button, Input, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Player = {
  key: string;
  ckey: string;
  name: string | null;
  mob_ref: string | null;
  living_minutes: number;
  living: string;
};

type Data = {
  players: Player[];
};

export const PlaytimeReport = (props) => {
  const { act, data } = useBackend<Data>();
  const { players = [] } = data;
  const [search, setSearch] = useState('');
  const [newestFirst, setNewestFirst] = useState(true);
  const filter = search.toLowerCase();
  const shown = players
    .filter(
      (player) =>
        !filter ||
        `${player.key} ${player.name || ''}`.toLowerCase().includes(filter),
    )
    .sort((a, b) =>
      newestFirst
        ? a.living_minutes - b.living_minutes
        : b.living_minutes - a.living_minutes,
    );
  return (
    <Window title="Czas gry graczy" theme="admin" width={480} height={560}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Szukaj..."
                  value={search}
                  onChange={(value) => setSearch(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={newestFirst ? 'sort-amount-up' : 'sort-amount-down'}
                  onClick={() => setNewestFirst(!newestFirst)}
                >
                  {newestFirst ? 'Najmniej grający' : 'Najwięcej grający'}
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title={`Gracze (${shown.length})`}>
              <Table>
                <Table.Row header>
                  <Table.Cell>Gracz</Table.Cell>
                  <Table.Cell collapsing>Czas jako żywy</Table.Cell>
                  <Table.Cell collapsing />
                </Table.Row>
                {shown.map((player) => (
                  <Table.Row key={player.ckey} className="candystripe">
                    <Table.Cell py={0.25}>
                      {player.key}
                      {!!player.name && ` (${player.name})`}
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      <Button
                        disabled={!player.mob_ref}
                        tooltip="Szczegóły czasu gry"
                        onClick={() => act('playtime', { ref: player.mob_ref })}
                      >
                        {player.living}
                      </Button>
                    </Table.Cell>
                    <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
                      <Button
                        disabled={!player.mob_ref}
                        onClick={() => act('pp', { ref: player.mob_ref })}
                      >
                        PP
                      </Button>
                      <Button onClick={() => act('pm', { ckey: player.ckey })}>
                        PM
                      </Button>
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
