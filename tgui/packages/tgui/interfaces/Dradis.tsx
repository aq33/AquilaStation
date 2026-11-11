import { CSSProperties, useState } from 'react';
import { Box, Button, Knob, ProgressBar, Section } from 'tgui-core/components';

// NSV13
import { useBackend } from '../backend';
import { Map } from '../components';
import { Window } from '../layouts';

type Data = {
  can_radar_pulse: any;
  can_target: any;
  can_use_radar: any;
  dradis_targeting: any;
  focus_x: any;
  focus_y: any;
  pulse_delay: any;
  // AQ EDIT - sygnatura okrętu (aquila/code/modules/overmap/dradis_uncertainty.dm)
  sensor_signatures: any;
  own_signature: number;
  seen_from: number;
  seen_from_pulse: number;
  map_width: number;
  map_height: number;
  // AQ EDIT - konsola sensorów (aquila/code/modules/overmap/sensor_console.dm)
  sensor_station: boolean;
  sensor_mode: any;
  ships: any;
  showAnomalies: any;
  showAsteroids: any;
  showEnemies: any;
  showFriendlies: any;
  width_mod: any;
  zoom_factor: any;
  zoom_factor_max: any;
  zoom_factor_min: any;
};

export const DradisContent = (props) => {
  const { act, data } = useBackend<Data>();
  // Bumping the key remounts the map, which centers it on the ship again
  const [focusKey, setFocusKey] = useState(0);

  const drawShips = (ship) => {
    let borderType = '1px solid ' + ship.colour;
    let markerStyle: CSSProperties = {
      height: '1px',
      position: 'absolute',
      left: ship.x * scale_factor + 'px',
      bottom: ship.y * scale_factor + 'px',
      border: borderType,
      opacity: ship.opacity,
      transition: 'all 0.5s ease-out',
    };
    let markerType = 'star_marker' + '_' + ship.alignment;
    // AQ EDIT START - niepewne kontakty i źródło ostrzału (aquila/code/modules/overmap/dradis_uncertainty.dm)
    const uncertainty = ship.uncertainty || 0;
    const circleSize = uncertainty * 2 * scale_factor;
    const circleStyle: CSSProperties = {
      position: 'absolute',
      left: ship.x * scale_factor - circleSize / 2 + 'px',
      bottom: ship.y * scale_factor - circleSize / 2 + 'px',
      width: circleSize + 'px',
      height: circleSize + 'px',
      borderRadius: '50%',
      border: '1px dashed ' + ship.colour,
      color: ship.colour,
      opacity: ship.opacity,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: Math.max(10, circleSize / 3) + 'px',
      pointerEvents: 'none',
      transition: 'all 0.5s ease-out',
    };
    const emission = ship.emission;
    const tooltip = emission
      ? 'Emisja radaru: kierunek ' +
        emission.bearing +
        '°, odległość około ' +
        Math.round(emission.distance) +
        ' pól. Kolejne impulsy zawężają namiar.'
      : ship.ghost
        ? 'Źródło ostrzału: trafiono nas z tego kierunku, strzelca nie wykryto.'
        : uncertainty > 0
          ? 'Niepewny kontakt, pozycja przybliżona. Podejdź bliżej albo użyj radaru.'
          : undefined;
    // AQ EDIT - podpis zasłonięty przez ważniejszy kontakt pokazuje się dopiero po najechaniu
    const labelShown = shownLabels.has(ship);
    return (
      <li key={ship.id}>
        {uncertainty > 0 && (
          <div style={circleStyle}>{ship.ghost ? '!' : '?'}</div>
        )}
        {!!emission && drawEmission(emission, ship.colour, ship.opacity)}
        {!!ship.designation && drawDesignation(ship)}
        {/* AQ EDIT END */}
        {!!ship.name && (
          <Button
            style={markerStyle}
            className={markerType}
            content=""
            tooltip={
              labelShown
                ? tooltip
                : ship.name + (tooltip ? ' · ' + tooltip : '')
            }
            onClick={() => act('hail', { target: ship.id })}
          >
            <span className="star_label">
              {labelShown && <p>{ship.name}</p>}
            </span>
          </Button>
        )}
      </li>
    );
  };

  // AQ EDIT START - cel wyznaczony przez operatora sensorów (aquila/code/modules/overmap/sensor_console.dm)
  const drawDesignation = (ship) => {
    const primary = ship.designation === 'primary';
    return (
      <div
        style={{
          position: 'absolute',
          left: ship.x * scale_factor - 9 + 'px',
          bottom: ship.y * scale_factor - 9 + 'px',
          width: '18px',
          height: '18px',
          border: (primary ? '2px solid ' : '1px dashed ') + '#ffcc00',
          borderRadius: '3px',
          pointerEvents: 'none',
          transition: 'all 0.5s ease-out',
        }}
      >
        <span
          style={{
            position: 'absolute',
            bottom: '20px',
            left: '-20px',
            width: '60px',
            textAlign: 'center',
            fontSize: '9px',
            color: '#ffcc00',
          }}
        >
          {primary ? 'CEL GŁÓWNY' : 'CEL'}
        </span>
      </div>
    );
  };
  // AQ EDIT END

  // AQ EDIT START - wycinek emisji radaru: namiar od naszego okrętu, odległość przybliżona
  const drawEmission = (emission, colour, opacity) => {
    const half = emission.width / 2;
    const inner = Math.max(0, emission.distance - emission.spread);
    const outer = emission.distance + emission.spread;
    const steps = 8;
    const points: number[][] = [];
    const toPoint = (degrees, radius) => {
      const radians = (degrees * Math.PI) / 180;
      return [
        (focus_x + Math.sin(radians) * radius) * scale_factor,
        (focus_y + Math.cos(radians) * radius) * scale_factor,
      ];
    };
    for (let i = 0; i <= steps; i++) {
      points.push(
        toPoint(emission.bearing - half + (i * 2 * half) / steps, outer),
      );
    }
    for (let i = steps; i >= 0; i--) {
      points.push(
        toPoint(emission.bearing - half + (i * 2 * half) / steps, inner),
      );
    }
    const xs = points.map((point) => point[0]);
    const ys = points.map((point) => point[1]);
    const minX = Math.min(...xs);
    const maxY = Math.max(...ys);
    const width = Math.max(1, Math.max(...xs) - minX);
    const height = Math.max(1, maxY - Math.min(...ys));
    const polygon = points
      .map((point) => point[0] - minX + ',' + (maxY - point[1]))
      .join(' ');
    // The overmap wraps, but the view cannot scroll past its edges:
    // the part of the sector beyond an edge is drawn again on the far side
    const mapWidth = (data.map_width || 0) * scale_factor;
    const mapHeight = (data.map_height || 0) * scale_factor;
    const copies: number[][] = [];
    for (const dx of mapWidth ? [-mapWidth, 0, mapWidth] : [0]) {
      for (const dy of mapHeight ? [-mapHeight, 0, mapHeight] : [0]) {
        const left = minX + dx;
        const bottom = maxY - height + dy;
        const visible =
          (dx === 0 && dy === 0) ||
          (left + width > 0 &&
            left < mapWidth &&
            bottom + height > 0 &&
            bottom < mapHeight);
        if (visible) {
          copies.push([left, bottom]);
        }
      }
    }
    return copies.map(([left, bottom]) => (
      <svg
        key={left + '_' + bottom}
        width={width}
        height={height}
        style={{
          position: 'absolute',
          left: left + 'px',
          bottom: bottom + 'px',
          opacity: opacity,
          pointerEvents: 'none',
          overflow: 'visible',
          transition: 'opacity 0.5s ease-out',
        }}
      >
        <polygon
          points={polygon}
          fill={colour}
          fillOpacity={0.18}
          stroke={colour}
          strokeDasharray="4 3"
        />
      </svg>
    ));
  };
  // AQ EDIT END

  // AQ EDIT START - podpisy bez nakładania: przy wielu kontaktach w jednym miejscu nazwy zlewały się w nieczytelną plamę.
  // Pierwszeństwo: własny okręt, cele operatora, wrogowie, nierozpoznani, sojusznicy, asteroidy i anomalie.
  let shownLabels = new Set<any>();
  const labelPriority = (ship) => {
    if (ship.colour === '#00FFFF') {
      return 0;
    }
    if (ship.designation) {
      return 1;
    }
    if (ship.colour === '#FF0000') {
      return 2;
    }
    if (ship.colour === '#a66300') {
      return 3;
    }
    if (ship.colour === '#32CD32') {
      return 4;
    }
    return 5;
  };
  const pickLabels = (ships, scale) => {
    const placed: { x: number; y: number; w: number }[] = [];
    const shown = new Set<any>();
    const order = [...(ships || [])]
      .filter((ship) => !!ship.name)
      .sort((a, b) => labelPriority(a) - labelPriority(b));
    for (const ship of order) {
      const x = ship.x * scale;
      const y = ship.y * scale;
      const w = String(ship.name).length * 6.5;
      const blocked = placed.some(
        (other) =>
          Math.abs(other.x - x) < (other.w + w) / 2 + 4 &&
          Math.abs(other.y - y) < 13,
      );
      if (!blocked) {
        placed.push({ x: x, y: y, w: w });
        shown.add(ship);
      }
    }
    return shown;
  };
  // AQ EDIT END

  const DradisMap = (ships, zoom_factor, width_mod, focus_x, focus_y) => {
    let scale_factor = 5 * zoom_factor;
    shownLabels = pickLabels(ships, scale_factor); // AQ EDIT - podpisy bez nakładania
    let multiplier = 562.5 * zoom_factor;
    let rangeStyle = {
      left: focus_x * scale_factor + 'px',
      bottom: focus_y * scale_factor + 'px',
      width: width_mod * multiplier + 'px',
      height: width_mod * multiplier + 'px',
      marginBottom: -1 * ((width_mod * multiplier) / 2) + 'px',
      marginLeft: -1 * ((width_mod * multiplier) / 2) + 'px',
    };
    let ShipMap = ships.map(drawShips);
    return (
      <Map
        key={focusKey}
        initial_focus_x={focus_x}
        initial_focus_y={focus_y}
        initial_scale_factor={scale_factor}
        grid
      >
        {ShipMap}
        <div id="rangeCircle" style={rangeStyle} />
      </Map>
    );
  };

  // Floats representing the different alpha values for different filtered objects.
  let showFriendlies = data.showFriendlies;
  let showEnemies = data.showEnemies;
  let showAsteroids = data.showAsteroids;
  let showAnomalies = data.showAnomalies;
  let focus_x = data.focus_x;
  let focus_y = data.focus_y;
  let zoom_factor = data.zoom_factor;
  let zoom_factor_min = data.zoom_factor_min;
  let zoom_factor_max = data.zoom_factor_max;
  let scale_factor = zoom_factor * 5;
  let dradis_targeting = data.dradis_targeting;
  let can_use_radar = data.can_use_radar;
  let dradis = DradisMap(
    data.ships,
    zoom_factor,
    data.width_mod,
    focus_x,
    focus_y,
  );

  return (
    <Section
      title="Ustawienia:"
      buttons={
        <>
          <Button icon="search-plus" onClick={() => act('zoomin')} />
          <Button icon="search-minus" onClick={() => act('zoomout')} />
          {/* AQ EDIT - przy konsoli sensorów radarem steruje operator */}
          {!!data.can_use_radar && !data.sensor_station && (
            <>
              <Button
                content="Impuls radaru"
                icon="bullseye"
                disabled={!data.can_radar_pulse}
                onClick={() => act('radar_pulse')}
              />
              <Button
                content={data.sensor_mode}
                icon="project-diagram"
                onClick={() => act('sensor_mode')}
              />
              <Button
                content={data.pulse_delay}
                icon="stopwatch"
                onClick={() => act('radar_delay')}
              />
            </>
          )}
          <Button
            content="Wyśrodkuj"
            icon="camera"
            onClick={() => setFocusKey(focusKey + 1)}
          />
          {!!data.can_target && (
            <Button
              content={dradis_targeting ? 'Celowanie' : 'Wywoływanie'}
              icon={dradis_targeting ? 'bullseye' : 'square-o'}
              disabled={!data.can_target}
              color={data.dradis_targeting ? 'bad' : 'good'}
              onClick={() => act('dradis_targeting')}
            />
          )}
        </>
      }
    >
      {/* AQ EDIT START - własna sygnatura okrętu */}
      {!!data.sensor_signatures && (
        <Box mb={1}>
          <ProgressBar
            value={Math.min(data.own_signature / 2, 1)}
            ranges={{
              good: [0, 0.45],
              average: [0.45, 0.7],
              bad: [0.7, 1],
            }}
          >
            {'Twoja sygnatura: ' +
              data.own_signature.toFixed(2).replace('.', ',') +
              ' · AI widzi cię z ~' +
              data.seen_from +
              ' pól (~' +
              data.seen_from_pulse +
              ', gdy pulsuje)'}
          </ProgressBar>
        </Box>
      )}
      {!!data.sensor_station && (
        <Box mb={1} color="label">
          Sensorami steruje stanowisko rozpoznania. Cele wyznaczone przez
          operatora mają żółtą ramkę.
        </Box>
      )}
      {/* AQ EDIT END */}
      Sojusznicy:
      <Knob
        tickWhileDragging
        inline
        mx={1}
        color={!!showFriendlies && 'green'}
        value={showFriendlies}
        unit="siła skanu"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onChange={(e, value) => act('showFriendlies', { alpha: value })}
      />
      Wrogowie:
      <Knob
        tickWhileDragging
        inline
        mx={1}
        color={!!showEnemies && 'green'}
        value={showEnemies}
        unit="siła skanu"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onChange={(e, value) => act('showEnemies', { alpha: value })}
      />
      Asteroidy:
      <Knob
        tickWhileDragging
        inline
        mx={1}
        color={!!showAsteroids && 'green'}
        value={showAsteroids}
        unit="siła skanu"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onChange={(e, value) => act('showAsteroids', { alpha: value })}
      />
      Anomalie:
      <Knob
        tickWhileDragging
        inline
        mx={1}
        color={!!showAnomalies && 'green'}
        value={showAnomalies}
        unit="siła skanu"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onChange={(e, value) => act('showAnomalies', { alpha: value })}
      />
      Przybliżenie:
      <Knob
        tickWhileDragging
        inline
        mx={1}
        color="green"
        value={zoom_factor * 100}
        unit="%"
        minValue={zoom_factor_min * 100}
        maxValue={zoom_factor_max * 100}
        step={1}
        stepPixelSize={1}
        onChange={(e, value) => act('setZoom', { zoom: value })}
      />
      {dradis}
    </Section>
  );
};

export const Dradis = (props) => {
  let content = DradisContent(props);

  return (
    <Window theme="hackerman" width={700} height={750}>
      <Window.Content scrollable>{content}</Window.Content>
    </Window>
  );
};
