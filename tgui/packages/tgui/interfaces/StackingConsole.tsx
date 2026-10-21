import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Sheet = {
  type: string;
  name: string;
  amount: number;
};

type Data = {
  machine: BooleanLike;
  stacking_amount: number | null;
  input_direction: string;
  output_direction: string;
  contents: Sheet[];
};

// dir2text() z DM zwraca angielskie nazwy kierunków
const DIRECTIONS: Record<string, string> = {
  north: 'Północ',
  south: 'Południe',
  east: 'Wschód',
  west: 'Zachód',
  northeast: 'Północny wschód',
  northwest: 'Północny zachód',
  southeast: 'Południowy wschód',
  southwest: 'Południowy zachód',
};

const dirName = (dir: string) => DIRECTIONS[dir] || dir || 'Nieznany';

export const StackingConsole = (props) => {
  const { data } = useBackend<Data>();
  const { machine } = data;
  return (
    <Window width={320} height={340}>
      <Window.Content scrollable>
        {!machine ? (
          <NoticeBox>Brak podłączonej maszyny układającej</NoticeBox>
        ) : (
          <StackingConsoleContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const StackingConsoleContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    input_direction,
    output_direction,
    stacking_amount,
    contents = [],
  } = data;
  return (
    <>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Wielkość stosu">
            {stacking_amount || 'Nieznana'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Wejście"
            buttons={
              <Button icon="rotate" onClick={() => act('rotate', { input: 1 })}>
                Obróć
              </Button>
            }
          >
            {dirName(input_direction)}
          </LabeledList.Item>
          <LabeledList.Item
            label="Wyjście"
            buttons={
              <Button icon="rotate" onClick={() => act('rotate', { input: 0 })}>
                Obróć
              </Button>
            }
          >
            {dirName(output_direction)}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Zgromadzone materiały">
        {!contents.length ? (
          <NoticeBox>Brak zgromadzonych materiałów</NoticeBox>
        ) : (
          <LabeledList>
            {contents.map((sheet) => (
              <LabeledList.Item
                key={sheet.type}
                label={sheet.name}
                buttons={
                  <Button
                    icon="eject"
                    onClick={() =>
                      act('release', {
                        type: sheet.type,
                      })
                    }
                  >
                    Wydaj
                  </Button>
                }
              >
                {sheet.amount || 'Nieznana'}
              </LabeledList.Item>
            ))}
          </LabeledList>
        )}
      </Section>
    </>
  );
};
