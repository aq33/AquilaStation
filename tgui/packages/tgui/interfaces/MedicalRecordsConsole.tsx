// AQUILA - konsola akt medycznych (aquila/code/game/machinery/computer/medical_records_ui.dm)
// Układ z tg (MedicalRecords: lista po lewej, akta po prawej, przyciski stanów z ikonami),
// dane i akcje nasze przez dawny Topic(); baza wirusów i roboty medyczne zostają jako osobne zakładki.
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

type TopicLink = {
  params: Record<string, string>;
  label: string;
};

type Temp = {
  text: string;
  buttons: TopicLink[];
};

type RecordRow = {
  name: string;
  id: string;
  rank: string;
  fingerprint: string;
  dna: string;
  blood_type: string;
  physical: string;
  mental: string;
};

type General = {
  name: string;
  id: string;
  rank: string;
  gender: string;
  sex: string;
  age: string | number;
  species: string;
  fingerprint: string;
  physical: string;
  mental: string;
  cause_of_death: string | null;
  photo_front: string | null;
  photo_side: string | null;
};

type Comment = {
  index: number;
  text: string;
  deleted: BooleanLike;
};

type MedicalRecord = {
  blood_type: string;
  dna: string;
  mi_dis: string;
  mi_dis_d: string;
  ma_dis: string;
  ma_dis_d: string;
  alg: string;
  alg_d: string;
  cdi: string;
  cdi_d: string;
  notes: string;
  comments: Comment[];
};

type Virus = {
  name: string;
  stages: number;
  spread: string;
  cure: string;
  desc: string;
  danger: string;
  agent: string;
};

type Medbot = {
  name: string;
  x: number;
  y: number;
  area: string;
  on: BooleanLike;
};

type Data = {
  authenticated: string | null;
  rank: string | null;
  screen: number | null;
  printing: BooleanLike;
  temp: Temp | null;
  records?: RecordRow[];
  general?: General | null;
  medical?: MedicalRecord | null;
  viruses: Virus[];
  medbots?: Medbot[];
};

type StatusOption = {
  value: string;
  param: string;
  name: string;
  icon: string;
  color: string;
  desc: string;
};

/** Statusy zostają w aktach po angielsku (czytają je HUD-y i inne konsole), tu tylko je tłumaczymy */
const PHYSICAL_STATUSES: StatusOption[] = [
  {
    value: 'Active',
    param: 'active',
    name: 'Aktywny',
    icon: 'person-running',
    color: 'green',
    desc: 'Aktywny. Przytomny i zdrowy.',
  },
  {
    value: 'Physically Unfit',
    param: 'unfit',
    name: 'Niezdolny fizycznie',
    icon: 'crutch',
    color: 'purple',
    desc: 'Niezdolny fizycznie. Przytomny, ale nie w pełni zdrowy.',
  },
  {
    value: '*Unconscious*',
    param: 'unconscious',
    name: 'Nieprzytomny',
    icon: 'moon',
    color: 'orange',
    desc: 'Nieprzytomny. Może potrzebować pomocy medycznej.',
  },
  {
    value: '*Deceased*',
    param: 'deceased',
    name: 'Zmarły',
    icon: 'skull',
    color: 'red',
    desc: 'Zmarły. Zgon stwierdzony, ciało ulega rozkładowi.',
  },
];

const MENTAL_STATUSES: StatusOption[] = [
  {
    value: 'Stable',
    param: 'stable',
    name: 'Stabilny',
    icon: 'face-smile',
    color: 'green',
    desc: 'Stabilny. Zdrowy psychicznie, bez zaburzeń.',
  },
  {
    value: '*Watch*',
    param: 'watch',
    name: 'Obserwacja',
    icon: 'eye',
    color: 'purple',
    desc: 'Obserwacja. Objawy choroby psychicznej, pilnuj tej osoby.',
  },
  {
    value: '*Unstable*',
    param: 'unstable',
    name: 'Niestabilny',
    icon: 'scale-unbalanced-flip',
    color: 'orange',
    desc: 'Niestabilny. Co najmniej jedna choroba psychiczna.',
  },
  {
    value: '*Insane*',
    param: 'insane',
    name: 'Niepoczytalny',
    icon: 'head-side-virus',
    color: 'red',
    desc: 'Niepoczytalny. Poważne, nienormalne zachowania.',
  },
];

const ALL_STATUSES = [...PHYSICAL_STATUSES, ...MENTAL_STATUSES];
const findStatus = (value: string) =>
  ALL_STATUSES.find((status) => status.value === value);

/** Domyślne wpisy nowych akt (code/datums/datacore.dm) */
const DEFAULT_TEXTS = {
  None: 'Brak',
  Unknown: 'Nieznane',
  'No minor disabilities have been declared.':
    'Nie zgłoszono drobnych niepełnosprawności.',
  'No minor disabilities have been diagnosed.':
    'Nie zdiagnozowano drobnych niepełnosprawności.',
  'No major disabilities have been diagnosed.':
    'Nie zdiagnozowano poważnych niepełnosprawności.',
  'No allergies have been detected in this patient.':
    'Nie wykryto u pacjenta alergii.',
  'No diseases have been diagnosed at the moment.':
    'Obecnie nie zdiagnozowano chorób.',
  'No notes.': 'Brak uwag.',
  Male: 'Mężczyzna',
  Female: 'Kobieta',
  Plural: 'Inna',
  Other: 'Inna',
};

const DANGER_NAMES = {
  Beneficial: 'Korzystna',
  Positive: 'Pozytywna',
  Harmless: 'Nieszkodliwa',
  Minor: 'Niewielkie',
  Medium: 'Średnie',
  Harmful: 'Szkodliwa',
  Dangerous: 'Niebezpieczna',
  BIOHAZARD: 'ZAGROŻENIE BIOLOGICZNE',
  PANDEMIC: 'PANDEMIA',
};

const DANGER_COLORS = {
  Beneficial: 'good',
  Positive: 'good',
  Harmless: 'label',
  Minor: 'olive',
  Medium: 'average',
  Harmful: 'orange',
  Dangerous: 'bad',
  BIOHAZARD: 'bad',
  PANDEMIC: 'bad',
};

const SPREAD_NAMES = {
  Airborne: 'Drogą powietrzną',
  Blood: 'Przez krew',
  Contact: 'Przez kontakt',
  Fluids: 'Przez płyny ustrojowe',
  'Intentional Injection': 'Celowy zastrzyk',
  None: 'Brak',
  Paranormal: 'Paranormalnie',
  Unknown: 'Nieznana',
  Acute: 'Ostra',
};

const translate = (text: string | null | undefined) =>
  (text && (findStatus(text)?.name || DEFAULT_TEXTS[text])) || text;

const useTopic = () => {
  const { act } = useBackend<Data>();
  return (params: Record<string, string | number>) => act('topic', params);
};

const TopicButton = (props: {
  params: Record<string, string | number>;
  icon?: string;
  color?: string;
  disabled?: BooleanLike;
  tooltip?: string;
  fluid?: boolean;
  children?: ReactNode;
}) => {
  const topic = useTopic();
  return (
    <Button
      icon={props.icon}
      color={props.color}
      disabled={props.disabled}
      tooltip={props.tooltip}
      fluid={props.fluid}
      onClick={() => topic(props.params)}
    >
      {props.children}
    </Button>
  );
};

const EditField = (props: { field: string; icon?: string }) => (
  <TopicButton
    params={{ field: props.field }}
    icon={props.icon || 'pen'}
    tooltip="Zmień"
  />
);

export const MedicalRecordsConsole = (_) => {
  const { data } = useBackend<Data>();
  const { authenticated } = data;
  return (
    <Window title="Akta medyczne" width={860} height={640}>
      <Window.Content>
        {!authenticated ? <RestrictedView /> : <AuthView />}
      </Window.Content>
    </Window>
  );
};

/** Ekran przed zalogowaniem */
const RestrictedView = () => (
  <Stack fill vertical>
    <Stack.Item grow />
    <Stack.Item align="center" grow={2}>
      <Icon color="teal" name="staff-snake" size={15} />
    </Stack.Item>
    <Stack.Item align="center" grow>
      <Box color="teal" fontSize="18px" bold mt={5}>
        Nanotrasen HealthPRO
      </Box>
    </Stack.Item>
    <Stack.Item>
      <NoticeBox align="right">
        Nie jesteś zalogowany. Użyj karty z dostępem medycznym albo
        kryminalistycznym.
        <TopicButton params={{ login: 1 }} icon="lock-open">
          Zaloguj
        </TopicButton>
      </NoticeBox>
    </Stack.Item>
  </Stack>
);

const AuthView = () => {
  const { data } = useBackend<Data>();
  const { authenticated, rank, screen, temp } = data;

  let content: ReactNode;
  if (temp) {
    content = <TempScreen temp={temp} />;
  } else if (screen === 3) {
    content = <Maintenance />;
  } else if (screen === 5) {
    content = <VirusDatabase />;
  } else if (screen === 6) {
    content = <MedbotTracking />;
  } else {
    content = (
      <Stack fill>
        <Stack.Item width="32%">
          <RecordTabs />
        </Stack.Item>
        <Stack.Item grow>
          {screen === 4 ? (
            <RecordView />
          ) : (
            <Section fill>
              <NoticeBox>Nie wybrano akt.</NoticeBox>
            </Section>
          )}
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <MenuTabs />
      </Stack.Item>
      <Stack.Item grow>{content}</Stack.Item>
      <Stack.Item>
        <NoticeBox align="right" info>
          {authenticated} ({rank}). Zabezpiecz stanowisko.
          <TopicButton params={{ logout: 1 }} icon="lock" color="good">
            Wyloguj
          </TopicButton>
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

const MenuTabs = () => {
  const topic = useTopic();
  const { data } = useBackend<Data>();
  const { screen } = data;
  const tab = screen === 1 || screen === 4 ? 2 : screen;
  return (
    <Tabs>
      <Tabs.Tab
        icon="notes-medical"
        selected={tab === 2}
        onClick={() => topic({ screen: 2 })}
      >
        Akta
      </Tabs.Tab>
      <Tabs.Tab
        icon="virus"
        selected={tab === 5}
        onClick={() => topic({ screen: 5 })}
      >
        Baza wirusów
      </Tabs.Tab>
      <Tabs.Tab
        icon="robot"
        selected={tab === 6}
        onClick={() => topic({ screen: 6 })}
      >
        Roboty medyczne
      </Tabs.Tab>
      <Tabs.Tab
        icon="tools"
        selected={tab === 3}
        onClick={() => topic({ screen: 3 })}
      >
        Konserwacja
      </Tabs.Tab>
    </Tabs>
  );
};

/** Podmenu z DM (potwierdzenia, grupy krwi itp.) */
const TempScreen = (props: { temp: Temp }) => {
  const topic = useTopic();
  const { temp } = props;
  return (
    <Section
      fill
      scrollable
      title="Wybierz"
      buttons={
        <TopicButton params={{ temp: 1 }} icon="times">
          Zamknij
        </TopicButton>
      }
    >
      <Box dangerouslySetInnerHTML={{ __html: temp.text }} />
      <Stack wrap mt={1}>
        {temp.buttons.map((button, index) => (
          <Stack.Item key={index}>
            <Button onClick={() => topic(button.params)}>{button.label}</Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

/** Lista akt po lewej, z wyszukiwarką */
const RecordTabs = () => {
  const topic = useTopic();
  const { data } = useBackend<Data>();
  const { records = [], general, screen } = data;
  const [search, setSearch] = useState('');
  const query = search.toLowerCase();

  const shown = sortBy(
    records.filter((record) =>
      [record.name, record.id, record.rank, record.fingerprint, record.dna]
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
          placeholder="Nazwisko/stanowisko/odciski/DNA"
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
                  ? 'Brak akt.'
                  : 'Brak wyników. Zawęź wyszukiwanie.'}
              </NoticeBox>
            ) : (
              shown.map((record) => {
                const isSelected =
                  screen === 4 &&
                  general?.id === record.id &&
                  general?.name === record.name;
                const physical = findStatus(record.physical);
                return (
                  <Tabs.Tab
                    key={`${record.name}|${record.id}`}
                    className="candystripe"
                    selected={isSelected}
                    onClick={() =>
                      isSelected
                        ? topic({ screen: 2 })
                        : topic({ d_rec: record.id })
                    }
                  >
                    <Box bold={isSelected} color={physical?.color}>
                      <Icon name={physical?.icon || 'question'} /> {record.name}
                    </Box>
                    <Box fontSize="0.9em" color="label">
                      {record.rank}
                      {!!record.blood_type && (
                        <Box as="span" color="red" ml={1}>
                          {record.blood_type}
                        </Box>
                      )}
                    </Box>
                  </Tabs.Tab>
                );
              })
            )}
          </Tabs>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const Maintenance = () => (
  <Section fill title="Konserwacja akt">
    <NoticeBox>
      Usunięcie akt medycznych zostawia dane ogólne. Tego nie da się cofnąć.
    </NoticeBox>
    <TopicButton params={{ del_all: 1 }} icon="trash" color="bad">
      Usuń wszystkie akta medyczne
    </TopicButton>
  </Section>
);

const Photo = (props: { src: string | null; side: boolean }) => {
  const { src, side } = props;
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
        <TopicButton
          params={{ field: side ? 'show_photo_side' : 'show_photo_front' }}
          icon="search-plus"
          disabled={!src}
        >
          {side ? 'Profil' : 'Przód'}
        </TopicButton>
      </Stack.Item>
    </Stack>
  );
};

/** Przyciski stanu jak w tg: ikony, opis w podpowiedzi */
const StatusButtons = (props: {
  options: StatusOption[];
  current: string;
  param: 'p_stat' | 'm_stat';
}) => {
  const topic = useTopic();
  const { options, current, param } = props;
  return (
    <>
      {options.map((option) => {
        const isSelected = option.value === current;
        return (
          <Button
            key={option.value}
            color={isSelected ? option.color : 'transparent'}
            icon={option.icon}
            tooltip={option.desc}
            tooltipPosition="bottom-start"
            onClick={() => topic({ [param]: option.param })}
          />
        );
      })}
    </>
  );
};

const RecordView = () => {
  const { data } = useBackend<Data>();
  const { general, medical, printing } = data;

  if (!general) {
    return (
      <Section fill>
        <NoticeBox danger>Utracono akta ogólne!</NoticeBox>
      </Section>
    );
  }

  const physical = findStatus(general.physical);
  const mental = findStatus(general.mental);

  return (
    <Section
      fill
      scrollable
      title={general.name}
      buttons={
        <TopicButton params={{ print_p: 1 }} icon="print" disabled={printing}>
          {printing ? 'Drukowanie...' : 'Drukuj'}
        </TopicButton>
      }
    >
      <Stack>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="ID">{general.id}</LabeledList.Item>
            <LabeledList.Item label="Stanowisko">
              {general.rank}
            </LabeledList.Item>
            <LabeledList.Item
              label="Płeć"
              buttons={<EditField field="gender" icon="sync" />}
            >
              {translate(general.gender)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Płeć biologiczna"
              buttons={<EditField field="sex" icon="sync" />}
            >
              {translate(general.sex)}
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
              label="Odcisk palca"
              color="good"
              buttons={<EditField field="fingerprint" />}
            >
              {general.fingerprint}
            </LabeledList.Item>
            <LabeledList.Item
              label="Stan fizyczny"
              buttons={
                <StatusButtons
                  options={PHYSICAL_STATUSES}
                  current={general.physical}
                  param="p_stat"
                />
              }
            >
              <Box bold color={physical?.color}>
                {translate(general.physical)}
              </Box>
            </LabeledList.Item>
            {general.physical === '*Deceased*' && (
              <LabeledList.Item
                label="Przyczyna zgonu"
                buttons={<EditField field="cause_of_death" />}
              >
                {general.cause_of_death || <Box color="label">nieustalona</Box>}
              </LabeledList.Item>
            )}
            <LabeledList.Item
              label="Stan psychiczny"
              buttons={
                <StatusButtons
                  options={MENTAL_STATUSES}
                  current={general.mental}
                  param="m_stat"
                />
              }
            >
              <Box bold color={mental?.color}>
                {translate(general.mental)}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Akta ogólne">
              <TopicButton params={{ choice: 'View Past General' }} icon="book">
                Pokaż
              </TopicButton>
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
      {medical ? (
        <MedicalData medical={medical} />
      ) : (
        <Section title="Dane medyczne">
          <NoticeBox>Utracono akta medyczne!</NoticeBox>
          <TopicButton params={{ new: 1 }} icon="plus">
            Utwórz akta medyczne
          </TopicButton>
        </Section>
      )}
    </Section>
  );
};

const ConditionItem = (props: {
  label: string;
  field: string;
  value: string;
  details: string;
}) => (
  <>
    <LabeledList.Item
      label={props.label}
      buttons={<EditField field={props.field} />}
    >
      <Box bold>{translate(props.value)}</Box>
    </LabeledList.Item>
    <LabeledList.Item
      label="Szczegóły"
      buttons={<EditField field={`${props.field}_d`} />}
    >
      <Box color="label">{translate(props.details)}</Box>
    </LabeledList.Item>
    <LabeledList.Divider />
  </>
);

enum MEDTAB {
  Data,
  Comments,
}

const MedicalData = (props: { medical: MedicalRecord }) => {
  const { medical } = props;
  const [tab, setTab] = useState(MEDTAB.Data);
  return (
    <>
      <Tabs fluid mt={1}>
        <Tabs.Tab
          icon="file-medical"
          selected={tab === MEDTAB.Data}
          onClick={() => setTab(MEDTAB.Data)}
        >
          Dane medyczne
        </Tabs.Tab>
        <Tabs.Tab
          icon="comment-medical"
          selected={tab === MEDTAB.Comments}
          onClick={() => setTab(MEDTAB.Comments)}
        >
          Komentarze i log: {medical.comments.length}
        </Tabs.Tab>
      </Tabs>
      {tab === MEDTAB.Data && (
        <Section
          buttons={
            <>
              <TopicButton params={{ choice: 'View Past Medical' }} icon="book">
                Historia choroby
              </TopicButton>
              <TopicButton params={{ del_r: 1 }} icon="trash" color="bad">
                Usuń akta medyczne
              </TopicButton>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Grupa krwi"
              buttons={<EditField field="blood_type" icon="list" />}
            >
              <Box bold color="red">
                {translate(medical.blood_type)}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="DNA" buttons={<EditField field="b_dna" />}>
              {translate(medical.dna)}
            </LabeledList.Item>
            <LabeledList.Divider />
            <ConditionItem
              label="Drobne niepełnosprawności"
              field="mi_dis"
              value={medical.mi_dis}
              details={medical.mi_dis_d}
            />
            <ConditionItem
              label="Poważne niepełnosprawności"
              field="ma_dis"
              value={medical.ma_dis}
              details={medical.ma_dis_d}
            />
            <ConditionItem
              label="Alergie"
              field="alg"
              value={medical.alg}
              details={medical.alg_d}
            />
            <ConditionItem
              label="Obecne choroby"
              field="cdi"
              value={medical.cdi}
              details={medical.cdi_d}
            />
            <LabeledList.Item
              label="Ważne uwagi"
              buttons={<EditField field="notes" />}
            >
              {translate(medical.notes)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      {tab === MEDTAB.Comments && (
        <Section
          buttons={
            <TopicButton params={{ add_c: 1 }} icon="plus">
              Dodaj wpis
            </TopicButton>
          }
        >
          {medical.comments.length === 0 && <NoticeBox>Brak wpisów.</NoticeBox>}
          {medical.comments.map((comment) =>
            comment.deleted ? (
              <Box key={comment.index} color="label" italic mb={1}>
                Wpis usunięty.
              </Box>
            ) : (
              <Section
                key={comment.index}
                buttons={
                  <TopicButton
                    params={{ del_c: comment.index }}
                    icon="times"
                    color="bad"
                    tooltip="Usuń wpis"
                  />
                }
              >
                <Box dangerouslySetInnerHTML={{ __html: comment.text }} />
              </Section>
            ),
          )}
        </Section>
      )}
    </>
  );
};

const VirusDatabase = () => {
  const { data } = useBackend<Data>();
  const viruses = sortBy(data.viruses || [], [(virus) => virus.name]);
  const [selected, setSelected] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const shown = viruses.filter((virus) =>
    virus.name.toLowerCase().includes(search.toLowerCase()),
  );
  const virus = viruses.find((entry) => entry.name === selected);
  return (
    <Stack fill>
      <Stack.Item width="32%">
        <Stack fill vertical>
          <Stack.Item>
            <Input
              fluid
              placeholder="Szukaj choroby..."
              value={search}
              onChange={setSearch}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <Tabs vertical>
                {shown.map((entry) => (
                  <Tabs.Tab
                    key={entry.name}
                    className="candystripe"
                    selected={entry.name === selected}
                    onClick={() => setSelected(entry.name)}
                  >
                    <Box inline color={DANGER_COLORS[entry.danger]}>
                      {entry.name}
                    </Box>
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={virus ? virus.name : 'Szczegóły'}>
          {!virus ? (
            <NoticeBox>Wybierz chorobę z listy.</NoticeBox>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Zagrożenie">
                <Box bold color={DANGER_COLORS[virus.danger]}>
                  {DANGER_NAMES[virus.danger] || virus.danger}
                </Box>
              </LabeledList.Item>
              {!!virus.agent && (
                <LabeledList.Item label="Czynnik">
                  {virus.agent}
                </LabeledList.Item>
              )}
              <LabeledList.Item label="Liczba stadiów">
                {virus.stages}
              </LabeledList.Item>
              <LabeledList.Item label="Przenoszenie">
                {SPREAD_NAMES[virus.spread] || virus.spread || 'nieznane'}
              </LabeledList.Item>
              <LabeledList.Item label="Możliwe leczenie">
                {virus.cure || 'brak'}
              </LabeledList.Item>
              <LabeledList.Item label="Opis">{virus.desc}</LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MedbotTracking = () => {
  const { data } = useBackend<Data>();
  const { medbots = [] } = data;
  return (
    <Section fill scrollable title="Roboty medyczne na tym pokładzie">
      {medbots.length === 0 ? (
        <NoticeBox>Nie wykryto robotów medycznych.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Nazwa</Table.Cell>
            <Table.Cell>Miejsce</Table.Cell>
            <Table.Cell>Współrzędne</Table.Cell>
            <Table.Cell>Stan</Table.Cell>
          </Table.Row>
          {medbots.map((medbot, index) => (
            <Table.Row key={index} className="candystripe">
              <Table.Cell>{medbot.name}</Table.Cell>
              <Table.Cell>{medbot.area}</Table.Cell>
              <Table.Cell>
                {medbot.x}, {medbot.y}
              </Table.Cell>
              <Table.Cell color={medbot.on ? 'good' : 'bad'}>
                {medbot.on ? 'Włączony' : 'Wyłączony'}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
