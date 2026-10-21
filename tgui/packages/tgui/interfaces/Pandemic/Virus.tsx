import { useBackend } from 'tgui/backend';
import {
  Box,
  Input,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { capitalizeFirst, decodeHtmlEntities } from 'tgui-core/string';

import { getColor } from './helpers';
import type { Data, Virus } from './types';

type Props = {
  virus: Virus;
};

/** Opis wirusa, a dla zaawansowanych także statystyki */
export const VirusDisplay = (props: Props) => {
  const { virus } = props;

  return (
    <Stack fill>
      <Stack.Item grow={3}>
        <Info virus={virus} />
      </Stack.Item>
      {!!virus.is_adv && (
        <>
          <Stack.Divider />
          <Stack.Item grow={1}>
            <Traits virus={virus} />
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

/** Nazwa, opis i pozostałe dane wirusa */
const Info = (props: Props) => {
  const { act } = useBackend<Data>();
  const {
    virus: {
      agent,
      can_rename,
      description,
      index,
      name,
      spread,
      danger,
      cure,
    },
  } = props;

  return (
    <LabeledList>
      <LabeledList.Item label="Nazwa">
        {can_rename ? (
          <Input
            placeholder="Wpisz nazwę"
            value={name === 'Unknown' ? '' : name}
            onBlur={(value) =>
              act('rename_disease', {
                index: index,
                name: value,
              })
            }
          />
        ) : (
          <Box color="bad">{decodeHtmlEntities(name)}</Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Opis">{description}</LabeledList.Item>
      <LabeledList.Item label="Czynnik">
        {capitalizeFirst(agent)}
      </LabeledList.Item>
      <LabeledList.Item label="Rozprzestrzenianie">{spread}</LabeledList.Item>
      {/* AQUILA - nasz DM wysyła też zagrożenie i lekarstwo */}
      <LabeledList.Item label="Zagrożenie">{danger}</LabeledList.Item>
      <LabeledList.Item label="Możliwe lekarstwo">{cure}</LabeledList.Item>
    </LabeledList>
  );
};

/** Statystyki zaawansowanego wirusa */
const Traits = (props: Props) => {
  const {
    virus: { resistance, stage_speed, stealth, transmission, symptom_severity },
  } = props;

  return (
    <Section title="Statystyki">
      <LabeledList>
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
        <Tooltip content="Ogólne zagrożenie, jakie niesie choroba.">
          <LabeledList.Item color={getColor(symptom_severity)} label="Groźność">
            {symptom_severity}
          </LabeledList.Item>
        </Tooltip>
      </LabeledList>
    </Section>
  );
};
