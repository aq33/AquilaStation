import { CSSProperties } from 'react';
import { Button, ProgressBar, Section } from 'tgui-core/components';

// NSV13
import { useBackend } from '../backend';
import { Map, StarButton } from '../components';
import { Window } from '../layouts';

type Data = {
  alignment: any;
  can_cancel: any;
  can_jump: any;
  focus_x: any;
  focus_y: any;
  freepointer_cos: any;
  freepointer_sin: any;
  freepointer_x: any;
  freepointer_y: any;
  from_star_id: any;
  from_star_name: any;
  ftl_goal: any;
  ftl_progress: any;
  ftl_safety_override: any;
  in_transit: any;
  lines: any;
  scale_factor: any;
  screen: any;
  star_dist: any;
  star_id: any;
  star_name: any;
  star_systems: any;
  time_left: any;
  to_star_id: any;
  to_star_name: any;
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

export const Starmap = (props) => {
  const { act, data } = useBackend<Data>();
  const screen = data.screen;
  const can_cancel = data.can_cancel;

  const handleSystemAction = (system) =>
    act('select_system', { star_id: system.star_id });

  return (
    <Window theme="ntos" width={800} height={660}>
      <Window.Content scrollable>
        <Section>
          {screen === 0 && (
            <>
              <Button
                content="Informacje o statku"
                icon="info-circle"
                onClick={() => act('shipinf')}
              />
              <Button
                content="Pokaż mapę"
                icon="map"
                onClick={() => act('map')}
              />
              <Section title="Stan napędu:">
                <ProgressBar
                  value={(data.ftl_progress / data.ftl_goal) * 100 * 0.01}
                  ranges={{
                    good: [0.95, Infinity],
                    average: [0.15, 0.9],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
              {(!!data.in_transit && (
                <Section title="Obecny układ:">
                  W drodze z:
                  <Button
                    content={data.from_star_name}
                    tooltip="Kliknij, żeby zobaczyć informacje o gwieździe"
                    icon="star"
                    onClick={() =>
                      act('select_system', { star_id: data.from_star_id })
                    }
                  />
                  Do:
                  <Button
                    content={data.to_star_name}
                    tooltip="Kliknij, żeby zobaczyć informacje o gwieździe"
                    icon="star"
                    onClick={() =>
                      act('select_system', { star_id: data.to_star_id })
                    }
                  />
                  ETA: {Math.round(data.time_left)}
                </Section>
              )) || (
                <Section title="Obecny układ:">
                  <Button
                    content={data.star_name}
                    tooltip="Kliknij, żeby zobaczyć informacje o gwieździe"
                    icon="star"
                    onClick={() => act('star_id', { star_id: data.star_id })}
                  />
                </Section>
              )}
            </>
          )}
          {screen === 1 && (
            <>
              <Button
                content="Informacje o statku"
                icon="info-circle"
                onClick={() => act('shipinf')}
              />
              <Button
                content="Pokaż mapę"
                icon="map"
                onClick={() => act('map')}
              />
              <Button
                content="Zmień sektor"
                icon="bullseye"
                onClick={() => act('sector')}
              />
            </>
          )}
          {screen === 1 && drawStarmap(props, handleSystemAction)}
          {screen === 2 && (
            <>
              <Button
                content="Informacje o statku"
                icon="info-circle"
                onClick={() => act('shipinf')}
              />
              <Button
                content="Pokaż mapę"
                icon="map"
                onClick={() => act('map')}
              />
              <Section title={data.star_name}>
                Odległość: {data.star_dist ? data.star_dist + ' ly' : '0 ly'}
                <br />
                Przynależność: {data.alignment ? data.alignment : 'Nieznana'}
                <br />
                <Button
                  content="Skok"
                  icon="arrow-right"
                  color={data.ftl_safety_override ? 'red' : 'default'}
                  disabled={!data.can_jump}
                  onClick={() => act('jump')}
                />
                <Button
                  content="Anuluj skok"
                  icon="stop-circle-o"
                  disabled={!can_cancel}
                  onClick={() => act('cancel_jump')}
                />
              </Section>
              <Section title="Stan napędu:">
                <ProgressBar
                  value={(data.ftl_progress / data.ftl_goal) * 100 * 0.01}
                  ranges={{
                    good: [0.95, Infinity],
                    average: [0.15, 0.9],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
