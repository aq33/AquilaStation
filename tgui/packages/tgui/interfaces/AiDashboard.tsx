import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Input,
  LabeledControls,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  current_cpu: number;
  current_ram: number;
  used_cpu: number;
  used_ram: number;
  max_cpu: number;
  max_ram: number;
  contribute_spare_cpu: BooleanLike;
  categories: string[];
  available_projects: AvailableProjectData[];
  completed_projects: CompletedProject[];
  chargeable_abilities: ChargeableAbility[];
  integrity: number;
  location_name: string;
  location_coords: string;
  temperature: number;
};

type AvailableProjectData = {
  name: string;
  description: string;
  ram_required: number;
  available: BooleanLike;
  research_cost: number;
  research_progress: number;
  assigned_cpu: number;
  research_requirements: string | null;
  category: string;
};

type CompletedProject = {
  name: string;
  description: string;
  ram_required: number;
  running: BooleanLike;
  category: string;
  can_be_run: BooleanLike;
};

type ChargeableAbility = {
  assigned_cpu: number;
  cost: number;
  progress: number;
  name: string;
  project_name: string;
  uses: number;
  max_uses: number;
};

const round2 = (value: number) => Math.round(value * 100) / 100;

const matchesSearch = (name: string, search: string) =>
  name.toLowerCase().includes(search.toLowerCase());

export const AiDashboard = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    current_cpu = 0,
    current_ram = 0,
    used_cpu = 0,
    used_ram = 0,
    integrity = 0,
    location_name,
    location_coords,
    temperature = 0,
    contribute_spare_cpu,
  } = data;

  const [tab, setTab] = useState(1);
  const integrityPercent = round2((integrity + 100) * 0.5);

  return (
    <Window width={650} height={600} title="Panel SI">
      <Window.Content scrollable>
        <Section
          title="Stan"
          buttons={
            <Button
              onClick={() => act('toggle_contribute_cpu')}
              color={contribute_spare_cpu ? 'good' : 'bad'}
              icon={contribute_spare_cpu ? 'toggle-on' : 'toggle-off'}
            >
              {contribute_spare_cpu
                ? 'Wolne CPU idzie na badania'
                : 'Wolne CPU nie idzie na badania'}
            </Button>
          }
        >
          <LabeledControls>
            <LabeledControls.Item label="Integralność systemu">
              <ProgressBar
                ranges={{
                  good: [50, Infinity],
                  average: [25, 50],
                  bad: [-Infinity, 25],
                }}
                value={integrityPercent}
                maxValue={100}
              >
                {integrityPercent}%
              </ProgressBar>
            </LabeledControls.Item>
            <LabeledControls.Item label="Położenie łącza">
              <Box bold color="average">
                {location_name}
                <Box>({location_coords})</Box>
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Temperatura łącza">
              <ProgressBar
                ranges={{
                  good: [-Infinity, 250],
                  average: [250, 750],
                  bad: [750, Infinity],
                }}
                value={temperature}
                maxValue={750}
              >
                {temperature} K
              </ProgressBar>
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
            <LabeledControls.Item label="Użyte CPU">
              <ProgressBar
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.3, 0.7],
                  bad: [-Infinity, 0.3],
                }}
                value={used_cpu}
                maxValue={1}
              >
                {round2(used_cpu * 100)}% ({round2(used_cpu * current_cpu)}/
                {current_cpu} THz)
              </ProgressBar>
            </LabeledControls.Item>
            <LabeledControls.Item label="Użyty RAM">
              <ProgressBar
                ranges={{
                  good: [current_ram * 0.7, Infinity],
                  average: [current_ram * 0.3, current_ram * 0.7],
                  bad: [-Infinity, current_ram * 0.3],
                }}
                value={used_ram}
                maxValue={current_ram}
              >
                {used_ram}/{current_ram} TB
              </ProgressBar>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Dostępne projekty
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Ukończone projekty
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Ładowanie zdolności
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
            Zasoby w chmurze
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <AvailableProjects />}
        {tab === 2 && <CompletedProjects />}
        {tab === 3 && <AbilityCharging />}
        {tab === 4 && <NetworkingResources />}
      </Window.Content>
    </Window>
  );
};

const AvailableProjects = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], available_projects = [], used_cpu = 0 } = data;

  const [search, setSearch] = useState('');
  const [selectedCategory, setCategory] = useState(categories[0]);

  const remaining_cpu = (1 - used_cpu) * 100;

  return (
    <Section
      title="Dostępne projekty"
      buttons={
        <Input
          value={search}
          placeholder="Szukaj..."
          onChange={(value) => setSearch(value)}
        />
      }
    >
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category}
            selected={!search && selectedCategory === category}
            onClick={() => setCategory(category)}
          >
            {category}
          </Tabs.Tab>
        ))}
      </Tabs>
      {available_projects
        .filter((project) =>
          search
            ? matchesSearch(project.name, search)
            : project.category === selectedCategory,
        )
        .map((project) => (
          <Section
            key={project.name}
            title={project.name}
            buttons={
              <>
                <Box inline bold mr={0.5}>
                  Przydział CPU:
                </Box>
                <NumberInput
                  unit="%"
                  value={round2(project.assigned_cpu * 100)}
                  minValue={0}
                  maxValue={round2(remaining_cpu + project.assigned_cpu * 100)}
                  step={1}
                  onChange={(value) =>
                    act('allocate_cpu', {
                      project_name: project.name,
                      amount: round2(value / 100),
                    })
                  }
                />
                <Button
                  icon="arrow-up"
                  disabled={used_cpu >= 1}
                  onClick={() =>
                    act('max_cpu', {
                      project_name: project.name,
                    })
                  }
                >
                  Maks.
                </Button>
              </>
            }
          >
            <LabeledList>
              <LabeledList.Item
                label="Stan"
                color={project.available ? 'good' : 'bad'}
              >
                {project.available ? 'Dostępny' : 'Niedostępny'}
              </LabeledList.Item>
              <LabeledList.Item label="Koszt badań">
                {project.research_cost} THz
              </LabeledList.Item>
              <LabeledList.Item label="Wymagany RAM">
                {project.ram_required} TB
              </LabeledList.Item>
              <LabeledList.Item label="Wymagania">
                {project.research_requirements || 'Brak'}
              </LabeledList.Item>
            </LabeledList>
            <Box my={1}>{project.description}</Box>
            <ProgressBar
              value={
                project.research_cost
                  ? project.research_progress / project.research_cost
                  : 0
              }
            >
              {project.research_cost
                ? round2(
                    (project.research_progress / project.research_cost) * 100,
                  )
                : 0}
              % ({round2(project.research_progress)}/{project.research_cost}{' '}
              THz)
            </ProgressBar>
          </Section>
        ))}
    </Section>
  );
};

const CompletedProjects = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], completed_projects = [] } = data;

  const [search, setSearch] = useState('');
  const [runnableOnly, setRunnableOnly] = useState(true);
  const [selectedCategory, setCategory] = useState(categories[0]);

  return (
    <Section
      title="Ukończone projekty"
      buttons={
        <>
          <Button.Checkbox
            checked={runnableOnly}
            onClick={() => setRunnableOnly(!runnableOnly)}
          >
            Tylko uruchamialne
          </Button.Checkbox>
          <Input
            value={search}
            placeholder="Szukaj..."
            onChange={(value) => setSearch(value)}
          />
        </>
      }
    >
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category}
            selected={!search && selectedCategory === category}
            onClick={() => setCategory(category)}
          >
            {category}
          </Tabs.Tab>
        ))}
      </Tabs>
      {completed_projects
        .filter((project) => {
          if (search) {
            return matchesSearch(project.name, search);
          }
          if (runnableOnly && !project.can_be_run) {
            return false;
          }
          return project.category === selectedCategory;
        })
        .map((project) => (
          <Section
            key={project.name}
            title={project.name}
            buttons={
              !!project.can_be_run && (
                <Button
                  icon={project.running ? 'stop' : 'play'}
                  color={project.running ? 'bad' : 'good'}
                  onClick={() =>
                    act(project.running ? 'stop_project' : 'run_project', {
                      project_name: project.name,
                    })
                  }
                >
                  {project.running ? 'Zatrzymaj' : 'Uruchom'}
                </Button>
              )
            }
          >
            <LabeledList>
              <LabeledList.Item
                label="Stan"
                color={!project.can_be_run || project.running ? 'good' : 'bad'}
              >
                {project.can_be_run
                  ? project.running
                    ? 'Działa'
                    : 'Wyłączony'
                  : 'Pasywny'}
              </LabeledList.Item>
              {!!project.can_be_run && (
                <LabeledList.Item label="Wymagany RAM">
                  {project.ram_required} TB
                </LabeledList.Item>
              )}
            </LabeledList>
            <Box my={1}>{project.description}</Box>
          </Section>
        ))}
    </Section>
  );
};

const AbilityCharging = (props) => {
  const { act, data } = useBackend<Data>();
  const { chargeable_abilities = [], used_cpu = 0 } = data;
  const remaining_cpu = (1 - used_cpu) * 100;

  return (
    <Section title="Ładowanie zdolności">
      {chargeable_abilities.length === 0 && (
        <Box color="label">Brak zdolności do naładowania.</Box>
      )}
      {chargeable_abilities.map((ability) => (
        <Section
          key={ability.project_name}
          title={ability.name}
          buttons={
            <>
              <Box inline bold mr={0.5}>
                Przydział CPU:
              </Box>
              <NumberInput
                unit="%"
                value={round2(ability.assigned_cpu * 100)}
                minValue={0}
                maxValue={round2(remaining_cpu + ability.assigned_cpu * 100)}
                step={1}
                onChange={(value) =>
                  act('allocate_recharge_cpu', {
                    project_name: ability.project_name,
                    amount: round2(value / 100),
                  })
                }
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Pozostałe użycia">
              {ability.uses}/{ability.max_uses}
            </LabeledList.Item>
          </LabeledList>
          <ProgressBar
            mt={1}
            value={ability.cost ? ability.progress / ability.cost : 0}
          >
            {ability.cost ? round2((ability.progress / ability.cost) * 100) : 0}
            % ({round2(ability.progress)}/{ability.cost} THz)
          </ProgressBar>
        </Section>
      ))}
    </Section>
  );
};

const NetworkingResources = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_cpu = 0, max_cpu = 0, current_ram = 0, max_ram = 0 } = data;

  return (
    <Section
      title="Zasoby sieciowe"
      buttons={
        <Button icon="trash" onClick={() => act('clear_ai_resources')}>
          Zwolnij zasoby SI
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Moc CPU">
          <ProgressBar minValue={0} value={current_cpu} maxValue={max_cpu}>
            {current_cpu}/{max_cpu} THz
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Pojemność RAM">
          <ProgressBar minValue={0} value={current_ram} maxValue={max_ram}>
            {current_ram}/{max_ram} TB
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
