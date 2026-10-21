import { Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  timing: BooleanLike;
  minutes: number;
  seconds: number;
  flash_charging: BooleanLike;
};

export const BrigTimer = (props) => {
  const { act, data } = useBackend<Data>();
  const { timing, minutes, seconds, flash_charging } = data;
  return (
    <Window width={300} height={138}>
      <Window.Content scrollable>
        <Section
          title="Zegar celi"
          buttons={
            <>
              <Button
                icon="clock-o"
                selected={timing}
                onClick={() => act(timing ? 'stop' : 'start')}
              >
                {timing ? 'Stop' : 'Start'}
              </Button>
              <Button
                icon="lightbulb-o"
                disabled={flash_charging}
                onClick={() => act('flash')}
              >
                {flash_charging ? 'Ładowanie' : 'Flesz'}
              </Button>
            </>
          }
        >
          <Button
            icon="fast-backward"
            tooltip="-1 min"
            onClick={() => act('time', { adjust: -600 })}
          />
          <Button
            icon="backward"
            tooltip="-10 s"
            onClick={() => act('time', { adjust: -100 })}
          />{' '}
          {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}{' '}
          <Button
            icon="forward"
            tooltip="+10 s"
            onClick={() => act('time', { adjust: 100 })}
          />
          <Button
            icon="fast-forward"
            tooltip="+1 min"
            onClick={() => act('time', { adjust: 600 })}
          />
          <br />
          <Button
            icon="hourglass-start"
            onClick={() => act('preset', { preset: 'short' })}
          >
            Krótki
          </Button>
          <Button
            icon="hourglass-start"
            onClick={() => act('preset', { preset: 'medium' })}
          >
            Średni
          </Button>
          <Button
            icon="hourglass-start"
            onClick={() => act('preset', { preset: 'long' })}
          >
            Długi
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
