import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Image,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
  VirtualList,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';
import { classes } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import type { Material } from './Fabrication/Types';

type Machine = {
  name: string;
  icon: string;
  on_hold: boolean;
  location: string;
};

type Log = {
  raw_materials: string;
  machine_name: string;
  area_name: string;
  action: string;
  amount: number;
  time: string;
  noun: string;
};

enum Tab {
  Machines,
  Logs,
}

type Data = {
  materials: Material[];
  machines: Machine[];
  logs: Log[];
};

/** Akcje z dziennika silosu (wartości z DM) -> kolor i polska nazwa */
const ACTIONS: Record<string, { color: string; text: string }> = {
  deposited: { color: 'green', text: 'WPŁATA' },
  ejected: { color: 'red', text: 'WYPŁATA' },
  released: { color: 'red', text: 'WYDANIE' },
  withdrawn: { color: 'red', text: 'POBRANIE' },
  collected: { color: 'green', text: 'ZEBRANO' },
  smelted: { color: 'green', text: 'PRZETOPIONO' },
  reclaimed: { color: 'green', text: 'ODZYSK' },
  built: { color: 'blue', text: 'PRODUKCJA' },
  consume: { color: 'blue', text: 'ZUŻYCIE' },
};

const NOUNS: Record<string, string> = {
  sheets: 'arkuszy',
};

const actionInfo = (action: string) =>
  ACTIONS[action.toLowerCase()] || {
    color: 'grey',
    text: action.toUpperCase(),
  };

export const OreSilo = (props) => {
  const { act, data } = useBackend<Data>();
  const { machines = [], logs = [] } = data;

  const [currentTab, setCurrentTab] = useState<Tab>(Tab.Logs);

  return (
    <Window title="Silos rudy" width={620} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="plug"
                selected={currentTab === Tab.Machines}
                onClick={() => setCurrentTab(Tab.Machines)}
              >
                Podłączone maszyny
              </Tabs.Tab>
              <Tabs.Tab
                icon="book-bookmark"
                selected={currentTab === Tab.Logs}
                onClick={() => setCurrentTab(Tab.Logs)}
              >
                Dziennik dostępu
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {currentTab === Tab.Machines && (
              <MachineList
                machines={machines}
                onPause={(index) => act('hold', { id: index })}
                onRemove={(index) => act('remove', { id: index })}
              />
            )}
            {currentTab === Tab.Logs && <LogsList logs={logs} />}
          </Stack.Item>
          <Stack.Item>
            <Section fill>
              <MaterialAccessBar
                availableMaterials={data.materials || []}
                onEjectRequested={(material, amount) =>
                  act('eject', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type MachineListProps = {
  machines: Machine[];
  onPause: (index: number) => void;
  onRemove: (index: number) => void;
};

const MachineList = (props: MachineListProps) => {
  const { machines, onPause, onRemove } = props;

  return machines.length > 0 ? (
    <Section fill scrollable>
      {machines.map((machine, index) => (
        <MachineDisplay
          key={index}
          machine={machine}
          onPause={() => onPause(index + 1)}
          onRemove={() => onRemove(index + 1)}
        />
      ))}
    </Section>
  ) : (
    <NoticeBox>Brak podłączonych maszyn!</NoticeBox>
  );
};

type MachineProps = {
  machine: Machine;
  onPause: () => void;
  onRemove: () => void;
};

const MachineDisplay = (props: MachineProps) => {
  const { machine, onPause, onRemove } = props;

  let machineName = machine.name;
  const index = machineName.indexOf('('); // część techfabów ma lokalizację w nazwie
  if (index >= 0) {
    machineName = machineName.substring(0, index);
  }
  machineName = `${machineName.trimEnd()} (${machine.location})`;

  return (
    <Box className="FabricatorRecipe">
      <Box
        className={
          machine.on_hold
            ? classes([
                'FabricatorRecipe__Title',
                'FabricatorRecipe__Title--disabled',
              ])
            : 'FabricatorRecipe__Title'
        }
      >
        <Box className="FabricatorRecipe__Icon">
          <Image
            width={'32px'}
            height={'32px'}
            src={`data:image/jpeg;base64,${machine.icon}`}
          />
        </Box>
        <Box className="FabricatorRecipe__Label">{machineName}</Box>
      </Box>

      <Tooltip
        content={
          machine.on_hold
            ? `Wznów pobieranie przez: ${machine.name}.`
            : `Wstrzymaj pobieranie przez: ${machine.name}.`
        }
      >
        <Box
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
          ])}
          onClick={() => onPause()}
        >
          <Icon name={machine.on_hold ? 'circle-play' : 'circle-pause'} />
        </Box>
      </Tooltip>
      <Tooltip content={`Odłącz: ${machine.name}.`}>
        <Box
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
          ])}
          onClick={() => onRemove()}
        >
          <Icon name="trash-can" />
        </Box>
      </Tooltip>
    </Box>
  );
};

type LogsListProps = {
  logs: Log[];
};

const LogsList = (props: LogsListProps) => {
  const { logs } = props;

  const searchableLogs = logs.map((log, index) => ({
    id: index,
    log,
    searchString: [
      log.action.toLowerCase(),
      actionInfo(log.action).text.toLowerCase(),
      log.raw_materials.toLowerCase(),
      log.machine_name.toLowerCase(),
      log.area_name.toLowerCase(),
      log.noun.toLowerCase(),
    ].join(' '),
  }));

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: searchableLogs,
    matchStrategy: 'smart',
    getSearchString: (item) => item.searchString,
  });

  const filteredLogs = query ? results.map((result) => result.log) : logs;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Dziennik operacji">
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                height={1.7}
                autoFocus
                placeholder="Szukaj maszyn, miejsc i materiałów..."
                value={query}
                onChange={(value) => setQuery(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="close"
                onClick={() => setQuery('')}
                disabled={!query}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable={filteredLogs.length > 0} pr={1}>
          {filteredLogs.length > 0 ? (
            <VirtualList>
              {filteredLogs.map((log, index) => (
                <LogEntry key={index} {...log} />
              ))}
            </VirtualList>
          ) : (
            <NoticeBox textAlign="center">
              {query ? 'Żaden wpis nie pasuje do wyszukiwania.' : 'Pusto...'}
            </NoticeBox>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const LogEntry = (props: Log) => {
  const { raw_materials, machine_name, area_name, action, amount, time, noun } =
    props;
  const [expanded, setExpanded] = useState(false);
  const info = actionInfo(action);

  return (
    <Box>
      <Box
        style={{
          cursor: 'pointer',
        }}
        onClick={() => setExpanded(!expanded)}
      >
        <Stack align="center" style={{ padding: '0.5em' }}>
          <Stack.Item>
            <Button
              disabled
              icon={expanded ? 'arrow-down' : 'arrow-right'}
              color="disabled"
            />
          </Stack.Item>
          <Stack.Item>
            <Button color={info.color} width="9em" textAlign="center">
              {info.text}
            </Button>
          </Stack.Item>
          <Stack.Item style={{ display: 'flex', alignItems: 'center' }}>
            <Icon name="arrow-right" ml={1} mr={1} />
          </Stack.Item>
          <Stack.Item grow style={{ display: 'flex', alignItems: 'center' }}>
            {` ${Math.abs(amount)} ${NOUNS[noun] || noun}`}
          </Stack.Item>
          <Stack.Item style={{ display: 'flex', alignItems: 'center' }}>
            <Box color="label">{time}</Box>
          </Stack.Item>
        </Stack>
      </Box>

      {expanded && (
        <Box mt={0.5}>
          <Table>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Czas</Table.Cell>
              <Table.Cell>{time}</Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Maszyna</Table.Cell>
              <Table.Cell>{capitalize(machine_name)}</Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Miejsce</Table.Cell>
              <Table.Cell>{area_name}</Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight={2}>
              <Table.Cell pl={1}>Materiały</Table.Cell>
              <Table.Cell color={amount > 0 ? 'good' : 'bad'}>
                {raw_materials}
              </Table.Cell>
            </Table.Row>
          </Table>
        </Box>
      )}
    </Box>
  );
};
