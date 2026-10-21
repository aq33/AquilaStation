import {
  BlockQuote,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  name: string;
  isDead: BooleanLike;
  isBraindead: BooleanLike;
  health: number;
  wireless: BooleanLike;
  radio: BooleanLike;
  wiping: BooleanLike;
  laws: string[];
};

export const Intellicard = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    name,
    isDead,
    isBraindead,
    health,
    wireless,
    radio,
    wiping,
    laws = [],
  } = data;
  const offline = isDead || isBraindead;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <Section
          title={name || 'Pusta karta'}
          buttons={
            !!name && (
              <Button
                icon="trash"
                disabled={isDead}
                onClick={() => act('wipe')}
              >
                {wiping ? 'Przerwij kasowanie' : 'Skasuj'}
              </Button>
            )
          }
        >
          {!!name && (
            <LabeledList>
              <LabeledList.Item label="Stan" color={offline ? 'bad' : 'good'}>
                {offline ? 'Wyłączona' : 'Działa'}
              </LabeledList.Item>
              <LabeledList.Item label="Integralność oprogramowania">
                <ProgressBar
                  value={health}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    good: [70, Infinity],
                    average: [50, 70],
                    bad: [-Infinity, 50],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Ustawienia">
                <Button
                  icon="signal"
                  selected={wireless}
                  onClick={() => act('wireless')}
                >
                  Łączność bezprzewodowa
                </Button>
                <Button
                  icon="microphone"
                  selected={radio}
                  onClick={() => act('radio')}
                >
                  Radio podprzestrzenne
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Prawa">
                {laws.map((law) => (
                  <BlockQuote key={law}>{law}</BlockQuote>
                ))}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
