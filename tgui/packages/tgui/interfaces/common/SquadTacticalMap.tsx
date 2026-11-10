// AQUILA: mapa taktyczna drużyn (pager i konsola XO).
// Podkład to plan poziomu z serwera (JSON: rodzaje pól i obszary), rysowany tu na canvasie
// z siatką sektorów; kropki członków i znaczniki rysujemy na nim.

import { useEffect, useRef, useState } from 'react';
import { Box, Button, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export type SquadMember = {
  ref: string;
  name: string;
  rank: string;
  job: string;
  position: string;
  base_position: string;
  position_name: string;
  leader: BooleanLike;
  status: string;
  status_name: string;
  /** Klucz obrazka w SquadInfo.blips (blip CM: tło w kolorze drużyny i glif funkcji) */
  blip: string;
  health: number;
  pager: BooleanLike;
  cam: BooleanLike;
  kit: string | null;
  missing: string[];
  x: number | null;
  y: number | null;
  z: number | null;
  area: string | null;
};

export type SquadMarker = {
  type: string;
  label: string;
  /** Sprite znacznika (data URI) */
  icon: string;
  x: number;
  y: number;
  z: number;
  area: string | null;
  placer: string;
  time_left: number;
};

export type SquadInfo = {
  id: string;
  name: string;
  colour: string;
  role: string;
  role_name: string;
  desc: string;
  secondary_objective: string | null;
  access_enabled: BooleanLike;
  weapons_clearance: BooleanLike;
  hidden: BooleanLike;
  heavy_armor: BooleanLike;
  leader: string | null;
  leader_name: string | null;
  members: SquadMember[];
  /** Blipy członków: klucz -> data URI, raz na drużynę */
  blips: Record<string, string>;
  markers: SquadMarker[];
};

export type MapLevel = { z: number; name: string };

export type MapData = {
  z: number | null;
  levels: MapLevel[];
  /** Plan poziomu (asset JSON) */
  url: string | null;
  /** Pole w lewym dolnym rogu wyciętej mapy */
  origin_x: number;
  origin_y: number;
  width: number;
  height: number;
  user_x: number | null;
  user_y: number | null;
  user_z: number | null;
};

export type MarkerType = { type: string; label: string };

export const POSITION_ICONS: Record<string, string> = {
  leader: 'star',
  medic: 'briefcase-medical',
  engineer: 'wrench',
  soldier: 'user',
};

export const STATUS_COLORS: Record<string, string> = {
  ok: 'good',
  injured: 'average',
  critical: 'bad',
  dead: 'grey',
  ssd: 'label',
};

export const MARKER_ICONS: Record<string, string> = {
  move: 'arrow-right',
  attack: 'crosshairs',
  defend: 'shield-alt',
  retreat: 'undo',
  rally: 'flag',
  target: 'bullseye',
};

/** Plan poziomu z aq_generate_squad_map(): wiersze od góry, znak na pole */
type MapLayout = {
  width: number;
  height: number;
  tiles: string;
  areas: string[];
  area_width: number;
  area_grid: string;
  /** Kolor działu obszaru z holomapy (#rrggbb) albo null */
  area_colours: (string | null)[];
  /** Środek obszaru: kolumna, wiersz, liczba pól */
  area_centres: number[][];
};

/** Działy według kolorów holomapy (HOLOMAP_AREACOLOR_* w nsv13/code/__DEFINES/holomap.dm) */
const DEPARTMENTS: Record<string, string> = {
  '#3434d4': 'Dowództwo',
  '#ae1212': 'Ochrona',
  '#447bc2': 'Medyczny',
  '#a154a6': 'Naukowy',
  '#f1c231': 'Inżynieria',
  '#853100': 'Zaopatrzenie',
  '#b9b9b9': 'Korytarze',
  '#5e5e5e': 'Tunele techniczne',
  '#6464ff': 'Przyloty',
  '#ff5858': 'Ewakuacja',
  '#bfff83': 'Kwatery',
  '#3ab336': 'Usługi',
  '#ec7701': 'Uzbrojenie',
  '#2681a5': 'Hangar',
};

/** Podpisy tylko dla obszarów z co najmniej tyloma polami */
const LABEL_MIN_TILES = 30;

/** Bok sektora siatki w polach (SQUAD_MAP_SECTOR w squad_tactical_map.dm) */
const SECTOR = 10;

const TILE_COLORS: Record<string, string> = {
  f: '#1e272c',
  c: '#2b363c',
  w: '#7d8e96',
  d: '#a88a3c',
  g: '#4f86a8',
};

const layoutCache: Record<string, MapLayout> = {};

/** Znak z area_grid na liczbę 0-89 (aq_squad_map_code() w DM) */
const decodeAreaCode = (char: string) => {
  const code = char.charCodeAt(0);
  return (code > 92 ? code - 1 : code) - 35;
};

/** Indeks obszaru pola (od 1; 0 = brak obszaru) */
const areaIndexAt = (layout: MapLayout, column: number, row: number) => {
  const index = (row * layout.width + column) * layout.area_width;
  return layout.area_width === 1
    ? decodeAreaCode(layout.area_grid[index])
    : decodeAreaCode(layout.area_grid[index]) * 90 +
        decodeAreaCode(layout.area_grid[index + 1]);
};

/** Sektor siatki ("C2") dla pola planu liczonego od lewej i górnej krawędzi */
const sectorName = (column: number, row: number) =>
  `${String.fromCharCode(65 + Math.floor(column / SECTOR))}${Math.floor(row / SECTOR) + 1}`;

const useMapLayout = (url: string | null) => {
  const [layout, setLayout] = useState<MapLayout | null>(
    url ? layoutCache[url] || null : null,
  );
  useEffect(() => {
    if (!url) {
      setLayout(null);
      return;
    }
    if (layoutCache[url]) {
      setLayout(layoutCache[url]);
      return;
    }
    let cancelled = false;
    setLayout(null);
    fetch(url)
      .then((response) => response.json())
      .then((data: MapLayout) => {
        layoutCache[url] = data;
        if (!cancelled) {
          setLayout(data);
        }
      })
      .catch(() => undefined);
    return () => {
      cancelled = true;
    };
  }, [url]);
  return layout;
};

const drawLayout = (
  canvas: HTMLCanvasElement,
  layout: MapLayout,
  zoom: number,
) => {
  const ctx = canvas.getContext('2d');
  if (!ctx) {
    return;
  }
  ctx.fillStyle = '#0d1215';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  for (let row = 0; row < layout.height; row++) {
    for (let column = 0; column < layout.width; column++) {
      const tile = layout.tiles[row * layout.width + column];
      const color = TILE_COLORS[tile];
      if (!color) {
        continue;
      }
      ctx.fillStyle = color;
      ctx.fillRect(column * zoom, row * zoom, zoom, zoom);
      // podłoga w kolorze działu (ściany zostają szare, żeby kontury były czytelne)
      if (tile !== 'w' && layout.area_colours) {
        const area = areaIndexAt(layout, column, row);
        const areaColor = area > 0 ? layout.area_colours[area - 1] : null;
        if (areaColor) {
          ctx.globalAlpha = 0.3;
          ctx.fillStyle = areaColor;
          ctx.fillRect(column * zoom, row * zoom, zoom, zoom);
          ctx.globalAlpha = 1;
        }
      }
    }
  }
  const cell = SECTOR * zoom;
  ctx.strokeStyle = 'rgba(95, 191, 134, 0.45)';
  ctx.lineWidth = 1;
  ctx.setLineDash([3, 3]);
  ctx.beginPath();
  for (let x = cell; x < canvas.width; x += cell) {
    ctx.moveTo(x + 0.5, 0);
    ctx.lineTo(x + 0.5, canvas.height);
  }
  for (let y = cell; y < canvas.height; y += cell) {
    ctx.moveTo(0, y + 0.5);
    ctx.lineTo(canvas.width, y + 0.5);
  }
  ctx.stroke();
  ctx.setLineDash([]);
  if (layout.area_centres) {
    ctx.font = `${zoom >= 4 ? 11 : 9}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.lineWidth = 3;
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.85)';
    ctx.fillStyle = '#e8eef2';
    // od największych obszarów; podpis, który zachodziłby na już narysowany, pomijamy
    const drawn: number[][] = [];
    const order = layout.area_centres
      .map((centre, index) => index)
      .sort((a, b) => layout.area_centres[b][2] - layout.area_centres[a][2]);
    for (const index of order) {
      const [column, row, count] = layout.area_centres[index];
      // tunele techniczne i korytarze bez podpisów: są wszędzie i zasłaniałyby pomieszczenia
      const color = layout.area_colours[index];
      if (
        count < LABEL_MIN_TILES ||
        !color ||
        color === '#5e5e5e' ||
        color === '#b9b9b9'
      ) {
        continue;
      }
      const name = layout.areas[index];
      const x = (column + 0.5) * zoom;
      const y = (row + 0.5) * zoom;
      const halfWidth = ctx.measureText(name).width / 2 + 2;
      const box = [x - halfWidth, y - 7, x + halfWidth, y + 7];
      if (
        drawn.some(
          (other) =>
            box[0] < other[2] &&
            box[2] > other[0] &&
            box[1] < other[3] &&
            box[3] > other[1],
        )
      ) {
        continue;
      }
      drawn.push(box);
      ctx.strokeText(name, x, y);
      ctx.fillText(name, x, y);
    }
    ctx.textAlign = 'start';
  }
  if (cell >= 30) {
    ctx.fillStyle = 'rgba(95, 191, 134, 0.8)';
    ctx.font = '10px monospace';
    ctx.textBaseline = 'top';
    for (let y = 0; y < canvas.height; y += cell) {
      for (let x = 0; x < canvas.width; x += cell) {
        ctx.fillText(sectorName(x / zoom, y / zoom), x + 2, y + 2);
      }
    }
  }
};

const STATUS_RING: Record<string, string> = {
  ok: '#1a1a1a',
  injured: '#ffa500',
  critical: '#ff2020',
  dead: '#000000',
  ssd: '#777777',
};

type MapProps = {
  map: MapData;
  squads: SquadInfo[];
  userRef?: string;
  /** Typ znacznika stawianego kliknięciem; null = kliknięcie nic nie robi */
  placing?: string | null;
  onSelectZ: (z: number) => void;
  onPlace?: (x: number, y: number, z: number) => void;
  onClearMarker?: (squad: SquadInfo, marker: SquadMarker) => void;
};

export const SquadTacticalMap = (props: MapProps) => {
  const { map, squads, userRef, placing, onSelectZ, onPlace, onClearMarker } =
    props;
  const longest = Math.max(map.width || 1, map.height || 1);
  // całkowity zoom: pole to pełne piksele, bez szwów między polami na canvasie
  const [zoom, setZoom] = useState(
    Math.min(8, Math.max(2, Math.floor(600 / longest))),
  );
  // po pierwszym rysowaniu dopasowujemy zoom do szerokości panelu (konsola XO ma go dużo więcej niż pager)
  const containerRef = useRef<HTMLDivElement>(null);
  const [fitted, setFitted] = useState(false);
  useEffect(() => {
    const width = containerRef.current?.clientWidth;
    if (fitted || !width || !map.width) {
      return;
    }
    setFitted(true);
    setZoom(Math.min(8, Math.max(2, Math.floor((width - 16) / map.width))));
  }, [map.width, fitted]);
  const layout = useMapLayout(map.url);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [hover, setHover] = useState<string | null>(null);
  const scaledWidth = map.width * zoom;
  const scaledHeight = map.height * zoom;
  useEffect(() => {
    if (canvasRef.current && layout) {
      drawLayout(canvasRef.current, layout, zoom);
    }
  }, [layout, zoom]);
  const toLeft = (x: number) => (x - map.origin_x + 0.5) * zoom;
  const toTop = (y: number) => (map.height - (y - map.origin_y) - 0.5) * zoom;

  /** Pole planu pod kursorem: kolumna i wiersz od lewego górnego rogu */
  const cellAt = (e) => {
    const rect = e.currentTarget.getBoundingClientRect();
    return {
      column: Math.floor((e.clientX - rect.left) / zoom),
      row: Math.floor((e.clientY - rect.top) / zoom),
    };
  };

  const handleHover = (e) => {
    if (!layout) {
      return;
    }
    const { column, row } = cellAt(e);
    if (
      column < 0 ||
      row < 0 ||
      column >= layout.width ||
      row >= layout.height
    ) {
      setHover(null);
      return;
    }
    const area = areaIndexAt(layout, column, row);
    const areaName = area > 0 ? layout.areas[area - 1] : null;
    setHover(`${sectorName(column, row)}${areaName ? ` · ${areaName}` : ''}`);
  };

  const handleClick = (e) => {
    if (!placing || !onPlace || map.z === null) {
      return;
    }
    const { column, row } = cellAt(e);
    onPlace(column + map.origin_x, map.origin_y + map.height - 1 - row, map.z);
  };

  const membersHere = squads.flatMap((squad) =>
    squad.members
      .filter((m) => m.z === map.z && m.x !== null && m.y !== null)
      .map((m) => ({ squad, member: m })),
  );
  const markersHere = squads.flatMap((squad) =>
    squad.markers
      .filter((marker) => marker.z === map.z)
      .map((marker) => ({ squad, marker })),
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack wrap="wrap" align="center">
          {map.levels.map((level) => (
            <Stack.Item key={level.z}>
              <Button
                selected={level.z === map.z}
                onClick={() => onSelectZ(level.z)}
              >
                {level.name}
              </Button>
            </Stack.Item>
          ))}
          <Stack.Item grow>
            <Box color="label" textAlign="right" fontSize="11px">
              {hover || 'Najedź na mapę: sektor i obszar'}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="search-minus"
              tooltip="Oddal"
              disabled={zoom <= 1}
              onClick={() => setZoom(Math.max(1, zoom - 1))}
            />
            <Button
              icon="search-plus"
              tooltip="Przybliż"
              disabled={zoom >= 10}
              onClick={() => setZoom(Math.min(10, zoom + 1))}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
        <div ref={containerRef} style={{ width: '100%', height: 0 }} />
        {!map.url || !layout ? (
          <Box color="label" p={2}>
            Wczytywanie mapy poziomu...
          </Box>
        ) : (
          <div
            style={{
              position: 'relative',
              width: `${scaledWidth}px`,
              height: `${scaledHeight}px`,
              cursor: placing ? 'crosshair' : 'default',
            }}
            onClick={handleClick}
            onMouseMove={handleHover}
            onMouseLeave={() => setHover(null)}
          >
            <canvas
              ref={canvasRef}
              width={scaledWidth}
              height={scaledHeight}
              style={{ display: 'block' }}
            />
            {markersHere.map(({ squad, marker }) => (
              <img
                key={`${squad.id}-${marker.type}`}
                src={marker.icon}
                title={`${squad.name}: ${marker.label} (${marker.placer}, ${marker.time_left} s)`}
                onClick={(e) => {
                  if (onClearMarker && e.ctrlKey) {
                    e.stopPropagation();
                    onClearMarker(squad, marker);
                  }
                }}
                style={{
                  position: 'absolute',
                  left: `${toLeft(marker.x) - 16}px`,
                  top: `${toTop(marker.y) - 28}px`,
                  width: '32px',
                  height: '32px',
                  imageRendering: 'pixelated',
                  filter: `drop-shadow(0 2px 0 ${squad.colour})`,
                }}
              />
            ))}
            {membersHere.map(({ squad, member }) => {
              const size = member.leader ? 24 : 21;
              const isUser = member.ref === userRef;
              return (
                <img
                  key={member.ref}
                  src={squad.blips?.[member.blip]}
                  title={`${member.name} (${squad.name}, ${member.position_name}): ${member.status_name}${member.area ? `, ${member.area}` : ''}`}
                  style={{
                    position: 'absolute',
                    left: `${toLeft(member.x as number) - size / 2}px`,
                    top: `${toTop(member.y as number) - size / 2}px`,
                    width: `${size}px`,
                    height: `${size}px`,
                    imageRendering: 'pixelated',
                    filter:
                      'drop-shadow(1px 0 0 #000) drop-shadow(-1px 0 0 #000) drop-shadow(0 1px 0 #000) drop-shadow(0 -1px 0 #000)',
                    opacity: member.status === 'ssd' ? 0.6 : 1,
                    outline: isUser
                      ? '2px solid #ffffff'
                      : member.status === 'injured' ||
                          member.status === 'critical'
                        ? `2px solid ${STATUS_RING[member.status]}`
                        : 'none',
                    pointerEvents: placing ? 'none' : 'auto',
                  }}
                />
              );
            })}
            {map.user_z === map.z && map.user_x !== null && (
              <div
                title="Tu jesteś"
                style={{
                  position: 'absolute',
                  left: `${toLeft(map.user_x as number) - 7}px`,
                  top: `${toTop(map.user_y as number) - 7}px`,
                  width: '10px',
                  height: '10px',
                  border: '2px dashed #ffffff',
                  borderRadius: '50%',
                  pointerEvents: 'none',
                }}
              />
            )}
          </div>
        )}
      </Stack.Item>
      {!!layout?.area_colours && (
        <Stack.Item>
          <Stack wrap="wrap" align="center">
            {Object.keys(DEPARTMENTS)
              .filter((color) => layout.area_colours.includes(color))
              .map((color) => (
                <Stack.Item key={color} mr={1}>
                  <span
                    style={{
                      display: 'inline-block',
                      width: '10px',
                      height: '10px',
                      marginRight: '4px',
                      background: color,
                      verticalAlign: 'middle',
                    }}
                  />
                  <Box inline fontSize="11px" color="label">
                    {DEPARTMENTS[color]}
                  </Box>
                </Stack.Item>
              ))}
          </Stack>
        </Stack.Item>
      )}
    </Stack>
  );
};

/** Wybór typu znacznika do stawiania kliknięciem na mapie */
export const MarkerPicker = (props: {
  markerTypes: MarkerType[];
  placing: string | null;
  setPlacing: (type: string | null) => void;
}) => {
  const { markerTypes, placing, setPlacing } = props;
  return (
    <Stack wrap="wrap" align="center">
      {markerTypes.map((marker) => (
        <Stack.Item key={marker.type}>
          <Button
            selected={placing === marker.type}
            icon={MARKER_ICONS[marker.type]}
            onClick={() =>
              setPlacing(placing === marker.type ? null : marker.type)
            }
          >
            {marker.label}
          </Button>
        </Stack.Item>
      ))}
      <Stack.Item>
        <Box color="label" fontSize="11px">
          {placing
            ? 'Kliknij mapę, żeby postawić znacznik. Ctrl+klik na znaczniku go usuwa.'
            : 'Wybierz znacznik, a potem kliknij mapę.'}
        </Box>
      </Stack.Item>
    </Stack>
  );
};
