import { type ReactNode, useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { round, toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export type Reagent = {
  name: string;
  volume: number;
};

export type MixingData = {
  reagents: Reagent[];
  emptying: BooleanLike;
  temperature: number;
  targetTemp: number;
  isReacting: BooleanLike;
};

export const ChemMixingChamber = (props) => {
  return (
    <Window width={290} height={400}>
      <Window.Content>
        <MixingChamberContent />
      </Window.Content>
    </Window>
  );
};

type MixingChamberContentProps = {
  /** AQUILA - dodatkowa sekcja pod warunkami, np. pH w komorze reakcyjnej */
  extraConditions?: ReactNode;
};

export const MixingChamberContent = (props: MixingChamberContentProps) => {
  const { extraConditions } = props;
  const { act, data } = useBackend<MixingData>();

  const [reagentQuantity, setReagentQuantity] = useState(1);

  const { emptying, temperature, targetTemp, isReacting } = data;
  const reagents = data.reagents || [];

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section
          title="Warunki"
          buttons={
            <Stack>
              <Stack.Item mt={0.3}>{'Cel:'}</Stack.Item>
              <Stack.Item>
                <NumberInput
                  tickWhileDragging
                  width="65px"
                  unit="K"
                  step={10}
                  stepPixelSize={3}
                  value={round(targetTemp, 0.1)}
                  minValue={0}
                  maxValue={1000}
                  onChange={(value) =>
                    act('temperature', {
                      target: value,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          }
        >
          <Stack vertical>
            <Stack.Item>
              <Stack fill>
                <Stack.Item textColor="label">Obecna temperatura:</Stack.Item>
                {extraConditions && <Stack.Item>{extraConditions}</Stack.Item>}
                <Stack.Item grow>
                  <AnimatedNumber
                    value={temperature}
                    format={(value) => `${toFixed(value)} K`}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          title="Ustawienia"
          fill
          scrollable
          buttons={
            (isReacting && (
              <Box inline bold color={'purple'}>
                {'Reakcja'}
              </Box>
            )) || (
              <Box
                fontSize="16px"
                inline
                bold
                color={emptying ? 'bad' : 'good'}
              >
                {emptying ? 'Opróżnianie' : 'Napełnianie'}
              </Box>
            )
          }
        >
          <Stack vertical fill>
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <Button
                    content="Dodaj odczynnik"
                    color="good"
                    icon="plus"
                    onClick={() =>
                      act('add', {
                        amount: reagentQuantity,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    tickWhileDragging
                    value={reagentQuantity}
                    minValue={1}
                    maxValue={100}
                    step={1}
                    stepPixelSize={3}
                    width="39px"
                    onChange={(value) => setReagentQuantity(value)}
                  />
                  <Box inline mr={1} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                {reagents.map((reagent) => (
                  <Stack.Item key={reagent.name}>
                    <Stack fill>
                      <Stack.Item mt={0.25} textColor="label">
                        {`${reagent.name}:`}
                      </Stack.Item>
                      <Stack.Item mt={0.25} grow>
                        {reagent.volume}
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="minus"
                          color="bad"
                          onClick={() =>
                            act('remove', {
                              chem: reagent.name,
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
