import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  NumberInput,
  Stack,
  Table,
} from 'tgui-core/components';

import { PageSelect } from '../components/PageSelect';
import { ScrollableSection } from '../components/ScrollableSection';
import type { LibraryConsoleData } from '../types';
import { useLibraryContext } from '../useLibraryContext';

export function Checkout(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkout_page, checkout_page_count } = data;

  const { checkoutBookState } = useLibraryContext();
  const [checkoutBook, setCheckoutBook] = checkoutBookState;

  return (
    <Stack vertical height="100%" justify="space-between">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item grow>
            <ScrollableSection
              header="Wypożyczone książki"
              contents={<CheckoutEntries />}
            />
          </Stack.Item>
          <Stack.Item align="center">
            <PageSelect
              minimum_page_count={1}
              page_count={checkout_page_count}
              current_page={checkout_page}
              call_on_change={(value) =>
                act('switch_checkout_page', {
                  page: value,
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          icon="barcode"
          fontSize="20px"
          onClick={() => setCheckoutBook(true)}
        >
          Wypożycz książkę
        </Button>
      </Stack.Item>
      {!!checkoutBook && <CheckoutModal />}
    </Stack>
  );
}

function CheckoutModal(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkout_title, inventory_titles = [] } = data;

  const { checkoutBookState } = useLibraryContext();
  const [_checkoutBook, setCheckoutBook] = checkoutBookState;

  const [checkoutee, setCheckoutee] = useState('Odbiorca');
  const [checkoutPeriod, setCheckoutPeriod] = useState(5);

  return (
    <Modal width="500px" py={4}>
      <Stack fill vertical>
        <Stack.Item fontSize="20px">
          Czy na pewno chcesz wypożyczyć tę książkę?
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            over
            width="100%"
            selected={checkout_title}
            placeholder="Wybierz książkę z katalogu..."
            displayText={checkout_title}
            options={inventory_titles}
            onSelected={(e) => {
              act('set_checkout', {
                book_name: e,
              });
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Dla kogo">
              <Input
                width="160px"
                value={checkoutee}
                onChange={setCheckoutee}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Okres wypożyczenia">
              <NumberInput
                value={checkoutPeriod}
                unit=" min"
                minValue={1}
                maxValue={120}
                step={1}
                stepPixelSize={10}
                onChange={(value) => setCheckoutPeriod(value)}
              />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Stack justify="center" align="center" pt={1}>
            <Stack.Item>
              <Button
                icon="upload"
                fontSize="16px"
                color="good"
                disabled={!checkout_title}
                onClick={() => {
                  setCheckoutBook(false);
                  act('checkout', {
                    loaned_to: checkoutee,
                    checkout_time: checkoutPeriod,
                  });
                }}
                lineHeight={2}
              >
                Wypożycz
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="times"
                fontSize="16px"
                color="bad"
                onClick={() => setCheckoutBook(false)}
                lineHeight={2}
              >
                Wróć
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}

export function CheckoutEntries(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkouts = [] } = data;

  return (
    <Table>
      <Table.Row header className="candystripe">
        <Table.Cell>Tytuł</Table.Cell>
        <Table.Cell>Wypożyczający</Table.Cell>
        <Table.Cell>Wypożyczono</Table.Cell>
        <Table.Cell>Pozostało</Table.Cell>
        <Table.Cell>Zwrot</Table.Cell>
      </Table.Row>
      {checkouts.length === 0 ? (
        <Table.Row>
          <Table.Cell textAlign="center" colSpan={5}>
            <NoticeBox>Brak wypożyczonych książek.</NoticeBox>
          </Table.Cell>
        </Table.Row>
      ) : (
        checkouts.map((entry) => (
          <Table.Row key={entry.ref} className="candystripe">
            <Table.Cell>{entry.title}</Table.Cell>
            <Table.Cell>{entry.borrower}</Table.Cell>
            <Table.Cell>{entry.taken_minutes} min temu</Table.Cell>
            <Table.Cell backgroundColor={entry.overdue ? 'bad' : 'good'}>
              {entry.overdue ? 'Po terminie' : `${entry.due_in_minutes} min`}
            </Table.Cell>
            <Table.Cell width="70px" textAlign="center">
              <Button
                mb={1}
                tooltip="Zwróć"
                onClick={() =>
                  act('checkin', {
                    checked_out_id: entry.ref,
                  })
                }
                icon="box-open"
              />
            </Table.Cell>
          </Table.Row>
        ))
      )}
    </Table>
  );
}
