import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Antag = {
  name: string;
  status: string;
  bad: boolean;
  mob_ref: string | null;
  mind_ref: string | null;
  ckey: string | null;
};

type ExtraRow = {
  text: string;
  pp_ref?: string | null;
  follow_ref?: string | null;
  vv_ref?: string | null;
  ckey?: string | null;
};

type AntagSection = {
  title: string;
  antags: Antag[];
  extra: { title: string; rows: ExtraRow[] }[];
};

type Stats = {
  ingame: number;
  connected: number;
  lobby: number;
  living_active: number;
  living_disconnected: number;
  living_antags: number;
  skipped_living: number;
  skipped_drones: number;
  dead_active: number;
  dead_disconnected: number;
  brains: number;
  other: number;
};

type Data = {
  round_started: boolean;
  mode_name: string;
  replacement_mode_name: string | null;
  round_duration: string;
  shuttle: {
    idle_or_recalled: boolean;
    eta?: string;
    called?: boolean;
  };
  continuous: boolean;
  midround_antag: boolean;
  midround_time_limit: number;
  midround_life_limit: number;
  round_ends_with_antag_death: boolean;
  delay_end: boolean;
  stats: Stats;
  sections: AntagSection[];
};

const AntagRow = (props: { antag: Antag }) => {
  const { act } = useBackend<Data>();
  const { antag } = props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell py={0.25}>
        {antag.mob_ref ? (
          <Button
            color="transparent"
            onClick={() => act('pp', { ref: antag.mob_ref })}
          >
            {antag.name}
          </Button>
        ) : (
          <Button
            color="transparent"
            onClick={() => act('vv', { ref: antag.mind_ref })}
          >
            {antag.name}
          </Button>
        )}
      </Table.Cell>
      <Table.Cell collapsing color={antag.bad ? 'bad' : 'label'}>
        {antag.status}
      </Table.Cell>
      <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
        {!!antag.ckey && (
          <Button onClick={() => act('pm', { ckey: antag.ckey })}>PM</Button>
        )}
        {!!antag.mob_ref && (
          <Button onClick={() => act('flw', { ref: antag.mob_ref })}>
            FLW
          </Button>
        )}
        {!!antag.mind_ref && (
          <Button onClick={() => act('tp', { ref: antag.mind_ref })}>
            Pokaż cele
          </Button>
        )}
      </Table.Cell>
    </Table.Row>
  );
};

const ExtraTable = (props: { title: string; rows: ExtraRow[] }) => {
  const { act } = useBackend<Data>();
  const { title, rows } = props;
  return (
    <Box mt={1}>
      <Box bold mb={0.5}>
        {title}
      </Box>
      {rows.length === 0 && (
        <Box color="label" italic>
          Brak.
        </Box>
      )}
      <Table>
        {rows.map((row, i) => (
          <Table.Row key={i} className="candystripe">
            <Table.Cell py={0.25}>{row.text}</Table.Cell>
            <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
              {!!row.pp_ref && (
                <Button onClick={() => act('pp', { ref: row.pp_ref })}>
                  PP
                </Button>
              )}
              {!!row.vv_ref && (
                <Button onClick={() => act('vv', { ref: row.vv_ref })}>
                  VV
                </Button>
              )}
              {!!row.ckey && (
                <Button onClick={() => act('pm', { ckey: row.ckey })}>
                  PM
                </Button>
              )}
              {!!row.follow_ref && (
                <Button onClick={() => act('flw', { ref: row.follow_ref })}>
                  FLW
                </Button>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
};

const RoundStatus = (props) => {
  const { act, data } = useBackend<Data>();
  const { shuttle, stats } = data;
  return (
    <Section
      title="Stan rundy"
      buttons={
        <Button icon="users" onClick={() => act('check_teams')}>
          Drużyny
        </Button>
      }
    >
      <LabeledList>
        {data.replacement_mode_name ? (
          <>
            <LabeledList.Item label="Poprzedni tryb">
              {data.mode_name}
            </LabeledList.Item>
            <LabeledList.Item label="Tryb zastępczy">
              {data.replacement_mode_name}
            </LabeledList.Item>
          </>
        ) : (
          <LabeledList.Item label="Tryb gry">{data.mode_name}</LabeledList.Item>
        )}
        <LabeledList.Item label="Czas rundy">
          {data.round_duration}
        </LabeledList.Item>
        <LabeledList.Item label="Prom ewakuacyjny">
          {shuttle.idle_or_recalled ? (
            <Button icon="shuttle-space" onClick={() => act('call_shuttle')}>
              Wezwij prom
            </Button>
          ) : (
            <>
              <Button
                tooltip="Zmień czas"
                onClick={() => act('edit_shuttle_time')}
              >
                ETA: {shuttle.eta}
              </Button>
              {!!shuttle.called && (
                <Button
                  color="average"
                  onClick={() => act('call_shuttle', { send_back: true })}
                >
                  Odwołaj
                </Button>
              )}
            </>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Ciągłość rundy">
          <Button onClick={() => act('toggle_continuous')}>
            {data.continuous
              ? 'Trwa dalej po śmierci antagonistów'
              : 'Kończy się po śmierci antagonistów'}
          </Button>
          {!!data.continuous && (
            <Button onClick={() => act('toggle_midround_antag')}>
              {data.midround_antag
                ? 'Tworzy zastępczych antagonistów'
                : 'Nie tworzy nowych antagonistów'}
            </Button>
          )}
        </LabeledList.Item>
        {!!data.midround_antag && (
          <>
            <LabeledList.Item label="Limit czasu">
              <Button onClick={() => act('alter_midround_time_limit')}>
                {data.midround_time_limit} min od startu rundy
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Limit żywej załogi">
              <Button onClick={() => act('alter_midround_life_limit')}>
                {data.midround_life_limit}% załogi przy życiu
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Po przekroczeniu limitów">
              <Button onClick={() => act('toggle_noncontinuous_behavior')}>
                {data.round_ends_with_antag_death
                  ? 'Zakończ rundę'
                  : 'Kontynuuj jako extended'}
              </Button>
            </LabeledList.Item>
          </>
        )}
        <LabeledList.Item label="Koniec rundy">
          <Button
            color="bad"
            icon="flag-checkered"
            onClick={() => act('end_round')}
          >
            Zakończ rundę teraz
          </Button>
          <Button onClick={() => act('delay_round_end')}>
            {data.delay_end
              ? 'Zakończ rundę normalnie'
              : 'Opóźnij koniec rundy'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1}>
        <Box bold color="blue">
          Gracze: {stats.ingame} w grze | {stats.connected} połączonych |{' '}
          {stats.lobby} w lobby
        </Box>
        <Box bold color="good">
          Żywi: {stats.living_active} aktywnych | {stats.living_disconnected}{' '}
          rozłączonych | {stats.living_antags} antagonistów
        </Box>
        <Box bold color="purple">
          Pominięci (poziom CentComu): {stats.skipped_living} żywych |{' '}
          {stats.skipped_drones} żywych dronów
        </Box>
        <Box bold color="bad">
          Martwi/obserwatorzy: {stats.dead_active} aktywnych |{' '}
          {stats.dead_disconnected} rozłączonych | {stats.brains} mózgów
        </Box>
        {stats.other > 0 && (
          <NoticeBox danger mt={1}>
            {stats.other} graczy w nieprawidłowym stanie albo statystyki są
            zepsute!
          </NoticeBox>
        )}
      </Box>
    </Section>
  );
};

export const CheckAntagonists = (props) => {
  const { data } = useBackend<Data>();
  const { sections = [] } = data;

  return (
    <Window title="Stan rundy" theme="admin" width={620} height={700}>
      <Window.Content scrollable>
        {!data.round_started ? (
          <NoticeBox>Gra jeszcze się nie zaczęła.</NoticeBox>
        ) : (
          <>
            <RoundStatus />
            {sections.length === 0 && (
              <NoticeBox>W tej rundzie nie ma antagonistów.</NoticeBox>
            )}
            {sections.map((section, i) => (
              <Section key={i} title={section.title}>
                {section.antags.length > 0 && (
                  <Table>
                    {section.antags.map((antag, j) => (
                      <AntagRow key={j} antag={antag} />
                    ))}
                  </Table>
                )}
                {section.extra.map((extra, j) => (
                  <ExtraTable key={j} title={extra.title} rows={extra.rows} />
                ))}
              </Section>
            ))}
          </>
        )}
      </Window.Content>
    </Window>
  );
};
