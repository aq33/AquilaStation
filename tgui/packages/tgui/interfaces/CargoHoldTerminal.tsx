import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  points: number;
  pad: BooleanLike;
  sending: BooleanLike;
  status_report: string;
};

export const CargoHoldTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { points, pad, sending, status_report } = data;

  return (
    <Window width={600} height={230}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Wartość ładunku">
              <Box inline bold>
                <AnimatedNumber value={Math.round(points)} /> kredytów
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Platforma ładunkowa"
          buttons={
            <>
              <Button icon="sync" disabled={!pad} onClick={() => act('recalc')}>
                Przelicz wartość
              </Button>
              <Button
                icon={sending ? 'times' : 'arrow-up'}
                selected={sending}
                disabled={!pad}
                onClick={() => act(sending ? 'stop' : 'send')}
              >
                {sending ? 'Przerwij wysyłkę' : 'Wyślij towar'}
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan" color={pad ? 'good' : 'bad'}>
              {pad ? 'Online' : 'Nie znaleziono'}
            </LabeledList.Item>
            <LabeledList.Item label="Raport ładunku">
              {status_report}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
