import { LabeledList, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../backend';
import type { AirAlarmData } from './types';

const dangerMap = {
  0: {
    color: 'good',
    localStatusText: 'Optymalny',
  },
  1: {
    color: 'average',
    localStatusText: 'Uwaga',
  },
  2: {
    color: 'bad',
    localStatusText: 'Zagrożenie (wymagany zapas powietrza)',
  },
} as const;

// Nazwy przychodzą z DM po angielsku; gazy zostają jak są.
export const ENV_NAMES = {
  Pressure: 'Ciśnienie',
  Temperature: 'Temperatura',
};

export function AirAlarmStatus(props) {
  const { data } = useBackend<AirAlarmData>();
  // AQUILA: jak w naszej starej wersji - ukrywamy śladowe ilości gazów
  const entries = (data.environment_data || []).filter(
    (entry) => entry.value >= 0.01,
  );

  const localStatus = dangerMap[data.danger_level] || dangerMap[0];

  return (
    <Section title="Stan powietrza">
      <LabeledList>
        {entries.length <= 0 ? (
          <LabeledList.Item label="Ostrzeżenie" color="bad">
            Nie można pobrać próbki powietrza do analizy.
          </LabeledList.Item>
        ) : (
          <>
            {entries.map((entry) => {
              const status = dangerMap[entry.danger_level] || dangerMap[0];
              return (
                <LabeledList.Item
                  key={entry.name}
                  label={ENV_NAMES[entry.name] || entry.name}
                  color={status.color}
                >
                  {toFixed(entry.value, 2)} {entry.unit}
                </LabeledList.Item>
              );
            })}
            <LabeledList.Item label="Stan lokalny" color={localStatus.color}>
              {localStatus.localStatusText}
            </LabeledList.Item>
            <LabeledList.Item
              label="Stan obszaru"
              color={data.atmos_alarm || data.fire_alarm ? 'bad' : 'good'}
            >
              {(data.atmos_alarm && 'Alarm atmosferyczny') ||
                (data.fire_alarm && 'Alarm pożarowy') ||
                'W normie'}
            </LabeledList.Item>
          </>
        )}
        {!!data.emagged && (
          <LabeledList.Item label="Ostrzeżenie" color="bad">
            Zabezpieczenia wyłączone. Urządzenie może zachowywać się
            nieprawidłowo.
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
