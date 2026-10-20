import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Chem = {
  path: string;
  name: string;
  cost: number;
  desc: string;
};

type Data = {
  chemicals: number;
  has_host: BooleanLike;
  chems: Chem[];
};

export const HorrorChemicals = (props) => {
  const { act, data } = useBackend<Data>();
  const { chemicals, has_host, chems = [] } = data;

  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Chemikalia">
              <Box bold color="#7264FF">
                {chemicals}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!has_host && (
          <NoticeBox danger>Nie jesteś w ciele nosiciela.</NoticeBox>
        )}
        <Section title="Substancje">
          <Stack vertical>
            {chems.map((chem) => (
              <Stack.Item key={chem.path}>
                <Button
                  fluid
                  textAlign="center"
                  disabled={!has_host || chemicals < chem.cost}
                  onClick={() => act('use_chem', { path: chem.path })}
                >
                  {chem.name} ({chem.cost})
                </Button>
                <Box color="label" mx={1} mb={1}>
                  {chem.desc}
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
