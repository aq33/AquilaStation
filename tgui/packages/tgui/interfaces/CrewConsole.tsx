import { useState } from 'react';
import { Box, Button, Icon, Input, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

// Wartości stat z code/__DEFINES/stat.dm (u nas DEAD = 3)
const STAT_LIVING = 0;
const STAT_DEAD = 3;

const jobIsHead = (jobId: number) => jobId % 10 === 0;

const damageSum = (sensor: CrewSensor) =>
  (sensor.oxydam ?? 0) +
  (sensor.toxdam ?? 0) +
  (sensor.burndam ?? 0) +
  (sensor.brutedam ?? 0);

const SORT_OPTIONS = [
  {
    name: 'Stanowisko',
    sort: (a: CrewSensor, b: CrewSensor) => {
      return a.ijob - b.ijob;
    },
  },
  {
    name: 'Nazwisko',
    sort: (a: CrewSensor, b: CrewSensor) => {
      if (a.name > b.name) return 1;
      if (a.name < b.name) return -1;
      return 0;
    },
  },
  {
    name: 'Obszar',
    sort: (a: CrewSensor, b: CrewSensor) => {
      if (a.area === undefined) return 1;
      if (b.area === undefined) return -1;
      if (a.area > b.area) return 1;
      if (a.area < b.area) return -1;
      return 0;
    },
  },
  {
    name: 'Funkcje życiowe',
    sort: (a: CrewSensor, b: CrewSensor) => {
      if ((a.life_status ?? 0) > (b.life_status ?? 0)) return -1;
      if ((a.life_status ?? 0) < (b.life_status ?? 0)) return 1;

      if (b.oxydam === undefined) return -1;
      if (a.oxydam === undefined) return 1;

      // AQUILA: nie wysyłamy "health", więc liczymy z sumy obrażeń
      if (damageSum(a) > damageSum(b)) return -1;
      if (damageSum(a) < damageSum(b)) return 1;

      return 0;
    },
  },
];

const jobToColor = (jobId: number) => {
  if (jobId >= 0 && jobId < 10) {
    return COLORS.department.captain;
  }
  if (jobId >= 10 && jobId < 20) {
    return COLORS.department.security;
  }
  if (jobId >= 20 && jobId < 30) {
    return COLORS.department.medbay;
  }
  if (jobId >= 30 && jobId < 40) {
    return COLORS.department.science;
  }
  if (jobId >= 40 && jobId < 50) {
    return COLORS.department.engineering;
  }
  if (jobId >= 50 && jobId < 60) {
    return COLORS.department.cargo;
  }
  if (jobId >= 60 && jobId < 200) {
    return COLORS.department.service;
  }
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

const statToIcon = (life_status: number | undefined) => {
  switch (life_status) {
    case STAT_LIVING:
      return 'heart';
    case STAT_DEAD:
      return 'skull';
  }
  return 'heartbeat';
};

const healthToAttribute = (
  oxy: number,
  tox: number,
  burn: number,
  brute: number,
  attributeList: string[],
) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return attributeList[level];
};

type HealthStatProps = {
  type: string;
  value: number;
};

const HealthStat = (props: HealthStatProps) => {
  const { type, value } = props;
  return (
    <Box inline width={2} color={COLORS.damageType[type]} textAlign="center">
      {value}
    </Box>
  );
};

export const CrewConsole = () => {
  return (
    <Window title="Monitor załogi" width={600} height={600}>
      <Window.Content scrollable>
        <Section minHeight="540px">
          <CrewTable />
        </Section>
      </Window.Content>
    </Window>
  );
};

type CrewSensor = {
  name: string;
  assignment: string | undefined;
  ijob: number;
  life_status: number | undefined;
  oxydam: number | undefined;
  toxdam: number | undefined;
  burndam: number | undefined;
  brutedam: number | undefined;
  area: string | undefined;
  ref: string;
  can_track: BooleanLike;
};

type CrewConsoleData = {
  sensors: CrewSensor[];
  link_allowed: BooleanLike;
};

const CrewTable = () => {
  const { data } = useBackend<CrewConsoleData>();
  const { sensors = [] } = data;

  const [sortAsc, setSortAsc] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [indexOfSortingOption, setIndexOfSortingOption] = useState(0);

  const cycleSortBy = () => {
    setIndexOfSortingOption((indexOfSortingOption + 1) % SORT_OPTIONS.length);
  };

  const nameSearch = createSearch(searchQuery, (crew: CrewSensor) => crew.name);

  const sorted = sensors
    .filter(nameSearch)
    .sort((a, b) =>
      sortAsc
        ? SORT_OPTIONS[indexOfSortingOption].sort(a, b)
        : SORT_OPTIONS[indexOfSortingOption].sort(b, a),
    );

  return (
    <Section
      title={
        <>
          <Button tooltip="Zmień sortowanie" onClick={cycleSortBy}>
            {SORT_OPTIONS[indexOfSortingOption].name}
          </Button>
          <Button onClick={() => setSortAsc(!sortAsc)}>
            <Icon
              style={{ marginLeft: '2px' }}
              name={sortAsc ? 'chevron-up' : 'chevron-down'}
            />
          </Button>
          <Input
            placeholder="Szukaj po nazwisku..."
            onChange={setSearchQuery}
            value={searchQuery}
          />
        </>
      }
    >
      <Table>
        <Table.Row>
          <Table.Cell bold>Nazwisko</Table.Cell>
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Funkcje życiowe
          </Table.Cell>
          <Table.Cell bold textAlign="center">
            Położenie
          </Table.Cell>
          {!!data.link_allowed && (
            <Table.Cell bold collapsing textAlign="center">
              Śledzenie
            </Table.Cell>
          )}
        </Table.Row>
        {sorted.map((sensor) => (
          <CrewTableEntry sensor_data={sensor} key={sensor.ref} />
        ))}
      </Table>
    </Section>
  );
};

type CrewTableEntryProps = {
  sensor_data: CrewSensor;
};

const CrewTableEntry = (props: CrewTableEntryProps) => {
  const { act, data } = useBackend<CrewConsoleData>();
  const { link_allowed } = data;
  const { sensor_data } = props;
  const {
    name,
    assignment,
    ijob,
    life_status,
    oxydam,
    toxdam,
    burndam,
    brutedam,
    area,
    can_track,
  } = sensor_data;

  return (
    <Table.Row className="candystripe">
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        {name}
        {assignment !== undefined ? ` (${assignment})` : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Icon
            name={statToIcon(life_status)}
            color={healthToAttribute(
              oxydam,
              toxdam ?? 0,
              burndam ?? 0,
              brutedam ?? 0,
              HEALTH_COLOR_BY_LEVEL,
            )}
            size={1}
          />
        ) : life_status !== STAT_DEAD ? (
          <Icon name="heart" color="#17d568" size={1} />
        ) : (
          <Icon name="skull" color="#801308" size={1} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Box inline>
            <HealthStat type="oxy" value={oxydam} />
            {'/'}
            <HealthStat type="toxin" value={toxdam ?? 0} />
            {'/'}
            <HealthStat type="burn" value={burndam ?? 0} />
            {'/'}
            <HealthStat type="brute" value={brutedam ?? 0} />
          </Box>
        ) : life_status !== STAT_DEAD ? (
          'Żywy'
        ) : (
          'Martwy'
        )}
      </Table.Cell>
      <Table.Cell>
        {area !== '~' && area !== undefined ? (
          area
        ) : (
          <Icon name="question" color="#ffffff" size={1} />
        )}
      </Table.Cell>
      {!!link_allowed && (
        <Table.Cell collapsing>
          <Button
            disabled={!can_track}
            onClick={() =>
              act('select_person', {
                name: name,
              })
            }
          >
            Śledź
          </Button>
        </Table.Cell>
      )}
    </Table.Row>
  );
};
