/**
 * Okno bloku utylizacyjnego w formie urządzenia.
 * Port pomysłu z Polonium Station (polonium14/polonium-station#1299).
 * Dźwignia (klik albo przeciągnięcie w dół), lampki ładowania, gotowości
 * i zawartości, wskaźnik ciśnienia, przełączniki pompy, wyrzutu i zamknięcia.
 * Kliknięcie otworu wkłada przedmiot z ręki, pustą ręką wyjmuje ostatni.
 */

import { MouseEvent, ReactNode, useRef, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  closeWindow,
  ItemIcon,
  PixelDevice,
  PixelNote,
  Px,
  Rect,
  SCALE,
  Sprite,
  useClock,
} from './PixelUi';

type Item = { ref: string; name: string; icon?: string };

type Data = {
  flush: BooleanLike;
  full_pressure: BooleanLike;
  pressure_charging: BooleanLike;
  panel_open: BooleanLike;
  per: number;
  isai: BooleanLike;
  items: Item[];
  creatures: number;
  big_creature: BooleanLike;
  flushing: BooleanLike;
  powered: BooleanLike;
  holding?: string;
};

const TOP = 24;
const MOUTH = { x: 13, y: 14 + TOP, w: 74, h: 30 };
const LEVER = { x: 54, y: 62 + TOP, w: 12, h: 46, handle: 9 };
const LAMP_X = 81;
const LAMP_YS = [67 + TOP, 82 + TOP, 97 + TOP];
const GAUGE = { x: 7, y: 114 + TOP, marks: 29 };
const ROCKERS = [64 + TOP, 79 + TOP, 94 + TOP];
const NOTE_X = 106;

const RED = ['#e85c33', '#feb070', '#5a1c1c'];
const GREEN = ['#35e765', '#aeff37', '#1d4a2a'];
const BLUE = ['#5fa4e9', '#abe8fd', '#22364f'];

export const DisposalDevice = () => {
  const { act, data } = useBackend<Data>();
  const {
    flush,
    full_pressure,
    pressure_charging,
    panel_open,
    per,
    isai,
    items = [],
    creatures,
    big_creature,
    flushing,
    powered,
    holding,
  } = data;
  const time = useClock(true, 8);
  const blink = Math.floor(time * 2) % 2 === 0;
  const waiting = items.length > 0 || creatures > 0;
  const ready = !!full_pressure;
  const leverLocked = !!isai || !!panel_open;

  const toggleLever = () => {
    if (!leverLocked) {
      act(flush ? 'handle-0' : 'handle-1');
    }
  };

  const status = !powered
    ? 'Brak zasilania'
    : panel_open
      ? 'Zasilanie odłączone'
      : ready
        ? 'Gotowy do spłukania'
        : pressure_charging
          ? `Nabijanie ciśnienia ${Math.round(per * 100)}%`
          : 'Pompa wyłączona';

  return (
    <PixelDevice width={NOTE_X + 96 + 4} height={162} title="Blok utylizacyjny">
      <Sprite
        img="disposal-disposal"
        x={0}
        y={TOP}
        w={100}
        h={136}
        drag
        className={flushing ? 'DisposalDevice__jolt' : undefined}
      />
      <Mouth
        items={items}
        creatures={creatures}
        big={!!big_creature}
        flushing={!!flushing}
        holding={holding}
        canReach={!isai}
        onClick={() => act('mouth')}
      />
      <Lever down={!!flush} locked={leverLocked} onToggle={toggleLever} />

      <Lamp
        y={LAMP_YS[0]}
        lit={!!powered && !ready && !!pressure_charging}
        colors={RED}
        title={powered ? 'Ładowanie ciśnienia' : 'Brak zasilania'}
      />
      <Lamp
        y={LAMP_YS[1]}
        lit={!!powered && ready}
        colors={GREEN}
        title={powered ? 'Gotowy' : 'Brak zasilania'}
      />
      <Lamp
        y={LAMP_YS[2]}
        lit={!!powered && waiting && (blink || !flush)}
        colors={BLUE}
        title={waiting ? 'Coś czeka na wysyłkę' : 'Pusto'}
      />

      <Px x={GAUGE.x} y={GAUGE.y} w={GAUGE.marks * 3} h={2} title={status}>
        {Array.from({ length: GAUGE.marks }, (_, index) => {
          const lit = powered
            ? ready
              ? GAUGE.marks
              : Math.floor(per * GAUGE.marks + 0.001)
            : 0;
          const on = index < lit;
          return (
            <Rect
              key={index}
              x={index * 3}
              y={0}
              w={2}
              h={2}
              color={on ? (ready ? GREEN[0] : RED[0]) : '#3a3c45'}
            />
          );
        })}
      </Px>

      <Rocker
        y={ROCKERS[0]}
        disabled={!!panel_open}
        title={pressure_charging ? 'Wyłącz pompę' : 'Włącz pompę'}
        onClick={() => act(pressure_charging ? 'pump-0' : 'pump-1')}
      >
        <Rect
          x={7}
          y={12}
          w={6}
          h={1}
          color={pressure_charging ? GREEN[1] : '#3a3c45'}
        />
        <Rect
          x={9}
          y={10}
          w={2}
          h={2}
          color={pressure_charging ? GREEN[1] : '#3a3c45'}
        />
      </Rocker>
      <Rocker
        y={ROCKERS[1]}
        disabled={!!isai}
        title="Wyrzuć zawartość"
        onClick={() => act('eject')}
      >
        <Rect x={9} y={10} w={1} h={1} color="#17181c" />
        <Rect x={8} y={11} w={3} h={1} color="#17181c" />
        <Rect x={7} y={12} w={5} h={1} color="#17181c" />
        <Rect x={7} y={13} w={5} h={1} color="#17181c" />
      </Rocker>
      <Rocker y={ROCKERS[2]} title="Zamknij" onClick={closeWindow}>
        {[0, 1, 2, 3].map((step) => (
          <div key={step}>
            <Rect x={7 + step} y={10 + step} w={1} h={1} color="#17181c" />
            <Rect x={10 - step} y={10 + step} w={1} h={1} color="#17181c" />
          </div>
        ))}
      </Rocker>

      <PixelNote
        x={NOTE_X}
        y={20}
        w={96}
        h={124}
        img="microwave-note"
        sections={[
          {
            top: 13,
            heading: 'W ŚRODKU',
            empty: creatures ? undefined : 'pusto',
            maxRows: 9,
            rows: [
              ...items
                .slice()
                .reverse()
                .map((item) => ({ key: item.ref, text: item.name })),
              ...(creatures
                ? [
                    {
                      key: 'creatures',
                      text: big_creature ? 'Coś dużego' : 'Coś się rusza',
                    },
                  ]
                : []),
            ],
          },
        ]}
      />
    </PixelDevice>
  );
};

/** Otwór z widocznymi rzeczami i klapą, która zamyka się przy spłukiwaniu. */
const Mouth = (props: {
  items: Item[];
  creatures: number;
  big: boolean;
  flushing: boolean;
  holding?: string;
  canReach: boolean;
  onClick: () => void;
}) => {
  const { items, creatures, big, flushing, holding, canReach, onClick } = props;
  const visible = items.slice(-4);
  let title = 'Otwór bloku';
  if (canReach) {
    title = holding
      ? `Wrzuć: ${holding}`
      : items.length
        ? `Wyjmij: ${items[items.length - 1].name}`
        : creatures
          ? big
            ? 'W środku jest coś dużego'
            : 'Coś się tam rusza'
          : 'Pusto';
  }
  return (
    <Px
      x={MOUTH.x}
      y={MOUTH.y}
      w={MOUTH.w}
      h={MOUTH.h}
      title={title}
      style={{ cursor: canReach ? 'pointer' : 'default', overflow: 'hidden' }}
      onClick={canReach ? onClick : undefined}
    >
      {visible.map((item, index) => (
        <ItemIcon
          key={item.ref}
          x={6 + index * 16}
          y={MOUTH.h - 26 + (index % 2) * 3}
          icon={item.icon}
          style={{ opacity: 0.55, pointerEvents: 'none' }}
        />
      ))}
      {creatures > 0 && (
        <div
          className="DisposalDevice__creature"
          style={{ pointerEvents: 'none' }}
        >
          <Rect
            x={MOUTH.w - 22}
            y={MOUTH.h - (big ? 16 : 9)}
            w={big ? 16 : 8}
            h={big ? 16 : 9}
            color="#0a0a0e"
          />
          <Rect
            x={MOUTH.w - 18}
            y={MOUTH.h - (big ? 12 : 7)}
            w={1}
            h={1}
            color="#e8e8ea"
          />
          <Rect
            x={MOUTH.w - 16}
            y={MOUTH.h - (big ? 12 : 7)}
            w={1}
            h={1}
            color="#e8e8ea"
          />
        </div>
      )}
      <div
        className="DisposalDevice__hatch"
        style={{ transform: flushing ? 'translateY(0)' : 'translateY(-101%)' }}
      >
        {[0, 1, 2, 3, 4].map((band) => (
          <Rect
            key={band}
            x={0}
            y={band * 6}
            w={MOUTH.w}
            h={5}
            color={band % 2 ? '#2f3850' : '#232a3b'}
          />
        ))}
      </div>
    </Px>
  );
};

/** Dźwignia spłukiwania: klik albo przeciągnięcie uchwytu w dół lub w górę. */
const Lever = (props: {
  down: boolean;
  locked: boolean;
  onToggle: () => void;
}) => {
  const { down, locked, onToggle } = props;
  const travelMax = LEVER.h - LEVER.handle;
  const [drag, setDrag] = useState<number | null>(null);
  const start = useRef(0);
  const travel = drag ?? (down ? travelMax : 0);

  const onMouseDown = (event: MouseEvent<HTMLDivElement>) => {
    if (locked) {
      return;
    }
    event.stopPropagation();
    start.current = event.clientY;
    const base = down ? travelMax : 0;
    setDrag(base);
    const move = (moveEvent: globalThis.MouseEvent) => {
      const delta = (moveEvent.clientY - start.current) / SCALE;
      setDrag(Math.max(0, Math.min(travelMax, base + delta)));
    };
    const up = (upEvent: globalThis.MouseEvent) => {
      window.removeEventListener('mousemove', move);
      window.removeEventListener('mouseup', up);
      const delta = (upEvent.clientY - start.current) / SCALE;
      setDrag(null);
      // Klik bez ruchu albo przeciągnięcie za połowę drogi przełącza dźwignię
      const moved = Math.abs(delta) > 2;
      if (!moved || (down ? delta < -travelMax / 2 : delta > travelMax / 2)) {
        onToggle();
      }
    };
    window.addEventListener('mousemove', move);
    window.addEventListener('mouseup', up);
  };

  const y = LEVER.y + Math.round(travel);
  return (
    <>
      {travel > 0 && (
        <>
          <Rect
            x={LEVER.x + 4}
            y={LEVER.y}
            w={4}
            h={Math.round(travel)}
            color="#585868"
          />
          <Rect
            x={LEVER.x + 4}
            y={LEVER.y}
            w={1}
            h={Math.round(travel)}
            color="#848893"
          />
          <Rect
            x={LEVER.x + 7}
            y={LEVER.y}
            w={1}
            h={Math.round(travel)}
            color="#848893"
          />
        </>
      )}
      <div
        title={
          locked
            ? 'Dźwignia zablokowana'
            : down
              ? 'Zwolnij dźwignię'
              : 'Pociągnij dźwignię: spłukanie po nabiciu ciśnienia'
        }
        onMouseDown={onMouseDown}
        style={{ cursor: locked ? 'default' : 'ns-resize' }}
      >
        <Rect
          x={LEVER.x - 2}
          y={y}
          w={LEVER.w + 4}
          h={LEVER.handle}
          color="#6b2329"
        />
        <Rect x={LEVER.x - 2} y={y} w={LEVER.w + 4} h={7} color="#a62228" />
        <Rect x={LEVER.x - 2} y={y} w={LEVER.w + 4} h={5} color="#d74722" />
        <Rect x={LEVER.x - 1} y={y + 1} w={LEVER.w + 2} h={1} color="#f0714a" />
      </div>
    </>
  );
};

const Lamp = (props: {
  y: number;
  lit: boolean;
  colors: string[];
  title: string;
}) => {
  const { y, lit, colors, title } = props;
  return (
    <Px x={LAMP_X} y={y} w={8} h={8} title={title}>
      <Rect
        x={0}
        y={0}
        w={8}
        h={8}
        color={lit ? colors[0] : colors[2]}
        style={
          lit ? { boxShadow: `0 0 ${6 * SCALE}px ${colors[0]}` } : undefined
        }
      />
      {lit && <Rect x={0} y={0} w={4} h={4} color={colors[1]} />}
    </Px>
  );
};

/** Przełącznik kołyskowy na lewym panelu (30x15), ikona na jasnej części. */
const Rocker = (props: {
  y: number;
  disabled?: boolean;
  title: string;
  onClick: () => void;
  children?: ReactNode;
}) => {
  const { y, disabled, title, onClick, children } = props;
  return (
    <Px
      x={14}
      y={y}
      w={30}
      h={15}
      title={title}
      className={disabled ? undefined : 'DisposalDevice__rocker'}
      onClick={disabled ? undefined : onClick}
    >
      {children}
    </Px>
  );
};
