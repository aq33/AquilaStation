import { useState } from 'react';
import { Box, Button, Flex, Input, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { CommsConsoleData } from './types';

// Nasza wersja: DM obsługuje setStatusPicture/setStatusMessage z lineOne/lineTwo
// (wspólny StatusDisplayControls z tg używa innych kluczy danych).
export function PageChangingStatus(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const { maxStatusLineLength } = data;

  const [lineOne, setLineOne] = useState(data.lineOne || '');
  const [lineTwo, setLineTwo] = useState(data.lineTwo || '');

  return (
    <Box>
      <Section>
        <Flex direction="column">
          <Flex.Item>
            <Button
              icon="toggle-off"
              color="bad"
              onClick={() => act('setStatusPicture', { picture: 'blank' })}
            >
              Wyłącz
            </Button>
          </Flex.Item>

          <Flex.Item mt={1}>
            <Button
              icon="check-square-o"
              onClick={() => act('setStatusPicture', { picture: 'default' })}
            >
              Domyślny
            </Button>

            <Button
              icon="bell-o"
              onClick={() => act('setStatusPicture', { picture: 'redalert' })}
            >
              Alarm bojowy
            </Button>

            <Button
              icon="exclamation-triangle"
              onClick={() => act('setStatusPicture', { picture: 'lockdown' })}
            >
              Blokada
            </Button>

            <Button
              icon="biohazard"
              onClick={() => act('setStatusPicture', { picture: 'biohazard' })}
            >
              Zagrożenie biologiczne
            </Button>

            <Button
              icon="space-shuttle"
              onClick={() => act('setStatusPicture', { picture: 'shuttle' })}
            >
              Przylot promu
            </Button>
          </Flex.Item>
        </Flex>
      </Section>

      <Section title="Wiadomość">
        <Flex direction="column">
          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={lineOne}
              placeholder="Pierwsza linia"
              onChange={setLineOne}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={lineTwo}
              placeholder="Druga linia"
              onChange={setLineTwo}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              onClick={() =>
                act('setStatusMessage', {
                  lineOne,
                  lineTwo,
                })
              }
            >
              Wyświetl
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
}
