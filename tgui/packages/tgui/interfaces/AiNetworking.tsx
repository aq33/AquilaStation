import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  label: string;
  connected: string | null;
  locked: BooleanLike;
  possible_targets: string[];
};

// Port Yogstation (AiNetworking.js)
export const AiNetworking = (props) => {
  const { act, data } = useBackend<Data>();
  const { label, connected, locked, possible_targets = [] } = data;

  if (locked) {
    return (
      <Window width={500} height={250} title="Nadajnik sieci SI">
        <Window.Content>
          <Section title="Blokada">
            <NoticeBox danger textAlign="center">
              Nadajnik zablokowany
            </NoticeBox>
            <Box textAlign="center">
              <Button
                icon="lock-open"
                color="good"
                tooltip="Bez połączenia inne nadajniki znów będą mogły się połączyć."
                onClick={() => act('toggle_lock')}
              >
                Odblokuj
              </Button>
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={500} height={450} title="Nadajnik sieci SI">
      <Window.Content scrollable>
        <Section
          title={`Nadajnik | ${label}`}
          buttons={
            <>
              <Button
                icon="lock"
                color="bad"
                tooltip="Bez połączenia nikt nie połączy się z tym nadajnikiem. Nie zrywa istniejącego połączenia."
                onClick={() => act('toggle_lock')}
              >
                Zablokuj
              </Button>
              <Button icon="pen" onClick={() => act('switch_label')}>
                Etykieta
              </Button>
            </>
          }
        >
          {possible_targets.length === 0 ? (
            <Box color="label">Brak nadajników w zasięgu.</Box>
          ) : (
            <LabeledList>
              {possible_targets.map((target) => (
                <LabeledList.Item
                  key={target}
                  label={target}
                  buttons={
                    connected === target ? (
                      <Button
                        icon="eject"
                        color="bad"
                        onClick={() => act('disconnect')}
                      >
                        Rozłącz
                      </Button>
                    ) : (
                      <Button
                        icon="wifi"
                        disabled={!!connected}
                        tooltip={
                          connected ? 'Najpierw rozłącz obecne połączenie.' : ''
                        }
                        tooltipPosition="left"
                        onClick={() => act('connect', { target_label: target })}
                      >
                        Połącz
                      </Button>
                    )
                  }
                />
              ))}
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
