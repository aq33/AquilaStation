import { CSSProperties } from 'react';
import { Box, Button } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

// NSV13
import { useBackend } from '../backend';
import { Map, StarButton } from '../components';
import { t } from '../i18n';
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
import { FTLDriveTab, type FtlTabData } from './FTLComputer';

type Position = {
  in_transit: BooleanLike;
  star_name?: string;
  star_id?: string;
  from_name?: string;
  from_id?: string;
  to_name?: string;
  to_id?: string;
  time_left?: number;
};

type Data = {
  alignment: any;
  can_cancel: any;
  can_control: BooleanLike;
  can_jump: any;
  current_sector: number;
  focus_x: any;
  focus_y: any;
  freepointer_cos: any;
  freepointer_sin: any;
  freepointer_x: any;
  freepointer_y: any;
  ftl?: FtlTabData;
  ftl_console: BooleanLike;
  ftl_goal: any;
  ftl_progress: any;
  ftl_safety_override: any;
  lines: any;
  position?: Position;
  scale_factor: any;
  screen: any;
  selected_name: string | null;
  star_dist: any;
  star_name: any;
  star_systems: any;
  travelling: any;
};

export const drawStarmap = (props, starCallback) => {
  const { act, data } = useBackend<Data>();
  const travelling = data.travelling;
  const scale_factor = typeof (data.scale_factor !== 'undefined')
    ? data.scale_factor
    : 12;
  const arrowStyle: CSSProperties = {
    position: 'absolute',
    left: data.freepointer_x * 12 + 'px',
    bottom: data.freepointer_y * 12 + 'px',
    transform: `matrix(${data.freepointer_cos}, ${-data.freepointer_sin}, ${data.freepointer_sin}, ${data.freepointer_cos}, 0, 0)`,
    transition: 'all 0.5s ease-out',
  };

  const drawSystemNodes = (System) => {
    let borderType = 'star_marker_outline_blue';
    let is_current = System.is_current;
    let in_range = System.in_range;
    {
      (!!is_current && (borderType = '1px solid #193a7a')) ||
        (borderType = in_range ? '1px solid #008000' : '1px solid #a30000');
    }
    let markerStyle: CSSProperties = {
      height: '1px',
      position: 'absolute',
      left: System.x * 12 + 'px',
      bottom: System.y * 12 + 'px',
      border: borderType,
    };
    let markerType = 'star_marker' + '_' + System.alignment;
    let distance = System.distance;
    let label = System.label;
    {
      !!label && (label = '|' + System.label);
    }
    return (
      <StarButton
        style={markerStyle}
        className={markerType}
        content=""
        tooltip={distance}
        onClick={() => starCallback(System)}
      >
        <span className="star_label">
          <p>
            {System.name} {label}
          </p>
        </span>
      </StarButton>
    );
  };

  const drawLines = (Line) => {
    // Css properties with hypens are auto-converted to camel case. Important!
    let lineStyle: CSSProperties = {
      height: '1px',
      position: 'absolute',
      left: Line.x * 12 + 'px',
      bottom: Line.y * 12 + 'px',
      width: Line.len * 12 + 'px',
      border: '0.5px solid ' + Line.colour,
      opacity: Line.opacity,
      transform: 'rotate(' + Line.angle + 'deg)',
      msTransform: 'rotate(' + Line.angle + 'deg)',
      transformOrigin: 'center left',
      zIndex: Line.priority,
    };
    return <div style={lineStyle} className="line" />;
  };

  let SystemNodes = data.star_systems
    .filter((system) => !system.hidden)
    .map(drawSystemNodes);
  let Connections = data.lines.map(drawLines);

  return (
    <Map
      initial_focus_x={data.focus_x}
      initial_focus_y={data.focus_y}
      initial_scale_factor={scale_factor}
    >
      <>
        {data.star_systems && SystemNodes}
        {data.lines && Connections}
        {!!travelling && (
          <span style={arrowStyle}>
            <i className="fa fa-arrow-right" />
          </span>
        )}
      </>
    </Map>
  );
};

// AQUILA: okno „Nawigacja i skok” (konsola nawigacji i stary komputer FTL) w wyglądzie konsol okrętu.
// Zakładka to ekran po stronie DM: 0 okręt, 1 mapa, 2 wybrany układ, 3 napęd FTL.
type Tab = '0' | '1' | '2' | '3';
const TAB_ACTIONS: Record<Tab, string> = {
  '0': 'shipinf',
  '1': 'map',
  '2': 'system',
  '3': 'ftl_tab',
};

/** Przycisk z nazwą układu, który otwiera jego zakładkę */
const StarLink = (props: { name?: string; id?: string }) => {
  const { act } = useBackend();
  if (!props.name) {
    return <span style={{ color: COLOR.muted }}>—</span>;
  }
  return (
    <Button
      compact
      icon="star"
      tooltip="Kliknij, żeby zobaczyć informacje o gwieździe"
      onClick={() => act('select_system', { star_id: props.id })}
    >
      {props.name}
    </Button>
  );
};

/** Pasek ładowania napędu */
const DriveMeter = (props: { width?: string }) => {
  const { data } = useBackend<Data>();
  const value = data.ftl_goal ? data.ftl_progress / data.ftl_goal : 0;
  return (
    <ConsoleMeter
      value={value}
      width={props.width}
      colour={
        value >= 0.95 ? COLOR.good : value >= 0.15 ? COLOR.warn : COLOR.bad
      }
    />
  );
};

const PositionRows = (props: { position: Position }) => {
  const { position } = props;
  if (position.in_transit) {
    return (
      <>
        <ConsoleRow label="W drodze z:">
          <StarLink name={position.from_name} id={position.from_id} />
        </ConsoleRow>
        <ConsoleRow label="Do:">
          <StarLink name={position.to_name} id={position.to_id} />
        </ConsoleRow>
        <ConsoleRow label="ETA:">
          {Math.round(position.time_left || 0) + ' min'}
        </ConsoleRow>
      </>
    );
  }
  return (
    <ConsoleRow label="Obecny układ:">
      <StarLink name={position.star_name} id={position.star_id} />
    </ConsoleRow>
  );
};

const ShipTab = () => {
  const { data } = useBackend<Data>();
  return (
    <>
      <ConsolePanel title="Położenie okrętu">
        <PositionRows position={data.position || { in_transit: false }} />
      </ConsolePanel>
      <ConsolePanel title="Stan napędu">
        <DriveMeter />
        <Box style={{ marginTop: '6px' }}>
          <ConsoleRow
            label="Bezpieczniki FTL:"
            colour={data.ftl_safety_override ? COLOR.bad : COLOR.good}
          >
            {data.ftl_safety_override ? t('nadpisane') : t('aktywne')}
          </ConsoleRow>
        </Box>
      </ConsolePanel>
    </>
  );
};

const MapTab = (props) => {
  const { act, data } = useBackend<Data>();
  if (!data.star_systems || !data.lines) {
    return (
      <ConsolePanel>
        <ConsoleEmpty>Brak danych mapy gwiezdnej.</ConsoleEmpty>
      </ConsolePanel>
    );
  }
  return (
    <ConsolePanel
      title="Mapa gwiezdna"
      right={
        <>
          <span style={{ color: COLOR.muted, marginRight: '8px' }}>
            Sektor {data.current_sector}
          </span>
          <Button compact icon="bullseye" onClick={() => act('sector')}>
            Zmień sektor
          </Button>
        </>
      }
    >
      {drawStarmap(props, (system) =>
        act('select_system', { star_id: system.star_id }),
      )}
    </ConsolePanel>
  );
};

const SystemTab = () => {
  const { act, data } = useBackend<Data>();
  if (!data.star_name) {
    return (
      <ConsolePanel>
        <ConsoleEmpty>Wybierz układ na mapie gwiezdnej.</ConsoleEmpty>
      </ConsolePanel>
    );
  }
  return (
    <>
      <ConsolePanel title={data.star_name}>
        <ConsoleRow label="Odległość:">
          {(data.star_dist || 0) + ' l.ś.'}
        </ConsoleRow>
        <ConsoleRow label="Przynależność:">
          {data.alignment ? data.alignment : t('Nieznana')}
        </ConsoleRow>
        <Box style={{ marginTop: '8px', display: 'flex', gap: '6px' }}>
          <Button
            icon="arrow-right"
            color={data.ftl_safety_override ? 'red' : 'default'}
            disabled={!data.can_jump}
            onClick={() => act('nav_jump')}
          >
            Skok
          </Button>
          <Button
            icon="stop-circle-o"
            disabled={!data.can_cancel}
            onClick={() => act('nav_cancel_jump')}
          >
            Anuluj skok
          </Button>
        </Box>
        {!data.can_control && (
          <Box style={{ color: COLOR.muted, marginTop: '6px' }}>
            Ta konsola tylko pokazuje mapę. Skok wykonuje się z konsoli
            nawigacji na mostku.
          </Box>
        )}
      </ConsolePanel>
      <ConsolePanel title="Stan napędu">
        <DriveMeter />
      </ConsolePanel>
    </>
  );
};

const StatusBar = () => {
  const { act, data } = useBackend<Data>();
  const position = data.position || { in_transit: false };
  return (
    <ConsoleBar>
      <span style={{ color: COLOR.muted }}>Położenie:</span>
      <span style={{ fontFamily: MONO }}>
        {position.in_transit
          ? (position.from_name || '?') +
            ' → ' +
            (position.to_name || '?') +
            ' (' +
            Math.round(position.time_left || 0) +
            ' min)'
          : position.star_name || '—'}
      </span>
      <span
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '6px',
          marginLeft: 'auto',
        }}
      >
        <span style={{ color: COLOR.muted }}>Napęd:</span>
        <DriveMeter width="150px" />
      </span>
      {!!data.ftl_safety_override && (
        <span style={{ color: COLOR.bad, fontWeight: 600 }}>
          NADPISANIE BEZPIECZNIKÓW FTL
        </span>
      )}
      {!!data.can_cancel && (
        <Button
          compact
          color="red"
          icon="stop-circle-o"
          onClick={() => act('nav_cancel_jump')}
        >
          Anuluj skok
        </Button>
      )}
    </ConsoleBar>
  );
};

export const Starmap = (props) => {
  const { act, data } = useBackend<Data>();
  const screen = String(data.screen ?? 1) as Tab;
  const ftl = data.ftl;
  const tabs: [Tab, string][] = [
    ['1', t('Mapa gwiezdna')],
    ['0', t('Okręt')],
    [
      '2',
      data.selected_name
        ? t('Układ') + ': ' + data.selected_name
        : t('Wybrany układ'),
    ],
  ];
  if (ftl) {
    tabs.push(['3', t('Napęd FTL')]);
  }

  return (
    <ConsoleWindow width={820} height={760} title="Nawigacja i skok">
      <StatusBar />
      <ConsoleTabs
        tabs={tabs}
        active={screen}
        onChange={(tab) => act(TAB_ACTIONS[tab])}
      />
      <ConsoleBody>
        {screen === '0' && <ShipTab />}
        {screen === '1' && <MapTab {...props} />}
        {screen === '2' && <SystemTab />}
        {screen === '3' && !!ftl && (
          <FTLDriveTab ftl={ftl} safetyOverride={!!data.ftl_safety_override} />
        )}
      </ConsoleBody>
    </ConsoleWindow>
  );
};
