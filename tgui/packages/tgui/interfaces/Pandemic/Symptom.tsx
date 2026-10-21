import {
  Box,
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { getColor } from './helpers';
import type { Symptom } from './types';

/** Symptomy wirusa jako rozwijane pozycje */
export const SymptomDisplay = (props: { symptoms: Symptom[] }) => {
  const { symptoms = [] } = props;
  if (!symptoms.length) {
    return <NoticeBox>Nie wykryto symptomów.</NoticeBox>;
  }

  return (
    <Section title="Symptomy">
      {symptoms.map((symptom) => (
        <Collapsible
          key={symptom.name}
          title={symptom.name}
          color={symptom.neutered ? 'bad' : 'default'}
        >
          <SymptomInfo symptom={symptom} />
        </Collapsible>
      ))}
    </Section>
  );
};

/** Opis, progi i modyfikatory jednego symptomu (też w katalogu symptomów) */
export const SymptomInfo = (props: { symptom: Symptom }) => {
  const { symptom } = props;
  const { desc, threshold_desc, neutered } = symptom;

  return (
    <Stack fill>
      <Stack.Item grow={3}>
        {!!neutered && (
          <Box bold color="bad" mb={1}>
            Zneutralizowany
          </Box>
        )}
        {desc}
        <Thresholds thresholds={threshold_desc} />
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow={1}>
        <Traits symptom={symptom} />
      </Stack.Item>
    </Stack>
  );
};

/** Progi - w naszym DM threshold_desc to gotowy HTML */
const Thresholds = (props: { thresholds: string }) => {
  const { thresholds } = props;

  return (
    <Section mt={1} title="Progi">
      {!thresholds ? (
        <NoticeBox>Brak</NoticeBox>
      ) : (
        <div
          // eslint-disable-next-line react/no-danger
          dangerouslySetInnerHTML={{
            __html: thresholds,
          }}
        />
      )}
    </Section>
  );
};

/** Modyfikatory statystyk wirusa od symptomu */
const Traits = (props: { symptom: Symptom }) => {
  const {
    symptom: {
      level,
      resistance,
      stage_speed,
      stealth,
      transmission,
      severity,
    },
  } = props;

  return (
    <Section title="Modyfikatory">
      <LabeledList>
        <Tooltip content="Rzadkość symptomu.">
          <LabeledList.Item color={getColor(level)} label="Poziom">
            {level}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Ochrona przed lekami i naturalnym wyzdrowieniem.">
          <LabeledList.Item color={getColor(resistance)} label="Odporność">
            {resistance}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Tempo przechodzenia przez kolejne stadia.">
          <LabeledList.Item
            color={getColor(stage_speed)}
            label="Szybkość stadiów"
          >
            {stage_speed}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Trudność wykrycia sprzętem medycznym.">
          <LabeledList.Item color={getColor(stealth)} label="Ukrycie">
            {stealth}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Decyduje o sposobie rozprzestrzeniania.">
          <LabeledList.Item color={getColor(transmission)} label="Transmisja">
            {transmission}
          </LabeledList.Item>
        </Tooltip>
        <Tooltip content="Jak groźny jest symptom.">
          <LabeledList.Item color={getColor(severity)} label="Groźność">
            {severity}
          </LabeledList.Item>
        </Tooltip>
      </LabeledList>
    </Section>
  );
};
