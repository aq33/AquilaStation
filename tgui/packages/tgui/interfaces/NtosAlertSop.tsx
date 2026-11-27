// AQUILA - program PDA „SOP”: co robić przy którym stanie okrętu (aquila/code/modules/security_levels/alert_sop.dm)
import { Box, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Level = {
  level: number;
  name: string;
  colour: string;
  rules: string[];
};

type Data = {
  levels: Level[];
  current: number;
};

export const NtosAlertSop = (props) => {
  const { data } = useBackend<Data>();
  const levels = data.levels || [];
  return (
    <NtosWindow width={420} height={560}>
      <NtosWindow.Content scrollable>
        {levels.map((entry) => {
          const active = entry.level === data.current;
          return (
            <Section
              key={entry.level}
              title={
                <Box color={entry.colour}>
                  {active && <Icon name="caret-right" mr={1} />}
                  {entry.name}
                </Box>
              }
              buttons={active && <Box color={entry.colour}>Obecny stan</Box>}
            >
              <Stack vertical>
                {entry.rules.map((rule) => (
                  <Stack.Item key={rule}>
                    <Icon name="check" color={entry.colour} mr={1} />
                    {rule}
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          );
        })}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
