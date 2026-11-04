import { useEffect, useState } from 'react';
import { DmIcon, Input } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PixelText, shade } from './common/PixelArt';

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
  code: string;
  remaining: number;
  free: boolean;
  price: number;
  colorable: boolean;
  /** Powód, dla którego nie da się kupić, albo null */
  blocked: string | null;
};

const COLS = 4;
const ROWS = 4;
const PER_PAGE = COLS * ROWS;
const ROW_LETTERS = 'ABCD';

/** Kolory szyldu; automat dostaje stały kolor z nazwy */
const ACCENTS = [
  '#a32d2d',
  '#2f6fd0',
  '#3b6d11',
  '#c46a1a',
  '#6a3ab0',
  '#1d8a7a',
];

const accentOf = (name: string) => {
  let h = 0;
  for (let i = 0; i < name.length; i++) {
    h = (h * 31 + name.charCodeAt(i)) >>> 0;
  }
  return ACCENTS[h % ACCENTS.length];
};

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
    displayed_currency_name,
  } = data;

  const [selectedCategory, setSelectedCategory] = useState(
    Object.keys(categories)[0],
  );
  const [stockSearch, setStockSearch] = useState('');
  const [page, setPage] = useState(0);
  const [code, setCode] = useState('');
  const [message, setMessage] = useState<string | null>(null);
  const [dropped, setDropped] = useState<{ product: Product; n: number }>();
  /** Zakup wysłany do serwera; towar spada dopiero, gdy ubędzie go w danych */
  const [pending, setPending] = useState<{
    product: Product;
    before: number;
  }>();

  useEffect(() => {
    if (!dropped) {
      return;
    }
    const timer = setTimeout(() => setDropped(undefined), 1600);
    return () => clearTimeout(timer);
  }, [dropped]);

  useEffect(() => {
    if (!pending) {
      return;
    }
    const { product, before } = pending;
    const now: number | undefined = data.vending_machine_input
      ? data.vending_machine_input.find((item) => item.name === product.name)
          ?.amount
      : product.path
        ? stock[product.path]?.amount
        : undefined;
    if (now !== undefined && now < before) {
      setDropped({ product, n: Date.now() });
      setPending(undefined);
      setMessage(null);
      return;
    }
    // Serwer odmówił (komunikat jest w czacie): po chwili czyścimy ekran
    const timer = setTimeout(() => {
      setPending(undefined);
      setMessage(null);
    }, 2500);
    return () => clearTimeout(timer);
  }, [pending, stock, data.vending_machine_input]);

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
  const shown = inventory.filter(
    (product) =>
      searching ||
      custom ||
      filteredCategories.length < 2 ||
      product.category === selectedCategory,
  );

  const pages = Math.max(1, Math.ceil(shown.length / PER_PAGE));
  const currentPage = Math.min(page, pages - 1);
  const pageItems = shown.slice(
    currentPage * PER_PAGE,
    (currentPage + 1) * PER_PAGE,
  );

  const slots: Slot[] = pageItems.map((product, idx) => {
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
      blocked = 'Wyprzedane';
    } else if (!all_products_free && !user) {
      blocked = 'Brak karty';
    } else if (!free && !access && price > (user?.cash ?? 0)) {
      blocked = 'Za mało środków';
    }
    return {
      product,
      code: ROW_LETTERS[Math.floor(idx / COLS)] + ((idx % COLS) + 1),
      remaining,
      free,
      price,
      colorable: !!productStock?.colorable,
      blocked,
    };
  });

  const selected = slots.find((slot) => slot.code === code);

  const changePage = (step: number) => {
    setPage((currentPage + step + pages) % pages);
    setCode('');
    setMessage(null);
  };

  const buy = (slot?: Slot) => {
    if (!slot) {
      setMessage(code.length === 2 ? 'Pusta spirala' : 'Wpisz kod, np. B2');
      return;
    }
    if (slot.blocked) {
      setMessage(slot.blocked);
      return;
    }
    if (custom) {
      act('dispense', { item: slot.product.name });
    } else {
      const record = slot.product as ProductRecord;
      act('vend', { ref: record.ref, discountless: !!record.premium });
    }
    setPending({ product: slot.product, before: slot.remaining });
    setMessage('Wydaję...');
    setCode('');
  };

  const pick = (slot: Slot) => {
    if (code === slot.code) {
      buy(slot);
      return;
    }
    setCode(slot.code);
    setMessage(null);
  };

  const press = (key: string) => {
    setMessage(null);
    if (key === 'C') {
      setCode('');
    } else if (key === 'OK') {
      buy(selected);
    } else if (ROW_LETTERS.includes(key)) {
      setCode(key);
    } else if (code.length === 1) {
      setCode(code + key);
    }
  };

  const accent = accentOf(machine_name);

  return (
    <Window width={600} height={600}>
      <Window.Content style={{ padding: 0 }}>
        <div className="AqVend">
          <Screw corner="tl" />
          <Screw corner="tr" />
          <Screw corner="bl" />
          <Screw corner="br" />
          <div className="AqVend__sign">
            <div className="AqPixel-hazard" />
            <div
              className="AqVend__plate"
              style={{
                background: accent,
                borderColor: `${shade(accent, 0.35)} ${shade(accent, -0.5)} ${shade(accent, -0.5)} ${shade(accent, 0.35)}`,
              }}
            >
              <PixelText text={machine_name} scale={3} color="#ffe0a0" />
            </div>
            <div className="AqPixel-hazard" />
          </div>
          <div className="AqVend__body">
            <div className="AqVend__glass AqPixel-inset">
              {slots.map((slot) => (
                <ProductSlot
                  key={slot.product.path || slot.product.name}
                  slot={slot}
                  selected={slot.code === code}
                  onClick={() => pick(slot)}
                />
              ))}
              {!slots.length && (
                <div className="AqVend__empty">
                  <PixelText
                    text={searching ? 'Nic nie pasuje' : 'Automat pusty'}
                    color="#4a505c"
                  />
                </div>
              )}
            </div>
            <div className="AqVend__panel">
              <Display
                code={code}
                slot={selected}
                message={message}
                currency={displayed_currency_name}
                page={currentPage}
                pages={pages}
              />
              <CardReader
                user={user}
                onstation={onstation}
                free={all_products_free}
                currency={displayed_currency_name}
                busy={!!pending || !!dropped}
              />
              <div className="AqVend__keypad">
                {['A', 'B', 'C', 'D', '1', '2', '3', '4'].map((key) => (
                  <Key key={key} onClick={() => press(key)}>
                    <PixelText text={key} />
                  </Key>
                ))}
                <Key variant="cancel" onClick={() => press('C')} tip="Wyczyść">
                  <PixelText text="X" />
                </Key>
                <Key
                  variant="ok"
                  wide
                  onClick={() => press('OK')}
                  tip="Kup wybrany towar"
                >
                  <PixelText text="OK" />
                </Key>
                <Key
                  disabled={!selected?.colorable}
                  onClick={() =>
                    selected &&
                    act('select_colors', {
                      ref: (selected.product as ProductRecord).ref,
                    })
                  }
                  tip="Zmień kolor"
                >
                  <PixelText text="*" color="#e8b923" />
                </Key>
              </div>
              <div className="AqVend__shelf">
                <Key onClick={() => changePage(-1)} tip="Poprzednia półka">
                  <PixelText text="<" />
                </Key>
                <PixelText
                  text={`Półka ${currentPage + 1}/${pages}`}
                  color="#c9ced6"
                />
                <Key onClick={() => changePage(1)} tip="Następna półka">
                  <PixelText text=">" />
                </Key>
              </div>
            </div>
          </div>
          <div className="AqVend__bottom">
            <div className="AqVend__tray AqPixel-inset">
              <div className="AqVend__flap" />
              {dropped ? (
                <div key={dropped.n} className="AqVend__dropped">
                  <ProductImage product={dropped.product} />
                </div>
              ) : (
                <PixelText text="Podajnik" color="#4a505c" />
              )}
            </div>
            <div className="AqVend__controls">
              <Input
                fluid
                expensive
                className="AqVend__search"
                placeholder="Szukaj towaru..."
                value={stockSearch}
                onChange={(value) => {
                  setStockSearch(value);
                  setPage(0);
                  setCode('');
                }}
              />
              {!searching && !custom && filteredCategories.length > 1 && (
                <div className="AqVend__categories">
                  {filteredCategories.map((name) => (
                    <Key
                      key={name}
                      on={name === selectedCategory}
                      variant={
                        name === 'Kontrabanda'
                          ? 'cancel'
                          : name === 'Premium'
                            ? 'gold'
                            : undefined
                      }
                      onClick={() => {
                        setSelectedCategory(name);
                        setPage(0);
                        setCode('');
                      }}
                    >
                      <PixelText text={name} />
                    </Key>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

const Screw = (props: { corner: 'tl' | 'tr' | 'bl' | 'br' }) => (
  <div className={`AqPixel-screw AqPixel-screw--${props.corner}`} />
);

type KeyProps = {
  children: React.ReactNode;
  onClick: () => void;
  tip?: string;
  on?: boolean;
  wide?: boolean;
  disabled?: boolean;
  variant?: 'ok' | 'cancel' | 'gold';
};

/** Pikselowy klawisz z wypukłą ramką, wciskany przy kliknięciu */
const Key = (props: KeyProps) => {
  const { children, onClick, tip, on, wide, disabled, variant } = props;
  return (
    <div
      className={classes([
        'AqPixel-key',
        on && 'AqPixel-key--on',
        wide && 'AqPixel-key--wide',
        disabled && 'AqPixel-key--disabled',
        variant && `AqPixel-key--${variant}`,
      ])}
      title={tip}
      onClick={disabled ? undefined : onClick}
    >
      {children}
    </div>
  );
};

/** Ikona produktu: base64, prosto z .dmi albo ze spritesheetu automatów */
const ProductImage = (props: { product: Product }) => {
  const { product } = props;
  const base64 = product.image || (product as CustomInput).img;
  if (base64) {
    return (
      <img
        className="AqVend__img"
        src={`data:image/png;base64,${base64}`}
        width={64}
        height={64}
      />
    );
  }
  const record = product as ProductRecord;
  if (record.icon && record.icon_state) {
    return (
      <DmIcon
        icon={record.icon}
        icon_state={record.icon_state}
        width="64px"
        height="64px"
        style={{ imageRendering: 'pixelated' }}
      />
    );
  }
  return (
    <span className={classes(['vending32x32', record.path, 'AqVend__sheet'])} />
  );
};

type ProductSlotProps = {
  slot: Slot;
  selected: boolean;
  onClick: () => void;
};

const ProductSlot = (props: ProductSlotProps) => {
  const { slot, selected, onClick } = props;
  const { product, code, remaining, free, price, blocked } = slot;
  const soldOut = remaining === 0;
  return (
    <div
      className={classes([
        'AqVend__slot',
        selected && 'AqVend__slot--selected',
      ])}
      title={`${product.name} (zostało: ${remaining})`}
      onClick={onClick}
    >
      <div className="AqVend__image">
        {!soldOut && <ProductImage product={product} />}
        {soldOut && <div className="AqVend__soldout" />}
      </div>
      <div className="AqVend__coil" />
      <div className="AqVend__tag">
        <PixelText text={code} color={selected ? '#071a0e' : '#e8b923'} />
        <PixelText
          text={soldOut ? 'Brak' : free ? 'Gratis' : `${price}`}
          color={
            selected
              ? '#071a0e'
              : soldOut || blocked
                ? '#ff3e5f'
                : free
                  ? '#5dff8f'
                  : '#c9ced6'
          }
        />
      </div>
    </div>
  );
};

type DisplayProps = {
  code: string;
  slot?: Slot;
  message: string | null;
  currency: string;
  page: number;
  pages: number;
};

/** Zielony ekran nad klawiaturą: kod, nazwa, cena i komunikaty */
const Display = (props: DisplayProps) => {
  const { code, slot, message, currency, page, pages } = props;
  const lines: [string, string][] = [];
  lines.push([`Kod ${code || '--'}`, '#5dff8f']);
  if (slot) {
    const name = slot.product.name;
    lines.push([name.slice(0, 22), '#5dff8f']);
    if (name.length > 22) {
      lines.push([name.slice(22, 44), '#5dff8f']);
    }
    lines.push([
      slot.free ? 'Za darmo' : `Cena: ${slot.price}${currency}`,
      '#e8b923',
    ]);
    lines.push([`Zostało: ${slot.remaining}`, '#5dff8f']);
  } else {
    lines.push(['Wybierz towar', '#5dff8f']);
    lines.push([`Półka ${page + 1} z ${pages}`, '#1f6b38']);
  }
  if (message) {
    lines.push([message, slot?.blocked ? '#ff3e5f' : '#e8b923']);
  }
  return (
    <div className="AqVend__display AqPixel-crt AqPixel-inset">
      {lines.map(([text, color], n) => (
        <div key={n}>
          <PixelText text={text} color={color} />
        </div>
      ))}
    </div>
  );
};

type CardReaderProps = {
  user: UserData | null;
  onstation: boolean;
  free: boolean;
  currency: string;
  busy: boolean;
};

const CardReader = (props: CardReaderProps) => {
  const { user, onstation, free, currency, busy } = props;
  return (
    <div className="AqVend__card">
      <div className="AqVend__reader AqPixel-raised">
        <div className="AqVend__readerSlot" />
        <div
          className={classes([
            'AqVend__led',
            busy && 'AqVend__led--busy',
            !user && !free && 'AqVend__led--none',
          ])}
        />
      </div>
      {free || !onstation ? (
        <PixelText text="Wszystko za darmo" color="#5dff8f" />
      ) : user ? (
        <>
          <PixelText
            text={(user.name || 'Nieznany').slice(0, 22)}
            color="#e6e9ee"
          />
          <PixelText text={(user.job || '').slice(0, 22)} color="#9aa1ad" />
          <PixelText
            text={`${user.cash || 0}${currency}`}
            color="#e8b923"
            scale={3}
          />
        </>
      ) : (
        <>
          <PixelText text="Brak karty" color="#ff3e5f" />
          <PixelText text="Zgłoś się do HoP" color="#9aa1ad" />
        </>
      )}
    </div>
  );
};
