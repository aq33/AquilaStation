import { Button, Flex, NoticeBox } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

type Data = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
};

// AQUILA: polska wersja InterfaceLockNoticeBox tylko dla alarmu powietrza
// (common/InterfaceLockNoticeBox zostaje bez zmian, używają go inne okna).
export const AlarmLockNoticeBox = (props) => {
  const { act, data } = useBackend<Data>();
  const { siliconUser, locked } = data;
  if (siliconUser) {
    return (
      <NoticeBox color="grey">
        <Flex align="center">
          <Flex.Item>Blokada interfejsu:</Flex.Item>
          <Flex.Item grow={1} />
          <Flex.Item>
            <Button
              m={0}
              color={locked ? 'red' : 'green'}
              icon={locked ? 'lock' : 'unlock'}
              onClick={() => act('lock')}
            >
              {locked ? 'Zablokowany' : 'Odblokowany'}
            </Button>
          </Flex.Item>
        </Flex>
      </NoticeBox>
    );
  }
  return (
    <NoticeBox>
      Przeciągnij kartę ID, aby {locked ? 'odblokować' : 'zablokować'} ten
      interfejs.
    </NoticeBox>
  );
};
