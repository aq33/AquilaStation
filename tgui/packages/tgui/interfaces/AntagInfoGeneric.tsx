import { Box, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
  // AQUILA: opis roli (np. playstyle_string potwora, demon cieni)
  intro?: string;
};

export const AntagInfoGeneric = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, objectives, intro } = data;
  return (
    <Window width={620} height={intro ? 480 : 250}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Twoja rola: {antag_name || 'antagonista'}!
            </Stack.Item>
            {!!intro && (
              <Stack.Item>
                <Box
                  style={{ whiteSpace: 'pre-line' }}
                  dangerouslySetInnerHTML={{ __html: intro }}
                />
              </Stack.Item>
            )}
            <Stack.Item>
              <ObjectivePrintout
                objectives={objectives}
                titleMessage="Twoje obecne cele"
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
