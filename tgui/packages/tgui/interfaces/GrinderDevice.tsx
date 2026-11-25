/**
 * Okno młynka w formie urządzenia.
 * Port pomysłu z Polonium Station (polonium14/polonium-station#1287),
 * dopasowany do naszego młynka: produkty leżą w dzbanku, odczynniki trafiają
 * od razu do naczynia w niszy, zamiast pokrętła AUTO jest klawisz MIESZAJ.
 */

import { useMemo, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  AtlasSprite,
  closeWindow,
  ItemIcon,
  NoteRow,
  Particle,
  Particles,
  PixelDevice,
  PixelNote,
  PixelText,
  Px,
  Rect,
  RoundKey,
  seededRandom,
  Sprite,
  useClock,
} from './PixelUi';

type Item = {
  ref: string;
  name: string;
  icon?: string;
  grind: BooleanLike;
  juice: BooleanLike;
};

type Reagent = { name: string; volume: number; color: string };

type Vessel = {
  name: string;
  icon?: string;
  volume: number;
  max: number;
  color?: string;
  reagents: Reagent[];
};

type Data = {
  items: Item[];
  limit: number;
  operating: BooleanLike;
  operation?: 'grind' | 'juice' | 'mix';
  time_left: number;
  powered: BooleanLike;
  broken: BooleanLike;
  speed: number;
  vessel?: Vessel;
  holding?: string;
  silicon: BooleanLike;
};

const CANVAS: [number, number] = [340, 304];
const ATLAS: [number, number] = [140, 61];
const GLASS = { x: 38, y: 50, w: 140, floor: 100 };
const SPOUT = { x: 108, bottom: 232 };
const TRAY_TOP = 280;
const KEY_ROW = 187;
const DARK_PRINT = '#262626';
// Miejsca na produkty w dzbanku: x od lewej ścianki szkła, poziom (warstwa) od dna
const REST_SPOTS: [number, number][] = [
  [38, 0],
  [70, 0],
  [102, 0],
  [54, 1],
  [86, 1],
  [70, 2],
];
const LEVEL_HEIGHT = 17;

export const GrinderDevice = () => {
  const { act, data } = useBackend<Data>();
  const {
    items = [],
    limit,
    operating,
    operation,
    powered,
    broken,
    vessel,
    holding,
    silicon,
  } = data;
  const [hovered, setHovered] = useState<string>();
  const time = useClock(!!operating);
  const idle = !operating && !!powered && !broken;
  const canReach = !silicon;

  const lamp: [number, number] = broken
    ? [100, 28]
    : powered
      ? operating
        ? [90, 28]
        : [80, 28]
      : [80, 28];

  const shake =
    operating && operation === 'grind'
      ? { transform: `translate(${Math.round(Math.sin(time * 60) * 2)}px, 0)` }
      : undefined;

  const noteRows: NoteRow[] = items.map((item) => ({
    key: item.ref,
    text: item.name,
    title: canReach && idle ? `${item.name}: kliknij, aby wyjąć` : item.name,
    onClick:
      canReach && idle ? () => act('eject_item', { ref: item.ref }) : undefined,
  }));
  const vesselRows: NoteRow[] = (vessel?.reagents || []).map((reagent) => ({
    key: `r-${reagent.name}`,
    text: `${reagent.volume} j. ${reagent.name}`,
    swatch: reagent.color,
  }));

  return (
    <PixelDevice width={CANVAS[0]} height={CANVAS[1]} title="Młynek">
      {/* Dzbanek z pokrywką */}
      <Sprite img="grinder-lid" x={30} y={operating ? 26 : 22} w={156} h={21} />
      <Sprite img="grinder-jug" x={26} y={45} w={180} h={113} drag />
      <Px
        x={GLASS.x}
        y={GLASS.y}
        w={GLASS.w}
        h={GLASS.floor}
        style={{
          cursor: holding && idle && canReach ? 'pointer' : 'default',
          ...shake,
        }}
        title={holding && idle && canReach ? `Wrzuć: ${holding}` : 'Dzbanek'}
        onClick={holding && idle && canReach ? () => act('insert') : undefined}
      >
        {items.map((item, index) => {
          const spot = REST_SPOTS[index];
          const small = !spot;
          const x = spot ? spot[0] : 8 + ((index - 6) % 4) * 30;
          const level = spot ? spot[1] : 3 + Math.floor((index - 6) / 4);
          const scale = small ? 1 : 2;
          const lift = hovered === item.ref && idle ? 2 : 0;
          const bob =
            operating && operation !== 'mix'
              ? Math.round(Math.sin(time * 25 + index * 1.7) * 3)
              : 0;
          return (
            <ItemIcon
              key={item.ref}
              x={x - 16 * scale + 16}
              y={GLASS.floor - level * LEVEL_HEIGHT - 26 * scale - lift + bob}
              icon={item.icon}
              scale={scale}
              title={
                canReach && idle
                  ? `${item.name}: kliknij, aby wyjąć`
                  : item.name
              }
              style={{ cursor: canReach && idle ? 'pointer' : 'default' }}
              onClick={
                canReach && idle
                  ? () => act('eject_item', { ref: item.ref })
                  : undefined
              }
              onMouseEnter={() => setHovered(item.ref)}
              onMouseLeave={() => setHovered(undefined)}
            />
          );
        })}
        {!!operating && operation !== 'mix' && <Crumbs />}
      </Px>
      <Sprite
        img="grinder-glass"
        x={GLASS.x}
        y={GLASS.y}
        w={140}
        h={100}
        style={{ pointerEvents: 'none' }}
      />
      <Sprite
        img="grinder-blades"
        x={74}
        y={144}
        w={68}
        h={7}
        className={operating ? 'GrinderDevice__blades--spin' : undefined}
      />
      <Sprite img="grinder-hub" x={98} y={144} w={20} h={7} />

      {/* Korpus z niszą na naczynie */}
      <Sprite img="grinder-body" x={5} y={157} w={206} h={138} drag />
      <Niche
        vessel={vessel}
        operating={!!operating}
        operation={operation}
        canReach={canReach && idle}
        holding={holding}
        onTake={() => act('eject_beaker')}
        onInsert={() => act('insert')}
      />
      <AtlasSprite
        img="grinder-controls"
        atlas={ATLAS}
        at={lamp}
        x={104}
        y={183}
        w={9}
        h={9}
        title={broken ? 'Awaria' : powered ? 'Zasilanie' : 'Brak zasilania'}
      />

      <RoundKey
        x={42 - 10}
        y={KEY_ROW - 10}
        size={21}
        img="grinder-controls"
        atlas={ATLAS}
        up={[0, 28]}
        down={[22, 28]}
        latched={!!operating && operation === 'mix'}
        disabled={!idle || !vessel?.volume}
        tooltip="Mieszanie zawartości naczynia (masło z mleka, majonez z żółtek)"
        onClick={() => act('mix')}
      >
        <Rect x={6} y={6} w={9} h={1} color="#f2f2f2" />
        <Rect x={6} y={9} w={9} h={1} color="#f2f2f2" />
        <Rect x={6} y={12} w={9} h={1} color="#f2f2f2" />
      </RoundKey>
      <Caption x={42} text="MIESZAJ" />
      <RoundKey
        x={81 - 12}
        y={KEY_ROW - 12}
        size={25}
        img="grinder-controls"
        atlas={ATLAS}
        up={[84, 0]}
        down={[110, 0]}
        latched={!!operating && operation === 'grind'}
        disabled={!idle || !items.length || !vessel}
        tooltip="Mieli produkty z dzbanka do naczynia"
        onClick={() => act('grind')}
      >
        <AtlasSprite
          img="grinder-controls"
          atlas={ATLAS}
          at={[110, 28]}
          x={7}
          y={7}
          w={11}
          h={11}
        />
      </RoundKey>
      <Caption x={81} text="MIEL" />
      <RoundKey
        x={135 - 12}
        y={KEY_ROW - 12}
        size={25}
        img="grinder-controls"
        atlas={ATLAS}
        up={[84, 0]}
        down={[110, 0]}
        latched={!!operating && operation === 'juice'}
        disabled={!idle || !items.length || !vessel}
        tooltip="Wyciska sok z produktów do naczynia"
        onClick={() => act('juice')}
      >
        <AtlasSprite
          img="grinder-controls"
          atlas={ATLAS}
          at={[122, 28]}
          x={8}
          y={7}
          w={9}
          h={11}
        />
      </RoundKey>
      <Caption x={135} text="WYCIŚNIJ" />
      <RoundKey
        x={174 - 10}
        y={KEY_ROW - 10}
        size={21}
        img="grinder-controls"
        atlas={ATLAS}
        up={[0, 28]}
        down={[22, 28]}
        disabled={!!operating || (!items.length && !vessel)}
        tooltip="Wyrzuca produkty i oddaje naczynie"
        onClick={() => act('eject')}
      >
        <AtlasSprite
          img="grinder-controls"
          atlas={ATLAS}
          at={[12, 50]}
          x={6}
          y={6}
          w={9}
          h={9}
        />
      </RoundKey>
      <Caption x={174} text="WYJMIJ" />

      <RoundKey
        x={198}
        y={6}
        size={17}
        img="grinder-controls"
        atlas={ATLAS}
        up={[44, 28]}
        down={[62, 28]}
        tooltip="Zamknij"
        onClick={closeWindow}
      >
        <AtlasSprite
          img="grinder-controls"
          atlas={ATLAS}
          at={[22, 50]}
          x={5}
          y={5}
          w={7}
          h={7}
        />
      </RoundKey>

      <PixelNote
        x={224}
        y={28}
        w={112}
        h={200}
        img="grinder-note"
        hovered={hovered}
        onHover={setHovered}
        sections={[
          {
            top: 13,
            heading: `DZBANEK ${items.length}/${limit}`,
            empty: 'pusto',
            maxRows: 7,
            rows: noteRows,
          },
          {
            top: 92,
            heading: vessel
              ? `NACZYNIE ${vessel.volume}/${vessel.max} j.`
              : 'BRAK NACZYNIA',
            empty: vessel ? 'puste' : undefined,
            maxRows: 10,
            rows: vesselRows,
          },
        ]}
      />
    </PixelDevice>
  );
};

const Caption = (props: { x: number; text: string }) => (
  <PixelText x={props.x - 30} y={203} w={60} align="center" color={DARK_PRINT}>
    {props.text}
  </PixelText>
);

/** Nisza pod dyszą: naczynie i strumień masy. */
const Niche = (props: {
  vessel?: Vessel;
  operating: boolean;
  operation?: string;
  canReach: boolean;
  holding?: string;
  onTake: () => void;
  onInsert: () => void;
}) => {
  const { vessel, operating, operation, canReach, holding, onTake, onInsert } =
    props;
  const color = vessel?.color || '#c8a060';
  const flowing = operating && operation !== 'mix' && !!vessel;
  if (!vessel) {
    return (
      <Px
        x={SPOUT.x - 30}
        y={SPOUT.bottom}
        w={60}
        h={TRAY_TOP - SPOUT.bottom}
        title={
          canReach && holding ? `Wstaw: ${holding}` : 'Miejsce na naczynie'
        }
        style={{ cursor: canReach && holding ? 'pointer' : 'default' }}
        onClick={canReach && holding ? onInsert : undefined}
      />
    );
  }
  const fill = vessel.max ? vessel.volume / vessel.max : 0;
  return (
    <>
      {flowing && (
        <Rect
          x={SPOUT.x - 1}
          y={SPOUT.bottom}
          w={3}
          h={TRAY_TOP - SPOUT.bottom - 34}
          color={color}
          className="GrinderDevice__stream"
        />
      )}
      <ItemIcon
        x={SPOUT.x - 32}
        y={TRAY_TOP - 62}
        icon={vessel.icon}
        scale={2}
        title={canReach ? `${vessel.name}: kliknij, aby wyjąć` : vessel.name}
        style={{ cursor: canReach ? 'pointer' : 'default' }}
        onClick={canReach ? onTake : undefined}
      />
      {/* Poziom w naczyniu */}
      <Rect x={SPOUT.x + 34} y={TRAY_TOP - 40} w={4} h={36} color="#171717" />
      <Rect
        x={SPOUT.x + 35}
        y={TRAY_TOP - 5 - Math.round(34 * fill)}
        w={2}
        h={Math.round(34 * fill)}
        color={color}
      />
    </>
  );
};

/** Okruchy i krople latające w dzbanku przy mieleniu. */
const Crumbs = () => {
  const particles = useMemo(() => {
    const random = seededRandom(99);
    const list: Particle[] = [];
    for (let i = 0; i < 30; i++) {
      list.push({
        x: 20 + random() * 100,
        y: 80 + random() * 15,
        size: 1 + Math.round(random() * 2),
        color: random() > 0.5 ? '#d8c090' : '#a07848',
        dx: (random() - 0.5) * 60,
        dy: -20 - random() * 50,
        life: 0.4 + random() * 0.4,
        delay: random() * 0.8,
      });
    }
    return list;
  }, []);
  return <Particles particles={particles} loop />;
};
