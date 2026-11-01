import { Button, ProgressBar, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  alignment: any;
  ammo: any;
  chambered: any;
  cooldown: any;
  field_integrity: any;
  loaded: any;
  max_ammo: any;
  plasma_moles: any;
  plasma_moles_max: any;
  safety: any;
};

// Forgot to change the Plasma Load to Ammo but I did that now //
// I also removed the old bar //

export const PlasmaGun = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="dominion" width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Table.Row>
            <Table.Cell collapsing>
              <Section title="Splajny:">
                <ProgressBar
                  value={(100 - data.cooldown) * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Table.Cell>
          </Table.Row>
        </Section>
        <Section>
          <Table.Row>
            <Table.Cell collapsing>
              <Section title="Ładunek kondensatora plazmy:">
                <ProgressBar
                  value={
                    (data.plasma_moles / data.plasma_moles_max) * 100 * 0.01
                  }
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Table.Cell>
            <Table.Cell collapsing>
              <Section title="Ładunek plazmy:">
                <ProgressBar
                  value={(data.ammo / data.max_ammo) * 100 * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Table.Cell>
          </Table.Row>
          <Section title="Wyrównanie pola">
            <ProgressBar
              value={data.alignment * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
          <Section title="Integralność pola:">
            <ProgressBar
              value={data.field_integrity * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
        </Section>
        <Section title="Sterowanie systemem odstraszającym:">
          <Button
            fluid
            icon={data.loaded ? 'check-circle' : 'square-o'}
            color={data.loaded ? 'red' : ''}
            width="100"
            selected={data.loaded}
            content="Skondensuj masę foronu"
            onClick={() => act('toggle_load')}
          />
          <Button
            fluid
            icon={data.chambered ? 'check-circle' : 'square-o'}
            color={data.chambered ? 'red' : ''}
            width="100"
            selected={data.chambered}
            content="Rozpocznij ładowanie magnetyczne"
            onClick={() => act('chamber')}
          />
          <Button
            fluid
            icon={data.safety ? 'power-off' : 'times'}
            color={data.safety ? 'red' : ''}
            width="100"
            selected={data.safety}
            content="Zwolnij pole zaciskające"
            onClick={() => act('toggle_safety')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
