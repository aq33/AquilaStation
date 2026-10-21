import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';

type Data = {
  filter_types: Filter[];
  on: BooleanLike;
  rate: number;
  max_rate: number;
};

// AQUILA: nasz filtr odsiewa jeden gaz naraz (DM: filter_type),
// więc zamiast przełączników wielu gazów z tg jest wybór jednego.
type Filter = {
  id: string;
  name: string;
  selected: BooleanLike;
};

export const AtmosFilter = (props) => {
  const { act, data } = useBackend<Data>();
  const { filter_types = [], on, rate, max_rate } = data;

  return (
    <Window width={440} height={240}>
      <Window.Content>
        <Section
          buttons={
            <Button
              icon={on ? 'power-off' : 'times'}
              content={on ? 'Wł.' : 'Wył.'}
              selected={on}
              onClick={() => act('power')}
            />
          }
          fill
          title="Filtr gazów"
        >
          <LabeledList>
            <LabeledList.Item label="Przepływ">
              <NumberInput
                animated
                tickWhileDragging
                step={1}
                value={rate}
                width="63px"
                unit="L/s"
                minValue={0}
                maxValue={max_rate}
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
                disabled={rate === max_rate}
                onClick={() =>
                  act('rate', {
                    rate: 'max',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Odsiewany gaz">
              {filter_types.map(({ id, name, selected }) => (
                <Button
                  key={id || 'none'}
                  icon={selected ? 'check-square-o' : 'square-o'}
                  selected={selected}
                  onClick={() =>
                    act('filter', {
                      mode: id,
                    })
                  }
                >
                  {id ? getGasLabel(id, name) : 'Nic'}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
