// AQUILA - sterowanie artylerią bluespace z misji wyjazdowych
// (code/modules/awaymissions/bluespaceartillery.dm). To nie jest BSA ze stacji
// (BluespaceArtillery.tsx), więc to własne okno w miejsce dawnego HTML.
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  reload: number;
  reload_cooldown: number;
};

export const ArtilleryControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { reload, reload_cooldown } = data;
  const ready = reload >= reload_cooldown;
  return (
    <Window width={380} height={240} title="Sterowanie artylerią bluespace">
      <Window.Content>
        <Section
          title="Namierzono"
          buttons={
            <Button
              icon="crosshairs"
              color="bad"
              disabled={!ready}
              onClick={() => act('fire')}
            >
              Otwórz ogień
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Postęp ładowania">
              <ProgressBar
                value={reload}
                maxValue={reload_cooldown}
                color={ready ? 'good' : 'average'}
              >
                {reload}/{reload_cooldown}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <Box>
            Użycie broni zatwierdzone przez Dowództwo Marynarki Nanotrasen.
          </Box>
          <Box mt={1} color="bad">
            Pamiętaj, ostrzał sojuszników jest podstawą do rozwiązania twojego
            kontraktu i zakończenia twojego życia.
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
