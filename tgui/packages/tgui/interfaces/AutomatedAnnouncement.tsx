import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA EDIT - wygląd z tg, ale nasz DM ma tylko dwa stałe ogłoszenia
// (przybycie i nowy szef działu), więc wpisy budujemy tutaj z naszych kluczy.
type Data = {
  arrival: string;
  arrivalToggle: BooleanLike;
  newhead: string;
  newheadToggle: BooleanLike;
  max_announcement_len?: number;
};

type AASConfigEntry = {
  name: string;
  entryRef: string;
  enabled: BooleanLike;
  text: string;
  toggleAction: string;
  textAction: string;
};

const VARS_TOOLTIP = [
  '%PERSON zostanie zastąpione imieniem i nazwiskiem.',
  '%RANK - stanowiskiem.',
  '%STNAME - nazwą statku.',
].join('\n');

export const AutomatedAnnouncement = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    arrival,
    arrivalToggle,
    newhead,
    newheadToggle,
    max_announcement_len,
  } = data;

  const config_entries: AASConfigEntry[] = [
    {
      name: 'Ogłoszenie o przybyciu',
      entryRef: 'arrival',
      enabled: arrivalToggle,
      text: arrival,
      toggleAction: 'ArrivalToggle',
      textAction: 'ArrivalText',
    },
    {
      name: 'Ogłoszenie o nowym szefie działu',
      entryRef: 'newhead',
      enabled: newheadToggle,
      text: newhead,
      toggleAction: 'NewheadToggle',
      textAction: 'NewheadText',
    },
  ];

  const [search, setSearch] = useState('');

  const isEntryMatch = (entry: AASConfigEntry, search: string) => {
    if (!search) return true;
    const query = search.toLowerCase();
    return (
      entry.name.toLowerCase().includes(query) ||
      (entry.text || '').toLowerCase().includes(query)
    );
  };

  const sorted = sortBy(
    filter(config_entries, (entry) => isEntryMatch(entry, search)),
    [(entry) => entry.name],
  );
  return (
    <Window title="Automatyczny system ogłoszeń" width={500} height={280}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Szukaj">
                <Input fluid placeholder="Nazwa/treść" onChange={setSearch} />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item grow>
            {!sorted.length ? (
              <NoticeBox>Brak wyników. Zawęź wyszukiwanie.</NoticeBox>
            ) : (
              <Section fill scrollable>
                {sorted.map((entry) => (
                  <Section
                    key={entry.entryRef}
                    title={entry.name}
                    buttons={
                      <>
                        <Button
                          icon="info"
                          tooltip={VARS_TOOLTIP}
                          tooltipPosition="left"
                        />
                        <Button
                          icon={entry.enabled ? 'power-off' : 'times'}
                          selected={entry.enabled}
                          onClick={() => act(entry.toggleAction)}
                        >
                          {entry.enabled ? 'Wł.' : 'Wył.'}
                        </Button>
                      </>
                    }
                  >
                    <Table>
                      <Table.Row>
                        <Table.Cell collapsing color="label">
                          Treść:
                        </Table.Cell>
                        <Table.Cell>
                          <Input
                            fluid
                            value={entry.text}
                            maxLength={max_announcement_len}
                            onBlur={(value) =>
                              act(entry.textAction, {
                                newText: value,
                              })
                            }
                          />
                        </Table.Cell>
                      </Table.Row>
                    </Table>
                  </Section>
                ))}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
