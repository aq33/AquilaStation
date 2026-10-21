import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  feedback: string;
  occupant: BooleanLike;
  occupant_name: string;
  occupant_status: number;
  open: BooleanLike;
};

export const ProbingConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { open, feedback, occupant, occupant_name, occupant_status } = data;
  return (
    <Window width={330} height={207} theme="abductor">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Raport maszyny">
              {feedback}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Skaner"
          buttons={
            <Button
              icon={open ? 'sign-out-alt' : 'sign-in-alt'}
              onClick={() => act('door')}
            >
              {open ? 'Zamknij' : 'Otwórz'}
            </Button>
          }
        >
          {(occupant && (
            <LabeledList>
              <LabeledList.Item label="Imię">{occupant_name}</LabeledList.Item>
              <LabeledList.Item
                label="Stan"
                color={
                  occupant_status === 3
                    ? 'bad'
                    : occupant_status === 2
                      ? 'average'
                      : 'good'
                }
              >
                {occupant_status === 3
                  ? 'Martwy'
                  : occupant_status === 2
                    ? 'Nieprzytomny'
                    : 'Przytomny'}
              </LabeledList.Item>
              <LabeledList.Item label="Eksperymenty">
                <Button
                  icon="thermometer"
                  onClick={() =>
                    act('experiment', {
                      experiment_type: 1,
                    })
                  }
                >
                  Sondowanie
                </Button>
                <Button
                  icon="brain"
                  onClick={() =>
                    act('experiment', {
                      experiment_type: 2,
                    })
                  }
                >
                  Sekcja
                </Button>
                <Button
                  icon="search"
                  onClick={() =>
                    act('experiment', {
                      experiment_type: 3,
                    })
                  }
                >
                  Analiza
                </Button>
              </LabeledList.Item>
            </LabeledList>
          )) || <NoticeBox>Brak obiektu badań</NoticeBox>}
        </Section>
      </Window.Content>
    </Window>
  );
};
