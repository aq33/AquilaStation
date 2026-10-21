import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Location = {
  id: string;
  name: string;
};

type Data = {
  type: string;
  blind_drop: BooleanLike;
  turrets: Turret[];
  status: string;
  locked: BooleanLike;
  destination: string;
  docked_location: string;
  timer_str: string;
  locations: Location[];
};

type Turret = {
  ref: string;
  name: string;
  integrity: number;
  status: string;
  direction: string;
  distance: number;
};

const TURRET_STATUS: Record<string, { color: string; text: string }> = {
  ERROR: { color: 'bad', text: 'BŁĄD' },
  Disabled: { color: 'bad', text: 'Wyłączona' },
  Firing: { color: 'average', text: 'Strzela' },
  'All Clear': { color: 'good', text: 'Wszystko w porządku' },
};

const SHUTTLE_STATUS: Record<string, { color: string; text: string }> = {
  'In Transit': { color: 'good', text: 'W tranzycie' },
  Idle: { color: 'average', text: 'Bezczynny' },
  Igniting: { color: 'average', text: 'Zapłon' },
  Recharging: { color: 'average', text: 'Ładowanie' },
  Missing: { color: 'bad', text: 'Brak promu' },
  Locked: { color: 'bad', text: 'Zablokowany' },
};

const DIRECTIONS: Record<string, string> = {
  north: 'północ',
  south: 'południe',
  east: 'wschód',
  west: 'zachód',
  northeast: 'północny wschód',
  northwest: 'północny zachód',
  southeast: 'południowy wschód',
  southwest: 'południowy zachód',
};

enum TAB {
  Shuttle = 1,
  Aux,
}

export const AuxBaseConsole = (props) => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState(TAB.Shuttle);
  const { type, turrets = [] } = data;

  return (
    <Window
      width={turrets.length ? 620 : 350}
      height={turrets.length ? 310 : 260}
    >
      <Window.Content scrollable={!!turrets.length}>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === TAB.Shuttle}
            onClick={() => setTab(TAB.Shuttle)}
          >
            {type === 'shuttle' ? 'Start promu' : 'Zrzut bazy'}
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === TAB.Aux}
            onClick={() => setTab(TAB.Aux)}
          >
            Wieżyczki ({turrets.length})
          </Tabs.Tab>
        </Tabs>
        {tab === TAB.Shuttle && <AuxBaseShuttleContent />}
        {tab === TAB.Aux && <AuxBaseConsoleContent />}
      </Window.Content>
    </Window>
  );
};

const getLocationNameById = (locations: Location[], id: string) =>
  locations?.find((location) => location.id === id)?.name;

const getLocationIdByName = (locations: Location[], name: string) =>
  locations?.find((location) => location.name === name)?.id;

/** Sterowanie promem/bazą (odpowiednik ShuttleConsoleContent z tg) */
const AuxBaseShuttleContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    type,
    blind_drop,
    status,
    locked,
    destination,
    docked_location,
    timer_str,
    locations = [],
  } = data;
  const statusInfo = SHUTTLE_STATUS[status];
  return (
    <Section>
      <Box bold fontSize="26px" textAlign="center" fontFamily="monospace">
        {timer_str || '00:00'}
      </Box>
      <Box textAlign="center" fontSize="14px" mb={1}>
        <Box inline bold>
          STAN:
        </Box>
        <Box inline color={statusInfo?.color || 'bad'} ml={1}>
          {statusInfo?.text || status || 'Niedostępny'}
        </Box>
      </Box>
      <Section
        title={
          type === 'shuttle' ? 'Sterowanie promem' : 'Sterowanie zrzutem bazy'
        }
      >
        <LabeledList>
          <LabeledList.Item label="Położenie">
            {docked_location || 'Niedostępne'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Cel"
            buttons={
              type !== 'shuttle' &&
              locations.length === 0 &&
              !!blind_drop && (
                <Button
                  color="bad"
                  icon="exclamation-triangle"
                  tooltip="Niebezpieczne: losowe miejsce lądowania"
                  onClick={() => act('random')}
                >
                  Zrzut na ślepo
                </Button>
              )
            }
          >
            {(locations.length === 0 && (
              <Box mb={1.7} color="bad">
                Niedostępny
              </Box>
            )) ||
              (locations.length === 1 && (
                <Box mb={1.7} color="average">
                  {getLocationNameById(locations, destination)}
                </Box>
              )) || (
                <Dropdown
                  mb={1.7}
                  over
                  width="240px"
                  options={locations.map((location) => location.name)}
                  disabled={!!locked}
                  selected={
                    getLocationNameById(locations, destination) || 'Wybierz cel'
                  }
                  onSelected={(value) =>
                    act('set_destination', {
                      destination: getLocationIdByName(locations, value),
                    })
                  }
                />
              )}
          </LabeledList.Item>
        </LabeledList>
        <Button
          fluid
          disabled={!getLocationNameById(locations, destination) || !!locked}
          icon="arrow-up"
          textAlign="center"
          onClick={() =>
            act('move', {
              shuttle_id: destination,
            })
          }
        >
          {type === 'shuttle' ? 'Odlot' : 'Zrzuć bazę'}
        </Button>
      </Section>
    </Section>
  );
};

export const AuxBaseConsoleContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { turrets = [] } = data;

  return (
    <Section
      fill
      scrollable
      title="System obrony obwodowej"
      buttons={
        !!turrets.length && (
          <Button icon="power-off" onClick={() => act('turrets_power')}>
            Przełącz zasilanie
          </Button>
        )
      }
    >
      {!turrets.length ? (
        <NoticeBox>Brak podłączonych wieżyczek</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Jednostka</Table.Cell>
            <Table.Cell>Stan</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Kierunek</Table.Cell>
            <Table.Cell>Odległość</Table.Cell>
            <Table.Cell>Zasilanie</Table.Cell>
          </Table.Row>
          {turrets.map((turret) => (
            <Table.Row key={turret.ref}>
              <Table.Cell bold>{turret.name}</Table.Cell>
              <Table.Cell>{turret.integrity}%</Table.Cell>
              <Table.Cell color={TURRET_STATUS[turret.status]?.color || 'bad'}>
                {TURRET_STATUS[turret.status]?.text || turret.status}
              </Table.Cell>
              <Table.Cell>
                {DIRECTIONS[turret.direction] || turret.direction}
              </Table.Cell>
              <Table.Cell>{turret.distance} m</Table.Cell>
              <Table.Cell>
                <Button
                  icon="power-off"
                  onClick={() =>
                    act('single_turret_power', {
                      single_turret_power: turret.ref,
                    })
                  }
                >
                  Przełącz
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
