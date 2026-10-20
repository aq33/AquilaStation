import type { Dispatch, SetStateAction } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import {
  AALARM_MODE_PANIC,
  AALARM_MODE_SCRUBBING,
  type AirAlarmData,
  type AlarmScreen,
} from '../types';

type Props = {
  setScreen?: Dispatch<SetStateAction<AlarmScreen>>;
};

export function AirAlarmControlHome(props: Props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { setScreen } = props;
  if (!setScreen) {
    throw new Error('setScreen is required');
  }

  const { atmos_alarm, mode } = data;

  const isPanicSiphoning = mode === AALARM_MODE_PANIC;
  return (
    <Stack vertical>
      <Stack.Item>
        <Button
          icon={atmos_alarm ? 'exclamation-triangle' : 'exclamation'}
          color={atmos_alarm && 'caution'}
          onClick={() => act(atmos_alarm ? 'reset' : 'alarm')}
        >
          Alarm atmosferyczny obszaru
        </Button>
      </Stack.Item>
      <Stack.Item mb={1}>
        <Button
          icon={isPanicSiphoning ? 'exclamation-triangle' : 'exclamation'}
          color={isPanicSiphoning && 'danger'}
          onClick={() =>
            act('mode', {
              mode: isPanicSiphoning
                ? AALARM_MODE_SCRUBBING
                : AALARM_MODE_PANIC,
            })
          }
        >
          Awaryjne wysysanie
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="sign-out-alt" onClick={() => setScreen('vents')}>
          Wentylacja
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="filter" onClick={() => setScreen('scrubbers')}>
          Scrubbery
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="cog" onClick={() => setScreen('modes')}>
          Tryb pracy
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="chart-bar" onClick={() => setScreen('thresholds')}>
          Progi alarmowe
        </Button>
      </Stack.Item>
    </Stack>
  );
}
