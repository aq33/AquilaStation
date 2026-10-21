import { Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  // Klucz to klasa alarmu z GLOB.alarms, wartość to nazwy obszarów
  alarms: Record<string, string[]>;
};

// Kolejność i nazwy klas alarmów (klucze przychodzą z DM)
const ALARM_CLASSES: Record<string, { order: number; title: string }> = {
  Fire: { order: 0, title: 'Alarmy pożarowe' },
  Atmosphere: { order: 1, title: 'Alarmy atmosferyczne' },
  Power: { order: 2, title: 'Alarmy zasilania' },
  Burglar: { order: 3, title: 'Alarmy włamaniowe' },
  Motion: { order: 4, title: 'Alarmy ruchu' },
  Camera: { order: 5, title: 'Alarmy kamer' },
};

export const StationAlertConsole = (props) => {
  return (
    <Window width={345} height={587}>
      <Window.Content scrollable>
        <StationAlertConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const StationAlertConsoleContent = (props) => {
  const { data } = useBackend<Data>();
  const alarms = data.alarms || {};

  const sortedClasses = Object.keys(alarms).sort(
    (a, b) => (ALARM_CLASSES[a]?.order ?? 99) - (ALARM_CLASSES[b]?.order ?? 99),
  );

  return (
    <>
      {sortedClasses.map((name) => {
        const alerts = alarms[name] || [];
        return (
          <Section
            key={name}
            title={ALARM_CLASSES[name]?.title || `Alarmy: ${name}`}
          >
            <ul>
              {alerts.length === 0 && (
                <li className="color-good">Systemy w normie</li>
              )}
              {alerts.map((alert) => (
                <li key={alert} className="color-average">
                  {alert}
                </li>
              ))}
            </ul>
          </Section>
        );
      })}
    </>
  );
};
