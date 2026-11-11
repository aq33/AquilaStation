import { useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PixelBuffer, shade, wrapText } from './common/PixelArt';

type Data = {
  proper_name: string | null;
  wires: Wire[];
  status: string[];
};

type Wire = {
  color: string;
  cut: BooleanLike;
  attached: BooleanLike;
  wire: string | null;
};

/** Polskie nazwy kolorów przewodów (wartość `color` z DM zostaje bez zmian) */
const COLOR_NAMES: Record<string, string> = {
  blue: 'niebieski',
  brown: 'brązowy',
  crimson: 'karmazynowy',
  cyan: 'cyjanowy',
  gold: 'złoty',
  grey: 'szary',
  green: 'zielony',
  magenta: 'purpurowy',
  orange: 'pomarańczowy',
  pink: 'różowy',
  purple: 'fioletowy',
  red: 'czerwony',
  silver: 'srebrny',
  violet: 'fiołkowy',
  white: 'biały',
  yellow: 'żółty',
};

/** Kolor izolacji w palecie sprite'a (środkowy ton, reszta liczona z niego) */
const COLOR_HEX: Record<string, string> = {
  blue: '#2f6fd0',
  brown: '#8a5426',
  crimson: '#a3142e',
  cyan: '#2ab8c8',
  gold: '#d4a017',
  grey: '#7c838e',
  green: '#38a832',
  magenta: '#d02ab8',
  orange: '#e0702a',
  pink: '#ee86ad',
  purple: '#7a2ad0',
  red: '#d0302a',
  silver: '#b4bcc6',
  violet: '#9a6ae0',
  white: '#dde2e8',
  yellow: '#e8d02a',
};

// Wymiary w pikselach sprite'a; na ekranie każdy piksel to SCALE pikseli
const SCALE = 3;
const W = 216;
const ROW = 10;
const BAY_Y = 24;
const LABEL_X = 4;
const LABEL_W = 70;
const BAY_X = 76;
const BAY_W = 100;
const WIRE_X0 = 84;
const WIRE_X1 = 168;
const CUT_X0 = 120;
const CUT_X1 = 130;
const KEYS_X = 179;
const KEY_W = 11;
const STATUS_CHARS = 58;
/** Napisy zwykłą czcionką okien tgui; rozmiar w pikselach sprite'a */
const FONT = 'Verdana, Geneva, sans-serif';
const FONT_SIZE = 4.4;

/** Polskie nazwy funkcji (wartości WIRE_* z DM są porównywane w kodzie, więc tłumaczymy tylko tu) */
const WIRE_NAMES: Record<string, string> = {
  Activate: 'Aktywacja',
  'AI Connection': 'Połączenie SI',
  Alarm: 'Alarm',
  Avoidance: 'Unikanie',
  'Auxiliary Power 1': 'Zasilanie zap.1',
  'Auxiliary Power 2': 'Zasilanie zap.2',
  Beacon: 'Nadajnik',
  Bolts: 'Rygle',
  Boom: 'Wybuch',
  Camera: 'Kamera',
  Contraband: 'Kontrabanda',
  Delay: 'Opóźnienie',
  Disable: 'Wyłączenie',
  Disarm: 'Rozbrojenie',
  Hack: 'Hakowanie',
  'ID Scan': 'Skaner ID',
  Interface: 'Interfejs',
  Launch: 'Start',
  'AI Law Synchronization': 'Synchr. praw SI',
  'Bolt Lights': 'Lampki rygli',
  Limiter: 'Ogranicznik',
  'Load Check': 'Kontr. ładunku',
  Lockdown: 'Blokada',
  'Motor 1': 'Silnik 1',
  'Motor 2': 'Silnik 2',
  Open: 'Otwieranie',
  'Panic Siphon': 'Wyssanie awar.',
  Power: 'Zasilanie',
  'Main Power 1': 'Zasilanie gł.1',
  'Main Power 2': 'Zasilanie gł.2',
  Proceed: 'Dalej',
  Receive: 'Odbiór',
  'Reset Module': 'Reset modułu',
  Safety: 'Zabezpieczenie',
  'High Voltage Ground': 'Uziemienie WN',
  Signal: 'Sygnał',
  Speaker: 'Głośnik',
  Strength: 'Siła',
  Throw: 'Wyrzut',
  Timing: 'Zegar',
  Transmit: 'Nadawanie',
  Unbolt: 'Odryglowanie',
  'High Voltage Circuit': 'Obwód WN',
  'High Voltage Circuit 1': 'Obwód WN 1',
  'High Voltage Circuit 2': 'Obwód WN 2',
};

const LABEL_CHARS = 20;

type Label = {
  x: number;
  y: number;
  text: string;
  color: string;
  anchor?: 'start' | 'middle';
  bold?: boolean;
};

const STEEL = '#5b6270';
const STEEL_LIGHT = '#9aa1ad';
const STEEL_DARK = '#2b2f38';
const KEY = '#6d7584';
const KEY_LIGHT = '#c9ced6';
const BRASS = '#6b5a2e';
const BRASS_LIGHT = '#b39a52';
const BRASS_DARK = '#3d321a';
const COPPER = '#e0a050';
const COPPER_LIGHT = '#ffd08a';

/** Ikony 5x5 na klawiszach */
const ICONS: Record<string, string[]> = {
  cut: ['#...#', '.#.#.', '..#..', '##.##', '##.##'],
  pulse: ['..##.', '.##..', '####.', '..##.', '.##..'],
  attach: ['...#.', '..#..', '#####', '#.#.#', '#####'],
};

type LampState = 'on' | 'off' | 'blink' | 'alarm' | 'info';

/** Stan lampki odczytany z polskiego zdania z get_status() */
const lampOf = (line: string): LampState => {
  const l = line.toLowerCase();
  if (l.includes('opadły') || l.includes('!')) {
    return 'alarm';
  }
  if (l.includes('miga')) {
    return 'blink';
  }
  if (
    l.includes('zgaszona') ||
    l.includes('niezasilany') ||
    l.includes('wyłączon')
  ) {
    return 'off';
  }
  if (
    l.includes('świeci') ||
    l.includes('zasilany') ||
    l.includes('włączon') ||
    l.includes('podniesione')
  ) {
    return 'on';
  }
  return 'info';
};

const LAMP_COLORS: Record<LampState, string> = {
  on: '#5dff8f',
  off: '#0d2a17',
  blink: '#ffb840',
  alarm: '#ff3e5f',
  info: '#e8b923',
};

const wireY = (i: number, x: number, cut: boolean) => {
  const cy = BAY_Y + 7 + i * ROW;
  const sag = 2 + (i % 3);
  const t = (x - WIRE_X0) / (WIRE_X1 - WIRE_X0);
  let y = cy - 1 + Math.round(sag * 4 * t * (1 - t));
  if (cut) {
    // Przecięte końce opadają w stronę szczeliny
    if (x > CUT_X0 - 8 && x < CUT_X0) {
      y += Math.round((x - (CUT_X0 - 8)) / 3);
    }
    if (x > CUT_X1 && x < CUT_X1 + 8) {
      y += Math.round((CUT_X1 + 8 - x) / 3);
    }
  }
  return y;
};

export const Wires = (props) => {
  const { act, data } = useBackend<Data>();
  const { proper_name, status = [], wires = [] } = data;
  const [hover, setHover] = useState<string | null>(null);
  const [flash, setFlash] = useState<string | null>(null);

  const bayH = wires.length * ROW + 6;
  const statusLines = status.flatMap((line) =>
    wrapText(line, STATUS_CHARS).map((text, n) => ({
      text,
      lamp: n === 0 ? lampOf(line) : null,
    })),
  );
  const crtY = BAY_Y + bayH + 3;
  const crtH = statusLines.length ? statusLines.length * 8 + 5 : 0;
  const H = crtY + crtH + (crtH ? 4 : 1);

  const buf = new PixelBuffer();
  const labels: Label[] = [];

  // Obudowa
  buf.bevel(0, 0, W, H, STEEL, STEEL_LIGHT, STEEL_DARK);
  buf.hazard(4, 3, W - 8, 3);
  buf.bevel(4, 8, W - 8, 13, '#1b1e24', STEEL_DARK, STEEL_LIGHT, true);
  const title = proper_name
    ? `Panel serwisowy: ${proper_name}`
    : 'Panel serwisowy';
  labels.push({
    x: W / 2,
    y: 11,
    text: title,
    color: '#e8b923',
    anchor: 'middle',
    bold: true,
  });

  // Wnęka z kablami
  buf.bevel(BAY_X, BAY_Y, BAY_W, bayH, '#1a1d23', '#0f1115', KEY, true);
  for (let i = 0; i < wires.length - 1; i++) {
    // Ścieżki płytki między kablami
    const ty = BAY_Y + 12 + i * ROW;
    const tx = BAY_X + 12 + ((i * 17) % 40);
    const tw = 18 + ((i * 7) % 20);
    buf.rect(tx, ty, tw, 1, '#1d3a26');
    buf.rect(tx + tw, ty - 3, 1, 4, '#1d3a26');
  }
  buf.bevel(BAY_X + 2, BAY_Y + 2, 6, bayH - 4, BRASS, BRASS_LIGHT, BRASS_DARK);
  buf.bevel(
    BAY_X + BAY_W - 8,
    BAY_Y + 2,
    6,
    bayH - 4,
    BRASS,
    BRASS_LIGHT,
    BRASS_DARK,
  );

  wires.forEach((wire, i) => {
    const cy = BAY_Y + 7 + i * ROW;
    const cut = !!wire.cut;
    const lit = flash === wire.color;
    const hovered = hover === wire.color;
    const base = COLOR_HEX[wire.color] || '#9aa1ad';
    const main = lit ? '#ffffff' : base;
    const light = lit ? '#ffffff' : shade(base, 0.45);
    const dark = lit ? '#fff07a' : shade(base, -0.45);

    // Etykieta z nazwą koloru
    buf.bevel(
      LABEL_X,
      cy - 4,
      LABEL_W,
      9,
      hovered ? '#3b4150' : STEEL_DARK,
      '#1b1e24',
      STEEL_LIGHT,
      true,
    );
    buf.rect(LABEL_X + 2, cy - 2, 2, 5, base);
    labels.push({
      x: LABEL_X + 6,
      y: cy - 2,
      text: (wire.wire
        ? WIRE_NAMES[wire.wire] || wire.wire
        : COLOR_NAMES[wire.color] || wire.color
      ).slice(0, LABEL_CHARS),
      color: wire.wire ? '#e8b923' : '#c9ced6',
    });

    if (hovered) {
      buf.rect(BAY_X + 9, cy - 4, BAY_W - 18, 9, '#262a33');
    }

    // Zaciski
    buf.rect(BAY_X + 2, cy - 1, 5, 3, BRASS_DARK);
    buf.rect(BAY_X + 3, cy - 1, 3, 1, '#e0c07a');
    buf.rect(BAY_X + BAY_W - 7, cy - 1, 5, 3, BRASS_DARK);
    buf.rect(BAY_X + BAY_W - 6, cy - 1, 3, 1, '#e0c07a');

    // Kabel: cień na płytce, światło, izolacja i cień; każdy ton osobnym
    // przebiegiem, żeby bufor skleił go w jedną ścieżkę
    (
      [
        [2, '#121418'],
        [-1, light],
        [0, main],
        [1, dark],
      ] as const
    ).forEach(([dy, color]) => {
      for (let x = WIRE_X0; x <= WIRE_X1; x++) {
        if (cut && x >= CUT_X0 && x <= CUT_X1) {
          continue;
        }
        buf.rect(x, wireY(i, x, cut) + dy, 1, 1, color);
      }
    });
    if (cut) {
      const ya = wireY(i, CUT_X0 - 1, true);
      const yb = wireY(i, CUT_X1 + 1, true);
      buf.rect(CUT_X0 - 1, ya, 2, 1, COPPER);
      buf.rect(CUT_X0, ya + 1, 1, 1, COPPER_LIGHT);
      buf.rect(CUT_X1, yb, 2, 1, COPPER);
      buf.rect(CUT_X1, yb + 1, 1, 1, COPPER_LIGHT);
    }

    // Sygnalizator wpięty w kabel
    if (wire.attached) {
      const sx = 140;
      const sy = wireY(i, sx + 4, cut) - 3;
      buf.bevel(sx, sy, 9, 6, '#737b88', '#c9ced6', STEEL_DARK);
      buf.rect(sx + 2, sy + 2, 2, 2, '#5dff8f');
      buf.rect(sx + 6, sy - 3, 1, 3, '#c9ced6');
      buf.rect(sx + 7, sy - 4, 1, 1, '#ff3e5f');
    }

    // Klawisze: przetnij, impuls, sygnalizator
    (['cut', 'pulse', 'attach'] as const).forEach((kind, k) => {
      const kx = KEYS_X + k * (KEY_W + 1);
      const on = kind === 'attach' && !!wire.attached;
      const pressed = hover === `${wire.color}:${kind}`;
      buf.bevel(
        kx,
        cy - 4,
        KEY_W,
        9,
        on ? '#0d2a17' : pressed ? '#7c8595' : KEY,
        on ? STEEL_DARK : KEY_LIGHT,
        on ? KEY_LIGHT : STEEL_DARK,
      );
      const color = on
        ? '#5dff8f'
        : kind === 'cut' && cut
          ? COPPER_LIGHT
          : '#e6e9ee';
      ICONS[kind].forEach((row, ry) =>
        row.split('').forEach((ch, rx) => {
          if (ch === '#') {
            buf.rect(kx + 3 + rx, cy - 2 + ry, 1, 1, color);
          }
        }),
      );
    });
  });

  // Lampki i komunikaty
  if (crtH) {
    buf.bevel(4, crtY, W - 8, crtH, '#071a0e', STEEL_DARK, STEEL_LIGHT, true);
    statusLines.forEach((line, n) => {
      const ly = crtY + 3 + n * 8;
      if (line.lamp) {
        buf.rect(8, ly, 4, 5, '#03100a');
        buf.rect(8, ly, 3, 4, LAMP_COLORS[line.lamp]);
        if (line.lamp !== 'off') {
          buf.rect(8, ly, 1, 1, '#ffffff');
        }
      }
      labels.push({ x: 15, y: ly, text: line.text, color: '#5dff8f' });
    });
  }

  buf.screw(2, 2);
  buf.screw(W - 3, 2);
  buf.screw(2, H - 3);
  buf.screw(W - 3, H - 3);

  const pulse = (color: string) => {
    setFlash(color);
    setTimeout(() => setFlash(null), 250);
  };

  const hit = (
    key: string,
    x: number,
    y: number,
    w: number,
    h: number,
    tip: string,
    onClick: () => void,
  ) => (
    <rect
      key={key}
      x={x}
      y={y}
      width={w}
      height={h}
      fill="transparent"
      style={{ cursor: 'pointer' }}
      role="button"
      tabIndex={0}
      aria-label={tip}
      onMouseEnter={() => setHover(key)}
      onMouseLeave={() => setHover(null)}
      onFocus={() => setHover(key)}
      onBlur={() => setHover(null)}
      onClick={onClick}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onClick();
        }
      }}
    >
      <title>{tip}</title>
    </rect>
  );

  return (
    <Window width={W * SCALE} height={H * SCALE + 32}>
      <Window.Content style={{ padding: 0, background: '#14161c' }}>
        <svg
          width={W * SCALE}
          height={H * SCALE}
          viewBox={`0 0 ${W} ${H}`}
          shapeRendering="crispEdges"
          style={{ display: 'block' }}
          onMouseLeave={() => setHover(null)}
        >
          {buf.render()}
          {labels.map((label, n) => (
            <text
              key={n}
              x={label.x}
              y={label.y + 4}
              fill={label.color}
              fontFamily={FONT}
              fontSize={FONT_SIZE}
              fontWeight={label.bold ? 'bold' : 'normal'}
              textAnchor={label.anchor || 'start'}
              style={{ pointerEvents: 'none' }}
            >
              {label.text}
            </text>
          ))}
          {wires.map((wire, i) => {
            const cy = BAY_Y + 7 + i * ROW;
            const name =
              (COLOR_NAMES[wire.color] || wire.color) +
              (wire.wire ? ` (${WIRE_NAMES[wire.wire] || wire.wire})` : '');
            const cut = () => act('cut', { wire: wire.color });
            return (
              <g key={wire.color}>
                {hit(
                  wire.color,
                  LABEL_X,
                  cy - 4,
                  WIRE_X1 - LABEL_X + 8,
                  9,
                  `${wire.cut ? 'Napraw' : 'Przetnij'} kabel: ${name}`,
                  cut,
                )}
                {hit(
                  `${wire.color}:cut`,
                  KEYS_X,
                  cy - 4,
                  KEY_W,
                  9,
                  wire.cut ? 'Napraw (kombinerki)' : 'Przetnij (kombinerki)',
                  cut,
                )}
                {hit(
                  `${wire.color}:pulse`,
                  KEYS_X + KEY_W + 1,
                  cy - 4,
                  KEY_W,
                  9,
                  'Impuls (multitool)',
                  () => {
                    pulse(wire.color);
                    act('pulse', { wire: wire.color });
                  },
                )}
                {hit(
                  `${wire.color}:attach`,
                  KEYS_X + 2 * (KEY_W + 1),
                  cy - 4,
                  KEY_W,
                  9,
                  wire.attached
                    ? 'Odłącz sygnalizator'
                    : 'Podłącz sygnalizator',
                  () => act('attach', { wire: wire.color }),
                )}
              </g>
            );
          })}
        </svg>
      </Window.Content>
    </Window>
  );
};
