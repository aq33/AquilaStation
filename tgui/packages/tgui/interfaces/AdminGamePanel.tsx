import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Mode = {
  id: string;
  name: string;
};

type Rule = {
  name: string;
  ref: string;
};

type Data = {
  master_mode: string;
  secret_force_mode: string;
  round_started: boolean;
  round_in_progress: boolean;
  pregame: boolean;
  hotswap_disabled: boolean;
  modes: Mode[];
  is_dynamic: boolean;
  forced_roundstart?: Rule[];
  forced_latejoin?: string | null;
  forced_extended?: boolean;
  no_stacking?: boolean;
  stacking_limit?: number;
  forced_threat?: number;
  marked_atom: boolean;
};

// AQUILA - dodatkowe tryby spoza config.modes (weighted to tryb Aquili)
const EXTRA_MODES: Mode[] = [
  { id: 'secret', name: 'Secret' },
  { id: 'random', name: 'Random' },
  { id: 'weighted', name: 'Weighted' },
];

const DynamicSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { forced_roundstart = [] } = data;
  return (
    <Section title="Tryb dynamic">
      {!!data.pregame && (
        <>
          <Button icon="plus" onClick={() => act('f_dynamic_roundstart')}>
            Wymuś zestawy na start rundy
          </Button>
          {forced_roundstart.length > 0 && (
            <Box mt={1}>
              {forced_roundstart.map((rule) => (
                <Button
                  key={rule.ref}
                  icon="times"
                  color="average"
                  tooltip="Usuń z wymuszonych"
                  onClick={() => act('remove_roundstart', { ref: rule.ref })}
                >
                  {rule.name}
                </Button>
              ))}
              <Button
                icon="trash"
                color="bad"
                onClick={() => act('f_dynamic_roundstart_clear')}
              >
                Wyczyść
              </Button>
            </Box>
          )}
        </>
      )}
      {!data.pregame && !!data.round_in_progress && (
        <>
          <Button icon="user-plus" onClick={() => act('f_dynamic_latejoin')}>
            Wymuś zestaw dla następnego dołączającego
          </Button>
          {!!data.forced_latejoin && (
            <Button
              icon="times"
              color="average"
              tooltip="Usuń wymuszony zestaw"
              onClick={() => act('f_dynamic_latejoin_clear')}
            >
              {data.forced_latejoin}
            </Button>
          )}
          <Box mt={1}>
            <Button
              icon="bolt"
              color="bad"
              onClick={() => act('f_dynamic_midround')}
            >
              Uruchom zestaw w trakcie rundy!
            </Button>
          </Box>
        </>
      )}
      <Box mt={1} mb={1} color="label" italic>
        Te opcje można zmieniać także w trakcie rundy.
      </Box>
      <LabeledList>
        <LabeledList.Item label="Wymuś extended">
          <Button.Checkbox
            checked={!!data.forced_extended}
            onClick={() => act('f_dynamic_force_extended')}
          >
            {data.forced_extended ? 'Włączone' : 'Wyłączone'}
          </Button.Checkbox>
          <Box color="label">
            Runda będzie extended, żadne zestawy nie zostaną wylosowane.
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Bez łączenia">
          <Button.Checkbox
            checked={!!data.no_stacking}
            onClick={() => act('f_dynamic_no_stacking')}
          >
            {data.no_stacking ? 'Włączone' : 'Wyłączone'}
          </Button.Checkbox>
          <Box color="label">
            Dopóki zagrożenie nie przekroczy {data.stacking_limit}, wylosuje się
            tylko jeden zestaw kończący rundę.
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Wymuszone zagrożenie">
          <Button onClick={() => act('f_dynamic_forced_threat')}>
            {data.forced_threat}
          </Button>
          <Box color="label">
            Poziom zagrożenia, jeśli wartość jest większa niż -1. Tylko przed
            startem rundy.
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Próg łączenia">
          <Button onClick={() => act('f_dynamic_stacking_limit')}>
            {data.stacking_limit}
          </Button>
          <Box color="label">
            Zagrożenie, od którego zestawy kończące rundę mogą się łączyć.
            Wartość powyżej 100 oznacza, że nigdy się nie połączą.
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const AdminGamePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { modes = [] } = data;
  const allModes = [...modes, ...EXTRA_MODES];

  return (
    <Window title="Panel gry" theme="admin" width={560} height={640}>
      <Window.Content scrollable>
        <Section title="Tryb gry">
          <LabeledList>
            <LabeledList.Item label="Obecny tryb">
              {data.master_mode}
            </LabeledList.Item>
          </LabeledList>
          {!!data.round_started && (
            <NoticeBox mt={1}>Runda już się zaczęła.</NoticeBox>
          )}
          {!data.round_started && !!data.hotswap_disabled && (
            <NoticeBox mt={1}>
              Tryb wczytał już mapy i nie można go zmienić.
            </NoticeBox>
          )}
          <Box mt={1}>
            {allModes.map((mode) => (
              <Button
                key={mode.id}
                selected={data.master_mode === mode.id}
                disabled={!!data.round_started}
                onClick={() => act('set_mode', { mode: mode.id })}
              >
                {mode.name}
              </Button>
            ))}
          </Box>
          {data.master_mode === 'secret' && !data.round_started && (
            <Box mt={1}>
              <Box bold mb={0.5}>
                Wymuś tryb pod przykrywką secret:
              </Box>
              <Box color="label" mb={0.5}>
                Zmienia tryb, ale gracze nadal myślą, że to secret.
              </Box>
              {modes.map((mode) => (
                <Button
                  key={mode.id}
                  selected={data.secret_force_mode === mode.id}
                  onClick={() => act('force_secret', { mode: mode.id })}
                >
                  {mode.name}
                </Button>
              ))}
              <Button
                selected={data.secret_force_mode === 'secret'}
                onClick={() => act('force_secret', { mode: 'secret' })}
              >
                Losowy (domyślnie)
              </Button>
            </Box>
          )}
          {!!data.round_in_progress && (
            <Button mt={1} icon="cogs" onClick={() => act('gamemode_panel')}>
              Panel trybu gry
            </Button>
          )}
        </Section>
        {!!data.is_dynamic && <DynamicSection />}
        <Section title="Tworzenie">
          <Button icon="cube" onClick={() => act('create_object')}>
            Stwórz obiekt
          </Button>
          <Button icon="bolt" onClick={() => act('quick_create_object')}>
            Szybkie tworzenie obiektu
          </Button>
          <Button icon="border-all" onClick={() => act('create_turf')}>
            Stwórz turf
          </Button>
          <Button icon="paw" onClick={() => act('create_mob')}>
            Stwórz moba
          </Button>
          {!!data.marked_atom && (
            <Button icon="copy" onClick={() => act('dupe_marked_datum')}>
              Powiel oznaczony datum
            </Button>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
