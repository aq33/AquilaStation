/**
 * Okno mikrofalówki w formie urządzenia.
 * Port pomysłu z Polonium Station (polonium14/polonium-station#1280),
 * dopasowany do naszej mikrofalówki: bez wyboru czasu (pieczenie trwa
 * stałą liczbę cykli zależną od mocy), gotowe rzeczy wypadają na podłogę.
 */

import { useEffect, useMemo, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  closeWindow,
  ItemIcon,
  Particle,
  Particles,
  PixelDevice,
  PixelKey,
  PixelNote,
  PixelText,
  Px,
  Rect,
  seededRandom,
  Segments,
  Sprite,
  useClock,
  usePrevious,
} from './PixelUi';

type Item = {
  ref: string;
  name: string;
  amount: number;
  icon?: string;
  food: BooleanLike;
};

type Data = {
  items: Item[];
  capacity: number;
  operating: BooleanLike;
  open: BooleanLike;
  dirty: number;
  mucking: BooleanLike;
  broken: number;
  powered: BooleanLike;
  efficiency: number;
  time_left: number;
  time_total: number;
  silicon: BooleanLike;
};

// Układ w pikselach grafiki (jak w oknie Polonium)
const CANVAS: [number, number] = [442, 220];
const CAVITY = { x: 14, y: 32, w: 214, h: 172 };
const PLATE = { x: 107, y: 124, rx: 82, ry: 30 };
const DISPLAY = { x: 240, y: 38, w: 82, h: 36 };
const LIT = '#30f050';
const GHOST = '#042b0b';
const SPIN_SPEED = 0.95;
const DONE_TIME = 2500;

const formatClock = (deciseconds: number) => {
  const seconds = Math.ceil(deciseconds / 10);
  const minutes = Math.min(9, Math.floor(seconds / 60));
  return `${minutes}:${String(seconds % 60).padStart(2, '0')}`;
};

export const MicrowaveDevice = () => {
  const { act, data } = useBackend<Data>();
  const {
    items = [],
    capacity,
    operating,
    dirty,
    mucking,
    broken,
    powered,
    efficiency,
    time_left,
  } = data;

  const [hovered, setHovered] = useState<string>();
  const [doneUntil, setDoneUntil] = useState(0);
  const wasOperating = usePrevious(!!operating);
  useEffect(() => {
    if (wasOperating && !operating && !broken) {
      setDoneUntil(Date.now() + DONE_TIME);
    }
  }, [operating]);

  const time = useClock(!!operating || !!broken || Date.now() < doneUntil);
  const done = Date.now() < doneUntil;
  // Odliczanie płynnie między aktualizacjami serwera
  const [syncedAt, setSyncedAt] = useState(Date.now());
  useEffect(() => setSyncedAt(Date.now()), [time_left]);
  const left = operating
    ? Math.max(0, time_left - (Date.now() - syncedAt) / 100)
    : 0;

  // Jak w Polonium: w spoczynku drzwiczki są otwarte i rzeczy da się wyjąć
  const doorOpen = !broken && !operating;
  const canTouch = !operating && !broken;
  const hoveredItem = items.find((item) => item.ref === hovered);

  let status = 'PUSTA';
  if (!powered) {
    status = 'BRAK PRĄDU';
  } else if (broken) {
    status = 'AWARIA';
  } else if (mucking) {
    status = 'BRUD!';
  } else if (operating) {
    status = 'PIECZENIE';
  } else if (done) {
    status = 'GOTOWE';
  } else if (dirty >= 100) {
    status = 'BRUDNA';
  } else if (hoveredItem) {
    status = hoveredItem.name.toUpperCase();
  } else if (items.length) {
    status = 'GOTOWA';
  }

  const count = items.length;

  return (
    <PixelDevice width={CANVAS[0]} height={CANVAS[1]} title="Mikrofalówka">
      <Sprite img="microwave-body" x={6} y={0} w={330} h={218} drag />
      {/* Tabliczka z nazwą */}
      <Rect x={16} y={7} w={88} h={13} color="#171717" drag />
      <Rect x={17} y={8} w={86} h={11} color="#363636" drag />
      <PixelText x={21} y={10} color="#c1bab5">
        MIKROFALÓWKA
      </PixelText>
      <PixelKey
        x={319}
        y={7}
        w={11}
        h={12}
        skin="dark"
        text="x"
        textColor="#c1bab5"
        tooltip="Zamknij"
        onClick={closeWindow}
      />

      <Chamber
        items={items}
        operating={!!operating && !!powered}
        broken={!!broken}
        dirty={dirty}
        mucking={!!mucking}
        time={time}
        hovered={hovered}
        canTouch={canTouch}
        onHover={setHovered}
        onTake={(ref) => act('eject_item', { ref })}
      />
      <Door open={doorOpen} broken={!!broken} />

      {/* Wyświetlacz */}
      {!!powered && (
        <>
          <Segments
            x={DISPLAY.x + 4}
            y={DISPLAY.y + 4}
            text={formatClock(left)}
            lit={broken ? '#f05030' : LIT}
            ghost={GHOST}
          />
          <PixelText
            x={DISPLAY.x + 50}
            y={DISPLAY.y + 5}
            w={28}
            align="right"
            color={LIT}
          >
            {`${count}/${capacity}`}
          </PixelText>
          <PixelText
            x={DISPLAY.x + 4}
            y={DISPLAY.y + 23}
            w={74}
            color={broken ? '#f05030' : LIT}
          >
            {status}
          </PixelText>
        </>
      )}

      {/* Moc: lampki według laserów */}
      <PixelText x={240} y={78} color="#a8a8a8">
        MOC
      </PixelText>
      {[1, 2, 3, 4].map((level) => (
        <Rect
          key={level}
          x={262 + level * 7}
          y={78}
          w={5}
          h={5}
          color={powered && efficiency >= level ? LIT : '#645951'}
        />
      ))}
      <Sticker />

      <PixelKey
        x={240}
        y={138}
        w={82}
        h={19}
        skin="green"
        text="START"
        textColor="#ffffff"
        disabled={!powered || !!broken || !!operating || !items.length}
        tooltip="Włącza mikrofalówkę (też prawy przycisk na maszynie)"
        onClick={() => act('start')}
      />
      <PixelKey
        x={240}
        y={160}
        w={82}
        h={26}
        skin="light"
        text="OPRÓŻNIJ"
        textColor="#a3261c"
        disabled={!!operating || !!broken || !items.length}
        tooltip="Wyrzuca całą zawartość na podłogę"
        onClick={() => act('eject')}
      />
      {!!broken && <GrilleSmoke />}

      <PixelNote
        x={342}
        y={22}
        w={96}
        h={124}
        img="microwave-note"
        hovered={hovered}
        onHover={setHovered}
        sections={[
          {
            top: 13,
            heading: 'ZAWARTOŚĆ',
            empty: 'pusto',
            rows: items.map((item) => ({
              key: item.ref,
              text:
                item.amount > 1 ? `${item.amount}× ${item.name}` : item.name,
              title: canTouch ? `${item.name}: kliknij, aby wyjąć` : item.name,
              onClick: canTouch
                ? () => act('eject_item', { ref: item.ref })
                : undefined,
            })),
          },
        ]}
      />
    </PixelDevice>
  );
};

/** Naklejka ostrzegawcza w miejscu klawiszy czasu (u nas czas jest stały). */
const Sticker = () => (
  <>
    <Rect x={240} y={92} w={82} h={36} color="#171717" />
    <Rect x={241} y={93} w={80} h={34} color="#e9c967" />
    <Sprite img="microwave-warning" x={244} y={106} w={9} h={9} />
    <PixelText x={256} y={96} color="#2b2b2b">
      NIE WKŁADAĆ
    </PixelText>
    <PixelText x={256} y={105} color="#2b2b2b">
      ZWIERZĄT
    </PixelText>
    <PixelText x={256} y={114} color="#2b2b2b">
      ANI KART ID
    </PixelText>
  </>
);

type ChamberProps = {
  items: Item[];
  operating: boolean;
  broken: boolean;
  dirty: number;
  mucking: boolean;
  time: number;
  hovered?: string;
  canTouch: boolean;
  onHover: (ref?: string) => void;
  onTake: (ref: string) => void;
};

/** Komora: światło, talerz z obracającą się zawartością, brud. */
const Chamber = (props: ChamberProps) => {
  const {
    items,
    operating,
    broken,
    dirty,
    mucking,
    time,
    hovered,
    canTouch,
    onHover,
    onTake,
  } = props;
  const count = items.length;
  const scale = count <= 6 ? 2 : 1;
  const reach = count <= 1 ? 0 : count <= 6 ? 0.62 : 0.8;
  const spin = operating ? time * SPIN_SPEED : 0;
  const placed = items
    .map((item, index) => {
      const angle = spin + (index / Math.max(1, count)) * Math.PI * 2 + 0.6;
      const cx = PLATE.x + Math.cos(angle) * PLATE.rx * reach;
      const cy = PLATE.y + Math.sin(angle) * PLATE.ry * reach;
      return { item, cx: Math.round(cx), cy: Math.round(cy) };
    })
    .sort((a, b) => a.cy - b.cy);

  // Brud z nieudanego pieczenia: plamy w stałych miejscach
  const stains = useMemo(() => {
    const random = seededRandom(1337);
    return Array.from({ length: 24 }, () => ({
      x: Math.round(random() * (CAVITY.w - 20)) + 4,
      y: Math.round(random() * (CAVITY.h - 20)) + 4,
      size: 3 + Math.round(random() * 9),
    }));
  }, []);
  const dirtShown = Math.ceil((Math.min(100, dirty) / 100) * stains.length);

  return (
    <Px x={CAVITY.x} y={CAVITY.y} w={CAVITY.w} h={CAVITY.h}>
      <Sprite
        img={operating ? 'microwave-chamber_lit' : 'microwave-chamber'}
        x={0}
        y={0}
        w={CAVITY.w}
        h={CAVITY.h}
        style={broken ? { filter: 'brightness(0.35)' } : undefined}
      />
      {stains.slice(0, dirtShown).map((stain, index) => (
        <Rect
          key={index}
          x={stain.x}
          y={stain.y}
          w={stain.size}
          h={Math.max(2, stain.size - 2)}
          color="#5a3d1e"
          style={{ opacity: 0.75, borderRadius: '30%' }}
        />
      ))}
      {placed.map(({ item, cx, cy }) => {
        const lift = hovered === item.ref && canTouch ? 2 : 0;
        return (
          <div key={item.ref}>
            <Sprite
              img="microwave-shadow"
              x={cx - 13}
              y={cy - 4}
              w={26}
              h={8}
            />
            <ItemIcon
              x={cx - 16 * scale}
              y={cy - 26 * scale - lift + 8}
              icon={item.icon}
              scale={scale}
              title={canTouch ? `${item.name}: kliknij, aby wyjąć` : item.name}
              style={{ cursor: canTouch ? 'pointer' : 'default' }}
              onClick={canTouch ? () => onTake(item.ref) : undefined}
              onMouseEnter={() => onHover(item.ref)}
              onMouseLeave={() => onHover(undefined)}
            />
          </div>
        );
      })}
      {mucking && <MuckSplatter />}
      {operating && (
        <Rect
          x={0}
          y={0}
          w={CAVITY.w}
          h={CAVITY.h}
          color="#fff4a0"
          style={{
            opacity: 0.06 + 0.04 * Math.sin(time * 9),
            pointerEvents: 'none',
          }}
        />
      )}
    </Px>
  );
};

/** Drzwiczki: otwarte w spoczynku, zamknięte przy pieczeniu i po awarii. */
const Door = (props: { open: boolean; broken: boolean }) => {
  const { open, broken } = props;
  return (
    <>
      <Sprite
        img="microwave-door"
        x={open ? 5 : 14}
        y={32}
        w={open ? 7 : 214}
        h={172}
        className="MicrowaveDevice__door"
        style={{ opacity: open ? 0 : 1, pointerEvents: 'none' }}
      />
      {open && <Sprite img="microwave-door_open" x={0} y={32} w={12} h={172} />}
      {broken && (
        <Sprite
          img="microwave-cracks"
          x={14}
          y={32}
          w={214}
          h={172}
          style={{ pointerEvents: 'none' }}
        />
      )}
    </>
  );
};

const MuckSplatter = () => {
  const particles = useMemo(() => {
    const random = seededRandom(42);
    const list: Particle[] = [];
    for (let i = 0; i < 40; i++) {
      list.push({
        x: PLATE.x + (random() - 0.5) * 40,
        y: PLATE.y - 20 + (random() - 0.5) * 20,
        size: 2 + Math.round(random() * 3),
        color: random() > 0.5 ? '#5a3d1e' : '#7a5a2a',
        dx: (random() - 0.5) * 180,
        dy: (random() - 0.7) * 120,
        life: 0.6 + random() * 0.5,
        delay: random() * 3,
      });
    }
    return list;
  }, []);
  return <Particles particles={particles} loop />;
};

/** Dym z kratki po awarii. */
const GrilleSmoke = () => {
  const particles = useMemo(() => {
    const random = seededRandom(7);
    const colors = ['#141210', '#24201d', '#34302c'];
    const list: Particle[] = [];
    for (let i = 0; i < 26; i++) {
      list.push({
        x: 244 + random() * 70,
        y: 190,
        size: 3 + Math.round(random() * 4),
        color: colors[Math.floor(random() * colors.length)],
        dx: (random() - 0.5) * 20,
        dy: -40 - random() * 60,
        life: 1.4 + random() * 1.2,
        delay: random() * 2.5,
      });
    }
    return list;
  }, []);
  return <Particles particles={particles} loop />;
};
