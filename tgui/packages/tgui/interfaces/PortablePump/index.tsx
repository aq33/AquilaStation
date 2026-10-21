import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PortableBasicInfo, type PortableBasicInfoData } from './PortableAtmos';

// AQUILA: klucze danych w snake_case, jak wysyła nasz DM (portable/pump.dm).
type PortablePumpData = {
  direction: BooleanLike;
  target_pressure: number;
  default_pressure: number;
  min_pressure: number;
  max_pressure: number;
} & PortableBasicInfoData;

export const PortablePump = (props) => {
  const { act, data } = useBackend<PortablePumpData>();
  const {
    direction,
    connected,
    holding,
    target_pressure,
    default_pressure,
    min_pressure,
    max_pressure,
  } = data;
  const pump_or_port = connected ? 'Port' : 'Pompa';
  const area_or_tank = holding ? 'Zbiornik' : 'Otoczenie';
  return (
    <Window width={300} height={340}>
      <Window.Content>
        <PortableBasicInfo />
        <Section
          title="Pompowanie"
          buttons={
            <Button
              color={!direction && !holding ? 'caution' : null}
              onClick={() => act('direction')}
            >
              {direction
                ? `${area_or_tank} → ${pump_or_port}`
                : `${pump_or_port} → ${area_or_tank}`}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Wyjście">
              <NumberInput
                value={target_pressure}
                unit="kPa"
                width="75px"
                minValue={min_pressure}
                maxValue={max_pressure}
                step={10}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Ustawienia">
              <Button
                icon="minus"
                tooltip="Minimum"
                disabled={target_pressure === min_pressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <Button
                icon="sync"
                tooltip="Domyślne"
                disabled={target_pressure === default_pressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
              <Button
                icon="plus"
                tooltip="Maksimum"
                disabled={target_pressure === max_pressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
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
