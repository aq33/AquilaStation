import { Box, Button } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { entryAmount } from './helpers';
import { type CargoData, CURRENCY } from './types';

/** Polska odmiana słowa "przedmiot" */
function itemsLabel(amount: number): string {
  if (amount === 1) {
    return '1 przedmiot';
  }
  const lastDigit = amount % 10;
  const lastTwo = amount % 100;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14)) {
    return `${amount} przedmioty`;
  }
  return `${amount} przedmiotów`;
}

export function CargoCartButtons(props) {
  const { act, data } = useBackend<CargoData>();
  const { cart = [], requestonly, can_send, can_approve_requests } = data;

  let total = 0;
  let amount = 0;
  for (let i = 0; i < cart.length; i++) {
    amount += entryAmount(cart[i]);
    total += cart[i].cost;
  }

  const canClear =
    !requestonly && !!can_send && !!can_approve_requests && cart.length > 0;

  return (
    <>
      <Box inline mx={1}>
        {amount === 0 ? 'Koszyk jest pusty' : itemsLabel(amount)}{' '}
        {total > 0 && `(${formatMoney(total)}${CURRENCY})`}
      </Box>

      <Button
        disabled={!canClear}
        icon="times"
        color="transparent"
        onClick={() => act('clear')}
      >
        Wyczyść
      </Button>
    </>
  );
}
