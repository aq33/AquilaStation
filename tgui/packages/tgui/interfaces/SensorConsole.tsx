// AQUILA - konsola sensorów, stanowisko operatora radaru (aquila/code/modules/overmap/sensor_console.dm,
// sensory okrętu gracza: aquila/code/modules/overmap/player_sensors.dm)
import {
  type CSSProperties,
  type MouseEvent,
  type ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export type Designation = 'primary' | 'secondary' | null;

type SuiteReport = {
  suite: string;
  reach: number;
  state: 'sees' | 'far' | 'cone' | 'blind' | 'off';
};

export type Contact = {
  id: string;
  name: string;
  number: number;
  dx: number;
  dy: number;
  uncertainty: number;
  hostile: boolean;
  identified: boolean;
  locking_us: boolean;
  painted: boolean;
  locked: boolean;
  designation: Designation;
  vx: number;
  vy: number;
  sensor?: string | null;
  suites?: SuiteReport[];
};

type Marker = {
  dx: number;
  dy: number;
  emission: {
    bearing: number;
    distance: number;
    width: number;
    spread: number;
  } | null;
  ghost: boolean;
  opacity: number;
};

type Data = {
  radar_mode: boolean;
  radar_delay: number;
  radar_delay_min: number;
  radar_delay_max: number;
  pulse_cooldown: number;
  pulse_active: boolean;
  can_radar_pulse: boolean;
  can_use_radar: boolean;
  sensor_signatures: boolean;
  seen_from: number;
  seen_from_pulse: number;
  contacts: Contact[];
  markers: Marker[];
  gunner: boolean;
  near_range: number;
  suites: boolean;
  cones: boolean;
  heading: number;
  heat: number;
  dampeners: boolean;
  telescope_mode: 'cel' | 'kurs' | 'recznie';
  telescope_bearing: number | null;
  telescope_half: number;
  telescope_target: string | null;
  ir_blind: boolean;
  ir_blind_half: number;
  camera_reach: number;
  turn: number;
  pulse_at: number;
  pulse_age: number;
  pulse_width: number;
  pulse_bearing: number;
  pulse_reach: number;
  radar_beam: number;
  radar_beam_mode: 'cel' | 'kurs' | 'recznie';
  radar_beam_bearing: number;
  radar_reach: number;
  objects: ScopeObject[];
};

export type ScopeObject = {
  id: string;
  kind: 'asteroid' | 'wreck' | 'anomaly';
  name: string;
  detail: string | null;
  dx: number;
  dy: number;
};

export const OBJECT_KIND = {
  asteroid: 'asteroida',
  wreck: 'wrak',
  anomaly: 'anomalia',
};

// Fala impulsu dochodzi do granicy zasięgu w tyle sekund
const PULSE_WAVE_SECONDS = 1.8;
export const LABEL_CHAR_PX = 6.6;

export const OBJECT_COLOR = {
  asteroid: '#8a8f98',
  wreck: '#a9b0ba',
  anomaly: '#eb9534',
};

export const COLOR = {
  bg: '#0a0f16',
  panel: '#111924',
  panel2: '#16202e',
  line: '#22303f',
  ink: '#e6ebf2',
  ink2: '#b4bfcd',
  muted: '#7d8a9c',
  hostile: '#ff5d5d',
  friend: '#4fd17a',
  unknown: '#f0b44c',
  desig: '#ffd23f',
  desig2: '#e6cf7a',
  tel: '#4cc9f0',
  ir: '#ff8c42',
  radar: '#5ee08a',
  esm: '#b18cff',
  opt: '#dfe6ef',
  memory: '#7d8a9c',
  good: '#4fd17a',
  warn: '#f0b44c',
  bad: '#ff5d5d',
};

const SUITES: Record<string, [string, string]> = {
  optyczny: ['Kamera', COLOR.opt],
  teleskop: ['Teleskop', COLOR.tel],
  termiczny: ['Podczerwień', COLOR.ir],
  lidar: ['Radar', COLOR.radar],
  nasłuch: ['Nasłuch', COLOR.esm],
  pamięć: ['Pamięć', COLOR.memory],
};

const SUITE_STATES: Record<SuiteReport['state'], string> = {
  sees: 'widzi',
  far: 'za daleko',
  cone: 'poza stożkiem',
  blind: 'ślepa (napęd)',
  off: 'wyłączony',
};

const SCOPE_RANGES = [50, 100, 200];
const SCOPE = 440;
const CENTER = SCOPE / 2;
const RADIUS = 208;
export const MONO = 'Consolas, monospace';

export type Side = 'hostile' | 'friend' | 'unknown';

export const distanceOf = (c: { dx: number; dy: number }) =>
  Math.round(Math.sqrt(c.dx * c.dx + c.dy * c.dy));
export const bearingOf = (c: { dx: number; dy: number }) =>
  (Math.round((Math.atan2(c.dx, c.dy) * 180) / Math.PI) + 360) % 360;
export const pad = (n: number) => ('00' + Math.round(n)).slice(-3);
export const sideOf = (c: Contact): Side =>
  !c.hostile ? 'friend' : c.identified ? 'hostile' : 'unknown';
export const shortOf = (c: Contact) => 'K' + c.number;
const angleDiff = (a: number, b: number) =>
  Math.abs(((a - b + 540) % 360) - 180);

export const sectionTitle: CSSProperties = {
  fontSize: '11px',
  letterSpacing: '0.09em',
  textTransform: 'uppercase',
  color: COLOR.muted,
  fontWeight: 600,
  marginBottom: '7px',
  display: 'flex',
  alignItems: 'center',
};
export const card: CSSProperties = {
  borderBottom: '1px solid ' + COLOR.line,
  padding: '9px 11px',
};
export const swatch = (colour: string): CSSProperties => ({
  display: 'inline-block',
  width: '10px',
  height: '10px',
  borderRadius: '2px',
  background: colour,
  marginRight: '5px',
  verticalAlign: '-1px',
});

export const Symbol = (props: { side: Side; size?: number }) => {
  const { side, size = 11 } = props;
  const colour = COLOR[side];
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 12 12"
      style={{ verticalAlign: '-1px', marginRight: '6px' }}
    >
      {side === 'hostile' && (
        <path
          d="M6 1 11 6 6 11 1 6Z"
          fill="none"
          stroke={colour}
          strokeWidth={1.6}
        />
      )}
      {side === 'friend' && (
        <circle
          cx={6}
          cy={6}
          r={4.5}
          fill="none"
          stroke={colour}
          strokeWidth={1.6}
        />
      )}
      {side === 'unknown' && (
        <rect
          x={1.5}
          y={1.5}
          width={9}
          height={9}
          fill="none"
          stroke={colour}
          strokeWidth={1.6}
        />
      )}
    </svg>
  );
};

export const Tag = (props: {
  colour: string;
  background: string;
  children: ReactNode;
}) => (
  <span
    style={{
      display: 'inline-block',
      padding: '0 6px',
      borderRadius: '3px',
      fontSize: '11px',
      fontWeight: 600,
      color: props.colour,
      background: props.background,
      marginRight: '4px',
    }}
  >
    {props.children}
  </span>
);

const ContactTags = (props: { contact: Contact }) => {
  const { contact } = props;
  return (
    <>
      {!!contact.locking_us && (
        <Tag colour="#ff9a9a" background="#3a1515">
          namierza nas
        </Tag>
      )}
      {contact.designation === 'primary' && (
        <Tag colour={COLOR.desig} background="#4a3d08">
          cel główny
        </Tag>
      )}
      {contact.designation === 'secondary' && (
        <Tag colour={COLOR.desig2} background="#2f2a10">
          drugorzędny
        </Tag>
      )}
    </>
  );
};

// Wycinek od środka ekranu w kierunku bearing (stopnie od północy, zgodnie z zegarem)
const wedgePath = (bearing: number, half: number, length: number) => {
  const r = Math.min(length, RADIUS);
  const a0 = ((bearing - half - 90) * Math.PI) / 180;
  const a1 = ((bearing + half - 90) * Math.PI) / 180;
  const x0 = CENTER + Math.cos(a0) * r;
  const y0 = CENTER + Math.sin(a0) * r;
  const x1 = CENTER + Math.cos(a1) * r;
  const y1 = CENTER + Math.sin(a1) * r;
  const large = half * 2 > 180 ? 1 : 0;
  return `M${CENTER},${CENTER} L${x0},${y0} A${r},${r} 0 ${large} 1 ${x1},${y1} Z`;
};

const TopBar = () => {
  const { data } = useBackend<Data>();
  const exposed = data.radar_mode || data.pulse_active;
  const heatPct = Math.round((data.heat || 0) * 100);
  return (
    <Box
      style={{
        display: 'flex',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: '10px',
        padding: '8px 10px',
        borderBottom: '1px solid ' + COLOR.line,
        background: COLOR.panel,
      }}
    >
      <span
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '7px',
          padding: '5px 11px',
          borderRadius: '999px',
          fontWeight: 600,
          border: '1px solid ' + (exposed ? '#7a2d2d' : '#2b6b45'),
          background: exposed ? '#2a1212' : '#0f2219',
          color: exposed ? COLOR.bad : COLOR.good,
        }}
      >
        <span
          style={{
            width: '8px',
            height: '8px',
            borderRadius: '50%',
            background: 'currentColor',
          }}
        />
        {data.radar_mode
          ? 'RADAR AKTYWNY'
          : data.pulse_active
            ? 'IMPULS'
            : 'CICHO'}
      </span>
      {!!data.sensor_signatures && (
        <>
          <span style={{ color: COLOR.ink2 }}>
            Wróg wykrywa nas z{' '}
            <b style={{ color: COLOR.ink, fontFamily: MONO, fontSize: '14px' }}>
              {'~' + (exposed ? data.seen_from_pulse : data.seen_from)}
            </b>{' '}
            pól
          </span>
          <span style={{ color: COLOR.muted, fontSize: '11.5px' }}>
            {exposed ? (
              '(radar słychać daleko, jako namiar)'
            ) : (
              <>
                (napęd {heatPct}%, IAS{' '}
                {data.dampeners ? 'włączony' : 'wyłączony'})
              </>
            )}
          </span>
        </>
      )}
      <span
        style={{
          marginLeft: 'auto',
          display: 'flex',
          alignItems: 'center',
          gap: '6px',
          color: COLOR.ink2,
        }}
      >
        Ciepło napędu
        <span
          style={{
            width: '120px',
            height: '8px',
            borderRadius: '4px',
            background: '#1c2735',
            overflow: 'hidden',
            display: 'inline-block',
          }}
        >
          <span
            style={{
              display: 'block',
              height: '100%',
              width: heatPct + '%',
              background: 'linear-gradient(90deg, #4fd17a, #f0b44c, #ff5d5d)',
            }}
          />
        </span>
      </span>
    </Box>
  );
};

type ScopeProps = {
  range: number;
  contacts: Contact[];
  heading: number;
  pulseAge: number;
  aimTarget: AimTarget;
  selected: string | null;
  onSelect: (id: string) => void;
};

// Przeciąganie po ekranie ustawia teleskop albo wiązkę radaru: to, w czym ostatnio wybrano tryb ręczny
type AimTarget = 'telescope' | 'radar';

// Teleskop ręczny: przy przeciąganiu wysyłamy namiar najwyżej co tyle ms
const DRAG_SEND_MS = 120;

// Fala impulsu jako animacja CSS: płynna niezależnie od odświeżania okna. Opóźnienie liczone raz,
// w chwili pojawienia się fali, z wieku impulsu, więc fala zgadza się z prawdziwym impulsem.
const PULSE_STYLE = `@keyframes aqRadarPulse {
  from { transform: scale(0.02); opacity: 1; }
  to { transform: scale(1); opacity: 0.25; }
}`;

const PulseWave = (props: {
  age: number;
  reach: number;
  width: number;
  bearing: number;
}) => {
  const [startAge] = useState(props.age);
  const style: CSSProperties = {
    transformOrigin: CENTER + 'px ' + CENTER + 'px',
    transformBox: 'view-box',
    animation: 'aqRadarPulse ' + PULSE_WAVE_SECONDS + 's linear forwards',
    animationDelay: -Math.min(startAge, PULSE_WAVE_SECONDS) + 's',
  };
  if (props.width) {
    return (
      <path
        d={wedgePath(props.bearing, props.width / 2, props.reach)}
        fill="rgba(94,224,138,0.08)"
        stroke="rgba(94,224,138,0.9)"
        strokeWidth={3}
        vectorEffect="non-scaling-stroke"
        style={style}
      />
    );
  }
  return (
    <circle
      cx={CENTER}
      cy={CENTER}
      r={props.reach}
      fill="rgba(94,224,138,0.05)"
      stroke="rgba(94,224,138,0.9)"
      strokeWidth={3}
      vectorEffect="non-scaling-stroke"
      style={style}
    />
  );
};

const Scope = (props: ScopeProps) => {
  const { act, data } = useBackend<Data>();
  const { range, contacts, heading, pulseAge, aimTarget, selected, onSelect } =
    props;
  const markers = data.markers || [];
  const objects = data.objects || [];
  const [dragBearing, setDragBearing] = useState<number | null>(null);
  const dragging = useRef(false);
  const lastSent = useRef(0);
  const scale = RADIUS / range;
  const toPoint = (dx: number, dy: number): [number, number, boolean] => {
    const dist = Math.sqrt(dx * dx + dy * dy);
    // Kontakt poza zasięgiem ekranu siedzi na jego krawędzi, w swoim kierunku
    const clamp = dist > range ? range / dist : 1;
    return [
      CENTER + dx * clamp * scale,
      CENTER - dy * clamp * scale,
      clamp < 1,
    ];
  };
  const manual =
    !!data.cones &&
    (aimTarget === 'radar'
      ? !!data.radar_beam && data.radar_beam_mode === 'recznie'
      : data.telescope_mode === 'recznie');
  const serverBearing =
    aimTarget === 'radar' ? data.radar_beam_bearing : data.telescope_bearing;
  const bearingAt = (event: MouseEvent<SVGSVGElement>) => {
    const box = event.currentTarget.getBoundingClientRect();
    const x = event.clientX - box.left - CENTER;
    const y = CENTER - (event.clientY - box.top);
    return (Math.round((Math.atan2(x, y) * 180) / Math.PI) + 360) % 360;
  };
  const aim = (bearing: number, force: boolean) => {
    setDragBearing(bearing);
    const now = Date.now();
    if (force || now - lastSent.current >= DRAG_SEND_MS) {
      lastSent.current = now;
      act(aimTarget === 'radar' ? 'set_radar_aim' : 'set_telescope', {
        bearing: bearing,
      });
    }
  };
  const startAim = (event: MouseEvent<SVGSVGElement>) => {
    if (!manual || event.button !== 0) {
      return;
    }
    dragging.current = true;
    aim(bearingAt(event), true);
  };
  const moveAim = (event: MouseEvent<SVGSVGElement>) => {
    if (dragging.current) {
      aim(bearingAt(event), false);
    }
  };
  const endAim = (event: MouseEvent<SVGSVGElement>) => {
    if (dragging.current) {
      dragging.current = false;
      aim(bearingAt(event), true);
    }
  };
  // Po puszczeniu przycisku trzymamy własny namiar, aż serwer go potwierdzi
  useEffect(() => {
    if (
      !dragging.current &&
      dragBearing !== null &&
      (!manual || serverBearing === dragBearing)
    ) {
      setDragBearing(null);
    }
  }, [serverBearing, manual]);
  const dragging_telescope =
    manual && aimTarget === 'telescope' && dragBearing !== null;
  const dragging_radar =
    manual && aimTarget === 'radar' && dragBearing !== null;
  const telescopeBearing = dragging_telescope
    ? dragBearing
    : data.telescope_bearing;
  const radarBearing = dragging_radar ? dragBearing : data.radar_beam_bearing;
  const ticks: ReactNode[] = [];
  for (let b = 0; b < 360; b += 10) {
    const a = ((b - 90) * Math.PI) / 180;
    const inner = b % 30 ? RADIUS - 5 : RADIUS - 10;
    ticks.push(
      <line
        key={'t' + b}
        x1={CENTER + Math.cos(a) * inner}
        y1={CENTER + Math.sin(a) * inner}
        x2={CENTER + Math.cos(a) * RADIUS}
        y2={CENTER + Math.sin(a) * RADIUS}
        stroke="#2f5a48"
      />,
    );
    if (b % 30 === 0) {
      ticks.push(
        <text
          key={'l' + b}
          x={CENTER + Math.cos(a) * (RADIUS - 20)}
          y={CENTER + Math.sin(a) * (RADIUS - 20) + 4}
          fontSize="11"
          fontFamily={MONO}
          textAnchor="middle"
          fill="#7fb59c"
        >
          {pad(b)}
        </text>,
      );
    }
  }
  const ha = ((heading - 90) * Math.PI) / 180;
  const labelled = new Set<string>();
  const placed: [number, number, number, number][] = [];
  const contactRank = { hostile: 0, unknown: 1, friend: 2 };
  const candidates = [
    ...[...contacts]
      .sort(
        (a, b) =>
          (b.designation ? 1 : 0) - (a.designation ? 1 : 0) ||
          contactRank[sideOf(a)] - contactRank[sideOf(b)],
      )
      .map((c) => ({
        id: c.id,
        dx: c.dx,
        dy: c.dy,
        text: shortOf(c) + (c.designation === 'primary' ? ' · CEL' : ''),
        offset: 10,
      })),
    ...objects.map((o) => ({
      id: o.id,
      dx: o.dx,
      dy: o.dy,
      text: o.name,
      offset: 8,
    })),
  ];
  for (const item of candidates) {
    const [px, py] = toPoint(item.dx, item.dy);
    const box: [number, number, number, number] = [
      px + item.offset,
      py - 20,
      px + item.offset + item.text.length * LABEL_CHAR_PX,
      py - 6,
    ];
    const hit = placed.some(
      (b) => box[0] < b[2] && box[2] > b[0] && box[1] < b[3] && box[3] > b[1],
    );
    if (!hit) {
      placed.push(box);
      labelled.add(item.id);
    }
  }
  return (
    <svg
      width={SCOPE}
      height={SCOPE}
      viewBox={'0 0 ' + SCOPE + ' ' + SCOPE}
      style={{
        display: 'block',
        cursor: manual ? 'crosshair' : 'default',
        userSelect: 'none',
      }}
      onMouseDown={startAim}
      onMouseMove={moveAim}
      onMouseUp={endAim}
      onMouseLeave={endAim}
    >
      <defs>
        <radialGradient id="scopeBg">
          <stop offset="0%" stopColor="#0f1d1a" />
          <stop offset="100%" stopColor="#08110f" />
        </radialGradient>
      </defs>
      <circle cx={CENTER} cy={CENTER} r={RADIUS} fill="url(#scopeBg)" />
      {[1, 2, 3, 4].map((i) => (
        <g key={'r' + i}>
          <circle
            cx={CENTER}
            cy={CENTER}
            r={(RADIUS * i) / 4}
            fill="none"
            stroke={i === 4 ? '#2f5a48' : '#1d3a30'}
          />
          <text
            x={CENTER + 4}
            y={CENTER - (RADIUS * i) / 4 + 12}
            fontSize="11"
            fontFamily={MONO}
            fill="#5f8f7a"
          >
            {(range * i) / 4}
          </text>
        </g>
      ))}
      {ticks}
      {!!data.ir_blind && (
        <path
          d={wedgePath((heading + 180) % 360, data.ir_blind_half, RADIUS)}
          fill="rgba(255,140,66,0.10)"
          stroke={COLOR.ir}
          strokeDasharray="4 3"
        />
      )}
      {!!data.cones && telescopeBearing !== null && (
        <path
          d={wedgePath(telescopeBearing, data.telescope_half, RADIUS)}
          fill="rgba(76,201,240,0.10)"
          stroke="rgba(76,201,240,0.7)"
        />
      )}
      {markers
        .filter((marker) => !!marker.emission)
        .map((marker) => (
          <path
            key={'e' + marker.emission!.bearing + '_' + marker.dx}
            d={wedgePath(
              marker.emission!.bearing,
              Math.max(3, marker.emission!.width / 2),
              RADIUS,
            )}
            fill="rgba(177,140,255,0.16)"
            fillOpacity={marker.opacity}
            stroke="rgba(177,140,255,0.6)"
            strokeOpacity={marker.opacity}
          />
        ))}
      {markers
        .filter((marker) => marker.ghost)
        .map((marker) => {
          const [x, y] = toPoint(marker.dx, marker.dy);
          return (
            <text
              key={'g' + marker.dx + '_' + marker.dy}
              x={x}
              y={y + 6}
              fontSize="18"
              fontWeight="bold"
              textAnchor="middle"
              fill={COLOR.ir}
              opacity={marker.opacity}
            >
              !
            </text>
          );
        })}
      <style>{PULSE_STYLE}</style>
      {!!data.cones && !!data.radar_beam && (
        <path
          d={wedgePath(
            radarBearing,
            data.radar_beam / 2,
            Math.min(data.radar_reach * scale, RADIUS),
          )}
          fill="none"
          stroke="rgba(94,224,138,0.45)"
          strokeDasharray="6 4"
        />
      )}
      {!!data.pulse_active && (
        <PulseWave
          key={'pulse' + data.pulse_at}
          age={pulseAge}
          reach={Math.min(data.pulse_reach * scale, RADIUS)}
          width={data.pulse_width}
          bearing={data.pulse_bearing}
        />
      )}
      {objects.map((thing) => {
        const [x, y, outside] = toPoint(thing.dx, thing.dy);
        if (outside) {
          return null;
        }
        const colour = OBJECT_COLOR[thing.kind];
        return (
          <g
            key={thing.id}
            style={{ cursor: 'pointer' }}
            onMouseDown={(event) => event.stopPropagation()}
            onClick={(event) => {
              event.stopPropagation();
              onSelect(thing.id);
            }}
          >
            <title>{thing.name}</title>
            {selected === thing.id && (
              <circle
                cx={x}
                cy={y}
                r={12}
                fill="none"
                stroke="#ffffff"
                strokeWidth={1}
              />
            )}
            {labelled.has(thing.id) && (
              <text
                x={x + 8}
                y={y - 6}
                fontSize="11"
                stroke="#08110f"
                strokeWidth={3}
                paintOrder="stroke"
                fill={colour}
              >
                {thing.name}
              </text>
            )}
            <circle cx={x} cy={y} r={10} fill="transparent" />
            {thing.kind === 'asteroid' && (
              <path
                d={`M${x - 4},${y - 1} L${x - 1},${y - 4} L${x + 3},${y - 3} L${x + 4},${y + 2} L${x},${y + 4} L${x - 3},${y + 3} Z`}
                fill={colour}
                fillOpacity={0.5}
                stroke={colour}
              />
            )}
            {thing.kind === 'wreck' && (
              <path
                d={`M${x - 4},${y - 4} L${x + 4},${y + 4} M${x + 4},${y - 4} L${x - 4},${y + 4}`}
                stroke={colour}
                strokeWidth={2}
              />
            )}
            {thing.kind === 'anomaly' && (
              <path
                d={`M${x},${y - 6} L${x + 2},${y - 2} L${x + 6},${y} L${x + 2},${y + 2} L${x},${y + 6} L${x - 2},${y + 2} L${x - 6},${y} L${x - 2},${y - 2} Z`}
                fill={colour}
                fillOpacity={0.7}
              />
            )}
          </g>
        );
      })}
      {contacts.map((contact) => {
        const [x, y, outside] = toPoint(contact.dx, contact.dy);
        const side = sideOf(contact);
        const colour = COLOR[side];
        const uncertainty = Math.max(0, contact.uncertainty * scale);
        const s = 6;
        const label = shortOf(contact);
        return (
          <g
            key={contact.id}
            style={{ cursor: 'pointer' }}
            opacity={outside ? 0.55 : 1}
            onMouseDown={(event) => event.stopPropagation()}
            onClick={(event) => {
              event.stopPropagation();
              onSelect(contact.id);
            }}
          >
            {uncertainty > 3 && !outside && (
              <circle
                cx={x}
                cy={y}
                r={uncertainty}
                fill="rgba(240,180,76,0.08)"
                stroke="rgba(240,180,76,0.5)"
                strokeDasharray="3 3"
              />
            )}
            {side === 'hostile' && (
              <path
                d={`M${x},${y - s} L${x + s},${y} L${x},${y + s} L${x - s},${y} Z`}
                fill="none"
                stroke={colour}
                strokeWidth={2}
              />
            )}
            {side === 'friend' && (
              <circle
                cx={x}
                cy={y}
                r={s * 0.85}
                fill="none"
                stroke={colour}
                strokeWidth={2}
              />
            )}
            {side === 'unknown' && (
              <rect
                x={x - s * 0.8}
                y={y - s * 0.8}
                width={s * 1.6}
                height={s * 1.6}
                fill="none"
                stroke={colour}
                strokeWidth={2}
              />
            )}
            {!!contact.designation &&
              [
                [-1, -1],
                [1, -1],
                [1, 1],
                [-1, 1],
              ].map(([kx, ky]) => (
                <path
                  key={kx + '_' + ky}
                  d={`M${x + kx * 12},${y + ky * 7} L${x + kx * 12},${y + ky * 12} L${x + kx * 7},${y + ky * 12}`}
                  fill="none"
                  stroke={
                    contact.designation === 'primary'
                      ? COLOR.desig
                      : COLOR.desig2
                  }
                  strokeWidth={1.5}
                />
              ))}
            {selected === contact.id && (
              <circle
                cx={x}
                cy={y}
                r={16}
                fill="none"
                stroke="#ffffff"
                strokeWidth={1}
              />
            )}
            <text
              x={x + 10}
              y={y - 8}
              display={labelled.has(contact.id) ? undefined : 'none'}
              fontSize="12"
              fontWeight="bold"
              stroke="#08110f"
              strokeWidth={3}
              paintOrder="stroke"
              fill={contact.designation ? COLOR.desig : '#dbe6e0'}
            >
              {label}
              {contact.designation === 'primary' && ' · CEL'}
            </text>
            <circle cx={x} cy={y} r={14} fill="transparent" />
          </g>
        );
      })}
      <line
        x1={CENTER}
        y1={CENTER}
        x2={CENTER + Math.cos(ha) * RADIUS}
        y2={CENTER + Math.sin(ha) * RADIUS}
        stroke="rgba(255,255,255,0.18)"
        strokeDasharray="2 4"
      />
      <path
        d="M0,-9 L6,7 L0,4 L-6,7 Z"
        fill={COLOR.ink}
        transform={`translate(${CENTER},${CENTER}) rotate(${heading})`}
      />
    </svg>
  );
};

const Legend = () => (
  <Box
    style={{
      display: 'flex',
      flexWrap: 'wrap',
      gap: '4px 12px',
      color: COLOR.ink2,
      fontSize: '11.5px',
      padding: '2px 4px',
    }}
  >
    <span>
      <Symbol side="hostile" />
      wróg
    </span>
    <span>
      <Symbol side="friend" />
      sojusznik
    </span>
    <span>
      <Symbol side="unknown" />
      nierozpoznany
    </span>
    <span>
      <span
        style={{
          ...swatch('rgba(76,201,240,0.33)'),
          border: '1px solid ' + COLOR.tel,
        }}
      />
      teleskop
    </span>
    <span>
      <span
        style={{
          ...swatch('rgba(255,140,66,0.2)'),
          border: '1px dashed ' + COLOR.ir,
        }}
      />
      podczerwień ślepa
    </span>
    <span>
      <span style={swatch('rgba(177,140,255,0.33)')} />
      usłyszany impuls
    </span>
    <span>
      <span style={swatch(OBJECT_COLOR.asteroid)} />
      asteroida
    </span>
    <span>
      <span style={{ color: OBJECT_COLOR.wreck, marginRight: '5px' }}>
        {'\u2715'}
      </span>
      wrak
    </span>
    <span>
      <span style={{ color: OBJECT_COLOR.anomaly, marginRight: '5px' }}>
        {'\u2726'}
      </span>
      anomalia
    </span>
  </Box>
);

const SensorRow = (props: {
  colour: string;
  name: string;
  children: ReactNode;
  control?: ReactNode;
}) => (
  <>
    <span
      style={{
        width: '10px',
        height: '10px',
        borderRadius: '50%',
        background: props.colour,
      }}
    />
    <span style={{ color: COLOR.ink, fontWeight: 600 }}>{props.name}</span>
    <span style={{ color: COLOR.ink2, fontSize: '12px' }}>
      {props.children}
    </span>
    <span>{props.control}</span>
  </>
);

const Sensors = (props: {
  contacts: Contact[];
  onAimTarget: (target: AimTarget) => void;
}) => {
  const { act, data } = useBackend<Data>();
  const cooldown = data.pulse_cooldown || 0;
  const delay = Math.max(1, data.radar_delay);
  const loaded = data.pulse_active ? 1 : 1 - Math.min(cooldown / delay, 1);
  const emissions = (data.markers || []).filter((marker) => !!marker.emission);
  const aim = props.contacts.find(
    (contact) => contact.id === data.telescope_target,
  );
  let pulseText: ReactNode = 'gotowy';
  if (data.pulse_active) {
    pulseText = 'impuls trwa';
  } else if (cooldown > 0) {
    pulseText = <>ładowanie: {Math.ceil(cooldown)} s</>;
  }
  const telescope = (mode: Data['telescope_mode'], label: string) => (
    <Button
      selected={data.telescope_mode === mode}
      onClick={() => {
        act('set_telescope', { mode: mode });
        if (mode === 'recznie') {
          props.onAimTarget('telescope');
        }
      }}
    >
      {label}
    </Button>
  );
  const radarAim = (mode: Data['radar_beam_mode'], label: string) => (
    <Button
      selected={data.radar_beam_mode === mode}
      onClick={() => {
        act('set_radar_aim', { mode: mode });
        if (mode === 'recznie') {
          props.onAimTarget('radar');
        }
      }}
    >
      {label}
    </Button>
  );
  return (
    <Box style={card}>
      <div style={sectionTitle}>Sensory</div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '12px 84px 1fr auto',
          gap: '6px 8px',
          alignItems: 'center',
        }}
      >
        <SensorRow
          colour={COLOR.radar}
          name="Radar"
          control={
            <>
              <Button
                selected={!data.radar_mode}
                onClick={() => act('set_sensor_mode', { radar: false })}
              >
                Nasłuch
              </Button>
              <Button
                selected={!!data.radar_mode}
                color={data.radar_mode ? 'bad' : undefined}
                disabled={!data.can_use_radar}
                onClick={() => act('set_sensor_mode', { radar: true })}
              >
                Aktywny
              </Button>
            </>
          }
        >
          {data.radar_mode ? (
            <span style={{ color: COLOR.bad }}>
              {data.radar_beam
                ? 'aktywny: słyszą nas okręty w wiązce'
                : 'aktywny: słyszy nas każdy wróg'}
            </span>
          ) : (
            <span style={{ color: COLOR.good }}>nasłuch: nas nie słychać</span>
          )}
        </SensorRow>
        {!!data.cones && (
          <>
            <span />
            <span style={{ color: COLOR.muted, fontSize: '12px' }}>Wiązka</span>
            <span style={{ color: COLOR.ink2, fontSize: '12px' }}>
              {data.radar_beam ? (
                <>
                  {data.radar_beam}° · namiar {pad(data.radar_beam_bearing)}° ·
                  do {data.radar_reach} pól
                </>
              ) : (
                <>dookoła · do {data.radar_reach} pól</>
              )}
            </span>
            <span>
              {[0, 30, 60, 90].map((width) => (
                <Button
                  key={width}
                  selected={data.radar_beam === width}
                  onClick={() => act('set_radar_beam', { width: width })}
                >
                  {width ? width + '°' : 'Dookólna'}
                </Button>
              ))}
            </span>
            {!!data.radar_beam && (
              <>
                <span />
                <span style={{ color: COLOR.muted, fontSize: '12px' }}>
                  Kierunek
                </span>
                <span style={{ color: COLOR.ink2, fontSize: '12px' }}>
                  {data.radar_beam_mode === 'recznie'
                    ? 'ręcznie'
                    : data.radar_beam_mode === 'kurs'
                      ? 'wzdłuż kursu'
                      : 'na cel główny albo cel działonowego'}
                </span>
                <span>
                  {radarAim('cel', 'Cel')}
                  {radarAim('kurs', 'Kurs')}
                  {radarAim('recznie', 'Ręczny')}
                </span>
              </>
            )}
          </>
        )}
        <span />
        <span />
        <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Button
            disabled={!data.can_radar_pulse || !data.can_use_radar}
            onClick={() => act('radar_pulse')}
            style={{
              background:
                'linear-gradient(90deg, rgba(43,90,60,0.6) ' +
                Math.round(loaded * 100) +
                '%, transparent ' +
                Math.round(loaded * 100) +
                '%)',
              fontWeight: 600,
            }}
          >
            Impuls
          </Button>
          <span style={{ color: COLOR.muted, fontSize: '11.5px' }}>
            {pulseText}
          </span>
        </span>
        <span style={{ visibility: data.radar_mode ? 'visible' : 'hidden' }}>
          impuls co{' '}
          <Button
            icon="minus"
            disabled={data.radar_delay <= data.radar_delay_min}
            onClick={() =>
              act('set_radar_delay', { seconds: data.radar_delay - 5 })
            }
          />
          <b style={{ fontFamily: MONO }}>{data.radar_delay + ' s'}</b>
          <Button
            icon="plus"
            disabled={data.radar_delay >= data.radar_delay_max}
            onClick={() =>
              act('set_radar_delay', { seconds: data.radar_delay + 5 })
            }
          />
        </span>
        {!!data.cones && (
          <SensorRow
            colour={COLOR.tel}
            name="Teleskop"
            control={
              <>
                {telescope('cel', 'Cel')}
                {telescope('kurs', 'Kurs')}
                {telescope('recznie', 'Ręczny')}
              </>
            }
          >
            {data.telescope_mode === 'cel' && aim ? (
              <>
                śledzi <b>{shortOf(aim)}</b>
              </>
            ) : data.telescope_mode === 'cel' ? (
              'brak celu, patrzy wzdłuż kursu'
            ) : data.telescope_mode === 'kurs' ? (
              'wzdłuż kursu'
            ) : (
              'ręcznie'
            )}
            {' · namiar '}
            <span style={{ fontFamily: MONO }}>
              {pad(data.telescope_bearing || 0) + '°'}
            </span>
          </SensorRow>
        )}
        {!!data.cones && (
          <SensorRow colour={COLOR.ir} name="Podczerwień">
            {data.ir_blind ? (
              <>
                <span style={{ color: COLOR.warn }}>
                  ślepa 2×{data.ir_blind_half}° za rufą
                </span>
                {' · napęd pracuje'}
              </>
            ) : (
              'widzi dookoła · napęd chłodny'
            )}
          </SensorRow>
        )}
        {!!data.suites && (
          <SensorRow colour={COLOR.opt} name="Kamera">
            dookoła · do{' '}
            <span style={{ fontFamily: MONO }}>{data.camera_reach}</span> pól na
            typowy okręt
          </SensorRow>
        )}
        <SensorRow colour={COLOR.esm} name="Nasłuch">
          {emissions.length === 0 ? (
            'cisza, nikt nie pulsuje'
          ) : (
            <>
              usłyszane impulsy: {emissions.length} · namiar{' '}
              {emissions.map((m) => pad(m.emission!.bearing) + '°').join(', ')}
            </>
          )}
        </SensorRow>
      </div>
    </Box>
  );
};

const ContactList = (props: {
  contacts: Contact[];
  selected: string | null;
  onSelect: (id: string) => void;
}) => {
  const { data } = useBackend<Data>();
  const { contacts, selected, onSelect } = props;
  const order = { hostile: 0, unknown: 1, friend: 2 };
  const sorted = [...contacts].sort(
    (a, b) =>
      order[sideOf(a)] - order[sideOf(b)] || distanceOf(a) - distanceOf(b),
  );
  const cell: CSSProperties = {
    padding: '4px 5px',
    borderBottom: '1px solid #18222f',
    whiteSpace: 'nowrap',
  };
  const head: CSSProperties = {
    color: COLOR.muted,
    fontWeight: 600,
    fontSize: '11px',
    textAlign: 'left',
    padding: '3px 5px',
    borderBottom: '1px solid ' + COLOR.line,
  };
  return (
    <Box style={card}>
      <div style={sectionTitle}>
        Kontakty
        <span
          style={{
            marginLeft: 'auto',
            textTransform: 'none',
            letterSpacing: 0,
            fontWeight: 400,
          }}
        >
          {contacts.length} · wrogich:{' '}
          {contacts.filter((c) => sideOf(c) === 'hostile').length}
        </span>
      </div>
      {sorted.length === 0 ? (
        <Box color="label">Sensory niczego nie wykrywają.</Box>
      ) : (
        <table
          style={{
            width: '100%',
            borderCollapse: 'collapse',
            fontSize: '12.5px',
          }}
        >
          <thead>
            <tr>
              <th style={head} />
              <th style={head}>kontakt</th>
              <th style={{ ...head, textAlign: 'right' }}>odl.</th>
              <th style={{ ...head, textAlign: 'right' }}>namiar</th>
              {!!data.suites && <th style={head}>sensor</th>}
              <th style={head}>stan</th>
            </tr>
          </thead>
          <tbody>
            {sorted.map((contact) => {
              const suite = contact.sensor ? SUITES[contact.sensor] : undefined;
              const isSelected = contact.id === selected;
              const row: CSSProperties = {
                ...cell,
                background: isSelected ? '#1a2c44' : undefined,
              };
              return (
                <tr
                  key={contact.id}
                  style={{ cursor: 'pointer' }}
                  onClick={() => onSelect(contact.id)}
                >
                  <td style={row}>
                    <Symbol side={sideOf(contact)} />
                  </td>
                  <td style={{ ...row, whiteSpace: 'normal' }}>
                    <b>{shortOf(contact)}</b> {contact.name}
                    {contact.uncertainty > 0 && (
                      <span style={{ color: COLOR.muted }}>
                        {' ±' + Math.round(contact.uncertainty)}
                      </span>
                    )}
                  </td>
                  <td style={{ ...row, textAlign: 'right', fontFamily: MONO }}>
                    {distanceOf(contact)}
                  </td>
                  <td style={{ ...row, textAlign: 'right', fontFamily: MONO }}>
                    {pad(bearingOf(contact)) + '°'}
                  </td>
                  {!!data.suites && (
                    <td style={row}>
                      {suite ? (
                        <>
                          <span style={swatch(suite[1])} />
                          {suite[0]}
                        </>
                      ) : (
                        <span style={{ color: COLOR.muted }}>słaby sygnał</span>
                      )}
                    </td>
                  )}
                  <td style={row}>
                    <ContactTags contact={contact} />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
    </Box>
  );
};

const ContactCard = (props: { contact: Contact | undefined }) => {
  const { act, data } = useBackend<Data>();
  const { contact } = props;
  if (!contact) {
    return null;
  }
  const distance = distanceOf(contact);
  const designate = (designation: Designation) =>
    act('designate', { id: contact.id, designation: designation });
  const scaleMax = Math.max(150, distance * 1.2);
  const fact: CSSProperties = { fontFamily: MONO, fontWeight: 500 };
  const label: CSSProperties = { color: COLOR.muted };
  return (
    <Box style={card}>
      <div style={sectionTitle}>Wybrany kontakt</div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          marginBottom: '6px',
        }}
      >
        <Symbol side={sideOf(contact)} size={13} />
        <b style={{ fontSize: '15px' }}>
          {shortOf(contact) + ' · ' + contact.name}
        </b>
        <ContactTags contact={contact} />
      </div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'auto 1fr auto 1fr',
          gap: '3px 10px',
          fontSize: '12.5px',
          marginBottom: '8px',
        }}
      >
        <span style={label}>odległość</span>
        <span style={fact}>{distance} pól</span>
        <span style={label}>namiar</span>
        <span style={fact}>{pad(bearingOf(contact)) + '°'}</span>
        <span style={label}>pozycja</span>
        <span style={fact}>
          {contact.uncertainty > 0 ? (
            <>±{Math.round(contact.uncertainty)} pól</>
          ) : (
            'dokładna'
          )}
        </span>
        <span style={label}>tożsamość</span>
        <span style={fact}>
          {contact.identified ? 'rozpoznany' : 'nierozpoznany'}
        </span>
        {(!!contact.painted || !!contact.locked) && (
          <>
            <span style={label}>działonowy</span>
            <span style={fact}>
              {contact.locked ? 'namierzony, cel ognia' : 'oznaczony'}
            </span>
          </>
        )}
      </div>
      {!!data.suites && !!contact.suites && (
        <>
          {contact.suites.map((report) => {
            const suite = SUITES[report.suite] || [report.suite, COLOR.muted];
            const sees = report.state === 'sees';
            return (
              <div
                key={report.suite}
                style={{
                  display: 'grid',
                  gridTemplateColumns: '96px 1fr 92px',
                  gap: '6px',
                  alignItems: 'center',
                  fontSize: '12px',
                  margin: '2px 0',
                  opacity: sees ? 1 : 0.55,
                }}
              >
                <span>
                  <span style={swatch(suite[1])} />
                  {suite[0]}
                </span>
                <span
                  style={{
                    height: '7px',
                    borderRadius: '4px',
                    background: '#1c2735',
                    position: 'relative',
                  }}
                >
                  <span
                    style={{
                      position: 'absolute',
                      left: 0,
                      top: 0,
                      bottom: 0,
                      borderRadius: '4px',
                      width:
                        Math.min(100, (report.reach / scaleMax) * 100) + '%',
                      background: suite[1],
                      opacity: 0.55,
                    }}
                  />
                  <span
                    style={{
                      position: 'absolute',
                      top: '-3px',
                      bottom: '-3px',
                      width: '2px',
                      background: '#ffffff',
                      left: Math.min(100, (distance / scaleMax) * 100) + '%',
                    }}
                  />
                </span>
                <span
                  style={{
                    textAlign: 'right',
                    color: sees ? COLOR.good : COLOR.ink2,
                  }}
                >
                  {SUITE_STATES[report.state]}
                </span>
              </div>
            );
          })}
        </>
      )}
      {!!contact.hostile && (
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            marginTop: '8px',
            flexWrap: 'wrap',
          }}
        >
          <span style={{ color: COLOR.muted, fontSize: '11.5px' }}>
            Przekaż mostkowi:
          </span>
          <Button
            icon="crosshairs"
            selected={contact.designation === 'primary'}
            onClick={() => designate('primary')}
          >
            Cel główny
          </Button>
          <Button
            icon="dot-circle"
            selected={contact.designation === 'secondary'}
            onClick={() => designate('secondary')}
          >
            Drugorzędny
          </Button>
          <Button
            icon="times"
            selected={!contact.designation}
            onClick={() => designate(null)}
          >
            Nie
          </Button>
        </div>
      )}
    </Box>
  );
};

const ObjectCard = (props: { thing: ScopeObject }) => {
  const { thing } = props;
  const label: CSSProperties = { color: COLOR.muted };
  const fact: CSSProperties = { fontFamily: MONO, fontWeight: 500 };
  return (
    <Box style={card}>
      <div style={sectionTitle}>Wybrany obiekt</div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          marginBottom: '6px',
        }}
      >
        <span style={swatch(OBJECT_COLOR[thing.kind])} />
        <b style={{ fontSize: '15px' }}>{thing.name}</b>
      </div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'auto 1fr auto 1fr',
          gap: '3px 10px',
          fontSize: '12.5px',
        }}
      >
        <span style={label}>rodzaj</span>
        <span style={fact}>{OBJECT_KIND[thing.kind]}</span>
        <span style={label}>odległość</span>
        <span style={fact}>{distanceOf(thing)} pól</span>
        <span style={label}>namiar</span>
        <span style={fact}>{pad(bearingOf(thing)) + '°'}</span>
        {!!thing.detail && (
          <>
            <span style={label}>stan</span>
            <span style={fact}>{thing.detail}</span>
          </>
        )}
      </div>
    </Box>
  );
};

const PassedToBridge = (props: { contacts: Contact[] }) => {
  const { data } = useBackend<Data>();
  const designated = props.contacts
    .filter((contact) => !!contact.designation)
    .sort((a, b) => (a.designation === 'primary' ? -1 : 1));
  return (
    <Box
      style={{
        display: 'flex',
        gap: '8px',
        alignItems: 'center',
        padding: '7px 10px',
        borderTop: '1px solid ' + COLOR.line,
        background: COLOR.panel,
        minHeight: '38px',
        flexWrap: 'wrap',
      }}
    >
      <span
        style={{
          color: COLOR.muted,
          fontSize: '11px',
          textTransform: 'uppercase',
          letterSpacing: '0.08em',
          marginRight: '4px',
        }}
      >
        Przekazane mostkowi
      </span>
      {designated.length === 0 && (
        <span style={{ color: COLOR.muted, fontSize: '12px' }}>brak</span>
      )}
      {designated.map((contact) => (
        <span
          key={contact.id}
          style={{
            display: 'inline-flex',
            gap: '6px',
            alignItems: 'center',
            border: '1px solid #3a3416',
            background: '#1c1a0c',
            borderRadius: '4px',
            padding: '3px 8px',
            fontSize: '12px',
          }}
        >
          <b
            style={{
              color:
                contact.designation === 'primary' ? COLOR.desig : COLOR.desig2,
            }}
          >
            {shortOf(contact)}
          </b>
          {contact.designation === 'primary' ? 'główny' : 'drugorzędny'}
          <span style={{ color: COLOR.ink2 }}>
            ·{' '}
            {contact.locked
              ? 'działonowy namierzył'
              : contact.painted
                ? 'działonowy oznaczył'
                : 'czeka na działonowego'}
          </span>
        </span>
      ))}
      <span
        style={{ marginLeft: 'auto', color: COLOR.muted, fontSize: '12px' }}
      >
        {'Działonowy: '}
        <b style={{ color: data.gunner ? COLOR.ink : COLOR.warn }}>
          {data.gunner ? 'obecny' : 'nikt nie siedzi przy konsoli taktycznej'}
        </b>
      </span>
    </Box>
  );
};

export const SensorConsole = (props) => {
  const { data } = useBackend<Data>();
  const [selected, setSelected] = useState<string | null>(null);
  const [rangeIndex, setRangeIndex] = useState(1);
  const [aimTarget, setAimTarget] = useState<AimTarget>('telescope');
  // Wiązka bez trybu ręcznego (albo radar dookólny): przeciąganie wraca do teleskopu
  const effectiveAim: AimTarget =
    aimTarget === 'radar' &&
    !(data.radar_beam && data.radar_beam_mode === 'recznie')
      ? 'telescope'
      : aimTarget;
  // Serwer przysyła dane mniej więcej co sekundę. Pewne kontakty (bez okręgu niepewności) mają kurs,
  // więc między aktualizacjami przesuwamy je sami, tak samo obrót własnego okrętu.
  const receivedAt = useRef(Date.now());
  const [, setFrame] = useState(0);
  // Czas przyjścia danych zapisujemy w tym samym renderze, w którym przyszły; efekt odpalał się po renderze
  // i pierwszy obraz po aktualizacji przesuwał kontakty o cały poprzedni czas (drganie)
  const lastData = useRef(data);
  if (lastData.current !== data) {
    lastData.current = data;
    receivedAt.current = Date.now();
  }
  useEffect(() => {
    const timer = setInterval(() => setFrame((frame) => frame + 1), 100);
    return () => clearInterval(timer);
  }, []);
  const elapsed = Math.min((Date.now() - receivedAt.current) / 1000, 1.5);
  const contacts = (data.contacts || []).map((contact) =>
    contact.vx || contact.vy
      ? {
          ...contact,
          dx: contact.dx + contact.vx * elapsed,
          dy: contact.dy + contact.vy * elapsed,
        }
      : contact,
  );
  const turned = (data.heading || 0) + (data.turn || 0) * Math.min(elapsed, 1);
  const heading = ((turned % 360) + 360) % 360;
  const current = contacts.find((contact) => contact.id === selected);
  const currentObject = (data.objects || []).find(
    (thing) => thing.id === selected,
  );
  const pulseAge = (data.pulse_age || 0) + elapsed;
  return (
    <Window width={1140} height={740}>
      <Window.Content
        style={{
          background: COLOR.bg,
          color: COLOR.ink,
          padding: 0,
          fontSize: '13px',
        }}
      >
        <Box
          style={{ display: 'flex', flexDirection: 'column', height: '100%' }}
        >
          <TopBar />
          <Box style={{ flex: 1, display: 'flex', minHeight: 0 }}>
            <Box
              style={{
                width: '462px',
                padding: '10px',
                display: 'flex',
                flexDirection: 'column',
                gap: '6px',
                borderRight: '1px solid ' + COLOR.line,
              }}
            >
              <Box style={{ position: 'relative', width: SCOPE + 'px' }}>
                <Scope
                  range={SCOPE_RANGES[rangeIndex]}
                  contacts={contacts}
                  heading={heading}
                  pulseAge={pulseAge}
                  aimTarget={effectiveAim}
                  selected={selected}
                  onSelect={setSelected}
                />
                <Box style={{ position: 'absolute', top: '4px', right: '4px' }}>
                  {SCOPE_RANGES.map((range, index) => (
                    <Button
                      key={range}
                      selected={index === rangeIndex}
                      onClick={() => setRangeIndex(index)}
                    >
                      <>{range} pól</>
                    </Button>
                  ))}
                </Box>
              </Box>
              <Legend />
            </Box>
            <Box
              style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                minWidth: 0,
                overflowY: 'auto',
              }}
            >
              <Sensors contacts={contacts} onAimTarget={setAimTarget} />
              <ContactList
                contacts={contacts}
                selected={selected}
                onSelect={setSelected}
              />
              {currentObject ? (
                <ObjectCard thing={currentObject} />
              ) : (
                <ContactCard contact={current} />
              )}
            </Box>
          </Box>
          <PassedToBridge contacts={contacts} />
        </Box>
      </Window.Content>
    </Window>
  );
};
