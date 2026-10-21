import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

// AQUILA EDIT - układ z tg na naszych kluczach z mulebot.dm; bez zmiany
// nazwy i osobowości z ghostroli (nie mamy ich), ID i baza ustawiane w oknie.
type Data = {
  on: BooleanLike;
  cell: BooleanLike;
  cellPercent: number | null;
  load: string | null;
  locked: BooleanLike;
  siliconUser: BooleanLike;
  mode: string;
  modeStatus: string;
  autoReturn: BooleanLike;
  autoPickup: BooleanLike;
  reportDelivery: BooleanLike;
  destination: string | null;
  destinations: string[];
  home: string | null;
  id: string;
  haspai: BooleanLike;
};

const MuleControls = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    load,
    autoReturn,
    autoPickup,
    reportDelivery,
    destination,
    home,
    id,
    haspai,
    destinations = [],
  } = data;

  return (
    <>
      <Section
        title="Sterowanie"
        buttons={
          <>
            {!!load && (
              <Button icon="eject" onClick={() => act('unload')}>
                Rozładuj
              </Button>
            )}
            {!!haspai && (
              <Button icon="eject" onClick={() => act('ejectpai')}>
                Wyjmij pAI
              </Button>
            )}
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="ID">
            <Input
              width="188px"
              value={id}
              onBlur={(value) => act('setid', { value })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Baza">
            <Dropdown
              over
              selected={home || 'Brak'}
              options={destinations}
              width="188px"
              onSelected={(value) => act('sethome', { value })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Cel">
            <Dropdown
              over
              selected={destination || 'Brak'}
              options={destinations}
              width="188px"
              onSelected={(value) => act('destination', { value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Polecenia">
        <Stack style={{ padding: '0px 30px' }}>
          <Stack.Item grow>
            <Button
              width="70px"
              icon="stop"
              color="bad"
              onClick={() => act('stop')}
            >
              Stój
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              width="70px"
              icon="play"
              color="average"
              onClick={() => act('go')}
            >
              Jedź
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button width="70px" icon="home" onClick={() => act('home')}>
              Do bazy
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Ustawienia">
        <Button.Checkbox checked={autoReturn} onClick={() => act('autoret')}>
          Automatyczny powrót
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={autoPickup} onClick={() => act('autopick')}>
          Automatyczny załadunek
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={reportDelivery} onClick={() => act('report')}>
          Zgłaszaj dostawy
        </Button.Checkbox>
      </Section>
    </>
  );
};

export const Mule = (props) => {
  const { act, data } = useBackend<Data>();
  const { on, cell, cellPercent, load, mode, modeStatus, locked, siliconUser } =
    data;

  const mulebotLocked = locked && !siliconUser;

  return (
    <Window width={350} height={500}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox />
        <Section
          title="Stan"
          buttons={
            !mulebotLocked && (
              <Button
                icon={on ? 'power-off' : 'times'}
                selected={on}
                onClick={() => act('power')}
              >
                {on ? 'Wł.' : 'Wył.'}
              </Button>
            )
          }
        >
          <ProgressBar
            value={cell && cellPercent ? cellPercent / 100 : 0}
            color={cell ? 'good' : 'bad'}
          >
            {cell ? `${Math.round(cellPercent ?? 0)}%` : 'Brak ogniwa'}
          </ProgressBar>
          <Stack mt={1} vertical>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Tryb" color={modeStatus}>
                  {mode}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Ładunek"
                  color={load ? 'good' : 'average'}
                >
                  {load ? capitalize(load) : 'Brak'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        {!mulebotLocked && <MuleControls />}
      </Window.Content>
    </Window>
  );
};
