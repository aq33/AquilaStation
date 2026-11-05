// NSV13

import {
  Button,
  Knob,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  apu: any;
  armour_integrity: any;
  battery: any;
  battery_charge: any;
  battery_max_charge: any;
  brakes: any;
  canopy_lock: any;
  countermeasures: any;
  docking_cooldown: any;
  docking_mode: any;
  ftl_active: any;
  ftl_capable: any;
  ftl_spool_progress: any;
  ftl_spool_time: any;
  ftl_target: any;
  fuel: any;
  fuel_pump: any;
  fuel_warning: any;
  hardpoints: any;
  ignition: any;
  inertial_dampeners: any;
  mag_locked: any;
  maintenance_mode: any;
  master_caution: any;
  max_armour_integrity: any;
  max_countermeasures: any;
  max_fuel: any;
  max_integrity: any;
  max_primary_ammo: any;
  max_secondary_ammo: any;
  obj_integrity: any;
  occupants_info: any;
  primary_ammo: any;
  rpm: any;
  rwr: any;
  secondary_ammo: any;
  target_lock: any;
  weapon_safety: any;
};

export const FighterControls = (props) => {
  const { act, data } = useBackend<Data>();
  const [settingsVisible, setSettingsVisible] = useLocalState(
    'settings',
    false,
  );
  return (
    <Window theme="hackerman" width={497} height={450}>
      <Window.Content scrollable>
        <Section title="Alarmy:">
          <Button
            width="150px"
            content="Master caution"
            color={data.master_caution ? 'average' : undefined}
            icon="exclamation-triangle"
            onClick={() => act('master_caution')}
          />
          <Button
            width="150px"
            content="Namierzenie radarem"
            color={data.rwr ? 'average' : undefined}
            icon="exclamation-triangle"
          />
          <Button
            width="150px"
            content="Ostrzeżenie: paliwo"
            color={data.fuel_warning ? 'average' : undefined}
            icon="gas-pump"
          />
        </Section>
        <Section title="Monitorowanie">
          PALIWO:
          <Knob
            inline
            size={1.25}
            color={data.fuel_warning ? 'bad' : undefined}
            value={data.fuel}
            unit="L"
            minValue={0}
            maxValue={data.max_fuel}
          />
          BAT.:
          <Knob
            inline
            size={1.25}
            color={data.battery_charge <= 2000 ? 'bad' : undefined}
            value={data.battery_charge}
            unit="W"
            minValue={0}
            maxValue={data.battery_max_charge}
          />
          OBR.:
          <Knob
            inline
            size={1.25}
            value={data.rpm}
            unit="obr./min"
            minValue={0}
            maxValue={8000}
          />
          GŁ.:
          <Knob
            inline
            size={1.25}
            value={data.primary_ammo}
            unit="szt."
            minValue={0}
            maxValue={data.max_primary_ammo}
          />
          POM.:
          <Knob
            inline
            size={1.25}
            value={data.secondary_ammo}
            unit="szt."
            minValue={0}
            maxValue={data.max_secondary_ammo}
          />
          CTR:
          <Knob
            inline
            size={1.25}
            value={data.countermeasures}
            unit="U"
            minValue={0}
            maxValue={data.max_countermeasures}
          />
          <br />
          <br />
          <LabeledList>
            <LabeledList.Item label="Pancerz">
              <ProgressBar
                value={
                  (data.armour_integrity / data.max_armour_integrity) *
                  100 *
                  0.01
                }
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Kadłub">
              <ProgressBar
                value={(data.obj_integrity / data.max_integrity) * 100 * 0.01}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!data.ftl_capable && (
          <Section title="Napęd FTL:">
            Cel: {data.ftl_target ? data.ftl_target : 'Brak'}
            <br />
            <br />
            <Button
              content={
                data.ftl_active ? 'Przerwij rozkręcanie' : 'Rozkręć napęd'
              }
              width="150px"
              icon="server"
              onClick={() => act('toggle_ftl')}
            />
            <Button
              content={'Wypuść linkę'}
              width="150px"
              icon="anchor"
              color={data.ftl_target ? 'good' : 'orange'}
              onClick={() => act('anchor_ftl')}
            />
            <Button
              content="Powrót"
              width="150px"
              icon="forward"
              onClick={() => act('return_jump')}
            />
            <ProgressBar
              value={
                (data.ftl_spool_progress / data.ftl_spool_time) * 100 * 0.01
              }
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
        )}
        <Section
          title="Sterowanie:"
          buttons={
            <Button
              icon={settingsVisible ? 'times' : 'cog'}
              selected={settingsVisible}
              onClick={() => setSettingsVisible(!settingsVisible)}
            />
          }
        >
          <Button
            width="150px"
            content="DRADIS"
            icon="satellite-dish"
            onClick={() => act('show_dradis')}
          />
          <Button
            width="150px"
            content="Tryb dokowania"
            icon={data.docking_mode ? 'anchor' : 'times'}
            color={
              (data.docking_cooldown && 'orange') ||
              (data.docking_mode ? 'good' : null)
            }
            onClick={() => act('docking_mode')}
          />
          <Button
            width="150px"
            content="Blokada osłony kokpitu"
            icon={!data.canopy_lock ? 'lock' : 'unlock'}
            color={!data.canopy_lock ? 'good' : undefined}
            onClick={() => act('canopy_lock')}
          />
          <Button
            width="150px"
            content="Hamulce"
            icon={!data.brakes ? 'unlock' : 'lock'}
            color={data.brakes ? 'good' : undefined}
            onClick={() => act('brakes')}
          />
          <Button
            width="150px"
            content="IAS"
            icon="bezier-curve"
            color={data.inertial_dampeners ? 'good' : undefined}
            onClick={() => act('inertial_dampeners')}
          />
          <Button
            width="150px"
            content="MAGLOCK"
            icon={data.mag_locked ? 'unlock' : 'magnet'}
            color={data.mag_locked ? 'good' : undefined}
            onClick={() => act('mag_release')}
          />
          <Button
            width="150px"
            content="BEZPIECZNIKI"
            icon={data.weapon_safety ? 'power-off' : 'times'}
            color={!data.weapon_safety ? 'bad' : 'good'}
            onClick={() => act('weapon_safety')}
          />
          <Button
            width="150px"
            content="NAMIERZANIE"
            icon={data.target_lock ? 'power-off' : 'square-o'}
            color={data.target_lock ? 'good' : 'average'}
            onClick={() => act('target_lock')}
          />
          <Button
            width="150px"
            content="BATERIA"
            icon={data.battery ? 'car-battery' : 'power-off'}
            color={data.battery ? 'good' : 'bad'}
            onClick={() => act('battery')}
          />
          <Button
            width="150px"
            content="WTRYSK PALIWA"
            icon={data.fuel_pump ? 'gas-pump' : 'power-off'}
            color={data.fuel_pump ? 'good' : 'bad'}
            onClick={() => act('fuel_pump')}
          />
          <Button
            width="150px"
            content="APU"
            icon={data.apu ? 'power-off' : 'square-o'}
            color={data.apu ? 'good' : 'bad'}
            onClick={() => act('apu')}
          />
          <Button
            width="150px"
            content="ZAPŁON"
            icon={data.ignition ? 'key' : 'square-o'}
            color={data.ignition ? 'good' : 'bad'}
            onClick={() => act('ignition')}
          />
        </Section>
        {!!settingsVisible && (
          <Section title="Ustawienia:">
            <Button content={'Ustaw nazwę'} onClick={() => act('set_name')} />
            <Button
              content={'Konserwacja'}
              onClick={() => act('toggle_maintenance')}
            />
            <br />
            {!!data.maintenance_mode && (
              <Section title="Załadowane moduły:">
                <LabeledList>
                  {Object.keys(data.hardpoints).map((key) => {
                    let value = data.hardpoints[key];
                    return (
                      <LabeledList.Item key={key} label={`${value.name}`}>
                        <Button
                          content={`Wysuń`}
                          icon="eject"
                          onClick={() =>
                            act('eject_hardpoint', { id: value.id })
                          }
                        />
                        <Button
                          content={`Wysyp zawartość`}
                          icon="download"
                          onClick={() =>
                            act('dump_hardpoint', { id: value.id })
                          }
                        />
                      </LabeledList.Item>
                    );
                  })}
                </LabeledList>
              </Section>
            )}
            <br />
            {/*             <Section title="Occupants:">
              <LabeledList>
                {Object.keys(data.occupants_info).map(key => {
                  let value = data.occupants_info[key];
                  return (
                    <LabeledList.Item label={`${value.name}`}>
                      <Button
                        fluid
                        content={`Wyrzuć (${value.afk})`}
                        icon="eject"
                        onClick={() => act('kick', { id: value.id })} />
                    </LabeledList.Item>);
                })}
              </LabeledList>
            </Section> */}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
