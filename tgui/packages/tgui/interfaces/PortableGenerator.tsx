import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: any;
  anchored: any;
  connected: any;
  current_heat: any;
  power_available: any;
  power_generated: any;
  power_output: any;
  ready_to_boot: any;
  sheet_name: any;
  sheets: any;
  stack_percent: any;
};

export const PortableGenerator = (props) => {
  const { act, data } = useBackend<Data>();
  const { stack_percent } = data;
  const stackPercentState =
    (stack_percent > 50 && 'good') ||
    (stack_percent > 15 && 'average') ||
    'bad';
  return (
    <Window width={450} height={340}>
      <Window.Content scrollable>
        {!data.anchored && (
          <NoticeBox>Generator nie jest przykręcony.</NoticeBox>
        )}
        <Section title="Stan">
          <LabeledList>
            <LabeledList.Item label="Włącznik">
              <Button
                icon={data.active ? 'power-off' : 'times'}
                onClick={() => act('toggle_power')}
                disabled={!data.ready_to_boot}
              >
                {data.active ? 'Wł.' : 'Wył.'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={`Arkusze: ${data.sheet_name}`}>
              <Box inline color={stackPercentState}>
                {data.sheets}
              </Box>
              {data.sheets >= 1 && (
                <Button
                  ml={1}
                  icon="eject"
                  disabled={data.active}
                  onClick={() => act('eject')}
                >
                  Wysuń
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Zużycie arkusza">
              <ProgressBar
                value={data.stack_percent / 100}
                ranges={{
                  good: [0.1, Infinity],
                  average: [0.01, 0.1],
                  bad: [-Infinity, 0.01],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Temperatura">
              {data.current_heat < 100 ? (
                <Box inline color="good">
                  W normie
                </Box>
              ) : data.current_heat < 200 ? (
                <Box inline color="average">
                  Uwaga
                </Box>
              ) : (
                <Box inline color="bad">
                  NIEBEZPIECZEŃSTWO
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Moc wyjściowa">
          <LabeledList>
            <LabeledList.Item label="Obecna moc">
              {data.power_output}
            </LabeledList.Item>
            <LabeledList.Item label="Regulacja mocy">
              <Button icon="minus" onClick={() => act('lower_power')}>
                {data.power_generated}
              </Button>
              <Button icon="plus" onClick={() => act('higher_power')}>
                {data.power_generated}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Dostępna moc">
              <Box inline color={!data.connected ? 'bad' : undefined}>
                {data.connected ? data.power_available : 'Niepodłączony'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
