// AQUILA: wygląd konsol okrętu (common/ShipConsole.tsx), dane i akcje bez zmian
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  COLOR,
  ConsoleBar,
  ConsoleBody,
  ConsoleEmpty,
  ConsoleMeter,
  ConsolePanel,
  ConsoleRow,
  ConsoleWindow,
  MONO,
} from './common/ShipConsole';
import { FtlCalibration } from './FtlCalibration'; // AQ EDIT - kalibracja pylonów

type Data = {
  auto_spool_enabled: any;
  await_emergency_ftl_confirm: any;
  can_auto_spool: any;
  goal: any;
  jumping: any;
  powered: any;
  progress: any;
  pylons: any;
};

// AQUILA: PYLON_STATE_* z DM to klucze, tłumaczymy tylko napis
const PYLON_STATUS_NAMES: Record<string, string> = {
  offline: 'wyłączony',
  shutdown: 'zatrzymany',
  starting: 'uruchamianie',
  warmup: 'rozgrzewanie',
  spooling: 'rozkręcanie',
  active: 'aktywny',
};

/** Kolor paska żyroskopu i kondensatora: dobry od 1, średni od 0,5 */
const gaugeColour = (value: number) =>
  value >= 1 ? COLOR.good : value >= 0.5 ? COLOR.warn : COLOR.bad;

const Pylon = (props: { pylon: any }) => {
  const { act } = useBackend<Data>();
  const { pylon } = props;
  const statusColour =
    pylon.status === 'shutdown'
      ? COLOR.warn
      : pylon.status === 'offline'
        ? COLOR.bad
        : COLOR.good;
  return (
    <Box
      style={{
        border: '1px solid ' + COLOR.line,
        borderRadius: '4px',
        background: COLOR.panel,
        padding: '8px 10px',
      }}
    >
      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          marginBottom: '6px',
        }}
      >
        <b style={{ color: COLOR.ink }}>{pylon.name}</b>
        <span
          style={{ marginLeft: 'auto', fontFamily: MONO, color: statusColour }}
        >
          {PYLON_STATUS_NAMES[pylon.status] || pylon.status}
        </span>
      </Box>
      <ConsoleRow label="Prędkość żyroskopu">
        <ConsoleMeter value={pylon.gyro} colour={gaugeColour(pylon.gyro)} />
      </ConsoleRow>
      <ConsoleRow label="Ładunek kondensatora">
        <ConsoleMeter
          value={pylon.capacitor}
          colour={gaugeColour(pylon.capacitor)}
        />
      </ConsoleRow>
      <ConsoleRow label="Pobór mocy">{pylon.draw}</ConsoleRow>
      <ConsoleRow label="Nucleium">{pylon.nucleium + ' mol/s'}</ConsoleRow>
      <Box mt={1}>
        <Button
          icon="power-off"
          color={
            pylon.status === 'shutdown'
              ? 'average'
              : pylon.status === 'offline'
                ? 'bad'
                : 'good'
          }
          disabled={pylon.status === 'shutdown'}
          onClick={() => act('pylon_power', { id: pylon.id })}
        >
          Przełącz zasilanie
        </Button>
        <Button
          icon="exclamation-triangle"
          color={pylon.shielded && 'average'}
          onClick={() => act('toggle_shield', { id: pylon.id })}
        >
          {pylon.shielded ? 'Otwórz osłonę' : 'Zamknij osłonę'}
        </Button>
      </Box>
    </Box>
  );
};

export const FTLComputerModular = (props) => {
  const { act, data } = useBackend<Data>();
  const pylons = data.pylons || [];
  const spool = data.goal ? data.progress / data.goal : 0;
  return (
    <ConsoleWindow width={600} height={760}>
      <ConsoleBar>
        <span style={{ color: COLOR.muted }}>Napęd FTL:</span>
        <span
          style={{
            fontFamily: MONO,
            color: data.powered ? COLOR.good : COLOR.ink2,
          }}
        >
          {data.jumping ? 'skok' : data.powered ? 'włączony' : 'wyłączony'}
        </span>
        <span style={{ marginLeft: 'auto', color: COLOR.muted }}>
          Rozkręcanie FTL
        </span>
        <ConsoleMeter
          value={spool}
          width="180px"
          colour={
            spool >= 0.95 ? COLOR.good : spool >= 0.15 ? COLOR.warn : COLOR.bad
          }
        />
      </ConsoleBar>
      <ConsoleBody>
        {data.await_emergency_ftl_confirm ? (
          <ConsolePanel
            title={<span style={{ color: COLOR.bad }}>NADPISANIE</span>}
          >
            <Button
              icon="exclamation-triangle"
              fluid
              color="red"
              onClick={() => act('emergency_jump')}
            >
              POTWIERDZIĆ SKOK AWARYJNY?
            </Button>
          </ConsolePanel>
        ) : (
          <>
            <ConsolePanel title="Sterowanie kolektorem">
              <Button
                color={!!data.powered && 'green'}
                disabled={data.jumping || !pylons.length}
                onClick={() => act('toggle_power')}
              >
                {data.progress ? 'Wyłącz napęd' : 'Rozkręć napęd'}
              </Button>
              <Button
                color={!!data.auto_spool_enabled && 'green'}
                disabled={!data.can_auto_spool}
                onClick={() => act('toggle_autospool')}
              >
                {data.auto_spool_enabled
                  ? 'Wyłącz autorozkręcanie'
                  : 'Włącz autorozkręcanie'}
              </Button>
            </ConsolePanel>
            <ConsolePanel
              title="Sterowanie pylonami"
              right={
                <Button icon="search" onClick={() => act('find_pylons')}>
                  Znajdź pylony
                </Button>
              }
            >
              {!pylons.length && (
                <ConsoleEmpty>Konsola nie widzi pylonów napędu.</ConsoleEmpty>
              )}
              <Box
                style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}
              >
                {pylons.map((pylon) => (
                  <Pylon key={pylon.id} pylon={pylon} />
                ))}
              </Box>
            </ConsolePanel>
            <FtlCalibration />
            {/* AQ EDIT - kalibracja pylonów (FtlCalibration.tsx) */}
          </>
        )}
      </ConsoleBody>
    </ConsoleWindow>
  );
};
