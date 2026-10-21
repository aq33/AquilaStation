import {
  Box,
  Button,
  LabeledControls,
  NumberInput,
  RoundGauge,
  Section,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const formatPressure = (value: number) => {
  if (value < 10000) {
    return `${toFixed(value)} kPa`;
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

type Data = {
  defaultReleasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  leakPressure: number;
  fragmentPressure: number;
  tankPressure: number;
  releasePressure: number;
  connected: BooleanLike;
};

export const Tank = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    leakPressure = 3040,
    fragmentPressure = 4053,
    tankPressure,
    releasePressure,
    connected,
  } = data;
  return (
    <Window width={300} height={130}>
      <Window.Content>
        <Section>
          <LabeledControls>
            <LabeledControls.Item label="Ciśnienie">
              <RoundGauge
                value={tankPressure}
                minValue={0}
                maxValue={fragmentPressure * 1.15}
                alertAfter={leakPressure}
                ranges={{
                  good: [0, leakPressure],
                  average: [leakPressure, fragmentPressure],
                  bad: [fragmentPressure, fragmentPressure * 1.15],
                }}
                format={formatPressure}
                size={2}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Regulator ciśnienia">
              <Button
                icon="fast-backward"
                tooltip="Minimum"
                disabled={releasePressure === minReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <NumberInput
                animated
                value={releasePressure}
                width="65px"
                unit="kPa"
                step={1}
                minValue={minReleasePressure}
                maxValue={maxReleasePressure}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                tooltip="Maksimum"
                disabled={releasePressure === maxReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
              <Button
                icon="undo"
                tooltip="Domyślne"
                disabled={releasePressure === defaultReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
              {!!connected && (
                <Box color="good" mt={0.5}>
                  Podłączony do oddychania
                </Box>
              )}
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
