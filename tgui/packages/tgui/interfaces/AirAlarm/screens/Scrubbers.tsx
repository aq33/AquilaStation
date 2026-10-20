import { NoticeBox, VirtualList } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { Scrubber } from '../AtmosDevices';
import type { AirAlarmData } from '../types';

export function AirAlarmControlScrubbers(props) {
  const { data } = useBackend<AirAlarmData>();
  const { scrubbers } = data;

  if (!scrubbers || scrubbers.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        Brak urządzeń do wyświetlenia
      </NoticeBox>
    );
  }

  return (
    <VirtualList>
      {scrubbers.map((scrubber) => (
        <Scrubber key={scrubber.id_tag} {...scrubber} />
      ))}
    </VirtualList>
  );
}
