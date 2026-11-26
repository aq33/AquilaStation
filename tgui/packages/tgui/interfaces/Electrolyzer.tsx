import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: okno elektrolizera z tg (plan maszynowni E6), maszyna w aquila/code/modules/atmospherics/machinery/electrolyzer/

type Data = {
  hasPowercell: BooleanLike;
  on: BooleanLike;
  open: BooleanLike;
  anchored: BooleanLike;
  powerLevel: number;
};

export const Electrolyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const { hasPowercell, on, open, anchored, powerLevel } = data;

  return (
    <Window width={400} height={160}>
      <Window.Content>
        <Section
          title="Zasilanie"
          buttons={
            <>
              <Button
                icon="eject"
                content="Wyjmij ogniwo"
                disabled={!hasPowercell || !open}
                onClick={() => act('eject')}
              />
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'Wł.' : 'Wył.'}
                selected={on}
                disabled={!hasPowercell && !anchored}
                onClick={() => act('power')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Ogniwo" color={!hasPowercell ? 'bad' : ''}>
              {(hasPowercell && (
                <ProgressBar
                  value={powerLevel / 100}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }}
                />
              )) ||
                'Brak'}
            </LabeledList.Item>
            <LabeledList.Item label="Sieć">
              {anchored ? 'Przykręcony do sieci' : 'Na ogniwie'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
