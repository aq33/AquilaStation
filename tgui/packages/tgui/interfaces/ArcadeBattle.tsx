// AQUILA - automat Space Villain 2000 (code/game/machinery/computer/arcade.dm, /battle).
// BattleArcade z tg to inna gra (mapa światów, sklep, ekwipunek), więc to własne
// okno w miejsce dawnego HTML: ta sama prosta walka atak/leczenie/odnowienie mocy.
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  enemy_name: string;
  temp: string;
  player_hp: number;
  player_mp: number;
  enemy_hp: number;
  gameover: BooleanLike;
  blocked: BooleanLike;
};

export const ArcadeBattle = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    enemy_name,
    temp,
    player_hp,
    player_mp,
    enemy_hp,
    gameover,
    blocked,
  } = data;
  return (
    <Window width={400} height={300} title="Space Villain 2000">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section textAlign="center">
              <Box bold fontSize={1.4}>
                {enemy_name}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill>
              <Box bold fontSize={1.2} textAlign="center" my={1}>
                {temp}
              </Box>
              <LabeledList>
                <LabeledList.Item label="Zdrowie" color="#c91212">
                  {player_hp}
                </LabeledList.Item>
                <LabeledList.Item label="Magia" color="#0783b5">
                  {player_mp}
                </LabeledList.Item>
                <LabeledList.Item label="Zdrowie wroga" color="bad">
                  {enemy_hp}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {gameover ? (
              <Button
                fluid
                textAlign="center"
                icon="redo"
                onClick={() => act('newgame')}
              >
                Nowa gra
              </Button>
            ) : (
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="fist-raised"
                    disabled={!!blocked}
                    onClick={() => act('attack')}
                  >
                    Atak
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="band-aid"
                    disabled={!!blocked}
                    onClick={() => act('heal')}
                  >
                    Lecz
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    icon="magic"
                    disabled={!!blocked}
                    onClick={() => act('charge')}
                  >
                    Odnów moc
                  </Button>
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
