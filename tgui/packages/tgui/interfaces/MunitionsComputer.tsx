// NSV13

// AQUILA: okno przetłumaczone na polski, wygląd konsol okrętu (common/ShipConsole.tsx)
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  COLOR,
  ConsoleBar,
  ConsoleBody,
  ConsoleMeter,
  ConsolePanel,
  ConsoleRow,
  ConsoleWindow,
  MONO,
} from './common/ShipConsole';
// AQ EDIT - przyciski etapów nabijają się paskiem (common/WeaponStageButton.tsx)
import {
  WeaponStageButton,
  type WeaponStageData,
} from './common/WeaponStageButton';

type Data = WeaponStageData & {
  // AQ EDIT - dane etapu z cycle_stage_ui_data()
  ammo: any;
  canReload: any;
  chambered: any;
  charge: any;
  has_linked_gun: any;
  isgaussgun: any;
  loaded: any;
  maint_req: any;
  max_ammo: any;
  max_maint_req: any;
  safety: any;
  sudo_mode: any;
  tool_buffer: any;
  tool_buffer_name: any;
};

/** Kolor paska amunicji i stanu działa: dobry od połowy, zły poniżej 15% */
const levelColour = (value: number) =>
  value >= 0.5 ? COLOR.good : value >= 0.15 ? COLOR.warn : COLOR.bad;

const buttonGap = {
  display: 'flex',
  flexDirection: 'column',
  gap: '3px',
} as const;

export const MunitionsComputer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    loaded,
    chambered,
    charge,
    safety,
    ammo,
    max_ammo,
    isgaussgun,
    maint_req,
    max_maint_req,
    sudo_mode,
    tool_buffer,
    tool_buffer_name,
    has_linked_gun,
  } = data;
  const ammoLevel = max_ammo ? ammo / max_ammo : 0;
  const maintLevel = maint_req / 25;
  return (
    <ConsoleWindow width={300} height={400}>
      <ConsoleBar>
        <span style={{ color: COLOR.muted }}>Broń:</span>
        <span
          style={{
            fontFamily: MONO,
            color: has_linked_gun ? COLOR.good : COLOR.bad,
          }}
        >
          {has_linked_gun ? 'połączona' : 'brak'}
        </span>
        <span style={{ marginLeft: 'auto', color: COLOR.muted }}>
          Bezpieczniki:
        </span>
        <span
          style={{ fontFamily: MONO, color: safety ? COLOR.good : COLOR.bad }}
        >
          {safety ? 'wł.' : 'wył.'}
        </span>
      </ConsoleBar>
      <ConsoleBody>
        {(!sudo_mode && (
          <>
            <ConsolePanel title="Sterowanie bronią">
              <Box style={buttonGap}>
                <WeaponStageButton
                  // AQ EDIT - był Button
                  fluid
                  data={data}
                  stages={['feed', 'unload']}
                  icon={loaded ? 'check-circle' : 'square-o'}
                  width="100"
                  selected={loaded}
                  content="I1 - Pocisk podany"
                  onClick={() => act('toggle_load')}
                />
                <WeaponStageButton
                  // AQ EDIT - był Button
                  fluid
                  data={data}
                  stages={['chamber']}
                  icon={chambered ? 'check-circle' : 'square-o'}
                  width="100"
                  selected={chambered}
                  content="I2 - Pocisk w komorze"
                  onClick={() => act('chamber')}
                />
                <Button
                  fluid
                  icon={safety ? 'power-off' : 'times'}
                  color={safety ? 'green' : 'red'}
                  content="I3 - Bezpieczniki"
                  onClick={() => act('toggle_safety')}
                />
                {!!isgaussgun && (
                  <WeaponStageButton
                    // AQ EDIT - był Button
                    fluid
                    data={data}
                    stages={['rack']}
                    icon={data.canReload ? 'power-off' : 'square-o'}
                    color={data.canReload ? 'green' : 'red'}
                    content="I4 - Przeładuj ze stojaka"
                    onClick={() => act('load')}
                  />
                )}
              </Box>
            </ConsolePanel>
            <ConsolePanel title="Statystyki">
              <ConsoleRow label="Amunicja">
                <ConsoleMeter
                  value={ammoLevel}
                  colour={levelColour(ammoLevel)}
                />
              </ConsoleRow>
              <ConsoleRow label="Stan działa">
                <ConsoleMeter
                  value={maintLevel}
                  colour={levelColour(maintLevel)}
                />
              </ConsoleRow>
            </ConsolePanel>
          </>
        )) || (
          <ConsolePanel title="Łączenie z bronią">
            <Box style={buttonGap}>
              <Button
                fluid
                icon="search"
                content="Połącz z najbliższą bronią"
                onClick={() => act('search')}
              />
              <Button
                fluid
                icon={tool_buffer ? 'link' : 'square-o'}
                selected={tool_buffer}
                content={`Połącz z: ${tool_buffer_name}`}
                onClick={() => act('link')}
              />
              <Button
                fluid
                icon={tool_buffer ? 'exclamation-triangle' : 'square-o'}
                color={tool_buffer ? 'bad' : undefined}
                content={'Wyczyść pamięć multitoola'}
                onClick={() => act('fflush')}
              />
              <Button
                fluid
                icon={has_linked_gun ? 'check-circle' : 'square-o'}
                selected={has_linked_gun}
                content="Broń połączona."
                onClick={() => act('unlink')}
              />
            </Box>
          </ConsolePanel>
        )}
      </ConsoleBody>
    </ConsoleWindow>
  );
};
