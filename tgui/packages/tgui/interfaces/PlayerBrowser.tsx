import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type PlayerRow = {
  ckey: string;
  key: string;
  firstseen: string;
  firstseen_round: string;
  lastseen: string;
  lastseen_round: string;
  rank: string;
};

type PlayerInfo = PlayerRow & {
  account_join_date: string | null;
  online: boolean;
};

type Ban = {
  bantime: string;
  round_id: string;
  roles: string[];
  expiration: string | null;
  reason: string;
  admin: string;
  unbanned: string | null;
  unbanned_by: string | null;
  active: boolean;
};

type CentcomBan = {
  server: string;
  rp_level: string;
  type: string;
  banned_by: string;
  reason: string;
  banned_on: string;
  expires: string | null;
  jobs: string | null;
};

type Data = {
  db_connected: boolean;
  centcom_enabled: boolean;
  search: string;
  page: number;
  has_next_page: boolean;
  players: PlayerRow[];
  selected_ckey: string | null;
  selected_info: PlayerInfo | null;
  bans: Ban[] | null;
  centcom_bans: CentcomBan[] | null;
  centcom_status: string | null;
};

export const PlayerBrowser = (props) => {
  const { data } = useBackend<Data>();

  return (
    <Window title="Przeglądarka graczy" width={950} height={620}>
      <Window.Content>
        {!data.db_connected ? (
          <NoticeBox>Brak połączenia z bazą danych.</NoticeBox>
        ) : (
          <Stack fill>
            <Stack.Item width="40%">
              <PlayerList />
            </Stack.Item>
            <Stack.Item grow>
              <PlayerDetails />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

const PlayerList = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchText, setSearchText] = useState(data.search);

  return (
    <Section
      fill
      scrollable
      title="Gracze"
      buttons={
        <>
          <Button
            icon="chevron-left"
            disabled={data.page <= 0}
            onClick={() => act('page', { page: data.page - 1 })}
          />
          <Box inline mx={1}>
            Strona {data.page + 1}
          </Box>
          <Button
            icon="chevron-right"
            disabled={!data.has_next_page}
            onClick={() => act('page', { page: data.page + 1 })}
          />
        </>
      }
    >
      <Stack mb={1}>
        <Stack.Item grow>
          <Input
            fluid
            value={searchText}
            placeholder="Fragment ckey..."
            onChange={setSearchText}
            onEnter={() => act('search', { search: searchText })}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="search"
            onClick={() => act('search', { search: searchText })}
          >
            Szukaj
          </Button>
        </Stack.Item>
      </Stack>
      {data.players.length === 0 ? (
        <NoticeBox>Brak graczy.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Ckey</Table.Cell>
            <Table.Cell>Ostatnio</Table.Cell>
          </Table.Row>
          {data.players.map((player) => (
            <Table.Row key={player.ckey}>
              <Table.Cell>
                <Button
                  fluid
                  selected={player.ckey === data.selected_ckey}
                  onClick={() => act('select', { ckey: player.ckey })}
                >
                  {player.key}
                </Button>
              </Table.Cell>
              <Table.Cell color="label">
                {player.lastseen} (runda {player.lastseen_round})
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const PlayerDetails = (props) => {
  const { act, data } = useBackend<Data>();
  const info = data.selected_info;

  if (!info) {
    return (
      <Section fill>
        <NoticeBox>Wybierz gracza z listy.</NoticeBox>
      </Section>
    );
  }

  return (
    <Section
      fill
      scrollable
      title={info.key}
      buttons={
        <>
          <Button icon="ticket" onClick={() => act('tickets')}>
            Historia ticketów
          </Button>
          <Button icon="gavel" onClick={() => act('unban_panel')}>
            Panel banów
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Ckey">{info.ckey}</LabeledList.Item>
        <LabeledList.Item label="Teraz na serwerze">
          {info.online ? 'Tak' : 'Nie'}
        </LabeledList.Item>
        <LabeledList.Item label="Pierwsze wejście">
          {info.firstseen} (runda {info.firstseen_round})
        </LabeledList.Item>
        <LabeledList.Item label="Ostatnie wejście">
          {info.lastseen} (runda {info.lastseen_round})
        </LabeledList.Item>
        <LabeledList.Item label="Ostatnia ranga">{info.rank}</LabeledList.Item>
        <LabeledList.Item label="Konto BYOND od">
          {info.account_join_date || 'Nieznane'}
        </LabeledList.Item>
      </LabeledList>
      <Section title="Bany na naszym serwerze" mt={1}>
        {!data.bans?.length ? (
          <Box color="good">Brak banów.</Box>
        ) : (
          data.bans.map((ban) => <BanEntry key={ban.bantime} ban={ban} />)
        )}
      </Section>
      <Section
        title="Bany w CentCom"
        buttons={
          <Button
            icon="search"
            disabled={!data.centcom_enabled}
            onClick={() => act('centcom')}
          >
            Sprawdź
          </Button>
        }
      >
        {!data.centcom_enabled && (
          <Box color="label">Baza CentCom jest wyłączona w configu.</Box>
        )}
        {!!data.centcom_status && <Box>{data.centcom_status}</Box>}
        {data.centcom_bans?.map((ban, i) => (
          <CentcomBanEntry key={i} ban={ban} />
        ))}
      </Section>
    </Section>
  );
};

const BanEntry = (props: { ban: Ban }) => {
  const { ban } = props;
  return (
    <Box mb={1} p={1} backgroundColor="rgba(255, 255, 255, 0.05)">
      <Box bold color={ban.active ? 'bad' : 'label'}>
        {ban.active ? 'AKTYWNY' : ban.unbanned ? 'Zdjęty' : 'Wygasł'}:{' '}
        {ban.roles.join(', ')}
      </Box>
      <Box>{ban.reason}</Box>
      <Box color="label">
        {ban.bantime} (runda {ban.round_id}), admin: {ban.admin}, do:{' '}
        {ban.expiration || 'permanentny'}
        {!!ban.unbanned &&
          `, zdjęty ${ban.unbanned} przez ${ban.unbanned_by || '?'}`}
      </Box>
    </Box>
  );
};

const CentcomBanEntry = (props: { ban: CentcomBan }) => {
  const { ban } = props;
  return (
    <Box mb={1} p={1} backgroundColor="rgba(255, 255, 255, 0.05)">
      <Box bold>
        {ban.server} ({ban.rp_level}): {ban.type}
        {!!ban.jobs && ` - ${ban.jobs}`}
      </Box>
      <Box>{ban.reason}</Box>
      <Box color="label">
        {ban.banned_on}, admin: {ban.banned_by}, do:{' '}
        {ban.expires || 'permanentny'}
      </Box>
    </Box>
  );
};
