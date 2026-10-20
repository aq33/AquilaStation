import { map } from 'es-toolkit/compat';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type RadioData = {
  freqlock: BooleanLike;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
  listening: BooleanLike;
  broadcasting: BooleanLike;
  command: BooleanLike;
  useCommand: BooleanLike;
  subspace: BooleanLike;
  subspaceSwitchable: BooleanLike;
  channels: Record<string, BooleanLike>;
};

export const Radio = (props) => {
  const { act, data } = useBackend<RadioData>();
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    listening,
    broadcasting,
    command,
    useCommand,
    subspace,
    subspaceSwitchable,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find(
    (channel) => channel.freq === frequency,
  );
  const channels = map(data.channels, (value, key) => ({
    name: key,
    status: !!value,
  }));
  // Calculate window height
  let height = 105;
  if (channels.length > 0) {
    height += channels.length * 25 + 8;
  } else if (subspace) {
    height += 24;
  }
  return (
    <Window width={360} height={height}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Częstotliwość">
              {(freqlock && (
                <Box inline color="light-gray">
                  {`${toFixed(frequency / 10, 1)} kHz`}
                </Box>
              )) || (
                <NumberInput
                  animated
                  tickWhileDragging
                  unit="kHz"
                  step={0.2}
                  stepPixelSize={10}
                  minValue={minFrequency / 10}
                  maxValue={maxFrequency / 10}
                  value={frequency / 10}
                  format={(value) => toFixed(value, 1)}
                  onChange={(value) =>
                    act('frequency', {
                      adjust: value - frequency / 10,
                    })
                  }
                />
              )}
              {tunedChannel && (
                <Box inline color={tunedChannel.color} ml={2}>
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Dźwięk">
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                tooltip={listening ? 'Głośnik włączony' : 'Głośnik wyłączony'}
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                tooltip={
                  broadcasting ? 'Mikrofon włączony' : 'Mikrofon wyłączony'
                }
                onClick={() => act('broadcast')}
              />
              {!!command && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={useCommand}
                  onClick={() => act('command')}
                >
                  {`Wzmocnienie ${useCommand ? 'WŁ.' : 'WYŁ.'}`}
                </Button>
              )}
              {!!subspaceSwitchable && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={subspace}
                  onClick={() => act('subspace')}
                >
                  {`Podprzestrzeń ${subspace ? 'WŁ.' : 'WYŁ.'}`}
                </Button>
              )}
            </LabeledList.Item>
            {(!!subspace || channels.length > 0) && (
              <LabeledList.Item label="Kanały">
                {channels.length === 0 && (
                  <Box inline color="bad">
                    Brak kluczy szyfrujących.
                  </Box>
                )}
                <Stack vertical>
                  {channels.map((channel) => (
                    <Box key={channel.name}>
                      <Button
                        icon={channel.status ? 'check-square-o' : 'square-o'}
                        selected={channel.status}
                        onClick={() =>
                          act('channel', {
                            channel: channel.name,
                          })
                        }
                      >
                        {channel.name}
                      </Button>
                    </Box>
                  ))}
                </Stack>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
