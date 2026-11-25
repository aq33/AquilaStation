/**
 * PixelUi: wspólne kontrolki okien w formie urządzeń (mikrofalówka, młynek,
 * dozowniki, blok utylizacyjny, pulpit fabrykatora).
 *
 * Wzorowane na PixelUi z Polonium Station (polonium14/polonium-station#1280).
 * Wszystko jest rysowane w pikselach grafiki: jeden piksel grafiki to
 * SCALE pikseli ekranu, więc pixel art się nie rozmywa. Współrzędne
 * w propsach są zawsze w pikselach grafiki.
 */

import {
  CSSProperties,
  MouseEvent,
  PropsWithChildren,
  ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { classes } from 'tgui-core/react';

import { dragStartHandler } from '../../drag';
import { closeWindow, Window } from '../../layouts/Window';

/** Ile pikseli ekranu zajmuje jeden piksel grafiki. */
export const SCALE = 2;

export const px = (value: number) => `${value * SCALE}px`;

type BoxProps = PropsWithChildren<{
  x: number;
  y: number;
  w?: number;
  h?: number;
  className?: string;
  style?: CSSProperties;
  /** Przytrzymanie tego elementu przesuwa okno. */
  drag?: boolean;
  title?: string;
  onClick?: (event: MouseEvent<HTMLDivElement>) => void;
  onMouseEnter?: () => void;
  onMouseLeave?: () => void;
}>;

/** Element ustawiony w pikselach grafiki. */
export const Px = (props: BoxProps) => {
  const {
    x,
    y,
    w,
    h,
    className,
    style,
    drag,
    title,
    onClick,
    onMouseEnter,
    onMouseLeave,
    children,
  } = props;
  return (
    <div
      className={classes(['PixelUi__box', className])}
      data-drag={drag ? '1' : undefined}
      title={title}
      onClick={onClick}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      style={{
        left: px(x),
        top: px(y),
        width: w === undefined ? undefined : px(w),
        height: h === undefined ? undefined : px(h),
        ...style,
      }}
    >
      {children}
    </div>
  );
};

type SpriteProps = BoxProps & {
  /** Klasa obrazka z PixelUi.scss, np. "microwave-body". */
  img: string;
};

/** Grafika z assets/pixelui w naturalnym rozmiarze (w/h w pikselach grafiki). */
export const Sprite = (props: SpriteProps) => {
  const { img, className, ...rest } = props;
  return (
    <Px
      {...rest}
      className={classes(['PixelUi__img', `PixelUi__img--${img}`, className])}
    />
  );
};

type AtlasProps = BoxProps & {
  img: string;
  /** Rozmiar całego atlasu w pikselach grafiki. */
  atlas: [number, number];
  /** Lewy górny róg wycinka w atlasie. */
  at: [number, number];
  w: number;
  h: number;
};

/** Wycinek atlasu grafik (w, h: rozmiar wycinka). */
export const AtlasSprite = (props: AtlasProps) => {
  const { img, atlas, at, style, className, ...rest } = props;
  return (
    <Px
      {...rest}
      className={classes(['PixelUi__atlas', `PixelUi__img--${img}`, className])}
      style={{
        backgroundSize: `${px(atlas[0])} ${px(atlas[1])}`,
        backgroundPosition: `${px(-at[0])} ${px(-at[1])}`,
        ...style,
      }}
    />
  );
};

type RoundKeyProps = {
  x: number;
  y: number;
  /** Bok klawisza (kwadratowy wycinek). */
  size: number;
  img: string;
  atlas: [number, number];
  up: [number, number];
  down: [number, number];
  latched?: boolean;
  disabled?: boolean;
  tooltip?: string;
  onClick?: () => void;
  children?: ReactNode;
};

/** Okrągły klawisz z atlasu (wycinek zwolniony i wciśnięty), z ikoną w środku. */
export const RoundKey = (props: RoundKeyProps) => {
  const {
    x,
    y,
    size,
    img,
    atlas,
    up,
    down,
    latched,
    disabled,
    tooltip,
    onClick,
    children,
  } = props;
  const [pressed, setPressed] = useState(false);
  const shown = latched || (pressed && !disabled) ? down : up;
  return (
    <Px
      x={x}
      y={y}
      w={size}
      h={size}
      title={tooltip}
      className={classes([
        'PixelUi__roundKey',
        disabled && 'PixelUi__roundKey--disabled',
      ])}
      onClick={disabled ? undefined : onClick}
    >
      <div
        className="PixelUi__roundKeyHit"
        onMouseDown={() => setPressed(true)}
        onMouseUp={() => setPressed(false)}
        onMouseLeave={() => setPressed(false)}
      />
      <AtlasSprite
        img={img}
        atlas={atlas}
        at={shown}
        x={0}
        y={0}
        w={size}
        h={size}
        style={{ pointerEvents: 'none' }}
      />
      <div
        className="PixelUi__roundKeyFace"
        style={{ top: latched || pressed ? px(1) : 0 }}
      >
        {children}
      </div>
    </Px>
  );
};

/** Prostokąt w jednolitym kolorze. */
export const Rect = (props: BoxProps & { color: string }) => {
  const { color, style, ...rest } = props;
  return <Px {...rest} style={{ background: color, ...style }} />;
};

type TextProps = {
  x: number;
  y: number;
  w?: number;
  color?: string;
  /** "tiny" (Tiny5), "screen" (Jersey 10), "screenBig" (Jersey 15), "plain" (font gry). */
  font?: 'tiny' | 'screen' | 'screenBig' | 'plain';
  align?: 'left' | 'center' | 'right';
  className?: string;
  title?: string;
  children: ReactNode;
};

/** Tekst pikselowym fontem. y to górna krawędź wielkich liter. */
export const PixelText = (props: TextProps) => {
  const {
    x,
    y,
    w,
    color,
    font = 'tiny',
    align = 'left',
    className,
    title,
    children,
  } = props;
  return (
    <Px
      x={x}
      y={y}
      w={w}
      title={title}
      className={classes([
        'PixelUi__text',
        `PixelUi__text--${font}`,
        className,
      ])}
      style={{ color, textAlign: align }}
    >
      {children}
    </Px>
  );
};

type KeyProps = {
  x: number;
  y: number;
  w: number;
  h: number;
  skin?: 'light' | 'green' | 'dark' | 'red';
  /** Zestaw skórek: wspólne z PixelUi albo pulpitu fabrykatora. */
  set?: 'pixelui' | 'lathe';
  text?: ReactNode;
  textColor?: string;
  /** Lampka w rogu: undefined = brak, true/false = zapalona/zgaszona. */
  lamp?: boolean;
  /** Klawisz zostaje wciśnięty. */
  latched?: boolean;
  disabled?: boolean;
  tooltip?: string;
  onClick?: () => void;
  children?: ReactNode;
};

/** Klawisz ze skórką dziewięciopolową (stan zwolniony i wciśnięty). */
export const PixelKey = (props: KeyProps) => {
  const {
    x,
    y,
    w,
    h,
    skin = 'light',
    set = 'pixelui',
    text,
    textColor = '#2b2b2b',
    lamp,
    latched,
    disabled,
    tooltip,
    onClick,
    children,
  } = props;
  const off = disabled && !latched;
  return (
    <div
      className={classes([
        'PixelUi__key',
        `PixelUi__key--${set}-${skin}`,
        latched && 'PixelUi__key--latched',
        off && 'PixelUi__key--disabled',
      ])}
      title={tooltip}
      style={{ left: px(x), top: px(y), width: px(w), height: px(h) }}
      onClick={off ? undefined : onClick}
    >
      <div className="PixelUi__keyFace" style={{ color: textColor }}>
        {text}
        {children}
      </div>
      {lamp !== undefined && (
        <div
          className="PixelUi__keyLamp"
          style={{ background: lamp ? '#30f050' : '#645951' }}
        />
      )}
    </div>
  );
};

const DIGIT_ADVANCE = 11;
const COLON_ADVANCE = 5;

/** Wyświetlacz siedmiosegmentowy z segments.png (cyfry i dwukropek). */
export const Segments = (props: {
  x: number;
  y: number;
  text: string;
  lit?: string;
  ghost?: string;
}) => {
  const { x, y, text, lit = '#30f050', ghost = '#042b0b' } = props;
  const cells: ReactNode[] = [];
  let cursor = x;
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    if (char === ':') {
      cells.push(
        <SegmentCell key={i} x={cursor - 2} y={y} index={11} color={lit} />,
      );
      cursor += COLON_ADVANCE;
      continue;
    }
    cells.push(
      <SegmentCell key={`g${i}`} x={cursor} y={y} index={10} color={ghost} />,
    );
    if (char >= '0' && char <= '9') {
      cells.push(
        <SegmentCell
          key={i}
          x={cursor}
          y={y}
          index={char.charCodeAt(0) - 48}
          color={lit}
        />,
      );
    }
    cursor += DIGIT_ADVANCE;
  }
  return <div>{cells}</div>;
};

const SegmentCell = (props: {
  x: number;
  y: number;
  index: number;
  color: string;
}) => (
  <Px
    x={props.x}
    y={props.y}
    w={8}
    h={14}
    className="PixelUi__segment"
    style={{
      backgroundColor: props.color,
      WebkitMaskPosition: `${-props.index * 8 * SCALE}px 0`,
      maskPosition: `${-props.index * 8 * SCALE}px 0`,
    }}
  />
);

/** Ikona przedmiotu z serwera (base64 PNG 32x32) w skali grafiki. */
export const ItemIcon = (props: {
  x: number;
  y: number;
  icon?: string;
  /** Ile pikseli grafiki na piksel sprite'a. */
  scale?: number;
  size?: number;
  className?: string;
  style?: CSSProperties;
  title?: string;
  onClick?: () => void;
  onMouseEnter?: () => void;
  onMouseLeave?: () => void;
}) => {
  const { icon, scale = 1, size = 32, x, y, className, style, ...rest } = props;
  const span = size * scale;
  return (
    <Px
      x={x}
      y={y}
      w={span}
      h={span}
      className={classes(['PixelUi__item', className])}
      style={{
        backgroundImage: icon ? `url(data:image/png;base64,${icon})` : 'none',
        ...style,
      }}
      {...rest}
    />
  );
};

export type NoteRow = {
  key: string;
  text: string;
  /** Liczba sztuk przed nazwą („2×”), osobno, żeby nazwa z DM dała się przetłumaczyć */
  count?: number;
  /** Kolor kwadracika przed tekstem (np. kolor reagentu). */
  swatch?: string;
  /** Tekst skreślony (np. zużyty, wyjęty). */
  struck?: boolean;
  title?: string;
  onClick?: () => void;
};

export type NoteSection = {
  /** Linia nagłówka (od górnej krawędzi kartki). */
  top: number;
  heading: ReactNode;
  rows: NoteRow[];
  empty?: string;
  maxRows?: number;
};

/** Kartka z listami: każda sekcja ma nagłówek i wiersze na liniach papieru. */
export const PixelNote = (props: {
  x: number;
  y: number;
  w: number;
  h: number;
  img: string;
  sections: NoteSection[];
  hovered?: string;
  onHover?: (key?: string) => void;
}) => {
  const { x, y, w, h, img, sections, hovered, onHover } = props;
  return (
    <Sprite img={img} x={x} y={y} w={w} h={h} drag>
      {sections.map((section) => (
        <NoteSectionView
          key={section.top}
          section={section}
          w={w}
          hovered={hovered}
          onHover={onHover}
        />
      ))}
    </Sprite>
  );
};

const NoteSectionView = (props: {
  section: NoteSection;
  w: number;
  hovered?: string;
  onHover?: (key?: string) => void;
}) => {
  const { section, w, hovered, onHover } = props;
  const { top, heading, rows, empty, maxRows = 10 } = section;
  const shown = rows.slice(0, maxRows);
  const hidden = rows.length - shown.length;
  return (
    <>
      <PixelText x={5} y={top - 3} w={w - 10} font="plain" color="#2f3f6b">
        <b>{heading}</b>
      </PixelText>
      {shown.length === 0 && !!empty && (
        <PixelText
          x={5}
          y={top + 8}
          w={w - 10}
          font="plain"
          color="#8c93a8"
          className="PixelUi__noteRow"
        >
          {empty}
        </PixelText>
      )}
      {shown.map((row, index) => (
        <Px
          key={row.key}
          x={5}
          y={top + 4 + index * 9}
          w={w - 10}
          h={9}
          title={row.title || row.text}
          className={classes([
            'PixelUi__noteRow',
            !!row.onClick && 'PixelUi__noteRow--clickable',
            hovered === row.key && 'PixelUi__noteRow--hovered',
            row.struck && 'PixelUi__noteRow--struck',
          ])}
          onClick={() => row.onClick?.()}
          onMouseEnter={() => onHover?.(row.key)}
          onMouseLeave={() => onHover?.(undefined)}
        >
          {!!row.swatch && (
            <span
              className="PixelUi__swatch"
              style={{ background: row.swatch }}
            />
          )}
          {!!row.count && row.count > 1 && `${row.count}× `}
          <span>{row.text}</span>
        </Px>
      ))}
      {hidden > 0 && (
        <PixelText
          x={5}
          y={top + 6 + maxRows * 9}
          w={w - 10}
          font="plain"
          color="#8c93a8"
        >
          {`+ ${hidden}…`}
        </PixelText>
      )}
    </>
  );
};

export type Particle = {
  x: number;
  y: number;
  size: number;
  color: string;
  /** Przesunięcie do końca życia (piksele grafiki). */
  dx: number;
  dy: number;
  /** Czas życia w sekundach. */
  life: number;
  delay: number;
};

/** Cząsteczki animowane w CSS (iskry, dym, płomienie, krople). */
export const Particles = (props: { particles: Particle[]; loop?: boolean }) => (
  <>
    {props.particles.map((p, index) => (
      <div
        key={index}
        className={classes([
          'PixelUi__particle',
          props.loop && 'PixelUi__particle--loop',
        ])}
        style={
          {
            left: px(p.x),
            top: px(p.y),
            width: px(p.size),
            height: px(p.size),
            background: p.color,
            animationDuration: `${p.life}s`,
            animationDelay: `${p.delay}s`,
            '--dx': px(p.dx),
            '--dy': px(p.dy),
          } as CSSProperties
        }
      />
    ))}
  </>
);

/** Prosty generator liczb pseudolosowych, żeby cząsteczki nie skakały co render. */
export const seededRandom = (seed: number) => {
  let state = seed % 2147483647;
  if (state <= 0) {
    state += 2147483646;
  }
  return () => {
    state = (state * 16807) % 2147483647;
    return (state - 1) / 2147483646;
  };
};

/** Czas w sekundach, odświeżany co klatkę animacji, gdy active. */
export const useClock = (active: boolean, fps = 30) => {
  const [time, setTime] = useState(() => performance.now() / 1000);
  useEffect(() => {
    if (!active) {
      return;
    }
    const timer = setInterval(
      () => setTime(performance.now() / 1000),
      1000 / fps,
    );
    return () => clearInterval(timer);
  }, [active, fps]);
  return time;
};

/** Poprzednia wartość z ostatniego renderu. */
export function usePrevious<T>(value: T) {
  const ref = useRef<T>(value);
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
}

/**
 * Chwila (performance.now() w sekundach), w której wartość ostatnio zmieniła
 * się na wskazaną. Służy do odpalania jednorazowych animacji po zmianie stanu.
 */
export const useSince = (condition: boolean) => {
  const [since, setSince] = useState<number | null>(
    condition ? performance.now() / 1000 : null,
  );
  useEffect(() => {
    setSince(condition ? performance.now() / 1000 : null);
  }, [condition]);
  return since;
};

/** Czy gracz włączył ograniczony ruch (animacje skrócone do stanów końcowych). */
export const reducedMotion = () =>
  !!window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;

type DeviceProps = PropsWithChildren<{
  /** Rozmiar płótna w pikselach grafiki. */
  width: number;
  height: number;
  title?: string;
  className?: string;
}>;

/**
 * Okno bez paska tytułu z płótnem pikselowym. Przytrzymanie tła albo
 * elementu z `drag` przesuwa okno; zamyka je klawisz z `closeWindow`.
 */
export const PixelDevice = (props: DeviceProps) => {
  const { width, height, title, className, children } = props;
  const onMouseDown = (event: MouseEvent<HTMLDivElement>) => {
    const target = event.target as HTMLElement;
    if (target === event.currentTarget || target.dataset.drag === '1') {
      dragStartHandler(event.nativeEvent);
    }
  };
  return (
    <Window
      title={title}
      width={width * SCALE}
      height={height * SCALE}
      noTitleBar
      override_bg="#141414"
    >
      <div
        className={classes(['PixelUi', className])}
        style={{ width: px(width), height: px(height) }}
        onMouseDown={onMouseDown}
      >
        {children}
      </div>
    </Window>
  );
};

export { closeWindow };
