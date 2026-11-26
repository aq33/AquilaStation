// AQUILA - okno DRADIS-ów ze specjalną funkcją (aquila/code/modules/overmap/dradis_window.dm): konsola dostaw
// ładunków, górniczy skaner asteroid i radar myśliwców. Wygląd ekranu taktycznego (TacticalScreen.tsx): okrągły
// radar, lista i karta kontaktu ze stanowiska rozpoznania (SensorBody), a obok panel funkcji tej konsoli.
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  card,
  COLOR,
  sectionTitle,
  SensorBody,
  type SensorConsoleData,
  SensorData,
} from './SensorConsole';

type Kind = 'cargo' | 'mining' | 'craft' | 'dradis';

type Data = SensorConsoleData & {
  kind: Kind;
  hail_range: number;
  sensor_range: number;
  mining_tier: number;
  show_asteroids: boolean;
  can_radar_pulse: boolean;
  can_use_radar: boolean;
  sensor_mode: string;
  pulse_delay: string;
  dradis_targeting: boolean;
  can_target: boolean;
};

const TITLE: Record<Kind, string> = {
  cargo: 'Dostawy ładunków',
  mining: 'Skaner asteroid',
  craft: 'Radar jednostki',
  dradis: 'DRADIS',
};

const Fact = (props: { label: string; children: string }) => (
  <div style={{ display: 'flex', gap: '8px', marginBottom: '4px' }}>
    <span style={{ color: COLOR.muted, minWidth: '130px' }}>{props.label}</span>
    <b>{props.children}</b>
  </div>
);

// Funkcja tej konsoli: dostawy, skaner asteroid, radar i namierzanie jednostki
const Functions = () => {
  const { act, data } = useBackend<Data>();
  const active = data.sensor_mode === 'Active Radar';
  const asteroids = (data.objects || []).filter(
    (thing) => thing.kind === 'asteroid',
  );
  return (
    <Box style={card}>
      <div style={sectionTitle}>{TITLE[data.kind]}</div>
      <Fact label="Zasięg sensorów">{data.sensor_range + ' pól'}</Fact>
      {data.kind === 'cargo' && (
        <Box style={{ color: COLOR.ink2, marginBottom: '6px' }}>
          Wybierz okręt na radarze albo na liście i użyj „Dostarcz ładunek”.
          Ładunek leci z wyrzutni ładowni połączonej z tą konsolą (multitool),
          do okrętów najwyżej {data.hail_range} pól stąd.
        </Box>
      )}
      {data.kind === 'mining' && (
        <>
          <Fact label="Poziom skanera">{String(data.mining_tier)}</Fact>
          <Fact label="Asteroidy w zasięgu">{String(asteroids.length)}</Fact>
          <Box style={{ color: COLOR.ink2, marginBottom: '6px' }}>
            Skaner pokazuje asteroidy do swojego poziomu. Wyższe pokaże po
            włożeniu ulepszenia skanera górniczego do konsoli.
          </Box>
        </>
      )}
      {!!data.can_use_radar && (
        <div
          style={{
            display: 'flex',
            gap: '6px',
            flexWrap: 'wrap',
            marginBottom: '6px',
          }}
        >
          <Button
            icon="satellite-dish"
            selected={active}
            tooltip="Aktywny radar widzi dalej, ale wrogowie słyszą okręt."
            onClick={() => act('sensor_mode')}
          >
            {active ? 'Aktywny radar' : 'Nasłuch'}
          </Button>
          <Button
            icon="broadcast-tower"
            disabled={!data.can_radar_pulse}
            onClick={() => act('radar_pulse')}
          >
            Impuls radaru
          </Button>
          <Button icon="stopwatch" onClick={() => act('radar_delay')}>
            {'Co ' + data.pulse_delay + ' s'}
          </Button>
        </div>
      )}
      {!!data.can_target && (
        <Button
          icon="bullseye"
          selected={!!data.dradis_targeting}
          tooltip="Gdy włączone, wybrany kontakt namierzasz zamiast go wywoływać."
          onClick={() => act('dradis_targeting')}
        >
          Namierzanie z radaru
        </Button>
      )}
    </Box>
  );
};

export const Dradis = (props) => {
  const { data } = useBackend<Data>();
  return (
    <Window width={1000} height={720}>
      <Window.Content
        style={{
          background: COLOR.bg,
          color: COLOR.ink,
          padding: 0,
          fontSize: '13px',
        }}
      >
        {data.contacts ? (
          <SensorData.Provider value={data}>
            <SensorBody bare extra={<Functions />} />
          </SensorData.Provider>
        ) : (
          <Box style={{ padding: '16px', color: COLOR.muted }}>
            Brak połączenia z okrętem.
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
