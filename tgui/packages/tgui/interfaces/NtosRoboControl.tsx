import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Bot = {
  name: string;
  mode: string;
  model: string;
  locat: string;
  bot_ref: string;
  mule_check: BooleanLike;
};

type Mule = {
  name: string;
  id: string;
  dest: string | null;
  power: number;
  home: string;
  load: string | null;
  autoReturn: BooleanLike;
  autoPickup: BooleanLike;
  reportDelivery: BooleanLike;
  mule_ref: string;
};

type Data = {
  botcount: number;
  bots: Bot[];
  have_id_slot: BooleanLike;
  id_owner: string;
  mules: Mule[];
};

// Część stanów botów przychodzi z DM po angielsku (get_mode_ui)
const BOT_MODE_NAMES: Record<string, string> = {
  Inactive: 'Nieaktywny',
  Idle: 'Bezczynny',
  Autonomous: 'Autonomiczny',
  Arresting: 'Aresztowanie',
  Patrolling: 'Patrolowanie',
  Cleaning: 'Sprzątanie',
  Repairing: 'Naprawa',
  Healing: 'Leczenie',
};

export const botModeName = (mode: string) => BOT_MODE_NAMES[mode] || mode;

const getMuleByRef = (mules: Mule[], ref: string) => {
  return mules?.find((mule) => mule.mule_ref === ref);
};

export const NtosRoboControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { bots, id_owner, have_id_slot, botcount } = data;
  return (
    <NtosWindow width={550} height={550}>
      <NtosWindow.Content scrollable>
        <Section
          title="Sterowanie robotami"
          buttons={
            // AQUILA: wysuwanie karty z czytnika urządzenia
            !!have_id_slot &&
            !!id_owner && (
              <Button icon="eject" onClick={() => act('ejectcard')}>
                Wysuń kartę
              </Button>
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Karta ID">
              {id_owner || 'Brak'}
            </LabeledList.Item>
            <LabeledList.Item label="Boty w zasięgu">
              {botcount}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {bots?.map((robot) => (
          <RobotInfo key={robot.bot_ref} robot={robot} />
        ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const RobotInfo = (props: { robot: Bot }) => {
  const { robot } = props;
  const { act, data } = useBackend<Data>();
  const mules = data.mules || [];
  // Get a mule object
  const mule = !!robot.mule_check && getMuleByRef(mules, robot.bot_ref);
  // Color based on type of a robot
  const color = robot.mule_check
    ? 'rgba(110, 75, 14, 1)'
    : 'rgba(74, 59, 140, 1)';
  return (
    <Section
      title={robot.name}
      style={{
        border: `4px solid ${color}`,
      }}
      buttons={
        mule && (
          <>
            <Button
              icon="play"
              tooltip="Jedź do celu."
              onClick={() =>
                act('go', {
                  robot: mule.mule_ref,
                })
              }
            />
            <Button
              icon="pause"
              tooltip="Zatrzymaj."
              onClick={() =>
                act('stop', {
                  robot: mule.mule_ref,
                })
              }
            />
            <Button
              icon="home"
              tooltip="Wróć do bazy."
              tooltipPosition="bottom-start"
              onClick={() =>
                act('home', {
                  robot: mule.mule_ref,
                })
              }
            />
          </>
        )
      }
    >
      <Stack>
        <Stack.Item grow={1} basis={0}>
          <LabeledList>
            <LabeledList.Item label="Model">{robot.model}</LabeledList.Item>
            <LabeledList.Item label="Położenie">{robot.locat}</LabeledList.Item>
            <LabeledList.Item label="Stan">
              {botModeName(robot.mode)}
            </LabeledList.Item>
            {mule && (
              <>
                <LabeledList.Item label="ID bota">{mule.id}</LabeledList.Item>
                <LabeledList.Item label="Ładunek">
                  {mule.load || 'brak'}
                </LabeledList.Item>
                <LabeledList.Item label="Baza">{mule.home}</LabeledList.Item>
                <LabeledList.Item label="Cel">
                  {mule.dest || 'brak'}
                </LabeledList.Item>
                <LabeledList.Item label="Zasilanie">
                  <ProgressBar
                    value={mule.power}
                    minValue={0}
                    maxValue={100}
                    ranges={{
                      good: [60, Infinity],
                      average: [20, 60],
                      bad: [-Infinity, 20],
                    }}
                  />
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Stack.Item>
        <Stack.Item width="150px">
          {mule && (
            <>
              <Button
                fluid
                onClick={() =>
                  act('destination', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Ustaw cel
              </Button>
              <Button
                fluid
                onClick={() =>
                  act('setid', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Ustaw ID
              </Button>
              <Button
                fluid
                onClick={() =>
                  act('sethome', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Ustaw bazę
              </Button>
              <Button
                fluid
                onClick={() =>
                  act('unload', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Rozładuj
              </Button>
              <Button.Checkbox
                fluid
                checked={mule.autoReturn}
                onClick={() =>
                  act('autoret', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Auto-powrót
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={mule.autoPickup}
                onClick={() =>
                  act('autopick', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Auto-odbiór
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={mule.reportDelivery}
                onClick={() =>
                  act('report', {
                    robot: mule.mule_ref,
                  })
                }
              >
                Raport dostawy
              </Button.Checkbox>
            </>
          )}
          {!mule && (
            <>
              <Button
                fluid
                onClick={() =>
                  act('patroloff', {
                    robot: robot.bot_ref,
                  })
                }
              >
                Zakończ patrol
              </Button>
              <Button
                fluid
                onClick={() =>
                  act('patrolon', {
                    robot: robot.bot_ref,
                  })
                }
              >
                Rozpocznij patrol
              </Button>
              <Button
                fluid
                onClick={() =>
                  act('summon', {
                    robot: robot.bot_ref,
                  })
                }
              >
                Wezwij
              </Button>
              <Button
                fluid
                onClick={() =>
                  act('ejectpai', {
                    robot: robot.bot_ref,
                  })
                }
              >
                Wysuń pAI
              </Button>
            </>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
