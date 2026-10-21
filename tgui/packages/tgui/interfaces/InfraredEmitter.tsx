import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  visible: BooleanLike;
};

export const InfraredEmitter = (props) => {
  const { act, data } = useBackend<Data>();
  const { on, visible } = data;

  return (
    <Window width={225} height={110}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Button
                icon={on ? 'power-off' : 'times'}
                selected={on}
                onClick={() => act('power')}
              >
                {on ? 'Włączony' : 'Wyłączony'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Wiązka">
              <Button
                icon={visible ? 'eye' : 'eye-slash'}
                selected={visible}
                onClick={() => act('visibility')}
              >
                {visible ? 'Widoczna' : 'Niewidoczna'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
