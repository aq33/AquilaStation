import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DisposalUnitData = {
  flush: BooleanLike;
  full_pressure: BooleanLike;
  pressure_charging: BooleanLike;
  panel_open: BooleanLike;
  per: number;
  isai: BooleanLike;
};

export const DisposalUnit = (props) => {
  const { act, data } = useBackend<DisposalUnitData>();
  const { flush, full_pressure, pressure_charging, panel_open, per, isai } =
    data;
  let stateColor: string;
  let stateText: string;
  if (full_pressure) {
    stateColor = 'good';
    stateText = 'Gotowy';
  } else if (panel_open) {
    stateColor = 'bad';
    stateText = 'Zasilanie odłączone';
  } else if (pressure_charging) {
    stateColor = 'average';
    stateText = 'Nabijanie ciśnienia';
  } else {
    stateColor = 'bad';
    stateText = 'Wyłączony';
  }
  return (
    <Window title="Zsyp na śmieci" width={300} height={180}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Stan" color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item label="Ciśnienie">
              <ProgressBar value={per} color="good" />
            </LabeledList.Item>
            <LabeledList.Item label="Dźwignia">
              <Button
                icon={flush ? 'toggle-on' : 'toggle-off'}
                disabled={isai || panel_open}
                onClick={() => act(flush ? 'handle-0' : 'handle-1')}
              >
                {flush ? 'Zwolnij' : 'Pociągnij'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Wyrzut">
              <Button
                icon="sign-out-alt"
                disabled={isai}
                onClick={() => act('eject')}
              >
                Wyrzuć zawartość
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Zasilanie">
              <Button
                icon="power-off"
                disabled={panel_open}
                selected={pressure_charging}
                onClick={() => act(pressure_charging ? 'pump-0' : 'pump-1')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
