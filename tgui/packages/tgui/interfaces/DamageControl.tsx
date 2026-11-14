// AQUILA - konsola kontroli uszkodzeń (aquila/code/modules/overmap/damage_control/dc_console.dm): schemat pokładów
// z wyłomami, pożarami i ciśnieniem w przedziałach, pancerz ćwiartek i nanopompy. Priorytet przedziału idzie na PDA ekip.
import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DCArea = {
  id: string;
  name: string;
  x0: number;
  y0: number;
  x1: number;
  y1: number;
  pressure: number;
  state: 'breach' | 'fire' | 'low' | 'ok';
  power: boolean;
  priority: number;
};

type Deck = {
  z: number;
  name: string;
  areas: DCArea[];
};

type Pump = {
  quadrant: string;
  online: boolean;
  stress: boolean;
};

type Data = {
  decks: Deck[];
  armour: number[];
  pumps: Pump[];
};

const STATE_COLOUR = {
  breach: '#e0463c',
  fire: '#f08a24',
  low: '#d8c43a',
  ok: '#3f9e5a',
};

const STATE_NAME = {
  breach: 'wyłom',
  fire: 'pożar',
  low: 'mało powietrza',
  ok: 'w porządku',
};

const SEVERITY = { breach: 0, fire: 1, low: 2, ok: 3 };

const QUADRANT_NAME = {
  forward_port: 'dziób, lewa burta',
  forward_starboard: 'dziób, prawa burta',
  aft_port: 'rufa, lewa burta',
  aft_starboard: 'rufa, prawa burta',
};

// Schemat jednego pokładu: przedziały jako prostokąty w obrysie okrętu (dziób na wschodzie, jak na mapie)
const DeckMap = (props: { deck: Deck }) => {
  const { act } = useBackend<Data>();
  const { deck } = props;
  const x0 = Math.min(...deck.areas.map((area) => area.x0));
  const x1 = Math.max(...deck.areas.map((area) => area.x1));
  const y0 = Math.min(...deck.areas.map((area) => area.y0));
  const y1 = Math.max(...deck.areas.map((area) => area.y1));
  const spanX = x1 - x0 + 1;
  const spanY = y1 - y0 + 1;
  const width = 700;
  const height = Math.max(120, Math.round((width * spanY) / spanX));
  return (
    <div
      style={{
        position: 'relative',
        width: width + 'px',
        height: height + 'px',
        background: '#0e141c',
        border: '1px solid #2c3a4a',
        borderRadius: '6px',
      }}
    >
      {deck.areas.map((area) => {
        const colour = STATE_COLOUR[area.state];
        return (
          <div
            key={area.id}
            title={
              area.name +
              ': ' +
              STATE_NAME[area.state] +
              ', ' +
              area.pressure +
              ' kPa'
            }
            onClick={() =>
              act('set_priority', {
                id: area.id,
                priority: (area.priority + 1) % 4,
              })
            }
            style={{
              position: 'absolute',
              left: ((area.x0 - x0) / spanX) * 100 + '%',
              top: ((y1 - area.y1) / spanY) * 100 + '%',
              width: ((area.x1 - area.x0 + 1) / spanX) * 100 + '%',
              height: ((area.y1 - area.y0 + 1) / spanY) * 100 + '%',
              background: colour + (area.state === 'ok' ? '1f' : '55'),
              border:
                (area.priority ? '2px solid #ffffff' : '1px solid ') +
                (area.priority ? '' : colour),
              cursor: 'pointer',
              overflow: 'hidden',
              fontSize: '9px',
              lineHeight: '10px',
              color: '#c9d4df',
              padding: '1px',
            }}
          >
            {area.priority ? 'P' + area.priority + ' ' : ''}
            {area.name}
          </div>
        );
      })}
    </div>
  );
};

const Problems = () => {
  const { act, data } = useBackend<Data>();
  const problems = data.decks
    .flatMap((deck) => deck.areas.map((area) => ({ ...area, deck: deck.name })))
    .filter((area) => area.state !== 'ok' || area.priority)
    .sort((a, b) => SEVERITY[a.state] - SEVERITY[b.state]);
  return (
    <Section title="Przedziały z problemami">
      {!problems.length && (
        <Box color="good">Wszystkie przedziały szczelne, bez pożarów.</Box>
      )}
      {problems.map((area) => (
        <Stack key={area.id} align="center" mb={0.5}>
          <Stack.Item grow>
            <b style={{ color: STATE_COLOUR[area.state] }}>
              {STATE_NAME[area.state]}
            </b>
            {' · ' + area.name + ' · ' + area.deck + ' · '}
            {area.pressure + ' kPa'}
            {!area.power && ' · bez zasilania'}
          </Stack.Item>
          {[1, 2, 3].map((priority) => (
            <Stack.Item key={priority}>
              <Button
                selected={area.priority === priority}
                onClick={() =>
                  act('set_priority', {
                    id: area.id,
                    priority: area.priority === priority ? 0 : priority,
                  })
                }
              >
                {'P' + priority}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      ))}
    </Section>
  );
};

const Armour = () => {
  const { data } = useBackend<Data>();
  const armour = data.armour || [];
  const quadrants = [
    'dziób, lewa burta',
    'dziób, prawa burta',
    'rufa, lewa burta',
    'rufa, prawa burta',
  ];
  return (
    <Section title="Pancerz i nanopompy">
      <Stack wrap>
        {quadrants.map((name, index) => (
          <Stack.Item key={name} basis="48%">
            {name + ': '}
            <b>{(armour[index] ?? 0) + '%'}</b>
          </Stack.Item>
        ))}
      </Stack>
      <Box mt={0.5}>{'Kadłub: ' + (armour[4] ?? 0) + '%'}</Box>
      <Box mt={0.5}>
        {!data.pumps.length && 'Brak nanopomp połączonych z okrętem.'}
        {data.pumps.map((pump, index) => (
          <Box key={index}>
            {(QUADRANT_NAME[pump.quadrant] || pump.quadrant) + ': '}
            <b style={{ color: pump.online ? '#3f9e5a' : '#e0463c' }}>
              {pump.stress
                ? 'przeciążona'
                : pump.online
                  ? 'pracuje'
                  : 'wyłączona'}
            </b>
          </Box>
        ))}
      </Box>
    </Section>
  );
};

export const DamageControl = () => {
  const { data } = useBackend<Data>();
  const [deckIndex, setDeckIndex] = useState(0);
  const deck = data.decks[Math.min(deckIndex, data.decks.length - 1)];
  return (
    <Window width={760} height={720}>
      <Window.Content scrollable>
        <Section
          title="Schemat pokładu"
          buttons={data.decks.map((d, index) => (
            <Button
              key={d.z}
              selected={index === deckIndex}
              onClick={() => setDeckIndex(index)}
            >
              {d.name}
            </Button>
          ))}
        >
          <Box mb={0.5} color="label">
            Kliknij przedział, żeby zmienić jego priorytet (P1 najważniejszy).
            Priorytet idzie na PDA inżynierii.
          </Box>
          {deck ? (
            <DeckMap deck={deck} />
          ) : (
            <Box>Konsola nie widzi przedziałów okrętu.</Box>
          )}
        </Section>
        <Problems />
        <Armour />
      </Window.Content>
    </Window>
  );
};
