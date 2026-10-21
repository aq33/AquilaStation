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
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type PowerChannel = {
  title: string;
  powerLoad: string;
  status: number;
  topicParams: {
    auto: Record<string, number>;
    on: Record<string, number>;
    off: Record<string, number>;
  };
};

type Data = {
  chargeMode: boolean;
  chargingStatus: number;
  coverLocked: boolean;
  emergencyLights: boolean;
  externalPower: number;
  failTime: number;
  isOperating: boolean;
  locked: boolean;
  malfStatus: number;
  nightshiftLights: boolean;
  powerCellStatus: number | null;
  powerChannels: PowerChannel[];
  remoteAccess: boolean;
  siliconUser: boolean;
  totalLoad: string;
};

export const Apc = (props) => {
  return (
    <Window width={450} height={460}>
      <Window.Content scrollable>
        <ApcContent />
      </Window.Content>
    </Window>
  );
};

const powerStatusMap = {
  2: {
    color: 'good',
    externalPowerText: 'Zasilanie zewnętrzne',
    chargingText: 'W pełni naładowany',
  },
  1: {
    color: 'average',
    externalPowerText: 'Słabe zasilanie zewnętrzne',
    chargingText: 'Ładuje',
  },
  0: {
    color: 'bad',
    externalPowerText: 'Brak zasilania zewnętrznego',
    chargingText: 'Nie ładuje',
  },
};

const malfMap = {
  1: {
    icon: 'terminal',
    content: 'Nadpisz oprogramowanie',
    action: 'hack',
  },
  2: {
    icon: 'caret-square-down',
    content: 'Przenieś proces rdzenia',
    action: 'occupy',
  },
  3: {
    icon: 'caret-square-left',
    content: 'Wróć do głównego rdzenia',
    action: 'deoccupy',
  },
  4: {
    icon: 'caret-square-down',
    content: 'Przenieś proces rdzenia',
    action: 'occupy',
  },
};

const ApcContent = (props) => {
  const { act, data } = useBackend<Data>();
  const locked = data.locked && !data.siliconUser;
  const externalPowerStatus =
    powerStatusMap[data.externalPower] || powerStatusMap[0];
  const chargingStatus =
    powerStatusMap[data.chargingStatus] || powerStatusMap[0];
  const channelArray = data.powerChannels || [];
  const malfStatus = malfMap[data.malfStatus] || malfMap[1];
  const adjustedCellChange = (data.powerCellStatus || 0) / 100;
  if (data.failTime > 0) {
    return (
      <NoticeBox info textAlign="center" mb={0}>
        <b>
          <h3>AWARIA SYSTEMU</h3>
        </b>
        Regulatory wejścia/wyjścia uległy awarii! <br />
        Oczekiwanie na restart systemu.
        <br />
        Programowy restart za {data.failTime} s...
        <br />
        <br />
        <Button
          icon="sync"
          tooltip="Wymuś reset interfejsu."
          tooltipPosition="bottom"
          onClick={() => act('reboot')}
        >
          Restartuj teraz
        </Button>
      </NoticeBox>
    );
  }
  return (
    <>
      <InterfaceLockNoticeBox
        siliconUser={data.remoteAccess || data.siliconUser}
      />
      <Section title="Stan zasilania">
        <LabeledList>
          <LabeledList.Item
            label="Wyłącznik główny"
            color={externalPowerStatus.color}
            buttons={
              <Button
                icon={data.isOperating ? 'power-off' : 'times'}
                selected={data.isOperating && !locked}
                disabled={locked}
                onClick={() => act('breaker')}
              >
                {data.isOperating ? 'Wł.' : 'Wył.'}
              </Button>
            }
          >
            [ {externalPowerStatus.externalPowerText} ]
          </LabeledList.Item>
          <LabeledList.Item label="Ogniwo">
            <ProgressBar color="good" value={adjustedCellChange} />
          </LabeledList.Item>
          <LabeledList.Item
            label="Tryb ładowania"
            color={chargingStatus.color}
            buttons={
              <Button
                icon={data.chargeMode ? 'sync' : 'times'}
                disabled={locked}
                onClick={() => act('charge')}
              >
                {data.chargeMode ? 'Auto' : 'Wył.'}
              </Button>
            }
          >
            [ {chargingStatus.chargingText} ]
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Kanały zasilania">
        <LabeledList>
          {channelArray.map((channel) => {
            const { topicParams } = channel;
            return (
              <LabeledList.Item
                key={channel.title}
                label={channel.title}
                buttons={
                  <>
                    <Box
                      inline
                      mx={2}
                      color={channel.status >= 2 ? 'good' : 'bad'}
                    >
                      {channel.status >= 2 ? 'Wł.' : 'Wył.'}
                    </Box>
                    <Button
                      icon="sync"
                      selected={
                        !locked &&
                        (channel.status === 1 || channel.status === 3)
                      }
                      disabled={locked}
                      onClick={() => act('channel', topicParams.auto)}
                    >
                      Auto
                    </Button>
                    <Button
                      icon="power-off"
                      selected={!locked && channel.status === 2}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.on)}
                    >
                      Wł.
                    </Button>
                    <Button
                      icon="times"
                      selected={!locked && channel.status === 0}
                      disabled={locked}
                      onClick={() => act('channel', topicParams.off)}
                    >
                      Wył.
                    </Button>
                  </>
                }
              >
                {channel.powerLoad}
              </LabeledList.Item>
            );
          })}
          <LabeledList.Item label="Całkowite obciążenie">
            <b>{data.totalLoad}</b>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Inne"
        buttons={
          !!data.siliconUser && (
            <>
              {!!data.malfStatus && (
                <Button
                  icon={malfStatus.icon}
                  color="bad"
                  onClick={() => act(malfStatus.action)}
                >
                  {malfStatus.content}
                </Button>
              )}
              <Button icon="lightbulb-o" onClick={() => act('overload')}>
                Przeciąż
              </Button>
            </>
          )
        }
      >
        <LabeledList>
          <LabeledList.Item
            label="Blokada pokrywy"
            buttons={
              <Button
                tooltip="Pokrywę APC można podważyć łomem."
                icon={data.coverLocked ? 'lock' : 'unlock'}
                disabled={locked}
                onClick={() => act('cover')}
              >
                {data.coverLocked ? 'Załączona' : 'Zwolniona'}
              </Button>
            }
          />
          <LabeledList.Item
            label="Oświetlenie awaryjne"
            buttons={
              <Button
                tooltip="Gdy brak zasilania, światła korzystają z wewnętrznego ogniwa."
                icon="lightbulb-o"
                disabled={locked}
                onClick={() => act('emergency_lighting')}
              >
                {data.emergencyLights ? 'Włączone' : 'Wyłączone'}
              </Button>
            }
          />
          <LabeledList.Item
            label="Oświetlenie nocne"
            buttons={
              <Button
                tooltip="Przyciemnia światła, by zmniejszyć pobór energii."
                icon="lightbulb-o"
                disabled={locked}
                onClick={() => act('toggle_nightshift')}
              >
                {data.nightshiftLights ? 'Włączone' : 'Wyłączone'}
              </Button>
            }
          />
        </LabeledList>
      </Section>
    </>
  );
};
