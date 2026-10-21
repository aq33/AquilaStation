import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ore = {
  ore: string;
  value: number;
};

type Data = {
  can_go_home: BooleanLike;
  id_points: number;
  ores: Ore[];
  status_info: string;
  unclaimed_points: number;
};

export const LaborClaimConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    can_go_home,
    id_points,
    ores = [],
    status_info,
    unclaimed_points,
  } = data;

  return (
    <Window width={315} height={440}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Stan">{status_info}</LabeledList.Item>
            <LabeledList.Item label="Prom">
              <Button
                disabled={!can_go_home}
                onClick={() => act('move_shuttle')}
              >
                Wezwij prom
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Punkty">{id_points}</LabeledList.Item>
            <LabeledList.Item
              label="Nieodebrane punkty"
              buttons={
                <Button
                  disabled={!unclaimed_points}
                  onClick={() => act('claim_points')}
                >
                  Odbierz punkty
                </Button>
              }
            >
              {unclaimed_points}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Instrukcja">
          Wydobywaj rudę w kopalni obozu, przetop ją w hucie, a gotowe arkusze
          wrzuć do maszyny układającej obok tej konsoli. Potem odbierz punkty na
          swój identyfikator więźnia. Gdy uzbierasz limit, możesz wezwać prom na
          stację.
        </Section>
        <Section title="Wartość materiałów">
          <Table>
            <Table.Row header>
              <Table.Cell>Materiał</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                Punkty
              </Table.Cell>
            </Table.Row>
            {ores.map((ore) => (
              <Table.Row key={ore.ore}>
                <Table.Cell>{toTitleCase(ore.ore)}</Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  <Box color="label" inline>
                    {ore.value}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
