import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  minutes: number;
  seconds: number;
  timing: BooleanLike;
  scanning: BooleanLike;
  sensitivity: number;
};

export const ProximitySensor = (props) => {
  const { act, data } = useBackend<Data>();
  const { minutes, seconds, timing, scanning, sensitivity } = data;
  return (
    <Window width={250} height={185}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Button
                icon={scanning ? 'lock' : 'unlock'}
                selected={scanning}
                onClick={() => act('scanning')}
              >
                {scanning ? 'Uzbrojony' : 'Rozbrojony'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Zasięg wykrywania">
              <Button
                icon="backward"
                disabled={scanning}
                onClick={() => act('sense', { range: -1 })}
              />{' '}
              {String(sensitivity).padStart(1, '1')}{' '}
              <Button
                icon="forward"
                disabled={scanning}
                onClick={() => act('sense', { range: 1 })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Automatyczne uzbrojenie"
          buttons={
            <Button
              icon="clock-o"
              selected={timing}
              disabled={scanning}
              onClick={() => act('time')}
            >
              {timing ? 'Stop' : 'Start'}
            </Button>
          }
        >
          <Button
            icon="fast-backward"
            disabled={scanning || timing}
            tooltip="-30 s"
            onClick={() => act('input', { adjust: -30 })}
          />
          <Button
            icon="backward"
            disabled={scanning || timing}
            tooltip="-1 s"
            onClick={() => act('input', { adjust: -1 })}
          />{' '}
          {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}{' '}
          <Button
            icon="forward"
            disabled={scanning || timing}
            tooltip="+1 s"
            onClick={() => act('input', { adjust: 1 })}
          />
          <Button
            icon="fast-forward"
            disabled={scanning || timing}
            tooltip="+30 s"
            onClick={() => act('input', { adjust: 30 })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
