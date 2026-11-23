// AQUILA - terminal restauracji/baru z robotami-turystami (aquila/code/modules/restaurant/terminal.dm)
import {
  Box,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Guest = {
  name: string;
  order: string | null;
  status: string;
  patience: number;
  waiting: boolean;
};

type Contract = {
  name: string;
  served: number;
  amount: number;
  time_left: number | null;
};

type Data = {
  venue_name: string;
  open: boolean;
  has_portal: boolean;
  served: number;
  lost: number;
  income: number;
  seats_total: number;
  seats_free: number;
  max_guests: number;
  contract: Contract | null;
  guests: Guest[];
};

export const RestaurantTerminal = (props) => {
  const { data } = useBackend<Data>();
  const {
    venue_name,
    open,
    has_portal,
    served,
    lost,
    income,
    seats_total,
    seats_free,
    max_guests,
    contract,
    guests = [],
  } = data;

  return (
    <Window title={venue_name} width={460} height={540}>
      <Window.Content scrollable>
        {!has_portal && (
          <NoticeBox danger>
            Brak portalu dla gości. Bez niego lokalu nie da się otworzyć.
          </NoticeBox>
        )}
        <Section title="Lokal">
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Box color={open ? 'good' : 'average'} bold>
                {open ? 'Otwarty, portal przyjmuje gości' : 'Zamknięty'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Zlecenie">
              {contract ? (
                <>
                  {contract.name}: {contract.served}/{contract.amount} gości
                  {contract.time_left !== null && (
                    <Box inline ml={1} color="label">
                      (zostało {contract.time_left} min)
                    </Box>
                  )}
                </>
              ) : (
                'Brak. Gości przysyła stacja handlowa na zlecenie.'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Obsłużeni goście">
              {served}
            </LabeledList.Item>
            <LabeledList.Item label="Wyszli głodni">{lost}</LabeledList.Item>
            <LabeledList.Item label="Zarobek">{income} kr</LabeledList.Item>
            <LabeledList.Item label="Miejsca">
              {seats_total} (wolne: {seats_free}), najwięcej gości naraz:{' '}
              {max_guests}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={`Goście (${guests.length})`}>
          {guests.length === 0 ? (
            <Box color="label">
              {open ? 'Czekamy na pierwszego gościa...' : 'Lokal jest pusty.'}
            </Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Gość</Table.Cell>
                <Table.Cell>Zamówienie</Table.Cell>
                <Table.Cell collapsing>Cierpliwość</Table.Cell>
              </Table.Row>
              {guests.map((guest, i) => (
                <Table.Row key={i} className="candystripe">
                  <Table.Cell>
                    <Box bold>{guest.name}</Box>
                    <Box color="label" fontSize="0.9em">
                      {guest.status}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>{guest.order || '—'}</Table.Cell>
                  <Table.Cell collapsing>
                    {guest.waiting ? (
                      <ProgressBar
                        width="80px"
                        value={guest.patience / 100}
                        ranges={{
                          good: [0.5, Infinity],
                          average: [0.2, 0.5],
                          bad: [-Infinity, 0.2],
                        }}
                      />
                    ) : (
                      '—'
                    )}
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
