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

type CoreDisplayOption = {
  name: string;
  icon_state: string;
  icon: string;
};

type CurrentIcon = {
  icon: string;
  icon_state: string;
};

type Data = {
  current_display: string | null;
  current_icon: CurrentIcon | null;
  options: CoreDisplayOption[];
};

/** Nazwy specjalnych opcji, reszta to nazwy własne motywów */
const OPTION_LABELS: Record<string, string> = {
  Random: 'Losowy',
  Portrait: 'Portret',
};

const optionLabel = (name: string) => OPTION_LABELS[name] || name;

export const AiCoreDisplayPicker = () => {
  return (
    <Window width={500} height={600} title="Wygląd rdzenia SI">
      <Window.Content scrollable>
        <AiCoreDisplayPickerContent />
      </Window.Content>
    </Window>
  );
};

const AiCoreDisplayPickerContent = () => {
  const { data } = useBackend<Data>();
  const { current_display, current_icon, options = [] } = data;

  const [searchTerm, setSearchTerm] = useState('');

  const filteredOptions = options.filter((option) =>
    optionLabel(option.name).toLowerCase().includes(searchTerm.toLowerCase()),
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Obecny wygląd rdzenia">
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
            <Flex.Item>
              <Box fontSize="1.2em" textAlign="center" bold color="good">
                {current_display ? optionLabel(current_display) : 'Domyślny'}
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Input
          placeholder="Szukaj wyglądu..."
          value={searchTerm}
          onChange={(value) => setSearchTerm(value)}
          fluid
        />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Dostępne wyglądy rdzenia">
              <OptionsList options={filteredOptions} />
            </Section>
          </Stack.Item>

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

const OptionsList = ({ options }: { options: CoreDisplayOption[] }) => {
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
          tooltip={optionLabel(option.name)}
        >
          {optionLabel(option.name)}
        </ImageButton>
      ))}
    </>
  );
};
