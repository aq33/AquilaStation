import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useBackend } from 'tgui/backend';
import { getGasColor, getGasLabel } from 'tgui/constants';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import type { HypertorusFuel, HypertorusGas } from '.';
import { HelpDummy, HoverHelp } from './helpers';

type GasListProps = {
  input_max: number;
  input_min: number;
  input_rate: string;
  input_switch: string;
  raw_gases: HypertorusGas[];
  minimumScale: number;
  prepend?: (gas: HypertorusGas) => void;
  rateHelp?: string;
  stickyGases?: readonly string[];
};

type GasListData = {
  start_power: number;
  start_cooling: number;
};

type HypertorusData = {
  fusion_gases: HypertorusGas[];
  moderator_gases: HypertorusGas[];
  selectable_fuel: HypertorusFuel[];
  selected: string;
};

/*
 * Displays contents of gas mixtures, along with help text for gases with
 * special text when present. Some gas bars are always visible, even when
 * absent, to hint at what can be added and their effects.
 */

// AQUILA: opisy tylko dla gazów, które u nas działają w moderatorze (bez protoazotanu, healium, antynoblium; frezon zamiast freonu)
const moderator_gases_help = {
  plasma:
    'Wytwarza podstawowe gazy. Daje niewielki bonus ciepła, który pomaga rozpędzić fuzję. W dużej ilości jego wysoka pojemność cieplna spowalnia zmiany temperatury do bezpiecznego tempa.',
  bz: 'Od poziomu fuzji 3 wytwarza bardziej złożone gazy. Mocno zwiększa promieniowanie i wywołuje halucynacje u osób w pobliżu.',
  o2: 'W dużej ilości szybko usuwa żelazo z rdzenia. Przy wysokich poziomach fuzji nie nadąża za uszkodzeniami.',
  frezon:
    'Tłumi większość form uwalniania energii. Spowalnia zmiany temperatury.',
} as const;

const moderator_gases_sticky_order = ['plasma', 'bz', 'frezon'] as const;

const ensure_gases = (gas_array: HypertorusGas[] = [], gasids) => {
  const gases_by_id = {};
  gas_array.forEach((gas) => {
    gases_by_id[gas.id] = true;
  });

  for (const gasid of gasids) {
    if (!gases_by_id[gasid]) {
      gas_array.push({ id: gasid, amount: 0 });
    }
  }
};

const GasList = (props: GasListProps) => {
  const { act, data } = useBackend<GasListData>();
  const {
    input_max,
    input_min,
    input_rate,
    input_switch,
    raw_gases = [],
    minimumScale,
    prepend,
    rateHelp = '',
    stickyGases,
  } = props;
  const { start_power, start_cooling } = data;

  const gases: HypertorusGas[] = sortBy(
    filter(raw_gases, (gas) => gas.amount >= 0.01),
    [(gas) => -gas.amount],
  );

  if (stickyGases) {
    ensure_gases(gases, stickyGases);
  }

  return (
    <LabeledList>
      <LabeledList.Item
        label={
          <>
            <HoverHelp content={rateHelp} />
            Wtrysk:
          </>
        }
      >
        <Button
          disabled={start_power === 0 || start_cooling === 0}
          icon={data[input_switch] ? 'power-off' : 'times'}
          content={data[input_switch] ? 'Wł.' : 'Wył.'}
          selected={data[input_switch]}
          onClick={() => act(input_switch)}
        />
        <NumberInput
          animated
          tickWhileDragging
          step={1}
          value={parseFloat(data[input_rate])}
          unit="mol/s"
          minValue={input_min}
          maxValue={input_max}
          onChange={(v) => act(input_rate, { [input_rate]: v })}
        />
      </LabeledList.Item>
      {gases.map((gas) => {
        let labelPrefix;
        if (prepend) {
          labelPrefix = prepend(gas);
        }
        return (
          <LabeledList.Item
            key={gas.id}
            label={
              <>
                {labelPrefix}
                {getGasLabel(gas.id)}:
              </>
            }
          >
            <ProgressBar
              color={getGasColor(gas.id)}
              value={gas.amount}
              minValue={0}
              maxValue={minimumScale}
            >
              {`${toFixed(gas.amount, 2)} mol`}
            </ProgressBar>
          </LabeledList.Item>
        );
      })}
    </LabeledList>
  );
};

export const HypertorusGases = (props) => {
  const { data } = useBackend<HypertorusData>();
  const {
    fusion_gases = [],
    moderator_gases = [],
    selectable_fuel = [],
    selected,
  } = data;

  const selected_fuel = selectable_fuel.filter((d) => d.id === selected)[0];

  return (
    <>
      <Section title="Gazy w komorze fuzji">
        {selected_fuel ? (
          <GasList
            input_rate="fuel_injection_rate"
            input_switch="start_fuel"
            input_max={150}
            input_min={0.5}
            raw_gases={fusion_gases}
            minimumScale={500}
            prepend={() => <HelpDummy />}
            rateHelp={
              'Tempo, w jakim nowe paliwo napływa z wlotu paliwa.' +
              ' Wpływa na tempo produkcji,' +
              ' nawet gdy wtrysk jest wyłączony.'
            }
            stickyGases={selected_fuel.requirements}
          />
        ) : (
          <Box align="center" color="red">
            {'Nie wybrano paliwa'}
          </Box>
        )}
      </Section>
      <Section title="Gazy moderatora">
        <GasList
          input_rate="moderator_injection_rate"
          input_switch="start_moderator"
          input_max={150}
          input_min={0.5}
          raw_gases={moderator_gases}
          minimumScale={500}
          rateHelp={
            'Tempo, w jakim nowy gaz moderatora napływa z wlotu moderatora.'
          }
          stickyGases={moderator_gases_sticky_order}
          prepend={(gas) =>
            moderator_gases_help[gas.id] ? (
              <HoverHelp content={moderator_gases_help[gas.id]} />
            ) : (
              <HelpDummy />
            )
          }
        />
      </Section>
    </>
  );
};
