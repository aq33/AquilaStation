// Komora reakcyjna plumbingu z automatycznym buforowaniem pH (fermichem z tg)
import { Box, NumberInput, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BUFFER_COLORS, PhReadout } from './ChemHeater';
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
            <Section title="pH">
              <PhReadout ph={ph} />
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
                    <Box inline bold color={BUFFER_COLORS.acidic}>
                      kwaśny {acidicBuffer}j.
                    </Box>
                    ,{' '}
                    <Box inline bold color={BUFFER_COLORS.basic}>
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
