import { Button, Flex, Input, Section } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';

type Data = {
  upperText: string;
  lowerText: string;
  maxStatusLineLength: number;
};

export function StatusDisplayControls(props) {
  const { act, data } = useBackend<Data>();
  const {
    upperText: initialUpper,
    lowerText: initialLower,
    maxStatusLineLength,
  } = data;

  const [upperText, setUpperText] = useSharedState(
    'statusUpperText',
    initialUpper,
  );
  const [lowerText, setLowerText] = useSharedState(
    'statusLowerText',
    initialLower,
  );

  return (
    <>
      <Section>
        <Button
          icon="toggle-off"
          color="bad"
          onClick={() => act('setStatusPicture', { picture: 'blank' })}
        >
          Wył.
        </Button>
        <Button
          icon="space-shuttle"
          color=""
          onClick={() => act('setStatusPicture', { picture: 'shuttle' })}
        >
          Shuttle ETA / Off
        </Button>
      </Section>

      <Section title="Grafika">
        <Button
          icon="flag"
          onClick={() => act('setStatusPicture', { picture: 'default' })}
        >
          Logo
        </Button>

        <Button
          icon="exclamation"
          onClick={() => act('setStatusPicture', { picture: 'currentalert' })}
        >
          Poziom alarmu
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
          icon="radiation"
          onClick={() => act('setStatusPicture', { picture: 'radiation' })}
        >
          Promieniowanie
        </Button>
      </Section>

      <Section title="Wiadomość">
        <Flex direction="column" align="stretch">
          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={upperText}
              onChange={setUpperText}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              fluid
              maxLength={maxStatusLineLength}
              value={lowerText}
              onChange={setLowerText}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              onClick={() => act('setStatusMessage', { upperText, lowerText })}
            >
              Wyślij
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </>
  );
}
