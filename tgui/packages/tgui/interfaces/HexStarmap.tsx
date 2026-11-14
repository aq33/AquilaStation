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
} from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

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
};

type Fleet = {
  hex: string;
  name: string;
  alignment: string;
  ships: number;
  heading: string | null;
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
  from?: string;
  from_hex?: string;
  to?: string;
  to_hex?: string;
  time_left?: number;
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
  cost_hex: number;
  cost_gate: number;
  cooldown: number;
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
const GAP = 3;

const FACTION_NAME: Record<string, string> = {
  nanotrasen: 'Nanotrasen',
  solgov: 'SolGov',
  whiterapids: 'WhiteRapids',
  syndicate: 'Syndykat',
  pirate: 'Piraci',
  unaligned: 'Niezależni',
  uncharted: 'Niezbadany',
};

const FACTION_COLOR: Record<string, string> = {
  nanotrasen: '#2a5bc4',
  solgov: '#6495ed',
  whiterapids: '#d8e2f0',
  syndicate: '#c21b1b',
  pirate: '#8e3cc2',
  unaligned: '#b07a1c',
  uncharted: '#555',
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
    cost_hex,
    cost_gate,
    cooldown,
  } = data;

  const [view, setView] = useState<View>(ship.sector || 2);
  const [zoom, setZoom] = useState(1);
  const mapRef = useRef<HTMLDivElement>(null);

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
    centerOn(ship.hex);
  }, [view, zoom, Object.keys(cells).length]);

  const showSector = (target: View, focus?: string) => {
    setView(target);
    // Przegląd trzech sektorów od razu w pomniejszeniu, pojedynczy sektor w zwykłej skali
    setZoom(target === 'all' ? 0.6 : 1);
    if (focus) {
      act('hex_select', { hex: focus });
    }
  };

  const onMapClick = (e: MouseEvent<SVGSVGElement>) => {
    const id = (e.target as SVGElement).getAttribute('data-hex');
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
                <Button
                  icon="search-minus"
                  onClick={() => setZoom(Math.max(0.4, zoom - 0.2))}
                />
                <Button
                  icon="search-plus"
                  onClick={() => setZoom(Math.min(1.6, zoom + 0.2))}
                />
              </Stack.Item>
              <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
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
                        const x = cell.x + R * 0.42 - k * 12;
                        const y = cell.y + R * 0.12;
                        return (
                          <g key={`fleet-${id}-${k}`} pointerEvents="none">
                            <title>{fleet.name}</title>
                            <path
                              d={`M${x} ${y - 7}l7 7-7 7-7-7z`}
                              fill="#000a"
                              stroke={ring}
                              strokeWidth={1.4}
                            />
                            <text
                              x={x}
                              y={y + 3.5}
                              textAnchor="middle"
                              fontSize={8.5}
                              fill={ring}
                            >
                              {fleet.ships}
                            </text>
                          </g>
                        );
                      });
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
                    maxValue={100}
                    ranges={{
                      good: [100 - 0.001, Infinity],
                      average: [cost_hex, 100 - 0.001],
                      bad: [-Infinity, cost_hex],
                    }}
                  >
                    {`${Math.floor(ship.charge)}%`}
                  </ProgressBar>
                  <LabeledList>
                    <LabeledList.Item label="Stan">
                      {ship.state}
                      {ship.cooldown > 0 && ` (${ship.cooldown} s)`}
                    </LabeledList.Item>
                    <LabeledList.Item label="Koszt skoku">
                      {`kafel ${percent(cost_hex)}, brama ${percent(cost_gate)}`}
                    </LabeledList.Item>
                    <LabeledList.Item label="Po skoku">
                      {`${cooldown} s chłodzenia bez ładowania`}
                    </LabeledList.Item>
                    {ship.in_transit ? (
                      <LabeledList.Item label="Lot">
                        {`${ship.from} → ${ship.to}, ${ship.time_left} s`}
                      </LabeledList.Item>
                    ) : (
                      <LabeledList.Item label="Położenie">
                        {shipCell
                          ? (systems.find((s) => s.hex === ship.hex)?.name ??
                            `Pusty kafel ${shipCell.col},${shipCell.row}`)
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
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section title="Kafel" fill scrollable>
                  {!selected ? (
                    <Box color="label">
                      Kliknij kafel na mapie, żeby zobaczyć trasę i koszt skoku.
                    </Box>
                  ) : (
                    <SelectedPanel
                      selected={selected}
                      ship={ship}
                      canControl={can_control}
                      routeOk={routeOk}
                      onJump={() => act('hex_jump')}
                      onShowGate={(gate) => showSector(gate.sector, gate.hex)}
                    />
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title="Legenda">
                  <Box fontSize="11px" color="label">
                    ◉ sektor okrętu · zielone kafle: zasięg skoku · ⇄ brama do
                    innego sektora · ★ stolica · $ stacja handlowa · ◎
                    hiperbrama · ◇ flota (zielona: sojusz, żółta: neutralna,
                    czerwona: wróg) · przerywany pierścień: układ okupowany ·
                    czerwona linia: front
                  </Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SelectedPanelProps = {
  selected: Selected;
  ship: Ship;
  canControl: boolean;
  routeOk: boolean;
  onJump: () => void;
  onShowGate: (gate: GateInfo) => void;
};

const SelectedPanel = (props: SelectedPanelProps) => {
  const { selected, ship, canControl, routeOk, onJump, onShowGate } = props;
  const route = selected.route;
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
    </>
  );
};
