import {
  Box,
  Button,
  ByondUi,
  Flex,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  mapRef: string;
  currentColor: number[];
};

const PRESETS = ['red', 'yellow', 'green', 'teal', 'blue', 'purple'] as const;

const PRESET_NAMES: Record<(typeof PRESETS)[number], string> = {
  red: 'Czerwony',
  yellow: 'Żółty',
  green: 'Zielony',
  teal: 'Morski',
  blue: 'Niebieski',
  purple: 'Fioletowy',
};

const colorToMatrix = (param: (typeof PRESETS)[number]) => {
  switch (param) {
    case 'red':
      return [
        1, 0, 0, 0, 0.25, 0.5, 0, 0, 0.25, 0, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'yellow':
      return [
        0.5, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0.25, 0.25, 0.5, 0, 0, 0, 0, 1, 0, 0, 0,
        0,
      ];
    case 'green':
      return [
        0.5, 0.25, 0, 0, 0, 1, 0, 0, 0, 0.25, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'teal':
      return [
        0.25, 0.25, 0.25, 0, 0, 0.5, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0, 0, 1, 0, 0,
        0, 0,
      ];
    case 'blue':
      return [
        0.25, 0, 0.25, 0, 0, 0.5, 0.25, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'purple':
      return [
        0.5, 0, 0.5, 0, 0.25, 0.5, 0.25, 0, 0.5, 0, 0.5, 0, 0, 0, 0, 1, 0, 0, 0,
        0,
      ];
  }
};

// Mianownik (nagłówek sekcji) i dopełniacz/nazwa kanału na suwaku
const CHANNELS = [
  { title: 'Czerwony', label: 'Czerwony' },
  { title: 'Zielony', label: 'Zielony' },
  { title: 'Niebieski', label: 'Niebieski' },
];

export const MODpaint = (props) => {
  const { act, data } = useBackend<Data>();
  const { mapRef, currentColor } = data;
  return (
    <Window width={600} height={365} title="Malowanie MOD">
      <Window.Content>
        <Stack fill>
          <Stack.Item width="30%">
            {[0, 1, 2].map((row) => (
              <Section
                key={row}
                title={`${CHANNELS[row].title} zmienia się w:`}
              >
                {[0, 1, 2].map((col) => (
                  <Flex key={col}>
                    <Flex.Item align="left" width="30%">
                      <Box inline textColor="label">
                        {`${CHANNELS[col].label}:`}
                      </Box>
                    </Flex.Item>
                    <Flex.Item align="right" width="70%">
                      <Slider
                        tickWhileDragging
                        inline
                        textAlign="right"
                        value={currentColor[row * 4 + col] * 100}
                        minValue={0}
                        maxValue={125}
                        step={1}
                        stepPixelSize={0.75}
                        format={(value) => `${value}%`}
                        onChange={(e, value) => {
                          const retColor = [...currentColor];
                          retColor[row * 4 + col] = value / 100;
                          act('transition_color', { color: retColor });
                        }}
                      />
                    </Flex.Item>
                  </Flex>
                ))}
              </Section>
            ))}
          </Stack.Item>
          <Stack.Item width="25%">
            <Section height="70%" title="Gotowe kolory">
              <Box textAlign="center">
                {PRESETS.map((preset) => (
                  <Button
                    key={preset}
                    height="50px"
                    width="50px"
                    color={preset}
                    tooltipPosition="top"
                    tooltip={PRESET_NAMES[preset]}
                    onClick={() =>
                      act('transition_color', { color: colorToMatrix(preset) })
                    }
                  />
                ))}
              </Box>
            </Section>
            <Section textAlign="center" fontSize="28px">
              <Button
                height="50px"
                width="50px"
                icon="question"
                color="average"
                tooltipPosition="top"
                tooltip="To macierz kolorów. Wyobraź sobie, że edytujesz obraz w trzech warstwach — czerwonej, zielonej i niebieskiej — zamiast zmieniać gotowy kolor jak w RGB."
              />
              <Button
                height="50px"
                width="50px"
                icon="check"
                color="good"
                tooltipPosition="top"
                tooltip="Zatwierdź zmiany!"
                onClick={() => act('confirm')}
              />
            </Section>
          </Stack.Item>
          <Stack.Item width="45%">
            <Section fill title="Podgląd">
              <ByondUi
                height="230px"
                params={{
                  id: mapRef,
                  type: 'map',
                }}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
