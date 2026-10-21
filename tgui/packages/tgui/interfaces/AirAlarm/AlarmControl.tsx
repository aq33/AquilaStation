import { useState } from 'react';
import { Button, Section } from 'tgui-core/components';

import { AirAlarmControlHome } from './screens/Home';
import { AirAlarmControlModes } from './screens/Modes';
import { AirAlarmControlScrubbers } from './screens/Scrubbers';
import { AirAlarmControlThresholds } from './screens/Thresholds';
import { AirAlarmControlVents } from './screens/Vents';
import type { AlarmScreen } from './types';

export const AIR_ALARM_ROUTES = {
  home: {
    title: 'Sterowanie powietrzem',
    component: AirAlarmControlHome,
  },
  vents: {
    title: 'Wentylacja',
    component: AirAlarmControlVents,
  },
  scrubbers: {
    title: 'Scrubbery',
    component: AirAlarmControlScrubbers,
  },
  modes: {
    title: 'Tryb pracy',
    component: AirAlarmControlModes,
  },
  thresholds: {
    title: 'Progi alarmowe',
    component: AirAlarmControlThresholds,
  },
} as const;

export function AirAlarmControl(props) {
  const [screen, setScreen] = useState<AlarmScreen>('home');

  const route = AIR_ALARM_ROUTES[screen] || AIR_ALARM_ROUTES.home;
  const Component = route.component;
  const isHome = screen === 'home';

  return (
    <Section
      fill
      scrollable
      title={route.title}
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => setScreen('home')}
          disabled={isHome}
        >
          Wróć
        </Button>
      }
    >
      <Component {...(isHome && { setScreen })} />
    </Section>
  );
}
