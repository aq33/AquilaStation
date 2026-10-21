import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { BeakerReagent } from './common/BeakerDisplay';

type Data = {
  active: BooleanLike;
  maxSetting: number;
  setting: number;
  TankContents: BeakerReagent[];
  TankCurrentVolume: number | null;
  TankMaxVolume: number;
  isTankLoaded: BooleanLike;
};

export const SmokeMachine = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    setting,
    maxSetting,
    TankContents = [],
    TankCurrentVolume,
    TankMaxVolume,
  } = data;
  const currentVolume = TankCurrentVolume || 0;

  return (
    <Window width={350} height={350}>
      <Window.Content>
        <Section
          title="Zbiornik rozpylacza"
          buttons={
            <Button
              icon={active ? 'power-off' : 'times'}
              selected={active}
              onClick={() => act('power')}
            >
              {active ? 'Wł.' : 'Wył.'}
            </Button>
          }
        >
          <ProgressBar
            value={currentVolume / TankMaxVolume}
            ranges={{
              bad: [-Infinity, 0.3],
            }}
          >
            <AnimatedNumber initial={0} value={currentVolume} />
            {` / ${TankMaxVolume} u`}
          </ProgressBar>
          <Box mt={1}>
            <LabeledList>
              <LabeledList.Item label="Zasięg">
                {[1, 2, 3, 4, 5].map((amount) => (
                  <Button
                    disabled={maxSetting < amount}
                    icon="plus"
                    key={amount}
                    onClick={() => act('setting', { amount })}
                    selected={setting === amount}
                  >
                    {amount * 3}
                  </Button>
                ))}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
        <Section
          title="Zawartość"
          buttons={
            <Button icon="trash" onClick={() => act('purge')}>
              Opróżnij
            </Button>
          }
        >
          {TankContents.length === 0 && <Box color="label">Pusto</Box>}
          {TankContents.map((chemical) => (
            <Box key={chemical.name} color="label">
              {chemical.name}:{' '}
              <AnimatedNumber initial={0} value={chemical.volume} /> u
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
