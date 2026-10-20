import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Cyborg = {
  name: string;
  locked_down: BooleanLike;
  status: number;
  shell_discon: BooleanLike;
  integ: number;
  charge: number | null;
  module: string;
  upgrades: string;
  ref: string;
};

type Data = {
  card: BooleanLike;
  cyborgs: Cyborg[];
};

export const NtosCyborgRemoteMonitor = (props) => {
  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

// tg ma tu jeszcze zakładkę z logami pobieranymi przez zeskanowanie cyborga PDA;
// u nas nie ma takiego pobierania, więc zostaje sama lista jednostek.
export const NtosCyborgRemoteMonitorContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { card, cyborgs = [] } = data;

  if (!cyborgs.length) {
    return <NoticeBox>Nie wykryto żadnych cyborgów.</NoticeBox>;
  }

  return (
    <>
      {!card && (
        <NoticeBox>Część funkcji wymaga zalogowania kartą ID.</NoticeBox>
      )}
      {cyborgs.map((cyborg) => (
        <Section
          key={cyborg.ref}
          title={cyborg.name}
          buttons={
            <Button
              icon="terminal"
              color="blue"
              disabled={!card}
              onClick={() =>
                act('messagebot', {
                  ref: cyborg.ref,
                })
              }
            >
              Wyślij wiadomość
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">
              <Box
                color={
                  cyborg.status
                    ? 'bad'
                    : cyborg.locked_down
                      ? 'average'
                      : 'good'
                }
              >
                {cyborg.status
                  ? 'Brak odpowiedzi'
                  : cyborg.locked_down
                    ? 'Zablokowany'
                    : cyborg.shell_discon
                      ? 'Sprawny/rozłączony'
                      : 'Sprawny'}
              </Box>
            </LabeledList.Item>
            {cyborg.integ !== undefined && (
              <LabeledList.Item label="Stan">
                <Box
                  color={
                    cyborg.integ <= 25
                      ? 'bad'
                      : cyborg.integ <= 75
                        ? 'average'
                        : 'good'
                  }
                >
                  {cyborg.integ <= 0
                    ? 'Krytyczna awaria'
                    : cyborg.integ <= 25
                      ? 'Działanie zakłócone'
                      : cyborg.integ <= 75
                        ? 'Działanie ograniczone'
                        : 'Sprawny technicznie'}
                </Box>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Ładunek">
              <Box
                color={
                  cyborg.charge === null || cyborg.charge <= 30
                    ? 'bad'
                    : cyborg.charge <= 70
                      ? 'average'
                      : 'good'
                }
              >
                {typeof cyborg.charge === 'number'
                  ? `${cyborg.charge}%`
                  : 'Brak ogniwa'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Moduł">{cyborg.module}</LabeledList.Item>
            <LabeledList.Item label="Ulepszenia">
              {cyborg.upgrades}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};
