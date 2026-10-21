import { useState } from 'react';
import { Button, Flex, Input, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  upper: string | null;
  lower: string | null;
  maxStatusLineLength: number;
};

/**
 * Układ jak tg (common/StatusDisplayControls), ale z naszym zestawem
 * obrazków (GLOB.approved_status_pictures) i akcjami programu.
 */
export const NtosStatus = (props) => {
  const { act, data } = useBackend<Data>();
  const { maxStatusLineLength } = data;
  const [upperText, setUpperText] = useState(data.upper || '');
  const [lowerText, setLowerText] = useState(data.lower || '');

  const setPicture = (picture: string) => act('stat_pic', { picture });

  return (
    <NtosWindow width={400} height={350}>
      <NtosWindow.Content>
        <Section>
          <Button
            icon="toggle-off"
            color="bad"
            onClick={() => setPicture('blank')}
          >
            Wyłącz
          </Button>
          <Button icon="space-shuttle" onClick={() => setPicture('shuttle')}>
            Czas przylotu promu
          </Button>
        </Section>
        <Section title="Grafika">
          <Button icon="flag" onClick={() => setPicture('default')}>
            Logo
          </Button>
          <Button icon="bell" onClick={() => setPicture('redalert')}>
            Czerwony alarm
          </Button>
          <Button
            icon="exclamation-triangle"
            onClick={() => setPicture('lockdown')}
          >
            Blokada
          </Button>
          <Button icon="biohazard" onClick={() => setPicture('biohazard')}>
            Zagrożenie biologiczne
          </Button>
        </Section>
        <Section title="Wiadomość">
          <Flex direction="column" align="stretch">
            <Flex.Item mb={1}>
              <Input
                fluid
                maxLength={maxStatusLineLength}
                placeholder="Górna linia"
                value={upperText}
                onChange={setUpperText}
              />
            </Flex.Item>
            <Flex.Item mb={1}>
              <Input
                fluid
                maxLength={maxStatusLineLength}
                placeholder="Dolna linia"
                value={lowerText}
                onChange={setLowerText}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="comment"
                onClick={() =>
                  act('setStatusMessage', { upperText, lowerText })
                }
              >
                Wyślij
              </Button>
            </Flex.Item>
          </Flex>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
