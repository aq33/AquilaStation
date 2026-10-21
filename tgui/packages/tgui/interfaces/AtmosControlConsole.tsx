import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: układ okna z tg, ale dane z naszej konsoli radiowej
// (code/game/machinery/computer/atmos_control.dm). Czujniki wysyłają
// procenty gazów po nazwie, a nie pełną mieszankę, więc zamiast
// GasmixParser i podręcznika atmosferyki jest prosta lista.
type Sensor = {
  id_tag: string;
  long_name: string;
  pressure: number;
  temperature: number;
  gases: Record<string, number>;
};

type Data = {
  sensors: Sensor[];
  tank?: BooleanLike;
  inputting?: BooleanLike;
  inputRate?: number;
  maxInputRate?: number;
  outputting?: BooleanLike;
  outputPressure?: number;
  maxOutputPressure?: number;
};

export const AtmosControlConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    sensors = [],
    tank,
    inputting,
    inputRate = 0,
    maxInputRate = 0,
    outputting,
    outputPressure = 0,
    maxOutputPressure = 0,
  } = data;
  const [sensorId, setSensorId] = useState(sensors[0]?.id_tag);
  const selectedSensor =
    sensors.length === 1
      ? sensors[0]
      : sensors.find((sensor) => sensor.id_tag === sensorId) || sensors[0];

  return (
    <Window width={450} height={tank ? 480 : 400}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            {sensors.length > 1 && (
              <Section title="Wybór komory">
                <Dropdown
                  width="100%"
                  options={sensors.map((sensor) => sensor.long_name)}
                  selected={selectedSensor?.long_name}
                  onSelected={(value) =>
                    setSensorId(
                      sensors.find((sensor) => sensor.long_name === value)
                        ?.id_tag || sensors[0].id_tag,
                    )
                  }
                />
              </Section>
            )}
            <Section
              title={
                selectedSensor ? selectedSensor.long_name : 'Odczyt komory'
              }
              buttons={
                !!tank && (
                  <Button
                    icon="undo"
                    content="Połącz ponownie"
                    tooltip="Wyszukaj urządzenia komory na nowo"
                    onClick={() => act('reconnect')}
                  />
                )
              }
            >
              {selectedSensor ? (
                <SensorReadout sensor={selectedSensor} />
              ) : (
                <Box italic>Nie wykryto czujników!</Box>
              )}
            </Section>
            {!!tank && (
              <Section title="Sterowanie komorą">
                <Stack>
                  <Stack.Item grow>
                    <LabeledList>
                      <LabeledList.Item label="Wtryskiwacz">
                        <Button
                          icon={inputting ? 'power-off' : 'times'}
                          content={inputting ? 'Wtryskuje' : 'Wył.'}
                          selected={inputting}
                          onClick={() => act('input')}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Przepływ">
                        <NumberInput
                          step={1}
                          value={Number(inputRate)}
                          unit="L/s"
                          width="63px"
                          minValue={0}
                          maxValue={maxInputRate}
                          // Sygnał radiowy wraca z opóźnieniem
                          onChange={(value) =>
                            act('rate', {
                              rate: value,
                            })
                          }
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item grow>
                    <LabeledList>
                      <LabeledList.Item label="Regulator wyjścia">
                        <Button
                          icon={outputting ? 'power-off' : 'times'}
                          content={outputting ? 'Otwarty' : 'Zamknięty'}
                          selected={outputting}
                          onClick={() => act('output')}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Ciśnienie wyjściowe">
                        <NumberInput
                          value={Number(outputPressure)}
                          unit="kPa"
                          width="75px"
                          minValue={0}
                          maxValue={maxOutputPressure}
                          step={10}
                          // Sygnał radiowy wraca z opóźnieniem
                          onChange={(value) =>
                            act('pressure', {
                              pressure: value,
                            })
                          }
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                </Stack>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SensorReadout = (props: { sensor: Sensor }) => {
  const { sensor } = props;
  const gases = Object.entries(sensor.gases || {}).sort((a, b) => b[1] - a[1]);
  return (
    <LabeledList>
      <LabeledList.Item label="Ciśnienie">
        {`${toFixed(sensor.pressure, 2)} kPa`}
      </LabeledList.Item>
      {!!sensor.temperature && (
        <LabeledList.Item label="Temperatura">
          {`${toFixed(sensor.temperature, 2)} K`}
        </LabeledList.Item>
      )}
      {gases.length > 0 && <LabeledList.Divider />}
      {gases.map(([gasName, gasPercent]) => (
        <LabeledList.Item key={gasName} label={gasName}>
          {`${toFixed(gasPercent, 2)}%`}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
