import {
  AnimatedNumber,
  Box,
  Button,
  Divider,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  BossID: string;
  GameActive: BooleanLike;
  Hitpoints: number;
  PauseState: BooleanLike;
  PlayerHitpoints: number;
  PlayerMP: number;
  Status: string;
  TicketCount: number;
};

export function NtosArcade(props) {
  return (
    <NtosWindow width={450} height={350}>
      <NtosWindow.Content>
        <Section title="Outbomb Cuban Pete Ultra" textAlign="center">
          <Stack fill>
            <Stack.Item>
              <PlayerStats />
            </Stack.Item>
            <Stack.Item>
              <BossBar />
            </Stack.Item>
          </Stack>
          <BottomButtons />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function PlayerStats(props) {
  const { data } = useBackend<Data>();
  const { PauseState, PlayerHitpoints, PlayerMP, Status } = data;

  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Zdrowie gracza">
          <ProgressBar
            value={PlayerHitpoints}
            minValue={0}
            maxValue={30}
            ranges={{
              olive: [31, Infinity],
              good: [20, 31],
              average: [10, 20],
              bad: [-Infinity, 10],
            }}
          >
            {PlayerHitpoints} PŻ
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Mana gracza">
          <ProgressBar
            value={PlayerMP}
            minValue={0}
            maxValue={10}
            ranges={{
              purple: [11, Infinity],
              violet: [3, 11],
              bad: [-Infinity, 3],
            }}
          >
            {PlayerMP} PM
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <NoticeBox danger={!PauseState}>{Status}</NoticeBox>
    </>
  );
}

function BossBar(props) {
  const { data } = useBackend<Data>();
  const { BossID, Hitpoints } = data;

  return (
    <>
      <ProgressBar
        value={Hitpoints}
        minValue={0}
        maxValue={45}
        ranges={{
          good: [30, Infinity],
          average: [5, 30],
          bad: [-Infinity, 5],
        }}
      >
        <AnimatedNumber value={Hitpoints} /> PŻ
      </ProgressBar>
      <Box m={1} />
      <Section inline width="156px" textAlign="center">
        {/* Nasz DM wysyła już gotowy adres zasobu, więc bez resolveAsset. */}
        <img src={BossID} />
      </Section>
    </>
  );
}

function BottomButtons(props) {
  const { act, data } = useBackend<Data>();
  const { GameActive, PauseState, TicketCount } = data;

  return (
    <>
      <Button
        icon="fist-raised"
        tooltip="Rusz po zwycięstwo!"
        tooltipPosition="top"
        disabled={!GameActive || !!PauseState}
        onClick={() => act('Attack')}
      >
        Atak!
      </Button>
      <Button
        icon="band-aid"
        tooltip="Ulecz się!"
        tooltipPosition="top"
        disabled={!GameActive || !!PauseState}
        onClick={() => act('Heal')}
      >
        Lecz!
      </Button>
      <Button
        icon="magic"
        tooltip="Odnów manę!"
        tooltipPosition="top"
        disabled={!GameActive || !!PauseState}
        onClick={() => act('Recharge_Power')}
      >
        Odnów!
      </Button>
      <Box>
        <Button
          icon="sync-alt"
          tooltip="Jeszcze jedna partia nie zaszkodzi."
          tooltipPosition="top"
          disabled={!!GameActive}
          onClick={() => act('Start_Game')}
        >
          Nowa gra
        </Button>
      </Box>
      {/* tg wydaje tu bilety za zwycięstwa; u nas nie ma biletów, więc tylko licznik. */}
      <Box color={TicketCount >= 1 ? 'good' : 'normal'}>
        Wygrane partie: {TicketCount}
      </Box>
    </>
  );
}
