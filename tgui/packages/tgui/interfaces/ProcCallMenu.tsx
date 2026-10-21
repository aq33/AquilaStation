// AQUILA: w tg to okno konfiguruje komponent wiremod „proccall”. U nas obsługuje
// Advanced ProcCall (zamiast serii input()). Wartości złożone (referencje, listy,
// typy itd.) wybiera się przez okno VV, tak jak wcześniej.
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Argument = {
  name: string;
  datatype: string;
  value: string;
};

type ProcCallMenuData = {
  target_selected: BooleanLike;
  target_name: string | null;
  procpath: string;
  arguments: Argument[];
  possible_types: string[];
};

// Wartości muszą się zgadzać z PROCCALL_ARG_* w callproc.dm
const TYPE_TEXT = 'Tekst';
const TYPE_NUM = 'Liczba';
const TYPE_VV = 'Zaawansowany (VV)';

export const ProcCallMenu = (props) => {
  const { act, data } = useBackend<ProcCallMenuData>();
  const {
    target_selected,
    target_name,
    procpath,
    arguments: args = [],
    possible_types = [],
  } = data;
  return (
    <Window width={560} height={460} title="Advanced ProcCall">
      <Window.Content scrollable>
        <Section title="Procedura">
          <LabeledList>
            <LabeledList.Item
              label="Właściciel"
              buttons={
                <>
                  <Button
                    icon="crosshairs"
                    onClick={() => act('select_target')}
                  >
                    Wybierz
                  </Button>
                  <Button
                    icon="globe"
                    selected={!target_selected}
                    tooltip="Wywołaj procedurę globalną (bez obiektu)."
                    onClick={() => act('clear_target')}
                  >
                    Globalna
                  </Button>
                </>
              }
            >
              {target_selected ? (
                target_name || (
                  <Box color="bad">Wybrany obiekt już nie istnieje</Box>
                )
              ) : (
                <Box color="label">brak (procedura globalna)</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Ścieżka">
              <Input
                fluid
                placeholder="np. /proc/fake_blood"
                value={procpath}
                onBlur={(value) => act('set_procpath', { path: value })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Argumenty">
          <Stack vertical>
            {args.map((val, index) => (
              <PortEntry
                key={index}
                name={val.name}
                datatype={val.datatype}
                value={val.value}
                datatypeOptions={possible_types}
                onRemove={() =>
                  act('remove_argument', {
                    index: index + 1,
                  })
                }
                onSetType={(type) =>
                  act('set_argument_datatype', {
                    index: index + 1,
                    datatype: type,
                  })
                }
                onEnter={(value) =>
                  act('rename_argument', {
                    index: index + 1,
                    name: value,
                  })
                }
                onSetValue={(value) =>
                  act('set_argument_value', {
                    index: index + 1,
                    value: value,
                  })
                }
                onPickValue={() =>
                  act('pick_argument_value', {
                    index: index + 1,
                  })
                }
              />
            ))}
            <Stack.Item>
              <Button
                fluid
                color="good"
                icon="plus"
                onClick={() => act('add_argument')}
              >
                Dodaj argument
              </Button>
            </Stack.Item>
            <Stack.Item>
              <NoticeBox info>
                Argumenty bez nazwy są pozycyjne i trafiają na początek. Puste
                pole nazwy oznacza argument pozycyjny.
              </NoticeBox>
            </Stack.Item>
          </Stack>
        </Section>
        <Button.Confirm
          fluid
          icon="play"
          color="bad"
          textAlign="center"
          disabled={!procpath}
          confirmContent="Na pewno wywołać?"
          onClick={() => act('call')}
        >
          Wywołaj
        </Button.Confirm>
      </Window.Content>
    </Window>
  );
};

type PortEntryProps = {
  name: string;
  datatype: string;
  value: string;
  datatypeOptions: string[];
  onRemove: () => void;
  onEnter: (value: string) => void;
  onSetType: (value: string) => void;
  onSetValue: (value: string) => void;
  onPickValue: () => void;
};

const PortEntry = (props: PortEntryProps) => {
  const {
    onRemove,
    onEnter,
    onSetType,
    onSetValue,
    onPickValue,
    name,
    datatype,
    value,
    datatypeOptions = [],
  } = props;

  return (
    <Stack.Item>
      <Stack align="center">
        <Stack.Item width="120px">
          <Input
            placeholder="Nazwa (opcjonalnie)"
            value={name}
            onBlur={onEnter}
            fluid
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            width="140px"
            selected={datatype}
            options={datatypeOptions}
            onSelected={onSetType}
          />
        </Stack.Item>
        <Stack.Item grow>
          {(datatype === TYPE_TEXT || datatype === TYPE_NUM) && (
            <Input
              fluid
              placeholder={datatype === TYPE_NUM ? '0' : 'Wartość'}
              value={value}
              onBlur={onSetValue}
            />
          )}
          {datatype === TYPE_VV && (
            <Button fluid ellipsis icon="pen" onClick={onPickValue}>
              {value || 'Wybierz wartość...'}
            </Button>
          )}
          {datatype !== TYPE_TEXT &&
            datatype !== TYPE_NUM &&
            datatype !== TYPE_VV && <Box color="label">null</Box>}
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" color="red" onClick={onRemove} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
