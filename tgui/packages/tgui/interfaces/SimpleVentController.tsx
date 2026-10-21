import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: tg nie ma tego okna, zastępuje stary HTML prostego kontrolera wentylacji
export const SimpleVentController = (props) => {
  const { act } = useBackend();
  return (
    <Window width={300} height={150}>
      <Window.Content>
        <Section title="Sterowanie wentylacją" fill>
          <Stack vertical>
            <Stack.Item>
              <Button
                fluid
                icon="power-off"
                onClick={() => act('vent_inactive')}
              >
                Wyłącz wentylację
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button fluid icon="fan" onClick={() => act('vent_pump')}>
                Włącz: napełnianie
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button fluid icon="wind" onClick={() => act('vent_clear')}>
                Włącz: opróżnianie
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
