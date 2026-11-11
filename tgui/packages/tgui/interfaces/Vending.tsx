import { useEffect, useRef, useState } from 'react';
import { Input } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { shade } from './common/PixelArt';
import { VENDING_BASE } from './common/vendingBase';

type VendingData = {
  all_products_free: boolean;
  onstation: boolean;
  /** AQUILA: nazwa automatu na szyldzie */
  machine_name?: string;
  displayed_currency_icon: string;
  displayed_currency_name: string;
  product_records: ProductRecord[];
  coin_records: CoinRecord[];
  hidden_records: HiddenRecord[];
  user: UserData | null;
  stock: Record<string, StockItem>;
  extended_inventory: boolean;
  access: boolean;
  vending_machine_input: CustomInput[];
  categories: Record<string, Category>;
  /** AQUILA: account department that gets regular products for free */
  department?: string;
};

type Category = {
  icon: string;
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  category: string;
  icon?: string;
  icon_state?: string;
  premium?: boolean;
  image?: string;
};

type CoinRecord = ProductRecord & {
  premium: boolean;
};

type HiddenRecord = ProductRecord & {
  premium: boolean;
};

type UserData = {
  name: string;
  cash: number;
  job: string;
  department?: string;
};

type StockItem = {
  name: string;
  path: string;
  amount: number;
  colorable: boolean;
};

type CustomInput = {
  path?: string;
  name: string;
  price: number;
  img: string;
  image?: string;
  amount: number;
  premium?: boolean;
  category?: string;
};

type Product = ProductRecord | CustomInput;

/** Wszystko, co okno musi wiedzieć o pozycji na szybie */
type Slot = {
  product: Product;
  key: string;
  code: string;
  remaining: number;
  free: boolean;
  price: number;
  colorable: boolean;
  /** Powód, dla którego nie da się kupić, albo null */
  blocked: string | null;
};

/** Stan widoku, który zmienia się co klatkę i nie potrzebuje renderu Reacta */
type ViewState = {
  entry: string;
  sel: number | null;
  msg: { lines: [string, string]; until: number } | null;
  deny: number;
  pressed: { k: string; t: number } | null;
  hover: string | null;
  pending: { key: string; before: number; t: number } | null;
  anim: {
    key: string;
    idx: number;
    phase: 'coil' | 'fall';
    t0: number;
    k: number;
    fy0: number;
    fy: number;
    tf: number;
  } | null;
  tray: { key: string; until: number } | null;
};

type Hit = {
  x: number;
  y: number;
  w: number;
  h: number;
  act: string;
  tip: string;
};
type Text = {
  x: number;
  y: number;
  s: string;
  size: number;
  color: string;
  align: CanvasTextAlign;
  bold: boolean;
  maxW: number;
};

// Wymiary obudowy w pikselach projektu; okno pokazuje ją w skali 4, a canvas ma 8x, żeby napisy były ostre
const NW = 137;
const NH = 162;
const K = 8;
const SCALE = 4;
const COLS = 3;
const PER_PAGE = 12;
const ROW_LETTERS = 'ABCD';
const COLX = [4, 37, 70];
const ROWY = [13, 46, 79, 112];
const KEYS = [
  ['1', '2', '3'],
  ['A', 'B', 'C'],
  ['D', 'X', 'OK'],
];
const KX = [108, 117, 126];
const KY = [40, 49, 58];
const FONT = 'Verdana, Geneva, "DejaVu Sans", sans-serif';

const productKey = (product: Product) => product.path || product.name;
const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export const Vending = (props) => {
  const { act, data } = useBackend<VendingData>();
  const {
    onstation,
    machine_name = 'Automat',
    product_records = [],
    coin_records = [],
    hidden_records = [],
    // AQ EDIT - okno z puli potrafiło dostać dane bez categories i Object.keys(null) wywalał je
    categories = {},
    stock = {},
    user,
    access,
    all_products_free,
    department,
    displayed_currency_name = ' cr',
  } = data;

  const [selectedCategory, setSelectedCategory] = useState(
    Object.keys(categories)[0],
  );
  const [stockSearch, setStockSearch] = useState('');
  const [page, setPage] = useState(0);

  let inventory: Product[];
  let custom = false;
  if (data.vending_machine_input) {
    inventory = data.vending_machine_input;
    custom = true;
  } else {
    inventory = [...product_records, ...coin_records];
    if (data.extended_inventory) {
      inventory = [...inventory, ...hidden_records];
    }
  }
  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);

  const searching = stockSearch.length >= 2;
  if (searching) {
    inventory = inventory.filter(
      createSearch(stockSearch, (item: Product) => item.name),
    );
  }

  const filteredCategories = Object.keys(categories).filter((name) =>
    inventory.some((product) => product.category === name),
  );
  const category = filteredCategories.includes(selectedCategory)
    ? selectedCategory
    : filteredCategories[0];
  const shown = inventory.filter(
    (product) =>
      searching ||
      custom ||
      filteredCategories.length < 2 ||
      product.category === category,
  );

  const pages = Math.max(1, Math.ceil(shown.length / PER_PAGE));
  const currentPage = Math.min(page, pages - 1);

  const slots: Slot[] = shown
    .slice(currentPage * PER_PAGE, (currentPage + 1) * PER_PAGE)
    .map((product, idx) => {
      const productStock = product.path ? stock[product.path] : undefined;
      const remaining = custom
        ? (product as CustomInput).amount
        : (productStock?.amount ?? 0);
      // AQUILA: the vendor's own department gets regular products for free
      const free =
        all_products_free ||
        product.price === 0 ||
        (custom && !!access) ||
        (!product.premium && !!department && user?.department === department);
      const price = Math.round(product.price);
      let blocked: string | null = null;
      if (remaining === 0) {
        blocked = 'wyprzedane';
      } else if (!all_products_free && !user) {
        blocked = 'brak karty';
      } else if (!free && !access && price > (user?.cash ?? 0)) {
        blocked = 'za mało środków';
      }
      return {
        product,
        key: productKey(product),
        code: ROW_LETTERS[Math.floor(idx / COLS)] + ((idx % COLS) + 1),
        remaining,
        free,
        price,
        colorable: !!productStock?.colorable,
        blocked,
      };
    });

  /** Wszystko, co rysuje pętla canvasa; odświeżane przy każdym renderze */
  const model = {
    slots,
    machineName: machine_name,
    user,
    free: all_products_free || !onstation,
    ownDepartment: !!department && user?.department === department,
    currency: displayed_currency_name,
    pages,
    page: currentPage,
    categories: searching || custom ? [] : filteredCategories,
    category,
  };
  const modelRef = useRef(model);
  modelRef.current = model;

  const view = useRef<ViewState>({
    entry: '',
    sel: null,
    msg: null,
    deny: 0,
    pressed: null,
    hover: null,
    pending: null,
    anim: null,
    tray: null,
  });

  const resetSelection = () => {
    view.current.entry = '';
    view.current.sel = null;
  };

  const flash = (l1: string, l2: string, ms = 1500) => {
    view.current.msg = { lines: [l1, l2], until: performance.now() + ms };
  };

  const buy = () => {
    const v = view.current;
    const slot = v.sel !== null ? slots[v.sel] : undefined;
    if (!slot) {
      flash('WYBIERZ', 'najpierw towar');
      v.deny = performance.now() + 700;
      return;
    }
    if (v.pending || v.anim) {
      return;
    }
    if (slot.blocked) {
      flash('ODMOWA', slot.blocked, 2000);
      v.deny = performance.now() + 700;
      return;
    }
    if (custom) {
      act('dispense', { item: slot.product.name });
    } else {
      const record = slot.product as ProductRecord;
      act('vend', { ref: record.ref, discountless: !!record.premium });
    }
    // Towar spada dopiero, gdy serwer zdejmie go ze stanu; odmowa (komunikat w czacie) go nie rusza
    v.pending = { key: slot.key, before: slot.remaining, t: performance.now() };
  };

  const press = (k: string) => {
    const v = view.current;
    v.pressed = { k, t: performance.now() };
    if (v.anim) {
      return;
    }
    if (ROW_LETTERS.includes(k)) {
      v.entry = k;
      v.sel = null;
      return;
    }
    if ('123'.includes(k)) {
      if (!v.entry) {
        flash('NAJPIERW', 'litera rzędu');
        return;
      }
      const idx = ROW_LETTERS.indexOf(v.entry) * COLS + (+k - 1);
      v.entry = '';
      if (!slots[idx]) {
        flash('PUSTO', 'nie ma takiego kodu');
        v.sel = null;
        return;
      }
      v.sel = idx;
      return;
    }
    if (k === 'X') {
      resetSelection();
      return;
    }
    if (k === 'OK') {
      buy();
    }
  };

  const handle = (action: string) => {
    const v = view.current;
    const [kind, arg] = action.split(':');
    if (kind === 'key') {
      press(arg);
    } else if (kind === 'cell') {
      const idx = +arg;
      if (v.anim) {
        return;
      }
      if (v.sel === idx) {
        buy();
        return;
      }
      v.sel = idx;
      v.entry = '';
    } else if (kind === 'page') {
      setPage((currentPage + +arg + pages) % pages);
      resetSelection();
    } else if (kind === 'cat') {
      const list = model.categories;
      const next = list[(list.indexOf(category) + 1) % list.length];
      setSelectedCategory(next);
      setPage(0);
      resetSelection();
    } else if (kind === 'color') {
      const slot = v.sel !== null ? slots[v.sel] : undefined;
      if (slot?.colorable) {
        act('select_colors', { ref: (slot.product as ProductRecord).ref });
      }
    } else if (kind === 'tray') {
      v.tray = null;
    }
  };

  const canvasRef = useRef<HTMLCanvasElement>(null);
  const hitsRef = useRef<Hit[]>([]);

  useEffect(() => {
    const cv = canvasRef.current;
    if (!cv) {
      return;
    }
    cv.width = NW * K;
    cv.height = NH * K;
    const g = cv.getContext('2d');
    const pix = document.createElement('canvas');
    pix.width = NW;
    pix.height = NH;
    const p = pix.getContext('2d');
    if (!g || !p) {
      return;
    }
    const base = new Image();
    base.src = VENDING_BASE;
    let raf = 0;
    const loop = (now: number) => {
      if (base.complete) {
        hitsRef.current = drawMachine(
          g,
          p,
          base,
          modelRef.current,
          view.current,
          now,
        );
      }
      raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    return () => cancelAnimationFrame(raf);
  }, []);

  const hitAt = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const r = e.currentTarget.getBoundingClientRect();
    const x = ((e.clientX - r.left) / r.width) * NW;
    const y = ((e.clientY - r.top) / r.height) * NH;
    const hits = hitsRef.current;
    for (let i = hits.length - 1; i >= 0; i--) {
      const h = hits[i];
      if (x >= h.x && x < h.x + h.w && y >= h.y && y < h.y + h.h) {
        return h;
      }
    }
    return null;
  };

  return (
    <Window width={580} height={724}>
      <Window.Content
        style={{
          padding: '8px 16px',
          background: '#14161c',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: '8px',
        }}
      >
        <canvas
          ref={canvasRef}
          style={{
            width: `${NW * SCALE}px`,
            maxWidth: '100%',
            imageRendering: 'pixelated',
            display: 'block',
          }}
          onMouseMove={(e) => {
            const h = hitAt(e);
            view.current.hover = h ? h.act : null;
            e.currentTarget.style.cursor = h ? 'pointer' : 'default';
            e.currentTarget.title = h ? h.tip : '';
          }}
          onMouseLeave={() => {
            view.current.hover = null;
          }}
          onClick={(e) => {
            const h = hitAt(e);
            if (h) {
              handle(h.act);
            }
          }}
        />
        <Input
          fluid
          expensive
          style={{ width: `${NW * SCALE}px`, maxWidth: '100%' }}
          placeholder="Szukaj towaru..."
          value={stockSearch}
          onChange={(value) => {
            setStockSearch(value);
            setPage(0);
            resetSelection();
          }}
        />
      </Window.Content>
    </Window>
  );
};

// --- sprite'y towarów: z .dmi, z base64 albo ze spritesheetu automatów ---

type Sprite = HTMLCanvasElement;
const SPRITES: Record<string, Sprite | null | undefined> = {};
const TINTS: Record<string, HTMLCanvasElement> = {};

/** Adres obrazka towaru i ewentualny wycinek ze spritesheetu */
const spriteSource = (
  product: Product,
): { src: string; sx: number; sy: number } | null => {
  const base64 = product.image || (product as CustomInput).img;
  if (base64) {
    return { src: `data:image/png;base64,${base64}`, sx: 0, sy: 0 };
  }
  const record = product as ProductRecord;
  const ref =
    record.icon && record.icon_state
      ? Byond.iconRefMap?.[record.icon]
      : undefined;
  if (ref) {
    return {
      src: `${ref}?state=${record.icon_state}&dir=2&movement=false&frame=1`,
      sx: 0,
      sy: 0,
    };
  }
  if (!record.path) {
    return null;
  }
  // Spritesheet automatów: odczyt obrazka i przesunięcia z klasy CSS
  const probe = document.createElement('span');
  probe.className = `vending32x32 ${record.path}`;
  probe.style.position = 'absolute';
  probe.style.left = '-9999px';
  document.body.appendChild(probe);
  const style = getComputedStyle(probe);
  const url = /url\(["']?(.*?)["']?\)/.exec(style.backgroundImage)?.[1];
  const [bx, by] = style.backgroundPosition
    .split(' ')
    .map((v) => -parseFloat(v) || 0);
  probe.remove();
  return url ? { src: url, sx: bx, sy: by } : null;
};

/** Sprite przycięty do nieprzezroczystej części, jak w prototypie */
const getSprite = (product: Product): Sprite | null => {
  const key = productKey(product);
  if (key in SPRITES) {
    return SPRITES[key] ?? null;
  }
  SPRITES[key] = null;
  const source = spriteSource(product);
  if (!source) {
    return null;
  }
  const img = new Image();
  img.onload = () => {
    const full = document.createElement('canvas');
    full.width = 32;
    full.height = 32;
    const fx = full.getContext('2d');
    if (!fx) {
      return;
    }
    fx.drawImage(img, source.sx, source.sy, 32, 32, 0, 0, 32, 32);
    let box = { x: 0, y: 0, w: 32, h: 32 };
    try {
      const px = fx.getImageData(0, 0, 32, 32).data;
      let x0 = 32;
      let y0 = 32;
      let x1 = -1;
      let y1 = -1;
      for (let y = 0; y < 32; y++) {
        for (let x = 0; x < 32; x++) {
          if (px[(y * 32 + x) * 4 + 3] > 8) {
            x0 = Math.min(x0, x);
            y0 = Math.min(y0, y);
            x1 = Math.max(x1, x);
            y1 = Math.max(y1, y);
          }
        }
      }
      if (x1 >= 0) {
        box = { x: x0, y: y0, w: x1 - x0 + 1, h: y1 - y0 + 1 };
      }
    } catch {
      // Obrazek z innego źródła: zostaje cały kafelek 32x32
    }
    const out = document.createElement('canvas');
    out.width = box.w;
    out.height = box.h;
    out
      .getContext('2d')
      ?.drawImage(full, box.x, box.y, box.w, box.h, 0, 0, box.w, box.h);
    SPRITES[key] = out;
  };
  img.src = source.src;
  return null;
};

/** Sylwetka sprite'a w jednym kolorze: kolejne sztuki w głębi spirali */
const tinted = (key: string, sprite: Sprite, color: string) => {
  const id = key + color;
  if (TINTS[id]) {
    return TINTS[id];
  }
  const c = document.createElement('canvas');
  c.width = sprite.width;
  c.height = sprite.height;
  const x = c.getContext('2d');
  if (x) {
    x.drawImage(sprite, 0, 0);
    x.globalCompositeOperation = 'source-in';
    x.fillStyle = color;
    x.fillRect(0, 0, c.width, c.height);
  }
  TINTS[id] = c;
  return c;
};

/** Rozmiar sprite'a dopasowany do przegródki szyby (duże ikony są zmniejszane) */
const fit = (sprite: Sprite) => {
  const s = Math.min(1, 28 / sprite.width, 22 / sprite.height);
  return {
    w: Math.max(1, Math.round(sprite.width * s)),
    h: Math.max(1, Math.round(sprite.height * s)),
  };
};

// --- rysowanie automatu (port prototypu „Automat Przekąski”) ---

type Model = {
  slots: Slot[];
  machineName: string;
  user: UserData | null;
  free: boolean;
  ownDepartment: boolean;
  currency: string;
  pages: number;
  page: number;
  categories: string[];
  category: string;
};

/** Wspólne narzędzia jednej klatki rysowania */
type Painter = {
  p: CanvasRenderingContext2D;
  m: Model;
  v: ViewState;
  now: number;
  blink: number;
  hits: Hit[];
  texts: (Text | Ticker)[];
  T: (
    x: number,
    y: number,
    s: string,
    size: number,
    color: string,
    align?: CanvasTextAlign,
    bold?: boolean,
    maxW?: number,
  ) => void;
  rect: (x: number, y: number, w: number, h: number, c: string) => void;
  px: (x: number, y: number, c: string) => void;
};

type Ticker = { ticker: string; x: number; y: number; w: number; h: number };

const drawMachine = (
  g: CanvasRenderingContext2D,
  p: CanvasRenderingContext2D,
  base: HTMLImageElement,
  m: Model,
  v: ViewState,
  now: number,
): Hit[] => {
  const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const texts: (Text | Ticker)[] = [];
  const rect = (x: number, y: number, w: number, h: number, c: string) => {
    p.fillStyle = c;
    p.fillRect(x, y, w, h);
  };
  const P: Painter = {
    p,
    m,
    v,
    now,
    blink: reduced ? 1 : Math.floor(now / 450) % 2,
    hits: [],
    texts,
    T: (x, y, s, size, color, align = 'left', bold = false, maxW = 0) =>
      texts.push({ x, y, s, size, color, align, bold, maxW }),
    rect,
    px: (x, y, c) => rect(x, y, 1, 1, c),
  };

  stepAnimation(m, v, now);
  p.clearRect(0, 0, NW, NH);
  p.drawImage(base, 0, 0);
  drawSign(P, g);
  drawGlass(P);
  drawDisplay(P);
  drawKeypad(P);
  drawCard(P);
  drawControls(P);
  drawTray(P);

  // Obraz w pikselach w skali K, potem napisy Verdaną w pełnej rozdzielczości
  g.imageSmoothingEnabled = false;
  g.clearRect(0, 0, NW * K, NH * K);
  g.drawImage(p.canvas, 0, 0, NW * K, NH * K);
  for (const t of texts) {
    if ('ticker' in t) {
      drawTicker(g, t, now, reduced);
    } else {
      drawText(g, t);
    }
  }
  return P.hits;
};

/** Zakup potwierdzony przez serwer (stan spadł): spirala się obraca, towar spada do podajnika */
const stepAnimation = (m: Model, v: ViewState, now: number) => {
  if (v.pending) {
    const slotIdx = m.slots.findIndex((s) => s.key === v.pending?.key);
    const slot = m.slots[slotIdx];
    if (slot && slot.remaining < v.pending.before) {
      v.anim = {
        key: slot.key,
        idx: slotIdx,
        phase: 'coil',
        t0: now,
        k: 0,
        fy0: 0,
        fy: 0,
        tf: 0,
      };
      v.pending = null;
    } else if (now - v.pending.t > 2500) {
      // Serwer odmówił: powód jest w czacie
      v.pending = null;
      flashView(v, 'ODMOWA', 'patrz czat', 1800, now);
      v.deny = now + 700;
    }
  }
  const a = v.anim;
  if (!a) {
    if (v.tray && now > v.tray.until) {
      v.tray = null;
    }
    return;
  }
  if (a.phase === 'coil') {
    a.k = Math.min(1, (now - a.t0) / 750);
    if (a.k >= 1) {
      const sprite = SPRITES[a.key];
      a.phase = 'fall';
      a.fy0 =
        ROWY[Math.floor(a.idx / COLS)] + 25 - (sprite ? fit(sprite).h : 16);
      a.fy = a.fy0;
      a.tf = now;
    }
    return;
  }
  const t = now - a.tf;
  a.fy = a.fy0 + 0.02 * t + 0.00035 * t * t;
  if (a.fy > 146) {
    v.tray = { key: a.key, until: now + 4000 };
    v.anim = null;
  }
};

/** Szyld: pełna nazwa, a gdy się nie mieści, pierwsze słowo */
const drawSign = (P: Painter, g: CanvasRenderingContext2D) => {
  if (P.v.anim && P.blink) {
    P.rect(71, 1, 35, 4, '#ffffff');
  }
  const sign = P.m.machineName.toUpperCase();
  g.font = `bold ${(9 * K) / 2}px ${FONT}`;
  const text =
    g.measureText(sign).width > 33 * K * 1.6 ? sign.split(' ')[0] : sign;
  P.T(88.5, 5.6, text, 9, '#610b0f', 'center', true, 33);
};

/** Szyba: przegródki, spirale, towar z sylwetkami w głębi i spadający towar */
const drawGlass = (P: Painter) => {
  const { p, v } = P;
  for (let i = 0; i < PER_PAGE; i++) {
    drawCell(P, i);
  }
  if (v.anim && v.anim.phase === 'fall') {
    const sprite = SPRITES[v.anim.key];
    if (sprite) {
      const { w, h } = fit(sprite);
      p.save();
      p.beginPath();
      p.rect(4, 13, 98, 131);
      p.clip();
      p.drawImage(
        sprite,
        COLX[v.anim.idx % COLS] + 16 - Math.floor(w / 2),
        Math.round(v.anim.fy),
        w,
        h,
      );
      p.restore();
    }
  }
  // Odblask szyby
  p.fillStyle = '#ffffff';
  for (let y = 13; y <= 143; y++) {
    for (let x = 4; x <= 101; x++) {
      const d = (x + y) % 97;
      if (d < 3 || d === 8) {
        p.globalAlpha = d < 3 ? 0.16 : 0.1;
        p.fillRect(x, y, 1, 1);
      }
    }
  }
  p.globalAlpha = 1;
};

const drawCell = (P: Painter, i: number) => {
  const { p, m, v, T, rect } = P;
  const slot = m.slots[i];
  const cx = COLX[i % COLS];
  const cy = ROWY[Math.floor(i / COLS)];
  const y0 = cy + 22;
  const anim = v.anim && v.anim.idx === i && v.anim.key === slot?.key;
  const turning = anim && v.anim?.phase === 'coil' ? (v.anim?.k ?? 0) : 0;
  if (v.entry && v.entry === ROW_LETTERS[Math.floor(i / COLS)]) {
    p.globalAlpha = 0.18;
    rect(cx, cy, 32, 28, '#ffffff');
    p.globalAlpha = 1;
  }
  coil(p, cx + 3, y0, turning * 6, false);
  const sprite = slot ? getSprite(slot.product) : null;
  if (slot && sprite) {
    const { w, h } = fit(sprite);
    const ix = cx + 16 - Math.floor(w / 2);
    const iy = y0 + 3 - h;
    // Sztuki w głębi spirali jako coraz jaśniejsze sylwetki
    if (slot.remaining > 2) {
      p.drawImage(tinted(slot.key, sprite, '#82bc3a'), ix + 4, iy - 2, w, h);
    }
    if (slot.remaining > 1) {
      p.drawImage(tinted(slot.key, sprite, '#6fa82d'), ix + 2, iy - 1, w, h);
    }
    if (slot.remaining > 0 || turning) {
      p.drawImage(sprite, ix, iy + Math.round(turning * 2), w, h);
    }
  }
  coil(p, cx + 3, y0, turning * 6, true);
  rect(cx, cy + 28, 32, 4, '#77b531');
  rect(cx, cy + 28, 32, 1, '#5d9128');
  const code = ROW_LETTERS[Math.floor(i / COLS)] + ((i % COLS) + 1);
  T(cx + 1.5, cy + 31.4, code, 6.5, '#1d3008', 'left', true);
  if (!slot) {
    T(cx + 30.5, cy + 31.4, '—', 6.5, '#3d5c18', 'right');
  } else if (slot.remaining > 0) {
    T(
      cx + 30.5,
      cy + 31.4,
      slot.free ? 'ZA DARMO' : `${slot.price}${m.currency}`,
      6.5,
      slot.product.premium ? '#6b1a5e' : '#1d3008',
      'right',
      slot.free,
      21,
    );
  } else {
    T(cx + 30.5, cy + 31.4, 'BRAK', 6.5, '#8e1620', 'right', true);
  }
  if (v.sel === i && !v.anim) {
    p.globalAlpha = P.blink ? 1 : 0.45;
    rect(cx, cy, 32, 1, '#f6ffd0');
    rect(cx, cy + 27, 32, 1, '#f6ffd0');
    rect(cx, cy, 1, 28, '#f6ffd0');
    rect(cx + 31, cy, 1, 28, '#f6ffd0');
    p.globalAlpha = 1;
  }
  P.hits.push({
    x: cx,
    y: cy,
    w: 32,
    h: 32,
    act: `cell:${i}`,
    tip: slot ? cellTip(slot, code, m.currency) : `${code}: pusta półka`,
  });
};

const cellTip = (slot: Slot, code: string, currency: string) => {
  const price = slot.free ? 'za darmo' : `${slot.price}${currency}`;
  const left = slot.remaining ? `zostało ${slot.remaining}` : 'wyprzedane';
  return `${code}: ${cap(slot.product.name)}, ${price} (${left})`;
};

/** Wyświetlacz i pasek z przewijaną nazwą */
const drawDisplay = (P: Painter) => {
  const { m, v, now, T, rect } = P;
  const sel = v.sel !== null ? m.slots[v.sel] : undefined;
  const denying = now < v.deny;
  if (denying) {
    rect(109, 14, 24, 13, '#d9413f');
  }
  const [l1, l2] = displayLines(P, sel);
  T(120.5, 20.2, l1, 8, denying ? '#fff3f0' : '#20330a', 'center', true, 22);
  T(120.5, 25.2, l2, 5.5, denying ? '#fff3f0' : '#2f4a12', 'center', false, 22);
  rect(107, 29, 28, 9, '#0a090d');
  rect(108, 30, 26, 7, '#0f1a08');
  P.texts.push({
    ticker: sel
      ? `${cap(sel.product.name)} · ${sel.remaining ? 'zostało ' + sel.remaining : 'wyprzedane'}`
      : `${m.machineName} · płatność kartą ID`,
    x: 108,
    y: 30,
    w: 26,
    h: 7,
  });
};

const displayLines = (P: Painter, sel?: Slot): [string, string] => {
  const { m, v, now, blink } = P;
  if (v.msg && now < v.msg.until) {
    return v.msg.lines;
  }
  if (v.anim || v.pending) {
    return ['WYDAJĘ…', sel?.code ?? ''];
  }
  if (v.tray) {
    return [blink ? 'WYDANO' : '', 'towar w ręce'];
  }
  if (v.entry) {
    return [`${v.entry} _`, 'wpisz cyfrę'];
  }
  if (sel) {
    return [
      `${sel.code}  ${sel.free ? '0' : sel.price}${m.currency}`,
      'OK = kup',
    ];
  }
  return ['WYBIERZ', 'kod lub półka'];
};

const drawKeypad = (P: Painter) => {
  const { v, now, T } = P;
  KEYS.forEach((row, r) =>
    row.forEach((k, c) => {
      const x = KX[c];
      const y = KY[r];
      const down = !!v.pressed && v.pressed.k === k && now - v.pressed.t < 140;
      const face = k === 'OK' ? '#77b531' : k === 'X' ? '#b3252a' : '#8a8f8f';
      bevelKey(P.p, x, y, 8, 8, face, down, v.hover === `key:${k}`);
      const nudge = down ? 0.25 : 0;
      T(
        x + 4 + nudge,
        y + 6.3 + nudge,
        k === 'X' ? '✕' : k,
        k === 'OK' ? 5.5 : 7,
        k === 'X' ? '#ffffff' : '#17171f',
        'center',
        true,
      );
      P.hits.push({
        x,
        y,
        w: 8,
        h: 8,
        act: `key:${k}`,
        tip: KEY_TIPS[k] ?? `Klawisz ${k}`,
      });
    }),
  );
};

const KEY_TIPS: Record<string, string> = {
  X: 'Wyczyść wybór',
  OK: 'Kup wybrany towar',
};

/** Czytnik: karta jest w nim, gdy gracz ma ID w ręce albo w slocie */
const drawCard = (P: Painter) => {
  const { m, blink, T, rect } = P;
  const card = m.user;
  const ok = !!card || m.free;
  rect(107, 69, 28, 22, '#0a090d');
  rect(108, 70, 26, 20, '#17171f');
  rect(108, 70, 26, 1, '#2c2c38');
  rect(108, 89, 26, 1, '#3b454b');
  rect(130, 72, 2, 2, ok ? '#02ff23' : blink ? '#ff1c00' : '#730000');
  if (card) {
    rect(113, 72, 16, 9, '#e9eef5');
    rect(113, 72, 16, 2, m.ownDepartment ? '#3fae45' : '#2b6cc4');
    rect(113, 72, 1, 9, '#ffffff');
    rect(128, 72, 1, 9, '#9aa1ad');
    rect(115, 75, 4, 4, '#d89a52');
    rect(116, 75, 2, 1, '#6b3a1f');
    rect(120, 76, 6, 1, '#8a919c');
    rect(120, 78, 5, 1, '#8a919c');
  }
  rect(110, 80, 22, 1, '#000000');
  rect(110, 81, 22, 1, '#3b454b');
  const label = card
    ? (card.name || 'Nieznany').toUpperCase()
    : m.free
      ? 'BEZ KARTY'
      : 'BRAK KARTY';
  const labelColor = ok || !blink ? '#8a919c' : '#e4ff02';
  T(121, 87.6, label, 4.6, labelColor, 'center', true, 25);
  P.hits.push({
    x: 107,
    y: 69,
    w: 28,
    h: 22,
    act: 'card',
    tip: card
      ? `Karta: ${card.name}, ${card.job}`
      : 'Brak karty ID w ręce ani w slocie',
  });
  rect(107, 93, 28, 8, '#0a090d');
  rect(108, 94, 26, 6, '#0f1a08');
  const account = m.free
    ? 'ZA DARMO'
    : card
      ? `KONTO ${card.cash || 0}${m.currency}`
      : 'BRAK KONTA';
  T(121, 98.9, account, 4.8, ok ? '#9bd143' : '#5d9128', 'center', true, 24);
};

/** Pod czytnikiem: głośnik, a gdy trzeba, półki, kategoria i kolor */
const drawControls = (P: Painter) => {
  const { m, v, T, rect, px } = P;
  for (let j = 0; j < 5; j++) {
    for (let i = 0; i < 8; i++) {
      px(110 + i * 3, 105 + j * 3, '#0a090d');
      px(110 + i * 3, 106 + j * 3, '#2c2c38');
    }
  }
  for (let x = 108; x < 134; x++) {
    for (let y = 122; y < 127; y++) {
      px(x, y, ((x + y) >> 1) % 2 ? '#e8b923' : '#17171f');
    }
  }
  rect(108, 121, 26, 1, '#0a090d');
  rect(108, 127, 26, 1, '#0a090d');
  if (m.pages > 1) {
    rect(107, 102, 28, 10, '#0a090d');
    rect(108, 103, 26, 8, '#17171f');
    pageKey(P, 'page:-1', 108, '◀', 'Poprzednia półka');
    pageKey(P, 'page:1', 126, '▶', 'Następna półka');
    T(121, 109.2, `${m.page + 1}/${m.pages}`, 5, '#9bd143', 'center', true, 9);
  }
  if (m.categories.length > 1) {
    const contraband = m.category === 'Kontrabanda';
    const face = contraband
      ? '#b3252a'
      : m.category === 'Premium'
        ? '#e8b923'
        : '#8a8f8f';
    bevelKey(P.p, 108, 113, 26, 8, face, false, v.hover === 'cat');
    T(
      121,
      119.2,
      m.category.toUpperCase(),
      5,
      contraband ? '#ffffff' : '#17171f',
      'center',
      true,
      24,
    );
    P.hits.push({
      x: 108,
      y: 113,
      w: 26,
      h: 8,
      act: 'cat',
      tip: 'Następna kategoria',
    });
  }
  const sel = v.sel !== null ? m.slots[v.sel] : undefined;
  if (sel?.colorable) {
    bevelKey(P.p, 108, 122, 26, 8, '#e8b923', false, v.hover === 'color');
    T(121, 128.2, 'KOLOR', 5, '#17171f', 'center', true);
    P.hits.push({
      x: 108,
      y: 122,
      w: 26,
      h: 8,
      act: 'color',
      tip: 'Zmień kolor wybranego towaru',
    });
  }
  for (const [x, y] of [
    [109, 133],
    [132, 133],
  ]) {
    rect(x - 1, y - 1, 3, 3, '#3b454b');
    rect(x - 1, y - 1, 2, 2, '#8a919c');
    px(x, y, '#17171f');
  }
  for (let y = 137; y < 145; y += 2) {
    rect(112, y, 18, 1, '#0a090d');
    rect(112, y + 1, 18, 1, '#2c2c38');
  }
};

const pageKey = (
  P: Painter,
  act: string,
  x: number,
  label: string,
  tip: string,
) => {
  bevelKey(P.p, x, 103, 8, 8, '#8a8f8f', false, P.v.hover === act);
  P.T(x + 4, 109.4, label, 5, '#17171f', 'center', true);
  P.hits.push({ x, y: 103, w: 8, h: 8, act, tip });
};

/** Podajnik: wydany towar widać przez chwilę za klapką */
const drawTray = (P: Painter) => {
  const { p, v, blink, T, rect } = P;
  if (v.tray) {
    const sprite = SPRITES[v.tray.key];
    rect(5, 148, 127, 3, '#0a090d');
    if (sprite) {
      const { w, h } = fit(sprite);
      p.save();
      p.beginPath();
      p.rect(5, 148, 127, 3);
      p.clip();
      p.drawImage(sprite, 68 - Math.floor(w / 2), 148, w, h);
      p.restore();
    }
    rect(5, 151, 127, 1, '#cbcdd1');
  }
  T(
    68.5,
    154.9,
    v.tray ? 'ODBIERZ' : 'PCHNIJ',
    5,
    v.tray && blink ? '#17171f' : '#59454b',
    'center',
    true,
  );
  P.hits.push({
    x: 2,
    y: 147,
    w: 133,
    h: 10,
    act: 'tray',
    tip: v.tray ? 'Towar jest już w ręce' : 'Podajnik',
  });
};

/** Napis Verdaną; za długi zmniejsza się do maxW */
const drawText = (g: CanvasRenderingContext2D, t: Text) => {
  let size = (t.size * K) / 2;
  g.font = `${t.bold ? 'bold ' : ''}${size}px ${FONT}`;
  if (t.maxW) {
    const w = g.measureText(t.s).width;
    if (w > t.maxW * K) {
      size = Math.floor((size * t.maxW * K) / w);
      g.font = `${t.bold ? 'bold ' : ''}${size}px ${FONT}`;
    }
  }
  g.textAlign = t.align;
  g.textBaseline = 'alphabetic';
  g.fillStyle = t.color;
  g.fillText(t.s, t.x * K, t.y * K);
};

const flashView = (
  v: ViewState,
  l1: string,
  l2: string,
  ms: number,
  now: number,
) => {
  v.msg = { lines: [l1, l2], until: now + ms };
};

/** Spirala: tylne zwoje za towarem, przednie przed nim; faza obraca ją przy wydawaniu */
const coil = (
  p: CanvasRenderingContext2D,
  x0: number,
  y0: number,
  phase: number,
  front: boolean,
) => {
  const px = (x: number, y: number, c: string) => {
    p.fillStyle = c;
    p.fillRect(x, y, 1, 1);
  };
  if (!front) {
    p.fillStyle = '#5d9128';
    p.fillRect(x0 - 2, y0 + 5, 30, 1);
  }
  const off = Math.round(phase) % 6;
  for (let k = -1; k < 6; k++) {
    const x = x0 + k * 5 + off;
    for (let i = 0; i < 5; i++) {
      const fx = x + i;
      const bx = x + 1 + i;
      if (front && fx >= x0 && fx <= x0 + 25) {
        px(fx, y0 + 4 - i, '#e8ffad');
        if (i < 4) {
          px(fx + 1, y0 + 4 - i, '#6fa82d');
        }
      }
      if (!front && bx >= x0 && bx <= x0 + 25 && i % 2 === 0) {
        px(bx, y0 + i, '#86c23c');
      }
    }
  }
};

/** Wypukły klawisz; wciśnięty ma odwrócone cienie */
const bevelKey = (
  p: CanvasRenderingContext2D,
  x: number,
  y: number,
  w: number,
  h: number,
  face: string,
  down: boolean,
  hover: boolean,
) => {
  const rect = (rx: number, ry: number, rw: number, rh: number, c: string) => {
    p.fillStyle = c;
    p.fillRect(rx, ry, rw, rh);
  };
  const lt = down ? '#3b454b' : '#cbcdd1';
  const dk = down ? '#cbcdd1' : '#3b454b';
  rect(x - 1, y - 1, w + 2, h + 2, '#0a090d');
  rect(x, y, w, h, face);
  if (hover && !down) {
    rect(x + 1, y + 1, w - 2, h - 2, shade(face, 0.18));
  }
  rect(x, y, w, 1, lt);
  rect(x, y, 1, h, lt);
  rect(x, y + h - 1, w, 1, dk);
  rect(x + w - 1, y, 1, h, dk);
};

/** Pasek z przewijanym napisem pod wyświetlaczem */
const drawTicker = (
  g: CanvasRenderingContext2D,
  t: { ticker: string; x: number; y: number; w: number; h: number },
  now: number,
  reduced: boolean,
) => {
  g.save();
  g.beginPath();
  g.rect(t.x * K, t.y * K, t.w * K, t.h * K);
  g.clip();
  g.font = `bold ${(5 * K) / 2}px ${FONT}`;
  g.textBaseline = 'alphabetic';
  g.fillStyle = '#9bd143';
  const tw = g.measureText(t.ticker).width;
  const box = t.w * K;
  const y = (t.y + 5.4) * K;
  if (tw > box - 8 && !reduced) {
    const span = tw + 60;
    const x = t.x * K + box - 4 - ((now / 22) % span);
    g.textAlign = 'left';
    g.fillText(t.ticker, x, y);
    g.fillText(t.ticker, x + span, y);
  } else if (tw > box - 8) {
    g.textAlign = 'left';
    g.fillText(t.ticker, t.x * K + 4, y);
  } else {
    g.textAlign = 'center';
    g.fillText(t.ticker, (t.x + t.w / 2) * K, y);
  }
  g.restore();
};
