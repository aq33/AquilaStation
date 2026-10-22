// AQUILA - biblioteka kaset (port z Monkestation, CassetteLibrary.tsx)
import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type LibraryCassette = {
  id: string;
  name: string;
  desc: string;
  author: string;
  icon_state: string;
  songs: string[];
};

type TopCassette = {
  id: string;
  name: string;
  author: string;
  purchases: number;
};

type Data = {
  icon: string;
  cassettes: LibraryCassette[];
  top_cassettes: TopCassette[];
  cost: number;
  busy: boolean;
  balance: number | null;
};

export const CassetteLibrary = () => {
  const { act, data } = useBackend<Data>();
  const { icon, cassettes, top_cassettes, cost, busy, balance } = data;
  const [tab, setTab] = useState(0);
  const [search, setSearch] = useState('');

  const query = search.toLowerCase();
  const shown = cassettes.filter(
    (cassette) =>
      !query ||
      cassette.name.toLowerCase().includes(query) ||
      (cassette.author || '').toLowerCase().includes(query) ||
      cassette.songs.some((song) => (song || '').toLowerCase().includes(query)),
  );
  const canBuy = !busy && balance !== null && balance >= cost;

  return (
    <Window width={560} height={620}>
      <Window.Content scrollable>
        <NoticeBox info={balance !== null}>
          {balance === null
            ? 'Załóż kartę ID z kontem bankowym, żeby kupować kasety.'
            : `Saldo: ${balance} kr · kaseta kosztuje ${cost} kr`}
        </NoticeBox>
        <Tabs>
          <Tabs.Tab selected={tab === 0} onClick={() => setTab(0)}>
            Wszystkie ({cassettes.length})
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Najpopularniejsze
          </Tabs.Tab>
        </Tabs>
        {tab === 0 ? (
          <Section>
            <Input
              fluid
              placeholder="Szukaj po nazwie, autorze albo utworze..."
              value={search}
              onChange={setSearch}
            />
            {shown.length === 0 && (
              <Box mt={1} color="label">
                Brak kaset.
              </Box>
            )}
            {shown.map((cassette) => (
              <Stack key={cassette.id} mt={1} align="center">
                <Stack.Item>
                  <DmIcon
                    icon={icon}
                    icon_state={cassette.icon_state}
                    width="48px"
                    height="48px"
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Box bold>{cassette.name}</Box>
                  <Box color="label">
                    {cassette.author ? `${cassette.author} · ` : ''}
                    {cassette.songs.length} utworów
                  </Box>
                  <Box fontSize="0.9em">{cassette.desc}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="print"
                    disabled={!canBuy}
                    onClick={() => act('purchase', { id: cassette.id })}
                  >
                    Kup
                  </Button>
                </Stack.Item>
              </Stack>
            ))}
          </Section>
        ) : (
          <Section>
            {top_cassettes.length === 0 ? (
              <Box color="label">Nikt jeszcze nic nie kupił.</Box>
            ) : (
              <Table>
                {top_cassettes.map((cassette, index) => (
                  <Table.Row key={cassette.id} className="candystripe">
                    <Table.Cell collapsing color="label">
                      {index + 1}.
                    </Table.Cell>
                    <Table.Cell>
                      <Box bold>{cassette.name}</Box>
                      <Box color="label">{cassette.author}</Box>
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      {cassette.purchases} kupujących
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        icon="print"
                        disabled={!canBuy}
                        onClick={() => act('purchase', { id: cassette.id })}
                      >
                        Kup
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
