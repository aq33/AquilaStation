/**
 * AQUILA: okno kanistra w wyglądzie przeniesionym z Unitystation (prefab TabCanister).
 * Układ jest w common/CanisterLayout.ts, grafiki w aquila/icons/ui/canister
 * (Unitystation, CC BY-SA 3.0). Ruchome elementy podmieniamy po ścieżce obiektu z prefabu.
 */
import type { CSSProperties, ReactNode } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  CANISTER_H,
  CANISTER_LAYOUT,
  CANISTER_W,
  type LayoutItem,
} from './common/CanisterLayout';

type HoldingTank = {
  name: string;
  tankPressure: number;
};

type Data = {
  portConnected: BooleanLike;
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  valveOpen: BooleanLike;
  isPrototype: BooleanLike;
  restricted?: BooleanLike;
  hasHoldingTank: BooleanLike;
  holdingTank?: HoldingTank;
  /** AQUILA: kolor obudowy i nazwa na etykiecie */
  canisterColor?: string;
  canisterName?: string;
};

const FONT = 'Verdana, Geneva, sans-serif';

/** Miejsca cyfr licznika bębnowego (nazwy obiektów w prefabie) */
const PLACES: Record<string, number> = {
  '100k': 5,
  '10k': 4,
  '1000': 3,
  '100': 2,
  '10': 1,
  '1': 0,
};

const WHEEL = 'Window/ReleaseValve/WheelGrouping/Wheel';
const MAIN_LEVER =
  'Window/ReleaseValve/MainLeverGrouping/InternalLever/Image (1)';
const TANK_LEVER =
  'Window/ExternalTank/SecondaryLeverGrouping/TankLever/Image (1)';

/** Miesza kolor #rrggbb z bielą (amount 0-1) */
const lighten = (hex: string, amount: number) => {
  const n = parseInt(hex.replace('#', '').slice(0, 6), 16);
  if (Number.isNaN(n)) {
    return hex;
  }
  const mix = (c: number) => Math.round(c + (255 - c) * amount);
  return `rgb(${mix((n >> 16) & 255)}, ${mix((n >> 8) & 255)}, ${mix(n & 255)})`;
};

const byId = (id: string) => CANISTER_LAYOUT.find((item) => item.id === id);

const digitOf = (value: number, place: number) =>
  String(Math.floor(Math.max(0, value) / 10 ** place) % 10);

/** Tekst w miejscu napisu z prefabu (wyrównanie Unity 0-8: góra-lewo ... dół-prawo) */
const Label = (props: { item: LayoutItem; text: string; color?: string }) => {
  const { item, text, color } = props;
  const align = item.align || 0;
  const style: CSSProperties = {
    position: 'absolute',
    left: item.x,
    top: item.y,
    width: item.w,
    height: item.h,
    display: 'flex',
    justifyContent: ['flex-start', 'center', 'flex-end'][align % 3],
    alignItems: ['flex-start', 'center', 'flex-end'][Math.floor(align / 3)],
    color: color || item.color,
    fontFamily: FONT,
    fontWeight: 'bold',
    fontSize: `${Math.max(8, (item.size || 12) * 0.78)}px`,
    whiteSpace: 'nowrap',
    pointerEvents: 'none',
    lineHeight: 1,
  };
  return <div style={style}>{text}</div>;
};

/** Obrazek z prefabu: zwykły, cięty na 9 części albo jednolity kolor */
const Sprite = (props: {
  item: LayoutItem;
  src?: string;
  fill?: string;
  style?: CSSProperties;
}) => {
  const { item, style } = props;
  const src = props.src ?? item.src;
  const fill = props.fill ?? item.fill;
  const base: CSSProperties = {
    position: 'absolute',
    left: item.x,
    top: item.y,
    width: item.w,
    height: item.h,
    boxSizing: 'border-box',
    opacity: item.opacity,
    transform:
      item.flipx || item.flipy
        ? `scale(${item.flipx ? -1 : 1}, ${item.flipy ? -1 : 1})`
        : undefined,
    pointerEvents: 'none',
    ...style,
  };
  if (!src) {
    return <div style={{ ...base, background: fill }} />;
  }
  const url = `url(${resolveAsset(src)})`;
  if (item.slice && item.bw) {
    const [t, r, b, l] = item.slice;
    return (
      <div
        style={{
          ...base,
          borderStyle: 'solid',
          borderWidth: item.bw.map((v) => `${v}px`).join(' '),
          borderImage: `${url} ${t} ${r} ${b} ${l} fill stretch`,
        }}
      />
    );
  }
  return (
    <div
      style={{
        ...base,
        backgroundImage: url,
        backgroundSize: item.contain ? 'contain' : '100% 100%',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'center',
      }}
    />
  );
};

/** Obudowa w kolorze kanistra: szara grafika przemnożona przez kolor */
const TintedBody = (props: { item: LayoutItem; color: string }) => {
  const { item, color } = props;
  const url = `url(${resolveAsset(item.src!)})`;
  const box: CSSProperties = {
    position: 'absolute',
    left: item.x,
    top: item.y,
    width: item.w,
    height: item.h,
    pointerEvents: 'none',
  };
  return (
    <>
      <div
        style={{ ...box, backgroundImage: url, backgroundSize: '100% 100%' }}
      />
      <div
        style={{
          ...box,
          background: color,
          mixBlendMode: 'multiply',
          WebkitMaskImage: url,
          WebkitMaskSize: '100% 100%',
          maskImage: url,
          maskSize: '100% 100%',
        }}
      />
    </>
  );
};

/** Przezroczysta strefa kliknięcia nad elementem z prefabu */
const Hit = (props: {
  item?: LayoutItem;
  tip: string;
  onClick: (e: React.MouseEvent) => void;
  onWheel?: (e: React.WheelEvent) => void;
  pad?: number;
}) => {
  const { item, tip, onClick, onWheel, pad = 0 } = props;
  if (!item) {
    return null;
  }
  return (
    <div
      className="AqCanister__hit"
      title={tip}
      onClick={onClick}
      onWheel={onWheel}
      style={{
        position: 'absolute',
        left: item.x - pad,
        top: item.y - pad,
        width: item.w + pad * 2,
        height: item.h + pad * 2,
        cursor: 'pointer',
      }}
    />
  );
};

export const Canister = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    portConnected,
    tankPressure,
    releasePressure,
    minReleasePressure,
    maxReleasePressure,
    valveOpen,
    isPrototype,
    restricted,
    hasHoldingTank,
    holdingTank,
    canisterColor = '#9aa1ad',
    canisterName = 'Kanister',
  } = data;

  const setPressure = (value: number) =>
    act('pressure', {
      pressure: Math.max(
        minReleasePressure,
        Math.min(maxReleasePressure, Math.round(value)),
      ),
    });

  const wheel = byId(WHEEL)!;
  const wheelCx = wheel.x + wheel.w / 2;
  const wheelCy = wheel.y + wheel.h / 2;
  // pełne ciśnienie wylotu to dwa obroty koła
  const wheelAngle =
    ((releasePressure - minReleasePressure) /
      Math.max(1, maxReleasePressure - minReleasePressure)) *
    720;

  const lampOn = {
    Red: tankPressure <= 0 || tankPressure > 9000,
    Yellow: !!valveOpen,
    Green: tankPressure > 0 && tankPressure <= 9000,
  };
  const lampColor = { Red: '#ff1c00', Yellow: '#e4ff02', Green: '#02ff23' };
  const lampOff = { Red: '#730000', Yellow: '#5e5400', Green: '#005e00' };

  const texts: Record<string, string> = {
    'Window/Internal': 'Stan kanistra',
    'Window/Internal/ConnectionStatus/ConnectionStatusText': portConnected
      ? 'Podłączony'
      : 'Niepodłączony',
    'Window/ReleaseValve': 'Zawór wylotu',
    'Window/ReleaseValve/MainLeverGrouping/Open': 'Otwarty',
    'Window/ReleaseValve/MainLeverGrouping/Closed': 'Zamknięty',
    'Window/ExternalTank/SecondaryLeverGrouping/Tank': 'Napełnij',
    'Window/ExternalTank/SecondaryLeverGrouping/Valve': 'Zamknij',
    'Window/ExternalTank/TankStatusGroup/TankStatusText': hasHoldingTank
      ? holdingTank?.name || 'Butla'
      : 'Brak butli',
    'Window/ExternalTank/eject/Text': 'Wyjmij',
    'Window/LabelFrame/PropertyText': canisterName,
  };

  // Dźwignia obraca się cała (gniazdo i rączka) wokół środka gałki:
  // zwisa w dół przy zamkniętym zaworze, przy otwartym wskazuje w prawo, na strzałki
  const lever = (item: LayoutItem, open: boolean, z: number) => (
    <Sprite
      key={item.id}
      item={item}
      style={{
        transform: open ? 'rotate(-90deg)' : undefined,
        transformOrigin: `50% ${(item.h * 32) / 220}px`,
        transition: 'transform 0.2s ease-out',
        zIndex: z,
      }}
    />
  );

  const nodes: ReactNode[] = CANISTER_LAYOUT.map((item) => {
    const { id } = item;
    if (item.kind === 'text') {
      const digit = id.match(
        /(InternalPressure|ExternalPressure|ReleasePressure)\/(\w+)\/center$/,
      );
      if (digit) {
        const value =
          digit[1] === 'InternalPressure'
            ? tankPressure
            : digit[1] === 'ExternalPressure'
              ? holdingTank?.tankPressure || 0
              : releasePressure;
        return (
          <Label
            key={id}
            item={item}
            text={digitOf(value, PLACES[digit[2]] ?? 0)}
          />
        );
      }
      return <Label key={id} item={item} text={texts[id] ?? item.text ?? ''} />;
    }
    if (id === 'Window/BG') {
      return (
        <TintedBody key={id} item={item} color={lighten(canisterColor, 0.45)} />
      );
    }
    // gniazdo z gałką leży nad rączką i obraca się razem z nią
    if (id === MAIN_LEVER || id === MAIN_LEVER.replace(' (1)', '')) {
      return lever(item, !!valveOpen, id === MAIN_LEVER ? 0 : 1);
    }
    if (id === TANK_LEVER || id === TANK_LEVER.replace(' (1)', '')) {
      return lever(
        item,
        !!valveOpen && !!hasHoldingTank,
        id === TANK_LEVER ? 0 : 1,
      );
    }
    if (id.startsWith(`${WHEEL}`) && !id.endsWith('Image (7)')) {
      return (
        <Sprite
          key={id}
          item={item}
          style={{
            transform: `rotate(${-wheelAngle}deg)`,
            transformOrigin: `${wheelCx - item.x}px ${wheelCy - item.y}px`,
            transition: 'transform 0.2s',
          }}
        />
      );
    }
    const lamp = id.match(/^Window\/LEDs\/(Red|Yellow|Green)$/);
    if (lamp) {
      const on = lampOn[lamp[1]];
      return (
        <Sprite
          key={id}
          item={item}
          fill={on ? lampColor[lamp[1]] : lampOff[lamp[1]]}
          style={
            on
              ? { boxShadow: `0 0 10px 2px ${lampColor[lamp[1]]}88` }
              : undefined
          }
        />
      );
    }
    if (id === 'Window/ExternalTank/TankImageGroup/TankImage') {
      return (
        <Sprite
          key={id}
          item={{ ...item, contain: true }}
          src={
            hasHoldingTank
              ? 'us_canister_externaltankinserted.png'
              : 'us_canister_externaltankempty.png'
          }
        />
      );
    }
    return <Sprite key={id} item={item} />;
  });

  return (
    <Window width={CANISTER_W} height={CANISTER_H + 32}>
      <Window.Content
        style={{ padding: 0, background: '#16181c', overflow: 'hidden' }}
      >
        <div
          style={{
            position: 'relative',
            width: CANISTER_W,
            height: CANISTER_H,
            userSelect: 'none',
          }}
        >
          {nodes}
          <Hit
            item={byId(MAIN_LEVER)}
            tip={valveOpen ? 'Zamknij zawór' : 'Otwórz zawór'}
            onClick={() => act('valve')}
          />
          <Hit
            item={byId(TANK_LEVER)}
            tip={
              hasHoldingTank
                ? valveOpen
                  ? 'Przestań napełniać butlę'
                  : 'Napełnij butlę'
                : 'Najpierw włóż butlę'
            }
            onClick={() => hasHoldingTank && act('valve')}
          />
          <Hit
            item={wheel}
            tip="Kręć kołem: lewa połowa zmniejsza, prawa zwiększa ciśnienie (albo kółko myszy)"
            onClick={(e) => {
              const rect = (
                e.currentTarget as HTMLElement
              ).getBoundingClientRect();
              const right = e.clientX - rect.left > rect.width / 2;
              setPressure(releasePressure + (right ? 100 : -100));
            }}
            onWheel={(e) =>
              setPressure(releasePressure + (e.deltaY < 0 ? 25 : -25))
            }
          />
          <Hit
            item={byId('Window/ReleaseValve/minus')}
            tip="Zmniejsz o 50 kPa"
            onClick={() => setPressure(releasePressure - 50)}
          />
          <Hit
            item={byId('Window/ReleaseValve/plus')}
            tip="Zwiększ o 50 kPa"
            onClick={() => setPressure(releasePressure + 50)}
          />
          <Hit
            item={byId('Window/ReleaseValve/releasekPA/Edit/Image')}
            tip="Wpisz ciśnienie"
            onClick={() => act('pressure', { pressure: 'input' })}
          />
          <Hit
            item={byId('Window/ExternalTank/eject')}
            tip="Wyjmij butlę"
            onClick={() => hasHoldingTank && act('eject')}
          />
          <Hit
            item={byId('Window/ExternalTank/TankImageGroup/frame')}
            tip={hasHoldingTank ? 'Wyjmij butlę' : 'Brak butli'}
            onClick={() => hasHoldingTank && act('eject')}
          />
          <Hit
            item={byId('Window/LabelFrame')}
            tip="Zmień etykietę kanistra"
            onClick={() => act('relabel')}
          />
          {!!isPrototype && (
            <div
              className="AqCanister__hit"
              title="Dostęp tylko dla inżynierii"
              onClick={() => act('restricted')}
              style={{
                position: 'absolute',
                left: 24,
                top: CANISTER_H - 28,
                padding: '3px 8px',
                background: restricted ? '#7a1c18' : '#3b4049',
                color: '#f2f2f2',
                fontFamily: FONT,
                fontSize: '11px',
                fontWeight: 'bold',
                border: '2px solid #1b1e24',
                cursor: 'pointer',
              }}
            >
              {restricted ? 'Tylko inżynieria' : 'Dostęp dla wszystkich'}
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
