// AQUILA - konsola nawigacji FTL na mapie hex (aquila/code/modules/overmap/hexmap/hex_console.dm).
// Trzy sektory jak w grze, każdy osobną mapą kafli; skok kosztuje część naładowania napędu,
// a zagrożenie na trasie zatrzymuje okręt. Wygląd z makiety „Rework mapy FTL” (wersja 4).
import { type MouseEvent, useEffect, useMemo, useRef, useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  HEX_FACILITY_ICONS,
  HEX_TERRAIN_COLORS,
  HEX_TERRAIN_ICONS,
} from './common/hexTerrainIcons';

type Sector = { id: number; name: string; cols: number; rows: number };

type StarSystem = {
  name: string;
  hex: string;
  sector: number;
  col: number;
  row: number;
  alignment: string;
  owner: string;
  capital: boolean;
  hypergate: boolean;
  trader: string | null;
  type: string | null;
  gates: string[];
  badlands: boolean;
  facilities?: string[] | null;
  raided?: boolean;
  ore?: number;
  parts?: number;
};

type Fleet = {
  hex: string;
  name: string;
  alignment: string;
  ships: number;
  heading: string | null;
  convoy?: boolean;
  ghost?: boolean;
  seen_ago?: number;
  order?: string | null;
  commander?: number | null;
};

type CommanderTrait = {
  name: string | null;
  kind: string | null;
  desc: string | null;
};

type Commander = {
  id: number;
  name: string;
  rank: string;
  stars: number;
  faction: string;
  status: string;
  wins: number;
  losses: number;
  grudge: number;
  traits: CommanderTrait[];
  scars: string[];
  history: string[];
  fleet_hex: string | null;
  nemesis: boolean;
};

type Ship = {
  hex: string | null;
  sector: number | null;
  charge: number;
  cooldown: number;
  state: string;
  jumping: boolean;
  lockout: boolean;
  safety_override: boolean;
  in_transit: boolean;
  // koszty i czasy z bonusem układu FTL (hex_ftl_chip.dm)
  cost_hex: number;
  cost_gate: number;
  capacity: number;
  cooldown_total: number;
  startup: number;
  from?: string;
  from_hex?: string;
  to?: string;
  to_hex?: string;
  time_left?: number;
};

type ChipBonus = { id: string; name: string; desc: string };

type Chip = {
  name: string;
  tier: number;
  bonus: string;
  bonuses: ChipBonus[];
};

type Route = {
  none?: boolean;
  path?: string[];
  full?: string[];
  cost?: number;
  hexes?: number;
  stopped?: string | null;
  stopped_name?: string | null;
  blocker?: string | null;
};

type GateInfo = { name: string; hex: string; sector: number; open: boolean };

type Selected = {
  hex: string;
  sector: number;
  col: number;
  row: number;
  name: string;
  system: boolean;
  desc: string | null;
  alignment: string | null;
  owner: string | null;
  trader: string | null;
  type: string | null;
  capital: boolean;
  gates: GateInfo[];
  route?: Route;
  terrain: string;
  stops: boolean;
  blocks: boolean;
  wormhole_to: string | null;
  nuke_blocker?: string | null;
};

type Missile = {
  faction: string;
  hex: string;
  target: string | null;
  trail: string[];
};

type Terrain = {
  id: string;
  name: string;
  desc: string;
  stops: boolean;
  blocks: boolean;
};

type Data = {
  can_control: boolean;
  ship: Ship;
  systems: StarSystem[];
  fleets: Fleet[];
  gates: { a: string; b: string }[];
  reach: Record<string, number>;
  selected: Selected | null;
  sectors: Sector[];
  chip: Chip | null;
  terrains: Terrain[];
  terrain: Record<string, string>;
  wormholes: { a: string; b: string }[];
  commanders: Commander[];
  defcon: number;
  nukes_loaded: number;
  missiles: Missile[];
  objective_hexes: string[];
};

const DEFCON_COLOR: Record<number, string> = {
  5: '#5fb35f',
  4: '#9fc95f',
  3: '#e0c040',
  2: '#ff8a2a',
  1: '#ff3030',
};

const FACILITY_NAME: Record<string, string> = {
  mine: 'Kopalnia',
  factory: 'Fabryka',
  yard: 'Stocznia',
  depot: 'Depot',
  post: 'Placówka nasłuchowa',
  hq: 'Kwatera główna',
  trade: 'Stacja handlowa',
};

const FACILITY_DESC: Record<string, string> = {
  mine: 'ruda +2 co 5 min, nadmiar jedzie konwojem do fabryki',
  factory: '3 rudy → 1 część, części jadą konwojem do stoczni',
  yard: '4 części → 2 okręty albo nowa flota',
  depot: 'naprawia i uzupełnia floty strony, która go trzyma',
  post: 'widok floty w promieniu 3 kafli',
  hq: 'kwatera sztabu frakcji',
  trade: 'handel; piraci mogą ją złupić',
};

const ORDER_NAME: Record<string, string> = {
  idle: 'bez rozkazu',
  hold: 'trzyma układ',
  defend: 'obrona',
  attack: 'natarcie',
  escort: 'eskorta konwoju',
  repair: 'naprawa w depocie',
  raid: 'łupieżczy rajd',
  home: 'powrót z łupem',
  hunt: 'polowanie na okręt',
  convoy: 'konwój',
};

const STATUS_NAME: Record<string, string> = {
  active: 'w służbie',
  wounded: 'ranny, wróci',
  dead: 'poległ',
};

type View = number | 'all';

type Cell = {
  id: string;
  sector: number;
  col: number;
  row: number;
  q: number;
  r: number;
  x: number;
  y: number;
};

const R = 22;
const SQ = Math.sqrt(3);

// Ikony kafli i obiektów są 32x32. Ostre piksele tylko przy całkowitym powiększeniu na ekranie (1:1, 2:1...):
// przy zmniejszeniu albo ułamkowej skali (zoom mapy, skalowanie Windows) „pixelated” gubi całe linie pikseli
// i ikona robi się nieczytelna, więc wtedy przeglądarka skaluje gładko.
const ICON_PX = 32;
const iconRendering = (shown: number, zoom = 1) => {
  const scale = (shown / ICON_PX) * zoom * (window.devicePixelRatio || 1);
  return scale >= 1 && Math.abs(scale - Math.round(scale)) < 0.01
    ? 'pixelated'
    : 'auto';
};
const GAP = 3;

const FACTION_NAME: Record<string, string> = {
  nanotrasen: 'Nanotrasen',
  solgov: 'SolGov',
  whiterapids: 'WhiteRapids',
  syndicate: 'Syndykat',
  pirate: 'Piraci',
  unaligned: 'Niezależni',
  uncharted: 'Niezbadany',
  hostile: 'Nieznana frakcja',
};

const FACTION_COLOR: Record<string, string> = {
  nanotrasen: '#2a5bc4',
  solgov: '#6495ed',
  whiterapids: '#d8e2f0',
  syndicate: '#c21b1b',
  pirate: '#8e3cc2',
  unaligned: '#b07a1c',
  uncharted: '#555',
  hostile: '#5a1f4a',
};

const BLOC: Record<string, string | undefined> = {
  nanotrasen: 'nt',
  solgov: 'nt',
  whiterapids: 'nt',
  syndicate: 'syn',
  pirate: 'pir',
  unaligned: 'neu',
};

const hostile = (a?: string | null, b?: string | null) => {
  const A = a ? BLOC[a] : undefined;
  const B = b ? BLOC[b] : undefined;
  if (!A || !B || A === B) {
    return false;
  }
  if (A === 'pir' || B === 'pir') {
    return true;
  }
  if (A === 'neu' || B === 'neu') {
    return false;
  }
  return true;
};

const AXIAL_DIRS = [
  [1, 0],
  [1, -1],
  [0, -1],
  [-1, 0],
  [-1, 1],
  [0, 1],
];
// Krawędź hexa (rogi) leżąca naprzeciw kierunku z AXIAL_DIRS
const EDGE_CORNERS = [
  [0, 1],
  [5, 0],
  [4, 5],
  [3, 4],
  [2, 3],
  [1, 2],
];

const parseId = (id: string) => {
  const [sector, col, row] = id.split(':').map(Number);
  return { sector, col, row };
};

const hexDistance = (a: Cell, b: Cell) =>
  (Math.abs(a.q - b.q) +
    Math.abs(a.r - b.r) +
    Math.abs(a.q + a.r - b.q - b.r)) /
  2;

const percent = (value: number) => `${Math.ceil(value - 0.001)}%`;

// Ładunek zaokrąglony w górę jak koszty (2/3 to 67%), ale nigdy nie pokazuje kosztu, którego jeszcze nie pokrywa (hex_charge_text w DM,
// progi z hex_charge_thresholds(): kafel, brama i pojemność napędu z bonusem układu FTL, do tego koszt wybranej trasy)
const chargeText = (charge: number, ship: Ship, routeCost?: number) => {
  let shown = Math.ceil(charge - 0.001);
  const thresholds = [ship.cost_hex, ship.cost_gate, ship.capacity];
  if (routeCost) {
    thresholds.push(routeCost);
  }
  for (const threshold of thresholds) {
    if (charge + 0.001 < threshold) {
      shown = Math.min(shown, Math.ceil(threshold - 0.001) - 1);
    }
  }
  return `${Math.max(shown, 0)}%`;
};

const corner = (cell: Cell, i: number): [number, number] => {
  const a = (Math.PI / 180) * (60 * i - 30);
  return [cell.x + R * Math.cos(a), cell.y + R * Math.sin(a)];
};

const polygon = (cell: Cell) =>
  [0, 1, 2, 3, 4, 5]
    .map((i) =>
      corner(cell, i)
        .map((v) => v.toFixed(1))
        .join(','),
    )
    .join(' ');

/** Kafle wszystkich sektorów; w przeglądzie sektory leżą obok siebie z przerwą. */
const buildCells = (sectors: Sector[]) => {
  const cells: Record<string, Cell> = {};
  const offsets: Record<number, number> = {};
  const bounds: Record<
    string,
    { x0: number; y0: number; x1: number; y1: number }
  > = {};
  let offset = 0;
  for (const sector of sectors) {
    offsets[sector.id] = offset;
    let x1 = 0;
    let y1 = 0;
    for (let row = 0; row < sector.rows; row++) {
      for (let col = 0; col < sector.cols; col++) {
        const cell: Cell = {
          id: `${sector.id}:${col}:${row}`,
          sector: sector.id,
          col,
          row,
          q: col - (row - (row & 1)) / 2,
          r: row,
          x: R * SQ * (offset + col + 0.5 * (row & 1)) + R * 1.2,
          y: R * 1.5 * row + R * 1.3,
        };
        cells[cell.id] = cell;
        x1 = Math.max(x1, cell.x + R * 1.2);
        y1 = Math.max(y1, cell.y + R * 1.3);
      }
    }
    bounds[sector.id] = {
      x0: R * SQ * offset,
      y0: 0,
      x1,
      y1,
    };
    offset += sector.cols + GAP;
  }
  const all = Object.values(bounds);
  bounds.all = {
    x0: 0,
    y0: 0,
    x1: Math.max(0, ...all.map((b) => b.x1)),
    y1: Math.max(0, ...all.map((b) => b.y1)),
  };
  return { cells, bounds };
};

type Zone = { owner: string | null; distance: number };

/**
 * Strefa kafla: frakcja najbliższego układu w promieniu 2 (układ zajęty przez flotę ma kolor okupanta).
 * Remis rozstrzyga liczba układów tej frakcji w promieniu 4, więc strefy się stykają i da się narysować front.
 */
const buildZones = (cells: Record<string, Cell>, systems: StarSystem[]) => {
  const zones: Record<string, Zone> = {};
  const bySector: Record<number, { cell: Cell; system: StarSystem }[]> = {};
  for (const system of systems) {
    const cell = cells[system.hex];
    if (!cell || !BLOC[system.alignment]) {
      continue;
    }
    (bySector[system.sector] ||= []).push({ cell, system });
  }
  for (const cell of Object.values(cells)) {
    const list = bySector[cell.sector] || [];
    let best: { cell: Cell; system: StarSystem } | null = null;
    let bestDistance = 99;
    const weight = (entry: { cell: Cell; system: StarSystem }) =>
      list.filter(
        (other) =>
          other.system.alignment === entry.system.alignment &&
          hexDistance(other.cell, cell) <= 4,
      ).length;
    for (const entry of list) {
      const d = hexDistance(cell, entry.cell);
      if (
        d < bestDistance ||
        (d === bestDistance &&
          best &&
          entry.system.alignment !== best.system.alignment &&
          weight(entry) > weight(best))
      ) {
        bestDistance = d;
        best = entry;
      }
    }
    zones[cell.id] = {
      owner: best && bestDistance <= 2 ? best.system.alignment : null,
      distance: bestDistance,
    };
  }
  return zones;
};

const neighbourId = (cells: Record<string, Cell>, cell: Cell, k: number) => {
  const [dq, dr] = AXIAL_DIRS[k];
  const r = cell.r + dr;
  const q = cell.q + dq;
  const col = q + (r - (r & 1)) / 2;
  const id = `${cell.sector}:${col}:${r}`;
  return cells[id] ? id : null;
};

export const HexStarmap = () => {
  const { act, data } = useBackend<Data>();
  const {
    can_control,
    ship,
    systems = [],
    fleets = [],
    gates = [],
    reach = {},
    selected,
    sectors = [],
    chip,
    terrains = [],
    terrain = {},
    wormholes = [],
    commanders = [],
    defcon = 5,
    nukes_loaded = 0,
    missiles = [],
    objective_hexes = [],
  } = data;
  const [panelTab, setPanelTab] = useState<
    'hex' | 'commanders' | 'war' | 'legend'
  >('hex');

  const [view, setView] = useState<View>(ship.sector || 2);
  const [zoom, setZoom] = useState(1);
  const mapRef = useRef<HTMLDivElement>(null);
  // Kafel do wyśrodkowania po zmianie sektora („Pokaż” przy bramie); bez niego mapa wraca do okrętu
  const focusRef = useRef<string | null>(null);
  const [focusTick, setFocusTick] = useState(0);

  const { cells, bounds } = useMemo(() => buildCells(sectors), [sectors]);
  const zoneKey = systems.map((s) => `${s.hex}=${s.alignment}`).join('|');
  const zones = useMemo(() => buildZones(cells, systems), [cells, zoneKey]);

  const inView = (sector: number) => view === 'all' || sector === view;
  const box = bounds[view] || bounds.all;
  const width = Math.max(1, box.x1 - box.x0);
  const height = Math.max(1, box.y1 - box.y0);

  const centerOn = (id: string | null | undefined) => {
    const el = mapRef.current;
    const cell = id ? cells[id] : undefined;
    if (!el || !cell) {
      return;
    }
    el.scrollLeft = (cell.x - box.x0) * zoom - el.clientWidth / 2;
    el.scrollTop = (cell.y - box.y0) * zoom - el.clientHeight / 2;
  };

  useEffect(() => {
    centerOn(focusRef.current || ship.hex);
    focusRef.current = null;
  }, [view, zoom, focusTick, Object.keys(cells).length]);

  const showSector = (target: View, focus?: string) => {
    setView(target);
    // Przegląd trzech sektorów od razu w pomniejszeniu, pojedynczy sektor w zwykłej skali
    setZoom(target === 'all' ? 0.6 : 1);
    if (focus) {
      act('hex_select', { hex: focus });
      focusRef.current = focus;
      setFocusTick((tick) => tick + 1);
    }
  };

  const onMapClick = (e: MouseEvent<SVGSVGElement>) => {
    // Floty i cele misji leżą nad kaflem (mają podpowiedzi), więc kafel bierzemy z najbliższego elementu z data-hex
    const id = (e.target as SVGElement)
      .closest('[data-hex]')
      ?.getAttribute('data-hex');
    if (id) {
      act('hex_select', { hex: id });
    }
  };

  const visibleCells = Object.values(cells).filter((c) => inView(c.sector));
  const shipCell = ship.hex ? cells[ship.hex] : undefined;
  const route = selected?.route;
  const routeOk =
    !!route && !route.none && !route.blocker && can_control && !ship.lockout;

  const pathD = (ids: string[] | undefined) => {
    if (!ids) {
      return '';
    }
    let d = '';
    let pen = false;
    ids.forEach((id, i) => {
      const cell = cells[id];
      if (!cell) {
        pen = false;
        return;
      }
      const prev = i > 0 ? cells[ids[i - 1]] : undefined;
      const continues =
        pen && inView(cell.sector) && prev?.sector === cell.sector;
      d += `${continues ? 'L' : 'M'}${cell.x.toFixed(1)} ${cell.y.toFixed(1)}`;
      pen = inView(cell.sector);
    });
    return d;
  };

  // Granice stref w kolorze frakcji i front na styku wrogich stref
  const borders: Record<string, string> = {};
  let front = '';
  for (const cell of visibleCells) {
    const own = zones[cell.id]?.owner;
    if (!own) {
      continue;
    }
    for (let k = 0; k < 6; k++) {
      const nid = neighbourId(cells, cell, k);
      const other = nid ? zones[nid]?.owner : null;
      if (other === own) {
        continue;
      }
      const pin = (c: [number, number]): [number, number] => [
        c[0] + (cell.x - c[0]) * 0.1,
        c[1] + (cell.y - c[1]) * 0.1,
      ];
      const a = pin(corner(cell, EDGE_CORNERS[k][0]));
      const b = pin(corner(cell, EDGE_CORNERS[k][1]));
      borders[own] =
        (borders[own] || '') +
        `M${a[0].toFixed(1)} ${a[1].toFixed(1)}L${b[0].toFixed(1)} ${b[1].toFixed(1)}`;
      if (k < 3 && other && hostile(own, other)) {
        const fa = corner(cell, EDGE_CORNERS[k][0]);
        const fb = corner(cell, EDGE_CORNERS[k][1]);
        front += `M${fa[0].toFixed(1)} ${fa[1].toFixed(1)}L${fb[0].toFixed(1)} ${fb[1].toFixed(1)}`;
      }
    }
  }

  const fleetsByHex: Record<string, Fleet[]> = {};
  for (const fleet of fleets) {
    (fleetsByHex[fleet.hex] ||= []).push(fleet);
  }

  const sectorTab = (id: View, label: string) => {
    const here = id !== 'all' && ship.sector === id;
    return (
      <Button
        key={String(id)}
        selected={view === id}
        onClick={() => showSector(id)}
      >
        {label}
        {here && ' ◉'}
      </Button>
    );
  };

  const selectedCell = selected ? cells[selected.hex] : undefined;
  const terrainById: Record<string, Terrain> = {};
  for (const t of terrains) {
    terrainById[t.id] = t;
  }

  const legend = (
    <>
      <Box fontSize="11px" bold mb={0.5}>
        Floty
      </Box>
      <Box fontSize="11px" color="label">
        ■ flota wojenna · ◆ konwój · liczba: okręty we flocie · obwódka: zielona
        sojusz, żółta neutralni, czerwona wróg · szary znak z „?”: ostatnia
        znana pozycja floty
      </Box>
      <Box mt={0.5} mb={1} fontSize="11px">
        {Object.keys(BLOC).map((faction) => (
          <span
            key={faction}
            style={{ whiteSpace: 'nowrap', marginRight: '10px' }}
          >
            <span
              style={{
                display: 'inline-block',
                width: '10px',
                height: '10px',
                marginRight: '4px',
                verticalAlign: 'middle',
                backgroundColor: FACTION_COLOR[faction] || '#888',
                border: '1px solid #000',
              }}
            />
            {FACTION_NAME[faction] || faction}
          </span>
        ))}
      </Box>
      <Box fontSize="11px" bold mb={0.5}>
        Mapa
      </Box>
      <Box fontSize="11px" color="label">
        ◉ sektor okrętu · zielone kafle: zasięg skoku · ⇄ brama do innego
        sektora · ★ stolica · $ stacja handlowa · ◎ hiperbrama · przerywany
        pierścień: układ okupowany · czerwona linia: front
      </Box>
      <Box mt={0.5} fontSize="10px" color="label">
        {Object.keys(HEX_FACILITY_ICONS).map((fac) => (
          <span
            key={fac}
            title={FACILITY_DESC[fac]}
            style={{ whiteSpace: 'nowrap', marginRight: '8px' }}
          >
            <img
              alt=""
              src={HEX_FACILITY_ICONS[fac]}
              width={ICON_PX}
              height={ICON_PX}
              style={{
                verticalAlign: 'middle',
                imageRendering: iconRendering(ICON_PX),
              }}
            />{' '}
            {FACILITY_NAME[fac]}
          </span>
        ))}
        {' · żółte „!”: cel misji · ☢ pocisk termojądrowy'}
      </Box>
      <Box mt={0.5} fontSize="10px" color="label">
        {terrains
          .filter((t) => !!HEX_TERRAIN_ICONS[t.id])
          .map((t) => (
            <span
              key={t.id}
              title={t.desc}
              style={{ whiteSpace: 'nowrap', marginRight: '8px' }}
            >
              <img
                alt=""
                src={HEX_TERRAIN_ICONS[t.id]}
                width={ICON_PX}
                height={ICON_PX}
                style={{
                  verticalAlign: 'middle',
                  imageRendering: iconRendering(ICON_PX),
                }}
              />{' '}
              {t.name}
            </span>
          ))}
      </Box>
    </>
  );

  return (
    <Window
      width={1220}
      height={780}
      theme="ntos"
      title="Konsola nawigacji FTL"
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
            <Stack vertical fill>
              <Stack.Item>
                {sectorTab('all', 'Przegląd')}
                {sectors.map((s) => sectorTab(s.id, s.name))}
                <Button
                  icon="crosshairs"
                  ml={1}
                  onClick={() => {
                    if (ship.sector) {
                      setView(ship.sector);
                    }
                    centerOn(ship.hex);
                  }}
                >
                  Do okrętu
                </Button>
                <Box
                  inline
                  ml={1}
                  px={1}
                  bold
                  style={{
                    border: `1px solid ${DEFCON_COLOR[defcon] || '#888'}`,
                    color: DEFCON_COLOR[defcon] || '#888',
                    borderRadius: '3px',
                  }}
                >
                  {`DEFCON ${defcon}`}
                </Box>
                <Button
                  icon="search-minus"
                  onClick={() => setZoom(Math.max(0.4, zoom - 0.2))}
                />
                <Button
                  icon="search-plus"
                  onClick={() => setZoom(Math.min(1.6, zoom + 0.2))}
                />
              </Stack.Item>
              <Stack.Item grow basis={0} style={{ minWidth: 0, minHeight: 0 }}>
                <div
                  ref={mapRef}
                  style={{
                    height: '100%',
                    width: '100%',
                    overflow: 'auto',
                    border: '1px solid #40628a',
                    backgroundColor: '#000',
                    backgroundImage: `url(${resolveAsset('space.png')})`,
                  }}
                >
                  <svg
                    width={width * zoom}
                    height={height * zoom}
                    viewBox={`${box.x0} ${box.y0} ${width} ${height}`}
                    onClick={onMapClick}
                    style={{ display: 'block' }}
                  >
                    {visibleCells.map((cell) => {
                      const zone = zones[cell.id];
                      const color = zone?.owner
                        ? FACTION_COLOR[zone.owner]
                        : undefined;
                      const opacity = zone?.owner
                        ? [0.46, 0.3, 0.16][Math.min(2, zone.distance)]
                        : 0;
                      return (
                        <polygon
                          key={cell.id}
                          data-hex={cell.id}
                          points={polygon(cell)}
                          fill={color || 'transparent'}
                          fillOpacity={opacity}
                          stroke="#7fa6d6"
                          strokeOpacity={0.15}
                          style={{ cursor: 'pointer' }}
                        />
                      );
                    })}
                    {visibleCells
                      .filter((cell) => !!terrain[cell.id])
                      .map((cell) => {
                        const kind = terrain[cell.id];
                        const size = ICON_PX; // 1:1 z oryginałem przy zoomie 100%
                        return (
                          <g key={`terrain-${cell.id}`} pointerEvents="none">
                            <polygon
                              points={polygon(cell)}
                              fill={HEX_TERRAIN_COLORS[kind] || '#888'}
                              fillOpacity={0.2}
                            />
                            {!!HEX_TERRAIN_ICONS[kind] && (
                              <image
                                href={HEX_TERRAIN_ICONS[kind]}
                                x={cell.x - size / 2}
                                y={cell.y - size / 2}
                                width={size}
                                height={size}
                                opacity={0.85}
                                style={{
                                  imageRendering: iconRendering(size, zoom),
                                }}
                              />
                            )}
                          </g>
                        );
                      })}
                    {wormholes.map((pair) => {
                      const a = cells[pair.a];
                      const b = cells[pair.b];
                      if (!a || !b || !inView(a.sector) || !inView(b.sector)) {
                        return null;
                      }
                      return (
                        <line
                          key={`wormhole-${pair.a}-${pair.b}`}
                          x1={a.x}
                          y1={a.y}
                          x2={b.x}
                          y2={b.y}
                          stroke={HEX_TERRAIN_COLORS.wh}
                          strokeOpacity={0.45}
                          strokeDasharray="2 6"
                          pointerEvents="none"
                        />
                      );
                    })}
                    {visibleCells
                      .filter((cell) => reach[cell.id] !== undefined)
                      .map((cell) => (
                        <polygon
                          key={`reach-${cell.id}`}
                          points={polygon(cell)}
                          fill="#3fbf5a"
                          fillOpacity={0.1}
                          stroke="#3fbf5a"
                          strokeOpacity={0.7}
                          strokeWidth={1.2}
                          pointerEvents="none"
                        />
                      ))}
                    {Object.entries(borders).map(([faction, d]) => (
                      <path
                        key={`border-${faction}`}
                        d={d}
                        stroke={FACTION_COLOR[faction]}
                        strokeOpacity={0.85}
                        strokeWidth={1.4}
                        strokeLinecap="round"
                        fill="none"
                        pointerEvents="none"
                      />
                    ))}
                    <path
                      d={front}
                      stroke="#ff4a3a"
                      strokeWidth={3}
                      strokeLinecap="round"
                      fill="none"
                      opacity={0.9}
                      pointerEvents="none"
                    />
                    {view === 'all' &&
                      gates.map((gate) => {
                        const a = cells[gate.a];
                        const b = cells[gate.b];
                        if (!a || !b) {
                          return null;
                        }
                        return (
                          <line
                            key={`gate-${gate.a}-${gate.b}`}
                            x1={a.x}
                            y1={a.y}
                            x2={b.x}
                            y2={b.y}
                            stroke="#7fffd4"
                            strokeOpacity={0.6}
                            strokeDasharray="5 5"
                            pointerEvents="none"
                          />
                        );
                      })}
                    {route?.stopped && (
                      <path
                        d={pathD(route.full)}
                        stroke="#ffe066"
                        strokeOpacity={0.3}
                        strokeWidth={2}
                        strokeDasharray="3 5"
                        fill="none"
                        pointerEvents="none"
                      />
                    )}
                    {route?.path && (
                      <path
                        d={pathD(route.path)}
                        stroke={routeOk ? '#ffe066' : '#ff8a70'}
                        strokeWidth={2.5}
                        strokeDasharray="6 4"
                        fill="none"
                        pointerEvents="none"
                      />
                    )}
                    {!!ship.in_transit && !!ship.from_hex && !!ship.to_hex && (
                      <path
                        d={pathD([ship.from_hex, ship.to_hex])}
                        stroke="#00ffff"
                        strokeWidth={2}
                        strokeDasharray="4 4"
                        fill="none"
                        pointerEvents="none"
                      />
                    )}
                    {(view === 'all'
                      ? sectors
                      : sectors.filter((s) => s.id === view)
                    ).map((sector) => {
                      const b = bounds[sector.id];
                      return (
                        <g key={`label-${sector.id}`} pointerEvents="none">
                          <text
                            x={b.x0 + 10}
                            y={b.y0 + 15}
                            fontSize={13}
                            fontWeight="bold"
                            fill="#8fc1ff"
                            stroke="#000"
                            strokeWidth={3}
                            paintOrder="stroke"
                          >
                            {sector.name}
                          </text>
                          {view === 'all' && (
                            <rect
                              x={b.x0 + 2}
                              y={b.y0 + 2}
                              width={b.x1 - b.x0 - 4}
                              height={b.y1 - b.y0 - 4}
                              fill="none"
                              stroke="#5fb3ff"
                              strokeOpacity={0.5}
                              strokeDasharray="6 5"
                            />
                          )}
                        </g>
                      );
                    })}
                    {systems
                      .filter((s) => inView(s.sector))
                      .map((system) => {
                        const cell = cells[system.hex];
                        if (!cell) {
                          return null;
                        }
                        const color = FACTION_COLOR[system.alignment] || '#888';
                        const occupied = system.alignment !== system.owner;
                        return (
                          <g key={`sys-${system.hex}`} pointerEvents="none">
                            {system.gates.length > 0 && (
                              <>
                                <polygon
                                  points={polygon(cell)}
                                  fill="none"
                                  stroke="#7fffd4"
                                  strokeWidth={2}
                                  strokeDasharray="4 3"
                                />
                                <text
                                  x={cell.x}
                                  y={cell.y + R * 0.8 + 11}
                                  textAnchor="middle"
                                  fontSize={9}
                                  fill="#7fffd4"
                                  stroke="#000"
                                  strokeWidth={2.6}
                                  paintOrder="stroke"
                                >
                                  {`⇄ ${system.gates.join(', ')}`}
                                </text>
                              </>
                            )}
                            <circle
                              cx={cell.x}
                              cy={cell.y}
                              r={9}
                              fill={color}
                              opacity={0.35}
                            />
                            <circle
                              cx={cell.x}
                              cy={cell.y}
                              r={4.5}
                              fill={color}
                              stroke="#fff"
                              strokeWidth={1}
                            />
                            {occupied && FACTION_COLOR[system.owner] && (
                              <circle
                                cx={cell.x}
                                cy={cell.y}
                                r={12}
                                fill="none"
                                stroke={FACTION_COLOR[system.owner]}
                                strokeWidth={2}
                                strokeDasharray="3 2"
                              />
                            )}
                            {!!(
                              system.capital ||
                              system.trader ||
                              system.hypergate
                            ) && (
                              <text
                                x={cell.x - R * 0.85}
                                y={cell.y - R * 0.35}
                                fontSize={10}
                                fill="#ffd56a"
                                stroke="#000"
                                strokeWidth={2.4}
                                paintOrder="stroke"
                              >
                                {`${system.capital ? '★' : ''}${system.trader ? '$' : ''}${system.hypergate ? '◎' : ''}`}
                              </text>
                            )}
                            <text
                              x={cell.x}
                              y={cell.y + R * 0.8}
                              textAnchor="middle"
                              fontSize={9.5}
                              fill="#fff"
                              stroke="#000"
                              strokeWidth={2.6}
                              paintOrder="stroke"
                            >
                              {system.name}
                            </text>
                            {(system.facilities || [])
                              .filter((fac) => !!HEX_FACILITY_ICONS[fac])
                              .slice(0, 3)
                              .map((fac, i, list) => {
                                const size = ICON_PX / 2; // trzy obok siebie nad układem
                                return (
                                  <image
                                    key={fac}
                                    href={HEX_FACILITY_ICONS[fac]}
                                    x={
                                      cell.x -
                                      (list.length * size) / 2 +
                                      i * size
                                    }
                                    y={cell.y - R * 0.98}
                                    width={size}
                                    height={size}
                                    opacity={
                                      fac === 'trade' && system.raided
                                        ? 0.35
                                        : 1
                                    }
                                    style={{
                                      imageRendering: iconRendering(size, zoom),
                                    }}
                                  />
                                );
                              })}
                          </g>
                        );
                      })}
                    {Object.entries(fleetsByHex).map(([id, list]) => {
                      const cell = cells[id];
                      if (!cell || !inView(cell.sector)) {
                        return null;
                      }
                      return list.map((fleet, k) => {
                        const ring = !hostile('nanotrasen', fleet.alignment)
                          ? BLOC[fleet.alignment] === 'nt'
                            ? '#32cd32'
                            : '#d8a032'
                          : '#ff3030';
                        const x = cell.x + R * 0.42 - k * 16;
                        const y = cell.y + R * 0.12;
                        const shape = fleet.convoy
                          ? `M${x} ${y - 9}l9 9-9 9-9-9z`
                          : `M${x - 7.5} ${y - 7.5}h15v15h-15z`;
                        const fill = fleet.ghost
                          ? '#000a'
                          : FACTION_COLOR[fleet.alignment] || '#888';
                        return (
                          <g
                            key={`fleet-${id}-${k}`}
                            data-hex={id}
                            style={{ cursor: 'pointer' }}
                            opacity={fleet.ghost ? 0.45 : 1}
                          >
                            <title>
                              {fleet.ghost
                                ? `${fleet.name} (ostatnio widziana ${fleet.seen_ago} min temu)`
                                : fleet.order
                                  ? `${fleet.name}: ${ORDER_NAME[fleet.order] || fleet.order}`
                                  : fleet.name}
                            </title>
                            <path
                              d={shape}
                              fill={fill}
                              stroke={fleet.ghost ? '#9aa4b2' : ring}
                              strokeWidth={2}
                              strokeDasharray={fleet.ghost ? '2 2' : undefined}
                            />
                            <text
                              x={x}
                              y={y + 4}
                              textAnchor="middle"
                              fontSize={11}
                              fontWeight="bold"
                              fill={fleet.ghost ? '#9aa4b2' : '#fff'}
                              stroke="#000"
                              strokeWidth={2.5}
                              paintOrder="stroke"
                            >
                              {fleet.ghost ? '?' : fleet.ships}
                            </text>
                          </g>
                        );
                      });
                    })}
                    {objective_hexes
                      .filter((id) => !!cells[id] && inView(cells[id].sector))
                      .map((id) => (
                        <g
                          key={`objective-${id}`}
                          data-hex={id}
                          style={{ cursor: 'pointer' }}
                        >
                          <title>Cel misji</title>
                          <polygon
                            points={polygon(cells[id])}
                            fill="none"
                            stroke="#ffd56a"
                            strokeWidth={2.4}
                            strokeDasharray="6 3"
                          />
                          <text
                            x={cells[id].x + R * 0.55}
                            y={cells[id].y - R * 0.45}
                            textAnchor="middle"
                            fontSize={13}
                            fontWeight="bold"
                            fill="#ffd56a"
                            stroke="#000"
                            strokeWidth={2.6}
                            paintOrder="stroke"
                          >
                            !
                          </text>
                        </g>
                      ))}
                    {missiles.map((m, i) => {
                      const head = cells[m.hex];
                      return (
                        <g key={`missile-${i}`} pointerEvents="none">
                          <path
                            d={pathD(m.trail)}
                            stroke="#ff3030"
                            strokeWidth={2}
                            strokeDasharray="2 3"
                            fill="none"
                          />
                          {!!m.target &&
                            cells[m.target] &&
                            inView(cells[m.target].sector) && (
                              <circle
                                cx={cells[m.target].x}
                                cy={cells[m.target].y}
                                r={R * 0.9}
                                fill="none"
                                stroke="#ff3030"
                                strokeWidth={1.5}
                                strokeDasharray="4 3"
                              />
                            )}
                          {!!head && inView(head.sector) && (
                            <text
                              x={head.x}
                              y={head.y + 5}
                              textAnchor="middle"
                              fontSize={15}
                              fill="#ff3030"
                              stroke="#000"
                              strokeWidth={2.6}
                              paintOrder="stroke"
                            >
                              ☢
                            </text>
                          )}
                        </g>
                      );
                    })}
                    {shipCell && inView(shipCell.sector) && (
                      <g pointerEvents="none">
                        <circle
                          cx={shipCell.x}
                          cy={shipCell.y - 1}
                          r={11}
                          fill="#000a"
                          stroke="#0ff"
                          strokeWidth={1.6}
                        />
                        <path
                          d={`M${shipCell.x} ${shipCell.y - 8}l6 11h-12z`}
                          fill="#0ff"
                        />
                      </g>
                    )}
                    {route?.stopped && cells[route.stopped] && (
                      <polygon
                        points={polygon(cells[route.stopped])}
                        fill="none"
                        stroke="#ff9b4a"
                        strokeWidth={2.4}
                        pointerEvents="none"
                      />
                    )}
                    {selectedCell && inView(selectedCell.sector) && (
                      <polygon
                        points={polygon(selectedCell)}
                        fill="none"
                        stroke="#ffe066"
                        strokeWidth={2.2}
                        pointerEvents="none"
                      />
                    )}
                  </svg>
                </div>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item width="330px">
            <Stack vertical fill>
              {!!ship.lockout && (
                <Stack.Item>
                  <NoticeBox danger>
                    Napęd zablokowany kodem nadpisania. Okręt wraca na koniec
                    zmiany.
                  </NoticeBox>
                </Stack.Item>
              )}
              <Stack.Item>
                <Section title="Napęd FTL">
                  <ProgressBar
                    value={ship.charge}
                    minValue={0}
                    maxValue={ship.capacity}
                    ranges={{
                      good: [100 - 0.001, Infinity],
                      average: [ship.cost_hex, 100 - 0.001],
                      bad: [-Infinity, ship.cost_hex],
                    }}
                  >
                    {chargeText(ship.charge, ship, route?.cost)}
                  </ProgressBar>
                  <LabeledList>
                    <LabeledList.Item label="Stan">
                      {ship.state}
                      {ship.cooldown > 0 && ` (${ship.cooldown} s)`}
                    </LabeledList.Item>
                    <LabeledList.Item label="Atomówki w wyrzutniach">
                      {nukes_loaded}
                    </LabeledList.Item>
                    <LabeledList.Item label="Koszt skoku">
                      {`kafel ${percent(ship.cost_hex)}, brama ${percent(ship.cost_gate)}`}
                    </LabeledList.Item>
                    <LabeledList.Item label="Rozruch i stygnięcie">
                      {`${ship.startup} s rozruchu, po skoku ${ship.cooldown_total} s bez ładowania`}
                    </LabeledList.Item>
                    {ship.in_transit ? (
                      <LabeledList.Item label="Lot">
                        {`${ship.from} → ${ship.to}, ${ship.time_left} s`}
                      </LabeledList.Item>
                    ) : (
                      <LabeledList.Item label="Położenie">
                        {shipCell
                          ? (systems.find((s) => s.hex === ship.hex)?.name ??
                            (terrainById[terrain[shipCell.id]]
                              ? `${terrainById[terrain[shipCell.id]].name} ${shipCell.col},${shipCell.row}`
                              : `Pusty kafel ${shipCell.col},${shipCell.row}`))
                          : 'nieznane'}
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                  {!!can_control && !!ship.jumping && (
                    <Button
                      fluid
                      mt={1}
                      icon="ban"
                      color="bad"
                      onClick={() => act('hex_cancel')}
                    >
                      Anuluj skok (ładunek zostaje)
                    </Button>
                  )}
                  <ChipPanel
                    chip={chip}
                    canControl={!!can_control && !ship.jumping}
                    onBonus={(bonus) => act('hex_chip_bonus', { bonus })}
                  />
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section
                  fill
                  scrollable
                  title={
                    <Tabs>
                      <Tabs.Tab
                        selected={panelTab === 'hex'}
                        onClick={() => setPanelTab('hex')}
                      >
                        Kafel
                      </Tabs.Tab>
                      <Tabs.Tab
                        selected={panelTab === 'commanders'}
                        onClick={() => setPanelTab('commanders')}
                      >
                        {`Dowódcy (${commanders.length})`}
                      </Tabs.Tab>
                      <Tabs.Tab
                        selected={panelTab === 'war'}
                        onClick={() => setPanelTab('war')}
                      >
                        Wojna
                      </Tabs.Tab>
                      <Tabs.Tab
                        selected={panelTab === 'legend'}
                        onClick={() => setPanelTab('legend')}
                      >
                        Legenda
                      </Tabs.Tab>
                    </Tabs>
                  }
                >
                  {panelTab === 'commanders' ? (
                    <CommandersPanel commanders={commanders} />
                  ) : panelTab === 'war' ? (
                    <WarPanel
                      systems={systems}
                      fleets={fleets}
                      commanders={commanders}
                    />
                  ) : panelTab === 'legend' ? (
                    legend
                  ) : !selected ? (
                    <Box color="label">
                      Kliknij kafel na mapie, żeby zobaczyć trasę i koszt skoku.
                    </Box>
                  ) : (
                    <SelectedPanel
                      selected={selected}
                      ship={ship}
                      canControl={can_control}
                      routeOk={routeOk}
                      terrain={terrainById[selected.terrain]}
                      system={systems.find((s) => s.hex === selected.hex)}
                      nukesLoaded={nukes_loaded}
                      onNuke={() => act('hex_nuke', { hex: selected.hex })}
                      onJump={() => act('hex_jump', { hex: selected.hex })}
                      onShowGate={(gate) => showSector(gate.sector, gate.hex)}
                    />
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// Układ FTL w konsoli (hex_ftl_chip.dm): jeden bonus skoku do wyboru, koszty liczy DM
const ChipPanel = (props: {
  chip: Chip | null;
  canControl: boolean;
  onBonus: (bonus: string) => void;
}) => {
  const { chip, canControl, onBonus } = props;
  if (!chip) {
    return (
      <Box mt={1} color="label" fontSize="11px">
        Bez układu FTL. Matrycę strumienia albo układ warp włóż do tej konsoli.
      </Box>
    );
  }
  const current = chip.bonuses.find((bonus) => bonus.id === chip.bonus);
  return (
    <Box mt={1}>
      <Box bold mb={0.5}>
        {chip.name}
      </Box>
      {chip.bonuses.map((bonus) => (
        <Button
          key={bonus.id}
          fluid
          selected={bonus.id === chip.bonus}
          disabled={!canControl}
          tooltip={bonus.desc}
          onClick={() => onBonus(bonus.id)}
        >
          {bonus.name}
        </Button>
      ))}
      {!!current && (
        <Box mt={0.5} color="label" fontSize="11px">
          {current.desc}
        </Box>
      )}
    </Box>
  );
};

type SelectedPanelProps = {
  selected: Selected;
  ship: Ship;
  canControl: boolean;
  routeOk: boolean;
  terrain?: Terrain;
  system?: StarSystem;
  nukesLoaded: number;
  onNuke: () => void;
  onJump: () => void;
  onShowGate: (gate: GateInfo) => void;
};

const SelectedPanel = (props: SelectedPanelProps) => {
  const {
    selected,
    ship,
    canControl,
    routeOk,
    terrain,
    system,
    nukesLoaded,
    onNuke,
    onJump,
    onShowGate,
  } = props;
  // Uzbrojenie dotyczy jednego kafla: po zmianie zaznaczenia trzeba potwierdzić od nowa
  const [armedHex, setArmedHex] = useState<string | null>(null);
  const nukeArmed = armedHex === selected.hex;
  // A -> B -> A: każda zmiana zaznaczenia rozbraja przycisk
  useEffect(() => setArmedHex(null), [selected.hex]);
  const route = selected.route;
  const showTerrain = !!terrain && terrain.id !== 'empty';
  return (
    <>
      <Box bold fontSize="14px" mb={1}>
        {selected.name}
      </Box>
      <LabeledList>
        {!!selected.system && (
          <LabeledList.Item label="Frakcja">
            {FACTION_NAME[selected.alignment || ''] || selected.alignment}
            {selected.owner &&
              selected.owner !== selected.alignment &&
              ` (okupacja, właściciel: ${FACTION_NAME[selected.owner] || selected.owner})`}
          </LabeledList.Item>
        )}
        {!!selected.type && (
          <LabeledList.Item label="Typ">{selected.type}</LabeledList.Item>
        )}
        {!!selected.trader && (
          <LabeledList.Item label="Stacja">{selected.trader}</LabeledList.Item>
        )}
        {!!selected.capital && (
          <LabeledList.Item label="Stolica">tak</LabeledList.Item>
        )}
        {selected.gates.map((gate) => (
          <LabeledList.Item key={gate.hex} label="Brama">
            {`⇄ ${gate.name} `}
            {!gate.open && (
              <Box inline color="bad">
                (zamknięta, układ w rękach wroga)
              </Box>
            )}
            <Button ml={1} onClick={() => onShowGate(gate)}>
              Pokaż
            </Button>
          </LabeledList.Item>
        ))}
      </LabeledList>
      {!!selected.desc && (
        <Box mt={1} color="label" italic>
          {selected.desc}
        </Box>
      )}
      {!!system?.facilities?.length && (
        <Box mt={1}>
          {system.facilities.map((fac) => (
            <div key={fac} title={FACILITY_DESC[fac]}>
              {!!HEX_FACILITY_ICONS[fac] && (
                <img
                  alt=""
                  src={HEX_FACILITY_ICONS[fac]}
                  width={ICON_PX}
                  height={ICON_PX}
                  style={{
                    verticalAlign: 'middle',
                    imageRendering: iconRendering(ICON_PX),
                    marginRight: '4px',
                  }}
                />
              )}
              {FACILITY_NAME[fac] || fac}
              {fac === 'trade' && !!system.raided && (
                <Box inline color="bad" ml={1}>
                  złupiona, nie handluje
                </Box>
              )}
            </div>
          ))}
          {(!!system.ore || !!system.parts) && (
            <Box color="label">
              {`Magazyn: ruda ${system.ore || 0}, części ${system.parts || 0}`}
            </Box>
          )}
        </Box>
      )}
      {showTerrain && (
        <Box mt={1}>
          {!!HEX_TERRAIN_ICONS[terrain.id] && (
            <img
              alt=""
              src={HEX_TERRAIN_ICONS[terrain.id]}
              width={ICON_PX}
              height={ICON_PX}
              style={{
                float: 'left',
                marginRight: '6px',
                imageRendering: iconRendering(ICON_PX),
              }}
            />
          )}
          <Box bold>{terrain.name}</Box>
          <Box color="label">{terrain.desc}</Box>
          {selected.blocks ? (
            <Box color="bad">Nie da się tu wlecieć.</Box>
          ) : selected.stops ? (
            <Box color="average">
              Zagrożenie: okręt i floty zatrzymują się na tym kaflu.
            </Box>
          ) : (
            <Box color="good">Przelot bez zatrzymania.</Box>
          )}
          {!!selected.wormhole_to && (
            <Box>{`Tunel prowadzi do: ${selected.wormhole_to}.`}</Box>
          )}
        </Box>
      )}
      <Box mt={1}>
        {selected.hex === ship.hex ? (
          <Box color="label">Okręt jest w tym kaflu.</Box>
        ) : !route || route.none ? (
          <Box color="bad">Brak trasy do tego kafla.</Box>
        ) : (
          <>
            <Box>
              {`Skok: ${route.hexes} kaf., ${percent(route.cost || 0)} naładowania.`}
            </Box>
            {!!route.stopped && (
              <Box color="average">
                {`Na trasie jest zagrożenie: okręt zatrzyma się w ${route.stopped_name}.`}
              </Box>
            )}
            {!!route.blocker && <Box color="bad">{route.blocker}</Box>}
          </>
        )}
      </Box>
      {!!canControl && selected.hex !== ship.hex && (
        <Button
          fluid
          mt={1}
          icon={ship.safety_override ? 'exclamation-triangle' : 'rocket'}
          color={ship.safety_override ? 'bad' : 'good'}
          disabled={!ship.safety_override && !routeOk}
          onClick={onJump}
        >
          {ship.safety_override ? 'Skok awaryjny' : 'Skok'}
        </Button>
      )}
      {!!canControl && nukesLoaded > 0 && selected.hex !== ship.hex && (
        <Box mt={1}>
          {selected.nuke_blocker ? (
            <Box color="label" fontSize="11px">
              {`Atomówka: ${selected.nuke_blocker}`}
            </Box>
          ) : (
            <Button
              fluid
              icon="radiation"
              color={nukeArmed ? 'bad' : 'average'}
              onClick={() => {
                if (!nukeArmed) {
                  setArmedHex(selected.hex);
                  return;
                }
                setArmedHex(null);
                onNuke();
              }}
            >
              {nukeArmed
                ? 'Potwierdź odpalenie atomówki'
                : 'Odpal atomówkę w ten kafel'}
            </Button>
          )}
        </Box>
      )}
    </>
  );
};

/** Podsumowanie wojny: kto ile trzyma układów, ile zajął, ile flot widać i jak idzie dowódcom */
const WarPanel = (props: {
  systems: StarSystem[];
  fleets: Fleet[];
  commanders: Commander[];
}) => {
  const { systems, fleets, commanders } = props;
  const rows: Record<
    string,
    {
      held: number;
      taken: number;
      lost: number;
      fleets: number;
      ships: number;
      wins: number;
      losses: number;
    }
  > = {};
  const row = (faction: string) =>
    (rows[faction] ||= {
      held: 0,
      taken: 0,
      lost: 0,
      fleets: 0,
      ships: 0,
      wins: 0,
      losses: 0,
    });
  for (const system of systems) {
    if (!BLOC[system.alignment]) {
      continue;
    }
    row(system.alignment).held++;
    if (system.owner && system.owner !== system.alignment) {
      row(system.alignment).taken++;
      if (BLOC[system.owner]) {
        row(system.owner).lost++;
      }
    }
  }
  for (const fleet of fleets) {
    if (fleet.ghost || !BLOC[fleet.alignment]) {
      continue;
    }
    row(fleet.alignment).fleets++;
    row(fleet.alignment).ships += fleet.ships;
  }
  for (const c of commanders) {
    if (BLOC[c.faction]) {
      row(c.faction).wins += c.wins;
      row(c.faction).losses += c.losses;
    }
  }
  const factions = Object.keys(rows).sort(
    (a, b) => rows[b].held - rows[a].held,
  );
  if (!factions.length) {
    return <Box color="label">Brak danych o wojnie.</Box>;
  }
  return (
    <>
      <Table>
        <Table.Row header>
          <Table.Cell>Frakcja</Table.Cell>
          <Table.Cell>Liczba układów</Table.Cell>
          <Table.Cell>Zajęte / utracone</Table.Cell>
          <Table.Cell>Floty</Table.Cell>
          <Table.Cell>Bitwy</Table.Cell>
        </Table.Row>
        {factions.map((faction) => (
          <Table.Row key={faction}>
            <Table.Cell bold color={FACTION_COLOR[faction] || 'label'}>
              {FACTION_NAME[faction] || faction}
            </Table.Cell>
            <Table.Cell>{rows[faction].held}</Table.Cell>
            <Table.Cell>
              {`${rows[faction].taken} / ${rows[faction].lost}`}
            </Table.Cell>
            <Table.Cell>
              {`${rows[faction].fleets} (${rows[faction].ships} okr.)`}
            </Table.Cell>
            <Table.Cell>
              {`${rows[faction].wins}–${rows[faction].losses}`}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
      <Box mt={1} fontSize="11px" color="label">
        Układy: pod kontrolą frakcji. Zajęte / utracone: cudze układy, które
        frakcja okupuje, i własne, które straciła. Floty: widziane przez
        sensory. Bitwy: zwycięstwa i porażki znanych dowódców.
      </Box>
    </>
  );
};

const CommandersPanel = (props: { commanders: Commander[] }) => {
  const { commanders } = props;
  if (!commanders.length) {
    return (
      <Box color="label">
        Załoga nie widziała jeszcze żadnej floty z dowódcą. Dowódca pojawia się
        tu, gdy jego flota znajdzie się w zasięgu sensorów.
      </Box>
    );
  }
  return (
    <>
      {commanders.map((c) => (
        <Box
          key={c.id}
          mb={1}
          p={0.5}
          style={{
            borderLeft: `3px solid ${FACTION_COLOR[c.faction] || '#888'}`,
            opacity: c.status === 'dead' ? 0.55 : 1,
          }}
        >
          <Box bold>{`${'★'.repeat(c.stars) || '·'} ${c.rank} ${c.name}`}</Box>
          {!!c.nemesis && (
            <Box color="average">Nemezis: dowodzi bossem swojego układu.</Box>
          )}
          <Box color="label">
            {`${FACTION_NAME[c.faction] || c.faction}, ${STATUS_NAME[c.status] || c.status}, zwycięstwa ${c.wins}, porażki ${c.losses}`}
          </Box>
          {c.grudge > 0 && (
            <Box color="bad">Poprzysiągł zemstę naszemu okrętowi.</Box>
          )}
          <Box>
            {c.traits.map((t, i) => (
              <span
                key={i}
                title={t.desc || 'Cecha nieznana: spotkaj jego flotę.'}
                style={{
                  display: 'inline-block',
                  marginRight: '4px',
                  padding: '0 4px',
                  borderRadius: '3px',
                  backgroundColor:
                    t.kind === 's'
                      ? '#2c5f2d'
                      : t.kind === 'w'
                        ? '#6b2a2a'
                        : t.kind === 'x'
                          ? '#4a3f6b'
                          : '#333',
                }}
              >
                {t.name || '?'}
              </span>
            ))}
          </Box>
          {c.scars.map((scar, i) => (
            <Box key={i} color="average" fontSize="11px">
              {`Blizna: ${scar}`}
            </Box>
          ))}
          {c.history.slice(0, 3).map((h, i) => (
            <Box key={i} color="label" fontSize="10px">
              {h}
            </Box>
          ))}
        </Box>
      ))}
    </>
  );
};
