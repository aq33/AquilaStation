// AQUILA - monitor sieci telekomunikacji (aquila/code/game/machinery/telecomms/telecomms_monitors_ui.dm)
// Układ jak w tg (lista z wyszukiwarką, ekran urządzenia), dane i akcje nasze.
import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Machine = {
  id: string;
  name: string;
  ref: string;
};

type Selected = {
  id: string;
  name: string;
  on: boolean;
  links: Machine[];
};

type Data = {
  network: string;
  notice: string;
  machines: Machine[];
  selected: Selected | null;
};

export const TelecommsMonitor = (_) => {
  const { data } = useBackend<Data>();
  const { notice, selected } = data;
  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Stack vertical fill>
          {!!notice && (
            <Stack.Item>
              <NoticeBox info>{notice}</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            {selected ? <MachineScreen selected={selected} /> : <MainScreen />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainScreen = () => {
  const { act, data } = useBackend<Data>();
  const { network, machines = [] } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack align="center">
            <Stack.Item grow>
              <Box color="label" inline mr={1}>
                Sieć:
              </Box>
              <Box inline bold>
                {network}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button icon="network-wired" onClick={() => act('network')}>
                Zmień sieć
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="satellite-dish"
                disabled={machines.length > 0}
                tooltip={
                  machines.length > 0
                    ? 'Najpierw wyczyść bufor'
                    : 'Wyszukaj urządzenia w tej sieci'
                }
                onClick={() => act('probe')}
              >
                Skanuj sieć
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <MachineList
          title="Wykryte urządzenia sieci"
          emptyText="Brak urządzeń. Zeskanuj sieć."
          buttons={
            <Button
              icon="trash"
              color="red"
              tooltip="Wyczyść bufor"
              disabled={machines.length === 0}
              onClick={() => act('release')}
            />
          }
          machines={machines}
        />
      </Stack.Item>
    </Stack>
  );
};

const MachineScreen = (props: { selected: Selected }) => {
  const { act, data } = useBackend<Data>();
  const { network } = data;
  const { id, name, on, links = [] } = props.selected;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title="Informacje o urządzeniu"
          buttons={
            <Button icon="home" onClick={() => act('main_menu')}>
              Menu główne
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Sieć">{network}</LabeledList.Item>
            <LabeledList.Item label="Identyfikator">{id}</LabeledList.Item>
            <LabeledList.Item label="Urządzenie">
              {toTitleCase(name)}
            </LabeledList.Item>
            <LabeledList.Item label="Stan">
              <Box color={on ? 'good' : 'bad'}>
                {on ? 'Działa' : 'Wyłączone'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <MachineList
          title="Połączone urządzenia"
          emptyText="Brak połączeń."
          machines={links}
        />
      </Stack.Item>
    </Stack>
  );
};

type MachineListProps = {
  title: string;
  emptyText: string;
  buttons?: ReactNode;
  machines: Machine[];
};

const MachineList = (props: MachineListProps) => {
  const { act } = useBackend<Data>();
  const { title, emptyText, buttons, machines } = props;

  const [searching, setSearching] = useState(false);
  const [search, setSearch] = useState('');

  const filteredMachines = machines.filter((machine) =>
    `${machine.id} ${machine.name}`
      .toLowerCase()
      .includes(search.toLowerCase()),
  );

  return (
    <Section
      scrollable
      fill
      title={title}
      buttons={
        <>
          <Button
            icon="magnifying-glass"
            selected={searching}
            disabled={machines.length === 0}
            tooltip="Szukaj po identyfikatorze"
            onClick={() => setSearching(!searching)}
          />
          {buttons}
        </>
      }
    >
      {searching && (
        <Input
          fluid
          autoFocus
          mb={1}
          value={search}
          placeholder="Wpisz identyfikator urządzenia..."
          onChange={setSearch}
        />
      )}
      {filteredMachines.length > 0 ? (
        <Stack fill vertical>
          {filteredMachines.map((machine) => (
            <Stack.Item key={machine.ref}>
              <Button
                fluid
                icon="broadcast-tower"
                tooltip={toTitleCase(machine.name)}
                onClick={() => act('view', { ref: machine.ref })}
              >
                {machine.id}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      ) : (
        <NoticeBox>{machines.length ? 'Nic nie pasuje.' : emptyText}</NoticeBox>
      )}
    </Section>
  );
};
