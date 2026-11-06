// AQUILA - konsola sensorów, stanowisko operatora radaru (aquila/code/modules/overmap/sensor_console.dm)
import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Designation = 'primary' | 'secondary' | null;

type Contact = {
  id: string;
  name: string;
  dx: number;
  dy: number;
  uncertainty: number;
  hostile: boolean;
  identified: boolean;
  locking_us: boolean;
  painted: boolean;
  locked: boolean;
  designation: Designation;
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
};

const SCOPE_RANGES = [50, 100, 200];
const SCOPE_SIZE = 340;
const THREAT_LABELS = ['sojusznik', 'niskie', 'średnie', 'wysokie'];
const THREAT_COLORS = ['good', 'label', 'average', 'bad'];
const COLOR_HOSTILE = '#ff4d4d';
const COLOR_FRIENDLY = '#4dd96b';
const COLOR_DESIGNATED = '#ffcc00';
const COLOR_EMISSION = '#e9a040';

const distanceOf = (dx: number, dy: number) =>
  Math.round(Math.sqrt(dx * dx + dy * dy));

const bearingOf = (dx: number, dy: number) =>
  Math.round(((Math.atan2(dx, dy) * 180) / Math.PI + 360) % 360);

const threatOf = (contact: Contact, near: number) => {
  if (!contact.hostile) {
    return 0;
  }
  if (contact.locking_us) {
    return 3;
  }
  return distanceOf(contact.dx, contact.dy) <= near ? 2 : 1;
};

const designationLabel = (designation: Designation) =>
  designation === 'primary'
    ? 'cel główny'
    : designation === 'secondary'
      ? 'drugorzędny'
      : '';

const SensorControls = () => {
  const { act, data } = useBackend<Data>();
  const exposed = data.radar_mode || data.pulse_active;
  const cooldown = data.pulse_cooldown || 0;
  const delay = Math.max(1, data.radar_delay);
  let pulseText = 'Impuls gotowy. Odsłoni nas na 5 s.';
  if (data.pulse_active) {
    pulseText = 'Impuls trwa: dokładne pozycje, ale słyszy nas każdy wróg.';
  } else if (cooldown > 0) {
    pulseText = 'Ładowanie impulsu: ' + Math.ceil(cooldown) + ' s';
  }
  return (
    <Section
      title="Sensory"
      buttons={
        !!data.sensor_signatures && (
          <Box inline color={exposed ? 'bad' : 'good'}>
            {'Wróg wykrywa nas z ~' +
              (exposed ? data.seen_from_pulse : data.seen_from) +
              ' pól'}
          </Box>
        )
      }
    >
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            icon="headphones"
            selected={!data.radar_mode}
            tooltip="Tylko nasłuch: cicho, ale kontakty są niepewne."
            onClick={() => act('set_sensor_mode', { radar: false })}
          >
            Nasłuch (cicho)
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="broadcast-tower"
            selected={!!data.radar_mode}
            disabled={!data.can_use_radar}
            tooltip="Radar sam wysyła impulsy w ustalonym odstępie."
            onClick={() => act('set_sensor_mode', { radar: true })}
          >
            Radar aktywny
          </Button>
        </Stack.Item>
      </Stack>
      <Stack mt={1} align="center">
        <Stack.Item>
          <Button
            icon="satellite-dish"
            disabled={!data.can_radar_pulse || !data.can_use_radar}
            onClick={() => act('radar_pulse')}
          >
            Impuls
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <ProgressBar
            value={data.pulse_active ? 1 : 1 - Math.min(cooldown / delay, 1)}
            color={
              data.pulse_active ? 'bad' : cooldown > 0 ? 'average' : 'good'
            }
          >
            {pulseText}
          </ProgressBar>
        </Stack.Item>
      </Stack>
      {!!data.radar_mode && (
        <Stack mt={1} align="center">
          <Stack.Item grow color="label">
            Radar aktywny wysyła impuls co
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="minus"
              disabled={data.radar_delay <= data.radar_delay_min}
              onClick={() =>
                act('set_radar_delay', { seconds: data.radar_delay - 5 })
              }
            />
          </Stack.Item>
          <Stack.Item width="40px" textAlign="center">
            {data.radar_delay + ' s'}
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              disabled={data.radar_delay >= data.radar_delay_max}
              onClick={() =>
                act('set_radar_delay', { seconds: data.radar_delay + 5 })
              }
            />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

type ScopeProps = {
  contacts: Contact[];
  markers: Marker[];
  range: number;
  selected: string | null;
  onSelect: (id: string) => void;
};

const Scope = (props: ScopeProps) => {
  const { contacts, markers, range, selected, onSelect } = props;
  const half = SCOPE_SIZE / 2;
  const scale = (half - 12) / range;
  const toPoint = (dx: number, dy: number): [number, number, boolean] => {
    const dist = Math.sqrt(dx * dx + dy * dy);
    // Contacts outside the scope sit on its edge, in their direction
    const clamp = dist > range ? range / dist : 1;
    return [half + dx * clamp * scale, half - dy * clamp * scale, clamp < 1];
  };
  const sector = (marker: Marker) => {
    const emission = marker.emission;
    if (!emission) {
      return null;
    }
    const points: string[] = [];
    const inner = Math.max(0, emission.distance - emission.spread);
    const outer = emission.distance + emission.spread;
    for (let i = 0; i <= 8; i++) {
      const angle =
        ((emission.bearing - emission.width / 2 + (i * emission.width) / 8) *
          Math.PI) /
        180;
      const r = Math.min(outer, range);
      points.push(
        half +
          Math.sin(angle) * r * scale +
          ',' +
          (half - Math.cos(angle) * r * scale),
      );
    }
    for (let i = 8; i >= 0; i--) {
      const angle =
        ((emission.bearing - emission.width / 2 + (i * emission.width) / 8) *
          Math.PI) /
        180;
      const r = Math.min(inner, range);
      points.push(
        half +
          Math.sin(angle) * r * scale +
          ',' +
          (half - Math.cos(angle) * r * scale),
      );
    }
    return (
      <polygon
        key={'emission_' + emission.bearing + '_' + emission.distance}
        points={points.join(' ')}
        fill={COLOR_EMISSION}
        fillOpacity={0.15 * marker.opacity}
        stroke={COLOR_EMISSION}
        strokeOpacity={marker.opacity}
        strokeDasharray="4 3"
      />
    );
  };
  return (
    <svg
      width={SCOPE_SIZE}
      height={SCOPE_SIZE}
      viewBox={'0 0 ' + SCOPE_SIZE + ' ' + SCOPE_SIZE}
    >
      <circle cx={half} cy={half} r={half - 12} fill="none" stroke="#3c6e47" />
      <circle
        cx={half}
        cy={half}
        r={(half - 12) / 2}
        fill="none"
        stroke="#3c6e47"
        strokeDasharray="3 4"
      />
      <line x1={half} y1={12} x2={half} y2={SCOPE_SIZE - 12} stroke="#26432c" />
      <line x1={12} y1={half} x2={SCOPE_SIZE - 12} y2={half} stroke="#26432c" />
      <text x={half + 4} y={24} fontSize="11" fill="#7fbf8c">
        {range + ' pól · N'}
      </text>
      <text
        x={half + 4}
        y={half - (half - 12) / 2 + 12}
        fontSize="11"
        fill="#7fbf8c"
      >
        {range / 2}
      </text>
      {markers.map(sector)}
      {markers
        .filter((marker) => marker.ghost)
        .map((marker) => {
          const [x, y] = toPoint(marker.dx, marker.dy);
          return (
            <text
              key={'ghost_' + marker.dx + '_' + marker.dy}
              x={x}
              y={y + 5}
              fontSize="16"
              textAnchor="middle"
              fill={COLOR_EMISSION}
              opacity={marker.opacity}
            >
              !
            </text>
          );
        })}
      <circle cx={half} cy={half} r={5} fill="#00ffff" />
      {contacts.map((contact) => {
        const [x, y, outside] = toPoint(contact.dx, contact.dy);
        const colour = contact.hostile ? COLOR_HOSTILE : COLOR_FRIENDLY;
        const uncertainty = Math.max(0, contact.uncertainty * scale);
        return (
          <g
            key={contact.id}
            style={{ cursor: 'pointer' }}
            opacity={outside ? 0.5 : 1}
            onClick={() => onSelect(contact.id)}
          >
            {uncertainty > 3 && !outside && (
              <circle
                cx={x}
                cy={y}
                r={uncertainty}
                fill={colour}
                fillOpacity={0.12}
                stroke={colour}
                strokeOpacity={0.5}
                strokeDasharray="2 2"
              />
            )}
            <circle cx={x} cy={y} r={4} fill={colour} />
            {!!contact.designation && (
              <rect
                x={x - 9}
                y={y - 9}
                width={18}
                height={18}
                rx={3}
                fill="none"
                stroke={COLOR_DESIGNATED}
                strokeWidth={contact.designation === 'primary' ? 2 : 1}
                strokeDasharray={
                  contact.designation === 'primary' ? undefined : '3 2'
                }
              />
            )}
            {selected === contact.id && (
              <circle
                cx={x}
                cy={y}
                r={Math.max(uncertainty, 8) + 5}
                fill="none"
                stroke="#ffffff"
              />
            )}
            <text x={x + 11} y={y - 7} fontSize="11" fill="#d0e8d4">
              {contact.name}
            </text>
            <circle cx={x} cy={y} r={14} fill="transparent" />
          </g>
        );
      })}
    </svg>
  );
};

const ContactCard = (props: { contact: Contact | undefined }) => {
  const { act, data } = useBackend<Data>();
  const { contact } = props;
  if (!contact) {
    return <NoticeBox info>Wybierz kontakt na ekranie albo z listy.</NoticeBox>;
  }
  const threat = threatOf(contact, data.near_range);
  const distance = distanceOf(contact.dx, contact.dy);
  const designate = (designation: Designation) =>
    act('designate', { id: contact.id, designation: designation });
  return (
    <Section
      title={contact.name}
      buttons={
        <Box inline color={THREAT_COLORS[threat]}>
          {contact.hostile
            ? 'zagrożenie ' + THREAT_LABELS[threat]
            : THREAT_LABELS[threat]}
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Odległość">
          {distance + ' pól'}
        </LabeledList.Item>
        <LabeledList.Item label="Namiar">
          {bearingOf(contact.dx, contact.dy) + '°'}
        </LabeledList.Item>
        <LabeledList.Item label="Pozycja">
          {contact.uncertainty > 0
            ? 'przybliżona, ±' + Math.round(contact.uncertainty) + ' pól'
            : 'dokładna'}
        </LabeledList.Item>
        <LabeledList.Item label="Tożsamość">
          {contact.identified ? 'rozpoznany' : 'nierozpoznany'}
        </LabeledList.Item>
        {!!contact.locking_us && (
          <LabeledList.Item label="Uwaga" color="bad">
            namierza nas
          </LabeledList.Item>
        )}
        {(!!contact.painted || !!contact.locked) && (
          <LabeledList.Item label="Działonowy">
            {contact.locked ? 'namierzony, cel ognia' : 'oznaczony'}
          </LabeledList.Item>
        )}
      </LabeledList>
      {!!contact.hostile && (
        <>
          <Box mt={1} color="label">
            Przekaż mostkowi jako
          </Box>
          <Stack mt={0.5}>
            <Stack.Item grow>
              <Button
                fluid
                icon="crosshairs"
                selected={contact.designation === 'primary'}
                onClick={() => designate('primary')}
              >
                Cel główny
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="dot-circle"
                selected={contact.designation === 'secondary'}
                onClick={() => designate('secondary')}
              >
                Drugorzędny
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="times"
                selected={!contact.designation}
                onClick={() => designate(null)}
              >
                Nie
              </Button>
            </Stack.Item>
          </Stack>
        </>
      )}
    </Section>
  );
};

export const SensorConsole = (props) => {
  const { data } = useBackend<Data>();
  const [selected, setSelected] = useState<string | null>(null);
  const [rangeIndex, setRangeIndex] = useState(1);
  const contacts = data.contacts || [];
  const markers = data.markers || [];
  const near = data.near_range;
  const sorted = [...contacts].sort(
    (a, b) =>
      threatOf(b, near) - threatOf(a, near) ||
      distanceOf(a.dx, a.dy) - distanceOf(b.dx, b.dy),
  );
  const current = contacts.find((contact) => contact.id === selected);
  const designated = sorted.filter((contact) => !!contact.designation);
  return (
    <Window theme="hackerman" width={780} height={720}>
      <Window.Content scrollable>
        <SensorControls />
        <Stack>
          <Stack.Item>
            <Section
              title="Ekran"
              buttons={SCOPE_RANGES.map((range, index) => (
                <Button
                  key={range}
                  selected={index === rangeIndex}
                  onClick={() => setRangeIndex(index)}
                >
                  {range + ' pól'}
                </Button>
              ))}
            >
              <Scope
                contacts={contacts}
                markers={markers}
                range={SCOPE_RANGES[rangeIndex]}
                selected={selected}
                onSelect={setSelected}
              />
              <Box color="label" textAlign="center">
                Kliknij kontakt, żeby go wybrać.
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <ContactCard contact={current} />
            <Section title={'Kontakty (' + sorted.length + ')'}>
              {sorted.length === 0 && (
                <Box color="label">Sensory niczego nie wykrywają.</Box>
              )}
              {sorted.map((contact) => (
                <Button
                  key={contact.id}
                  fluid
                  selected={contact.id === selected}
                  color={contact.hostile ? undefined : 'good'}
                  icon={contact.locking_us ? 'exclamation-triangle' : 'circle'}
                  onClick={() => setSelected(contact.id)}
                >
                  {contact.name +
                    ' · ' +
                    distanceOf(contact.dx, contact.dy) +
                    ' pól' +
                    (contact.designation
                      ? ' · ' + designationLabel(contact.designation)
                      : '')}
                </Button>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
        <Section title="Przekazane mostkowi">
          {!data.gunner && (
            <Box color="average" mb={1}>
              Nikt nie siedzi przy konsoli taktycznej.
            </Box>
          )}
          {designated.length === 0 && (
            <Box color="label">
              Nie przekazano celów. Działonowy namierza sam z DRADIS.
            </Box>
          )}
          {designated.map((contact) => (
            <Box key={contact.id}>
              {contact.name +
                ' (' +
                designationLabel(contact.designation) +
                '): ' +
                (contact.locked
                  ? 'działonowy go namierzył'
                  : contact.painted
                    ? 'działonowy go oznaczył'
                    : 'czeka na działonowego')}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
