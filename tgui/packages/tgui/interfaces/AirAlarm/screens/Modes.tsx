import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { AirAlarmData } from '../types';

// AQUILA: DM wysyła opisy trybów po angielsku, tu po numerze trybu (AALARM_MODE_*).
const MODE_NAMES: Record<number, string> = {
  1: 'Filtrowanie – usuwa zanieczyszczenia',
  8: 'Skażenie – szybko usuwa WSZYSTKIE zanieczyszczenia',
  2: 'Przeciąg – wysysa powietrze, jednocześnie je uzupełniając',
  9: 'Uzupełnianie – potrójny wydmuch wentylacji',
  4: 'Wymiana – najpierw wysysa powietrze, potem je uzupełnia',
  7: 'Wysysanie – wysysa powietrze z pomieszczenia',
  3: 'Awaryjne wysysanie – szybko wysysa powietrze z pomieszczenia',
  5: 'Wyłączony – wyłącza wentylację i scrubbery',
  6: 'Zalanie – wyłącza scrubbery i otwiera wentylację',
};

export function AirAlarmControlModes(props) {
  const { act, data } = useBackend<AirAlarmData>();
  const { modes } = data;

  if (!modes || modes.length === 0) {
    return (
      <NoticeBox info textAlign="center">
        Brak trybów do wyświetlenia
      </NoticeBox>
    );
  }

  return (
    <Stack vertical>
      {modes.map((mode) => (
        <Stack.Item key={mode.mode}>
          <Button
            icon={mode.selected ? 'check-square-o' : 'square-o'}
            color={mode.selected && (mode.danger ? 'red' : 'green')}
            onClick={() => act('mode', { mode: mode.mode })}
          >
            {MODE_NAMES[mode.mode] || mode.name}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}
