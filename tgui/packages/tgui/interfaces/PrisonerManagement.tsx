// AQUILA - konsola zarządzania więźniami (aquila/code/game/machinery/computer/prisoner_management_ui.dm)
// Wygląd z tg, dane i akcje nasze (przyciski idą przez dawny Topic()).
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type PrisonerId = {
  name: string;
  points: number;
  goal: number;
  permanent: BooleanLike;
};

type ChemImplant = {
  name: string;
  volume: number;
  ref: string;
};

type TrackingImplant = {
  name: string;
  location: string;
  ref: string;
};

type Data = {
  logged_in: BooleanLike;
  prisoner_id: PrisonerId | null;
  chem_implants: ChemImplant[];
  tracking_implants: TrackingImplant[];
};

const ChemImplantDisplay = (props: { implant: ChemImplant }) => {
  const { act } = useBackend<Data>();
  const { implant } = props;

  return (
    <LabeledList>
      <LabeledList.Item label="Nosiciel">{implant.name}</LabeledList.Item>
      <LabeledList.Item label="Zapas">{implant.volume} j.</LabeledList.Item>
      <LabeledList.Item label="Wstrzyknij">
        {[1, 5, 10].map((amount) => (
          <Button
            key={amount}
            icon="syringe"
            color="bad"
            tooltip={`Wstrzyknij ${amount} j.`}
            onClick={() => act('inject', { ref: implant.ref, amount })}
          >
            {amount}
          </Button>
        ))}
      </LabeledList.Item>
      <LabeledList.Divider />
    </LabeledList>
  );
};

const TrackingImplantDisplay = (props: { implant: TrackingImplant }) => {
  const { act } = useBackend<Data>();
  const { implant } = props;

  return (
    <LabeledList>
      <LabeledList.Item label="Nosiciel">{implant.name}</LabeledList.Item>
      <LabeledList.Item label="Położenie">{implant.location}</LabeledList.Item>
      <LabeledList.Item label="Opcje">
        <Button
          icon="comment"
          tooltip="Wyślij wiadomość do nosiciela"
          onClick={() => act('warn', { ref: implant.ref })}
        >
          Wiadomość
        </Button>
      </LabeledList.Item>
      <LabeledList.Divider />
    </LabeledList>
  );
};

const AllImplantDisplay = () => {
  const { data } = useBackend<Data>();
  const { chem_implants = [], tracking_implants = [] } = data;
  const [implantTab, setImplantTab] = useState<'chem' | 'tracking'>('chem');

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            selected={implantTab === 'chem'}
            onClick={() => setImplantTab('chem')}
          >
            Chemiczne ({chem_implants.length})
          </Tabs.Tab>
          <Tabs.Tab
            selected={implantTab === 'tracking'}
            onClick={() => setImplantTab('tracking')}
          >
            Śledzące ({tracking_implants.length})
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        {implantTab === 'chem' &&
          (chem_implants.length === 0 ? (
            <NoticeBox>Nie wykryto implantów.</NoticeBox>
          ) : (
            chem_implants.map((implant) => (
              <ChemImplantDisplay key={implant.ref} implant={implant} />
            ))
          ))}
        {implantTab === 'tracking' &&
          (tracking_implants.length === 0 ? (
            <NoticeBox>Nie wykryto implantów.</NoticeBox>
          ) : (
            tracking_implants.map((implant) => (
              <TrackingImplantDisplay key={implant.ref} implant={implant} />
            ))
          ))}
      </Stack.Item>
    </Stack>
  );
};

const IdShowcase = (props: { id: PrisonerId | null }) => {
  const { act } = useBackend<Data>();
  const { id } = props;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <LabeledList>
          {id ? (
            <>
              <LabeledList.Item label="Karta">
                <Button
                  onClick={() => act('id', { action: 'eject' })}
                  icon="eject"
                  tooltip="Wyjmij kartę"
                  mr={1}
                />
                {id.name}
              </LabeledList.Item>
              <LabeledList.Item label="Punkty">
                <Stack align="center">
                  <Stack.Item>
                    <Button
                      onClick={() => act('id', { action: 'reset' })}
                      icon="times"
                      color="bad"
                      tooltip="Zeruj punkty"
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <ProgressBar
                      value={id.points}
                      maxValue={Math.max(id.goal, 1)}
                    >
                      {id.points} / {id.goal}
                    </ProgressBar>
                  </Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Cel">
                <Button
                  onClick={() => act('id', { action: 'setgoal' })}
                  icon="check"
                  tooltip="Ustaw cel"
                  mr={1}
                />
                {id.goal}
                {/* AQUILA: kara stała albo tymczasowa */}
                <Button
                  ml={1}
                  icon={id.permanent ? 'lock' : 'clock'}
                  onClick={() => act('id', { action: 'setpermanent' })}
                >
                  {id.permanent ? 'Stała' : 'Tymczasowa'}
                </Button>
              </LabeledList.Item>
            </>
          ) : (
            <LabeledList.Item label="Karta">
              <Button
                icon="id-card"
                onClick={() => act('id', { action: 'insert' })}
              >
                Brak karty — włóż
              </Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Stack.Item>
      {!!id && (
        <Stack.Item>
          <NoticeBox>
            Prawo Kosmiczne zaleca 100 punktów za każdą minutę, którą więzień
            spędziłby w areszcie.
          </NoticeBox>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ManagementConsole = () => {
  const { act, data } = useBackend<Data>();

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Karta więźnia">
          <IdShowcase id={data.prisoner_id} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Implanty ochrony" scrollable fill>
          <AllImplantDisplay />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox align="right" info>
          Zabezpiecz stanowisko.
          <Button icon="lock" color="good" ml={2} onClick={() => act('lock')}>
            Wyloguj
          </Button>
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

const LogIn = () => {
  const { act } = useBackend<Data>();

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center" grow={2}>
          <Icon color="average" name="exclamation-triangle" size={15} />
        </Stack.Item>
        <Stack.Item align="center" grow>
          <Box color="red" fontSize="18px" bold mt={5}>
            Nanotrasen SecurityHUB
          </Box>
        </Stack.Item>
        <Stack.Item>
          <NoticeBox align="right">
            Nie jesteś zalogowany. Wymagany dostęp do aresztu.
            <Button ml={2} icon="lock-open" onClick={() => act('lock')}>
              Zaloguj
            </Button>
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const PrisonerManagement = () => {
  const { data } = useBackend<Data>();
  const { logged_in } = data;
  return (
    <Window width={465} height={565} title="Zarządzanie więźniami">
      <Window.Content>
        {logged_in ? <ManagementConsole /> : <LogIn />}
      </Window.Content>
    </Window>
  );
};
