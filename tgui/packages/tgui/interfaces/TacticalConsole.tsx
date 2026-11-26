// NSV13
// AQUILA: wygląd konsol okrętu (common/ShipConsole.tsx), dane i akcje bez zmian

import { Fragment } from 'react';
import { Box, Button, NumberInput } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
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

type Data = {
  additional_weapon_info: any;
  armour_integrity: any;
  has_quadrant: any;
  integrity: any;
  max_armour_integrity: any;
  max_integrity: any;
  modifying_weapon_priorities: any;
  no_gun_cam: any;
  painted_targets: any;
  quadrant_ap_armour_current: any;
  quadrant_ap_armour_max: any;
  quadrant_as_armour_current: any;
  quadrant_as_armour_max: any;
  quadrant_fp_armour_current: any;
  quadrant_fp_armour_max: any;
  quadrant_fs_armour_current: any;
  quadrant_fs_armour_max: any;
  target_name: any;
  weapons: any;
  // AQ EDIT - cele od operatora sensorów (aquila/code/modules/overmap/sensor_console.dm)
  sensor_station: boolean;
  designated_targets: {
    id: string;
    name: string;
    designation: string;
    distance: number;
    bearing: number;
    painted: boolean;
    locked: boolean;
  }[];
};

/** Kolor paska: dobry od progu good, średni od avg */
const levelColour = (value: number, good: number, avg: number) =>
  value >= good ? COLOR.good : value >= avg ? COLOR.warn : COLOR.bad;

/** Pasek integralności lub pancerza; bez maksimum pokazuje pusty */
const Level = (props: {
  current: number;
  max: number;
  good: number;
  avg: number;
}) => {
  const value = props.max ? props.current / props.max : 0;
  return (
    <ConsoleMeter
      value={value}
      colour={levelColour(value, props.good, props.avg)}
    />
  );
};

/** Pancerz ćwiartek: f/a = dziób/rufa, p/s = lewa/prawa burta */
const QUADRANTS: [string, string][] = [
  ['fp', 'Dziób, lewa burta'],
  ['fs', 'Dziób, prawa burta'],
  ['ap', 'Rufa, lewa burta'],
  ['as', 'Rufa, prawa burta'],
];

const listRow = {
  padding: '6px 0',
  borderTop: '1px solid ' + COLOR.line,
};

export const TacticalConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const [current, setCurrent] = useLocalState('fs_current', true);
  const [hidden, setHidden] = useLocalState('fs_hidden', true);
  const hull = data.max_integrity ? data.integrity / data.max_integrity : 0;
  const designated = data.designated_targets || [];
  return (
    <ConsoleWindow width={560} height={600}>
      <ConsoleBar>
        <span style={{ color: COLOR.muted }}>Cel:</span>
        <span
          style={{
            fontFamily: MONO,
            color: data.target_name ? COLOR.hostile : COLOR.ink2,
          }}
        >
          {data.target_name || 'brak'}
        </span>
        <span style={{ marginLeft: 'auto', color: COLOR.muted }}>Kadłub</span>
        <ConsoleMeter
          value={hull}
          width="160px"
          colour={levelColour(hull, 0.95, 0.15)}
        />
      </ConsoleBar>
      <ConsoleBody>
        <ConsolePanel title="Stan statku">
          <ConsoleRow label="Integralność kadłuba">
            <Level
              current={data.integrity}
              max={data.max_integrity}
              good={0.95}
              avg={0.15}
            />
          </ConsoleRow>
          {data.has_quadrant ? (
            QUADRANTS.map(([key, name]) => (
              <ConsoleRow key={key} label={name}>
                <Level
                  current={data['quadrant_' + key + '_armour_current']}
                  max={data['quadrant_' + key + '_armour_max']}
                  good={0.66}
                  avg={0.33}
                />
              </ConsoleRow>
            ))
          ) : (
            <ConsoleRow label="Pancerz">
              <Level
                current={data.armour_integrity}
                max={data.max_armour_integrity}
                good={0.9}
                avg={0.15}
              />
            </ConsoleRow>
          )}
        </ConsolePanel>
        <ConsolePanel
          title="Uzbrojenie"
          right={
            <>
              <Button
                icon="cog"
                color={data.additional_weapon_info ? 'good' : 'default'}
                content="Więcej informacji"
                onClick={() => act('toggle_additional_weapon_info')}
              />
              <Button
                icon="wrench"
                color={data.modifying_weapon_priorities ? 'blue' : 'grey'}
                disabled={!data.additional_weapon_info}
                onClick={() => act('toggle_weapon_priority_modification')}
              />
            </>
          }
        >
          {Object.keys(data.weapons).map((key) => {
            let value = data.weapons[key];
            return (
              <Fragment key={key}>
                {!!value.maxammo && (
                  <Box style={listRow}>
                    <ConsoleRow label={value.name}>
                      <Level
                        current={value.ammo}
                        max={value.maxammo}
                        good={0.95}
                        avg={0.15}
                      />
                    </ConsoleRow>
                    {!!data.additional_weapon_info &&
                      ((!!data.modifying_weapon_priorities &&
                        !!value.can_modify_priority && (
                          <ConsoleRow label="Priorytet">
                            <NumberInput
                              step={1}
                              value={value.weapon_priority}
                              width="47px"
                              minValue={1}
                              maxValue={900}
                              onChange={(input_number) =>
                                act('change_weapon_priority', {
                                  target_weapon: value.weapon_ref,
                                  new_priority: input_number,
                                })
                              }
                            />
                          </ConsoleRow>
                        )) || (
                        <ConsoleRow label="Priorytet">
                          {value.weapon_priority}
                        </ConsoleRow>
                      ))}
                    {!!value.controllers && (
                      <ConsoleRow label="Kontrolery broni">
                        {value.controllers}
                      </ConsoleRow>
                    )}
                    {!!value.ammo_filter && (
                      <ConsoleRow label="Filtr amunicji">
                        {value.ammo_filter}
                      </ConsoleRow>
                    )}
                  </Box>
                )}
              </Fragment>
            );
          })}
        </ConsolePanel>
        {/* AQ EDIT START - cele od operatora sensorów (aquila/code/modules/overmap/sensor_console.dm) */}
        {!!data.sensor_station && (
          <ConsolePanel title="Cele od operatora rozpoznania">
            {designated.length === 0 && <ConsoleEmpty>brak</ConsoleEmpty>}
            {designated.map((target) => (
              <Box
                key={target.id}
                style={{
                  ...listRow,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                }}
              >
                <Box style={{ flex: 1, minWidth: 0 }}>
                  <span
                    style={{
                      fontWeight: target.designation === 'primary' ? 700 : 400,
                      color:
                        target.designation === 'primary'
                          ? COLOR.desig
                          : COLOR.desig2,
                    }}
                  >
                    {target.name}
                  </span>
                  <span style={{ color: COLOR.muted }}>
                    {' · ' +
                      (target.designation === 'primary'
                        ? 'cel główny'
                        : 'drugorzędny') +
                      ' · '}
                  </span>
                  <span style={{ fontFamily: MONO, color: COLOR.ink2 }}>
                    {target.distance + ' pól · namiar ' + target.bearing + '°'}
                  </span>
                </Box>
                {target.locked ? (
                  <span style={{ color: COLOR.bad }}>namierzony</span>
                ) : (
                  <Button
                    icon="crosshairs"
                    tooltip={
                      target.painted
                        ? 'Cel jest oznaczony, ustaw go jako cel ognia.'
                        : 'Rozpocznij namierzanie celu.'
                    }
                    onClick={() => act('lock_designated', { id: target.id })}
                  >
                    {target.painted ? 'Wybierz' : 'Namierz'}
                  </Button>
                )}
              </Box>
            ))}
          </ConsolePanel>
        )}
        {/* AQ EDIT END */}
        <ConsolePanel title="Śledzenie">
          {!data.no_gun_cam && (
            <Button
              width="100%"
              fluid
              content={'Przełącz kamerę działa'}
              icon="bullseye"
              onClick={() => act('toggle_gun_camera')}
            />
          )}
          {Object.keys(data.painted_targets).map((key) => {
            let value = data.painted_targets[key];
            return (
              <Fragment key={key}>
                {!!value.name && (
                  <Box style={listRow}>
                    <Button
                      width="100%"
                      fluid
                      onClick={() => {
                        setCurrent(value.name);
                        setHidden(!hidden);
                      }}
                    >
                      {`${value.name}`}
                    </Button>
                    {!!(current === value.name) && !hidden && (
                      <Box mt={0.5}>
                        {QUADRANTS.map(([quadrant, name]) => (
                          <ConsoleRow key={quadrant} label={name}>
                            <Level
                              current={
                                value[
                                  'quadrant_' + quadrant + '_armour_current'
                                ]
                              }
                              max={
                                value['quadrant_' + quadrant + '_armour_max']
                              }
                              good={0.95}
                              avg={0.15}
                            />
                          </ConsoleRow>
                        ))}
                      </Box>
                    )}
                    <ConsoleRow label="Integralność">
                      <Level
                        current={value.integrity}
                        max={value.max_integrity}
                        good={0.95}
                        avg={0.15}
                      />
                    </ConsoleRow>
                    <Button
                      fluid
                      content={
                        data.target_name === value.name
                          ? `Przestań celować: ${value.name}`
                          : `Wyceluj: ${value.name}`
                      }
                      icon="bullseye"
                      onClick={() => act('lock_ship', { target: value.name })}
                    />
                    <Button
                      fluid
                      content={`Przestań śledzić: ${value.name}`}
                      icon="bullseye"
                      onClick={() => act('dump_lock', { target: value.name })}
                    />
                  </Box>
                )}
              </Fragment>
            );
          })}
        </ConsolePanel>
      </ConsoleBody>
    </ConsoleWindow>
  );
};
