import { classes } from 'common/react';
import { Box, Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  product_records: any;
  user: any;
};

export const MiningVendor = (props) => {
  const { act, data } = useBackend<Data>();
  let inventory = [...data.product_records];
  return (
    <Window width={425} height={600}>
      <Window.Content scrollable>
        <Section title="Użytkownik">
          {(data.user && (
            <Box>
              Witaj, <b>{data.user.name || 'Nieznajomy'}</b>,{' '}
              <b>{data.user.job || 'Bezrobotny'}</b>!
              <br />
              Your balance is <b>{data.user.points} mining points</b>.
            </Box>
          )) || (
            <Box color="light-gray">
              Brak zarejestrowanego identyfikatora!
              <br />
              Zgłoś się do kierownika personelu!
            </Box>
          )}
        </Section>
        <Section title="Wyposażenie">
          <Table>
            {inventory.map((product) => {
              return (
                <Table.Row key={product.name}>
                  <Table.Cell>
                    <span
                      className={classes(['vending32x32', product.path])}
                      style={{
                        verticalAlign: 'middle',
                      }}
                    />{' '}
                    <b>{product.name}</b>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      style={{
                        minWidth: '95px',
                        textAlign: 'center',
                      }}
                      disabled={!data.user || product.price > data.user.points}
                      content={'Punkty: ' + product.price}
                      onClick={() =>
                        act('purchase', {
                          ref: product.ref,
                        })
                      }
                    />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
