// AQUILA - kuźnia amunicji: rytmiczna minigra kowadła (na wzór anvil_minigame z Monkestation).
// Nuty jadą od prawej do linii uderzenia. Czas mierzy klient, serwer sprawdza go ze swoim zegarem.

import { useEffect, useRef, useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { KEY_E, KEY_Q, KEY_SPACE } from '../../common/keycodes';
import { useBackend } from '../backend';
import { acquireHotKey, listenForKeyEvents, releaseHotKey } from '../hotkeys';
import { Window } from '../layouts';

type NoteKey = 'space' | 'q' | 'e';

type Note = {
  time: number;
  key: NoteKey;
};

type Data = {
  notes: Note[];
  window: number;
  difficulty: number;
  part: string;
  target_class: string;
  start_ref: string;
  hits: number;
  misses: number;
};

const LANE_WIDTH = 440;
const HIT_LINE = 60;
/** Piksele na milisekundę */
const SPEED = 0.22;

const KEY_LABELS: Record<NoteKey, string> = {
  space: 'Spacja',
  q: 'Q',
  e: 'E',
};

const KEY_COLORS: Record<NoteKey, string> = {
  space: '#e8a33a',
  q: '#5aa9e6',
  e: '#d9534f',
};

const KEY_HINTS: Record<NoteKey, string> = {
  space: 'uderzenie',
  q: 'lekkie',
  e: 'mocne',
};

const CODE_TO_KEY: Record<number, NoteKey> = {
  [KEY_SPACE]: 'space',
  [KEY_Q]: 'q',
  [KEY_E]: 'e',
};

/** Co klient już rozstrzygnął: true trafiona, false pudło */
type Resolved = Record<number, boolean>;

export const MunitionsAnvil = (props) => {
  const { act, data } = useBackend<Data>();
  const { notes = [], window: hitWindow, part, target_class, start_ref } = data;

  const startRef = useRef(performance.now());
  const resolvedRef = useRef<Resolved>({});
  const [now, setNow] = useState(0);
  const [flash, setFlash] = useState<'hit' | 'miss' | null>(null);

  // Nowe kucie (inny datum na serwerze) zaczyna zegar od zera
  useEffect(() => {
    startRef.current = performance.now();
    resolvedRef.current = {};
  }, [start_ref]);

  // Pętla animacji; spóźnione nuty od razu zgłaszamy jako pudła
  useEffect(() => {
    let frame = 0;
    const tick = () => {
      const elapsed = performance.now() - startRef.current;
      setNow(elapsed);
      notes.forEach((note, i) => {
        if (resolvedRef.current[i] !== undefined) {
          return;
        }
        if (elapsed > note.time + hitWindow) {
          resolvedRef.current[i] = false;
          act('miss', { index: i + 1 });
        }
      });
      frame = requestAnimationFrame(tick);
    };
    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  }, [notes, hitWindow, start_ref]);

  const press = (key: NoteKey) => {
    const elapsed = performance.now() - startRef.current;
    // pierwsza nierozstrzygnięta nuta w oknie albo tuż przed nim
    const index = notes.findIndex(
      (note, i) =>
        resolvedRef.current[i] === undefined &&
        Math.abs(elapsed - note.time) <= hitWindow * 3,
    );
    if (index < 0) {
      return;
    }
    const note = notes[index];
    const delta = Math.round(elapsed - note.time);
    const good = note.key === key && Math.abs(delta) <= hitWindow;
    resolvedRef.current[index] = good;
    setFlash(good ? 'hit' : 'miss');
    act('hit', { index: index + 1, key, delta });
  };

  // Spacja, Q i E nie trafiają do gry, póki okno jest otwarte
  useEffect(() => {
    acquireHotKey(KEY_Q);
    acquireHotKey(KEY_E);
    const stop = listenForKeyEvents((key) => {
      if (!key.isDown() || key.repeat) {
        return;
      }
      const noteKey = CODE_TO_KEY[key.code];
      if (noteKey) {
        press(noteKey);
      }
    });
    return () => {
      stop();
      releaseHotKey(KEY_Q);
      releaseHotKey(KEY_E);
    };
  }, [notes, hitWindow, start_ref]);

  useEffect(() => {
    if (!flash) {
      return;
    }
    const timer = setTimeout(() => setFlash(null), 150);
    return () => clearTimeout(timer);
  }, [flash, now > 0]);

  const resolvedCount = Object.keys(resolvedRef.current).length;
  const hits = Object.values(resolvedRef.current).filter(Boolean).length;
  const misses = resolvedCount - hits;
  const accuracy = notes.length ? hits / notes.length : 1;
  const countdown = notes.length ? Math.ceil((notes[0].time - now) / 1000) : 0;
  const usedKeys = Array.from(new Set(notes.map((note) => note.key)));

  return (
    <Window width={500} height={320} title="Kowadło">
      <Window.Content>
        <Section title={`${part} (cel: klasa ${target_class})`}>
          <Box
            position="relative"
            width={`${LANE_WIDTH}px`}
            height="64px"
            backgroundColor="#1d1d22"
            style={{
              overflow: 'hidden',
              borderRadius: '4px',
              cursor: 'pointer',
            }}
            onMouseDown={() => press('space')}
          >
            <Box
              position="absolute"
              left={`${HIT_LINE - 2}px`}
              top="0px"
              width="4px"
              height="64px"
              backgroundColor={
                flash === 'hit'
                  ? '#7fd36b'
                  : flash === 'miss'
                    ? '#d9534f'
                    : '#c8c8c8'
              }
            />
            {notes.map((note, i) => {
              const state = resolvedRef.current[i];
              const x = HIT_LINE + (note.time - now) * SPEED;
              if (state === true || x < -20 || x > LANE_WIDTH + 20) {
                return null;
              }
              return (
                <Box
                  key={i}
                  position="absolute"
                  left={`${x - 14}px`}
                  top="14px"
                  width="28px"
                  height="36px"
                  lineHeight="36px"
                  textAlign="center"
                  bold
                  backgroundColor={
                    state === false ? '#555' : KEY_COLORS[note.key]
                  }
                  style={{ borderRadius: '6px', fontSize: '10px' }}
                >
                  {note.key === 'space' ? 'SPC' : note.key.toUpperCase()}
                </Box>
              );
            })}
            {countdown > 0 && (
              <Box
                position="absolute"
                left="0px"
                top="0px"
                width="100%"
                height="64px"
                lineHeight="64px"
                textAlign="center"
                fontSize="24px"
                bold
              >
                {countdown}
              </Box>
            )}
          </Box>
          <Stack mt={1}>
            {usedKeys.map((key) => (
              <Stack.Item key={key}>
                <Button
                  color="transparent"
                  textColor={KEY_COLORS[key]}
                  onClick={() => press(key)}
                >
                  {KEY_LABELS[key]}: {KEY_HINTS[key]}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
          <Box mt={1}>
            Trafione: {hits}, pudła: {misses}, zostało:{' '}
            {notes.length - resolvedCount}. Celność:{' '}
            {Math.round(accuracy * 100)}
            %.
          </Box>
          <Box mt={0.5} color="label">
            Klawisze działają, gdy to okno jest aktywne: kliknij tor nut
            (kliknięcie to też uderzenie Spacją). Od 90% celnych uderzeń
            wychodzi klasa z formy, każde 15% mniej to klasa niżej. Zamknięcie
            okna albo odłożenie młota przerywa kucie.
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
