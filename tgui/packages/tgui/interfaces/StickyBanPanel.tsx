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

type Alt = {
  key: string;
  ckey: string;
  exempt: boolean;
};

type StickyBan = {
  ckey: string;
  message: string;
  admin: string | null;
  timeout: boolean;
  alts: Alt[];
};

type Data = {
  bans: StickyBan[];
  db_connected: boolean;
};

const BanSection = (props: { ban: StickyBan }) => {
  const { act, data } = useBackend<Data>();
  const { ban } = props;
  const ckey = ban.ckey;
  return (
    <Section
      title={ban.ckey}
      buttons={
        <>
          {data.db_connected ? (
            <Button
              icon={ban.timeout ? 'play' : 'pause'}
              color={ban.timeout ? 'average' : undefined}
              tooltip={
                ban.timeout
                  ? 'Zdejmij zawieszenie'
                  : 'Zawieś ban do następnej rundy'
              }
              onClick={() =>
                act(ban.timeout ? 'untimeout' : 'timeout', { ckey })
              }
            >
              {ban.timeout ? 'Zawieszony' : 'Zawieś'}
            </Button>
          ) : (
            <Button
              icon="undo"
              tooltip="Przywróć stan z początku rundy (albo ostatniej edycji)"
              onClick={() => act('revert', { ckey })}
            >
              Przywróć
            </Button>
          )}
          <Button icon="pen" onClick={() => act('edit', { ckey })}>
            Edytuj powód
          </Button>
          <Button
            icon="trash"
            color="bad"
            onClick={() => act('remove', { ckey })}
          >
            Usuń
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Powód">{ban.message}</LabeledList.Item>
        <LabeledList.Item label="Nałożył">
          {ban.admin || 'LEGACY'}
        </LabeledList.Item>
      </LabeledList>
      <Box bold mt={1} mb={0.5}>
        Złapane konta
      </Box>
      {ban.alts.length === 0 && (
        <Box color="label" italic>
          Brak.
        </Box>
      )}
      <Table>
        {ban.alts.map((alt) => (
          <Table.Row key={alt.ckey} className="candystripe">
            <Table.Cell py={0.25}>
              {alt.key}
              {!!alt.exempt && (
                <Box inline ml={1} color="good">
                  (wyjątek)
                </Box>
              )}
            </Table.Cell>
            <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
              {alt.exempt ? (
                <Button
                  tooltip="Usuń wyjątek"
                  onClick={() => act('unexempt', { ckey, alt: alt.ckey })}
                >
                  UE
                </Button>
              ) : (
                <Button
                  tooltip="Dodaj wyjątek (konto nie będzie łapane)"
                  onClick={() => act('exempt', { ckey, alt: alt.ckey })}
                >
                  E
                </Button>
              )}
              <Button
                icon="minus"
                color="bad"
                tooltip="Odłącz konto od bana"
                onClick={() => act('remove_alt', { ckey, alt: alt.ckey })}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const StickyBanPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { bans = [] } = data;
  const [search, setSearch] = useState('');
  const filter = search.toLowerCase();
  const shown = filter
    ? bans.filter((ban) =>
        [ban.ckey, ban.message, ...ban.alts.map((alt) => alt.key)]
          .join(' ')
          .toLowerCase()
          .includes(filter),
      )
    : bans;
  return (
    <Window title="Stickybany" theme="admin" width={700} height={550}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Szukaj (ckey, powód, złapane konto)..."
                  value={search}
                  onChange={(value) => setSearch(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button icon="plus" color="good" onClick={() => act('add')}>
                  Dodaj
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="sync"
                  tooltip="Odśwież"
                  onClick={() => act('refresh')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={`Wszystkie stickybany (${bans.length})`}
            >
              {shown.length === 0 && <NoticeBox>Brak stickybanów.</NoticeBox>}
              {shown.map((ban) => (
                <BanSection key={ban.ckey} ban={ban} />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
