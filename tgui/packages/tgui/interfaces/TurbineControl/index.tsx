/**
 * @file
 * @copyright 2022
 * @author Amylizzle (https://github.com/amylizzle)
 * @author Sovexe  (https://github.com/Sovexe)
 * @license MIT
 *
 * AQUILA: port z goonstation (okno turbiny gazowej, aquila/code/modules/power/blade_turbine.dm),
 * teksty po polsku, bez motywu retro-dark, ciśnienie formatowane lokalnie, materiał części w diagnostyce.
 */

import {
  Box,
  Button,
  Chart,
  Dimmer,
  Icon,
  Input,
  Knob,
  LabeledList,
  RoundGauge,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { formatPower, formatSiUnit } from '../../format';
import { Window } from '../../layouts';
import type {
  TurbineBladeData,
  TurbineControlData,
  TurbineHistorySample,
} from './type';

type HistoryMetric =
  | 'power'
  | 'rpm'
  | 'temperature'
  | 'pressure'
  | 'outletTemperature'
  | 'outletPressure';
type TurbineStatus =
  | 'disconnected'
  | 'ruined'
  | 'overspeed'
  | 'overtemp'
  | 'stalled'
  | 'undertemp'
  | 'damaged'
  | 'idle'
  | 'nominal';

const getTurbineStatus = (
  data: Pick<
    TurbineControlData,
    | 'connected'
    | 'ruined'
    | 'overspeed'
    | 'overtemp'
    | 'undertemp'
    | 'stalling'
    | 'rpm'
    | 'blade'
    | 'stator'
  >,
): TurbineStatus => {
  if (!data.connected) {
    return 'disconnected';
  }
  if (data.ruined || !data.blade?.installed || !data.stator?.installed) {
    return 'ruined';
  }
  if (data.overspeed) {
    return 'overspeed';
  }
  if (data.overtemp) {
    return 'overtemp';
  }
  if (data.stalling) {
    return 'stalled';
  }
  if (data.undertemp) {
    return 'undertemp';
  }
  if (data.blade?.installed && data.blade.healthPercent <= 50) {
    return 'damaged';
  }
  if (!data.rpm) {
    return 'idle';
  }
  return 'nominal';
};

const loadToExponent = (load: number, minLoad: number, maxLoad: number) =>
  Math.min(
    Math.max(Math.log10(Math.max(load, minLoad)), Math.log10(minLoad)),
    Math.log10(maxLoad),
  );

const exponentToLoad = (exponent: number, minLoad: number, maxLoad: number) =>
  Math.min(Math.max(10 ** exponent, minLoad), maxLoad);

const formatPressure = (value: number) => formatSiUnit(value * 1000, 1, 'Pa');

const formatLoad = (load: number) => `${formatSiUnit(load, 0, 'J')}/obrót`;

const formatTemperature = (temperature: number) =>
  `${Math.round(temperature)} K`;

const formatRPM = (rpm: number) => `${Math.round(rpm)} obr./min`;

const HISTORY_CHART_STROKE_COLOR = 'rgba(203, 135, 66, 1)';
const HISTORY_CHART_FILL_COLOR = 'rgba(241, 183, 125, 0.25)';

const chartData = (values: number[]) => {
  if (!values.length) {
    return [[0, 0]];
  }
  return values.map((value, index) => [index, value]);
};

const chartMaximum = (values: number[]) => Math.max(1, ...values);

const historyValues = (
  history: TurbineHistorySample[],
  metric: HistoryMetric,
) =>
  history.map((sample) => {
    const value = sample[metric];
    return Number.isFinite(value) ? value : 0;
  });

const buildHistoryChart = (
  history: TurbineHistorySample[],
  metric: HistoryMetric,
) => {
  const values = historyValues(history, metric);
  return {
    data: chartData(values),
    max: chartMaximum(values),
  };
};

const statusLabel: Record<TurbineStatus, string> = {
  disconnected: 'BRAK POŁĄCZENIA Z TURBINĄ',
  ruined: 'USTERKA CZĘŚCI',
  overspeed: 'NADOBROTY',
  overtemp: 'OSTRZEŻENIE TERMICZNE',
  stalled: 'ZDŁAWIONA',
  undertemp: 'ZA ZIMNY GAZ',
  damaged: 'USZKODZONE ŁOPATKI',
  idle: 'POSTÓJ',
  nominal: 'PRACA NOMINALNA',
};

const statusColor: Record<TurbineStatus, string> = {
  disconnected: 'average',
  ruined: 'bad',
  overspeed: 'bad',
  overtemp: 'bad',
  stalled: 'bad',
  undertemp: 'average',
  damaged: 'bad',
  idle: 'average',
  nominal: 'good',
};

const bladeStatus = (blade: TurbineBladeData | null) => {
  if (!blade?.installed) {
    return 'Brak';
  }
  if (blade.healthPercent <= 25) {
    return 'Krytyczny';
  }
  if (blade.healthPercent <= 50) {
    return 'Zużyte';
  }
  return 'Dobry';
};

const bladeStatusColor = (blade: TurbineBladeData | null) => {
  const status = bladeStatus(blade);
  if (status === 'Dobry') {
    return 'good';
  }
  if (status === 'Zużyte') {
    return 'average';
  }
  return 'bad';
};

type LoadAdjustmentControlsProps = {
  load: number;
  onCommit: (value: string) => void;
  onAdjust: (factor: number) => void;
};

const LoadAdjustmentControls = ({
  load,
  onCommit,
  onAdjust,
}: LoadAdjustmentControlsProps) => (
  <Stack vertical>
    <Stack.Item>
      <Stack align="center">
        <Stack.Item>
          <Input value={`${load / 1000}`} monospace onBlur={onCommit} />
        </Stack.Item>
        <Stack.Item>
          <Box>kJ/obrót</Box>
        </Stack.Item>
      </Stack>
    </Stack.Item>
    <Stack.Item>
      <Stack>
        <Stack.Item>
          <Button onClick={() => onAdjust(0.9)}>-10%</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => onAdjust(0.99)}>-1%</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => onAdjust(1.01)}>+1%</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => onAdjust(1.1)}>+10%</Button>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  </Stack>
);

type HistoryPanel = {
  label: string;
  value: string;
  chart: {
    data: number[][];
    max: number;
  };
};

const HistoryGrid = ({
  panels,
  hasHistory,
}: {
  panels: HistoryPanel[];
  hasHistory: boolean;
}) => (
  <Stack vertical>
    <Stack.Item>
      <Stack wrap="wrap" justify="space-around">
        {panels.map((panel) => (
          <Stack.Item key={panel.label} grow minWidth={20} maxWidth={25}>
            <Stack vertical>
              <Stack.Item>
                <Box color="label">
                  {panel.label}: {panel.value}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Chart.Line
                  height="4em"
                  data={panel.chart.data}
                  rangeX={[0, Math.max(panel.chart.data.length - 1, 1)]}
                  rangeY={[0, panel.chart.max]}
                  strokeColor={HISTORY_CHART_STROKE_COLOR}
                  fillColor={HISTORY_CHART_FILL_COLOR}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </Stack.Item>
    {!hasHistory && (
      <Stack.Item>
        <Box color="label">Brak próbek.</Box>
      </Stack.Item>
    )}
  </Stack>
);

const turbineWindowProps = {
  width: 520,
  height: 770,
  title: 'Turbina gazowa: pulpit operatora',
};

export const TurbineControl = () => {
  const { act, data } = useBackend<TurbineControlData>();

  if (!data.connected) {
    return (
      <Window {...turbineWindowProps}>
        <Window.Content>
          <Dimmer>BRAK POŁĄCZENIA Z TURBINĄ</Dimmer>
        </Window.Content>
      </Window>
    );
  }

  const status = getTurbineStatus(data);
  const historyPanels = [
    {
      label: 'Moc',
      value: formatPower(data.power),
      chart: buildHistoryChart(data.history, 'power'),
    },
    {
      label: 'Obroty',
      value: formatRPM(data.rpm),
      chart: buildHistoryChart(data.history, 'rpm'),
    },
    {
      label: 'Temperatura wejścia',
      value: formatTemperature(data.inletTemperature),
      chart: buildHistoryChart(data.history, 'temperature'),
    },
    {
      label: 'Ciśnienie wejścia',
      value: formatPressure(data.inletPressure),
      chart: buildHistoryChart(data.history, 'pressure'),
    },
    {
      label: 'Temperatura wyjścia',
      value: formatTemperature(data.outletTemperature),
      chart: buildHistoryChart(data.history, 'outletTemperature'),
    },
    {
      label: 'Ciśnienie wyjścia',
      value: formatPressure(data.outletPressure),
      chart: buildHistoryChart(data.history, 'outletPressure'),
    },
  ];
  const rpmGaugeMax = Math.max(data.overspeedRPM * 1.5, data.rpm * 1.1, 1);
  const temperatureGaugeMax = Math.max(
    data.overtempLimit * 1.1,
    data.inletTemperature * 1.1,
    1,
  );
  const loadExponent = loadToExponent(
    data.load,
    data.statorLoadMin,
    data.statorLoadMax,
  );
  const adjustLoad = (factor: number) =>
    act('loadChange', { newVal: data.load * factor });
  const commitLoad = (value: string) => {
    const load = Number(value);
    if (Number.isFinite(load)) {
      act('loadChange', { newVal: load * 1000 });
    }
  };
  return (
    <Window {...turbineWindowProps}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <Box color={statusColor[status]} textAlign="center">
                    <Icon name="cog" size={3} spin={!!data.rpm} />
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box color="label">STAN TURBINY</Box>
                  <Box color={statusColor[status]} bold fontSize={1.5}>
                    {statusLabel[status]}
                  </Box>
                </Stack.Item>
                <Stack.Item textAlign="right">
                  <Box color="label">MOC</Box>
                  <Box bold fontSize={1.5}>
                    {formatPower(data.power)}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Wskaźniki">
              <Stack justify="space-around" align="center" wrap="wrap">
                <Stack.Item>
                  <Box textAlign="center">OBROTY</Box>
                  <RoundGauge
                    size={4}
                    value={Math.min(data.rpm, rpmGaugeMax)}
                    minValue={0}
                    maxValue={rpmGaugeMax}
                    alertAfter={data.overspeedRPM}
                    format={formatRPM}
                    ranges={{
                      average: [0, data.optimalRPM * 0.75],
                      good: [data.optimalRPM * 0.75, data.overspeedRPM],
                      bad: [data.overspeedRPM, rpmGaugeMax],
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box textAlign="center">TEMPERATURA</Box>
                  <RoundGauge
                    size={4}
                    value={Math.min(data.inletTemperature, temperatureGaugeMax)}
                    minValue={0}
                    maxValue={temperatureGaugeMax}
                    alertAfter={data.overtempWarning}
                    format={formatTemperature}
                    ranges={{
                      blue: [0, data.minimumTemperature],
                      good: [data.minimumTemperature, data.overtempWarning],
                      average: [data.overtempWarning, data.overtempLimit],
                      bad: [data.overtempLimit, temperatureGaugeMax],
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Nastawy">
              <Stack vertical>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Box>Obciążenie statora</Box>
                      <Box color="label">{formatLoad(data.load)}</Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Knob
                        animated
                        size={2}
                        value={loadExponent}
                        minValue={Math.log10(data.statorLoadMin)}
                        maxValue={Math.log10(data.statorLoadMax)}
                        step={0.05}
                        format={(value) =>
                          formatLoad(
                            exponentToLoad(
                              value,
                              data.statorLoadMin,
                              data.statorLoadMax,
                            ),
                          )
                        }
                        onChange={(_event, value) =>
                          act('loadChange', {
                            newVal: exponentToLoad(
                              value,
                              data.statorLoadMin,
                              data.statorLoadMax,
                            ),
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <LoadAdjustmentControls
                        load={data.load}
                        onCommit={commitLoad}
                        onAdjust={adjustLoad}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Box>Przepływ</Box>
                      <Box color="label">{data.volume} l/cykl</Box>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Slider
                        value={data.volume}
                        minValue={data.flowRateMin}
                        maxValue={data.volumeMax}
                        step={1}
                        unit="l/cykl"
                        onChange={(_event, value) =>
                          act('volChange', { newVal: value })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Historia">
              <HistoryGrid
                panels={historyPanels}
                hasHistory={!!data.history.length}
              />
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Diagnostyka części">
              <LabeledList>
                <LabeledList.Item label="Łopatki">
                  <Box color={bladeStatusColor(data.blade)}>
                    {bladeStatus(data.blade)}
                    {!!data.blade?.installed &&
                      ` (${data.blade.material}, ${Math.round(data.blade.healthPercent)}%)`}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Stator">
                  {data.stator?.installed ? (
                    <Box color="good">Założony ({data.stator.material})</Box>
                  ) : (
                    <Box color="bad">BRAK</Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
