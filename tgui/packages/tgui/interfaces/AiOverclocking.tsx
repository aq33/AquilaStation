import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  has_cpu: BooleanLike;
  overclocking: BooleanLike;
  overclock_progress: number;
  speed: number;
  max_speed: number;
  power_multiplier: number;
  max_power_multiplier: number;
  last_values: LastValuesData[];
  power_usage: number;
  MINIMUM_CPU_SPEED: number;
  MINIMUM_CPU_POWER: number;
};

type LastValuesData = {
  speed: number;
  power: number;
  valid: BooleanLike;
};

const round2 = (value: number) => Math.round(value * 100) / 100;

export const AiOverclocking = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_cpu,
    overclocking,
    overclock_progress = 0,
    speed = 0,
    max_speed = 0,
    power_multiplier = 0,
    max_power_multiplier = 0,
    last_values = [],
    power_usage = 0,
    MINIMUM_CPU_SPEED,
    MINIMUM_CPU_POWER,
  } = data;

  const [increment, setIncrement] = useState(0.1);

  const setSpeed = (value: number) =>
    act('set_speed', {
      new_speed: round2(
        Math.min(Math.max(value, MINIMUM_CPU_SPEED), max_speed),
      ),
    });

  const setPower = (value: number) =>
    act('set_power', {
      new_power: round2(
        Math.min(Math.max(value, MINIMUM_CPU_POWER), max_power_multiplier),
      ),
    });

  const applyResult = (result: LastValuesData) => {
    setSpeed(result.speed);
    setPower(result.power);
  };

  return (
    <Window width={380} height={420} title="Podkręcanie CPU">
      <Window.Content scrollable>
        {(!overclocking && (
          <Section
            title="Podkręcanie"
            buttons={
              <Button
                color="bad"
                icon="eject"
                disabled={!has_cpu}
                onClick={() => act('eject_cpu')}
              >
                Wysuń CPU
              </Button>
            }
          >
            {(!!has_cpu && (
              <>
                <Collapsible title="Poprzednie wyniki">
                  {last_values.length === 0 && (
                    <Box color="label" mb={1}>
                      Brak wyników testów.
                    </Box>
                  )}
                  {last_values.map((result, index) => (
                    <Section
                      key={index}
                      title={`Wynik #${index + 1}`}
                      buttons={
                        <Button
                          icon="check"
                          onClick={() => applyResult(result)}
                        >
                          Zastosuj
                        </Button>
                      }
                    >
                      <LabeledList>
                        <LabeledList.Item label="Taktowanie">
                          {result.speed} THz
                        </LabeledList.Item>
                        <LabeledList.Item label="Mnożnik mocy">
                          {result.power}x
                        </LabeledList.Item>
                        <LabeledList.Item label="Stabilność">
                          {(result.valid && (
                            <Box color="good">Stabilne</Box>
                          )) || <Box color="bad">Niestabilne</Box>}
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  ))}
                </Collapsible>
                <Section
                  title="Ustawienia"
                  buttons={
                    <Button
                      color="good"
                      icon="vial"
                      onClick={() => act('test_overclock')}
                    >
                      Testuj
                    </Button>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Krok">
                      <NumberInput
                        value={increment}
                        minValue={0.1}
                        maxValue={1}
                        step={0.1}
                        format={(value) => value.toFixed(1)}
                        onChange={(value) => setIncrement(value)}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Taktowanie">
                      <Stack align="center">
                        <Stack.Item grow>{speed} THz</Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="minus"
                            disabled={speed <= MINIMUM_CPU_SPEED}
                            onClick={() => setSpeed(speed - increment)}
                          />
                          <NumberInput
                            value={speed}
                            minValue={MINIMUM_CPU_SPEED}
                            maxValue={max_speed}
                            step={0.1}
                            format={(value) => value.toFixed(2)}
                            onChange={(value) => setSpeed(value)}
                          />
                          <Button
                            icon="plus"
                            disabled={speed >= max_speed}
                            onClick={() => setSpeed(speed + increment)}
                          />
                        </Stack.Item>
                      </Stack>
                    </LabeledList.Item>
                    <LabeledList.Item label="Mnożnik mocy">
                      <Stack align="center">
                        <Stack.Item grow>
                          {power_multiplier}x ({power_usage} W)
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="minus"
                            disabled={power_multiplier <= MINIMUM_CPU_POWER}
                            onClick={() =>
                              setPower(power_multiplier - increment)
                            }
                          />
                          <NumberInput
                            value={power_multiplier}
                            minValue={MINIMUM_CPU_POWER}
                            maxValue={max_power_multiplier}
                            step={0.1}
                            format={(value) => value.toFixed(2)}
                            onChange={(value) => setPower(value)}
                          />
                          <Button
                            icon="plus"
                            disabled={power_multiplier >= max_power_multiplier}
                            onClick={() =>
                              setPower(power_multiplier + increment)
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </>
            )) || <NoticeBox>Włóż procesor.</NoticeBox>}
          </Section>
        )) || (
          <Section title="Trwa podkręcanie">
            <NoticeBox>Testowanie ustawień...</NoticeBox>
            <ProgressBar value={1 - overclock_progress} />
            <Button
              color="bad"
              fluid
              icon="times"
              mt={0.5}
              textAlign="center"
              onClick={() => act('stop_overclock')}
            >
              Przerwij
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
