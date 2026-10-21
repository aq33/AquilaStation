// AQUILA - pluskwa kamerowa (code/game/objects/items/devices/camera_bug.dm).
// tg usunęło pluskwę, więc to własne okno w miejsce dawnego HTML:
// lista kamer, analiza obrazu z kamery i śledzenie celu.
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Tryby jak BUGMODE_* w camera_bug.dm
const MODE_LIST = 0;
const MODE_MONITOR = 1;
const MODE_TRACK = 2;

type Camera = {
  name: string;
  ref: string;
  bugged: BooleanLike;
};

type Seen = {
  name: string;
  extra?: string;
  ref: string;
};

type Data = {
  mode: number;
  viewing: BooleanLike;
  cameras: Camera[];
  current_name?: string;
  camera_active?: BooleanLike;
  seen?: Seen[];
  tracked_name?: string;
  last_found?: string;
  last_found_ref?: string;
  last_found_bugged?: BooleanLike;
  last_seen?: string;
};

export const CameraBug = (props) => {
  const { data } = useBackend<Data>();
  const { mode } = data;
  return (
    <Window width={460} height={520} title="Pluskwa kamerowa">
      <Window.Content scrollable>
        {mode === MODE_MONITOR ? (
          <Monitor />
        ) : mode === MODE_TRACK ? (
          <Tracking />
        ) : (
          <CameraList />
        )}
      </Window.Content>
    </Window>
  );
};

const CancelViewButton = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Button
      icon="eye-slash"
      disabled={!data.viewing}
      onClick={() => act('view')}
    >
      Wyłącz podgląd
    </Button>
  );
};

const CameraList = (props) => {
  const { act, data } = useBackend<Data>();
  const cameras = data.cameras || [];
  return (
    <Section title="Wybierz kamerę" buttons={<CancelViewButton />}>
      {cameras.length === 0 ? (
        <NoticeBox>Nie znaleziono podsłuchiwanych kamer.</NoticeBox>
      ) : (
        <Table>
          {cameras.map((camera) => (
            <Table.Row key={camera.ref} className="candystripe">
              <Table.Cell>
                <Button
                  fluid
                  ellipsis
                  icon="video"
                  onClick={() => act('view', { ref: camera.ref })}
                >
                  {camera.name}
                </Button>
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="search"
                  onClick={() => act('monitor', { ref: camera.ref })}
                >
                  Analizuj
                </Button>
                {!!camera.bugged && (
                  <Button
                    icon="bolt"
                    color="bad"
                    onClick={() => act('emp', { ref: camera.ref })}
                  >
                    Wyłącz
                  </Button>
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const Monitor = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_name, camera_active } = data;
  const seen = data.seen || [];
  return (
    <Section
      title={`Analiza kamery „${current_name}”`}
      buttons={
        <Button icon="list" onClick={() => act('mode', { mode: MODE_LIST })}>
          Wybierz kamerę
        </Button>
      }
    >
      {!camera_active ? (
        <NoticeBox danger>Kamera wyłączona.</NoticeBox>
      ) : seen.length === 0 ? (
        <NoticeBox>Nie wykryto ruchu.</NoticeBox>
      ) : (
        <Table>
          {seen.map((thing) => (
            <Table.Row key={thing.ref} className="candystripe">
              <Table.Cell>
                {thing.name}
                {!!thing.extra && (
                  <Box inline color="label" ml={1}>
                    ({thing.extra})
                  </Box>
                )}
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="crosshairs"
                  onClick={() => act('track', { ref: thing.ref })}
                >
                  Śledź
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const Tracking = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    tracked_name,
    last_found,
    last_found_ref,
    last_found_bugged,
    last_seen,
  } = data;
  return (
    <Section
      title={`Śledzenie: ${tracked_name}`}
      buttons={
        <>
          <Button icon="times" onClick={() => act('mode', { mode: MODE_LIST })}>
            Przerwij śledzenie
          </Button>
          <CancelViewButton />
        </>
      }
    >
      {!last_found ? (
        <NoticeBox>Jeszcze niewidziany.</NoticeBox>
      ) : (
        <LabeledList>
          <LabeledList.Item
            label="Ostatnio widziany w pobliżu"
            buttons={
              !!last_found_bugged && (
                <Button
                  icon="bolt"
                  color="bad"
                  onClick={() => act('emp', { ref: last_found_ref })}
                >
                  Wyłącz
                </Button>
              )
            }
          >
            {last_found_ref ? (
              <Button
                icon="video"
                onClick={() => act('view', { ref: last_found_ref })}
              >
                {last_found}
              </Button>
            ) : (
              last_found
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Kiedy">{last_seen}</LabeledList.Item>
        </LabeledList>
      )}
    </Section>
  );
};
