import { Box, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Data = {
  objectives: Objective[];
};

export const AntagInfoBrainwashed = (props) => {
  const { data } = useBackend<Data>();

  return (
    <Window width={400} height={400} theme="abductor">
      <Window.Content backgroundColor="#722e7d">
        <Icon
          size={16}
          name="flushed"
          color="#3f1945"
          position="absolute"
          top="42%"
          left="26%"
        />
        <Section fill>
          <Stack fill vertical g={0} textAlign="center">
            <Stack.Item fontFamily="Wingdings">
              Hej, nie! Przestań to tłumaczyć!
            </Stack.Item>
            <Stack.Item fontSize="20px">Twój umysł wiruje...</Stack.Item>
            <Stack.Item fontSize="20px">
              Skupia się na jednym celu...
            </Stack.Item>
            <Stack.Item mt={3.5} grow>
              <ObjectivePrintout
                fill
                objectives={data.objectives}
                titleMessage="Twoje obecne dyrektywy"
                objectiveFollowup={
                  <Box bold textColor="red">
                    Tej dyrektywy trzeba przestrzegać.
                  </Box>
                }
              />
            </Stack.Item>
            <Stack.Item mb={0.5} fontSize="20px" textColor="#61e4b9">
              Wykonuj dyrektywy za wszelką cenę!
            </Stack.Item>
            <Stack.Item fontFamily="Wingdings">
              Zepsułeś mi fajny efekt czcionki.
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
