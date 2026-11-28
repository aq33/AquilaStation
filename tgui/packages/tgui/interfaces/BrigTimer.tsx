import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  timing: BooleanLike;
  minutes: number;
  seconds: number;
  flash_charging: BooleanLike;
  prisoner: string | null;
  crimes: string | null;
  paused: BooleanLike;
  needs_prisoner: BooleanLike;
  can_pardon: BooleanLike;
};

export const BrigTimer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    timing,
    minutes,
    seconds,
    flash_charging,
    prisoner,
    crimes,
    paused,
    needs_prisoner,
    can_pardon,
  } = data;
  const locked = !!timing || !!paused;
  const blocked = !timing && !!needs_prisoner && !prisoner;
  return (
    <Window width={340} height={250}>
      <Window.Content scrollable>
        <Section
          title="Zegar celi"
          buttons={
            <>
              <Button
                icon="clock-o"
                selected={timing}
                disabled={blocked}
                tooltip={blocked ? 'Najpierw wpisz osadzonego' : undefined}
                onClick={() => act(timing ? 'stop' : 'start')}
              >
                {timing ? 'Zatrzymaj' : 'Uruchom'}
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
        <Section
          title="Osadzony"
          buttons={
            <>
              {locked && (
                <Button
                  icon={paused ? 'play' : 'pause'}
                  onClick={() => act(paused ? 'resume' : 'pause')}
                >
                  {paused ? 'Wznów' : 'Pauza'}
                </Button>
              )}
              <Button
                icon="gavel"
                disabled={!can_pardon}
                tooltip="Kapitan albo Komendant"
                onClick={() => act('pardon')}
              >
                Ułaskaw
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Imię"
              buttons={
                <Button
                  icon="user"
                  disabled={locked}
                  onClick={() => act('set_prisoner')}
                >
                  Wybierz
                </Button>
              }
            >
              {prisoner || 'brak'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Zarzuty"
              buttons={
                <Button icon="book" onClick={() => act('set_crimes')}>
                  Z kodeksu
                </Button>
              }
            >
              {crimes || 'brak'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
