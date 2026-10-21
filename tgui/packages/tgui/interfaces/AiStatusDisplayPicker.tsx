import { useState } from 'react';
import {
  Box,
  DmIcon,
  Flex,
  ImageButton,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type StatusDisplayOption = {
  name: string;
  icon_state: string;
  icon: string;
};

type CurrentIcon = {
  icon: string;
  icon_state: string;
};

type Data = {
  current_emotion: string | null;
  current_icon: CurrentIcon | null;
  options: StatusDisplayOption[];
};

/** Polskie nazwy emocji; do DM idzie oryginalna nazwa */
const EMOTION_LABELS: Record<string, string> = {
  'Very Happy': 'Bardzo szczęśliwa',
  Happy: 'Szczęśliwa',
  Neutral: 'Neutralna',
  Unsure: 'Niepewna',
  Confused: 'Zdezorientowana',
  Sad: 'Smutna',
  BSOD: 'BSOD',
  Blank: 'Pusty ekran',
  'Problems?': 'Problem?',
  Awesome: 'Super',
  Facepalm: 'Facepalm',
  Thinking: 'Myśli',
  'Friend Computer': 'Przyjaciel Komputer',
  Dorfy: 'Krasnolud',
  'Blue Glow': 'Niebieska poświata',
  'Red Glow': 'Czerwona poświata',
};

const emotionLabel = (name: string) => EMOTION_LABELS[name] || name;

export const AiStatusDisplayPicker = () => {
  return (
    <Window width={500} height={600} title="Ekrany statusu SI">
      <Window.Content scrollable>
        <AiStatusDisplayPickerContent />
      </Window.Content>
    </Window>
  );
};

const AiStatusDisplayPickerContent = () => {
  const { data } = useBackend<Data>();
  const { current_emotion, current_icon, options = [] } = data;

  const [searchTerm, setSearchTerm] = useState('');

  const filteredOptions = options.filter((option) =>
    emotionLabel(option.name).toLowerCase().includes(searchTerm.toLowerCase()),
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Obecnie wyświetlane">
          <Flex align="center" justify="center" direction="column">
            {current_icon && (
              <Flex.Item mb={2}>
                <Box
                  style={{
                    border: '2px solid #4a9eff',
                    borderRadius: '4px',
                    backgroundColor: '#1a1a1a',
                    padding: '8px',
                  }}
                >
                  <DmIcon
                    icon={current_icon.icon}
                    icon_state={current_icon.icon_state}
                    width="64px"
                    height="64px"
                  />
                </Box>
              </Flex.Item>
            )}
            <Flex.Item mb={1}>
              <Box fontSize="1.4em" textAlign="center" bold color="good">
                {current_emotion ? emotionLabel(current_emotion) : 'Brak'}
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section>
          <Input
            fluid
            placeholder="Szukaj emocji..."
            value={searchTerm}
            onChange={(value) => setSearchTerm(value)}
          />
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill vertical>
          {filteredOptions.length > 0 && (
            <Stack.Item>
              <Section title="Emocje SI">
                <OptionsList options={filteredOptions} />
              </Section>
            </Stack.Item>
          )}

          {filteredOptions.length === 0 && (
            <Stack.Item>
              <Box textAlign="center" color="average" mt={4}>
                Nic nie pasuje do „{searchTerm}”
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const OptionsList = ({ options }: { options: StatusDisplayOption[] }) => {
  const { act } = useBackend<Data>();

  return (
    <>
      {options.map((option) => (
        <ImageButton
          key={option.name}
          dmIcon={option.icon}
          dmIconState={option.icon_state}
          onClick={() => act('select_option', { option: option.name })}
          imageSize={64}
          tooltip={emotionLabel(option.name)}
        >
          {emotionLabel(option.name)}
        </ImageButton>
      ))}
    </>
  );
};
