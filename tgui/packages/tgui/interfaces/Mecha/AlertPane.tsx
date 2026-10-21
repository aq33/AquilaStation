import { Box, Button, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { MainData } from './data';

// Klucze jak w DM (MECHA_INT_*); u nas zamiast "cabin breach" jest
// rozszczelnienie zbiornika gazu (MECHA_INT_TANK_BREACH).
export const InternalDamageToDamagedDesc = {
  MECHA_INT_FIRE: 'Wykryto pożar wewnętrzny',
  MECHA_INT_TEMP_CONTROL: 'Awaria podtrzymywania życia',
  MECHA_INT_TANK_BREACH: 'Rozszczelnienie zbiornika gazu',
  MECHA_INT_CONTROL_LOST: 'Błąd kalibracji układu koordynacji',
  MECHA_INT_SHORT_CIRCUIT: 'Zwarcie obwodów',
};

export const InternalDamageToNormalDesc = {
  MECHA_INT_FIRE: 'Brak pożaru wewnętrznego',
  MECHA_INT_TEMP_CONTROL: 'Podtrzymywanie życia działa',
  MECHA_INT_TANK_BREACH: 'Zbiornik gazu szczelny',
  MECHA_INT_CONTROL_LOST: 'Układ koordynacji skalibrowany',
  MECHA_INT_SHORT_CIRCUIT: 'Obwody sprawne',
};

export const AlertPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    internal_damage,
    internal_damage_keys = {},
    cabin_pressure,
    warning_high_pressure,
    integrity,
    integrity_max,
  } = data;
  const critical = integrity_max && integrity / integrity_max < 0.3;
  return (
    <Section title="Stan">
      <Stack vertical>
        {!!critical && (
          <Stack.Item>
            <Box color="bad" bold>
              <Icon mr={1} name="skull" />
              KRYTYCZNY POZIOM USZKODZEŃ!
            </Box>
          </Stack.Item>
        )}
        {cabin_pressure > warning_high_pressure && (
          <Stack.Item>
            <Box color="bad" bold>
              <Icon mr={1} name="gauge-high" />
              NIEBEZPIECZNIE WYSOKIE CIŚNIENIE W KABINIE
            </Box>
          </Stack.Item>
        )}
        {Object.keys(internal_damage_keys).map((t) => {
          const damaged = !!(internal_damage & internal_damage_keys[t]);
          return (
            <Stack.Item key={t}>
              <Stack justify="space-between">
                <Stack.Item>
                  <Box color={damaged ? 'red' : 'green'}>
                    <Icon mr={1} name={damaged ? 'warning' : 'check'} />
                    {damaged
                      ? InternalDamageToDamagedDesc[t]
                      : InternalDamageToNormalDesc[t]}
                  </Box>
                </Stack.Item>
                {damaged && t === 'MECHA_INT_CONTROL_LOST' && (
                  <Stack.Item>
                    <Button
                      my="-4px"
                      color="red"
                      tooltip="Mech nie może się ruszać przez 10 sekund."
                      onClick={() => act('repair_int_control_lost')}
                    >
                      Kalibruj
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};
