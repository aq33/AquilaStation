import {
  AnimatedNumber,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  // AQUILA: jedna maszyna grzeje albo chłodzi, przełącznik trybu
  cooling: BooleanLike;
  initial: number;
  max: number;
  min: number;
  pressure: number;
  target: number;
  temperature: number;
};

export const ThermoMachine = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={300} height={270}>
      <Window.Content>
        <Section title="Stan">
          <LabeledList>
            <LabeledList.Item label="Temperatura">
              <AnimatedNumber
                value={data.temperature}
                format={(value) => toFixed(value, 2)}
              />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Item label="Ciśnienie">
              <AnimatedNumber
                value={data.pressure}
                format={(value) => toFixed(value, 2)}
              />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Sterowanie"
          buttons={
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'Wł.' : 'Wył.'}
              selected={data.on}
              onClick={() => act('power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Tryb">
              <Button
                icon={data.cooling ? 'snowflake' : 'fire'}
                content={data.cooling ? 'Chłodzenie' : 'Grzanie'}
                selected={data.cooling}
                onClick={() => act('cooling')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Temperatura docelowa">
              <NumberInput
                animated
                tickWhileDragging
                value={Math.round(data.target)}
                unit="K"
                width="62px"
                minValue={Math.round(data.min)}
                maxValue={Math.round(data.max)}
                step={5}
                stepPixelSize={3}
                onChange={(value) =>
                  act('target', {
                    target: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Ustawienia">
              <Button
                icon="fast-backward"
                disabled={data.target === data.min}
                tooltip="Temperatura minimalna"
                onClick={() =>
                  act('target', {
                    target: data.min,
                  })
                }
              />
              <Button
                icon="sync"
                disabled={data.target === data.initial}
                tooltip="Temperatura pokojowa"
                onClick={() =>
                  act('target', {
                    target: data.initial,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={data.target === data.max}
                tooltip="Temperatura maksymalna"
                onClick={() =>
                  act('target', {
                    target: data.max,
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
