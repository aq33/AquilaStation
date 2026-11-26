// NSV13 - podgląd uzbrojenia (AQUILA: wygląd konsol okrętu z common/ShipConsole.tsx; na mostkach graczy
// lista broni jest w konsoli taktycznej, to okno zostaje dla konsol na innych mapach)

import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  COLOR,
  ConsoleBody,
  ConsoleEmpty,
  ConsoleMeter,
  ConsolePanel,
  ConsoleWindow,
} from './common/ShipConsole';

type Weapon = {
  name: string;
  ammo: number;
  maxammo: number;
  controllers?: string;
  ammo_filter?: string;
};

type Data = {
  additional_weapon_info: boolean;
  weapons: Record<string, Weapon>;
};

export const OrdnanceConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const weapons = Object.values(data.weapons || {}).filter(
    (weapon) => !!weapon.maxammo,
  );
  return (
    <ConsoleWindow width={560} height={600}>
      <ConsoleBody>
        <ConsolePanel
          title="Uzbrojenie"
          right={
            <Button
              icon="cog"
              selected={!!data.additional_weapon_info}
              onClick={() => act('toggle_additional_weapon_info')}
            >
              Więcej informacji
            </Button>
          }
        >
          {weapons.length === 0 && (
            <ConsoleEmpty>Okręt nie ma broni z amunicją.</ConsoleEmpty>
          )}
          {weapons.map((weapon) => (
            <Box key={weapon.name} style={{ marginBottom: '8px' }}>
              <Box style={{ display: 'flex', gap: '10px' }}>
                <span style={{ flex: 1 }}>{weapon.name}</span>
                <ConsoleMeter
                  width="200px"
                  value={weapon.ammo / weapon.maxammo}
                  label={weapon.ammo + '/' + weapon.maxammo}
                />
              </Box>
              {!!data.additional_weapon_info && (
                <Box style={{ color: COLOR.muted, fontSize: '11.5px' }}>
                  {!!weapon.controllers && (
                    <>Kontrolery broni: {weapon.controllers}</>
                  )}
                  {!!weapon.controllers && !!weapon.ammo_filter && ' · '}
                  {!!weapon.ammo_filter && (
                    <>Filtr amunicji: {weapon.ammo_filter}</>
                  )}
                </Box>
              )}
            </Box>
          ))}
        </ConsolePanel>
      </ConsoleBody>
    </ConsoleWindow>
  );
};
