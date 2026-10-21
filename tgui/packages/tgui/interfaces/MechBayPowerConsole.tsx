import {
  AnimatedNumber,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Cell = {
  charge: number;
  maxcharge: number;
};

type Mech = {
  name: string;
  health: number;
  maxhealth: number;
  cell: Cell | null;
};

type Data = {
  recharge_port?: {
    mech: Mech | null;
  };
};

const RANGES: Record<string, [number, number]> = {
  good: [0.7, Infinity],
  average: [0.3, 0.7],
  bad: [-Infinity, 0.3],
};

export const MechBayPowerConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { recharge_port } = data;
  const mech = recharge_port?.mech;
  const cell = mech?.cell;
  const noPort = (
    <NoticeBox>
      Nie wykryto portu zasilającego. Zsynchronizuj ponownie.
    </NoticeBox>
  );
  const noMech = <NoticeBox>Nie wykryto egzoszkieletu.</NoticeBox>;
  return (
    <Window width={400} height={200}>
      <Window.Content>
        <Section
          title="Stan egzoszkieletu"
          textAlign="center"
          buttons={
            <Button icon="sync" onClick={() => act('reconnect')}>
              Synchronizuj
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Integralność">
              {!recharge_port ? (
                noPort
              ) : !mech ? (
                noMech
              ) : (
                <ProgressBar
                  value={mech.health / mech.maxhealth}
                  ranges={RANGES}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Zasilanie">
              {!recharge_port ? (
                noPort
              ) : !mech ? (
                noMech
              ) : !cell ? (
                <NoticeBox>Brak zainstalowanego ogniwa.</NoticeBox>
              ) : (
                // Our cells hold raw charge units, not joules, so no formatEnergy like tg
                <ProgressBar
                  value={cell.charge / cell.maxcharge}
                  ranges={RANGES}
                >
                  <AnimatedNumber value={cell.charge} />
                  {' / ' + cell.maxcharge}
                </ProgressBar>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
