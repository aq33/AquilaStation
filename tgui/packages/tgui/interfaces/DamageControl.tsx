// AQUILA - konsola kontroli uszkodzeń (aquila/code/modules/overmap/damage_control/dc_console.dm): schemat pokładów
// z wyłomami, pożarami i ciśnieniem w przedziałach, pancerz ćwiartek i nanopompy. Priorytet przedziału idzie na PDA ekip.
import { useState } from 'react';
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  COLOR,
  ConsoleBar,
  ConsoleBody,
  ConsoleEmpty,
  ConsoleMeter,
  ConsolePanel,
  ConsoleRow,
  ConsoleTabs,
  ConsoleWindow,
  MONO,
} from './common/ShipConsole';

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
  breach: COLOR.bad,
  fire: COLOR.ir,
  low: COLOR.warn,
  ok: COLOR.good,
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
        background: COLOR.bg,
        border: '1px solid ' + COLOR.line,
        borderRadius: '4px',
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
                (area.priority ? '2px solid ' + COLOR.desig : '1px solid ') +
                (area.priority ? '' : colour),
              cursor: 'pointer',
              overflow: 'hidden',
              fontSize: '9px',
              lineHeight: '10px',
              color: COLOR.ink2,
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
    <ConsolePanel
      title="Przedziały z problemami"
      right={<span style={{ fontFamily: MONO }}>{problems.length}</span>}
    >
      {!problems.length && (
        <Box style={{ color: COLOR.good }}>
          Wszystkie przedziały szczelne, bez pożarów.
        </Box>
      )}
      {problems.map((area) => (
        <Box
          key={area.id}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            padding: '4px 0',
            borderTop: '1px solid ' + COLOR.line,
          }}
        >
          <Box style={{ flex: 1, minWidth: 0 }}>
            <b style={{ color: STATE_COLOUR[area.state] }}>
              {STATE_NAME[area.state]}
            </b>
            <span style={{ color: COLOR.ink }}>{' · ' + area.name}</span>
            <span style={{ color: COLOR.muted }}>
              {' · ' + area.deck + ' · '}
            </span>
            <span style={{ fontFamily: MONO, color: COLOR.ink2 }}>
              {area.pressure + ' kPa'}
            </span>
            {!area.power && (
              <span style={{ color: COLOR.warn }}>{' · bez zasilania'}</span>
            )}
          </Box>
          {[1, 2, 3].map((priority) => (
            <Button
              key={priority}
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
          ))}
        </Box>
      ))}
    </ConsolePanel>
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
    <ConsolePanel title="Pancerz i nanopompy">
      {quadrants.map((name, index) => (
        <ConsoleRow key={name} label={name}>
          <ConsoleMeter value={(armour[index] ?? 0) / 100} />
        </ConsoleRow>
      ))}
      <ConsoleRow label="Kadłub">
        <ConsoleMeter value={(armour[4] ?? 0) / 100} />
      </ConsoleRow>
      <Box mt={1}>
        {!data.pumps.length && (
          <ConsoleEmpty>Brak nanopomp połączonych z okrętem.</ConsoleEmpty>
        )}
        {data.pumps.map((pump, index) => (
          <ConsoleRow
            key={index}
            label={QUADRANT_NAME[pump.quadrant] || pump.quadrant}
            colour={pump.online ? COLOR.good : COLOR.bad}
          >
            {pump.stress
              ? 'przeciążona'
              : pump.online
                ? 'pracuje'
                : 'wyłączona'}
          </ConsoleRow>
        ))}
      </Box>
    </ConsolePanel>
  );
};

export const DamageControl = () => {
  const { data } = useBackend<Data>();
  const [deckIndex, setDeckIndex] = useState(0);
  const deck = data.decks[Math.min(deckIndex, data.decks.length - 1)];
  const areas = data.decks.flatMap((d) => d.areas);
  const count = (state: DCArea['state']) =>
    areas.filter((area) => area.state === state).length;
  const hull = data.armour?.[4] ?? 0;
  return (
    <ConsoleWindow width={760} height={720}>
      <ConsoleBar>
        {(['breach', 'fire', 'low'] as const).map((state) => (
          <span key={state}>
            <span style={{ color: COLOR.muted }}>
              {STATE_NAME[state] + ': '}
            </span>
            <span
              style={{
                fontFamily: MONO,
                color: count(state) ? STATE_COLOUR[state] : COLOR.ink2,
              }}
            >
              {count(state)}
            </span>
          </span>
        ))}
        <span style={{ marginLeft: 'auto', color: COLOR.muted }}>Kadłub</span>
        <ConsoleMeter value={hull / 100} width="160px" />
      </ConsoleBar>
      <ConsoleTabs<string>
        tabs={data.decks.map((d, index) => [String(index), d.name])}
        active={String(deckIndex)}
        onChange={(tab) => setDeckIndex(Number(tab))}
      />
      <ConsoleBody>
        <ConsolePanel title="Schemat pokładu">
          <Box mb={1} style={{ color: COLOR.muted }}>
            Kliknij przedział, żeby zmienić jego priorytet (P1 najważniejszy).
            Priorytet idzie na PDA inżynierii.
          </Box>
          {deck ? (
            <DeckMap deck={deck} />
          ) : (
            <ConsoleEmpty>Konsola nie widzi przedziałów okrętu.</ConsoleEmpty>
          )}
        </ConsolePanel>
        <Problems />
        <Armour />
      </ConsoleBody>
    </ConsoleWindow>
  );
};
