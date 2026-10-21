import { Button, NoticeBox, Section, Table } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { type CargoData, CURRENCY } from './types';

export function CargoRequests(props) {
  const { act, data } = useBackend<CargoData>();
  const { requests = [], requestonly, can_send, can_approve_requests } = data;

  const canAct = (!requestonly || !!can_send) && !!can_approve_requests;
  const showAccount = requests.some((request) => !!request.account);

  return (
    <Section fill scrollable>
      {requests.length === 0 && <NoticeBox success>Brak próśb</NoticeBox>}
      {requests.length > 0 && (
        <Table>
          <Table.Row header color="gray">
            <Table.Cell>ID</Table.Cell>
            <Table.Cell>Zamówienie</Table.Cell>
            <Table.Cell>Zamawiający</Table.Cell>
            <Table.Cell>Powód</Table.Cell>
            {showAccount && <Table.Cell>Konto</Table.Cell>}
            <Table.Cell>Koszt</Table.Cell>
            {canAct && <Table.Cell>Akcje</Table.Cell>}
          </Table.Row>

          {requests.map((request) => (
            <Table.Row key={request.id} className="candystripe" color="label">
              <Table.Cell collapsing>#{request.id}</Table.Cell>
              <Table.Cell>{request.object}</Table.Cell>
              <Table.Cell>
                <b>{request.orderer}</b>
              </Table.Cell>
              <Table.Cell color="lightgray" width="25%">
                <i>{decodeHtmlEntities(request.reason || '')}</i>
              </Table.Cell>
              {showAccount && (
                <Table.Cell collapsing>{request.account || '-'}</Table.Cell>
              )}
              <Table.Cell collapsing color="gold">
                {formatMoney(request.cost)}
                {CURRENCY}
              </Table.Cell>
              {canAct && (
                <Table.Cell collapsing>
                  <Button
                    icon="check"
                    color="good"
                    tooltip="Zatwierdź"
                    onClick={() =>
                      act('approve', {
                        id: request.id,
                      })
                    }
                  />
                  <Button
                    icon="times"
                    color="bad"
                    tooltip="Odrzuć"
                    onClick={() =>
                      act('deny', {
                        id: request.id,
                      })
                    }
                  />
                </Table.Cell>
              )}
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}
