/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */
// AQUILA: port z Monkestation 2.0, po polsku, drabinka jednostek do TW

import {
  Box,
  Button,
  Knob,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatMoney, formatPower } from '../format';
import { Window } from '../layouts';

type Data = {
  output: number;
  total_earnings: number;
  unsent_earnings: number;
  held_power: number;
  max_capacity: number;
  max_grid_load: number;
  accepting_power: boolean;
  sucking_power: boolean;
  firing: boolean;
  broken: boolean;
  power_format: number;
  input_number: number;
  avalible_input: number;
  output_number: number;
  output_multiplier: number;
  input_total: number;
  output_total: number;
};

const UNITS: [string, string, number][] = [
  ['W', 'W', 1],
  ['KW', 'kW', 1e3],
  ['MW', 'MW', 1e6],
  ['GW', 'GW', 1e9],
  ['TW', 'TW', 1e12],
];

const UnitButtons = (props: { action: string; current: number }) => {
  const { act } = useBackend<Data>();
  const { action, current } = props;
  return (
    <>
      {UNITS.map(([unit, label, value]) => (
        <Button
          key={unit}
          selected={current === value}
          onClick={() => act(action, { unit })}
        >
          {label}
        </Button>
      ))}
    </>
  );
};

export const TransmissionLaser = (props) => {
  const { data } = useBackend<Data>();
  const { total_earnings, broken } = data;
  return (
    <Window title="Laser przesyłu mocy" width={440} height={490}>
      <Window.Content>
        {!!broken && (
          <NoticeBox danger>
            Brak terminala zasilania za laserem. Laser nie działa.
          </NoticeBox>
        )}
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>
          Zarobione kredyty: {total_earnings ? formatMoney(total_earnings) : 0}
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};

const Status = (props) => {
  const { data } = useBackend<Data>();
  const { held_power, output_total, max_grid_load } = data;

  return (
    <Section title="Stan">
      <LabeledList>
        <LabeledList.Item label="Zgromadzona moc">
          {held_power ? formatPower(held_power) : '0 W'}
        </LabeledList.Item>
        <LabeledList.Item label="Nadwyżka sieci">
          {max_grid_load > 0 ? formatPower(max_grid_load) : '0 W'}
        </LabeledList.Item>
        <LabeledList.Item label="Wysycenie sieci" />
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={max_grid_load > 0 ? output_total / max_grid_load : 0}
      />
    </Section>
  );
};

const InputControls = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    input_total,
    accepting_power,
    sucking_power,
    input_number,
    power_format,
  } = data;

  return (
    <Section title="Wejście">
      <LabeledList>
        <LabeledList.Item
          label="Obwód wejścia"
          buttons={
            <Button
              icon="power-off"
              color={accepting_power ? 'green' : 'red'}
              onClick={() => act('toggle_input')}
            >
              {accepting_power ? 'Włączony' : 'Wyłączony'}
            </Button>
          }
        >
          <Box
            color={
              (sucking_power && 'good') ||
              (accepting_power && 'average') ||
              'bad'
            }
          >
            {(sucking_power && 'Ładuje') ||
              (accepting_power && 'Czeka') ||
              'Wyłączony'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Poziom wejścia">
          {input_total ? formatPower(input_total) : '0 W'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          animated
          size={1.25}
          inline
          step={5}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          value={input_number}
          tickWhileDragging
          onChange={(_, set_input) => act('set_input', { set_input })}
        />
        <UnitButtons action="input_unit" current={power_format} />
      </Box>
    </Section>
  );
};

const OutputControls = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    output_total,
    firing,
    accepting_power,
    output_number,
    output_multiplier,
  } = data;

  return (
    <Section title="Wyjście">
      <LabeledList>
        <LabeledList.Item
          label="Obwód lasera"
          buttons={
            <Button
              icon="power-off"
              color={firing ? 'green' : 'red'}
              onClick={() => act('toggle_output')}
            >
              {firing ? 'Włączony' : 'Wyłączony'}
            </Button>
          }
        >
          <Box
            color={
              (firing && 'good') || (accepting_power && 'average') || 'bad'
            }
          >
            {(firing && 'Strzela') ||
              (accepting_power && 'Czeka') ||
              'Wyłączony'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Poziom wyjścia">
          {output_total ? formatPower(output_total) : '0 W'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <Knob
          mr="0.5em"
          size={1.25}
          animated
          inline
          step={5}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          value={output_number}
          tickWhileDragging
          onChange={(_, set_output) => act('set_output', { set_output })}
        />
        <UnitButtons action="output_unit" current={output_multiplier} />
      </Box>
      <Box mt="0.5em" color="label">
        Laser strzela od 1 MW zgromadzonej mocy. Nie stawaj na linii wiązki.
      </Box>
    </Section>
  );
};
