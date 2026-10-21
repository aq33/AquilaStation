import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  rate: number;
  max_heat_transfer_rate: number;
};

export const AtmosTempPump = (props) => {
  const { act, data } = useBackend<Data>();
  const { on, rate, max_heat_transfer_rate } = data;

  return (
    <Window width={335} height={115}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Zasilanie">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'Wł.' : 'Wył.'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Transfer ciepła">
              <NumberInput
                animated
                value={rate}
                unit="%"
                width="75px"
                minValue={0}
                maxValue={max_heat_transfer_rate}
                step={1}
                onChange={(value) =>
                  act('rate', {
                    rate: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={rate === max_heat_transfer_rate}
                onClick={() =>
                  act('rate', {
                    rate: 'max',
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
