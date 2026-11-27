// AQUILA - okno „Lotnictwo”: konsola kontroli myśliwców (nsv13/code/modules/overmap/fighters/control_console.dm)
// i konsola katapult (nsv13/code/modules/overmap/fighters/fighters_launcher.dm) w jednym oknie z zakładkami
// „Telemetria” i „Katapulty”. Dane obu zakładek daje każda z konsol: aquila/code/modules/overmap/consoles/aviation_console.dm.
import { type ReactNode, useState } from 'react';
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
  ConsoleTabs,
  ConsoleWindow,
  MONO,
} from './common/ShipConsole';

type Tab = 'telemetry' | 'launchers';

type Fighter = {
  id: string;
  name: string;
  class: string;
  integrity: number;
  max_integrity: number;
  safeties: boolean;
  has_docking: boolean;
  docking_mode: boolean | null;
};

type FilterType = {
  class: string;
  visible: boolean;
};

type Launcher = {
  id: string;
  name: string;
  can_launch: boolean;
  mag_locked: string | null;
  pilot: string | null;
  pilot_id: string | null;
  msg_cooldown: boolean;
};

type Data = {
  default_tab: Tab;
  ship_name: string | null;
  can_control: boolean;
  fighters: Fighter[];
  filter_types: FilterType[];
  launchers_info: Launcher[];
};

/** Klucz filtra porównywany w DM; wyświetlamy go po polsku */
const OCCUPIED_FILTER = 'Only Occupied Ship';

/** Dopisek pod zakładkami (brak dostępu) */
const Notice = (props: { children: ReactNode }) => (
  <Box
    style={{
      padding: '6px 11px',
      borderBottom: '1px solid ' + COLOR.line,
      color: COLOR.warn,
    }}
  >
    {props.children}
  </Box>
);

/** Wartość na pasku stanu: szara etykieta i liczba czcionką o stałej szerokości */
const BarStat = (props: { label: ReactNode; children: ReactNode }) => (
  <span>
    <span style={{ color: COLOR.muted }}>{props.label}</span>{' '}
    <span style={{ fontFamily: MONO, color: COLOR.ink }}>{props.children}</span>
  </span>
);

const FilterLabel = (props: { filter: string }) =>
  props.filter === OCCUPIED_FILTER ? <>Tylko z pilotem</> : props.filter;

const Telemetry = (props: { data: Data }) => {
  const { act } = useBackend<Data>();
  const { can_control, fighters, filter_types } = props.data;
  return (
    <>
      {!can_control && (
        <Notice>
          Brak dostępu kontroli lotów: zakładka tylko do podglądu.
        </Notice>
      )}
      <ConsolePanel
        title="Polecenia dla wszystkich"
        right={
          <>
            <Button
              icon="bullseye"
              color="average"
              disabled={!can_control}
              onClick={() => act('global_toggle')}
            >
              Przełącz bezpieczniki broni wszystkim
            </Button>
            <Button
              icon="eject"
              color="bad"
              disabled={!can_control}
              onClick={() => act('global_eject')}
            >
              Katapultuj wszystkich pilotów
            </Button>
          </>
        }
      />
      <ConsolePanel title="Filtry">
        <Box style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
          {filter_types.map((filter) => (
            <Button
              key={filter.class}
              icon={filter.visible ? 'eye' : 'eye-slash'}
              selected={filter.visible}
              onClick={() => act('filter', { filter: filter.class })}
            >
              <FilterLabel filter={filter.class} />
            </Button>
          ))}
        </Box>
      </ConsolePanel>
      {fighters.length === 0 && (
        <ConsolePanel title="Myśliwce">
          <ConsoleEmpty>
            Brak myśliwców do pokazania (sprawdź filtry).
          </ConsoleEmpty>
        </ConsolePanel>
      )}
      {fighters.map((fighter) => (
        <ConsolePanel
          key={fighter.id}
          title={fighter.name}
          right={<span style={{ color: COLOR.muted }}>{fighter.class}</span>}
        >
          <ConsoleRow label="Kadłub">
            <ConsoleMeter
              value={
                fighter.max_integrity
                  ? fighter.integrity / fighter.max_integrity
                  : 0
              }
              label={
                Math.round(fighter.integrity) +
                ' / ' +
                Math.round(fighter.max_integrity)
              }
            />
          </ConsoleRow>
          <ConsoleRow
            label="Bezpieczniki broni"
            colour={fighter.safeties ? COLOR.good : COLOR.bad}
          >
            {fighter.safeties ? <>włączone</> : <>wyłączone</>}
          </ConsoleRow>
          <ConsoleRow
            label="Tryb dokowania"
            colour={
              !fighter.has_docking
                ? COLOR.muted
                : fighter.docking_mode
                  ? COLOR.good
                  : COLOR.ink2
            }
          >
            {!fighter.has_docking ? (
              <>brak komputera dokowania</>
            ) : fighter.docking_mode ? (
              <>włączony</>
            ) : (
              <>wyłączony</>
            )}
          </ConsoleRow>
          <Box
            style={{
              display: 'flex',
              flexWrap: 'wrap',
              gap: '4px',
              marginTop: '6px',
            }}
          >
            <Button
              icon="eject"
              color="average"
              disabled={!can_control}
              onClick={() => act('eject', { id: fighter.id })}
            >
              Katapultuj pilota
            </Button>
            <Button
              icon="bullseye"
              selected={fighter.safeties}
              disabled={!can_control}
              onClick={() => act('toggle_safeties', { id: fighter.id })}
            >
              Przełącz bezpieczniki
            </Button>
            <Button
              icon="anchor"
              selected={!!fighter.docking_mode}
              disabled={!can_control || !fighter.has_docking}
              onClick={() => act('toggle_docking', { id: fighter.id })}
            >
              Przełącz dokowanie
            </Button>
          </Box>
        </ConsolePanel>
      ))}
    </>
  );
};

const Launchers = (props: { data: Data }) => {
  const { act } = useBackend<Data>();
  const { launchers_info } = props.data;
  if (launchers_info.length === 0) {
    return (
      <ConsolePanel title="Katapulty">
        <ConsoleEmpty>Brak katapult podłączonych do tej konsoli.</ConsoleEmpty>
      </ConsolePanel>
    );
  }
  return (
    <>
      {launchers_info.map((launcher) => (
        <ConsolePanel
          key={launcher.id}
          title={launcher.name}
          right={
            launcher.can_launch ? (
              <span style={{ color: COLOR.good }}>Gotowa</span>
            ) : (
              <span style={{ color: COLOR.warn }}>Ładowanie</span>
            )
          }
        >
          <ConsoleRow
            label="Na haku"
            colour={launcher.mag_locked ? COLOR.ink : COLOR.muted}
          >
            {launcher.mag_locked || <>pusto</>}
          </ConsoleRow>
          {!!launcher.mag_locked && (
            <ConsoleRow
              label="Pilot"
              colour={launcher.pilot ? COLOR.ink : COLOR.muted}
            >
              {launcher.pilot || <>brak pilota</>}
            </ConsoleRow>
          )}
          {!!(launcher.mag_locked || launcher.pilot_id) && (
            <Box
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '4px',
                marginTop: '6px',
              }}
            >
              {!!launcher.mag_locked && (
                <>
                  <Button
                    icon="arrow-right"
                    color="good"
                    disabled={!launcher.can_launch}
                    onClick={() => act('launch', { id: launcher.id })}
                  >
                    Wystrzel
                  </Button>
                  <Button
                    icon="eject"
                    color="average"
                    onClick={() => act('release', { id: launcher.id })}
                  >
                    Zwolnij z haka
                  </Button>
                </>
              )}
              {!!launcher.pilot_id && (
                <Button
                  icon="comments"
                  disabled={!launcher.msg_cooldown}
                  onClick={() =>
                    act('message', { pilot_id: launcher.pilot_id })
                  }
                >
                  Wiadomość do pilota
                </Button>
              )}
            </Box>
          )}
        </ConsolePanel>
      ))}
    </>
  );
};

export const AviationConsole = (props) => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState<Tab>(data.default_tab || 'telemetry');
  const fighters = data.fighters || [];
  const launchers = data.launchers_info || [];
  const safe = {
    ...data,
    fighters,
    launchers_info: launchers,
    filter_types: data.filter_types || [],
  };
  return (
    <ConsoleWindow width={600} height={640} title="Lotnictwo">
      <ConsoleBar>
        <BarStat label="Okręt:">{data.ship_name || <>brak</>}</BarStat>
        <BarStat label="Myśliwce:">{fighters.length}</BarStat>
        <BarStat label="Katapulty:">{launchers.length}</BarStat>
      </ConsoleBar>
      <ConsoleTabs<Tab>
        tabs={[
          ['telemetry', <>Telemetria</>],
          ['launchers', <>Katapulty</>],
        ]}
        active={tab}
        onChange={setTab}
      />
      <ConsoleBody>
        {tab === 'telemetry' ? (
          <Telemetry data={safe} />
        ) : (
          <Launchers data={safe} />
        )}
      </ConsoleBody>
    </ConsoleWindow>
  );
};
