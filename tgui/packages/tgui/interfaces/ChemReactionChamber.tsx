// Komora reakcyjna plumbingu z automatycznym buforowaniem pH (fermichem z tg)
import {
  Box,
  NumberInput,
  RoundGauge,
  Section,
  Stack,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { PH_RANGES } from './ChemHeater';
import { MixingChamberContent, MixingData } from './ChemMixingChamber';

type ReactionChamberData = MixingData & {
  ph: number;
  reagentAcidic: number;
  reagentAlkaline: number;
  acidicBuffer: number;
  alkalineBuffer: number;
};

export const ChemReactionChamber = (props) => {
  const { act, data } = useBackend<ReactionChamberData>();
  const { ph, reagentAcidic, reagentAlkaline, acidicBuffer, alkalineBuffer } =
    data;

  return (
    <Window width={290} height={520}>
      <Window.Content>
        <MixingChamberContent
          extraConditions={
            <Section
              title="pH"
              buttons={
                <Stack>
                  <Stack.Item mt={0.3} color="label">
                    {`pH: ${round(ph, 2)}`}
                  </Stack.Item>
                  <Stack.Item>
                    <RoundGauge
                      size={1.4}
                      value={ph}
                      minValue={0}
                      maxValue={14}
                      format={() => ''}
                      ranges={PH_RANGES}
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              <Stack vertical>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow textColor="label">
                      Dolewaj bufor zasadowy poniżej pH:
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        width="45px"
                        step={1}
                        stepPixelSize={3}
                        value={reagentAcidic}
                        minValue={0}
                        maxValue={reagentAlkaline - 1}
                        onChange={(value) =>
                          act('acidic', {
                            target: value,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow textColor="label">
                      Dolewaj bufor kwaśny powyżej pH:
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        width="45px"
                        step={1}
                        stepPixelSize={3}
                        value={reagentAlkaline}
                        minValue={reagentAcidic + 1}
                        maxValue={14}
                        onChange={(value) =>
                          act('alkaline', {
                            target: value,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Box color="label">
                    Bufory w zapasie:{' '}
                    <Box inline color={COLORS.reagent.acidicbuffer}>
                      kwaśny {acidicBuffer}j.
                    </Box>
                    ,{' '}
                    <Box inline color={COLORS.reagent.basicbuffer}>
                      zasadowy {alkalineBuffer}j.
                    </Box>
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          }
        />
      </Window.Content>
    </Window>
  );
};
