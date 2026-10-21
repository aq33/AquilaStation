import { useState } from 'react';
import {
  Button,
  Icon,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { entryAmount } from './helpers';
import { type CargoData, CURRENCY, MAX_ORDER } from './types';

export function CargoCart(props) {
  const { act, data } = useBackend<CargoData>();
  const { can_send, away, cart = [], docked, location, requestonly } = data;

  const sendable = !!away && !!docked;

  return (
    <Stack fill vertical g={0}>
      <Stack.Item grow>
        <Section fill scrollable>
          <CheckoutItems />
        </Section>
      </Stack.Item>
      {cart.length > 0 && !requestonly && !!can_send && (
        <Stack.Item>
          <Section textAlign="right">
            <Stack fill align="center">
              <Stack.Item grow>
                {!sendable && (
                  <Icon mr={0.5} size={1.5} color="blue" name="toolbox" spin />
                )}
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="green"
                  disabled={!sendable}
                  onClick={() => act('send')}
                  px={2}
                  py={1}
                  tooltip={sendable ? '' : `Prom: ${location}`}
                >
                  Potwierdź zamówienie
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
}

function CheckoutItems(props) {
  const { act, data } = useBackend<CargoData>();
  const { can_send, cart = [] } = data;

  const [isValid, setIsValid] = useState(true);

  if (cart.length === 0) {
    return <NoticeBox>Koszyk jest pusty</NoticeBox>;
  }

  return (
    <Table>
      <Table.Row header color="gray">
        <Table.Cell collapsing>ID</Table.Cell>
        <Table.Cell>Paczka</Table.Cell>
        <Table.Cell>Ilość</Table.Cell>
        <Table.Cell collapsing />
        <Table.Cell collapsing textAlign="right">
          Koszt
        </Table.Cell>
      </Table.Row>

      {cart.map((entry) => {
        const amount = entryAmount(entry);
        // Opłaconych prywatnie zamówień nie da się zmieniać z konsoli
        const canChange = !!can_send && !entry.paid;
        return (
          <Table.Row className="candystripe" key={entry.id}>
            <Table.Cell collapsing color="label">
              #{entry.id}
            </Table.Cell>
            <Table.Cell>{entry.object}</Table.Cell>

            <Table.Cell width={11}>
              {canChange ? (
                <>
                  <Button
                    icon="minus"
                    onClick={() => act('remove', { order_name: entry.object })}
                  />
                  <RestrictedInput
                    width={5}
                    minValue={0}
                    maxValue={MAX_ORDER}
                    value={amount}
                    onEnter={(value) =>
                      isValid &&
                      act('modify', {
                        order_name: entry.object,
                        amount: value,
                      })
                    }
                    onValidationChange={setIsValid}
                  />
                  <Button
                    icon="plus"
                    disabled={amount >= MAX_ORDER}
                    onClick={() =>
                      act('add_by_name', { order_name: entry.object })
                    }
                  />
                </>
              ) : (
                <RestrictedInput width="40px" value={amount} disabled />
              )}
            </Table.Cell>

            <Table.Cell collapsing color="average">
              {!!entry.paid && (
                <b>
                  [Prywatnie x{' '}
                  {typeof entry.paid === 'number' ? entry.paid : amount}]
                </b>
              )}
            </Table.Cell>

            <Table.Cell collapsing color="gold" textAlign="right">
              {formatMoney(entry.cost)}
              {CURRENCY}
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
}
