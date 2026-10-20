import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  connected: BooleanLike;
  minutes: number;
  seconds: number;
  timing: BooleanLike;
  power: number;
  poddoor: BooleanLike;
};

export const MassDriverControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { connected, minutes, seconds, timing, power, poddoor } = data;
  return (
    <Window width={300} height={connected ? 215 : 107}>
      <Window.Content>
        {!!connected && (
          <Section
            title="Automatyczny start"
            buttons={
              <Button
                icon="clock-o"
                selected={timing}
                onClick={() => act('time')}
              >
                {timing ? 'Zatrzymaj' : 'Rozpocznij'}
              </Button>
            }
          >
            <Button
              icon="fast-backward"
              disabled={!!timing}
              onClick={() => act('input', { adjust: -30 })}
            />
            <Button
              icon="backward"
              disabled={!!timing}
              onClick={() => act('input', { adjust: -1 })}
            />{' '}
            {String(minutes).padStart(2, '0')}:
            {String(seconds).padStart(2, '0')}{' '}
            <Button
              icon="forward"
              disabled={!!timing}
              onClick={() => act('input', { adjust: 1 })}
            />
            <Button
              icon="fast-forward"
              disabled={!!timing}
              onClick={() => act('input', { adjust: 30 })}
            />
          </Section>
        )}
        <Section
          title="Sterowanie"
          buttons={
            <Button
              icon="toggle-on"
              disabled={!!timing || !poddoor}
              onClick={() => act('door')}
            >
              Przełącz drzwi zewnętrzne
            </Button>
          }
        >
          {(!!connected && (
            <>
              <LabeledList>
                <LabeledList.Item
                  label="Moc"
                  buttons={
                    <Button
                      icon="bomb"
                      disabled={!!timing}
                      onClick={() => act('driver_test')}
                    >
                      Strzał próbny
                    </Button>
                  }
                >
                  <NumberInput
                    value={power}
                    width="40px"
                    step={0.25}
                    minValue={0.25}
                    maxValue={16}
                    onChange={(value) =>
                      act('set_power', {
                        power: value,
                      })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
              <Button
                fluid
                disabled={!!timing}
                mt={1.5}
                icon="arrow-up"
                textAlign="center"
                onClick={() => act('launch')}
              >
                Odpal
              </Button>
            </>
          )) || <Box color="bad">Brak podłączonej katapulty masowej</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};
