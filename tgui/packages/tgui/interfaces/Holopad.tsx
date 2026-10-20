import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  calling: BooleanLike;
  on_network: BooleanLike;
  on_cooldown: BooleanLike;
  allowed: BooleanLike;
  disk: BooleanLike;
  disk_record: BooleanLike;
  replay_mode: BooleanLike;
  loop_mode: BooleanLike;
  record_mode: BooleanLike;
  holo_calls: HoloCall[];
};

type HoloCall = {
  caller: string;
  connected: BooleanLike;
  ref: string;
};

export const Holopad = (props) => {
  const { act, data } = useBackend<Data>();
  const { calling } = data;

  return (
    <Window width={440} height={245}>
      {!!calling && (
        <Modal fontSize="36px" fontFamily="monospace">
          <Flex align="center">
            <Flex.Item mr={2} mt={2}>
              <Icon name="phone-alt" rotation={25} />
            </Flex.Item>
            <Flex.Item mr={2}>Łączenie...</Flex.Item>
          </Flex>
          <Box mt={2} textAlign="center" fontSize="24px">
            <Button
              lineHeight="40px"
              icon="times"
              color="bad"
              onClick={() => act('hang_up')}
            >
              Rozłącz
            </Button>
          </Box>
        </Modal>
      )}
      <Window.Content scrollable>
        <HolopadContent />
      </Window.Content>
    </Window>
  );
};

const HolopadContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on_network,
    on_cooldown,
    allowed,
    disk,
    disk_record,
    replay_mode,
    loop_mode,
    record_mode,
    holo_calls = [],
  } = data;

  return (
    <>
      <Section
        title="Holopad"
        buttons={
          <Button
            icon="bell"
            disabled={!on_network || on_cooldown}
            onClick={() => act('AIrequest')}
          >
            {on_cooldown ? 'Wezwano SI' : 'Wezwij SI'}
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Łączność">
            <Button
              icon="phone-alt"
              disabled={!on_network}
              onClick={() => act('holocall', { headcall: allowed })}
            >
              {allowed ? 'Połącz z holopadem' : 'Zadzwoń na holopad'}
            </Button>
          </LabeledList.Item>
          {holo_calls.map((call) => {
            return (
              <LabeledList.Item
                label={
                  call.connected
                    ? 'Trwające połączenie'
                    : 'Połączenie przychodzące'
                }
                key={call.ref}
              >
                <Button
                  icon={call.connected ? 'phone-slash' : 'phone-alt'}
                  color={call.connected ? 'bad' : 'good'}
                  disabled={!on_network}
                  onClick={() =>
                    act(call.connected ? 'disconnectcall' : 'connectcall', {
                      holopad: call.ref,
                    })
                  }
                >
                  {call.connected
                    ? `Rozłącz: ${call.caller}`
                    : `Odbierz od: ${call.caller}`}
                </Button>
              </LabeledList.Item>
            );
          })}
          {holo_calls.filter((call) => !call.connected).length > 0 && (
            <LabeledList.Item key="reject">
              <Button
                icon="phone-slash"
                color="bad"
                onClick={() => act('rejectall')}
              >
                Odrzuć połączenia przychodzące
              </Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section
        title="Holodysk"
        buttons={
          <Button
            icon="eject"
            disabled={!disk || replay_mode || record_mode}
            onClick={() => act('disk_eject')}
          >
            Wysuń
          </Button>
        }
      >
        {(!disk && <NoticeBox>Brak holodysku</NoticeBox>) || (
          <LabeledList>
            <LabeledList.Item label="Odtwarzacz">
              <Button
                icon={replay_mode ? 'pause' : 'play'}
                selected={replay_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('replay_mode')}
              >
                {replay_mode ? 'Stop' : 'Odtwórz'}
              </Button>
              <Button
                icon="sync"
                selected={loop_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('loop_mode')}
              >
                {loop_mode ? 'Zapętlone' : 'Zapętl'}
              </Button>
              <Button
                icon="exchange-alt"
                disabled={!replay_mode}
                onClick={() => act('offset')}
              >
                Zmień przesunięcie
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Nagrywarka">
              <Button
                icon={record_mode ? 'pause' : 'video'}
                selected={record_mode}
                disabled={(disk_record && !record_mode) || replay_mode}
                onClick={() => act('record_mode')}
              >
                {record_mode ? 'Zakończ nagrywanie' : 'Nagrywaj'}
              </Button>
              <Button
                icon="trash"
                color="bad"
                disabled={!disk_record || replay_mode || record_mode}
                onClick={() => act('record_clear')}
              >
                Wyczyść nagranie
              </Button>
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </>
  );
};
