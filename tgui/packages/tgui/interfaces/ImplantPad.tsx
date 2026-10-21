import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  has_case: BooleanLike;
  has_implant: BooleanLike;
  // AQUILA: get_data() u nas zwraca HTML (pogrubienia, <BR>)
  case_information: string | null;
};

export const ImplantPad = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_case, has_implant, case_information } = data;
  return (
    <Window width={320} height={380}>
      <Window.Content scrollable>
        <Stack bold>
          <Stack.Item grow color="good" align="center">
            Minikomputer implantów
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eject"
              disabled={!has_case}
              onClick={() => act('eject_implant')}
            >
              Wyjmij obudowę
            </Button>
          </Stack.Item>
        </Stack>
        <Divider />
        <Section title="Informacje o implancie">
          {!has_case && (
            <Box color="label">
              Nie wykryto obudowy implantu. Włóż ją, aby zobaczyć zawartość.
            </Box>
          )}
          {!!has_case && !has_implant && (
            <Box color="label">Obudowa implantu jest pusta.</Box>
          )}
          {!!has_case && !!has_implant && (
            <Box dangerouslySetInnerHTML={{ __html: case_information || '' }} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
