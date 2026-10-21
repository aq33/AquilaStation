// AQUILA - alarmy stacji dla SI, na wzór StationAlertConsole z tg (widok z kamerami).
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Camera = {
  name: string;
  ref: string;
};

type Alert = {
  name: string;
  sources: number;
  cameras: Camera[];
};

type Category = {
  name: string;
  alerts: Alert[];
};

type Data = {
  alarms: Category[];
};

const ALARM_CLASSES: Record<string, { order: number; title: string }> = {
  Fire: { order: 0, title: 'Alarmy pożarowe' },
  Atmosphere: { order: 1, title: 'Alarmy atmosferyczne' },
  Power: { order: 2, title: 'Alarmy zasilania' },
  Burglar: { order: 3, title: 'Alarmy włamaniowe' },
  Motion: { order: 4, title: 'Alarmy ruchu' },
  Camera: { order: 5, title: 'Alarmy kamer' },
};

export const AiStationAlerts = (props) => {
  const { act, data } = useBackend<Data>();
  const sortedAlarms = [...(data.alarms || [])].sort(
    (a, b) =>
      (ALARM_CLASSES[a.name]?.order ?? 99) -
      (ALARM_CLASSES[b.name]?.order ?? 99),
  );

  return (
    <Window width={420} height={587}>
      <Window.Content scrollable>
        {sortedAlarms.map((category) => (
          <Section
            key={category.name}
            title={
              ALARM_CLASSES[category.name]?.title || `Alarmy: ${category.name}`
            }
          >
            {category.alerts.length === 0 && (
              <Box color="good">Wszystkie systemy działają prawidłowo</Box>
            )}
            {category.alerts.map((alert) => (
              <Stack key={alert.name} align="baseline" mb={0.5}>
                <Stack.Item grow color="average">
                  {alert.name}
                  {alert.sources > 1 && ` (źródła: ${alert.sources})`}
                </Stack.Item>
                <Stack.Item>
                  {alert.cameras.length === 0 ? (
                    <Button disabled width="100px" textAlign="center">
                      Brak kamery
                    </Button>
                  ) : (
                    alert.cameras.map((camera) => (
                      <Button
                        key={camera.ref}
                        icon="video"
                        onClick={() =>
                          act('select_camera', { camera: camera.ref })
                        }
                      >
                        {camera.name}
                      </Button>
                    ))
                  )}
                </Stack.Item>
              </Stack>
            ))}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
