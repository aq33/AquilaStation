/**
 * Pulpit operatora fabrykatora w formie urządzenia.
 * Port pomysłu z Polonium Station (polonium14/polonium-station#1283).
 * Obsługuje autolat i drukarkę komponentów (kolejka zleceń) oraz protolaty,
 * techfaby i drukarkę płytek (jeden wydruk naraz, materiały z silosu).
 * Rzadkie opcje (dyski, powtarzanie kolejki, kierunek wydruku) są w starym
 * oknie pod klawiszem STARE OKNO.
 */

import { useEffect, useMemo, useRef, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { isTranslating, translateUiText } from '../i18n';
import {
  BLACKLISTED_CATEGORIES,
  categoryTitle,
} from './Fabrication/DesignBrowser';
import { MATERIAL_ICONS } from './Fabrication/MaterialIcon';
import type { Design, Material, Reagent } from './Fabrication/Types';
import { SHEET_MATERIAL_AMOUNT } from './Fabrication/Types';
import {
  AtlasSprite,
  closeWindow,
  PixelDevice,
  PixelKey,
  PixelScrollbar,
  PixelText,
  Px,
  Rect,
  SCALE,
  Sprite,
  useClock,
  usePrevious,
} from './PixelUi';

type QueueEntry = { name: string; amount: number; design_id: string };

type Printing = {
  id: string;
  name: string;
  amount?: number;
  left: number;
  total: number;
};

type Data = {
  fabName: string;
  designs: Record<string, Design>;
  materials: Material[];
  queued: BooleanLike;
  canSync: BooleanLike;
  powered: BooleanLike;
  silo: BooleanLike;
  hacked: BooleanLike;
  printing?: Printing;
  // autolat i drukarka komponentów
  design_queue?: QueueEntry[];
  processing?: BooleanLike;
  // protolaty, techfaby, drukarka płytek
  busy?: BooleanLike;
  onHold?: BooleanLike;
  reagents?: Reagent[];
  reagentCapacity?: number;
};

// Kolory ekranu i pulpitu (jak w Polonium)
const SCREEN_BACK = '#0a120a';
const SCREEN_GRID = '#102410';
const SCREEN_DIM = '#1a551a';
const SCREEN_LOW = '#1a7a22';
const SCREEN = '#33ff33';
const SCREEN_HOT = '#c8ffc8';
const ROW_HOVER = '#14501a';
const LABEL = '#c5c7d4';
const ENGRAVED = '#9497ab';
const OUTLINE = '#0b0c12';
const INK = '#1d2a1d';
const INK_SOFT = '#5f7a58';
const STAMP = '#b83325';

const BODY: [number, number] = [450, 290];
const SCREEN_AREA = { x: 19, y: 41, w: 280, h: 133 };
const PANE_W = 164;
const HEADER_H = 11;
const PROMPT_H = 12;
const LIST_TOP = HEADER_H + PROMPT_H;
const ROW_H = 14;
const VISIBLE_ROWS = 7;
const PLOT = { x: PANE_W, y: HEADER_H, w: 116, h: 84 };
const SOFT_LEFT = [20, 46, 104, 161, 219, 276];
const SOFT_WIDTH = [22, 54, 53, 54, 53, 22];
const SOFT_TOP = 181;
const RACK = { x: 319, y: 44, w: 120, h: 126 };
const TICKET_H = 35;
const TICKET_GAP = 3;
const TRAY = { x: 321, y: 174, w: 114, h: 22 };
const MATERIALS = { x: 118, y: 221, w: 234, h: 56 };
const CELL_PITCH = 53;
const STOP = { x: 382, y: 224, size: 40 };
const TANK = { x: 456, y: 80, w: 40, h: 198 };
const MAX_AMOUNT = 50;
const ALL = '';

const normalize = (text: string) =>
  text.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/ł/g, 'l');

const topCategory = (category: string) => category.split('/')[0];

const formatTime = (deciseconds: number) => {
  const seconds = Math.max(0, Math.ceil(deciseconds / 10));
  return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`;
};

export const LathePulpit = () => {
  const { act, data } = useBackend<Data>();
  const {
    fabName,
    designs = {},
    materials = [],
    queued,
    canSync,
    powered,
    silo,
    hacked,
    printing,
    processing,
    onHold,
    reagents = [],
    reagentCapacity = 0,
  } = data;
  const design_queue = data.design_queue || [];

  const [search, setSearch] = useState('');
  const [category, setCategory] = useState(ALL);
  const [softPage, setSoftPage] = useState(0);
  const [scroll, setScroll] = useState(0);
  const [amount, setAmount] = useState(1);
  const [hovered, setHovered] = useState<string>();
  const [denied, setDenied] = useState(0);
  const time = useClock(!!printing || Date.now() - denied < 1500, 15);

  const available = useMemo(() => {
    const map: Record<string, number> = {};
    for (const material of materials) {
      map[material.name] = material.amount;
    }
    return map;
  }, [materials]);

  const categories = useMemo(() => {
    const set = new Set<string>();
    for (const design of Object.values(designs)) {
      for (const entry of design.categories || []) {
        const top = topCategory(entry);
        if (!BLACKLISTED_CATEGORIES[top]) {
          set.add(top);
        }
      }
    }
    return [ALL, ...Array.from(set).sort()];
  }, [designs]);

  const listed = useMemo(() => {
    const query = normalize(search.trim());
    return Object.values(designs)
      .filter((design) => {
        if (
          category !== ALL &&
          !(design.categories || []).some(
            (entry) => topCategory(entry) === category,
          )
        ) {
          return false;
        }
        if (!query) {
          return true;
        }
        return (
          normalize(translateUiText(design.name)).includes(query) ||
          normalize(design.name).includes(query) ||
          (!!design.nameEn && normalize(design.nameEn).includes(query))
        );
      })
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [designs, search, category]);

  useEffect(() => setScroll(0), [search, category]);
  const maxScroll = Math.max(0, listed.length - VISIBLE_ROWS);
  const shownScroll = Math.min(scroll, maxScroll);

  const affordable = (design: Design, count: number) =>
    Object.entries(design.cost || {}).every(
      ([name, cost]) => (available[name] ?? 0) >= cost * count,
    );

  const order = (design: Design) => {
    if (!powered) {
      return;
    }
    if (!affordable(design, amount)) {
      setDenied(Date.now());
      return;
    }
    if (queued) {
      act('build', { design_id: design.id, amount });
    } else {
      act('build', { ref: design.id, amount });
    }
  };

  const hoveredDesign = hovered ? designs[hovered] : undefined;
  const stopped = !!queued && !processing && design_queue.length > 0;
  const working = !!printing;

  // Ostatnio skończony wydruk wysuwa się na tackę
  const previousPrinting = usePrevious(printing?.id);
  const [trayItem, setTrayItem] = useState<{ id: string; at: number }>();
  useEffect(() => {
    if (previousPrinting && !printing) {
      setTrayItem({ id: previousPrinting, at: Date.now() });
    }
  }, [printing?.id]);

  const softCategories = categories.slice(softPage * 4, softPage * 4 + 4);
  const softPages = Math.max(1, Math.ceil(categories.length / 4));
  const tank = reagentCapacity > 0;

  return (
    <PixelDevice
      width={tank ? TANK.x + TANK.w + 4 : BODY[0]}
      height={BODY[1]}
      title={fabName}
      className={hacked ? 'LathePulpit--hacked' : undefined}
    >
      <Sprite img="lathe-body" x={0} y={0} w={BODY[0]} h={BODY[1]} drag />
      <NamePlate
        name={fabName}
        powered={!!powered}
        working={working}
        silo={!!silo}
        onHold={!!onHold}
      />
      <PixelKey
        x={408}
        y={10}
        w={14}
        h={14}
        set="lathe"
        skin="dark"
        text="≡"
        textColor="#dfe0e8"
        tooltip="Stare okno (dyski, powtarzanie kolejki, kierunek wydruku)"
        onClick={() => act('classic')}
      />
      <PixelKey
        x={428}
        y={10}
        w={14}
        h={14}
        set="lathe"
        skin="red"
        text="x"
        textColor="#dfe0e8"
        tooltip="Zamknij"
        onClick={closeWindow}
      />

      {/* Ekran */}
      <Px
        x={SCREEN_AREA.x}
        y={SCREEN_AREA.y}
        w={SCREEN_AREA.w}
        h={SCREEN_AREA.h}
        className="LathePulpit__screen"
        style={{ background: SCREEN_BACK }}
      >
        {!powered ? null : (
          <>
            <PixelText x={3} y={3} font="screen" color={SCREEN_LOW}>
              {category === ALL
                ? 'KATALOG'
                : categoryTitle(category).toUpperCase()}
            </PixelText>
            <PixelText
              x={PANE_W - 60}
              y={3}
              w={56}
              align="right"
              font="screen"
              color={SCREEN_LOW}
            >
              {`${listed.length} poz.`}
            </PixelText>
            <Prompt value={search} onChange={setSearch} />
            <Catalog
              designs={listed}
              scroll={shownScroll}
              amount={amount}
              hovered={hovered}
              affordable={affordable}
              onScroll={(delta) =>
                setScroll(Math.max(0, Math.min(maxScroll, shownScroll + delta)))
              }
              onHover={setHovered}
              onOrder={order}
            />
            <Plot
              printing={printing}
              preview={hoveredDesign}
              stopped={stopped}
              denied={Date.now() - denied < 1500}
              time={time}
            />
            <Readout
              printing={printing}
              queue={design_queue}
              queued={!!queued}
              stopped={stopped}
            />
            {/* Podpisy klawiszy ekranowych */}
            {softCategories.map((entry, index) => (
              <PixelText
                key={entry || 'all'}
                x={SOFT_LEFT[index + 1] - SCREEN_AREA.x + 1}
                y={124}
                w={SOFT_WIDTH[index + 1] - 2}
                align="center"
                font="screen"
                color={entry === category ? SCREEN_HOT : SCREEN_LOW}
              >
                {entry === ALL
                  ? 'WSZYSTKO'
                  : categoryTitle(entry).toUpperCase()}
              </PixelText>
            ))}
          </>
        )}
      </Px>

      {/* Klawisze ekranowe: strzałki stron i cztery kategorie */}
      <PixelKey
        x={SOFT_LEFT[0]}
        y={SOFT_TOP}
        w={SOFT_WIDTH[0]}
        h={13}
        set="lathe"
        skin="dark"
        text="<"
        textColor="#dfe0e8"
        disabled={softPage <= 0}
        onClick={() => setSoftPage(softPage - 1)}
      />
      {[0, 1, 2, 3].map((slot) => {
        const entry = softCategories[slot];
        return (
          <PixelKey
            key={slot}
            x={SOFT_LEFT[slot + 1]}
            y={SOFT_TOP}
            w={SOFT_WIDTH[slot + 1]}
            h={13}
            set="lathe"
            skin="light"
            latched={entry !== undefined && entry === category}
            disabled={entry === undefined}
            tooltip={
              entry === undefined
                ? undefined
                : entry === ALL
                  ? 'Wszystkie projekty'
                  : categoryTitle(entry)
            }
            onClick={() => entry !== undefined && setCategory(entry)}
          />
        );
      })}
      <PixelKey
        x={SOFT_LEFT[5]}
        y={SOFT_TOP}
        w={SOFT_WIDTH[5]}
        h={13}
        set="lathe"
        skin="dark"
        text=">"
        textColor="#dfe0e8"
        disabled={softPage >= softPages - 1}
        onClick={() => setSoftPage(softPage + 1)}
      />

      <PixelText x={319} y={34} color={ENGRAVED}>
        {queued ? 'ZLECENIA' : 'WYDRUK'}
      </PixelText>
      <TicketRack
        queue={queued ? design_queue : []}
        single={printing}
        designs={designs}
        onRemoveOne={(id) => act('queue_remove_one', { design_id: id })}
        onRemove={(id) => act('clear_item', { design_id: id })}
      />
      <Tray item={trayItem} designs={designs} />

      {/* Ilość */}
      <PixelText x={14} y={212} color={ENGRAVED}>
        ILOŚĆ
      </PixelText>
      <PixelKey
        x={14}
        y={222}
        w={17}
        h={20}
        set="lathe"
        skin="light"
        text="-"
        textColor="#212330"
        disabled={amount <= 1}
        onClick={() => setAmount(Math.max(1, amount - 1))}
      />
      <Rect x={36} y={225} w={44} h={14} color={SCREEN_BACK} />
      <PixelText
        x={36}
        y={228}
        w={44}
        align="center"
        font="screen"
        color={SCREEN}
      >
        {`×${amount}`}
      </PixelText>
      <PixelKey
        x={85}
        y={222}
        w={17}
        h={20}
        set="lathe"
        skin="light"
        text="+"
        textColor="#212330"
        disabled={amount >= MAX_AMOUNT}
        onClick={() => setAmount(Math.min(MAX_AMOUNT, amount + 1))}
      />
      <PixelKey
        x={14}
        y={263}
        w={17}
        h={14}
        set="lathe"
        skin="dark"
        text="C"
        textColor="#dfe0e8"
        tooltip="Ilość 1"
        onClick={() => setAmount(1)}
      />
      <PixelKey
        x={33}
        y={263}
        w={69}
        h={14}
        set="lathe"
        skin="dark"
        text="SYNCHRO"
        textColor="#dfe0e8"
        disabled={!canSync}
        tooltip="Pobierz projekty z serwera badań"
        onClick={() => act(queued ? 'resync_rd' : 'sync_research')}
      />

      <PixelText x={118} y={212} color={ENGRAVED}>
        MATERIAŁY
      </PixelText>
      <Materials
        materials={materials}
        cost={hoveredDesign?.cost}
        amount={amount}
        onEject={(ref, sheets) => act('remove_mat', { ref, amount: sheets })}
      />

      <StopButton
        queued={!!queued}
        stopped={stopped}
        working={working || (!!queued && design_queue.length > 0)}
        onStop={() => act('stop_queue')}
        onResume={() => act('build_queue')}
        onStopAll={() => act('stop_all')}
      />

      {tank && <Tank reagents={reagents} capacity={reagentCapacity} />}
    </PixelDevice>
  );
};

const NamePlate = (props: {
  name: string;
  powered: boolean;
  working: boolean;
  silo: boolean;
  onHold: boolean;
}) => {
  const { name, powered, working, silo, onHold } = props;
  const leds: [string, boolean, string][] = [
    ['ZASILANIE', powered, '#44ff00'],
    ['PRACA', working, '#ffb000'],
    [
      onHold ? 'SILOS WSTRZYMANY' : 'SILOS',
      silo,
      onHold ? '#ff4030' : '#44ff00',
    ],
  ];
  return (
    <>
      <Rect x={8} y={8} w={180} h={18} color={OUTLINE} drag />
      <Rect x={9} y={9} w={178} h={16} color="#b7b9c6" drag />
      <PixelText x={14} y={14} w={110} color="#151824">
        {name.toUpperCase()}
      </PixelText>
      {leds.map(([title, lit, color], index) => (
        <Px key={title} x={140 + index * 15} y={13} w={9} h={9} title={title}>
          <Rect x={0} y={0} w={9} h={9} color={OUTLINE} />
          <Rect
            x={1}
            y={1}
            w={7}
            h={7}
            color={lit ? color : '#3a3c45'}
            style={
              lit ? { boxShadow: `0 0 ${4 * SCALE}px ${color}` } : undefined
            }
          />
        </Px>
      ))}
    </>
  );
};

/** Linia wyszukiwania na ekranie. */
const Prompt = (props: {
  value: string;
  onChange: (value: string) => void;
}) => (
  <Px x={3} y={HEADER_H} w={PANE_W - 6} h={PROMPT_H}>
    <PixelText x={0} y={3} font="screen" color={SCREEN_DIM}>
      {'>'}
    </PixelText>
    <input
      className="LathePulpit__search"
      value={props.value}
      placeholder="SZUKAJ..."
      spellCheck={false}
      onChange={(event) => props.onChange(event.target.value)}
      onMouseDown={(event) => event.stopPropagation()}
    />
    <Rect x={0} y={PROMPT_H - 1} w={PANE_W - 6} h={1} color={SCREEN_GRID} />
  </Px>
);

const DesignIcon = (props: { design: Design; scale?: number }) => (
  <div
    className={classes(['design32x32', props.design.icon, 'LathePulpit__icon'])}
    style={{ transform: `scale(${props.scale ?? 1})` }}
  />
);

const Catalog = (props: {
  designs: Design[];
  scroll: number;
  amount: number;
  hovered?: string;
  affordable: (design: Design, count: number) => boolean;
  onScroll: (delta: number) => void;
  onHover: (id?: string) => void;
  onOrder: (design: Design) => void;
}) => {
  const {
    designs,
    scroll,
    amount,
    hovered,
    affordable,
    onScroll,
    onHover,
    onOrder,
  } = props;
  const shown = designs.slice(scroll, scroll + VISIBLE_ROWS);
  return (
    <Px
      x={0}
      y={LIST_TOP}
      w={PANE_W}
      h={VISIBLE_ROWS * ROW_H}
      style={{ overflow: 'hidden' }}
    >
      <div
        className="LathePulpit__wheel"
        onWheel={(event) => onScroll(event.deltaY > 0 ? 1 : -1)}
      >
        {shown.length === 0 && (
          <PixelText x={6} y={6} font="screen" color={SCREEN_DIM}>
            BRAK PROJEKTÓW
          </PixelText>
        )}
        {shown.map((design, index) => {
          const canPrint = affordable(design, amount);
          const lit = hovered === design.id;
          return (
            <Px
              key={design.id}
              x={2}
              y={index * ROW_H}
              w={PANE_W - 10}
              h={ROW_H}
              className="LathePulpit__row"
              title={`${translateUiText(design.name)}${design.desc ? `\n${design.desc}` : ''}`}
              style={{ background: lit ? ROW_HOVER : undefined }}
              onClick={() => onOrder(design)}
              onMouseEnter={() => onHover(design.id)}
              onMouseLeave={() => onHover(undefined)}
            >
              <Px x={1} y={-1} w={16} h={16} className="LathePulpit__iconBox">
                <DesignIcon design={design} />
              </Px>
              <PixelText
                x={20}
                y={4}
                w={PANE_W - 32}
                font="screen"
                color={canPrint ? (lit ? SCREEN_HOT : SCREEN) : SCREEN_DIM}
              >
                {translateUiText(design.name)}
              </PixelText>
            </Px>
          );
        })}
      </div>
      <PixelScrollbar
        x={PANE_W - 6}
        y={0}
        w={4}
        h={VISIBLE_ROWS * ROW_H}
        total={designs.length}
        visible={VISIBLE_ROWS}
        offset={scroll}
        track={SCREEN_GRID}
        thumb={SCREEN_LOW}
        onChange={(offset) => onScroll(offset - scroll)}
      />
    </Px>
  );
};

/** Ploter: drukowany przedmiot rysowany od dołu, podgląd projektu pod kursorem. */
const Plot = (props: {
  printing?: Printing;
  preview?: Design;
  stopped: boolean;
  denied: boolean;
  time: number;
}) => {
  const { printing, preview, stopped, denied, time } = props;
  const { data } = useBackend<Data>();
  const designs = data.designs || {};
  const design = printing ? designs[printing.id] : preview;
  const progress = printing
    ? Math.max(0, Math.min(1, 1 - printing.left / Math.max(1, printing.total)))
    : 1;
  // Ikona 32x32 powiększona do 64x64 pikseli grafiki
  const iconX = PLOT.w / 2 - 32;
  const iconY = 4;
  const headY = iconY + Math.round(64 * (1 - progress));
  return (
    <Px
      x={PLOT.x}
      y={PLOT.y}
      w={PLOT.w}
      h={PLOT.h}
      className="LathePulpit__plot"
    >
      <Rect x={0} y={0} w={1} h={PLOT.h} color={SCREEN_GRID} />
      {Array.from({ length: Math.floor(PLOT.w / 8) }, (_, index) => (
        <Rect
          key={`v${index}`}
          x={4 + index * 8}
          y={0}
          w={1}
          h={PLOT.h}
          color={SCREEN_GRID}
          style={{ opacity: 0.5 }}
        />
      ))}
      {Array.from({ length: Math.floor(PLOT.h / 8) }, (_, index) => (
        <Rect
          key={`h${index}`}
          x={0}
          y={4 + index * 8}
          w={PLOT.w}
          h={1}
          color={SCREEN_GRID}
          style={{ opacity: 0.5 }}
        />
      ))}
      {!!design && (
        <Px
          x={iconX}
          y={iconY}
          w={64}
          h={64}
          className={classes([
            'LathePulpit__plotIcon',
            !printing && 'LathePulpit__plotIcon--preview',
          ])}
          style={{
            clipPath: printing
              ? `inset(${Math.round((1 - progress) * 100)}% 0 0 0)`
              : undefined,
          }}
        >
          <DesignIcon design={design} scale={4} />
        </Px>
      )}
      {!!printing && (
        <>
          <Rect x={4} y={headY} w={PLOT.w - 8} h={1} color={SCREEN_HOT} />
          <Rect
            x={Math.round(PLOT.w / 2 + Math.sin(time * 9) * 30) - 2}
            y={headY - 2}
            w={5}
            h={5}
            color={SCREEN_HOT}
          />
        </>
      )}
      {stopped && !printing && (
        <PixelText
          x={0}
          y={34}
          w={PLOT.w}
          align="center"
          font="screenBig"
          color={STAMP}
        >
          STOP
        </PixelText>
      )}
      {denied && (
        <PixelText
          x={0}
          y={34}
          w={PLOT.w}
          align="center"
          font="screen"
          color={STAMP}
        >
          BRAK MATERIAŁÓW
        </PixelText>
      )}
    </Px>
  );
};

const Readout = (props: {
  printing?: Printing;
  queue: QueueEntry[];
  queued: boolean;
  stopped: boolean;
}) => {
  const { printing, queue, queued, stopped } = props;
  const top = PLOT.y + PLOT.h + 1;
  const progress = printing
    ? Math.max(0, Math.min(1, 1 - printing.left / Math.max(1, printing.total)))
    : 0;
  const segments = 22;
  const lit = Math.round(progress * segments);
  const waiting = queue.reduce((sum, entry) => sum + (entry.amount || 0), 0);
  let line1 = 'GOTOWY';
  let line2 = queued ? `W KOLEJCE: ${waiting}` : '';
  if (printing) {
    line1 = translateUiText(printing.name).toUpperCase();
    line2 = `${printing.amount && printing.amount > 1 ? `×${printing.amount}  ` : ''}${formatTime(printing.left)}`;
  } else if (stopped) {
    line1 = 'ZATRZYMANO';
  }
  return (
    <Px x={PLOT.x + 4} y={top} w={PLOT.w - 8} h={30}>
      <PixelText x={0} y={2} w={PLOT.w - 8} font="screen" color={SCREEN}>
        {line1}
      </PixelText>
      <PixelText x={0} y={12} w={PLOT.w - 8} font="screen" color={SCREEN_LOW}>
        {line2}
      </PixelText>
      {Array.from({ length: segments }, (_, index) => (
        <Rect
          key={index}
          x={index * 5}
          y={21}
          w={4}
          h={3}
          color={index < lit ? SCREEN : SCREEN_GRID}
        />
      ))}
    </Px>
  );
};

/** Stojak ze zleceniami na papierze. */
const TicketRack = (props: {
  queue: QueueEntry[];
  single?: Printing;
  designs: Record<string, Design>;
  onRemoveOne: (id: string) => void;
  onRemove: (id: string) => void;
}) => {
  const { queue, single, designs, onRemoveOne, onRemove } = props;
  const [scroll, setScroll] = useState(0);
  // Bieżący wydruk (kolejka oddaje go maszynie przy starcie) wisi na górze jako zlecenie w toku
  const tickets: (QueueEntry & { single?: boolean })[] = [
    ...(single
      ? [
          {
            name: single.name,
            amount: single.amount || 1,
            design_id: single.id,
            single: true,
          },
        ]
      : []),
    ...queue,
  ];
  const visible = 3;
  const maxScroll = Math.max(0, tickets.length - visible);
  const shown = Math.min(scroll, maxScroll);
  return (
    <Px
      x={RACK.x}
      y={RACK.y}
      w={RACK.w}
      h={RACK.h}
      style={{ overflow: 'hidden' }}
    >
      <div
        className="LathePulpit__wheel"
        onWheel={(event) =>
          setScroll(
            Math.max(
              0,
              Math.min(maxScroll, shown + (event.deltaY > 0 ? 1 : -1)),
            ),
          )
        }
      >
        {tickets.length === 0 && (
          <PixelText x={4} y={8} w={100} font="plain" color={ENGRAVED}>
            brak zleceń
          </PixelText>
        )}
        {tickets.slice(shown, shown + visible).map((ticket, index) => {
          const design = designs[ticket.design_id];
          return (
            <Px
              key={(ticket.single ? 'w-' : '') + ticket.design_id}
              x={0}
              y={index * (TICKET_H + TICKET_GAP)}
              w={RACK.w}
              h={TICKET_H}
              className="LathePulpit__ticket"
            >
              <Sprite img="lathe-ticket" x={0} y={0} w={102} h={35} />
              <PixelText x={26} y={4} w={74} color={INK_SOFT}>
                {ticket.single ? 'W TOKU' : `ZLEC. ${shown + index + 1}`}
              </PixelText>
              <PixelText x={26} y={13} w={74} font="plain" color={INK}>
                {translateUiText(ticket.name)}
              </PixelText>
              <PixelText x={26} y={23} w={40} color={INK}>
                {`×${ticket.amount}`}
              </PixelText>
              {/* dziurki: po jednej na sztukę (do 12) */}
              {Array.from(
                { length: Math.min(12, ticket.amount) },
                (_, hole) => (
                  <Rect
                    key={hole}
                    x={52 + (hole % 12) * 4}
                    y={25}
                    w={3}
                    h={3}
                    color={INK}
                    style={{ opacity: 0.55 }}
                  />
                ),
              )}
              {!!design && (
                <Px x={0} y={9} w={32} h={16} style={{ overflow: 'hidden' }}>
                  <Px x={8} y={0} w={16} h={16}>
                    <DesignIcon design={design} />
                  </Px>
                </Px>
              )}
              {ticket.single ? (
                <PixelText x={60} y={5} w={38} align="right" color={STAMP}>
                  DRUK
                </PixelText>
              ) : (
                <>
                  <PixelKey
                    x={104}
                    y={4}
                    w={14}
                    h={11}
                    set="lathe"
                    skin="light"
                    text="-"
                    textColor="#212330"
                    tooltip="Jedna sztuka mniej"
                    onClick={() => onRemoveOne(ticket.design_id)}
                  />
                  <PixelKey
                    x={104}
                    y={16}
                    w={14}
                    h={11}
                    set="lathe"
                    skin="red"
                    text="x"
                    textColor="#dfe0e8"
                    tooltip="Usuń zlecenie"
                    onClick={() => onRemove(ticket.design_id)}
                  />
                </>
              )}
            </Px>
          );
        })}
      </div>
    </Px>
  );
};

/** Tacka: ostatni wydruk wysuwa się na chwilę. */
const Tray = (props: {
  item?: { id: string; at: number };
  designs: Record<string, Design>;
}) => {
  const { item, designs } = props;
  const design = item ? designs[item.id] : undefined;
  const [, setTick] = useState(0);
  useEffect(() => {
    if (!item) {
      return;
    }
    const timer = setTimeout(() => setTick((tick) => tick + 1), 2600);
    return () => clearTimeout(timer);
  }, [item?.at]);
  if (!design || !item || Date.now() - item.at > 2500) {
    return null;
  }
  return (
    <Px
      x={TRAY.x}
      y={TRAY.y}
      w={TRAY.w}
      h={TRAY.h}
      style={{ overflow: 'hidden' }}
    >
      <Px
        x={TRAY.w / 2 - 8}
        y={2}
        w={16}
        h={16}
        className="LathePulpit__trayItem"
      >
        <DesignIcon design={design} />
      </Px>
    </Px>
  );
};

const Materials = (props: {
  materials: Material[];
  cost?: Record<string, number>;
  amount: number;
  onEject: (ref: string, sheets: number) => void;
}) => {
  const { materials, cost, amount, onEject } = props;
  const [scroll, setScroll] = useState(0);
  const visible = 4;
  const maxScroll = Math.max(0, materials.length - visible);
  const shown = Math.min(scroll, maxScroll);
  return (
    <Px x={MATERIALS.x} y={MATERIALS.y} w={MATERIALS.w} h={MATERIALS.h}>
      <div
        className="LathePulpit__wheel"
        onWheel={(event) =>
          setScroll(
            Math.max(
              0,
              Math.min(maxScroll, shown + (event.deltaY > 0 ? 1 : -1)),
            ),
          )
        }
      >
        {materials.length === 0 && (
          <PixelText x={4} y={20} font="plain" color={ENGRAVED}>
            Brak materiałów: włóż arkusze do maszyny
          </PixelText>
        )}
        {materials.slice(shown, shown + visible).map((material, index) => {
          const need = (cost?.[material.name] ?? 0) * amount;
          const sheets = material.amount / SHEET_MATERIAL_AMOUNT;
          // Wskaźnik pełny przy 50 arkuszach
          const fill = Math.min(1, sheets / 50);
          const needFill = Math.min(fill, need / SHEET_MATERIAL_AMOUNT / 50);
          const short = need > material.amount;
          return (
            <Px
              key={material.ref}
              x={index * CELL_PITCH}
              y={0}
              w={50}
              h={MATERIALS.h}
              title={`${materialTitle(material.name)}: ${sheets.toFixed(1)} ark.${need ? `\nProjekt: ${(need / SHEET_MATERIAL_AMOUNT).toFixed(2)} ark.` : ''}`}
            >
              <Rect x={0} y={0} w={9} h={31} color={OUTLINE} />
              <Rect x={1} y={1} w={7} h={29} color="#15161e" />
              <Rect
                x={1}
                y={1 + Math.round(29 * (1 - fill))}
                w={7}
                h={Math.round(29 * fill)}
                color={material.color || '#9aa0b0'}
              />
              {need > 0 && (
                <Rect
                  x={1}
                  y={1 + Math.round(29 * (1 - fill))}
                  w={7}
                  h={Math.max(1, Math.round(29 * needFill))}
                  color={short ? STAMP : '#ffffff'}
                  style={{ opacity: 0.6 }}
                />
              )}
              <Px x={12} y={0} w={16} h={16} className="LathePulpit__iconBox">
                <MaterialSheet name={material.name} />
              </Px>
              <PixelText x={12} y={19} w={38} font="plain" color={LABEL}>
                {materialTitle(material.name)}
              </PixelText>
              <PixelText
                x={12}
                y={33}
                w={38}
                font="screen"
                color={short ? STAMP : SCREEN}
              >
                {sheets.toFixed(sheets < 10 ? 1 : 0)}
              </PixelText>
              {[1, 5, 10].map((count, key) => (
                <PixelKey
                  key={count}
                  x={key * 17}
                  y={43}
                  w={16}
                  h={11}
                  set="lathe"
                  skin="dark"
                  text={String(count)}
                  textColor="#dfe0e8"
                  disabled={!material.removable || material.sheets < count}
                  tooltip={`Wydaj ${count} ark.`}
                  onClick={() => onEject(material.ref, count)}
                />
              ))}
            </Px>
          );
        })}
      </div>
      {materials.length > visible && (
        <Rect
          x={Math.round((shown / materials.length) * MATERIALS.w)}
          y={MATERIALS.h - 1}
          w={Math.round((visible / materials.length) * MATERIALS.w)}
          h={1}
          color={ENGRAVED}
        />
      )}
    </Px>
  );
};

/** Polskie nazwy materiałów (DM wysyła identyfikatory po angielsku). */
const MATERIAL_TITLES: Record<string, string> = {
  iron: 'Żelazo',
  glass: 'Szkło',
  copper: 'Miedź',
  silver: 'Srebro',
  gold: 'Złoto',
  diamond: 'Diament',
  plasma: 'Plazma',
  uranium: 'Uran',
  bananium: 'Bananium',
  titanium: 'Tytan',
  'bluespace crystal': 'Bluespace',
  plastic: 'Plastik',
  wood: 'Drewno',
  adamantine: 'Adamantyn',
  meat: 'Mięso',
};

const materialTitle = (name: string) =>
  isTranslating() ? name : (MATERIAL_TITLES[name] ?? name);

/** Ikona arkusza z arkusza sprite'ów sheetmaterials (jak w starym oknie). */
const MaterialSheet = (props: { name: string }) => {
  const state = MATERIAL_ICONS[props.name]?.[0]?.[1];
  if (!state) {
    return <Rect x={4} y={4} w={8} h={8} color="#6a6d7a" />;
  }
  return (
    <div
      className={classes(['sheetmaterials32x32', state, 'LathePulpit__icon'])}
      style={{ transform: 'scale(1)' }}
    />
  );
};

/** STOP: klik zatrzymuje kolejkę po bieżącym wydruku, przytrzymanie czyści kolejkę. */
const StopButton = (props: {
  queued: boolean;
  stopped: boolean;
  working: boolean;
  onStop: () => void;
  onResume: () => void;
  onStopAll: () => void;
}) => {
  const { queued, stopped, working, onStop, onResume, onStopAll } = props;
  const [pressed, setPressed] = useState(false);
  const holdTimer = useRef<ReturnType<typeof setTimeout>>(undefined);
  const held = useRef(false);
  const release = (fire: boolean) => {
    if (holdTimer.current) {
      clearTimeout(holdTimer.current);
    }
    setPressed(false);
    if (fire && !held.current) {
      if (stopped) {
        onResume();
      } else {
        onStop();
      }
    }
    held.current = false;
  };
  const tooltip = !queued
    ? 'Wydruku z tej maszyny nie da się przerwać'
    : stopped
      ? 'Wznów kolejkę (przytrzymaj: usuń całą kolejkę)'
      : 'Zatrzymaj kolejkę po bieżącym wydruku (przytrzymaj: usuń całą kolejkę)';
  return (
    <Px
      x={STOP.x}
      y={STOP.y}
      w={STOP.size}
      h={STOP.size}
      title={tooltip}
      style={{ cursor: queued ? 'pointer' : 'default' }}
    >
      <div
        className="LathePulpit__stopHit"
        onMouseDown={(event) => {
          event.stopPropagation();
          if (!queued) {
            return;
          }
          setPressed(true);
          holdTimer.current = setTimeout(() => {
            held.current = true;
            onStopAll();
          }, 1000);
        }}
        onMouseUp={() => queued && release(true)}
        onMouseLeave={() => pressed && release(false)}
      />
      <AtlasSprite
        img="lathe-stop"
        atlas={[80, 40]}
        at={[pressed ? 40 : 0, 0]}
        x={0}
        y={0}
        w={40}
        h={40}
        style={{
          pointerEvents: 'none',
          filter: queued && (working || stopped) ? undefined : 'saturate(0.4)',
        }}
      />
    </Px>
  );
};

/** Zbiornik odczynników (protolat, drukarka płytek). */
const Tank = (props: { reagents: Reagent[]; capacity: number }) => {
  const { reagents, capacity } = props;
  const volume = reagents.reduce((sum, reagent) => sum + reagent.volume, 0);
  const fill = capacity ? Math.min(1, volume / capacity) : 0;
  const glassTop = 45;
  const glassHeight = 144;
  const liquid = Math.round(glassHeight * fill);
  return (
    <Px
      x={TANK.x}
      y={TANK.y}
      w={TANK.w}
      h={TANK.h}
      title={
        reagents.length
          ? `${reagents.map((reagent) => `${reagent.volume} j. ${reagent.name}`).join('\n')}\nRazem ${volume}/${capacity} j.`
          : `Pusty zbiornik (${capacity} j.)`
      }
    >
      <Sprite img="lathe-tank_back" x={0} y={0} w={40} h={198} drag />
      <Rect
        x={5}
        y={glassTop + glassHeight - liquid}
        w={30}
        h={liquid}
        color="#4a90c8"
        style={{ opacity: 0.85 }}
      />
      <Sprite
        img="lathe-tank_front"
        x={0}
        y={0}
        w={40}
        h={198}
        style={{ pointerEvents: 'none' }}
      />
      <PixelText x={0} y={67} w={40} align="center" color={OUTLINE}>
        {`${Math.round(volume)}`}
      </PixelText>
    </Px>
  );
};
