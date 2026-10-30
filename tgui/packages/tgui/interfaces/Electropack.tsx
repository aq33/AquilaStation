import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ElectropackData = {
  power: BooleanLike;
  frequency: number;
  code: number;
  minFrequency: number;
  maxFrequency: number;
};

export const Electropack = (props) => {
  const { act, data } = useBackend<ElectropackData>();
  const { power, code, frequency, minFrequency, maxFrequency } = data;
  return (
    <Window width={260} height={137}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Zasilanie">
              <Button
                icon={power ? 'power-off' : 'times'}
                selected={power}
                onClick={() => act('power')}
              >
                {power ? 'Wł.' : 'Wył.'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label="Częstotliwość"
              buttons={
                <Button
                  icon="sync"
                  onClick={() =>
                    act('reset', {
                      reset: 'freq',
                    })
                  }
                >
                  Resetuj
                </Button>
              }
            >
              <NumberInput
                animated
                tickWhileDragging
                unit="kHz"
                step={0.2}
                stepPixelSize={6}
                minValue={minFrequency / 10}
                maxValue={maxFrequency / 10}
                value={frequency / 10}
                format={(value) => toFixed(value, 1)}
                width="80px"
                onChange={(value) =>
                  act('freq', {
                    freq: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Kod"
              buttons={
                <Button
                  icon="sync"
                  onClick={() =>
                    act('reset', {
                      reset: 'code',
                    })
                  }
                >
                  Resetuj
                </Button>
              }
            >
              <NumberInput
                animated
                tickWhileDragging
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onChange={(value) =>
                  act('code', {
                    code: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
