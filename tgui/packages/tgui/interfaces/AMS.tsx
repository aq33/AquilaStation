// NSV13 - konsola AMS (AQUILA: wygląd konsol okrętu z common/ShipConsole.tsx; na mostkach graczy te ustawienia
// są w konsoli taktycznej, to okno zostaje dla konsol na innych mapach)

import { Box, Button, NumberInput } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  COLOR,
  ConsoleBody,
  ConsolePanel,
  ConsoleWindow,
} from './common/ShipConsole';

type Mode = { id: string; name: string; desc: string; enabled: boolean };

type Data = {
  categories: Mode[];
  data_source: string;
  shot_limit: number;
};

export const AMS = (props) => {
  const { act, data } = useBackend<Data>();
  // Klucz porównywany z AMS_LOCKED_TARGETS w nsv13/code/__DEFINES/overmap.dm
  const lockedOnly = data.data_source === 'Locked Targets';
  return (
    <ConsoleWindow width={500} height={500}>
      <ConsoleBody>
        <ConsolePanel title="Źródło celów">
          <Button
            selected={lockedOnly}
            onClick={() => !lockedOnly && act('data_source')}
          >
            Cel ognia
          </Button>
          <Button
            selected={!lockedOnly}
            onClick={() => lockedOnly && act('data_source')}
          >
            Wszystkie śledzone
          </Button>
        </ConsolePanel>
        <ConsolePanel title="Tryby AMS">
          {Object.values(data.categories || {}).map((mode) => (
            <Box key={mode.id} style={{ marginBottom: '8px' }}>
              <Box style={{ display: 'flex', alignItems: 'center' }}>
                <b style={{ flex: 1 }}>{mode.name}</b>
                <Button
                  icon={mode.enabled ? 'check-circle' : 'times'}
                  selected={mode.enabled}
                  onClick={() => act('select', { target: mode.id })}
                >
                  {mode.enabled ? 'Włączony' : 'Wyłączony'}
                </Button>
              </Box>
              <Box style={{ color: COLOR.muted, fontSize: '11.5px' }}>
                {mode.desc}
              </Box>
            </Box>
          ))}
        </ConsolePanel>
        <ConsolePanel title="Strzałów na cel">
          <NumberInput
            value={Number(data.shot_limit) || 1}
            unit="strz."
            width="90px"
            minValue={1}
            maxValue={100}
            step={1}
            onChange={(value) => act('set_shot_limit', { shot_limit: value })}
          />
        </ConsolePanel>
      </ConsoleBody>
    </ConsoleWindow>
  );
};
