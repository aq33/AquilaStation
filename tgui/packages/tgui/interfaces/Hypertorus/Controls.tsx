import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Icon,
  Knob,
  LabeledControls,
  LabeledList,
  NumberInput,
  Section,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { HypertorusFilter } from '.';
import { HelpDummy, HoverHelp } from './helpers';

type ComboProps = {
  color?: string | BooleanLike;
  defaultValue: number;
  flipIcon?: BooleanLike;
  help?: string;
  icon?: string;
  maxValue: number;
  minValue: number;
  parameter: string;
  step?: number;
  unit: string;
  value: number;
};

type ControlsData = {
  cooling_volume: number;
  current_damper: number;
  heat_output: number;
  heating_conductor: number;
  magnetic_constrictor: number;
};

type WasteData = {
  filter_types: HypertorusFilter[];
  mod_filtering_rate: number;
  waste_remove: BooleanLike;
};

/*
 * This module holds user interactable controls. Some may be good candidates
 * for generalizing and refactoring.
 */
const ComboKnob = (props: ComboProps) => {
  const {
    color = false,
    defaultValue,
    flipIcon,
    help,
    icon,
    maxValue,
    minValue,
    parameter,
    step = 5,
    value,
    ...rest
  } = props;

  const { act } = useBackend();

  const iconProps = {
    rotation: 0,
  };
  if (flipIcon) {
    iconProps.rotation = 180;
  }

  const icon_element = icon && (
    <Icon
      position="absolute"
      top="16px"
      left="-27px"
      color="label"
      fontSize="200%"
      name={icon}
      {...iconProps}
    />
  );

  return (
    <Box position="relative" left="2px">
      {help ? <Tooltip content={help}>{icon_element}</Tooltip> : icon_element}
      <Knob
        color={color}
        size={2}
        value={value}
        minValue={minValue}
        maxValue={maxValue}
        step={step}
        stepPixelSize={1}
        onChange={(_, v) => act(parameter, { [parameter]: v })}
        {...rest}
      />
      <Button
        fluid
        position="absolute"
        top="-2px"
        right="-20px"
        color="transparent"
        icon="fast-forward"
        onClick={() => act(parameter, { [parameter]: maxValue })}
      />
      <Button
        fluid
        position="absolute"
        top="16px"
        right="-20px"
        color="transparent"
        icon="undo"
        onClick={() => act(parameter, { [parameter]: defaultValue })}
      />
      <Button
        fluid
        position="absolute"
        top="34px"
        right="-20px"
        color="transparent"
        icon="fast-backward"
        onClick={() => act(parameter, { [parameter]: minValue })}
      />
    </Box>
  );
};

export const HypertorusSecondaryControls = (props) => {
  const { data } = useBackend<ControlsData>();
  const {
    cooling_volume,
    current_damper,
    heat_output,
    heating_conductor,
    magnetic_constrictor,
  } = data;

  return (
    <Section title="Sterowanie reaktorem">
      <LabeledControls justify="space-around" wrap>
        <LabeledControls.Item label="Przewodnik ciepła">
          <ComboKnob
            color={heating_conductor > 50 && heat_output > 0 && 'yellow'}
            value={heating_conductor}
            unit="J/cm"
            minValue={50}
            defaultValue={100}
            maxValue={500}
            parameter="heating_conductor"
            icon="fire"
            help="Ustala, jak szybko reakcja fuzji się nagrzewa albo chłodzi. Wyższe grzanie zwiększa produkcję, ale grozi wymknięciem się reakcji spod kontroli."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Objętość chłodzenia">
          <ComboKnob
            value={cooling_volume}
            unit="L"
            minValue={50}
            defaultValue={100}
            maxValue={2000}
            parameter="cooling_volume"
            step={25}
            icon="snowflake-o"
            help="Ustala wewnętrzną przestrzeń chłodzenia w rdzeniu HFR. Mniejsza chłodzi słabiej w środku, ale większość chłodziwa zostaje na zewnątrz rdzenia, gdzie szybko się schładza, gdy nie jest potrzebne."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Zwężacz magnetyczny">
          <ComboKnob
            value={magnetic_constrictor}
            unit="m³/T"
            minValue={50}
            defaultValue={100}
            maxValue={1000}
            parameter="magnetic_constrictor"
            icon="magnet"
            flipIcon
            help="Ustala gęstość reakcji fuzji. Gęstsza reakcja uwalnia więcej energii, ale przy zbyt dużej masie może stracić stabilność."
          />
        </LabeledControls.Item>
        <LabeledControls.Item label="Tłumik prądu">
          <ComboKnob
            color={current_damper && 'yellow'}
            value={current_damper}
            unit="W"
            minValue={0}
            defaultValue={0}
            maxValue={1000}
            parameter="current_damper"
            icon="sun-o"
            help="Destabilizuje reakcję. Dostatecznie zdestabilizowana reakcja przestaje produkować i staje się endotermiczna: chłodzi mieszankę fuzji zamiast ją grzać. Reakcję z dużą ilością żelaza trudniej zdestabilizować."
          />
        </LabeledControls.Item>
      </LabeledControls>
    </Section>
  );
};

export const HypertorusWasteRemove = (props) => {
  const { act, data } = useBackend<WasteData>();
  const { filter_types = [], waste_remove, mod_filtering_rate } = data;

  return (
    <Section title="Sterowanie wylotem">
      <LabeledList>
        <LabeledList.Item
          label={
            <>
              <HoverHelp
                content={
                  'Usuwa gazy odpadowe z mieszanki fuzji' +
                  ' i zaznaczone gazy z moderatora.'
                }
              />
              Usuwanie odpadów:
            </>
          }
        >
          <Button
            icon={waste_remove ? 'power-off' : 'times'}
            content={waste_remove ? 'Wł.' : 'Wył.'}
            selected={waste_remove}
            onClick={() => act('waste_remove')}
          />
        </LabeledList.Item>
        <LabeledList.Item
          label={
            <>
              <HelpDummy />
              Tempo filtrowania moderatora:
            </>
          }
        >
          <NumberInput
            animated
            tickWhileDragging
            value={mod_filtering_rate}
            unit="mol/s"
            step={1}
            minValue={5}
            maxValue={200}
            onChange={(value) =>
              act('mod_filtering_rate', {
                mod_filtering_rate: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item
          label={
            <>
              <HelpDummy />
              Filtruj z moderatora:
            </>
          }
        >
          {filter_types.map(({ gas_id, gas_name, enabled }) => (
            <Button.Checkbox
              key={gas_id}
              checked={enabled}
              onClick={() =>
                act('filter', {
                  mode: gas_id,
                })
              }
            >
              {gas_name}
            </Button.Checkbox>
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
