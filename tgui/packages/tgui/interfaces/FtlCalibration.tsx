// AQUILA - kalibracja pylonów FTL (aquila/code/modules/overmap/ftl_calibration.dm)
import { Box, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';

type CalibrationPylon = {
  id: string;
  name: string;
  active: boolean;
  target_freq: number;
  target_phase: number;
  freq: number;
  phase: number;
  match: number;
};

type Calibration = {
  pylons: CalibrationPylon[];
  quality: number;
  charge_mult: number;
  mishap: number;
  freq_min: number;
  freq_max: number;
};

type Data = {
  calibration?: Calibration;
};

const WIDTH = 260;
const HEIGHT = 70;

const wavePath = (freq: number, phase: number) => {
  const points: string[] = [];
  for (let x = 0; x <= WIDTH; x += 4) {
    const t = x / WIDTH;
    const y =
      HEIGHT / 2 -
      (HEIGHT / 2 - 6) *
        Math.sin(2 * Math.PI * freq * t + (phase * Math.PI) / 180);
    points.push(`${x},${y.toFixed(1)}`);
  }
  return 'M' + points.join(' L');
};

const Scope = (props: { pylon: CalibrationPylon }) => {
  const { pylon } = props;
  return (
    <svg
      width={WIDTH}
      height={HEIGHT}
      style={{ background: '#0b1410', border: '1px solid #1f3a2c' }}
    >
      <line
        x1={0}
        y1={HEIGHT / 2}
        x2={WIDTH}
        y2={HEIGHT / 2}
        stroke="#1f3a2c"
      />
      <path
        d={wavePath(pylon.target_freq, pylon.target_phase)}
        fill="none"
        stroke="#4fd17a"
        strokeWidth={2}
      />
      <path
        d={wavePath(pylon.freq, pylon.phase)}
        fill="none"
        stroke="#f0b44c"
        strokeWidth={2}
        strokeDasharray="5 3"
      />
    </svg>
  );
};

export const FtlCalibration = () => {
  const { act, data } = useBackend<Data>();
  const cal = data.calibration;
  if (!cal || !cal.pylons.length) {
    return null;
  }
  return (
    <Section title="Kalibracja pylonów:">
      <Box mb={1}>
        Zielona fala to cel, żółta to ustawienie pylonu. Pokryj je, zanim
        pylony skończą ładowanie.
      </Box>
      <Box mb={1}>
        Jakość kalibracji: <b>{cal.quality}%</b>, ładowanie ×{cal.charge_mult},
        szansa wypadku przy skoku: <b>{cal.mishap}%</b>
      </Box>
      {cal.pylons.map((pylon) => (
        <Box key={pylon.id} mb={1}>
          <Box bold color={pylon.active ? 'good' : 'label'}>
            {pylon.name}: dopasowanie {pylon.match}%
            {!pylon.active && ' (nieaktywny, nie liczy się)'}
          </Box>
          <Stack align="center">
            <Stack.Item>
              <Scope pylon={pylon} />
            </Stack.Item>
            <Stack.Item grow>
              <Box>Częstotliwość</Box>
              <Slider
                minValue={cal.freq_min}
                maxValue={cal.freq_max}
                step={0.05}
                stepPixelSize={2}
                value={pylon.freq}
                format={(value) => value.toFixed(2)}
                onChange={(_, value) =>
                  act('calibrate', { id: pylon.id, freq: value })
                }
              />
              <Box mt={0.5}>Faza</Box>
              <Slider
                minValue={0}
                maxValue={359}
                step={1}
                stepPixelSize={1}
                value={pylon.phase}
                unit="°"
                onChange={(_, value) =>
                  act('calibrate', { id: pylon.id, phase: value })
                }
              />
            </Stack.Item>
          </Stack>
        </Box>
      ))}
    </Section>
  );
};
