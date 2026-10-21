import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  records: WarrantRecord[];
};

type WarrantRecord = {
  citations: Citation[];
  crew_name: string;
  crew_ref: string;
  /** AQUILA: akta właściciela karty ID */
  own: BooleanLike;
  crimes?: Crime[];
  criminal?: string;
};

type Citation = {
  author: string;
  details: string;
  fine_name: string;
  fine_ref: number;
  fine: number;
  paid: number;
  time: string;
};

type Crime = {
  name: string;
  details: string;
  author: string;
  time: string;
};

/** Statusy z akt ochrony (wartości z DM) */
const CRIMINAL_STATUS: Record<string, { label: string; color: string }> = {
  Arrest: { label: 'Do aresztowania', color: 'bad' },
  Incarcerated: { label: 'Uwięziony', color: 'orange' },
  Search: { label: 'Do przeszukania', color: 'purple' },
  Monitor: { label: 'Pod obserwacją', color: 'bad' },
  Paroled: { label: 'Zwolniony warunkowo', color: 'orange' },
  Discharged: { label: 'Zwolniony', color: 'blue' },
  None: { label: 'Brak', color: 'good' },
};

export const WarrantConsole = (props) => {
  const { data } = useBackend<Data>();
  const { records = [] } = data;
  const [selectedRef, setSelectedRef] = useState<string | undefined>(undefined);
  const selectedRecord = records.find(
    (record) => record.crew_ref === selectedRef,
  );

  return (
    <Window width={540} height={500}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={2}>
            <RecordList
              selectedRef={selectedRecord?.crew_ref}
              onSelect={(ref) =>
                setSelectedRef(ref === selectedRef ? undefined : ref)
              }
            />
          </Stack.Item>
          {selectedRecord && (
            <Stack.Item grow={3}>
              <ViewRecord record={selectedRecord} />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays all valid records with warrants. */
const RecordList = (props: {
  selectedRef?: string;
  onSelect: (ref: string) => void;
}) => {
  const { selectedRef, onSelect } = props;
  const { act, data } = useBackend<Data>();
  const { records = [] } = data;
  // własne akta na górze, reszta alfabetycznie
  const sorted = sortBy(records, [
    (record) => (record.own ? 0 : 1),
    (record) => record.crew_name,
  ]);

  return (
    <Section
      buttons={
        <Button
          icon="sync"
          onClick={() => act('refresh')}
          tooltip="Odśwież"
          tooltipPosition="bottom-start"
        />
      }
      fill
      scrollable
      title="Grzywny"
    >
      <Stack fill vertical>
        {!records?.length ? (
          <NoticeBox>Nie wystawiono żadnych grzywien.</NoticeBox>
        ) : (
          <Tabs vertical>
            {sorted.map((record) => (
              <Tabs.Tab
                className="candystripe"
                key={record.crew_ref}
                icon={record.own ? 'user' : undefined}
                onClick={() => onSelect(record.crew_ref)}
                selected={selectedRef === record.crew_ref}
              >
                {record.crew_name}: {record.citations.length}
              </Tabs.Tab>
            ))}
          </Tabs>
        )}
      </Stack>
    </Section>
  );
};

/** Views info on the current selection. */
const ViewRecord = (props: { record: WarrantRecord }) => {
  const { record } = props;
  const { citations = [], crew_name, own, crimes = [], criminal } = record;
  const status = criminal ? CRIMINAL_STATUS[criminal] : undefined;

  return (
    <Section fill scrollable title={crew_name}>
      <Stack fill vertical>
        {!!own && (
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box bold color={status?.color}>
                  {status?.label || criminal || 'Brak'}
                  {criminal === 'Arrest' && ' — ZGŁOŚ SIĘ DO ARESZTU'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        )}
        {!citations.length && (
          <Stack.Item>
            <NoticeBox info>Brak grzywien.</NoticeBox>
          </Stack.Item>
        )}
        {citations.map((citation) => (
          <Stack.Item key={citation.fine_ref}>
            <CitationManager citation={citation} crew_ref={record.crew_ref} />
          </Stack.Item>
        ))}
        {!!own && (
          <Stack.Item>
            <Section title="Przestępstwa">
              {!crimes.length ? (
                <Box color="label">Brak wpisów.</Box>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Przestępstwo</Table.Cell>
                    <Table.Cell>Szczegóły</Table.Cell>
                    <Table.Cell>Autor</Table.Cell>
                    <Table.Cell>Czas</Table.Cell>
                  </Table.Row>
                  {crimes.map((crime, index) => (
                    <Table.Row key={index} className="candystripe">
                      <Table.Cell>{crime.name}</Table.Cell>
                      <Table.Cell>{crime.details}</Table.Cell>
                      <Table.Cell>{crime.author}</Table.Cell>
                      <Table.Cell>{crime.time}</Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

/** Handles paying fines */
const CitationManager = (props: { citation: Citation; crew_ref: string }) => {
  const { act } = useBackend<Data>();
  const {
    crew_ref,
    citation: { author, details, fine, fine_ref, fine_name, paid, time },
  } = props;

  const [paying, setPaying] = useState(Math.min(5, fine));
  const [payingIsValid, setPayingIsValid] = useState(true);

  return (
    <Collapsible
      buttons={
        <Button
          disabled={fine <= 0}
          icon="print"
          onClick={() =>
            act('print', { crew_ref: crew_ref, fine_ref: fine_ref })
          }
        >
          Drukuj
        </Button>
      }
      color={getFineColor(fine)}
      title={fine_name}
    >
      <LabeledList>
        <LabeledList.Item label="Szczegóły">
          <BlockQuote>{details}</BlockQuote>
        </LabeledList.Item>
        <LabeledList.Item label="Wystawił">{author}</LabeledList.Item>
        <LabeledList.Item label="Czas">{time}</LabeledList.Item>
        <LabeledList.Item label="Do zapłaty">
          {fine > 0 ? `${fine} cr` : 'Wszystko spłacone'}
        </LabeledList.Item>
        <LabeledList.Item label="Wpłacono">{paid} cr</LabeledList.Item>
        {fine > 0 && (
          <LabeledList.Item label="Zapłać z konta">
            <RestrictedInput
              maxValue={fine}
              minValue={1}
              onChange={setPaying}
              value={paying}
              onValidationChange={setPayingIsValid}
            />
            <Button.Confirm
              disabled={!payingIsValid}
              confirmContent="Na pewno?"
              onClick={() =>
                act('pay', {
                  amount: paying,
                  crew_ref: crew_ref,
                  fine_ref: fine_ref,
                })
              }
            >
              Zapłać
            </Button.Confirm>
          </LabeledList.Item>
        )}
        {fine > 0 && (
          <LabeledList.Item label="Holożeton">
            <Button
              icon="money-bill"
              tooltip="Wpłaca całą wartość holożetonu trzymanego w ręce."
              onClick={() =>
                act('pay_holochip', {
                  crew_ref: crew_ref,
                  fine_ref: fine_ref,
                })
              }
            >
              Zapłać holożetonem
            </Button>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Collapsible>
  );
};

/** Returns a color based on the fine amount */
export const getFineColor = (fine: number) => {
  switch (true) {
    case fine > 700:
      return 'bad';
    case fine > 300:
      return 'average';
    case fine === 0:
      return 'grey';
    default:
      return '';
  }
};
