// AQUILA - okno „Odzysk i abordaż”: zakłócacz EWAR (nsv13/code/game/machinery/computer/salvage.dm) i magnes
// na asteroidy (aquila/code/modules/mining/mineral_magnet_ui.dm) w jednym oknie z dwiema zakładkami.
// Dane i akcje drugiej zakładki przekazuje konsola: aquila/code/modules/overmap/consoles/salvage_console.dm.
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

type Tab = 'boarding' | 'magnet';

type Ship = {
  name: string;
  desc: string;
  id: string;
};

type Boarding = {
  salvage_target: string | null;
  salvage_target_name: string;
  salvage_target_integrity: number;
  salvage_target_max_integrity: number;
  ships: Ship[];
};

type Asteroid = {
  name: string;
  ref: string;
  ores: string[];
};

type Wreck = {
  name: string;
  ref: string;
};

type Magnet = {
  has_cage: boolean;
  cooldown: boolean;
  has_asteroid: boolean;
  has_wreck: boolean;
  wreck_name: string | null;
  wreck_health: number | null;
  asteroids: Asteroid[];
  wrecks: Wreck[];
};

type Data = {
  default_tab: Tab;
  boarding_present: boolean;
  boarding_access: boolean;
  boarding: Boarding | null;
  magnet_present: boolean;
  magnet_access: boolean;
  magnet: Magnet | null;
};

/** Dopisek pod zakładkami (brak dostępu, ładowanie magnesu) */
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

/** Wiersz listy: nazwa i opis po lewej, przycisk po prawej */
const ListRow = (props: {
  name: string;
  detail?: string;
  children: ReactNode;
}) => (
  <Box
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
      padding: '5px 0',
      borderTop: '1px solid ' + COLOR.line,
    }}
  >
    <Box style={{ flex: 1, minWidth: 0 }}>
      <div style={{ color: COLOR.ink, fontWeight: 600 }}>{props.name}</div>
      {!!props.detail && (
        <div style={{ color: COLOR.muted, fontSize: '12px' }}>
          {props.detail}
        </div>
      )}
    </Box>
    {props.children}
  </Box>
);

const BoardingTab = () => {
  const { act, data } = useBackend<Data>();
  const { boarding_present, boarding_access, boarding } = data;
  if (!boarding_present || !boarding) {
    return (
      <ConsolePanel title="Cele abordażu">
        <ConsoleEmpty>Okręt nie ma zakłócacza telemetrii EWAR.</ConsoleEmpty>
      </ConsolePanel>
    );
  }
  const ships = boarding.ships || [];
  const integrity =
    boarding.salvage_target_integrity /
    (boarding.salvage_target_max_integrity || 1);
  return (
    <>
      {!boarding_access && (
        <Notice>Brak dostępu: zakładka tylko do podglądu.</Notice>
      )}
      <ConsolePanel
        title="Obecnie utrzymywany cel"
        right={
          !!boarding.salvage_target && (
            <Button
              icon="bullseye"
              color="average"
              disabled={!boarding_access}
              tooltip="Przestań zakłócać obronę tego statku. Wszystkie siły, które dokonują na nim abordażu, zginą."
              onClick={() => act('stop_salvage')}
            >
              Zwolnij Hammerlock
            </Button>
          )
        }
      >
        {boarding.salvage_target ? (
          <>
            <ConsoleRow label="Cel">{boarding.salvage_target_name}</ConsoleRow>
            <ConsoleRow label="Integralność">
              <ConsoleMeter
                value={integrity}
                colour={
                  integrity >= 0.5
                    ? COLOR.good
                    : integrity >= 0.15
                      ? COLOR.warn
                      : COLOR.bad
                }
              />
            </ConsoleRow>
          </>
        ) : (
          <ConsoleEmpty>Brak utrzymywanego celu.</ConsoleEmpty>
        )}
      </ConsolePanel>
      <ConsolePanel
        title="Dostępne cele do złomowania"
        right={<span style={{ fontFamily: MONO }}>{ships.length}</span>}
      >
        {ships.length === 0 && (
          <ConsoleEmpty>
            W pobliżu nie ma okrętów, na które można wejść.
          </ConsoleEmpty>
        )}
        {ships.map((ship) => (
          <ListRow key={ship.id} name={ship.name} detail={ship.desc}>
            <Button
              icon="anchor"
              disabled={!boarding_access}
              onClick={() => act('salvage', { target: ship.id })}
            >
              Nawiąż Hammerlock
            </Button>
          </ListRow>
        ))}
      </ConsolePanel>
    </>
  );
};

const MagnetTab = () => {
  const { act, data } = useBackend<Data>();
  const { magnet_present, magnet_access, magnet } = data;
  if (!magnet_present || !magnet) {
    return (
      <ConsolePanel title="Magnes">
        <ConsoleEmpty>Okręt nie ma magnesu na asteroidy.</ConsoleEmpty>
      </ConsolePanel>
    );
  }
  if (!magnet.has_cage) {
    return (
      <ConsolePanel title="Magnes">
        <ConsoleEmpty>
          Magnes nie ma przypisanej klatki na asteroidy.
        </ConsoleEmpty>
      </ConsolePanel>
    );
  }
  const {
    cooldown,
    has_asteroid,
    has_wreck,
    wreck_name,
    wreck_health,
    asteroids = [],
    wrecks = [],
  } = magnet;
  const locked = !magnet_access || cooldown;
  return (
    <>
      {!magnet_access && (
        <Notice>Brak dostępu górnika: zakładka tylko do podglądu.</Notice>
      )}
      {!!cooldown && (
        <Notice>Obwody magnesu się ładują, poczekaj chwilę.</Notice>
      )}
      {has_wreck ? (
        <ConsolePanel title="Wrak w klatce">
          <Box mb={1}>
            {wreck_name}. Rozbierz go młotem i spawarką, a złom zanieś do
            recyklera.
          </Box>
          <ConsoleRow label="Zostało wraku">
            <ConsoleMeter value={(wreck_health ?? 0) / 100} />
          </ConsoleRow>
          <Box mt={1}>
            <Button.Confirm
              fluid
              icon="trash"
              color="bad"
              disabled={locked}
              confirmContent="Na pewno? Wszystko w klatce zniknie"
              onClick={() => act('push')}
            >
              Wypchnij wrak
            </Button.Confirm>
          </Box>
        </ConsolePanel>
      ) : has_asteroid ? (
        <ConsolePanel title="Asteroida w klatce">
          <Box mb={1}>
            Asteroida jest przyciągnięta. Zanim ją wypchniesz, upewnij się, że
            nikt nie został w klatce.
          </Box>
          <Button.Confirm
            fluid
            icon="meteor"
            color="bad"
            disabled={locked}
            confirmContent="Na pewno? Kliknij jeszcze raz"
            onClick={() => act('push')}
          >
            Wypchnij asteroidę
          </Button.Confirm>
        </ConsolePanel>
      ) : (
        <>
          <ConsolePanel
            title="Wraki w zasięgu"
            right={<span style={{ fontFamily: MONO }}>{wrecks.length}</span>}
          >
            {wrecks.length === 0 && (
              <ConsoleEmpty>
                W pobliżu nie ma wraków. Zostają po zestrzelonych okrętach.
              </ConsoleEmpty>
            )}
            {wrecks.map((wreck) => (
              <ListRow key={wreck.ref} name={wreck.name}>
                <Button
                  icon="magnet"
                  disabled={locked}
                  onClick={() => act('pull_wreck', { ref: wreck.ref })}
                >
                  Przyciągnij
                </Button>
              </ListRow>
            ))}
          </ConsolePanel>
          <ConsolePanel
            title="Asteroidy w zasięgu"
            right={<span style={{ fontFamily: MONO }}>{asteroids.length}</span>}
          >
            {asteroids.length === 0 && (
              <ConsoleEmpty>
                W pobliżu statku nie ma asteroid. Podleć bliżej któregoś pola.
              </ConsoleEmpty>
            )}
            {asteroids.map((asteroid) => (
              <ListRow
                key={asteroid.ref}
                name={asteroid.name}
                detail={asteroid.ores.join(', ')}
              >
                <Button
                  icon="magnet"
                  disabled={locked}
                  onClick={() => act('pull', { ref: asteroid.ref })}
                >
                  Przyciągnij
                </Button>
              </ListRow>
            ))}
          </ConsolePanel>
        </>
      )}
    </>
  );
};

/** Stan magnesu krótko, do paska u góry: [napis, kolor] */
const magnetState = (data: Data): [string, string] => {
  const magnet = data.magnet;
  if (!data.magnet_present || !magnet || !magnet.has_cage) {
    return ['brak', COLOR.muted];
  }
  if (magnet.has_wreck) {
    return ['wrak w klatce', COLOR.warn];
  }
  if (magnet.has_asteroid) {
    return ['asteroida w klatce', COLOR.warn];
  }
  if (magnet.cooldown) {
    return ['ładowanie', COLOR.muted];
  }
  return ['gotowy', COLOR.good];
};

export const SalvageConsole = (_) => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState<Tab>(data.default_tab || 'boarding');
  const target = data.boarding?.salvage_target
    ? data.boarding.salvage_target_name
    : null;
  const [magnetText, magnetColour] = magnetState(data);
  return (
    <ConsoleWindow width={600} height={640} title="Odzysk i abordaż">
      <ConsoleBar>
        <span style={{ color: COLOR.muted }}>Cel abordażu:</span>
        <span
          style={{
            fontFamily: MONO,
            color: target ? COLOR.hostile : COLOR.ink2,
          }}
        >
          {target || 'brak'}
        </span>
        <span style={{ marginLeft: 'auto', color: COLOR.muted }}>Magnes:</span>
        <span style={{ fontFamily: MONO, color: magnetColour }}>
          {magnetText}
        </span>
      </ConsoleBar>
      <ConsoleTabs<Tab>
        tabs={[
          ['boarding', 'Cele abordażu'],
          ['magnet', 'Magnes'],
        ]}
        active={tab}
        onChange={setTab}
      />
      <ConsoleBody>
        {tab === 'boarding' ? <BoardingTab /> : <MagnetTab />}
      </ConsoleBody>
    </ConsoleWindow>
  );
};
