import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  LabeledList,
  Modal,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  materials: MaterialData[];
  can_print: BooleanLike;
  cpus: CpuData[];
  total_cpu: number;
  power_usage: number;
  efficiency: number;
  ram: RamData[];
  total_ram: number;
  possible_ram: PossibleRamData[];
  unlocked_ram: number;
  unlocked_cpu: number;
  SHEET_MATERIAL_AMOUNT: number;
};

type MaterialData = {
  name: string;
  ref: string;
  amount: number;
  sheets: number;
  removable: BooleanLike;
};

type CpuData = {
  speed: number;
  efficiency: number;
  power_usage: number;
};

type RamData = {
  capacity: number;
  name: string;
  cost: string;
};

type PossibleRamData = {
  name: string;
  capacity: number;
  cost: string;
  id: string;
  unlocked: BooleanLike;
};

const SLOTS = [1, 2, 3, 4];

const CPU_LOCK_TECH = [
  '',
  '',
  'Lepsze gniazda CPU',
  'Zaawansowane gniazda CPU',
  "Bluespace'owe gniazda CPU",
];

const RAM_LOCK_TECH = [
  '',
  '',
  'Lepsza magistrala pamięci',
  'Zaawansowana magistrala pamięci',
  "Bluespace'owa magistrala pamięci",
];

const capitalize = (text: string) =>
  text ? text.charAt(0).toUpperCase() + text.slice(1) : '';

const LockedDimmer = (props: { tech: string }) => (
  <Dimmer>
    <Box color="average" textAlign="center">
      Zablokowane
      <br />
      Wymaga technologii: {props.tech}
    </Box>
  </Dimmer>
);

const CpuSlot = (props: { slot: number }) => {
  const { act, data } = useBackend<Data>();
  const { cpus = [], unlocked_cpu = 1 } = data;
  const { slot } = props;
  const cpu = cpus[slot - 1];
  const locked = unlocked_cpu < slot;

  return (
    <Section title={`CPU #${slot}`} textAlign="center">
      <Box position="relative" minHeight="110px">
        <Button
          color="transparent"
          icon="microchip"
          iconSize={4}
          fluid
          tooltip={cpu ? 'Wyjmij CPU' : 'Włóż CPU'}
          onClick={() =>
            cpu ? act('remove_cpu', { cpu_index: slot }) : act('insert_cpu')
          }
        />
        {cpu ? (
          <Box bold mt={0.5}>
            {cpu.speed} THz | {formatPower(cpu.power_usage)} ({cpu.efficiency}%)
          </Box>
        ) : (
          <Box color="label" mt={0.5}>
            Puste gniazdo
          </Box>
        )}
        {locked && <LockedDimmer tech={CPU_LOCK_TECH[slot]} />}
      </Box>
    </Section>
  );
};

const RamSlot = (props: { slot: number; onSelect: () => void }) => {
  const { act, data } = useBackend<Data>();
  const { ram = [], unlocked_ram = 1 } = data;
  const { slot, onSelect } = props;
  const stick = ram[slot - 1];
  const locked = unlocked_ram < slot;

  return (
    <Section title={`Kość #${slot}`}>
      <Box position="relative" minHeight="40px">
        <Stack align="center">
          <Stack.Item>
            <Button
              color="transparent"
              icon="memory"
              iconSize={2}
              tooltip={stick ? 'Wyjmij kość RAM' : 'Wybierz kość RAM'}
              onClick={() =>
                stick ? act('remove_ram', { ram_index: slot }) : onSelect()
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            {stick ? (
              <>
                <Box bold>
                  {toTitleCase(stick.name)} ({stick.capacity} TB)
                </Box>
                <Box italic color="label">
                  {capitalize(stick.cost)}
                </Box>
              </>
            ) : (
              <Box color="label">Puste gniazdo</Box>
            )}
          </Stack.Item>
        </Stack>
        {locked && <LockedDimmer tech={RAM_LOCK_TECH[slot]} />}
      </Box>
    </Section>
  );
};

const Materials = () => {
  const { act, data } = useBackend<Data>();
  const { materials = [] } = data;

  if (materials.length === 0) {
    return <Box color="label">Brak materiałów.</Box>;
  }

  return (
    <Table>
      {materials.map((material) => (
        <Table.Row key={material.ref} className="candystripe">
          <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
          <Table.Cell collapsing textAlign="right" pr={1}>
            {material.sheets} ark. ({material.amount} j.)
          </Table.Cell>
          <Table.Cell collapsing>
            {[1, 5].map((count) => (
              <Button
                key={count}
                disabled={material.sheets < count}
                onClick={() =>
                  act('remove_mat', { ref: material.ref, amount: count })
                }
              >
                x{count}
              </Button>
            ))}
            <Button
              icon="eject"
              disabled={!material.removable}
              onClick={() =>
                act('remove_mat', {
                  ref: material.ref,
                  amount: material.sheets,
                })
              }
            >
              Wszystko
            </Button>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

export const AiRackCreator = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    total_cpu = 0,
    total_ram = 0,
    power_usage = 0,
    efficiency = 1,
    can_print,
    possible_ram = [],
  } = data;

  const [modalStatus, setModalStatus] = useState(false);

  return (
    <Window width={650} height={800} title="Składarka racków">
      <Window.Content scrollable>
        <Section title="Statystyki">
          <LabeledList>
            <LabeledList.Item label="Moc obliczeniowa">
              {total_cpu} THz
            </LabeledList.Item>
            <LabeledList.Item label="Pamięć">{total_ram} TB</LabeledList.Item>
            <LabeledList.Item label="Pobór mocy">
              {formatPower(power_usage)}
            </LabeledList.Item>
            <LabeledList.Item label="Wydajność">
              {Math.round(efficiency * 100)}%
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Procesory">
          <Stack>
            <Stack.Item basis="50%">
              <CpuSlot slot={1} />
            </Stack.Item>
            <Stack.Item basis="50%">
              <CpuSlot slot={2} />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item basis="50%">
              <CpuSlot slot={3} />
            </Stack.Item>
            <Stack.Item basis="50%">
              <CpuSlot slot={4} />
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Pamięć RAM">
          {SLOTS.map((slot) => (
            <RamSlot
              key={slot}
              slot={slot}
              onSelect={() => setModalStatus(true)}
            />
          ))}
        </Section>
        <Button.Confirm
          fontSize="18px"
          textAlign="center"
          icon="arrow-right"
          fluid
          color="good"
          disabled={!can_print}
          tooltip={!can_print ? 'Za mało materiałów.' : undefined}
          confirmContent="Na pewno zbudować?"
          onClick={() => act('finalize')}
        >
          Zbuduj rack
        </Button.Confirm>
        <Section title="Materiały" mt={1}>
          <Materials />
        </Section>
      </Window.Content>
      {modalStatus && (
        <Modal width="550px">
          <Section title="Wybierz kość RAM">
            {possible_ram.map((entry) => (
              <Section
                key={entry.id}
                title={toTitleCase(entry.name)}
                buttons={
                  <Button
                    color="good"
                    tooltip={!entry.unlocked ? 'Nie odblokowano.' : undefined}
                    disabled={!entry.unlocked}
                    onClick={() => {
                      act('insert_ram', { ram_type: entry.id });
                      setModalStatus(false);
                    }}
                  >
                    Wybierz
                  </Button>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Pojemność">
                    {entry.capacity} TB
                  </LabeledList.Item>
                  <LabeledList.Item label="Koszt">
                    <Box italic>{capitalize(entry.cost)}</Box>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))}
            <Button
              fontSize="16px"
              fluid
              textAlign="center"
              color="bad"
              mt={1}
              onClick={() => setModalStatus(false)}
            >
              Anuluj
            </Button>
          </Section>
        </Modal>
      )}
    </Window>
  );
};
