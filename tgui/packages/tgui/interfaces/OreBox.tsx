import { Box, Button, Section, Table } from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Material = {
  name: string;
  amount: number;
};

type Data = {
  materials: Material[];
};

export const OreBox = (props) => {
  const { act, data } = useBackend<Data>();
  const { materials = [] } = data;

  return (
    <Window width={335} height={415}>
      <Window.Content scrollable>
        <Section
          title="Rudy"
          buttons={
            <Button
              disabled={materials.length === 0}
              onClick={() => act('removeall')}
            >
              Opróżnij
            </Button>
          }
        >
          <Table>
            <Table.Row header>
              <Table.Cell>Ruda</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                Ilość
              </Table.Cell>
            </Table.Row>
            {materials.map((material, id) => (
              <Table.Row key={id}>
                <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  <Box color="label" inline>
                    {material.amount}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        <Section>
          <Box>
            Rudę można załadować ręcznie albo z torby górniczej. Jeśli ciągniesz
            skrzynię, mając torbę przy pasku lub w kieszeni, wykopana ruda sama
            do niej trafia.
            <br />
            Gibtonit nie jest przyjmowany.
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
