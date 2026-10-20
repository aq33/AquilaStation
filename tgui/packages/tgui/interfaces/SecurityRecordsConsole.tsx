// AQUILA - konsola rekordów ochrony (aquila/code/game/machinery/computer/security_records_ui.dm)
// Układ z tg (SecurityRecords: lista po lewej, rekord po prawej), dane i akcje nasze:
// przyciski idą przez dawny Topic(), więc logi, dostęp, mandaty i wydruki działają bez zmian.
import { sortBy } from 'es-toolkit';
import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type TopicButton = {
  params: Record<string, string>;
  label: string;
};

type Temp = {
  text: string;
  buttons: TopicButton[];
};

type RecordRow = {
  ref: string;
  name: string;
  id: string;
  rank: string;
  fingerprint: string;
  criminal: string;
};

type General = {
  name: string;
  id: string;
  gender: string;
  age: string | number;
  species: string;
  rank: string;
  fingerprint: string;
  physical: string;
  mental: string;
  photo_front: string | null;
  photo_side: string | null;
};

type Citation = {
  id: number;
  name: string;
  fine: number;
  owed: number;
  author: string;
  time: string;
};

type Crime = {
  id: number;
  name: string;
  details: string;
  author: string;
  time: string;
};

type Comment = {
  index: number;
  text: string;
  deleted: BooleanLike;
};

type SecurityRecord = {
  criminal: string;
  notes: string;
  citations: Citation[];
  crimes: Crime[];
  comments: Comment[];
};

type Data = {
  authenticated: string | null;
  rank: string | null;
  screen: number | null;
  printing: BooleanLike;
  temp: Temp | null;
  records?: RecordRow[];
  active_ref?: string | null;
  general?: General | null;
  security?: SecurityRecord | null;
};

const STATUS_COLORS = {
  Arrest: 'bad',
  Incarcerated: 'average',
  Search: 'purple',
  Monitor: 'teal',
  Paroled: 'good',
  Discharged: 'blue',
  None: 'label',
};

const STATUS_NAMES = {
  Arrest: 'Do aresztowania',
  Incarcerated: 'Uwięziony',
  Search: 'Do przeszukania',
  Monitor: 'Obserwacja',
  Paroled: 'Zwolniony warunkowo',
  Discharged: 'Zwolniony',
  None: 'Brak',
};

// Wartość statusu w DM -> parametr criminal2 dla "Change Criminal Status"
const STATUS_BUTTONS = [
  { status: 'None', param: 'none', desc: 'Brak. Nic nie jest zarzucane.' },
  {
    status: 'Arrest',
    param: 'arrest',
    desc: 'Do aresztowania. Ochrona ma zatrzymać osobę.',
  },
  {
    status: 'Search',
    param: 'search',
    desc: 'Do przeszukania. Ochrona ma przeszukać osobę.',
  },
  {
    status: 'Monitor',
    param: 'monitor',
    desc: 'Obserwacja. Pilnuj tej osoby pod kątem przestępstw.',
  },
  {
    status: 'Incarcerated',
    param: 'incarcerated',
    desc: 'Uwięziony. Osoba odbywa obecnie wyrok.',
  },
  {
    status: 'Paroled',
    param: 'paroled',
    desc: 'Zwolniony warunkowo. Na wolności, ale pod nadzorem.',
  },
  {
    status: 'Discharged',
    param: 'released',
    desc: 'Zwolniony. Osoba odbyła karę lub ją uniewinniono.',
  },
];

const useTopic = () => {
  const { act } = useBackend<Data>();
  return (params: Record<string, string | number>) => act('topic', params);
};

const ChoiceButton = (props: {
  choice: string;
  extra?: Record<string, string | number>;
  icon?: string;
  color?: string;
  disabled?: BooleanLike;
  tooltip?: string;
  children?: ReactNode;
}) => {
  const topic = useTopic();
  return (
    <Button
      icon={props.icon}
      color={props.color}
      disabled={props.disabled}
      tooltip={props.tooltip}
      onClick={() => topic({ choice: props.choice, ...props.extra })}
    >
      {props.children}
    </Button>
  );
};

const EditField = (props: {
  field: string;
  children?: ReactNode;
  icon?: string;
  tooltip?: string;
}) => (
  <ChoiceButton
    choice="Edit Field"
    extra={{ field: props.field }}
    icon={props.icon || 'pen'}
    tooltip={props.tooltip}
  >
    {props.children}
  </ChoiceButton>
);

export const SecurityRecordsConsole = (_) => {
  const { data } = useBackend<Data>();
  const { authenticated } = data;
  return (
    <Window title="Rekordy ochrony" width={820} height={620}>
      <Window.Content>
        <Stack fill>{!authenticated ? <RestrictedView /> : <AuthView />}</Stack>
      </Window.Content>
    </Window>
  );
};

/** Ekran przed zalogowaniem */
const RestrictedView = () => (
  <Stack.Item grow>
    <Stack fill vertical>
      <Stack.Item grow />
      <Stack.Item align="center" grow={2}>
        <Icon color="average" name="exclamation-triangle" size={15} />
      </Stack.Item>
      <Stack.Item align="center" grow>
        <Box color="red" fontSize="18px" bold mt={5}>
          Nanotrasen SecurityHUB
        </Box>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox align="right">
          Nie jesteś zalogowany. Użyj karty z dostępem do rekordów ochrony.
          <ChoiceButton choice="Log In" icon="lock-open">
            Zaloguj
          </ChoiceButton>
        </NoticeBox>
      </Stack.Item>
    </Stack>
  </Stack.Item>
);

const AuthView = () => {
  const { data } = useBackend<Data>();
  const { authenticated, rank, screen, temp } = data;

  let content: ReactNode;
  if (temp) {
    content = <TempScreen temp={temp} />;
  } else if (screen === 2) {
    content = <Maintenance />;
  } else if (screen === 3) {
    content = <RecordView />;
  } else {
    content = (
      <Section fill>
        <NoticeBox>Nie wybrano rekordu.</NoticeBox>
      </Section>
    );
  }

  return (
    <>
      <Stack.Item width="32%">
        <RecordTabs />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item grow>{content}</Stack.Item>
          <Stack.Item>
            <NoticeBox align="right" info>
              {authenticated} ({rank}). Zabezpiecz stanowisko.
              <ChoiceButton choice="Log Out" icon="lock" color="good">
                Wyloguj
              </ChoiceButton>
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};

/** Lista rekordów po lewej, z wyszukiwarką */
const RecordTabs = () => {
  const topic = useTopic();
  const { data } = useBackend<Data>();
  const { records = [], active_ref } = data;
  const [search, setSearch] = useState('');
  const query = search.toLowerCase();

  const shown = sortBy(
    records.filter((record) =>
      [record.name, record.id, record.rank, record.fingerprint]
        .join(' ')
        .toLowerCase()
        .includes(query),
    ),
    [(record) => record.name],
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          fluid
          placeholder="Nazwisko/stanowisko/ID/odciski"
          value={search}
          onChange={setSearch}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Tabs vertical>
            {!shown.length ? (
              <NoticeBox>
                {!records.length
                  ? 'Brak rekordów.'
                  : 'Brak wyników. Zawęź wyszukiwanie.'}
              </NoticeBox>
            ) : (
              shown.map((record) => {
                const isSelected = record.ref === active_ref;
                return (
                  <Tabs.Tab
                    key={record.ref}
                    className="candystripe"
                    selected={isSelected}
                    onClick={() =>
                      isSelected
                        ? topic({ choice: 'Return' })
                        : topic({ choice: 'Browse Record', d_rec: record.ref })
                    }
                  >
                    <Box
                      bold={isSelected}
                      color={STATUS_COLORS[record.criminal] || 'label'}
                    >
                      {record.name}
                    </Box>
                    <Box fontSize="0.9em" color="label">
                      {record.rank}
                    </Box>
                  </Tabs.Tab>
                );
              })
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item align="center">
        <ChoiceButton choice="New Record (General)" icon="plus">
          Nowy rekord
        </ChoiceButton>
        <ChoiceButton choice="Record Maintenance" icon="tools">
          Konserwacja
        </ChoiceButton>
      </Stack.Item>
    </Stack>
  );
};

/** Podmenu z DM (potwierdzenia, wybór stanowiska itp.) */
const TempScreen = (props: { temp: Temp }) => {
  const topic = useTopic();
  const { temp } = props;
  return (
    <Section
      fill
      scrollable
      title="Wybierz"
      buttons={
        <ChoiceButton choice="Clear Screen" icon="times">
          Zamknij
        </ChoiceButton>
      }
    >
      <Box dangerouslySetInnerHTML={{ __html: temp.text }} />
      <Stack wrap mt={1}>
        {temp.buttons.map((button, index) => (
          <Stack.Item key={index}>
            <Button onClick={() => topic(button.params)}>
              {STATUS_NAMES[button.label] || button.label}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const Maintenance = () => (
  <Section fill title="Konserwacja rekordów">
    <ChoiceButton choice="Delete All Records" icon="trash" color="bad">
      Usuń wszystkie rekordy ochrony
    </ChoiceButton>
  </Section>
);

const Photo = (props: { src: string | null; side: boolean }) => {
  const { src, side } = props;
  const suffix = side ? 'side' : 'front';
  return (
    <Stack vertical align="center">
      <Stack.Item>
        {src ? (
          <img
            src={`data:image/png;base64,${src}`}
            width="96px"
            height="96px"
            style={{ imageRendering: 'pixelated', border: '2px solid #444' }}
          />
        ) : (
          <Box width="96px" height="96px" color="label" textAlign="center">
            brak zdjęcia
          </Box>
        )}
      </Stack.Item>
      <Stack.Item>
        <EditField
          field={`upd_photo_${suffix}`}
          icon="camera"
          tooltip="Zmień"
        />
        <EditField
          field={`print_photo_${suffix}`}
          icon="print"
          tooltip="Drukuj"
        />
      </Stack.Item>
    </Stack>
  );
};

const RecordView = () => {
  const { data } = useBackend<Data>();
  const { general, security, printing } = data;

  if (!general) {
    return (
      <Section fill>
        <NoticeBox danger>Rekord ogólny utracony.</NoticeBox>
      </Section>
    );
  }

  const status = security?.criminal || 'None';

  return (
    <Section
      fill
      scrollable
      title={
        <Box as="span" color={security ? STATUS_COLORS[status] : undefined}>
          {general.name}
        </Box>
      }
      buttons={
        <>
          <ChoiceButton
            choice="Print Record"
            icon="print"
            disabled={printing}
            tooltip="Drukuj rekord"
          />
          <ChoiceButton
            choice="Print Poster"
            icon="exclamation-triangle"
            disabled={printing}
            tooltip="Drukuj list gończy"
          />
          <ChoiceButton
            choice="Print Missing"
            icon="question"
            disabled={printing}
            tooltip="Drukuj plakat o zaginięciu"
          />
          <ChoiceButton
            choice="Delete Record (Security)"
            icon="eraser"
            tooltip="Usuń tylko dane ochrony"
          />
          <ChoiceButton
            choice="Delete Record (ALL)"
            icon="trash"
            color="bad"
            tooltip="Usuń cały rekord"
          />
        </>
      }
    >
      {security && (
        <LabeledList>
          <LabeledList.Item label="Status">
            <Box color={STATUS_COLORS[status]} bold mb={0.5}>
              {STATUS_NAMES[status] || status}
            </Box>
            <StatusButtons current={status} />
          </LabeledList.Item>
        </LabeledList>
      )}
      <Stack mt={1}>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label="Nazwisko"
              buttons={<EditField field="name" />}
            >
              {general.name}
            </LabeledList.Item>
            <LabeledList.Item label="ID" buttons={<EditField field="id" />}>
              {general.id}
            </LabeledList.Item>
            <LabeledList.Item
              label="Stanowisko"
              buttons={<EditField field="rank" />}
            >
              {general.rank}
            </LabeledList.Item>
            <LabeledList.Item label="Wiek" buttons={<EditField field="age" />}>
              {general.age}
            </LabeledList.Item>
            <LabeledList.Item
              label="Gatunek"
              buttons={<EditField field="species" />}
            >
              {general.species}
            </LabeledList.Item>
            <LabeledList.Item
              label="Płeć"
              buttons={<EditField field="gender" icon="sync" />}
            >
              {general.gender}
            </LabeledList.Item>
            <LabeledList.Item
              label="Odciski"
              color="good"
              buttons={<EditField field="fingerprint" />}
            >
              {general.fingerprint}
            </LabeledList.Item>
            <LabeledList.Item label="Stan fizyczny">
              {general.physical}
            </LabeledList.Item>
            <LabeledList.Item label="Stan psychiczny">
              {general.mental}
            </LabeledList.Item>
            <LabeledList.Item label="Przeszłość">
              <ChoiceButton choice="View Past General" icon="book">
                Pokaż
              </ChoiceButton>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Photo src={general.photo_front} side={false} />
        </Stack.Item>
        <Stack.Item>
          <Photo src={general.photo_side} side />
        </Stack.Item>
      </Stack>
      {security ? (
        <SecurityData security={security} />
      ) : (
        <Section title="Dane ochrony">
          <NoticeBox>Rekord ochrony utracony.</NoticeBox>
          <ChoiceButton choice="New Record (Security)" icon="plus">
            Utwórz rekord ochrony
          </ChoiceButton>
        </Section>
      )}
    </Section>
  );
};

/** Przyciski statusu jak w tg (pierwsza litera, opis w podpowiedzi) */
const StatusButtons = (props: { current: string }) => {
  const topic = useTopic();
  const { current } = props;
  return (
    <>
      {STATUS_BUTTONS.map((button) => {
        const isSelected = button.status === current;
        return (
          <Button
            key={button.status}
            color={isSelected ? STATUS_COLORS[button.status] : 'grey'}
            icon={isSelected ? 'check' : undefined}
            tooltip={button.desc}
            tooltipPosition="bottom-start"
            onClick={() =>
              topic({
                choice: 'Change Criminal Status',
                criminal2: button.param,
              })
            }
          >
            {STATUS_NAMES[button.status]}
          </Button>
        );
      })}
    </>
  );
};

enum SECURETAB {
  Crimes,
  Citations,
  Comments,
}

const SecurityData = (props: { security: SecurityRecord }) => {
  const { security } = props;
  const [tab, setTab] = useState(SECURETAB.Crimes);
  return (
    <>
      <Section title="Dane ochrony">
        <LabeledList>
          <LabeledList.Item
            label="Ważne uwagi"
            buttons={<EditField field="notes" />}
          >
            {security.notes}
          </LabeledList.Item>
          <LabeledList.Item label="Przeszłość">
            <ChoiceButton choice="View Past Security" icon="book">
              Pokaż
            </ChoiceButton>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Tabs fluid>
        <Tabs.Tab
          selected={tab === SECURETAB.Crimes}
          onClick={() => setTab(SECURETAB.Crimes)}
        >
          Przestępstwa: {security.crimes.length}
        </Tabs.Tab>
        <Tabs.Tab
          selected={tab === SECURETAB.Citations}
          onClick={() => setTab(SECURETAB.Citations)}
        >
          Mandaty: {security.citations.length}
        </Tabs.Tab>
        <Tabs.Tab
          selected={tab === SECURETAB.Comments}
          onClick={() => setTab(SECURETAB.Comments)}
        >
          Komentarze: {security.comments.length}
        </Tabs.Tab>
      </Tabs>
      {tab === SECURETAB.Crimes && <CrimeList crimes={security.crimes} />}
      {tab === SECURETAB.Citations && (
        <CitationList citations={security.citations} />
      )}
      {tab === SECURETAB.Comments && (
        <CommentList comments={security.comments} />
      )}
    </>
  );
};

const CrimeList = (props: { crimes: Crime[] }) => {
  const topic = useTopic();
  const { crimes } = props;
  return (
    <Section
      buttons={
        <EditField field="crim_add" icon="plus">
          Dodaj przestępstwo
        </EditField>
      }
    >
      {crimes.length === 0 ? (
        <NoticeBox>Brak przestępstw.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Przestępstwo</Table.Cell>
            <Table.Cell>Szczegóły</Table.Cell>
            <Table.Cell>Dodał</Table.Cell>
            <Table.Cell>Czas</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {crimes.map((crime) => (
            <Table.Row key={crime.id} className="candystripe">
              <Table.Cell>{crime.name}</Table.Cell>
              <Table.Cell>
                {crime.details || (
                  <Button
                    icon="plus"
                    onClick={() =>
                      topic({
                        choice: 'Edit Field',
                        field: 'add_details',
                        cdataid: crime.id,
                      })
                    }
                  >
                    Dodaj
                  </Button>
                )}
              </Table.Cell>
              <Table.Cell>{crime.author}</Table.Cell>
              <Table.Cell>{crime.time}</Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="times"
                  color="bad"
                  tooltip="Usuń"
                  onClick={() =>
                    topic({
                      choice: 'Edit Field',
                      field: 'crim_delete',
                      cdataid: crime.id,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const CitationList = (props: { citations: Citation[] }) => {
  const topic = useTopic();
  const { citations } = props;
  return (
    <Section
      buttons={
        <EditField field="citation_add" icon="plus">
          Wystaw mandat
        </EditField>
      }
    >
      {citations.length === 0 ? (
        <NoticeBox>Brak mandatów.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Wykroczenie</Table.Cell>
            <Table.Cell>Kwota</Table.Cell>
            <Table.Cell>Wystawił</Table.Cell>
            <Table.Cell>Czas</Table.Cell>
            <Table.Cell>Do zapłaty</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {citations.map((citation) => (
            <Table.Row key={citation.id} className="candystripe">
              <Table.Cell>{citation.name}</Table.Cell>
              <Table.Cell>{citation.fine} cr</Table.Cell>
              <Table.Cell>{citation.author}</Table.Cell>
              <Table.Cell>{citation.time}</Table.Cell>
              <Table.Cell>
                {citation.owed > 0 ? (
                  <Button
                    icon="money-bill"
                    color="average"
                    tooltip="Zapłać holoczipem trzymanym w ręce"
                    onClick={() =>
                      topic({
                        choice: 'Pay',
                        field: 'citation_pay',
                        cdataid: citation.id,
                      })
                    }
                  >
                    {citation.owed} cr
                  </Button>
                ) : (
                  <Box color="good">Spłacony</Box>
                )}
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="times"
                  color="bad"
                  tooltip="Usuń"
                  onClick={() =>
                    topic({
                      choice: 'Edit Field',
                      field: 'citation_delete',
                      cdataid: citation.id,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const CommentList = (props: { comments: Comment[] }) => {
  const { comments } = props;
  return (
    <Section
      buttons={
        <ChoiceButton choice="Add Entry" icon="plus">
          Dodaj komentarz
        </ChoiceButton>
      }
    >
      {comments.length === 0 && <NoticeBox>Brak komentarzy.</NoticeBox>}
      {comments.map((comment) => (
        <Section
          key={comment.index}
          buttons={
            !comment.deleted && (
              <ChoiceButton
                choice="Delete Entry"
                extra={{ del_c: comment.index }}
                icon="times"
                color="bad"
                tooltip="Usuń"
              />
            )
          }
        >
          <Box dangerouslySetInnerHTML={{ __html: comment.text }} />
        </Section>
      ))}
    </Section>
  );
};
