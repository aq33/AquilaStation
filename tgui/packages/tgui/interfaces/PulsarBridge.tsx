// AQUILA - mostek mocy pulsara (aquila/code/modules/power/pulsar.dm)
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  connected: boolean;
  has_console: boolean;
  percent: number;
  output_mw: number;
  reconnect_in: number;
  overcharge: boolean;
};

export const PulsarBridge = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    connected,
    has_console,
    percent,
    output_mw,
    reconnect_in,
    overcharge,
  } = data;
  return (
    <Window width={380} height={220}>
      <Window.Content>
        {!has_console && (
          <NoticeBox danger>Brak konsoli orbity pulsara na okręcie.</NoticeBox>
        )}
        {!!overcharge && (
          <NoticeBox danger>Satelita jest przeciążony!</NoticeBox>
        )}
        <Section
          title="Połączenie z satelitą"
          buttons={
            <Button
              icon={connected ? 'unlink' : 'link'}
              color={connected ? 'bad' : 'good'}
              disabled={!connected && reconnect_in > 0}
              onClick={() => act('toggle')}
            >
              {connected ? 'Rozłącz' : 'Połącz'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan">
              {connected
                ? 'Połączony'
                : reconnect_in > 0
                  ? `Rozłączony, połączenie możliwe za ${reconnect_in} s`
                  : 'Rozłączony'}
            </LabeledList.Item>
            <LabeledList.Item label="Moc">
              <ProgressBar value={percent / 100} maxValue={1.5}>
                {Math.round(percent)}% ({output_mw} MW)
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
