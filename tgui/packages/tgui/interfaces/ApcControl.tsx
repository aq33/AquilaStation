import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AreaCharge, powerRank } from './PowerMonitor';

enum Screen {
  ControlPanel = 1,
  LogView,
}

type APC = {
  name: string;
  operating: BooleanLike;
  charge: number;
  has_cell: BooleanLike;
  load: string;
  charging: number;
  chargeMode: number;
  eqp: number;
  lgt: number;
  env: number;
  responds: BooleanLike;
  // AQUILA: APC, z którym konsola jest teraz połączona
  active: BooleanLike;
  ref: string;
};

type Log = {
  entry: string;
};

type Data = {
  auth_id: string;
  authenticated: BooleanLike;
  emagged: BooleanLike;
  apcs: APC[];
  logs: Log[];
};

export function ApcControl(props) {
  const { data } = useBackend<Data>();
  const { authenticated } = data;

  return (
    <Window title="Sterowanie APC" width={600} height={500}>
      <Window.Content>
        {authenticated ? <ApcLoggedIn /> : <ApcLoggedOut />}
      </Window.Content>
    </Window>
  );
}

function ApcLoggedOut(props) {
  const { act } = useBackend<Data>();

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item grow>
          <Stack fill vertical justify="center" align="center">
            <Stack.Item>
              <Icon name="bolt-lightning" color="yellow" size={8} />
            </Stack.Item>
            <Stack.Item bold mt={5}>
              Sterownik Zeus™ wersja 0.19
            </Stack.Item>
            <Stack.Item color="label">Copyright 2526 Nanotrasen</Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item color="#2a2a2a">
          Nanotrasen i podmioty powiązane nie rekomendują tego produktu.
          Korzystanie z każdego urządzenia wytwarzającego energię elektryczną
          wiąże się z ryzykiem poważnych obrażeń ciała lub śmierci. Nanotrasen
          nie odpowiada za szkody wynikłe z używania tego produktu.
        </Stack.Item>
        <Stack.Item>
          <NoticeBox
            m={0}
            mt={1}
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}
          >
            Tylko dla upoważnionego personelu.
            <Button
              icon="sign-in-alt"
              color="good"
              onClick={() => act('log-in')}
            >
              Zaloguj (przeciągnij kartę ID)
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function ApcLoggedIn(props) {
  const { act } = useBackend<Data>();

  const [tabIndex, setTabIndex] = useState<Screen>(Screen.ControlPanel);
  const sortByState = useState('name');
  const searchState = useState('');

  return (
    <Stack fill vertical g={0}>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === Screen.ControlPanel}
            onClick={() => {
              setTabIndex(Screen.ControlPanel);
              act('check-apcs');
            }}
          >
            Panel sterowania APC
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === Screen.LogView}
            onClick={() => {
              setTabIndex(Screen.LogView);
              act('check-logs');
            }}
          >
            Logi
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {tabIndex === Screen.ControlPanel && (
          <Stack fill vertical g={0}>
            <Stack.Item>
              <Section>
                <ControlPanel
                  sortByState={sortByState}
                  searchState={searchState}
                />
              </Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow={4}>
              <Section fill scrollable>
                <ApcControlScene
                  sortByState={sortByState}
                  searchState={searchState}
                />
              </Section>
            </Stack.Item>
          </Stack>
        )}
        {tabIndex === Screen.LogView && <LogPanel />}
      </Stack.Item>
    </Stack>
  );
}

type ControlProps = {
  sortByState: [string, (field: string) => void];
  searchState: [string, (text: string) => void];
};

function ControlPanel(props: ControlProps) {
  const { act, data } = useBackend<Data>();
  const { emagged, auth_id } = data;
  const [sortByField, setSortByField] = props.sortByState;
  const [search, setSearch] = props.searchState;

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack justify="space-between" align="center">
          <Stack.Item color="label">Zalogowano jako: {auth_id}</Stack.Item>
          <Stack.Item>
            <Button
              icon="sign-out-alt"
              color="bad"
              onClick={() => act('log-out')}
            >
              Wyloguj
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item color="label">Sortuj:</Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              checked={sortByField === 'name'}
              onClick={() => setSortByField('name')}
            >
              Nazwa
            </Button.Checkbox>
            <Button.Checkbox
              checked={sortByField === 'charge'}
              onClick={() => setSortByField('charge')}
            >
              Ładunek
            </Button.Checkbox>
            <Button.Checkbox
              checked={sortByField === 'draw'}
              onClick={() => setSortByField('draw')}
            >
              Pobór
            </Button.Checkbox>
          </Stack.Item>
          <Stack.Item grow>
            {/* AQUILA: zastępuje dawny filtr nazwy */}
            <Input
              fluid
              placeholder="Szukaj obszaru..."
              value={search}
              onChange={(value) => setSearch(value)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {!!emagged && (
        <Stack.Item>
          <NoticeBox danger m={0}>
            <Stack align="center">
              <Stack.Item grow>
                Funkcja logowania została częściowo wyłączona z zewnątrz.
              </Stack.Item>
              <Stack.Item>
                <Button color="good" onClick={() => act('restore-logging')}>
                  Przywróć logowanie
                </Button>
              </Stack.Item>
            </Stack>
          </NoticeBox>
        </Stack.Item>
      )}
    </Stack>
  );
}

type WithIndex = APC & { id: string };

function ApcControlScene(props: ControlProps) {
  const { data, act } = useBackend<Data>();

  const [sortByField] = props.sortByState;
  const [search] = props.searchState;
  const searchText = search.toLowerCase();

  const withIndex = (data.apcs || [])
    .filter((apc) => apc.name.toLowerCase().includes(searchText))
    .map((apc, idx) => ({
      ...apc,
      id: apc.ref + idx,
    }));

  let sorted: WithIndex[] = [];
  if (sortByField === 'name') {
    sorted = sortBy(withIndex, [(apc) => apc.name]);
  } else if (sortByField === 'charge') {
    sorted = sortBy(withIndex, [(apc) => -apc.charge]);
  } else if (sortByField === 'draw') {
    sorted = sortBy(withIndex, [
      (apc) => -powerRank(apc.load),
      (apc) => -parseFloat(apc.load),
    ]);
  }

  if (!sorted.length) {
    return <NoticeBox>Brak dostępnych APC.</NoticeBox>;
  }

  return (
    <Table>
      <Table.Row header>
        <Table.Cell collapsing>Wł./wył.</Table.Cell>
        <Table.Cell>Obszar</Table.Cell>
        <Table.Cell collapsing>Ładunek</Table.Cell>
        <Table.Cell collapsing textAlign="right">
          Pobór
        </Table.Cell>
        <Table.Cell collapsing>Sprzęt</Table.Cell>
        <Table.Cell collapsing>Światło</Table.Cell>
        <Table.Cell collapsing>Środow.</Table.Cell>
      </Table.Row>
      {sorted.map((apc) => (
        <Table.Row key={apc.id} className="candystripe">
          <Table.Cell>
            <Button
              icon={apc.operating ? 'power-off' : 'times'}
              color={apc.operating ? 'good' : 'bad'}
              disabled={!apc.responds}
              tooltip="Główny wyłącznik"
              onClick={() =>
                act('breaker', {
                  ref: apc.ref,
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              color="transparent"
              selected={!!apc.active}
              disabled={!apc.responds}
              tooltip={
                apc.responds
                  ? 'Połącz zdalnie z interfejsem APC'
                  : 'APC nie odpowiada na zapytanie interfejsu'
              }
              onClick={() =>
                act('access-apc', {
                  ref: apc.ref,
                })
              }
            >
              {apc.name}
            </Button>
          </Table.Cell>
          <Table.Cell className="text-right text-nowrap">
            {apc.has_cell ? (
              <AreaCharge charging={apc.charging} charge={apc.charge} />
            ) : (
              <Box color="bad">Brak ogniwa</Box>
            )}
          </Table.Cell>
          <Table.Cell className="text-right text-nowrap">{apc.load}</Table.Cell>
          <Table.Cell className="text-center text-nowrap">
            <AreaStatusColorButton
              target="equipment"
              status={apc.eqp}
              apc={apc}
              act={act}
            />
          </Table.Cell>
          <Table.Cell className="text-center text-nowrap">
            <AreaStatusColorButton
              target="lighting"
              status={apc.lgt}
              apc={apc}
              act={act}
            />
          </Table.Cell>
          <Table.Cell className="text-center text-nowrap">
            <AreaStatusColorButton
              target="environ"
              status={apc.env}
              apc={apc}
              act={act}
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

function LogPanel(props) {
  const { act, data } = useBackend<Data>();
  const { emagged } = data;

  const logs = (data.logs || [])
    .map((line, idx) => ({ ...line, id: line.entry + idx }))
    .reverse();

  return (
    <Section
      fill
      scrollable
      buttons={
        !!emagged && (
          <Button color="bad" icon="trash" onClick={() => act('clear-logs')}>
            @#%! WYCZYŚĆ LOGI
          </Button>
        )
      }
    >
      {!logs.length && (
        <Box color="label">Na razie nie zarejestrowano żadnej aktywności.</Box>
      )}
      <Box m={-0.5}>
        {logs.map((line) => {
          // Format wpisu z DM: "(gg:mm:ss) operator: treść"
          const colonIndex = line.entry.indexOf(': ');
          const timestamp =
            colonIndex >= 0 ? line.entry.substring(0, colonIndex) : '';
          const message =
            colonIndex >= 0 ? line.entry.substring(colonIndex + 2) : line.entry;

          return (
            <Box p={0.5} key={line.id} className="candystripe">
              {!!timestamp && (
                <Box as="b" color="label">
                  {timestamp}:
                </Box>
              )}{' '}
              <Box>{message}</Box>
            </Box>
          );
        })}
      </Box>
    </Section>
  );
}

function AreaStatusColorButton(props) {
  const { target, status, apc, act } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);

  return (
    <Button
      icon={mode ? 'sync' : 'power-off'}
      color={power ? 'good' : 'bad'}
      disabled={!apc.responds}
      tooltip={
        power
          ? mode
            ? 'Automatycznie (wł.)'
            : 'Włączone'
          : mode
            ? 'Automatycznie (wył.)'
            : 'Wyłączone'
      }
      onClick={() =>
        act('toggle-minor', {
          type: target,
          value: statusChange(status),
          ref: apc.ref,
        })
      }
    />
  );
}

function statusChange(status) {
  // mode flip power flip both flip
  // 0, 2, 3
  return status === 0 ? 2 : status === 2 ? 3 : 0;
}
