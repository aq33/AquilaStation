// AQUILA - kadź do lodów (code/modules/food_and_drinks/kitchen_machinery/icecream_vat.dm).
// tg ma inną kadź (menu radialne), więc to własne okno w miejsce dawnego HTML:
// wybór smaku, robienie gałek i rożków, wydawanie rożków, zawartość kadzi.
import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Product = {
  id: number;
  name: string;
  ingredients: string;
};

type Reagent = {
  name: string;
  volume: number;
  id: string;
};

type Data = {
  flavours: Product[];
  cones: Product[];
  dispense_flavour: number;
  flavour_name: string;
  product_amounts: number[];
  reagents: Reagent[];
};

const ProductRow = (props: { product: Product; isCone?: boolean }) => {
  const { act, data } = useBackend<Data>();
  const { product, isCone } = props;
  const amount = data.product_amounts?.[product.id - 1] ?? 0;
  return (
    <Table.Row className="candystripe">
      <Table.Cell>
        <Box bold>{product.name}</Box>
        <Box color="label" fontSize={0.9}>
          Składniki: {product.ingredients}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {amount}
      </Table.Cell>
      <Table.Cell collapsing>
        {isCone ? (
          <Button
            icon="ice-cream"
            disabled={amount < 1}
            onClick={() => act('cone', { id: product.id })}
          >
            Wydaj
          </Button>
        ) : (
          <Button
            icon="check"
            selected={data.dispense_flavour === product.id}
            onClick={() => act('select', { id: product.id })}
          >
            Wybierz
          </Button>
        )}
        <Button onClick={() => act('make', { id: product.id, amount: 1 })}>
          Zrób
        </Button>
        <Button onClick={() => act('make', { id: product.id, amount: 5 })}>
          x5
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

export const IcecreamVat = (props) => {
  const { act, data } = useBackend<Data>();
  const { flavours = [], cones = [], flavour_name } = data;
  const reagents = data.reagents || [];
  return (
    <Window width={560} height={560} title="Kadź do lodów">
      <Window.Content scrollable>
        <Section title={`Lody — wydawanie: ${flavour_name}`}>
          <Table>
            <Table.Row header>
              <Table.Cell>Smak</Table.Cell>
              <Table.Cell collapsing>Gałki</Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {flavours.map((product) => (
              <ProductRow key={product.id} product={product} />
            ))}
          </Table>
        </Section>
        <Section title="Rożki">
          <Table>
            <Table.Row header>
              <Table.Cell>Rodzaj</Table.Cell>
              <Table.Cell collapsing>Sztuk</Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {cones.map((product) => (
              <ProductRow key={product.id} product={product} isCone />
            ))}
          </Table>
        </Section>
        <Section title="Zawartość kadzi">
          {reagents.length === 0 ? (
            <NoticeBox>Kadź jest pusta.</NoticeBox>
          ) : (
            <Table>
              {reagents.map((reagent) => (
                <Table.Row key={reagent.id} className="candystripe">
                  <Table.Cell>
                    {reagent.name}: {reagent.volume}u
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="trash"
                      color="bad"
                      onClick={() => act('purge', { id: reagent.id })}
                    >
                      Wylej
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
