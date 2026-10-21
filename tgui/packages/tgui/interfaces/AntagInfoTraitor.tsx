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
  color: 'lightblue',
  fontWeight: 'bold',
};

type Info = {
  antag_name: string;
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  theme?: string;
  allies?: string;
  goal?: string;
  intro?: string;
  code: string;
  failsafe_code: string;
  has_uplink: BooleanLike;
  uplink_unlock_info: string;
  objectives: Objective[];
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, intro, objectives } = data;
  return (
    <Section fill title="Wprowadzenie" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          {intro || `Twoja rola: ${antag_name || 'zdrajca'}.`}
        </Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout
            objectives={objectives}
            titleMessage="Twoje obecne cele"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EmployerSection = (props) => {
  const { data } = useBackend<Info>();
  const { allies, goal } = data;
  return (
    <Section
      fill
      title="Pracodawca"
      scrollable
      buttons={
        <Button
          icon="hammer"
          tooltip={`
            To tylko podpowiedź dla znudzonych zdrajców.
            Nie musisz się jej trzymać, chyba że szukasz
            pomysłu na spędzenie rundy.`}
          tooltipPosition="bottom-start"
        >
          Polityka
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack vertical>
            {!!allies && (
              <Stack.Item>
                <span style={allystyle}>
                  Twoje sojusze:
                  <br />
                </span>
                <BlockQuote>{allies}</BlockQuote>
              </Stack.Item>
            )}
            {!!allies && !!goal && <Stack.Divider />}
            {!!goal && (
              <Stack.Item mb={1}>
                <span style={goalstyle}>
                  Zdanie pracodawcy:
                  <br />
                </span>
                <BlockQuote>{goal}</BlockQuote>
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props) => {
  const { data } = useBackend<Info>();
  const { uplink_unlock_info, code, failsafe_code } = data;
  return (
    <Section title="Uplink">
      <Stack fill>
        <Stack.Item bold>
          Dbaj o uplink i nie kupuj wszystkiego od razu - telekryształy możesz
          zachować na trudną sytuację.
          <br />
          {!!code && <span style={goalstyle}>Kod: {code}</span>}
          <br />
          {!!failsafe_code && (
            <span style={badstyle}>Kod awaryjny: {failsafe_code}</span>
          )}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item align="center">
          <BlockQuote>{uplink_unlock_info}</BlockQuote>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CodewordsSection = (props) => {
  const { data } = useBackend<Info>();
  const { has_codewords, phrases, responses } = data;
  return (
    <Section title="Słowa kodowe" mb={!has_codewords && -1}>
      <Stack fill>
        {(!has_codewords && (
          <BlockQuote>
            Nie dostałeś słów kodowych. Potencjalnych sojuszników musisz szukać
            innymi sposobami. Zachowaj jednak ostrożność - każdy może okazać się
            wrogiem.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                Twój pracodawca przekazał ci poniższe słowa kodowe, po których
                rozpoznasz innych agentów. Wplataj je w zwykłą rozmowę, aby
                odnaleźć swoich. Zachowaj jednak ostrożność - każdy może okazać
                się wrogiem.
                <span style={badstyle}>
                  &ensp;Zapamiętałeś słowa kodowe, więc rozpoznasz je, gdy je
                  usłyszysz.
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
};

// AQUILA: treść okna jest też zakładką „Informacje” w TraitorBackstoryMenu
export const AntagInfoTraitorContent = (props) => {
  const { data } = useBackend<Info>();
  const { allies, goal, has_uplink } = data;
  const hasEmployer = !!allies || !!goal;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item width={hasEmployer ? '70%' : '100%'}>
            <IntroductionSection />
          </Stack.Item>
          {hasEmployer && (
            <Stack.Item width="30%">
              <EmployerSection />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      {!!has_uplink && (
        <Stack.Item>
          <UplinkSection />
        </Stack.Item>
      )}
      <Stack.Item>
        <CodewordsSection />
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoTraitor = (props) => {
  const { data } = useBackend<Info>();
  const { theme } = data;
  return (
    <Window width={620} height={580} theme={theme || 'syndicate'}>
      <Window.Content>
        <AntagInfoTraitorContent />
      </Window.Content>
    </Window>
  );
};
