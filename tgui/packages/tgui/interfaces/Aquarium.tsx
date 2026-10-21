import {
  Button,
  DmIcon,
  Flex,
  Icon,
  Knob,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA EDIT - wygląd z tg na naszym prostszym akwarium: bez trybów,
// karmienia, głaskania i zmiany imion ryb; zostaje blokada rozmnażania.
type Data = {
  temperature: number;
  fluidType: string;
  minTemperature: number;
  maxTemperature: number;
  fluidTypes: string[];
  fishData: FishData[];
  propData: PropData[];
  allow_breeding: BooleanLike;
};

type FishData = {
  fish_ref: string;
  fish_name: string;
  fish_icon: string;
  fish_icon_state: string;
  fish_alive: BooleanLike;
  fish_health: number;
};

type PropData = {
  prop_ref: string;
  prop_name: string;
  prop_icon: string;
  prop_icon_state: string;
};

export const Aquarium = (props) => {
  const { data } = useBackend<Data>();
  const { fishData = [] } = data;

  return (
    <Window width={765} height={500} theme="ntos">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Settings />
          </Stack.Item>
          <Stack.Item grow>
            <Flex>
              <Flex.Item height="300px" width="75%">
                <Section fill title="Ryby" scrollable>
                  {fishData.length === 0 && (
                    <Stack.Item color="label">
                      W akwarium nie ma ryb.
                    </Stack.Item>
                  )}
                  <Stack wrap>
                    {fishData.map((fish) => (
                      <Stack.Item
                        width="44%"
                        height="80px"
                        ml={1}
                        mb={1}
                        key={fish.fish_ref}
                        style={{
                          background: 'rgba(36, 50, 67, 0.5)',
                          padding: '5px 5px',
                          borderRadius: '1em',
                          border: '3px solid #574e82',
                        }}
                      >
                        <FishInfo fish={fish} />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Flex.Item>
              <Flex.Item ml={1} grow>
                <PropTypes />
              </Flex.Item>
            </Flex>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type FishInfoProps = {
  fish: FishData;
};

const FishInfo = (props: FishInfoProps) => {
  const { act } = useBackend<Data>();
  const { fish } = props;

  return (
    <Flex>
      <Flex.Item width="40px">
        <DmIcon
          style={{ borderRadius: '1em', background: '#151326' }}
          icon={fish.fish_icon}
          icon_state={fish.fish_icon_state}
          height="40px"
          width="40px"
        />
      </Flex.Item>
      <Flex.Item grow>
        <Stack vertical>
          <Stack.Item ml={1} style={{ fontSize: '13px', fontWeight: 'bold' }}>
            {capitalizeFirst(fish.fish_name)}
          </Stack.Item>
          <Stack.Item ml={1}>
            {fish.fish_alive ? (
              <ProgressBar
                value={fish.fish_health}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [70, Infinity],
                  average: [30, 70],
                  bad: [-Infinity, 30],
                }}
              >
                Zdrowie: {Math.round(fish.fish_health)}%
              </ProgressBar>
            ) : (
              <>
                <Icon name="skull-crossbones" textColor="white" mr={1} />
                Martwa
              </>
            )}
          </Stack.Item>
        </Stack>
      </Flex.Item>
      <Flex.Item>
        <Button
          icon="arrow-up"
          color="transparent"
          tooltip="Wyjmij"
          onClick={() => act('remove', { ref: fish.fish_ref })}
        />
      </Flex.Item>
    </Flex>
  );
};

const PropTypes = (props) => {
  const { act, data } = useBackend<Data>();
  const { propData = [] } = data;

  return (
    <Section scrollable fill title="Dekoracje">
      <Stack vertical>
        {propData.map((prop) => (
          <Stack.Item className="candystripe" key={prop.prop_ref}>
            <Button
              fluid
              color="transparent"
              tooltip="Wyjmij"
              onClick={() => act('remove', { ref: prop.prop_ref })}
            >
              <Flex>
                <Flex.Item>
                  <DmIcon
                    icon={prop.prop_icon}
                    icon_state={prop.prop_icon_state}
                    height="40px"
                    width="40px"
                  />
                </Flex.Item>
                <Flex.Item
                  ml={1}
                  mt={1}
                  style={{ fontSize: '11px', fontWeight: 'bold' }}
                >
                  {capitalizeFirst(prop.prop_name)}
                </Flex.Item>
              </Flex>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const Settings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    temperature,
    minTemperature,
    maxTemperature,
    fluidTypes = [],
    fluidType,
    allow_breeding,
  } = data;

  return (
    <Flex fill>
      <Flex.Item grow>
        <Section fill title="Temperatura">
          <Knob
            mt={3}
            size={1.5}
            mb={1}
            value={temperature}
            unit="K"
            minValue={minTemperature}
            maxValue={maxTemperature}
            step={1}
            stepPixelSize={1}
            onChange={(_, value) =>
              act('temperature', {
                temperature: value,
              })
            }
          />
        </Section>
      </Flex.Item>
      <Flex.Item ml={1} grow>
        <Section fill title="Ciecz">
          <Flex direction="column" mb={1}>
            {fluidTypes.map((f) => (
              <Flex.Item className="candystripe" key={f}>
                <Button
                  textAlign="center"
                  fluid
                  color="transparent"
                  selected={fluidType === f}
                  onClick={() => act('fluid', { fluid: f })}
                >
                  {f}
                </Button>
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Flex.Item>
      <Flex.Item ml={1} grow>
        <Section fill title="Ustawienia">
          <LabeledList>
            <LabeledList.Item label="Blokada rozmnażania">
              <Button
                icon={allow_breeding ? 'unlock' : 'lock'}
                selected={!allow_breeding}
                onClick={() => act('allow_breeding')}
              >
                {allow_breeding ? 'Wyłączona' : 'Włączona'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Flex.Item>
    </Flex>
  );
};
