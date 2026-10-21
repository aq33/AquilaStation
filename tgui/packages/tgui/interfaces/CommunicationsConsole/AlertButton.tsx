import { Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { alertLevelName, SWIPE_NEEDED } from './constants';
import type { CommsConsoleData } from './types';

type Props = {
  alertLevel: string;
  onClick: () => void;
};

export function AlertButton(props: Props) {
  const { alertLevel, onClick } = props;

  const { act, data } = useBackend<CommsConsoleData>();
  const { canSetAlertLevel } = data;

  const thisIsCurrent = data.alertLevel === alertLevel;

  return (
    <Button
      icon="exclamation-triangle"
      color={thisIsCurrent && 'good'}
      onClick={() => {
        if (thisIsCurrent) {
          return;
        }

        if (canSetAlertLevel === SWIPE_NEEDED) {
          onClick();
        } else {
          act('changeSecurityLevel', {
            newSecurityLevel: alertLevel,
          });
        }
      }}
    >
      {alertLevelName(alertLevel)}
    </Button>
  );
}
