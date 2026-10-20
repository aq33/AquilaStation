import { Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const ninja_emphasis = {
  color: 'red',
};

// AQUILA: bez przycisku podmiany celów z tg (nie mamy tej mechaniki)
type NinjaInfo = {
  objectives: Objective[];
};

export const AntagInfoNinja = (props) => {
  const { data } = useBackend<NinjaInfo>();
  const { objectives } = data;
  return (
    <Window width={550} height={450} theme="hackerman">
      <Window.Content>
        <Icon
          size={30}
          name="spider"
          color="#003300"
          position="absolute"
          top="10%"
          left="10%"
        />
        <Section scrollable fill>
          <Stack vertical textColor="green">
            <Stack.Item textAlign="center" fontSize="20px">
              Jestem elitarnym najemnikiem Klanu Pająka.
              <br />
              <span style={ninja_emphasis}>KOSMICZNYM NINJA</span>!
            </Stack.Item>
            <Stack.Item textAlign="center" italic>
              Zaskoczenie jest moją bronią. Cienie są moją zbroją. Bez nich
              jestem niczym.
            </Stack.Item>
            <Stack.Item>
              <Section fill>
                Twój zaawansowany strój ninja ma wiele potężnych modułów.
                <br />
                Możesz go naładować, klikając prawym przyciskiem na APC albo
                inne źródła energii, żeby wyssać z nich prąd.
                <br />
                Kliknięcie prawym przyciskiem na niektóre maszyny i przedmioty w
                założonym stroju zhakuje je, z różnym skutkiem. Eksperymentuj i
                sprawdź, co potrafisz!
              </Section>
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
