// NSV13

import { toFixed } from 'common/math';
import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  alloy_t1: any;
  alloy_t2: any;
  alloy_t3: any;
  alloy_t4: any;
  alloy_t5: any;
  available_power: any;
  iron: any;
  maximum_power_allocation: any;
  plasma: any;
  power_allocation: any;
  quadrant_ap_armour_current: any;
  quadrant_ap_armour_max: any;
  quadrant_as_armour_current: any;
  quadrant_as_armour_max: any;
  quadrant_fp_armour_current: any;
  quadrant_fp_armour_max: any;
  quadrant_fs_armour_current: any;
  quadrant_fs_armour_max: any;
  repair_efficiency: any;
  repair_resources: any;
  repair_resources_max: any;
  resourcing: any;
  silver: any;
  structural_integrity_current: any;
  structural_integrity_max: any;
  system_allocation: any;
  system_stress: any;
  titanium: any;
};

export const ArmourPlatingNanorepairWell = (props) => {
  const { act, data } = useBackend<Data>();
  const availablePower = data.available_power;
  return (
    <Window theme="ntos" width={560} height={600}>
      <Window.Content scrollable>
        <Section title="Stan statku:">
          Integralność strukturalna kadłuba:
          <ProgressBar
            value={
              data.structural_integrity_current / data.structural_integrity_max
            }
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
          />
          Pancerz dziobowy, lewa burta:
          <ProgressBar
            value={
              data.quadrant_fp_armour_current / data.quadrant_fp_armour_max
            }
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}
          />
          Pancerz dziobowy, prawa burta:
          <ProgressBar
            value={
              data.quadrant_fs_armour_current / data.quadrant_fs_armour_max
            }
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}
          />
          Pancerz rufowy, lewa burta:
          <ProgressBar
            value={
              data.quadrant_ap_armour_current / data.quadrant_ap_armour_max
            }
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}
          />
          Pancerz rufowy, prawa burta:
          <ProgressBar
            value={
              data.quadrant_as_armour_current / data.quadrant_as_armour_max
            }
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}
          />
        </Section>
        <Section title="Stan systemu APNW">
          Obciążenie systemu:
          <ProgressBar
            value={data.system_allocation / 100}
            ranges={{
              average: [0.75, 1.5],
              bad: [1.5, Infinity],
            }}
          />
          Przeciążenie systemu:
          <ProgressBar
            value={data.system_stress / 100}
            ranges={{
              average: [0.75, 1.5],
              bad: [1.5, Infinity],
            }}
          />
        </Section>
        <Section title="Zasoby APNW:">
          Przetwarzanie materiałów:
          <br />
          <Button
            content="Opróżnij silos"
            icon="exclamation-triangle"
            color={'bad'}
            onClick={() => act('unload')}
          />
          <Button
            content="Usuń RR"
            icon="exclamation-triangle"
            color={'bad'}
            onClick={() => act('purge')}
          />
          <Button
            content="Przetwarzanie RR"
            icon="power-off"
            color={data.resourcing && 'good'}
            onClick={() => act('toggle')}
          />
          <br />
          <br />
          Silos materiałów:
          <br />
          <LabeledList>
            <LabeledList.Item label="Żelazo">
              <ProgressBar
                value={data.iron}
                minValue={0}
                maxValue={100000}
                color="brown"
              >
                {toFixed(data.iron)}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Tytan">
              <ProgressBar
                value={data.titanium}
                minValue={0}
                maxValue={100000}
                color="grey"
              >
                {toFixed(data.titanium)}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Srebro">
              <ProgressBar
                value={data.silver}
                minValue={0}
                maxValue={100000}
                color="white"
              >
                {toFixed(data.silver)}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Plazma">
              <ProgressBar
                value={data.plasma}
                minValue={0}
                maxValue={100000}
                color="purple"
              >
                {toFixed(data.plasma)}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
          <br />
          Wybór stopu:
          <br />
          <Button
            content="Żelazo"
            icon="cog"
            tooltip="Żelazo: 100%"
            color={!!data.alloy_t1 && 'white'}
            onClick={() => act('iron')}
          />
          <Button
            content="Plastal"
            icon="cog"
            tooltip="Żelazo: 50%, plazma: 50%"
            color={!!data.alloy_t2 && 'white'}
            onClick={() => act('plasteel')}
          />
          <Button
            content="Ferrotytan"
            icon="cog"
            tooltip="Żelazo: 25%, tytan: 75%"
            color={!!data.alloy_t3 && 'white'}
            onClick={() => act('ferrotitanium')}
          />
          <Button
            content="Durastal"
            icon="cog"
            tooltip="Żelazo: 20%, tytan: 65%, srebro: 15%"
            color={!!data.alloy_t4 && 'white'}
            onClick={() => act('durasteel')}
          />
          <Button
            content="Duranium"
            icon="cog"
            tooltip="Żelazo: 17.5%, tytan: 62.5%, srebro: 15%, plazma: 5%"
            color={!!data.alloy_t5 && 'white'}
            onClick={() => act('duranium')}
          />
          <br />
          <br />
          Zasoby naprawcze:
          <br />
          <ProgressBar
            value={data.repair_resources / data.repair_resources_max}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}
          >
            {data.repair_resources + ' RUs'}
          </ProgressBar>
          Wydajność naprawy:
          <ProgressBar
            value={data.repair_efficiency}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}
          />
          Przydział mocy (W):
          <Slider
            tickWhileDragging
            value={data.power_allocation}
            minValue={0}
            maxValue={data.maximum_power_allocation}
            step={1}
            stepPixelSize={0.0002}
            onChange={(e, value) =>
              act('power_allocation', {
                adjust: value,
              })
            }
          />
          Dostępna moc (W):
          <ProgressBar
            value={availablePower}
            minValue={0}
            maxValue={1e6}
            color="yellow"
          >
            {toFixed(availablePower)}
          </ProgressBar>
        </Section>
      </Window.Content>
    </Window>
  );
};
