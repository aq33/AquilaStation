// AQUILA: mapa taktyczna drużyn (pager i konsola XO).
// Podkład to holomapa poziomu; kropki członków i znaczniki rysujemy tutaj.

import { useState } from 'react';
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
  /** Blip CM: tło w kolorze drużyny i glif funkcji (data URI) */
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
  leader: string | null;
  leader_name: string | null;
  members: SquadMember[];
  markers: SquadMarker[];
};

export type MapLevel = { z: number; name: string };

export type MapData = {
  z: number | null;
  levels: MapLevel[];
  url: string | null;
  /** Pole w lewym dolnym rogu wyciętej mapy; jeden piksel to jedno pole */
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
  // Domyślnie mapa mieści się w oknie (ok. 600 px na dłuższym boku)
  const [zoom, setZoom] = useState(
    Math.min(8, Math.max(1, Math.round((600 / longest) * 2) / 2)),
  );
  const scaledWidth = map.width * zoom;
  const scaledHeight = map.height * zoom;
  const toLeft = (x: number) => (x - map.origin_x + 0.5) * zoom;
  const toTop = (y: number) => (map.height - (y - map.origin_y) - 0.5) * zoom;

  const handleClick = (e) => {
    if (!placing || !onPlace || map.z === null) {
      return;
    }
    const rect = e.currentTarget.getBoundingClientRect();
    const px = (e.clientX - rect.left) / zoom;
    const py = (e.clientY - rect.top) / zoom;
    const x = Math.floor(px) + map.origin_x;
    const y = map.origin_y + map.height - 1 - Math.floor(py);
    onPlace(x, y, map.z);
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
          <Stack.Item grow />
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
        {!map.url ? (
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
          >
            <img
              src={map.url}
              width={scaledWidth}
              height={scaledHeight}
              style={{ imageRendering: 'pixelated', display: 'block' }}
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
                  src={member.blip}
                  title={`${member.name} (${squad.name}, ${member.position_name}): ${member.status_name}${member.area ? `, ${member.area}` : ''}`}
                  style={{
                    position: 'absolute',
                    left: `${toLeft(member.x as number) - size / 2}px`,
                    top: `${toTop(member.y as number) - size / 2}px`,
                    width: `${size}px`,
                    height: `${size}px`,
                    imageRendering: 'pixelated',
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
