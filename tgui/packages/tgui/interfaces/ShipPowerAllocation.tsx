// AQUILA - podział mocy okrętu w konsoli monitorowania zasilania (aquila/code/modules/overmap/ship_power.dm)
import { Box, Button, Section, Slider, Table } from 'tgui-core/components';

import { useBackend } from '../backend';

type ShipPowerSystem = {
  id: string;
  name: string;
  limit: number;
  priority: number;
  draw: string;
  demand: string;
  max: string | null;
  apc: boolean;
};

export type ShipPowerData = {
  systems: ShipPowerSystem[];
  presets: string[];
  can_edit: boolean;
};

type Data = {
  ship_power?: ShipPowerData;
};

const PRIORITIES = [1, 2, 3, 4, 5];

export function ShipPowerAllocation() {
  const { act, data } = useBackend<Data>();
  const power = data.ship_power;
  if (!power) {
    return null;
  }
  const { systems, presets, can_edit } = power;
  return (
    <>
      <Section title="Gotowe ustawienia">
        {presets.map((preset) => (
          <Button
            key={preset}
            disabled={!can_edit}
            onClick={() => act('ship_power_preset', { preset })}
          >
            {preset}
          </Button>
        ))}
        {!can_edit && (
          <Box mt={1} color="average">
            Zmiany wymagają dostępu do inżynierii.
          </Box>
        )}
      </Section>
      <Section title="Systemy okrętu">
        <Table>
          <Table.Row header>
            <Table.Cell>System</Table.Cell>
            <Table.Cell>Limit</Table.Cell>
            <Table.Cell collapsing>Priorytet</Table.Cell>
            <Table.Cell collapsing textAlign="right">
              Pobór / zapotrzebowanie
            </Table.Cell>
          </Table.Row>
          {systems.map((system) => (
            <Table.Row key={system.id} className="candystripe">
              <Table.Cell>
                <Box bold>{system.name}</Box>
                <Box color="label" fontSize="0.9em">
                  {system.max ? `Maks. ${system.max}` : 'Brak aktywnych urządzeń'}
                  {system.apc && ' (z APC)'}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Slider
                  minValue={0}
                  maxValue={100}
                  step={5}
                  stepPixelSize={2}
                  value={system.limit}
                  unit="%"
                  disabled={!can_edit}
                  onChange={(_, value) =>
                    act('ship_power_limit', { system: system.id, value })
                  }
                />
              </Table.Cell>
              <Table.Cell collapsing>
                {PRIORITIES.map((priority) => (
                  <Button
                    key={priority}
                    selected={system.priority === priority}
                    disabled={!can_edit || system.apc}
                    onClick={() =>
                      act('ship_power_priority', {
                        system: system.id,
                        value: priority,
                      })
                    }
                  >
                    {priority}
                  </Button>
                ))}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {system.draw} / {system.demand}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <Box mt={1} color="label">
          <Box>Priorytet 1 dostaje prąd pierwszy.</Box>
          <Box>Przy braku mocy najpierw odcinane są niższe priorytety.</Box>
          <Box>Napęd bierze prąd z APC, więc działa u niego tylko limit.</Box>
        </Box>
      </Section>
    </>
  );
}
