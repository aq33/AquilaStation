import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import type { CargoData } from './types';

export function CargoStatus(props) {
  const { act, data } = useBackend<CargoData>();
  const {
    department,
    away,
    docked,
    loan,
    loan_dispatched,
    location,
    message,
    points,
    requestonly,
    can_send,
    mail,
  } = data;

  return (
    <Section
      title={department}
      buttons={
        <Box inline bold verticalAlign="middle">
          <AnimatedNumber
            value={points}
            format={(value) => formatMoney(value)}
          />
          {' kredytów'}
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Prom">
          {docked && !requestonly && can_send ? (
            <Button color="green" onClick={() => act('send')}>
              {location}
            </Button>
          ) : (
            String(location)
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Wiadomość Centrali">
          {message}
        </LabeledList.Item>
        {!!loan && !requestonly && (
          <LabeledList.Item label="Wypożyczenie">
            {!loan_dispatched ? (
              <Button disabled={!(away && docked)} onClick={() => act('loan')}>
                Wypożycz prom
              </Button>
            ) : (
              <Box color="bad">Wypożyczony Centrali</Box>
            )}
          </LabeledList.Item>
        )}
        {/* NSV13 - Mail Control */}
        {!requestonly && mail !== undefined && (
          <LabeledList.Item label="Poczta">
            <Button.Checkbox checked={mail} onClick={() => act('togglemail')}>
              Przyjmuj pocztę
            </Button.Checkbox>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
