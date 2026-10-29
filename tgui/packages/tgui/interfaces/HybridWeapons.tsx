// NSV13

import { toFixed } from 'common/math';
import {
  Button,
  Flex,
  ProgressBar,
  Section,
  Slider,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  alignment: any;
  available_power: any;
  capacitor_charge: any;
  capacitor_current_charge_rate: any;
  capacitor_max_charge: any;
  capacitor_max_charge_rate: any;
  chambered: any;
  loaded: any;
  magazine: any;
  maint_req: any;
  max_obj_integ: any;
  obj_integ: any;
  safety: any;
  slug_shell: any;
};

export const HybridWeapons = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="ntos" width={600} height={460}>
      <Window.Content scrollable>
        <Section title="Sterowanie systemem broni:">
          <Flex spacing={1}>
            <Flex.Item width="250px">
              <Section fill position="relative" height="100%">
                <Button
                  icon={data.loaded ? 'check-circle' : 'square-o'}
                  width="100"
                  selected={data.loaded}
                  content="I1 - Ładunek załadowany"
                  onClick={() => act('toggle_load')}
                />
                <Button
                  icon={data.chambered ? 'check-circle' : 'square-o'}
                  width="100"
                  selected={data.chambered}
                  content="I2 - Ładunek w komorze"
                  onClick={() => act('chamber')}
                />
                <Button
                  icon={data.safety ? 'power-off' : 'times'}
                  color={data.safety ? 'green' : 'red'}
                  content="I3 - Bezpieczniki broni"
                  onClick={() => act('toggle_safety')}
                />
                <Button
                  icon="cog"
                  color={data.slug_shell ? 'orange' : 'yellow'}
                  content={
                    data.slug_shell
                      ? 'I4 - Konfiguracja: kanister'
                      : 'I4 - Konfiguracja: pocisk pełny'
                  }
                  onClick={() => act('switch_type')}
                />
                Integralność strukturalna:{' '}
                <b>{(data.obj_integ / data.max_obj_integ) * 100}%</b>
                <br />
                Stan lufy: <b>{(data.maint_req / 25) * 100}%</b>
                <br />
                Wyrównanie magnetyczne: <b>{data.alignment}%</b>
              </Section>
            </Flex.Item>
            <Flex.Item width="300px">
              <Section>
                Ładunek kondensatora:
                <ProgressBar
                  value={data.capacitor_charge / data.capacitor_max_charge}
                  ranges={{
                    good: [0.99, Infinity],
                    average: [0.5, 0.99],
                    bad: [-Infinity, 0.5],
                  }}
                />
                Przydział mocy (W):
                <Slider
                  tickWhileDragging
                  value={data.capacitor_current_charge_rate}
                  minValue={0}
                  maxValue={data.capacitor_max_charge_rate}
                  step={1}
                  stepPixelSize={0.0031}
                  onChange={(e, value) =>
                    act('capacitor_current_charge_rate', {
                      adjust: value,
                    })
                  }
                />
                Dostępna moc (W):
                <ProgressBar
                  value={data.available_power}
                  minValue={0}
                  maxValue={2e5}
                  color="yellow"
                >
                  {toFixed(data.available_power)}
                </ProgressBar>
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Amunicja:">
          <Table.Row>
            {Object.keys(data.magazine).map((key) => {
              let value = data.magazine[key];
              return (
                <Table.Cell key={key}>
                  <Section title={`${value.name}`}>
                    Przewodność: <b>{value.conductivity}</b>
                    <br />
                    Gęstość: <b>{value.density}</b>
                    <br />
                    Twardość: <b>{value.hardness}</b>
                    <br />
                    Ładunek: <b>{value.charge}</b>
                    <br />
                    Integralność: <b>{value.integrity}</b>
                  </Section>
                </Table.Cell>
              );
            })}
          </Table.Row>
        </Section>
      </Window.Content>
    </Window>
  );
};
