import { useState } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AirAlarmControl } from './AlarmControl';
import { AlarmEditingModal } from './AlarmModal';
import { AirAlarmStatus } from './AlarmStatus';
import { AlarmLockNoticeBox } from './LockNotice';
import type { ActiveModal, AirAlarmData } from './types';
import { ModalContext } from './useModal';

export function AirAlarm(props) {
  const { data } = useBackend<AirAlarmData>();
  const { thresholds = [] } = data;

  const locked = data.locked && !data.siliconUser;

  const modalState = useState<ActiveModal>();
  const [activeModal] = modalState;

  const oldValue = activeModal
    ? thresholds
        .find((threshold) =>
          threshold.settings.some((s) => s.env === activeModal.env),
        )
        ?.settings.find((s) => s.val === activeModal.typeVar)?.selected
    : undefined;

  return (
    <ModalContext.Provider value={modalState}>
      <Window width={475} height={650}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item mb={-1}>
              <AlarmLockNoticeBox />
            </Stack.Item>
            <Stack.Item>
              <AirAlarmStatus />
            </Stack.Item>
            <Stack.Item grow>{!locked && <AirAlarmControl />}</Stack.Item>
          </Stack>
          {activeModal && (
            <AlarmEditingModal oldValue={oldValue ?? -1} {...activeModal} />
          )}
        </Window.Content>
      </Window>
    </ModalContext.Provider>
  );
}
