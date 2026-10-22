// Lifeline z Monkestation: lista załogi z czujnikami zamiast mapy radaru.
// AQUILA: sortowanie i filtr trzymane w oknie, filtr dowództwa zamiast Blueshielda, ikony działów zamiast ikon prac.
import { useState } from 'react';
import { Box, Button, Icon, Input, Stack, Tabs } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { NtosWindow } from '../layouts';

type Data = {
  selected: string | null;
  sensors: CrewSensor[];
};

type CrewSensor = {
  ref: string;
  name: string;
  assignment: string;
  ijob: number;
  area?: string;
  dist: number;
  degrees: number;
  zdiff: number;
};

const SORT_NAMES = {
  dist: 'Odległość',
  ijob: 'Praca',
  name: 'Imię',
  area: 'Miejsce',
};

const SORT_OPTIONS = ['dist', 'ijob', 'name', 'area'];

const jobIsHead = (jobId: number) => jobId % 10 === 0;

// Dowództwo: szefowie działów (poza kwatermistrzem) i CentCom
const jobIsCommand = (jobId: number) =>
  (jobIsHead(jobId) && jobId !== 50) || (jobId >= 200 && jobId < 300);

const DEPARTMENTS = [
  { max: 10, color: COLORS.department.captain, icon: 'crown' },
  { max: 20, color: COLORS.department.security, icon: 'shield-alt' },
  { max: 30, color: COLORS.department.medbay, icon: 'medkit' },
  { max: 40, color: COLORS.department.science, icon: 'flask' },
  { max: 50, color: COLORS.department.engineering, icon: 'wrench' },
  { max: 60, color: COLORS.department.cargo, icon: 'box' },
  { max: 200, color: COLORS.department.service, icon: 'concierge-bell' },
  { max: 230, color: COLORS.department.centcom, icon: 'star' },
];

const jobDepartment = (jobId: number) =>
  DEPARTMENTS.find((dep) => jobId >= 0 && jobId < dep.max) || {
    color: COLORS.department.other,
    icon: 'user',
  };

const compareArea = (a: CrewSensor, b: CrewSensor) => {
  const areaA = a.area ?? '~';
  const areaB = b.area ?? '~';
  if (areaA < areaB) return -1;
  if (areaA > areaB) return 1;
  return 0;
};

export const NtosLifeline = () => {
  return (
    <NtosWindow width={400} height={600}>
      <NtosLifelineContent />
    </NtosWindow>
  );
};

const NtosLifelineContent = () => {
  const { data } = useBackend<Data>();
  const { sensors = [] } = data;
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState('dist');
  const [sortAsc, setSortAsc] = useState(true);
  const [commandOnly, setCommandOnly] = useState(false);

  const cycleSortBy = () => {
    let idx = SORT_OPTIONS.indexOf(sortBy) + 1;
    if (idx === SORT_OPTIONS.length) idx = 0;
    setSortBy(SORT_OPTIONS[idx]);
  };

  const nameSearch = createSearch(
    searchQuery,
    (crew: CrewSensor) => crew.name + crew.assignment,
  );

  const sorted = sensors
    .filter(nameSearch)
    .filter((sensor) => !commandOnly || jobIsCommand(sensor.ijob))
    .sort((a, b) => {
      if (a.dist < 0 || b.dist < 0) {
        return b.dist - a.dist;
      }
      switch (sortBy) {
        case 'name':
          return sortAsc ? +(a.name > b.name) : +(b.name > a.name);
        case 'ijob':
          return sortAsc ? a.ijob - b.ijob : b.ijob - a.ijob;
        case 'dist':
          return sortAsc ? a.dist - b.dist : b.dist - a.dist;
        case 'area':
          return sortAsc ? compareArea(a, b) : compareArea(b, a);
        default:
          return 0;
      }
    });

  return (
    <NtosWindow.Content scrollable>
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                placeholder="Szukaj po imieniu..."
                value={searchQuery}
                onChange={(value) => setSearchQuery(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button selected onClick={cycleSortBy}>
                {SORT_NAMES[sortBy]}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                selected
                icon={sortAsc ? 'chevron-up' : 'chevron-down'}
                onClick={() => setSortAsc(!sortAsc)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox
                checked={commandOnly}
                tooltip="Tylko dowództwo"
                onClick={() => setCommandOnly(!commandOnly)}
              >
                <Icon name="crown" />
              </Button.Checkbox>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          {sorted.length === 0 && (
            <Box color="label" mt={1}>
              Brak sygnałów czujników z pełnym śledzeniem.
            </Box>
          )}
          {sorted.map((sensor) => (
            <CrewTab key={sensor.ref} sensor={sensor} />
          ))}
        </Stack.Item>
      </Stack>
    </NtosWindow.Content>
  );
};

const CrewTab = (props: { sensor: CrewSensor }) => {
  const { act, data } = useBackend<Data>();
  const { sensor } = props;
  const selected = data.selected === sensor.ref;
  const department = jobDepartment(sensor.ijob);

  return (
    <Tabs.Tab
      className="candystripe"
      selected={selected}
      onClick={() => act('select', { ref: selected ? null : sensor.ref })}
    >
      <Stack align="center">
        <Stack.Item>
          <Icon name={selected ? 'check-square-o' : 'square-o'} />
        </Stack.Item>
        <Stack.Item>
          <Icon color={department.color} name={department.icon} width="20px" />
        </Stack.Item>
        <Stack.Item grow>
          <Box color={department.color} bold={jobIsHead(sensor.ijob)}>
            {sensor.name} ({sensor.assignment})
          </Box>
          <SensorLocation sensor={sensor} />
        </Stack.Item>
      </Stack>
    </Tabs.Tab>
  );
};

const SensorLocation = (props: { sensor: CrewSensor }) => {
  const { sensor } = props;
  if (sensor.dist < 0) {
    return (
      <Box color="label">
        <Icon name="satellite-dish" mr={0.5} />[{sensor.area ?? '???'}]
      </Box>
    );
  }
  let zdiff = '-';
  if (sensor.zdiff > 0) {
    zdiff = '↑'.repeat(sensor.zdiff);
  } else if (sensor.zdiff < 0) {
    zdiff = '↓'.repeat(-sensor.zdiff);
  }
  return (
    <Box>
      {sensor.dist > 0 && (
        <Icon mr={0.5} size={0.8} name="arrow-up" rotation={sensor.degrees} />
      )}
      {sensor.dist}m {zdiff} [{sensor.area}]
    </Box>
  );
};
