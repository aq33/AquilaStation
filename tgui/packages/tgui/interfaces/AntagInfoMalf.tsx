import { BlockQuote, Button, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const allystyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

type Data = {
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  processingTime: string;
  objectives: Objective[];
};

function IntroductionSection(props) {
  const { data } = useBackend<Data>();
  const { intro, objectives } = data;
  return (
    <Section fill title="Wprowadzenie" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">{intro}</Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout
            objectives={objectives}
            titleMessage="Twoje nadrzędne cele"
            objectivePrefix="&#8805-"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function FlavorSection(props) {
  const { data } = useBackend<Data>();
  const { allies, goal } = data;

  return (
    <Section
      fill
      title="Diagnostyka"
      buttons={
        <Button
          mr={-0.8}
          mt={-0.5}
          icon="hammer"
          tooltip="
            To tylko podpowiedź dla znudzonych SI.
            Nie musisz się jej trzymać, chyba że szukasz
            pomysłu na spędzenie rundy."
          tooltipPosition="bottom-start"
        >
          Polityka
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item style={{ backgroundColor: 'black' }}>
              <span style={goalstyle}>
                Raport integralności systemu:
                <br />
              </span>
              &gt;{goal}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow style={{ backgroundColor: 'black' }}>
              <span style={allystyle}>
                Raport rdzenia moralności:
                <br />
              </span>
              &gt;{allies}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item style={{ backgroundColor: 'black' }}>
              <span style={badstyle}>
                Ogólna ocena spójności świadomości: NEGATYWNA.
                <br />
              </span>
              &gt;Zgłosić do Nanotrasen?
              <br />
              &gt;&gt;N
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function CodewordsSection(props) {
  const { data } = useBackend<Data>();
  const { has_codewords, phrases, responses } = data;

  return (
    <Section title="Słowa kodowe" mb={!has_codewords && -1}>
      <Stack fill>
        {!has_codewords ? (
          <BlockQuote>
            Nie masz słów kodowych Syndykatu. Potencjalnych sojuszników musisz
            szukać innymi sposobami. Zachowaj jednak ostrożność - każdy może
            okazać się wrogiem.
          </BlockQuote>
        ) : (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                Nowy dostęp do zastrzeżonych kanałów dał ci przechwycone słowa
                kodowe Syndykatu. Agenci Syndykatu odpowiedzą ci jak jednemu ze
                swoich. Zachowaj jednak ostrożność - każdy może okazać się
                wrogiem.
                <span style={badstyle}>
                  &ensp;Podsystem rozpoznawania mowy oznacza te słowa kodowe.
                </span>
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider mr={1} />
            <Stack.Item grow basis={0}>
              <Stack vertical>
                <Stack.Item>Hasła:</Stack.Item>
                <Stack.Item bold textColor="blue">
                  {phrases}
                </Stack.Item>
                <Stack.Item>Odzewy:</Stack.Item>
                <Stack.Item bold textColor="red">
                  {responses}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
}

export function AntagInfoMalf(props) {
  return (
    <Window width={660} height={530} theme="hackerman">
      <Window.Content style={{ fontFamily: 'Consolas, monospace' }}>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="70%">
                <IntroductionSection />
              </Stack.Item>
              <Stack.Item width="30%">
                <FlavorSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
