import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Admin = {
  key: string;
  deadmined: boolean;
  rank: string;
  rights: string;
  denied: string;
  can_edit: string;
};

type LogEntry = {
  datetime: string;
  round_id: string;
  admin_key: string;
  operation: string;
  target: string;
  log: string;
};

type InvalidRank = {
  key: string;
  rank: string;
};

type UnusedRank = {
  rank: string;
  rights: string;
  denied: string;
  can_edit: string;
};

type Data = {
  tab: string;
  admins: Admin[];
  log_entries: LogEntry[];
  log_page: number;
  log_page_count: number;
  log_target: string | null;
  log_operation: string | null;
  invalid_ranks: InvalidRank[];
  unused_ranks: UnusedRank[];
};

const AdminsTab = (props) => {
  const { act, data } = useBackend<Data>();
  const { admins = [] } = data;
  const [search, setSearch] = useState('');
  const filter = search.toLowerCase();
  const shown = filter
    ? admins.filter((admin) =>
        [admin.key, admin.rank, admin.rights, admin.denied, admin.can_edit]
          .join(' ')
          .toLowerCase()
          .includes(filter),
      )
    : admins;
  return (
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
            <Button icon="plus" color="good" onClick={() => act('add')}>
              Dodaj admina
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Table>
            <Table.Row header>
              <Table.Cell>Ckey</Table.Cell>
              <Table.Cell>Ranga</Table.Cell>
              <Table.Cell>Uprawnienia</Table.Cell>
              <Table.Cell>Zabronione</Table.Cell>
              <Table.Cell>Może edytować</Table.Cell>
            </Table.Row>
            {shown.map((admin) => {
              const edit = (task: string) =>
                act('edit', { task, key: admin.key });
              return (
                <Table.Row key={admin.key} className="candystripe">
                  <Table.Cell py={0.5} collapsing>
                    <Box bold color={admin.deadmined ? 'label' : undefined}>
                      {admin.key}
                    </Box>
                    <Box style={{ whiteSpace: 'nowrap' }}>
                      {admin.deadmined ? (
                        <Button
                          compact
                          tooltip="Przywróć uprawnienia (readmin)"
                          onClick={() => edit('activate')}
                        >
                          RA
                        </Button>
                      ) : (
                        <Button
                          compact
                          tooltip="Odbierz uprawnienia na tę rundę (deadmin)"
                          onClick={() => edit('deactivate')}
                        >
                          DA
                        </Button>
                      )}
                      <Button
                        compact
                        icon="minus"
                        color="bad"
                        tooltip="Usuń admina"
                        onClick={() => edit('remove')}
                      />
                      <Button
                        compact
                        tooltip="Synchronizuj ostatnią rangę w bazie"
                        onClick={() => edit('sync')}
                      >
                        SYNC
                      </Button>
                    </Box>
                  </Table.Cell>
                  <Table.Cell py={0.5} collapsing>
                    <Button onClick={() => edit('rank')}>{admin.rank}</Button>
                  </Table.Cell>
                  <Table.Cell py={0.5}>
                    <Box
                      style={{ cursor: 'pointer' }}
                      onClick={() => edit('permissions')}
                    >
                      {admin.rights || '-'}
                    </Box>
                  </Table.Cell>
                  <Table.Cell py={0.5}>
                    <Box
                      color="bad"
                      style={{ cursor: 'pointer' }}
                      onClick={() => edit('permissions')}
                    >
                      {admin.denied || '-'}
                    </Box>
                  </Table.Cell>
                  <Table.Cell py={0.5}>
                    <Box
                      color="average"
                      style={{ cursor: 'pointer' }}
                      onClick={() => edit('permissions')}
                    >
                      {admin.can_edit || '-'}
                    </Box>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const LogTab = (props) => {
  const { act, data } = useBackend<Data>();
  const { log_entries = [], log_page, log_page_count } = data;
  return (
    <Section
      fill
      scrollable
      title="Log zmian uprawnień"
      buttons={
        <>
          {(!!data.log_target || !!data.log_operation) && (
            <Button icon="filter" onClick={() => act('log_clear_filter')}>
              Wyczyść filtr
            </Button>
          )}
          <Button
            icon="chevron-left"
            disabled={log_page <= 0}
            onClick={() => act('log_page', { page: log_page - 1 })}
          />
          <Box inline mx={1}>
            Strona {log_page + 1} / {Math.max(log_page_count, 1)}
          </Box>
          <Button
            icon="chevron-right"
            disabled={log_page + 1 >= log_page_count}
            onClick={() => act('log_page', { page: log_page + 1 })}
          />
        </>
      }
    >
      {log_entries.length === 0 && <NoticeBox>Brak wpisów.</NoticeBox>}
      {log_entries.map((entry, i) => (
        <Box key={i}>
          <Box bold>
            {entry.datetime} | Runda {entry.round_id} | Admin {entry.admin_key}{' '}
            | {entry.operation} na {entry.target}
          </Box>
          <Box>{entry.log}</Box>
          <Divider />
        </Box>
      ))}
    </Section>
  );
};

const ManagementTab = (props) => {
  const { act, data } = useBackend<Data>();
  const { invalid_ranks = [], unused_ranks = [] } = data;
  return (
    <Box>
      <Section title="Admini z nieistniejącą rangą">
        {invalid_ranks.length === 0 && <Box color="label">Brak.</Box>}
        <Table>
          {invalid_ranks.map((entry) => (
            <Table.Row key={entry.key} className="candystripe">
              <Table.Cell py={0.25}>
                {entry.key} ma nieistniejącą rangę {entry.rank}
              </Table.Cell>
              <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
                <Button
                  onClick={() => act('manage_change_rank', { key: entry.key })}
                >
                  Zmień rangę
                </Button>
                <Button
                  color="bad"
                  onClick={() => act('manage_remove', { key: entry.key })}
                >
                  Usuń
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
      <Section title="Nieużywane rangi">
        {unused_ranks.length === 0 && <Box color="label">Brak.</Box>}
        {unused_ranks.map((rank) => (
          <Box key={rank.rank} mb={1}>
            <Stack align="center">
              <Stack.Item grow bold>
                Rangi {rank.rank} nie ma żaden admin
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="bad"
                  onClick={() => act('manage_remove_rank', { rank: rank.rank })}
                >
                  Usuń
                </Button>
              </Stack.Item>
            </Stack>
            <Box>Uprawnienia: {rank.rights || '-'}</Box>
            <Box color="bad">Zabronione: {rank.denied || '-'}</Box>
            <Box color="average">Może edytować: {rank.can_edit || '-'}</Box>
            <Divider />
          </Box>
        ))}
      </Section>
    </Box>
  );
};

export const PermissionsPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { tab } = data;
  return (
    <Window title="Uprawnienia adminów" theme="admin" width={1000} height={650}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="user-shield"
                selected={tab === 'admins'}
                onClick={() => act('tab', { tab: 'admins' })}
              >
                Uprawnienia
              </Tabs.Tab>
              <Tabs.Tab
                icon="scroll"
                selected={tab === 'log'}
                onClick={() => act('tab', { tab: 'log' })}
              >
                Log
              </Tabs.Tab>
              <Tabs.Tab
                icon="tools"
                selected={tab === 'management'}
                onClick={() => act('tab', { tab: 'management' })}
              >
                Zarządzanie
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'log' && <LogTab />}
            {tab === 'management' && (
              <Section fill scrollable>
                <ManagementTab />
              </Section>
            )}
            {tab !== 'log' && tab !== 'management' && <AdminsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
