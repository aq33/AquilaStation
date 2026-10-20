import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
};

export const AntagInfoBrother = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, brothers, objectives } = data;
  return (
    <Window width={620} height={250}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Twoja rola: {antag_name || 'Brat krwi'}!
            </Stack.Item>
            {!!brothers && (
              <Stack.Item>
                Twoje rodzeństwo krwi: <b>{brothers}</b>
              </Stack.Item>
            )}
            <Stack.Item>
              <ObjectivePrintout
                objectives={objectives}
                titleMessage="Wasze obecne cele"
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
