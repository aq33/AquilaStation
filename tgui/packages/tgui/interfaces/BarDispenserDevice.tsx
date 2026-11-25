/**
 * Okno dozownika napojów i dozownika alkoholi w formie urządzenia.
 * Port pomysłu z Polonium Station (polonium14/polonium-station#1301),
 * dopasowany do naszych dozowników: napoje biorą się z energii maszyny,
 * więc zamiast pojemników w magazynie są klawisze (i butelki na półce
 * w dozowniku alkoholi), a receptury zostają w starym oknie (KLASYCZNE).
 */

import { CSSProperties, useEffect, useMemo, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  AtlasSprite,
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
  RoundKey,
  seededRandom,
  useClock,
} from './PixelUi';

type Chemical = { title: string; id: string; color?: string };
type BeakerReagent = { name: string; volume: number };

type Data = {
  amount: number;
  energy: number;
  maxEnergy: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: BeakerReagent[];
  beakerCurrentVolume: number | null;
  beakerMaxVolume: number | null;
  beakerTransferAmounts: number[] | null;
  chemicals: Chemical[];
  hasBeakerInHand: BooleanLike;
  kinds: Record<string, 'liquid' | 'ice' | 'grains' | 'fizzy'>;
  bottles: BooleanLike;
  powered: BooleanLike;
  beakerName?: string;
  beakerIcon?: string;
  beakerColor?: string;
  beakerColors: Record<string, string>;
  recordingRecipe?: Record<string, number> | null;
};

type Skin = { body: string; light: string; bright: string; dark: string };

const SODA: Skin = {
  body: '#41617d',
  light: '#5d83a3',
  bright: '#8db4d4',
  dark: '#2a4157',
};
const BOOZE: Skin = {
  body: '#5e3f2a',
  light: '#80583c',
  bright: '#a8805c',
  dark: '#3b2619',
};
const INK = '#0c0c0c';
const AMBER = '#ffb000';
const LAMP_GREEN = '#44ff00';
const ATLAS: [number, number] = [80, 19];

const LEFT = 4;
const WIDTH = 266;
const TOP = 2;
const SHELF = 31;
const RAIL = 6;
const LID = 13;
const KEY_W = 82;
const KEY_H = 12;
const COLUMNS = 3;
const PITCH_X = 84;
const PITCH_Y = 12;
const MAX_ROWS = 9;
const BAND = 76;
const BAY_W = 78;
const BAY_H = 68;
const SIDE = (WIDTH - BAY_W) / 4;
const DOSE_AXIS = LEFT + SIDE;
const ROUND_AXIS = LEFT + WIDTH - SIDE;
const NOTE_LEFT = LEFT + WIDTH + 6;
const NOTE_W = 110;
const NOTE_H = 120;
const POUR_TIME = 900;

type Pour = { color: string; kind: string; at: number };

export const BarDispenserDevice = () => {
  const { act, data } = useBackend<Data>();
  const {
    amount,
    energy,
    maxEnergy,
    isBeakerLoaded,
    beakerContents = [],
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerTransferAmounts,
    chemicals = [],
    hasBeakerInHand,
    kinds = {},
    bottles,
    powered,
    beakerName,
    beakerIcon,
    beakerColor,
    beakerColors = {},
  } = data;
  const skin = bottles ? BOOZE : SODA;
  const [scroll, setScroll] = useState(0);
  const [pointed, setPointed] = useState<string>();
  const [pour, setPour] = useState<Pour>();
  const [drainAt, setDrainAt] = useState(0);
  // Odświeżanie, póki leci strumień albo naczynie się przechyla
  useClock(
    (!!pour && Date.now() - pour.at < POUR_TIME) ||
      Date.now() - drainAt < POUR_TIME,
  );
  const now = Date.now();
  const pouring = pour && now - pour.at < POUR_TIME ? pour : undefined;
  const draining = now - drainAt < POUR_TIME;

  const rowsTotal = Math.ceil(chemicals.length / COLUMNS);
  const rowsShown = Math.min(MAX_ROWS, Math.max(1, rowsTotal));
  const maxScroll = Math.max(0, rowsTotal - rowsShown);
  const shown = Math.min(scroll, maxScroll);

  const panelTop = TOP + (bottles ? SHELF + RAIL : LID);
  const panelH = rowsShown * PITCH_Y + 8;
  const band = panelTop + panelH;
  const bottom = band + BAND;
  const canvasW = NOTE_LEFT + NOTE_W + 4;
  const canvasH = Math.max(bottom + 4, NOTE_H + 8);

  // Nagrywanie receptury (ze starego okna): dawka trafia do receptury, nie do naczynia
  const recording = !!data.recordingRecipe;
  const full =
    !!beakerMaxVolume && (beakerCurrentVolume ?? 0) >= beakerMaxVolume;
  const dispense = (chemical: Chemical) => {
    if (!isBeakerLoaded && !recording) {
      return;
    }
    // Strumień dopiero, gdy serwer naprawdę doleje (energia, pełne naczynie, nagrywanie receptury)
    if (!recording && !full && energy > 0) {
      setPending({
        color: chemical.color || '#c8a060',
        kind: kinds[chemical.id] || 'liquid',
        before: beakerCurrentVolume ?? 0,
        vessel: beakerName,
        at: Date.now(),
      });
    }
    act('dispense', { reagent: chemical.id });
  };
  const [pending, setPending] = useState<
    Pour & { before: number; vessel?: string }
  >();
  useEffect(() => {
    if (!pending) {
      return;
    }
    // Najpierw wygaśnięcie i zmiana naczynia: późniejszy wzrost objętości nie należy do tego kliknięcia
    if (Date.now() - pending.at > 1500 || pending.vessel !== beakerName) {
      setPending(undefined);
      return;
    }
    if ((beakerCurrentVolume ?? 0) > pending.before) {
      setPour({ color: pending.color, kind: pending.kind, at: Date.now() });
      setPending(undefined);
    }
  }, [beakerCurrentVolume, beakerName, pending]);
  // Oczekiwanie wygasa też bez nowych danych z serwera
  useEffect(() => {
    if (!pending) {
      return;
    }
    const timer = setTimeout(() => setPending(undefined), 1500);
    return () => clearTimeout(timer);
  }, [pending]);

  const vesselTitle = beakerName || 'Naczynie';
  const amounts = beakerTransferAmounts?.length
    ? beakerTransferAmounts.slice(0, 9)
    : [5, 10, 15, 20, 25, 30];
  const fill =
    beakerMaxVolume && beakerCurrentVolume
      ? beakerCurrentVolume / beakerMaxVolume
      : 0;

  return (
    <PixelDevice
      width={canvasW}
      height={canvasH}
      title={bottles ? 'Dozownik alkoholi' : 'Dozownik napojów'}
    >
      {bottles ? (
        <Shelf
          chemicals={chemicals}
          skin={skin}
          pointed={pointed}
          enabled={(!!isBeakerLoaded || recording) && !!powered}
          onPoint={setPointed}
          onPour={dispense}
        />
      ) : (
        <>
          <Rect x={LEFT} y={TOP} w={WIDTH} h={LID} color={INK} drag />
          <Rect
            x={LEFT + 1}
            y={TOP + 1}
            w={WIDTH - 2}
            h={LID - 1}
            color={skin.light}
            drag
          />
          <Rect
            x={LEFT + 1}
            y={TOP + 1}
            w={WIDTH - 2}
            h={1}
            color={skin.bright}
          />
          <Rect
            x={LEFT + 1}
            y={TOP + LID - 2}
            w={WIDTH - 2}
            h={1}
            color={skin.body}
          />
        </>
      )}

      {/* Korpus z klawiszami napojów */}
      <Rect
        x={LEFT}
        y={panelTop}
        w={WIDTH}
        h={bottom - panelTop}
        color={INK}
        drag
      />
      <Rect
        x={LEFT + 1}
        y={panelTop}
        w={WIDTH - 2}
        h={bottom - panelTop - 1}
        color={skin.body}
        drag
      />
      <Rect
        x={LEFT + 5}
        y={panelTop + 2}
        w={WIDTH - 10}
        h={panelH - 4}
        color={skin.dark}
        drag
      />
      <div
        onWheel={(event) => {
          if (maxScroll <= 0) {
            return;
          }
          setScroll(
            Math.max(
              0,
              Math.min(maxScroll, shown + (event.deltaY > 0 ? 1 : -1)),
            ),
          );
        }}
      >
        {chemicals.map((chemical, index) => {
          const row = Math.floor(index / COLUMNS) - shown;
          if (row < 0 || row >= rowsShown) {
            return null;
          }
          return (
            <DrinkKey
              key={chemical.id + index}
              x={LEFT + 8 + (index % COLUMNS) * PITCH_X}
              y={panelTop + 4 + row * PITCH_Y}
              chemical={chemical}
              highlighted={pointed === chemical.id}
              disabled={(!isBeakerLoaded && !recording) || !powered}
              onPoint={setPointed}
              onPour={() => dispense(chemical)}
            />
          );
        })}
      </div>
      {maxScroll > 0 && (
        <Rect
          x={LEFT + WIDTH - 5}
          y={panelTop + 3 + Math.round((shown / rowsTotal) * (panelH - 6))}
          w={2}
          h={Math.max(4, Math.round((rowsShown / rowsTotal) * (panelH - 6)))}
          color={skin.bright}
        />
      )}

      {/* Pas z naczyniem, dawkami i klawiszami okrągłymi */}
      <Rect x={LEFT + 1} y={band} w={WIDTH - 2} h={1} color={skin.light} />
      <PixelText x={DOSE_AXIS - 26} y={band + 8} color="#f2f2f2">
        DAWKA
      </PixelText>
      {amounts.map((dose, index) => {
        const chosen = dose === amount;
        return (
          <PixelKey
            key={dose}
            x={DOSE_AXIS - 26 + (index % 3) * 18}
            y={band + 21 + Math.floor(index / 3) * 13}
            w={17}
            h={12}
            skin="dark"
            latched={chosen}
            text={String(dose)}
            textColor={chosen ? LAMP_GREEN : '#f2f2f2'}
            disabled={!isBeakerLoaded}
            tooltip={`Dawka ${dose} j.`}
            onClick={() => act('amount', { target: dose })}
          />
        );
      })}
      <EnergyGauge
        x={DOSE_AXIS - 26}
        y={band + 62}
        energy={energy}
        max={maxEnergy}
      />

      <Bay
        x={LEFT + (WIDTH - BAY_W) / 2}
        y={band + 4}
        loaded={!!isBeakerLoaded}
        name={beakerName}
        icon={beakerIcon}
        color={beakerColor}
        fill={fill}
        pour={pouring}
        draining={draining}
        canInsert={!!hasBeakerInHand}
        onTake={() => act('eject')}
        onInsert={() => act('insert')}
      />

      <PixelText
        x={ROUND_AXIS - 30}
        y={band + 6}
        w={60}
        align="center"
        color="#f2f2f2"
      >
        {!powered
          ? 'BRAK PRĄDU'
          : recording
            ? 'NAGRYWANIE'
            : full
              ? 'PEŁNE'
              : 'GOTOWY'}
      </PixelText>
      <BarRoundKey
        x={ROUND_AXIS - 18}
        y={band + 22}
        icon={[40, 0, 9, 9]}
        tooltip="Wylej całą zawartość naczynia"
        disabled={!beakerCurrentVolume || !powered}
        onClick={() => {
          setDrainAt(Date.now());
          act('drain');
        }}
      />
      <BarRoundKey
        x={ROUND_AXIS + 18}
        y={band + 22}
        icon={[50, 0, 9, 9]}
        tooltip="Wyjmij naczynie"
        disabled={!isBeakerLoaded}
        onClick={() => act('eject')}
      />
      <Caption x={ROUND_AXIS - 18} y={band + 34} text="WYLEJ" />
      <Caption x={ROUND_AXIS + 18} y={band + 34} text="WYJMIJ" />
      <BarRoundKey
        x={ROUND_AXIS - 18}
        y={band + 52}
        icon={[60, 0, 11, 8]}
        tooltip="Stare okno z recepturami"
        onClick={() => act('classic')}
      />
      <BarRoundKey
        x={ROUND_AXIS + 18}
        y={band + 52}
        icon={[72, 0, 7, 7]}
        tooltip="Zamknij"
        onClick={closeWindow}
      />
      <Caption x={ROUND_AXIS - 18} y={band + 64} text="STARE" />
      <Caption x={ROUND_AXIS + 18} y={band + 64} text="ZAMKNIJ" />

      <PixelNote
        x={NOTE_LEFT}
        y={4}
        w={NOTE_W}
        h={NOTE_H}
        img="bardispenser-note"
        sections={[
          {
            top: 15,
            heading: isBeakerLoaded ? (
              <>
                <span>{vesselTitle}</span>
                {` ${beakerCurrentVolume ?? 0}/${beakerMaxVolume ?? 0}`}
              </>
            ) : (
              'BRAK NACZYNIA'
            ),
            empty: isBeakerLoaded ? 'puste' : undefined,
            rows: beakerContents.map((reagent) => ({
              key: reagent.name,
              text: `${reagent.volume} j. ${reagent.name}`,
              swatch: beakerColors[reagent.name],
            })),
          },
        ]}
      />
    </PixelDevice>
  );
};

const Caption = (props: { x: number; y: number; text: string }) => (
  <PixelText x={props.x - 20} y={props.y} w={40} align="center" color="#f2f2f2">
    {props.text}
  </PixelText>
);

/** Okrągły klawisz 19x19 z atlasu controls.png, x/y to środek. */
const BarRoundKey = (props: {
  x: number;
  y: number;
  icon: [number, number, number, number];
  tooltip: string;
  disabled?: boolean;
  onClick: () => void;
}) => {
  const { x, y, icon, tooltip, disabled, onClick } = props;
  return (
    <RoundKey
      x={x - 9}
      y={y - 9}
      size={19}
      img="bardispenser-controls"
      atlas={ATLAS}
      up={[0, 0]}
      down={[20, 0]}
      disabled={disabled}
      tooltip={tooltip}
      onClick={onClick}
    >
      <AtlasSprite
        img="bardispenser-controls"
        atlas={ATLAS}
        at={[icon[0], icon[1]]}
        x={Math.floor((19 - icon[2]) / 2)}
        y={Math.floor((19 - icon[3]) / 2)}
        w={icon[2]}
        h={icon[3]}
      />
    </RoundKey>
  );
};

const DrinkKey = (props: {
  x: number;
  y: number;
  chemical: Chemical;
  highlighted: boolean;
  disabled: boolean;
  onPoint: (id?: string) => void;
  onPour: () => void;
}) => {
  const { x, y, chemical, highlighted, disabled, onPoint, onPour } = props;
  return (
    <div
      onMouseEnter={() => onPoint(chemical.id)}
      onMouseLeave={() => onPoint(undefined)}
    >
      <PixelKey
        x={x}
        y={y}
        w={KEY_W}
        h={KEY_H}
        skin="dark"
        disabled={disabled}
        tooltip={
          disabled
            ? `${chemical.title}: najpierw wstaw naczynie`
            : `${chemical.title}: nalej`
        }
        onClick={onPour}
      >
        <span
          className="BarDispenserDevice__swatch"
          style={{ background: chemical.color || '#888888' }}
        />
        <span
          className="BarDispenserDevice__drink"
          style={{ color: highlighted ? AMBER : '#f2f2f2' }}
        >
          {chemical.title}
        </span>
      </PixelKey>
    </div>
  );
};

/** Półka z butelkami (dozownik alkoholi): kliknięcie butelki nalewa. */
const Shelf = (props: {
  chemicals: Chemical[];
  skin: Skin;
  pointed?: string;
  enabled: boolean;
  onPoint: (id?: string) => void;
  onPour: (chemical: Chemical) => void;
}) => {
  const { chemicals, skin, pointed, enabled, onPoint, onPour } = props;
  const count = Math.max(1, chemicals.length);
  const pitch = (WIDTH - 12) / count;
  return (
    <>
      <Rect x={LEFT} y={TOP + SHELF} w={WIDTH} h={RAIL} color={INK} drag />
      <Rect
        x={LEFT + 1}
        y={TOP + SHELF + 1}
        w={WIDTH - 2}
        h={RAIL - 2}
        color={skin.light}
        drag
      />
      {chemicals.map((chemical, index) => {
        const axis = Math.round(LEFT + 6 + pitch * index + pitch / 2);
        const lifted = pointed === chemical.id ? 2 : 0;
        const color = chemical.color || '#888888';
        const tall = 18 + (index % 3) * 2;
        const style: CSSProperties = {
          cursor: enabled ? 'pointer' : 'default',
        };
        return (
          <Px
            key={chemical.id + index}
            x={axis - 4}
            y={TOP + SHELF - tall - 6 - lifted}
            w={9}
            h={tall + 6}
            style={style}
            title={chemical.title}
            onClick={enabled ? () => onPour(chemical) : undefined}
            onMouseEnter={() => onPoint(chemical.id)}
            onMouseLeave={() => onPoint(undefined)}
          >
            {/* szyjka z kapslem */}
            <Rect x={3} y={0} w={3} h={2} color="#c8a040" />
            <Rect x={3} y={2} w={3} h={6} color={INK} />
            <Rect
              x={4}
              y={2}
              w={1}
              h={6}
              color={color}
              style={{ opacity: 0.8 }}
            />
            {/* butelka */}
            <Rect x={0} y={8} w={9} h={tall - 2} color={INK} />
            <Rect x={1} y={9} w={7} h={tall - 4} color={color} />
            <Rect
              x={2}
              y={10}
              w={1}
              h={tall - 8}
              color="#ffffff"
              style={{ opacity: 0.35 }}
            />
            <Rect
              x={1}
              y={13}
              w={7}
              h={5}
              color="#e9e3cf"
              style={{ opacity: 0.85 }}
            />
          </Px>
        );
      })}
    </>
  );
};

const EnergyGauge = (props: {
  x: number;
  y: number;
  energy: number;
  max: number;
}) => {
  const { x, y, energy, max } = props;
  const marks = 17;
  const lit = max ? Math.round((energy / max) * marks) : 0;
  return (
    <Px
      x={x}
      y={y}
      w={marks * 3}
      h={4}
      title={`Energia: ${Math.round(energy)}/${Math.round(max)}`}
    >
      {Array.from({ length: marks }, (_, index) => (
        <Rect
          key={index}
          x={index * 3}
          y={0}
          w={2}
          h={3}
          color={index < lit ? AMBER : '#3a2a10'}
        />
      ))}
    </Px>
  );
};

/** Wnęka pod dyszą: naczynie, strumień, lód, cukier, bąbelki, wylewanie. */
const Bay = (props: {
  x: number;
  y: number;
  loaded: boolean;
  name?: string;
  icon?: string;
  color?: string;
  fill: number;
  pour?: Pour;
  draining: boolean;
  canInsert: boolean;
  onTake: () => void;
  onInsert: () => void;
}) => {
  const {
    x,
    y,
    loaded,
    name,
    icon,
    color,
    fill,
    pour,
    draining,
    canInsert,
    onTake,
    onInsert,
  } = props;
  const nozzle = BAY_W / 2;
  return (
    <Px x={x} y={y} w={BAY_W} h={BAY_H}>
      <Rect x={0} y={0} w={BAY_W} h={BAY_H} color={INK} />
      <Rect x={1} y={1} w={BAY_W - 2} h={BAY_H - 2} color="#1b1d22" />
      {/* kratka ociekowa */}
      {Array.from({ length: 9 }, (_, index) => (
        <Rect
          key={index}
          x={6 + index * 7}
          y={BAY_H - 6}
          w={5}
          h={2}
          color="#3a3d45"
        />
      ))}
      <Rect x={nozzle - 4} y={1} w={8} h={5} color="#6a6d75" />
      <Rect x={nozzle - 2} y={6} w={4} h={3} color="#45474e" />
      {!!pour && loaded && <Stream pour={pour} nozzle={nozzle} />}
      {loaded ? (
        <ItemIcon
          x={nozzle - 32}
          y={BAY_H - 64}
          icon={icon}
          scale={2}
          className={draining ? 'BarDispenserDevice__drain' : undefined}
          title={`${name}: kliknij, aby wyjąć`}
          style={{ cursor: 'pointer' }}
          onClick={onTake}
        />
      ) : (
        <Px
          x={0}
          y={10}
          w={BAY_W}
          h={BAY_H - 10}
          title={canInsert ? 'Wstaw naczynie z ręki' : 'Miejsce na naczynie'}
          style={{ cursor: canInsert ? 'pointer' : 'default' }}
          onClick={canInsert ? onInsert : undefined}
        />
      )}
      {loaded && (
        <>
          <Rect x={BAY_W - 8} y={20} w={4} h={38} color={INK} />
          <Rect
            x={BAY_W - 7}
            y={57 - Math.round(36 * fill)}
            w={2}
            h={Math.round(36 * fill)}
            color={color || '#3a5a7a'}
          />
        </>
      )}
    </Px>
  );
};

const Stream = (props: { pour: Pour; nozzle: number }) => {
  const { pour, nozzle } = props;
  const particles = useMemo(() => {
    const random = seededRandom(Math.floor(pour.at) % 100000);
    const list: Particle[] = [];
    if (pour.kind === 'ice') {
      for (let i = 0; i < 6; i++) {
        list.push({
          x: nozzle - 2 + (random() - 0.5) * 4,
          y: 9,
          size: 4,
          color: '#d8f0ff',
          dx: (random() - 0.5) * 6,
          dy: 30,
          life: 0.35,
          delay: i * 0.1,
        });
      }
    } else if (pour.kind === 'grains') {
      for (let i = 0; i < 24; i++) {
        list.push({
          x: nozzle - 1 + (random() - 0.5) * 3,
          y: 9,
          size: 1,
          color: '#ffffff',
          dx: (random() - 0.5) * 6,
          dy: 30,
          life: 0.3,
          delay: random() * 0.6,
        });
      }
    } else if (pour.kind === 'fizzy') {
      for (let i = 0; i < 14; i++) {
        list.push({
          x: nozzle - 1 + (random() - 0.5) * 2,
          y: 30,
          size: 1,
          color: '#ffffff',
          dx: (random() - 0.5) * 2,
          dy: -18,
          life: 0.4,
          delay: random() * 0.6,
        });
      }
    }
    return list;
  }, [pour.at]);
  return (
    <>
      {pour.kind !== 'ice' && pour.kind !== 'grains' && (
        <Rect
          x={nozzle - 1}
          y={9}
          w={2}
          h={28}
          color={pour.color}
          className="BarDispenserDevice__stream"
        />
      )}
      <Particles particles={particles} />
    </>
  );
};
