import type { ReactElement } from 'react';

/**
 * AQUILA: wspólne klocki pikselowych okien (panel kabli, automat).
 * Wszystko jest rysowane w jednostkach „piksela sprite'a”, a skala
 * mnoży je na ekranie, więc krawędzie zostają ostre przy każdym DPI.
 */

/** Czcionka 3x5, wiersze od góry, `#` to zapalony piksel. */
const GLYPHS: Record<string, string> = {
  A: '.#.#.#####.##.#',
  B: '##.#.###.#.###.',
  C: '.###..#..#...##',
  D: '##.#.##.##.###.',
  E: '####..##.#..###',
  F: '####..##.#..#..',
  G: '.###..#.##.#.##',
  H: '#.##.#####.##.#',
  I: '###.#..#..#.###',
  J: '..#..#..##.#.#.',
  K: '#.##.###.#.##.#',
  L: '#..#..#..#..###',
  M: '#.########.##.#',
  N: '##.#.##.##.##.#',
  O: '.#.#.##.##.#.#.',
  P: '##.#.###.#..#..',
  Q: '.#.#.##.###..##',
  R: '##.#.###.#.##.#',
  S: '.###...#...###.',
  T: '###.#..#..#..#.',
  U: '#.##.##.##.####',
  V: '#.##.##.##.#.#.',
  W: '#.##.########.#',
  X: '#.##.#.#.#.##.#',
  Y: '#.##.#.#..#..#.',
  Z: '###..#.#.#..###',
  '0': '####.##.##.####',
  '1': '.#.##..#..#.###',
  '2': '##...#.#.#..###',
  '3': '##...#.#...###.',
  '4': '#.##.####..#..#',
  '5': '####..##...###.',
  '6': '.###..####.####',
  '7': '###..#.#..#..#.',
  '8': '####.#####.####',
  '9': '####.####..###.',
  '.': '.............#.',
  ',': '..........#.#..',
  '!': '.#..#..#.....#.',
  '?': '##...#.#.....#.',
  ':': '....#.....#....',
  ';': '....#.....#.#..',
  '-': '......###......',
  '+': '....#.###.#....',
  '=': '...###...###...',
  '/': '..#..#.#.#..#..',
  '(': '.#.#..#..#...#.',
  ')': '.#...#..#..#.#.',
  "'": '.#..#..........',
  '"': '#.##.#.........',
  '%': '#.#..#.#.#..#.#',
  '>': '#...#...#.#.#..',
  '<': '..#.#.#...#...#',
  _: '............###',
  '*': '#.#.#.#.#......',
  '#': '#.#####.#####.#',
  '[': '##.#..#..#..##.',
  ']': '.##..#..#..#.##',
  ' ': '...............',
};

/** Polskie litery: baza + znak diakrytyczny (piksel nad lub pod literą). */
const DIACRITICS: Record<string, [string, number, number]> = {
  Ą: ['A', 2, 6],
  Ę: ['E', 2, 6],
  Ć: ['C', 2, 0],
  Ń: ['N', 2, 0],
  Ó: ['O', 2, 0],
  Ś: ['S', 2, 0],
  Ź: ['Z', 2, 0],
  Ż: ['Z', 1, 0],
  Ł: ['L', 1, 3],
};

export const FONT_W = 4;
export const FONT_H = 7;

/**
 * Bufor pikseli: zbiera prostokąty w kolejności rysowania i skleja kolejne
 * piksele tego samego koloru w jedną ścieżkę SVG (późniejsze leżą na wierzchu).
 */
export class PixelBuffer {
  private runs: { color: string; d: string[] }[] = [];

  rect(x: number, y: number, w: number, h: number, color: string) {
    if (w <= 0 || h <= 0) {
      return;
    }
    let run = this.runs[this.runs.length - 1];
    if (!run || run.color !== color) {
      run = { color, d: [] };
      this.runs.push(run);
    }
    run.d.push(`M${x} ${y}h${w}v${h}h${-w}z`);
  }

  /** Wypukła albo wklęsła ramka z jasną i ciemną krawędzią. */
  bevel(
    x: number,
    y: number,
    w: number,
    h: number,
    fill: string,
    light: string,
    dark: string,
    inset = false,
  ) {
    this.rect(x, y, w, h, fill);
    const top = inset ? dark : light;
    const bottom = inset ? light : dark;
    this.rect(x, y, w, 1, top);
    this.rect(x, y, 1, h, top);
    this.rect(x, y + h - 1, w, 1, bottom);
    this.rect(x + w - 1, y, 1, h, bottom);
  }

  /** Śruba 3x3 z nacięciem. */
  screw(x: number, y: number) {
    this.rect(x - 1, y - 1, 3, 3, '#2b2f38');
    this.rect(x - 1, y - 1, 2, 2, '#c9ced6');
    this.rect(x, y - 1, 1, 3, '#737b88');
  }

  /** Taśma ostrzegawcza w ukośne pasy. */
  hazard(x: number, y: number, w: number, h: number) {
    this.rect(x, y, w, h, '#1b1e26');
    for (let i = 0; i < w; i++) {
      for (let j = 0; j < h; j++) {
        if (((i + j) >> 2) % 2 === 0) {
          this.rect(x + i, y + j, 1, 1, '#e8b923');
        }
      }
    }
  }

  /** Tekst czcionką 3x5; zwraca szerokość w pikselach. */
  text(x: number, y: number, str: string, color: string) {
    const chars = str.toUpperCase().split('');
    chars.forEach((ch, n) => {
      const ox = x + n * FONT_W;
      let base = ch;
      const mark = DIACRITICS[ch];
      if (mark) {
        base = mark[0];
        this.rect(ox + mark[1], y + mark[2] - 1, 1, 1, color);
      }
      const glyph = GLYPHS[base] ?? GLYPHS['?'];
      for (let i = 0; i < 15; i++) {
        if (glyph[i] === '#') {
          this.rect(ox + (i % 3), y + Math.floor(i / 3), 1, 1, color);
        }
      }
    });
    return textWidth(str);
  }

  render() {
    const out: ReactElement[] = [];
    this.runs.forEach((run, n) => {
      out.push(<path key={n} fill={run.color} d={run.d.join('')} />);
    });
    return out;
  }
}

export const textWidth = (str: string) => Math.max(0, str.length * FONT_W - 1);

/** Dzieli tekst na linie o długości najwyżej `max` znaków. */
export const wrapText = (str: string, max: number) => {
  const lines: string[] = [];
  let line = '';
  for (const word of str.split(' ')) {
    if (!line.length) {
      line = word;
    } else if (line.length + 1 + word.length <= max) {
      line += ' ' + word;
    } else {
      lines.push(line);
      line = word;
    }
    while (line.length > max) {
      lines.push(line.slice(0, max));
      line = line.slice(max);
    }
  }
  if (line.length) {
    lines.push(line);
  }
  return lines;
};

/** Rozjaśnia (amount > 0) lub przyciemnia (amount < 0) kolor #rrggbb. */
export const shade = (hex: string, amount: number) => {
  const n = parseInt(hex.slice(1), 16);
  const mix = (c: number) =>
    Math.round(amount > 0 ? c + (255 - c) * amount : c * (1 + amount));
  const r = mix((n >> 16) & 255);
  const g = mix((n >> 8) & 255);
  const b = mix(n & 255);
  return `#${((1 << 24) | (r << 16) | (g << 8) | b).toString(16).slice(1)}`;
};

type ScreenTextProps = {
  text: string;
  color?: string;
  scale?: number;
  title?: string;
};

/**
 * Napis na ekranie lub klawiszu maszyny, zwykłą czcionką okien tgui (Verdana).
 * `scale` odpowiada wielkości z siatki pikseli: 2 to zwykły tekst, 3 to duży.
 */
export const ScreenText = (props: ScreenTextProps) => {
  const { text, color = '#e6e9ee', scale = 2, title } = props;
  return (
    <span
      title={title}
      style={{
        color,
        fontFamily: 'Verdana, Geneva, sans-serif',
        fontSize: `${scale * 6}px`,
        fontWeight: scale > 2 ? 'bold' : 'normal',
        lineHeight: 1.2,
        whiteSpace: 'nowrap',
        display: 'inline-block',
        verticalAlign: 'middle',
      }}
    >
      {text}
    </span>
  );
};
