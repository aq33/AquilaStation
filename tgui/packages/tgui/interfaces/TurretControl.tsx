import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type Data = {
  enabled: BooleanLike;
  lethal: BooleanLike;
  locked: BooleanLike;
  shootCyborgs: BooleanLike;
  siliconUser: BooleanLike;
};

export const TurretControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { enabled, lethal, locked, siliconUser, shootCyborgs } = data;
  const isLocked = locked && !siliconUser;

  return (
    <Window width={305} height={siliconUser ? 168 : 164}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section>
          <LabeledList>
            <LabeledList.Item label="Wieżyczki">
              <Button
                icon={enabled ? 'power-off' : 'times'}
                selected={enabled}
                disabled={isLocked}
                onClick={() => act('power')}
              >
                {enabled ? 'Włączone' : 'Wyłączone'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Tryb">
              <Button
                icon={lethal ? 'exclamation-triangle' : 'minus-circle'}
                color={lethal ? 'bad' : 'average'}
                disabled={isLocked}
                onClick={() => act('mode')}
              >
                {lethal ? 'Zabójczy' : 'Ogłuszający'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Strzelaj do cyborgów">
              <Button
                icon={shootCyborgs ? 'check' : 'times'}
                selected={shootCyborgs}
                disabled={isLocked}
                onClick={() => act('shoot_silicons')}
              >
                {shootCyborgs ? 'Tak' : 'Nie'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
