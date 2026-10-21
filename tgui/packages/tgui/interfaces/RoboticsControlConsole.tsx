import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Cyborg = {
  name: string;
  ref: string;
  status: BooleanLike;
  locked_down: BooleanLike;
  emagged: BooleanLike;
  charge: number | null;
  module: string;
  synchronization: string | null;
};

type Drone = {
  name: string;
  ref: string;
  status: BooleanLike;
};

type Upload = {
  name: string;
  area: string;
  coords: string;
  ref: string;
};

type Data = {
  can_hack: BooleanLike;
  is_silicon: BooleanLike;
  cyborgs: Cyborg[];
  drones: Drone[];
  uploads: Upload[];
};

export const RoboticsControlConsole = (props) => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useSharedState('tab', 1);
  const {
    can_hack,
    is_silicon,
    cyborgs = [],
    drones = [],
    uploads = [],
  } = data;

  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}
          >
            Cyborgi ({cyborgs.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}
          >
            Drony ({drones.length})
          </Tabs.Tab>
          {/* AQUILA (Bee): lista konsol wgrywania praw SI */}
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 3}
            onClick={() => setTab(3)}
          >
            Konsole praw ({uploads.length})
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <Cyborgs cyborgs={cyborgs} can_hack={can_hack} />}
        {tab === 2 && <Drones drones={drones} />}
        {tab === 3 && <Uploads uploads={uploads} is_silicon={is_silicon} />}
      </Window.Content>
    </Window>
  );
};

type CyborgsProps = {
  cyborgs: Cyborg[];
  can_hack: BooleanLike;
};

const Cyborgs = (props: CyborgsProps) => {
  const { cyborgs, can_hack } = props;
  const { act } = useBackend<Data>();
  if (!cyborgs.length) {
    return <NoticeBox>Nie wykryto cyborgów w zakresie uprawnień</NoticeBox>;
  }
  return (
    <>
      {cyborgs.map((cyborg) => (
        <Section
          key={cyborg.ref}
          title={cyborg.name}
          buttons={
            <>
              {!!can_hack && !cyborg.emagged && (
                <Button
                  icon="terminal"
                  color="bad"
                  onClick={() =>
                    act('magbot', {
                      ref: cyborg.ref,
                    })
                  }
                >
                  Zhakuj
                </Button>
              )}
              <Button.Confirm
                icon={cyborg.locked_down ? 'unlock' : 'lock'}
                color={cyborg.locked_down ? 'good' : 'default'}
                confirmContent="Na pewno?"
                onClick={() =>
                  act('stopbot', {
                    ref: cyborg.ref,
                  })
                }
              >
                {cyborg.locked_down ? 'Odblokuj' : 'Zablokuj'}
              </Button.Confirm>
              <Button.Confirm
                icon="bomb"
                color="bad"
                confirmContent="Na pewno?"
                onClick={() =>
                  act('killbot', {
                    ref: cyborg.ref,
                  })
                }
              >
                Zdetonuj
              </Button.Confirm>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Box
                color={
                  cyborg.status
                    ? 'bad'
                    : cyborg.locked_down
                      ? 'average'
                      : 'good'
                }
              >
                {cyborg.status
                  ? 'Nie odpowiada'
                  : cyborg.locked_down
                    ? 'Zablokowany'
                    : 'W normie'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Ładunek">
              <Box
                color={
                  (cyborg.charge ?? 0) <= 30
                    ? 'bad'
                    : (cyborg.charge ?? 0) <= 70
                      ? 'average'
                      : 'good'
                }
              >
                {typeof cyborg.charge === 'number'
                  ? `${cyborg.charge}%`
                  : 'Brak ogniwa'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Moduł">{cyborg.module}</LabeledList.Item>
            <LabeledList.Item label="Nadrzędna SI">
              <Box color={cyborg.synchronization ? 'default' : 'average'}>
                {cyborg.synchronization || 'Brak'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};

const Drones = (props: { drones: Drone[] }) => {
  const { drones } = props;
  const { act } = useBackend<Data>();

  if (!drones.length) {
    return <NoticeBox>Nie wykryto dronów w zakresie uprawnień</NoticeBox>;
  }

  return (
    <>
      {drones.map((drone) => (
        <Section
          key={drone.ref}
          title={drone.name}
          buttons={
            <Button.Confirm
              icon="bomb"
              color="bad"
              confirmContent="Na pewno?"
              onClick={() =>
                act('killdrone', {
                  ref: drone.ref,
                })
              }
            >
              Zdetonuj
            </Button.Confirm>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Box color={drone.status ? 'bad' : 'good'}>
                {drone.status ? 'Nie odpowiada' : 'W normie'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};

type UploadsProps = {
  uploads: Upload[];
  is_silicon: BooleanLike;
};

// AQUILA (Bee): przycisk wyciągania klucza wgrywania usunięty, bo akcja
// "extract" jest wyłączona w DM (NSV13)
const Uploads = (props: UploadsProps) => {
  const { uploads, is_silicon } = props;
  if (is_silicon) {
    return (
      <NoticeBox>
        Ze względów bezpieczeństwa jednostki krzemowe nie mają tu dostępu
      </NoticeBox>
    );
  }
  if (!uploads.length) {
    return <NoticeBox>Nie wykryto konsol praw w zakresie uprawnień</NoticeBox>;
  }
  return (
    <>
      {uploads.map((upload) => (
        <Section
          key={upload.ref}
          title={upload.name[0].toUpperCase() + upload.name.substring(1)}
        >
          <LabeledList>
            <LabeledList.Item label="Położenie">{upload.area}</LabeledList.Item>
            <LabeledList.Item label="Współrzędne">
              {upload.coords}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};
