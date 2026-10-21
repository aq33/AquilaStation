import { Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

// AQUILA: separatyści to u nas strajkujący dział (event niepodległości
// działu), więc FAQ opisuje strajk; bez koloru narodu z tg.
type Info = {
  objectives: Objective[];
  nation: string;
  reason?: string;
};

export const AntagInfoSeparatist = (props) => {
  return (
    <Window width={620} height={450}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <IntroductionObjectives />
          </Stack.Item>
          <Stack.Item>
            <FrequentlyAskedQuestions />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionObjectives = (props) => {
  const { data } = useBackend<Info>();
  const { nation, objectives, reason } = data;
  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item textColor="red" fontSize="20px">
          Jesteś separatystą, obywatelem wolnego państwa {nation}!
        </Stack.Item>
        {!!reason && (
          <Stack.Item italic>
            Związek zawodowy ogłosił strajk, ponieważ {reason}.
          </Stack.Item>
        )}
        <Stack.Item grow>
          <ObjectivePrintout
            objectives={objectives}
            titleMessage={`Cele państwa ${nation}`}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FrequentlyAskedQuestions = (props) => {
  const { data } = useBackend<Info>();
  const { nation } = data;
  return (
    <Section fill>
      <Stack vertical>
        <Stack.Item fontSize="18px" bold>
          <Icon name="info" color="label" /> Najczęstsze pytania:
        </Stack.Item>
        <Stack.Item fontSize="16px">
          &quot;Kim w ogóle jest separatysta?&quot;
        </Stack.Item>
        <Stack.Item>
          Separatyści to półantagoniści: cały dział ogłosił niepodległość i
          rozpoczął strajk. Nie wolno wam swobodnie chodzić i zabijać, macie
          bronić suwerenności swojego działu.
        </Stack.Item>
        <Stack.Item fontSize="16px">&quot;Co mam robić?&quot;</Stack.Item>
        <Stack.Item>
          Wasze państwo ma wspólny cel. Nie wracajcie do pracy, dopóki dowództwo
          nie spełni żądań. Jeśli dojdzie do konfliktu, obie strony powinny
          wiedzieć, o co i dlaczego walczą, zanim zacznie się przemoc.
        </Stack.Item>
        <Stack.Item fontSize="16px">
          &quot;Czy {nation} to najlepsze państwo?&quot;
        </Stack.Item>
        <Stack.Item>Tak.</Stack.Item>
      </Stack>
    </Section>
  );
};
