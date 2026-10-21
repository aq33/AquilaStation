import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Stack } from 'tgui-core/components';

import { BeakerDisplay } from './Beaker';
import { SpecimenDisplay } from './Specimen';
import { SymptomCatalog } from './SymptomCatalog';
import type { Data } from './types';

export const Pandemic = (props) => {
  const { data } = useBackend<Data>();
  const { has_beaker, has_blood } = data;

  return (
    <Window width={650} height={550}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <BeakerDisplay />
          </Stack.Item>
          {!!has_beaker && !!has_blood && (
            <Stack.Item>
              <SpecimenDisplay />
            </Stack.Item>
          )}
          {/* AQUILA - lista symptomów */}
          <Stack.Item>
            <SymptomCatalog />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
