import { NoticeBox, VirtualList } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { Vent } from '../AtmosDevices';
import type { AirAlarmData } from '../types';

export function AirAlarmControlVents(props) {
  const { data } = useBackend<AirAlarmData>();
  const { vents } = data;

  if (!vents || vents.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        Brak urządzeń do wyświetlenia
      </NoticeBox>
    );
  }

  return (
    <VirtualList>
      {vents.map((vent) => (
        <Vent key={vent.id_tag} {...vent} />
      ))}
    </VirtualList>
  );
}
