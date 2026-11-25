// AQUILA - ekran taktyczny (aquila/code/modules/overmap/tactical_screen.dm): jedno okno stanowiska rozpoznania,
// konsoli taktycznej, DRADIS mostka, monitorowania uzbrojenia i AMS. Tryby Rozpoznanie (SensorConsole.tsx),
// Ogień (FireControl.tsx) i Podgląd; konsola wybiera tryb startowy, a serwer pilnuje, kto czym steruje.
import { useState } from 'react';
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  AmsPanel,
  FireBody,
  type FireControlData,
  FireData,
  OwnShip,
  Weapons,
} from './FireControl';
import {
  COLOR,
  LockBox,
  SensorBody,
  type SensorConsoleData,
  SensorData,
} from './SensorConsole';

type Mode = 'sensors' | 'fire' | 'view';

type Data = {
  console: string;
  ship_name: string;
  has_station: boolean;
  mode: Mode;
  can_sensors: boolean;
  can_fire: boolean;
  can_pulse: boolean;
  sensor?: SensorConsoleData;
  fire?: FireControlData;
};

const MODES: [Mode, string][] = [
  ['sensors', 'Rozpoznanie'],
  ['fire', 'Ogień'],
  ['view', 'Podgląd'],
];

// Impuls radaru dla pilota przy sterze, który nie ma panelu sensorów
const PulseButton = () => {
  const { act, data } = useBackend<Data>();
  const sensor = data.sensor;
  if (!sensor || !data.can_pulse || data.can_sensors) {
    return null;
  }
  const cooldown = sensor.pulse_cooldown || 0;
  return (
    <Button
      icon="satellite-dish"
      disabled={!sensor.can_radar_pulse || cooldown > 0}
      tooltip="Impuls radaru ze stanowiska rozpoznania: widać dalej, ale wrogowie słyszą okręt."
      onClick={() => act('radar_pulse')}
    >
      {cooldown > 0 ? <>Impuls za {Math.ceil(cooldown)} s</> : 'Impuls radaru'}
    </Button>
  );
};

// Kto steruje czym, gdy ta konsola tylko patrzy
const lockNote = (data: Data, mode: Mode) => {
  if (mode === 'sensors' && !data.can_sensors) {
    return data.has_station
      ? 'Sensorami steruje tylko stanowisko rozpoznania.'
      : 'Sensorami steruje tylko DRADIS mostka.';
  }
  if (mode === 'fire' && !data.can_fire) {
    return 'Strzela tylko strzelec przy konsoli taktycznej.';
  }
  return null;
};

export const TacticalScreen = (props) => {
  const { data } = useBackend<Data>();
  const available = MODES.filter(
    ([mode]) =>
      (mode !== 'sensors' || !!data.sensor) && (mode !== 'fire' || !!data.fire),
  );
  const [chosen, setChosen] = useState<Mode | null>(null);
  const start = available.some(([mode]) => mode === data.mode)
    ? data.mode
    : 'view';
  const mode =
    chosen && available.some(([value]) => value === chosen) ? chosen : start;
  const sensor = data.sensor && {
    ...data.sensor,
    readonly: !data.can_sensors,
    can_hail: data.can_pulse,
  };
  const fire = data.fire && {
    ...data.fire,
    readonly: !data.can_fire,
    can_hail: data.can_pulse && data.can_fire,
  };
  const note = lockNote(data, mode);
  let body;
  if (mode === 'sensors' && sensor) {
    body = (
      <SensorData.Provider value={sensor}>
        <SensorBody />
      </SensorData.Provider>
    );
  } else if (mode === 'fire' && fire) {
    body = (
      <FireData.Provider value={fire}>
        <FireBody />
      </FireData.Provider>
    );
  } else if (sensor) {
    // Podgląd: radar i kontakty z rozpoznania, a obok stan okrętu i uzbrojenia z konsoli taktycznej
    body = (
      <SensorData.Provider value={{ ...sensor, readonly: true }}>
        <SensorBody
          extra={
            fire ? (
              <FireData.Provider value={{ ...fire, readonly: true }}>
                <OwnShip />
                <LockBox locked>
                  <Weapons />
                  <AmsPanel />
                </LockBox>
              </FireData.Provider>
            ) : (
              <Box style={{ padding: '10px', color: COLOR.muted }}>
                Okręt nie ma konsoli taktycznej z kontrolą ognia.
              </Box>
            )
          }
        />
      </SensorData.Provider>
    );
  } else if (fire) {
    body = (
      <FireData.Provider value={{ ...fire, readonly: true }}>
        <FireBody />
      </FireData.Provider>
    );
  } else {
    body = (
      <Box style={{ padding: '16px', color: COLOR.muted }}>
        Brak połączenia z sensorami i uzbrojeniem okrętu.
      </Box>
    );
  }
  return (
    <Window width={1140} height={780}>
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
          <Box
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 10px',
              borderBottom: '1px solid ' + COLOR.line,
              background: COLOR.panel,
              flexWrap: 'wrap',
            }}
          >
            <b style={{ letterSpacing: '0.06em', marginRight: '8px' }}>
              {data.ship_name}
            </b>
            {available.map(([value, label]) => (
              <Button
                key={value}
                selected={value === mode}
                onClick={() => setChosen(value)}
              >
                {label}
              </Button>
            ))}
            <PulseButton />
            <span
              style={{
                marginLeft: 'auto',
                color: note ? COLOR.warn : COLOR.muted,
                fontSize: '12px',
              }}
            >
              {note || data.console}
            </span>
          </Box>
          <Box style={{ flex: 1, minHeight: 0 }}>{body}</Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
