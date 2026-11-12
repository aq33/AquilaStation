// AQUILA - konsola taktyczna (strzelca) z ekranem kontroli ognia (aquila/code/modules/overmap/fire_control.dm).
// Wygląd jak stanowisko rozpoznania (SensorConsole.tsx), w kolorach ognia.
import {
  type CSSProperties,
  Fragment,
  type ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Box, Button, NumberInput } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  bearingOf,
  card,
  COLOR,
  type Contact,
  distanceOf,
  LABEL_CHAR_PX,
  MONO,
  OBJECT_COLOR,
  pad,
  type ScopeObject,
  sectionTitle,
  shortOf,
  sideOf,
  swatch,
  Symbol,
  Tag,
} from './SensorConsole';

type FireContact = Contact & {
  targetable: boolean;
  armour?: number[];
};

type Weapon = {
  name: string;
  ammo: number;
  maxammo: number;
  controllers: string | null;
  ammo_filter: string | null;
  weapon_priority: number | null;
  can_modify_priority: boolean | null;
  weapon_ref: string;
};

type Designated = {
  id: string;
  name: string;
  designation: 'primary' | 'secondary';
  distance: number;
  painted: boolean;
  locked: boolean;
};

type Data = {
  own_armour: number[];
  heading: number;
  turn: number;
  contacts: FireContact[];
  objects: ScopeObject[];
  gun_range: number;
  hail_range: number;
  weapons: Weapon[];
  additional_weapon_info: boolean;
  modifying_weapon_priorities: boolean;
  no_gun_cam: boolean;
  target_name: string;
  sensor_station: boolean;
  designated_targets: Designated[];
};

const FIRE = {
  lock: '#ff3b3b',
  paint: '#ff9a3c',
  ring: '#5a3a30',
  ringInner: '#3a2620',
  label: '#c39a88',
  ringText: '#a07a6a',
};

const SCOPE = 440;
const CENTER = SCOPE / 2;
const RADIUS = 208;
const RANGES: [number, string][] = [
  [50, '50 pól'],
  [100, '100 pól'],
  [200, '200 pól'],
  [255, 'cała mapa'],
];
// Kolejność ćwiartek z DM (get_armour_report): dziób lewa, dziób prawa, rufa lewa, rufa prawa, kadłub
const QUADRANTS = [
  'dziób, lewa burta',
  'dziób, prawa burta',
  'rufa, lewa burta',
  'rufa, prawa burta',
];

const healthColour = (pct: number) =>
  pct > 60 ? COLOR.good : pct > 30 ? COLOR.warn : COLOR.bad;

// Pancerz i kadłub w dużej, czytelnej formie: cztery ćwiartki jak rzut okrętu z góry (dziób u góry) i pasek kadłuba
const ArmourDiagram = (props: { armour: number[]; title?: ReactNode }) => {
  const { armour, title } = props;
  const hull = armour[4] ?? 0;
  const cell = (index: number) => {
    const value = armour[index] ?? 0;
    const colour = healthColour(value);
    return (
      <div
        title={QUADRANTS[index]}
        style={{
          border: '1px solid ' + colour,
          background: colour + '26',
          borderRadius: index < 2 ? '14px 14px 4px 4px' : '4px 4px 10px 10px',
          padding: '2px 0',
          textAlign: 'center',
        }}
      >
        <div
          style={{
            fontFamily: MONO,
            fontSize: '14px',
            fontWeight: 700,
            color: colour,
          }}
        >
          {value}%
        </div>
        <div style={{ fontSize: '9.5px', color: COLOR.ink2 }}>
          {QUADRANTS[index]}
        </div>
      </div>
    );
  };
  return (
    <div>
      {title}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '4px',
          maxWidth: '240px',
        }}
      >
        {cell(0)}
        {cell(1)}
        {cell(2)}
        {cell(3)}
      </div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          marginTop: '6px',
          maxWidth: '240px',
        }}
      >
        <span style={{ color: COLOR.ink2, width: '50px' }}>Kadłub</span>
        <span
          style={{
            flex: 1,
            height: '12px',
            borderRadius: '6px',
            background: '#1c2735',
            overflow: 'hidden',
          }}
        >
          <span
            style={{
              display: 'block',
              height: '100%',
              width: hull + '%',
              background: healthColour(hull),
            }}
          />
        </span>
        <b
          style={{
            fontFamily: MONO,
            fontSize: '16px',
            color: healthColour(hull),
            width: '48px',
            textAlign: 'right',
          }}
        >
          {hull}%
        </b>
      </div>
    </div>
  );
};

const TopBar = () => {
  const { act, data } = useBackend<Data>();
  const hull = data.own_armour?.[4] ?? 0;
  const locked = (data.contacts || []).find((contact) => contact.locked);
  return (
    <Box
      style={{
        display: 'flex',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: '14px',
        padding: '8px 10px',
        borderBottom: '1px solid ' + COLOR.line,
        background: COLOR.panel,
      }}
    >
      <span style={{ color: COLOR.ink2 }}>
        Kadłub{' '}
        <b
          style={{
            fontFamily: MONO,
            fontSize: '18px',
            color: healthColour(hull),
          }}
        >
          {hull}%
        </b>
      </span>
      <span style={{ color: COLOR.ink2 }}>
        Cel ognia:{' '}
        <b style={{ color: locked ? FIRE.lock : COLOR.muted }}>
          {locked ? shortOf(locked) + ' ' + locked.name : 'brak'}
        </b>
      </span>
      <span style={{ marginLeft: 'auto', color: COLOR.ink2 }}>
        Obraz z:{' '}
        <b style={{ color: COLOR.ink }}>
          {data.sensor_station ? 'stanowiska rozpoznania' : 'własnych sensorów'}
        </b>
      </span>
      {!data.no_gun_cam && (
        <Button icon="video" onClick={() => act('toggle_gun_camera')}>
          Kamera działa
        </Button>
      )}
    </Box>
  );
};

type ScopeProps = {
  range: number;
  contacts: FireContact[];
  heading: number;
  selected: string | null;
  onSelect: (id: string) => void;
};

const FireScope = (props: ScopeProps) => {
  const { data } = useBackend<Data>();
  const { range, contacts, heading, selected, onSelect } = props;
  const objects = data.objects || [];
  const scale = RADIUS / range;
  const toPoint = (dx: number, dy: number): [number, number, boolean] => {
    const dist = Math.sqrt(dx * dx + dy * dy);
    const clamp = dist > range ? range / dist : 1;
    return [
      CENTER + dx * clamp * scale,
      CENTER - dy * clamp * scale,
      clamp < 1,
    ];
  };
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
        stroke={FIRE.ring}
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
          fill={FIRE.label}
        >
          {pad(b)}
        </text>,
      );
    }
  }
  // Podpisy bez nakładania: cel ognia, śledzone, od operatora, reszta, obiekty na końcu
  const rank = (c: FireContact) =>
    c.locked
      ? 0
      : c.painted
        ? 1
        : c.designation
          ? 2
          : sideOf(c) === 'hostile'
            ? 3
            : 4;
  const labelled = new Set<string>();
  const placed: [number, number, number, number][] = [];
  const candidates = [
    ...[...contacts]
      .sort((a, b) => rank(a) - rank(b))
      .map((c) => ({
        id: c.id,
        dx: c.dx,
        dy: c.dy,
        text: shortOf(c) + (c.locked ? ' · OGIEŃ' : ''),
        offset: 14,
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
      py - 24,
      px + item.offset + item.text.length * LABEL_CHAR_PX,
      py - 10,
    ];
    if (
      !placed.some(
        (b) => box[0] < b[2] && box[2] > b[0] && box[1] < b[3] && box[3] > b[1],
      )
    ) {
      placed.push(box);
      labelled.add(item.id);
    }
  }
  const locked = contacts.find((c) => c.locked);
  const ring = (r: number) => Math.min(r * scale, RADIUS);
  return (
    <svg
      width={SCOPE}
      height={SCOPE}
      viewBox={'0 0 ' + SCOPE + ' ' + SCOPE}
      style={{ display: 'block', userSelect: 'none' }}
    >
      <defs>
        <radialGradient id="fireBg">
          <stop offset="0%" stopColor="#1a1210" />
          <stop offset="100%" stopColor="#0d0a09" />
        </radialGradient>
      </defs>
      <circle cx={CENTER} cy={CENTER} r={RADIUS} fill="url(#fireBg)" />
      {[1, 2, 3, 4].map((i) => (
        <g key={'r' + i}>
          <circle
            cx={CENTER}
            cy={CENTER}
            r={(RADIUS * i) / 4}
            fill="none"
            stroke={i === 4 ? FIRE.ring : FIRE.ringInner}
          />
          <text
            x={CENTER + 4}
            y={CENTER - (RADIUS * i) / 4 + 12}
            fontSize="11"
            fontFamily={MONO}
            fill={FIRE.ringText}
          >
            {Math.round((range * i) / 4)}
          </text>
        </g>
      ))}
      {ticks}
      <circle
        cx={CENTER}
        cy={CENTER}
        r={ring(data.gun_range)}
        fill="rgba(255,93,93,0.06)"
        stroke="rgba(255,93,93,0.7)"
        strokeDasharray="4 3"
      />
      <circle
        cx={CENTER}
        cy={CENTER}
        r={ring(data.hail_range)}
        fill="none"
        stroke="rgba(120,180,255,0.35)"
        strokeDasharray="2 5"
      />
      {objects.map((thing) => {
        const [x, y, outside] = toPoint(thing.dx, thing.dy);
        if (outside) {
          return null;
        }
        const colour = OBJECT_COLOR[thing.kind];
        return (
          <g key={thing.id}>
            <title>{thing.name}</title>
            {thing.kind === 'wreck' ? (
              <path
                d={`M${x - 4},${y - 4} L${x + 4},${y + 4} M${x + 4},${y - 4} L${x - 4},${y + 4}`}
                stroke={colour}
                strokeWidth={2}
              />
            ) : (
              <circle
                cx={x}
                cy={y}
                r={thing.kind === 'anomaly' ? 4 : 3.5}
                fill={colour}
                fillOpacity={0.7}
              />
            )}
            {labelled.has(thing.id) && (
              <text
                x={x + 8}
                y={y - 12}
                fontSize="11"
                stroke="#0d0a09"
                strokeWidth={3}
                paintOrder="stroke"
                fill={colour}
              >
                {thing.name}
              </text>
            )}
          </g>
        );
      })}
      {!!locked &&
        (() => {
          const [x, y] = toPoint(locked.dx, locked.dy);
          return (
            <line
              x1={CENTER}
              y1={CENTER}
              x2={x}
              y2={y}
              stroke="rgba(255,59,59,0.45)"
              strokeDasharray="5 4"
              strokeWidth={1.5}
            />
          );
        })()}
      {contacts.map((contact) => {
        const [x, y, outside] = toPoint(contact.dx, contact.dy);
        const side = sideOf(contact);
        const colour = COLOR[side];
        const uncertainty = Math.max(0, contact.uncertainty * scale);
        const s = 6;
        return (
          <g
            key={contact.id}
            style={{ cursor: 'pointer' }}
            opacity={outside ? 0.55 : 1}
            onClick={() => onSelect(contact.id)}
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
            {!!contact.painted && (
              <rect
                x={x - 11}
                y={y - 11}
                width={22}
                height={22}
                fill="none"
                stroke={FIRE.paint}
                strokeWidth={2}
              />
            )}
            {!!contact.locked && (
              <>
                <circle
                  cx={x}
                  cy={y}
                  r={15}
                  fill="none"
                  stroke={FIRE.lock}
                  strokeWidth={2}
                />
                {[
                  [0, -1],
                  [1, 0],
                  [0, 1],
                  [-1, 0],
                ].map(([kx, ky]) => (
                  <line
                    key={kx + '_' + ky}
                    x1={x + kx * 15}
                    y1={y + ky * 15}
                    x2={x + kx * 21}
                    y2={y + ky * 21}
                    stroke={FIRE.lock}
                    strokeWidth={2}
                  />
                ))}
              </>
            )}
            {!!contact.designation &&
              [
                [-1, -1],
                [1, -1],
                [1, 1],
                [-1, 1],
              ].map(([kx, ky]) => (
                <path
                  key={'d' + kx + '_' + ky}
                  d={`M${x + kx * 13},${y + ky * 8} L${x + kx * 13},${y + ky * 13} L${x + kx * 8},${y + ky * 13}`}
                  fill="none"
                  stroke={COLOR.desig}
                  strokeWidth={1.5}
                />
              ))}
            {selected === contact.id && (
              <circle
                cx={x}
                cy={y}
                r={24}
                fill="none"
                stroke="#ffffff"
                strokeDasharray="2 3"
              />
            )}
            {labelled.has(contact.id) && (
              <text
                x={x + 14}
                y={y - 12}
                fontSize="12"
                fontWeight="bold"
                stroke="#0d0a09"
                strokeWidth={3}
                paintOrder="stroke"
                fill={contact.locked ? '#ff8a8a' : '#e8dcd6'}
              >
                {shortOf(contact)}
                {!!contact.locked && ' · OGIEŃ'}
              </text>
            )}
            <circle cx={x} cy={y} r={16} fill="transparent" />
          </g>
        );
      })}
      <path
        d="M0,-9 L6,7 L0,4 L-6,7 Z"
        fill={COLOR.ink}
        transform={`translate(${CENTER},${CENTER}) rotate(${heading})`}
      />
    </svg>
  );
};

const Weapons = () => {
  const { act, data } = useBackend<Data>();
  const weapons = Object.values(data.weapons || {}).filter(
    (weapon) => !!weapon.maxammo,
  );
  return (
    <Box style={card}>
      <div style={sectionTitle}>
        Uzbrojenie
        <span style={{ marginLeft: 'auto', textTransform: 'none' }}>
          <Button
            icon="cog"
            selected={!!data.additional_weapon_info}
            onClick={() => act('toggle_additional_weapon_info')}
          >
            Więcej informacji
          </Button>
          <Button
            icon="wrench"
            selected={!!data.modifying_weapon_priorities}
            disabled={!data.additional_weapon_info}
            onClick={() => act('toggle_weapon_priority_modification')}
          />
        </span>
      </div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 130px 60px',
          gap: '4px 10px',
          alignItems: 'center',
          fontSize: '12.5px',
        }}
      >
        {weapons.map((weapon) => {
          const ratio = weapon.ammo / weapon.maxammo;
          return (
            <Fragment key={weapon.weapon_ref}>
              <span>{weapon.name}</span>
              <span
                style={{
                  height: '8px',
                  borderRadius: '4px',
                  background: '#1c2735',
                  overflow: 'hidden',
                }}
              >
                <span
                  style={{
                    display: 'block',
                    height: '100%',
                    width: Math.round(ratio * 100) + '%',
                    background:
                      ratio > 0.9
                        ? COLOR.good
                        : ratio > 0.15
                          ? COLOR.warn
                          : COLOR.bad,
                  }}
                />
              </span>
              <span
                style={{
                  textAlign: 'right',
                  fontFamily: MONO,
                  color: COLOR.ink2,
                }}
              >
                {weapon.ammo + '/' + weapon.maxammo}
              </span>
              {!!data.additional_weapon_info && (
                <span
                  style={{
                    gridColumn: '1 / 4',
                    color: COLOR.muted,
                    fontSize: '11.5px',
                    marginBottom: '3px',
                  }}
                >
                  {data.modifying_weapon_priorities &&
                  weapon.can_modify_priority ? (
                    <>
                      Priorytet:{' '}
                      <NumberInput
                        step={1}
                        value={weapon.weapon_priority || 1}
                        width="47px"
                        minValue={1}
                        maxValue={900}
                        onChange={(value) =>
                          act('change_weapon_priority', {
                            target_weapon: weapon.weapon_ref,
                            new_priority: value,
                          })
                        }
                      />
                    </>
                  ) : (
                    <>Priorytet: {weapon.weapon_priority}</>
                  )}
                  {!!weapon.controllers && (
                    <> · kontrolery: {weapon.controllers}</>
                  )}
                  {!!weapon.ammo_filter && (
                    <> · filtr amunicji: {weapon.ammo_filter}</>
                  )}
                </span>
              )}
            </Fragment>
          );
        })}
      </div>
    </Box>
  );
};

const FireTags = (props: { contact: FireContact }) => {
  const { contact } = props;
  return (
    <>
      {!!contact.locking_us && (
        <Tag colour="#ff9a9a" background="#3a1515">
          namierza nas
        </Tag>
      )}
      {contact.locked ? (
        <Tag colour="#ff8a8a" background="#4a1010">
          cel ognia
        </Tag>
      ) : (
        !!contact.painted && (
          <Tag colour="#ffbe7a" background="#3a2410">
            śledzony
          </Tag>
        )
      )}
      {!!contact.designation && (
        <Tag colour={COLOR.desig} background="#4a3d08">
          {contact.designation === 'primary'
            ? 'od operatora: główny'
            : 'od operatora'}
        </Tag>
      )}
    </>
  );
};

const ContactList = (props: {
  contacts: FireContact[];
  selected: string | null;
  onSelect: (id: string) => void;
}) => {
  const { contacts, selected, onSelect } = props;
  const rank = (c: FireContact) =>
    c.locked
      ? 0
      : c.painted
        ? 1
        : c.designation
          ? 2
          : sideOf(c) === 'hostile'
            ? 3
            : sideOf(c) === 'unknown'
              ? 4
              : 5;
  const sorted = [...contacts].sort(
    (a, b) => rank(a) - rank(b) || distanceOf(a) - distanceOf(b),
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
          {contacts.length} · śledzonych:{' '}
          {contacts.filter((c) => c.painted).length}
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
              <th style={head}>stan</th>
            </tr>
          </thead>
          <tbody>
            {sorted.map((contact) => {
              const row: CSSProperties = {
                ...cell,
                background: contact.id === selected ? '#2c1a16' : undefined,
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
                  <td style={{ ...row, whiteSpace: 'normal' }}>
                    <FireTags contact={contact} />
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

const ContactCard = (props: { contact: FireContact | undefined }) => {
  const { act, data } = useBackend<Data>();
  const { contact } = props;
  if (!contact) {
    return null;
  }
  const distance = distanceOf(contact);
  const label: CSSProperties = { color: COLOR.muted };
  const fact: CSSProperties = { fontFamily: MONO, fontWeight: 500 };
  const doIt = (action: string) => act(action, { id: contact.id });
  return (
    <Box style={card}>
      <div style={sectionTitle}>Wybrany kontakt</div>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          flexWrap: 'wrap',
        }}
      >
        <Symbol side={sideOf(contact)} size={13} />
        <b style={{ fontSize: '15px' }}>
          {shortOf(contact) + ' · ' + contact.name}
        </b>
        <FireTags contact={contact} />
      </div>
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'auto 1fr auto 1fr',
          gap: '3px 10px',
          fontSize: '12.5px',
          margin: '6px 0 8px',
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
        <span style={label}>działa</span>
        <span style={fact}>
          {distance <= data.gun_range ? 'w zasięgu' : 'za daleko'}
        </span>
      </div>
      {!!contact.armour && <ArmourDiagram armour={contact.armour} />}
      <div
        style={{
          display: 'flex',
          gap: '6px',
          flexWrap: 'wrap',
          marginTop: '8px',
        }}
      >
        {!!contact.hostile && !contact.painted && (
          <Button
            icon="crosshairs"
            color="bad"
            disabled={!contact.targetable}
            tooltip={
              contact.targetable
                ? undefined
                : 'Niepewny kontakt: namierzyć można dopiero pewny.'
            }
            onClick={() => doIt('fc_lockon')}
          >
            Namierz
          </Button>
        )}
        {!!contact.painted && (
          <>
            <Button
              icon="bullseye"
              color="bad"
              selected={!!contact.locked}
              onClick={() => doIt('fc_fire_target')}
            >
              {contact.locked ? 'Przestań celować' : 'Wyceluj'}
            </Button>
            <Button icon="times" onClick={() => doIt('fc_dump')}>
              Przestań śledzić
            </Button>
          </>
        )}
        <Button
          icon="phone"
          disabled={distance > data.hail_range}
          tooltip={
            distance > data.hail_range
              ? 'Za daleko na wywołanie: podejdź na zasięg niebieskiego okręgu.'
              : undefined
          }
          onClick={() => doIt('fc_hail')}
        >
          Wywołaj
        </Button>
      </div>
    </Box>
  );
};

const OwnShip = () => {
  const { data } = useBackend<Data>();
  return (
    <Box style={card}>
      <div style={sectionTitle}>Stan okrętu</div>
      <ArmourDiagram armour={data.own_armour || []} />
    </Box>
  );
};

const DesignatedBar = () => {
  const { act, data } = useBackend<Data>();
  const designated = [...(data.designated_targets || [])].sort((a) =>
    a.designation === 'primary' ? -1 : 1,
  );
  return (
    <Box
      style={{
        display: 'flex',
        gap: '8px',
        alignItems: 'center',
        padding: '7px 10px',
        borderTop: '1px solid ' + COLOR.line,
        background: COLOR.panel,
        minHeight: '40px',
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
        Cele od operatora
      </span>
      {designated.length === 0 && (
        <span style={{ color: COLOR.muted, fontSize: '12px' }}>brak</span>
      )}
      {designated.map((target) => (
        <span
          key={target.id}
          style={{
            display: 'inline-flex',
            gap: '6px',
            alignItems: 'center',
            border: '1px solid #3a3416',
            background: '#1c1a0c',
            borderRadius: '4px',
            padding: '3px 4px 3px 8px',
            fontSize: '12px',
          }}
        >
          <b
            style={{
              color:
                target.designation === 'primary' ? COLOR.desig : COLOR.desig2,
            }}
          >
            {target.name}
          </b>
          {target.designation === 'primary' ? 'główny' : 'drugorzędny'}
          <span style={{ color: COLOR.ink2 }}>· {target.distance} pól</span>
          <Button
            selected={target.locked}
            onClick={() => act('lock_designated', { id: target.id })}
          >
            {target.locked
              ? 'namierzony'
              : target.painted
                ? 'Wyceluj'
                : 'Namierz'}
          </Button>
        </span>
      ))}
    </Box>
  );
};

export const FireControl = (props) => {
  const { data } = useBackend<Data>();
  const [selected, setSelected] = useState<string | null>(null);
  const [rangeIndex, setRangeIndex] = useState(1);
  // Jak na stanowisku rozpoznania: pewne kontakty i obrót okrętu płyną między aktualizacjami
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
  return (
    <Window width={900} height={620}>
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
                width: '460px',
                padding: '10px',
                display: 'flex',
                flexDirection: 'column',
                gap: '6px',
                borderRight: '1px solid ' + COLOR.line,
              }}
            >
              <Box style={{ position: 'relative', width: SCOPE + 'px' }}>
                <FireScope
                  range={RANGES[rangeIndex][0]}
                  contacts={contacts}
                  heading={heading}
                  selected={selected}
                  onSelect={setSelected}
                />
                <Box style={{ position: 'absolute', top: '4px', right: '4px' }}>
                  {RANGES.map(([value, label], index) => (
                    <Button
                      key={value}
                      selected={index === rangeIndex}
                      onClick={() => setRangeIndex(index)}
                    >
                      {label}
                    </Button>
                  ))}
                </Box>
              </Box>
              <Box
                style={{
                  display: 'flex',
                  flexWrap: 'wrap',
                  gap: '4px 12px',
                  color: COLOR.ink2,
                  fontSize: '11.5px',
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
                      ...swatch('transparent'),
                      border: '2px solid ' + FIRE.paint,
                    }}
                  />
                  śledzony
                </span>
                <span>
                  <span
                    style={{
                      ...swatch('transparent'),
                      border: '2px solid ' + FIRE.lock,
                      borderRadius: '50%',
                    }}
                  />
                  cel ognia
                </span>
                <span>
                  <span
                    style={{
                      ...swatch('rgba(255,93,93,0.15)'),
                      border: '1px dashed #ff5d5d',
                      borderRadius: '50%',
                    }}
                  />
                  zasięg dział
                </span>
                <span>
                  <span
                    style={{
                      ...swatch('transparent'),
                      border: '1px dashed rgba(120,180,255,0.6)',
                      borderRadius: '50%',
                    }}
                  />
                  zasięg wywołania
                </span>
              </Box>
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
              <OwnShip />
              <Weapons />
              <ContactList
                contacts={contacts}
                selected={selected}
                onSelect={setSelected}
              />
              <ContactCard contact={current} />
            </Box>
          </Box>
          <DesignatedBar />
        </Box>
      </Window.Content>
    </Window>
  );
};
