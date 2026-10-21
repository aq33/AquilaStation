import {
  Box,
  Button,
  Collapsible,
  Divider,
  Dropdown,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: nie mamy wspólnego "ID" instrumentów z tg (synchroniczne granie),
// więc to pole zostało pominięte. Dodatkowo pokazujemy typ instrumentu
// (dawny/syntetyzowany) i kategorię przy wyborze instrumentu.

type Data = {
  using_instrument: string | null;
  can_noteshift: BooleanLike;
  note_shift_min: number;
  note_shift_max: number;
  note_shift: number;
  octaves: number;
  sustain_mode: number;
  sustain_mode_duration: number;
  sustain_mode_min: number;
  sustain_mode_max: number;
  sustain_mode_step: number;
  instrument_ready: BooleanLike;
  legacy: BooleanLike;
  volume: number;
  volume_dropoff_threshold: number;
  min_volume: number;
  max_volume: number;
  sustain_indefinitely: BooleanLike;
  playing: BooleanLike;
  max_repeats: number;
  repeat: number;
  bpm: number;
  lines: LineData[];
  can_switch_instrument: BooleanLike;
  possible_instruments: InstrumentData[];
  max_line_chars: number;
  max_lines: number;
};

type InstrumentData = {
  name: string;
  id: string;
  category: string;
};

type LineData = {
  line_count: number;
  line_text: string;
};

// Wartości jak w DM: SUSTAIN_LINEAR, SUSTAIN_EXPONENTIAL
const SUSTAIN_LINEAR = 1;
const SUSTAIN_MODES = [
  { displayText: 'Liniowy', value: SUSTAIN_LINEAR },
  { displayText: 'Wykładniczy', value: 2 },
];

export const InstrumentEditor = (props) => {
  return (
    <Window width={750} height={500}>
      <Window.Content scrollable>
        <InstrumentSettings />
        <Collapsible open title="Edytor utworu" icon="pencil">
          <EditingSettings />
        </Collapsible>
        <Collapsible title="Pomoc" icon="question">
          <HelpSection />
        </Collapsible>
      </Window.Content>
    </Window>
  );
};

const instrumentLabel = (instrument: InstrumentData) =>
  instrument.category
    ? `${instrument.category}: ${instrument.name}`
    : instrument.name;

const InstrumentSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    playing,
    repeat,
    max_repeats,
    can_switch_instrument,
    possible_instruments = [],
    instrument_ready,
    using_instrument,
    legacy,
    can_noteshift,
    note_shift_min,
    note_shift_max,
    note_shift,
    octaves,
    sustain_mode,
    sustain_mode_duration,
    sustain_indefinitely,
    sustain_mode_min,
    sustain_mode_max,
    sustain_mode_step,
    volume,
    min_volume,
    max_volume,
    volume_dropoff_threshold,
    lines = [],
  } = data;

  const currentInstrument = possible_instruments.find(
    (instrument) => instrument.name === using_instrument,
  );

  return (
    <Section title="Ustawienia">
      {lines.length > 0 && (
        <Box fontSize="16px" mb={1}>
          <Button
            icon={playing ? 'stop' : 'play'}
            selected={!!playing}
            onClick={() => act('play_music')}
          >
            {playing ? 'Zatrzymaj' : 'Graj'}
          </Button>
        </Box>
      )}
      <Box>
        {playing ? 'Pozostałe powtórzenia:' : 'Powtórzenia:'}
        <NumberInput
          ml={1}
          step={1}
          minValue={0}
          disabled={!!playing}
          maxValue={max_repeats}
          value={repeat}
          onChange={(value) =>
            act('set_repeat_amount', {
              amount: value,
            })
          }
        />
      </Box>
      <Box mt={0.5}>
        <Stack fill>
          <Stack.Item mt={0.5}>Instrument:</Stack.Item>
          <Stack.Item grow>
            {can_switch_instrument ? (
              <Dropdown
                width="60%"
                selected={
                  currentInstrument
                    ? instrumentLabel(currentInstrument)
                    : using_instrument || 'Nie załadowano instrumentu!'
                }
                options={possible_instruments.map((instrument) => ({
                  displayText: instrumentLabel(instrument),
                  value: instrument.id,
                }))}
                onSelected={(value) =>
                  act('change_instrument', {
                    new_instrument: value,
                  })
                }
              />
            ) : (
              <Box mt={0.5} color={using_instrument ? undefined : 'bad'}>
                {using_instrument || 'Nie załadowano instrumentu!'}
              </Box>
            )}
          </Stack.Item>
        </Stack>
      </Box>
      <Stack mt={1}>
        <Stack.Item>
          Ustawienia odtwarzania:
          {!!can_noteshift && (
            <Box>
              Przesunięcie:{' '}
              <NumberInput
                minValue={note_shift_min}
                maxValue={note_shift_max}
                step={1}
                value={note_shift}
                onChange={(value) =>
                  act('set_note_shift', {
                    amount: value,
                  })
                }
              />{' '}
              klawiszy / {octaves} oktaw
            </Box>
          )}
          <Stack>
            <Stack.Item mt={0.5}>Tryb podtrzymania:</Stack.Item>
            <Stack.Item grow>
              <Dropdown
                width="100%"
                selected={
                  SUSTAIN_MODES.find((mode) => mode.value === sustain_mode)
                    ?.displayText || ''
                }
                options={SUSTAIN_MODES}
                onSelected={(value) =>
                  act('set_sustain_mode', {
                    new_mode: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
          <Box>
            {sustain_mode === SUSTAIN_LINEAR
              ? 'Czas liniowego podtrzymania (s)'
              : 'Współczynnik wykładniczego zaniku (% na decysekundę)'}
            :
            <NumberInput
              ml={1}
              step={sustain_mode_step}
              minValue={sustain_mode_min}
              maxValue={sustain_mode_max}
              value={sustain_mode_duration}
              format={(value) => String(Math.round(value * 1000) / 1000)}
              onChange={(value) =>
                act('edit_sustain_mode', {
                  amount: value,
                })
              }
            />
          </Box>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item>
          <Box>
            Stan:
            {instrument_ready ? (
              <Box as="span" color="good">
                {' '}
                Gotowy
              </Box>
            ) : (
              <Box as="span" color="bad">
                {' '}
                Błąd definicji instrumentu!
              </Box>
            )}
          </Box>
          <Box>Typ instrumentu: {legacy ? 'dawny' : 'syntetyzowany'}</Box>
          <Box>
            Głośność:
            <NumberInput
              ml={1}
              step={1}
              minValue={min_volume}
              maxValue={max_volume}
              value={volume}
              onChange={(value) =>
                act('set_volume', {
                  amount: value,
                })
              }
            />
          </Box>
          <Box>
            Próg zaniku głośności:
            <NumberInput
              ml={1}
              step={1}
              minValue={0}
              maxValue={100}
              value={volume_dropoff_threshold}
              onChange={(value) =>
                act('set_dropoff_volume', {
                  amount: value,
                })
              }
            />
          </Box>
          <Box>
            <Button.Checkbox
              checked={!!sustain_indefinitely}
              onClick={() => act('toggle_sustain_hold_indefinitely')}
            >
              Podtrzymuj bez końca ostatnią przytrzymaną nutę
            </Button.Checkbox>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EditingSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const { bpm, lines = [], max_lines } = data;

  return (
    <Section>
      <Box>
        <Button icon="file" onClick={() => act('start_new_song')}>
          Zacznij nowy utwór
        </Button>
        <Button icon="file-import" onClick={() => act('import_song')}>
          Importuj utwór
        </Button>
      </Box>
      <Box mt={0.5}>
        Tempo:{' '}
        <Button
          onClick={() => act('tempo', { tempo_change: 'decrease_speed' })}
        >
          -
        </Button>{' '}
        {bpm} BPM{' '}
        <Button
          onClick={() => act('tempo', { tempo_change: 'increase_speed' })}
        >
          +
        </Button>
      </Box>
      <Box mt={0.5}>
        {lines.map((line) => (
          <Box key={line.line_count} fontSize="11px">
            Linia {line.line_count}:
            <Button
              onClick={() =>
                act('modify_line', { line_editing: line.line_count })
              }
            >
              Edytuj
            </Button>
            <Button
              color="bad"
              onClick={() =>
                act('delete_line', { line_deleted: line.line_count })
              }
            >
              X
            </Button>
            {line.line_text}
          </Box>
        ))}
      </Box>
      <Box>
        <Button
          icon="plus"
          disabled={lines.length >= max_lines}
          onClick={() => act('add_new_line')}
        >
          Dodaj linię
        </Button>
      </Box>
    </Section>
  );
};

const HelpSection = (props) => {
  const { data } = useBackend<Data>();
  const { max_line_chars, max_lines } = data;

  return (
    <Section>
      <Box>
        Linie to ciągi akordów oddzielonych przecinkami (,), a nuty w akordzie
        oddziela się łącznikami (-).
        <br />
        Wszystkie nuty w akordzie zagrają razem, a czas akordu wyznacza tempo.
        <br />
        Nuty zapisuje się nazwą nuty i opcjonalnie znakiem chromatycznym i/lub
        numerem oktawy.
        <br />
        Domyślnie każda nuta jest naturalna i w oktawie 3. Zmienione ustawienie
        jest zapamiętywane dla każdej nuty.
        <br />
        Przykład: <i>C,D,E,F,G,A,B</i> zagra gamę C-dur.
        <br />
        Gdy nuta dostanie znak chromatyczny, zostanie on zapamiętany:{' '}
        <i>C,C4,C,C3</i> to <i>C3,C4,C4,C3</i>
        <br />
        Akordy gra się, oddzielając nuty łącznikiem: <i>A-C#,Cn-E,E-G#,Gn-B</i>
        <br />
        Pauzę oznacza pusty akord: <i>C,E,,C,G</i>
        <br />
        Aby akord trwał inaczej, zakończ go /x, a jego długość wyniesie tempo /
        x: <i>C,G/2,E/4</i>
        <br />
        Łącznie przykład wygląda tak: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i>
        <br />
        Pierwsza linia importowanego utworu może ustawić tempo: <i>BPM: 120</i>
        <br />
        Linie mogą mieć do {max_line_chars} znaków.
        <br />
        Utwór może mieć najwyżej {max_lines} linii.
        <br />
      </Box>
    </Section>
  );
};
