import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { botModeName } from './NtosRoboControl';

type Robot = {
  name: string;
  model: string;
  mode: string;
  hacked: BooleanLike;
  location: string;
  ref: string;
};

type Data = {
  robots: Robot[];
};

export const RemoteRobotControl = (props) => {
  return (
    <Window title="Zdalne sterowanie robotami" width={500} height={500}>
      <Window.Content scrollable>
        <RemoteRobotControlContent />
      </Window.Content>
    </Window>
  );
};

export const RemoteRobotControlContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { robots = [] } = data;
  if (!robots.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">Nie wykryto robotów</NoticeBox>
      </Section>
    );
  }
  return (
    <>
      {robots.map((robot) => {
        // Porównanie z surową wartością z DM (get_mode_ui)
        const mode = decodeHtmlEntities(robot.mode);
        return (
          <Section
            key={robot.ref}
            title={`${robot.name} (${robot.model})`}
            buttons={
              <>
                <Button
                  icon="tools"
                  onClick={() =>
                    act('interface', {
                      ref: robot.ref,
                    })
                  }
                >
                  Połącz
                </Button>
                <Button
                  icon="phone-alt"
                  onClick={() =>
                    act('callbot', {
                      ref: robot.ref,
                    })
                  }
                >
                  Wezwij
                </Button>
              </>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Stan">
                <Box
                  inline
                  color={
                    mode === 'Inactive'
                      ? 'bad'
                      : mode === 'Idle'
                        ? 'average'
                        : 'good'
                  }
                >
                  {botModeName(mode)}
                </Box>{' '}
                {!!robot.hacked && (
                  <Box inline color="bad">
                    (ZHAKOWANY)
                  </Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Położenie">
                {robot.location}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </>
  );
};
