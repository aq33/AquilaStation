import { Box, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const jauntstyle = {
  color: 'lightblue',
};

type Info = {
  fluff: string;
  explain_attack: BooleanLike;
  objectives: Objective[];
};

// AQUILA: nasz demon nie ma ciosu prawym przyciskiem z tg, więc opis mocy
// mówi tylko o Krwawym Pełzie.
export const AntagInfoDemon = (props) => {
  const { data } = useBackend<Info>();
  const { fluff, objectives = [], explain_attack } = data;
  return (
    <Window width={620} height={356} theme="syndicate">
      <Window.Content style={{ backgroundImage: 'none' }}>
        <Stack fill>
          <Stack.Item>
            <DemonRunes />
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical width="544px" fill>
              <Stack.Item grow>
                <Section fill scrollable={objectives.length > 2}>
                  <Stack vertical>
                    <Stack.Item
                      textAlign="center"
                      textColor="red"
                      fontSize="20px"
                    >
                      {fluff}
                    </Stack.Item>
                    <Stack.Item>
                      <ObjectivePrintout
                        titleMessage="Leży w twojej naturze, by osiągnąć te cele"
                        objectiveTextSize="20px"
                        objectives={objectives}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              {!!explain_attack && (
                <Stack.Item>
                  <Section fill title="Demoniczne moce">
                    <Stack vertical>
                      <Stack.Item>
                        <span style={jauntstyle}>Krwawy Pełz:</span> możesz
                        zanurzać się w kałużach krwi i wynurzać z nich, żeby
                        dostać się tam, gdzie chcesz. Po wyjściu z krwi przez
                        chwilę poruszasz się szybciej, co pozwala na zaskakujące
                        ataki. Możesz wciągać do krwi unieszkodliwione ofiary,
                        pożerając je i odzyskując zdrowie.
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <DemonRunes />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DemonRunes = (props) => {
  return (
    <Section height="102%" mt="-6px" fill>
      {/*
      shoutout to my boy Yuktopus from Crash Bandicoot: Crash of the Titans.
      Damn, that was such a good game.
      */}
      <Box className="HellishRunes__demonrune">
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S<br />
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S<br />
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S<br />
        Y<br />U<br />K<br />T<br />O<br />P<br />U<br />S
      </Box>
    </Section>
  );
};
