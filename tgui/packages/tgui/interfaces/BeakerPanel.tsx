import { useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type typePath = string;

type Reagent = {
  id: typePath;
  text: string;
};

type ContainerType = {
  id: typePath;
  text: string;
  volume: number;
};

type Data = {
  reagents: Reagent[];
  containers: ContainerType[];
};

type Container = {
  type: typePath;
  reagents: Record<typePath, number>;
};

function removeContainerReagent(
  container: Container,
  setContainer: (container: Container) => void,
  reagent: typePath,
) {
  const newReagents = { ...container.reagents };
  delete newReagents[reagent];
  setContainer({ ...container, reagents: newReagents });
}

function setContainerReagentVolume(
  container: Container,
  setContainer: (container: Container) => void,
  reagent: typePath,
  volume: number = 10,
) {
  const newReagents = { ...container.reagents };
  newReagents[reagent] = volume;
  setContainer({ ...container, reagents: newReagents });
}

function containerToSpawnInfo(container: Container) {
  return {
    container: container.type,
    reagents: container.reagents,
  };
}

function readableContainerType(container_type?: ContainerType) {
  if (!container_type) {
    return '';
  }
  return capitalizeFirst(`${container_type.text} (${container_type.volume}u)`);
}

function readableReagentType(reagent?: Reagent) {
  if (!reagent) {
    return '';
  }
  return capitalizeFirst(reagent.text);
}

function grenadeCheck(containers: Container[]) {
  return containers.every((container) => container.type.includes('beaker'));
}

// AQUILA - makro chemiczne ze starego panelu: "nazwa=ilość;nazwa=ilość"
function macroKey(text: string) {
  return text.toLowerCase().replace(/\W/g, '');
}

function exportMacro(container: Container, reagents: Reagent[]) {
  return Object.keys(container.reagents)
    .map((reagent) => {
      const found = reagents.find((r) => r.id === reagent);
      return `${macroKey(found?.text || reagent)}=${container.reagents[reagent]}`;
    })
    .join(';');
}

function importMacro(
  macro: string,
  container: Container,
  reagents: Reagent[],
): Container {
  const newReagents = { ...container.reagents };
  for (const part of macro.split(';')) {
    const [name, amount] = part.split('=');
    if (!name) {
      continue;
    }
    const found = reagents.find((r) => macroKey(r.text) === macroKey(name));
    const volume = Number(amount);
    if (found && volume > 0) {
      newReagents[found.id] = volume;
    }
  }
  return { ...container, reagents: newReagents };
}

type ContainerProps = {
  container: Container;
  number: number;
  updateContainer: (container: Container) => void;
  reagents: Reagent[];
  containers: ContainerType[];
};

const ContainerSection = (props: ContainerProps) => {
  const { container, number, updateContainer, reagents, containers } = props;
  const { act } = useBackend<Data>();

  const [addingReagent, setAddingReagent] = useState<string>(
    reagents[0]?.id || '',
  );
  const [addingReagentVolume, setAddingReagentVolume] = useState<number>(50);
  const [reagentSearch, setReagentSearch] = useState('');
  const [macro, setMacro] = useState('');

  const search = reagentSearch.toLowerCase();
  const filteredReagents = search
    ? reagents.filter(
        (reagent) =>
          reagent.text.toLowerCase().includes(search) ||
          reagent.id.toLowerCase().includes(search),
      )
    : reagents;

  return (
    <Section
      fill
      scrollable
      title={`Pojemnik ${number}`}
      buttons={
        <Button
          icon="cog"
          onClick={() =>
            act('spawn', { spawn_info: containerToSpawnInfo(container) })
          }
        >
          Stwórz
        </Button>
      }
    >
      <Stack fill vertical>
        <Stack.Item>
          <Dropdown
            fluid
            options={containers.map((container) => ({
              displayText: readableContainerType(container),
              value: container.id,
            }))}
            placeholder="Wybierz rodzaj pojemnika"
            selected={container.type}
            displayText={readableContainerType(
              containers.find((c) => c.id === container.type),
            )}
            onSelected={(value) => {
              updateContainer({ ...container, type: value });
            }}
          />
        </Stack.Item>
        {Object.keys(container.reagents).map((reagent) => (
          <Stack.Item key={reagent}>
            <Stack>
              <Stack.Item grow>
                <Button disabled fluid>
                  {readableReagentType(reagents.find((r) => r.id === reagent))}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  step={1}
                  minValue={0}
                  maxValue={1000}
                  unit="u"
                  value={container.reagents[reagent]}
                  onChange={(value) => {
                    setContainerReagentVolume(
                      container,
                      updateContainer,
                      reagent,
                      value,
                    );
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="red"
                  icon="minus"
                  tooltip="Usuń"
                  onClick={() => {
                    removeContainerReagent(container, updateContainer, reagent);
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
        <Stack.Item>
          <Input
            fluid
            placeholder="Szukaj odczynnika..."
            value={reagentSearch}
            onChange={(value) => {
              setReagentSearch(value);
              const first = reagents.find(
                (reagent) =>
                  reagent.text.toLowerCase().includes(value.toLowerCase()) ||
                  reagent.id.toLowerCase().includes(value.toLowerCase()),
              );
              if (first) {
                setAddingReagent(first.id);
              }
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Dropdown
                fluid
                options={filteredReagents.map((reagent) => ({
                  displayText: readableReagentType(reagent),
                  value: reagent.id,
                }))}
                placeholder="Dodaj odczynnik"
                selected={addingReagent}
                displayText={readableReagentType(
                  reagents.find((r) => r.id === addingReagent),
                )}
                onSelected={(value) => {
                  setAddingReagent(value);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                step={1}
                minValue={0}
                maxValue={1000}
                unit="u"
                value={addingReagentVolume}
                onChange={(value) => {
                  setAddingReagentVolume(value);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="green"
                icon="plus"
                tooltip="Dodaj"
                disabled={!addingReagent}
                onClick={() => {
                  setContainerReagentVolume(
                    container,
                    updateContainer,
                    addingReagent,
                    addingReagentVolume,
                  );
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                placeholder="Makro: nazwa=ilość;nazwa=ilość"
                value={macro}
                onChange={(value) => setMacro(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-import"
                tooltip="Dodaj odczynniki z makra"
                disabled={!macro}
                onClick={() =>
                  updateContainer(importMacro(macro, container, reagents))
                }
              >
                Import
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-export"
                tooltip="Wpisz zawartość pojemnika jako makro (do skopiowania)"
                onClick={() => setMacro(exportMacro(container, reagents))}
              >
                Eksport
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const BeakerPanel = () => {
  const { act, data } = useBackend<Data>();
  const { reagents = [], containers = [] } = data;

  const defaultContainer =
    containers.find(
      (c) => c.id === '/obj/item/reagent_containers/glass/beaker/large',
    ) || containers[0];
  const [container_one, setContainerOne] = useState<Container>({
    type: defaultContainer?.id || '',
    reagents: {},
  });
  const [container_two, setContainerTwo] = useState<Container>({
    type: defaultContainer?.id || '',
    reagents: {},
  });
  const [grenadeTimer, setGrenadeTimer] = useState<number>(5.0);

  const reagentsSorted = [...reagents].sort((a, b) =>
    a.text < b.text ? -1 : 1,
  );
  const containersSorted = [...containers].sort((a, b) =>
    readableContainerType(a) < readableContainerType(b) ? -1 : 1,
  );

  return (
    <Window
      title="Stwórz pojemnik z odczynnikami"
      width={850}
      height={480}
      theme="admin"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item>
                  <Button
                    icon="bomb"
                    tooltip={
                      grenadeCheck([container_one, container_two])
                        ? ''
                        : 'Oba pojemniki muszą być zlewkami!'
                    }
                    disabled={!grenadeCheck([container_one, container_two])}
                    onClick={() =>
                      act('spawngrenade', {
                        spawn_info: [
                          containerToSpawnInfo(container_one),
                          containerToSpawnInfo(container_two),
                        ],
                        grenade_info: {
                          detonation_type: 'normal',
                          detonation_timer: grenadeTimer,
                        },
                      })
                    }
                  >
                    Stwórz granat
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  Zapalnik:&nbsp;
                  <NumberInput
                    step={0.1}
                    minValue={1.0}
                    maxValue={10.0}
                    unit="s"
                    value={grenadeTimer}
                    onChange={(value) => {
                      setGrenadeTimer(value);
                    }}
                  />
                </Stack.Item>
                <Stack.Item fontSize={0.9}>
                  <i>
                    Pojemniki powiększą się, by zmieścić wszystkie odczynniki!
                  </i>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <ContainerSection
                  container={container_one}
                  number={1}
                  updateContainer={setContainerOne}
                  reagents={reagentsSorted}
                  containers={containersSorted}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <ContainerSection
                  container={container_two}
                  number={2}
                  updateContainer={setContainerTwo}
                  reagents={reagentsSorted}
                  containers={containersSorted}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
