import { BlockQuote, Box, Button, Section, Table } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA EDIT - polskie etykiety akcji (nazwy akcji zostają dla DM)
const ACTION_LABELS: Record<string, string> = {
  flw: 'Śledź',
  claim: 'Przejmij',
  reject: 'Odrzuć',
  ic: 'IC',
  mhelp: 'Mentorhelp',
  resolve: 'Rozwiąż',
  close: 'Zamknij',
  reopen: 'Otwórz ponownie',
};

type Data = {
  admin_ckey: any;
  closed_tickets: any;
  open_tickets: any;
  resolved_tickets: any;
  unclaimed_tickets: any;
};

export const TicketBrowser = (props) => {
  const { data } = useBackend<Data>();
  const {
    unclaimed_tickets = [],
    open_tickets = [],
    closed_tickets = [],
    resolved_tickets = [],
    admin_ckey,
  } = data;
  return (
    <Window title="Zgłoszenia" theme="admin" width={720} height={480}>
      <Window.Content scrollable>
        <Section
          title={
            <Table>
              <Table.Row>
                <Table.Cell inline>Administrator: {admin_ckey}</Table.Cell>
              </Table.Row>
            </Table>
          }
        />
        <Section>
          <TicketMenu
            ticket_list={unclaimed_tickets}
            name={'Nieprzejęte zgłoszenia'}
            actions={[
              ['flw', 'blue'],
              ['claim', 'good'],
              ['reject', 'bad'],
              ['ic', 'label'],
              ['mhelp', 'label'],
            ]}
          />
          <TicketMenu
            ticket_list={open_tickets}
            name={'Przejęte zgłoszenia'}
            actions={[
              ['flw', 'blue'],
              ['claim', 'average'],
              ['resolve', 'good'],
              ['reject', 'bad'],
              ['close', 'label'],
              ['mhelp', 'label'],
              ['ic', 'label'],
            ]}
          />
          <TicketMenu
            ticket_list={resolved_tickets}
            name={'Rozwiązane zgłoszenia'}
            actions={[
              ['flw', 'blue'],
              ['reopen', 'good'],
            ]}
          />
          <TicketMenu
            ticket_list={closed_tickets}
            name={'Zamknięte zgłoszenia'}
            actions={[
              ['flw', 'blue'],
              ['reopen', 'good'],
            ]}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketMenu = (props) => {
  const { ticket_list, name, actions = [] } = props;
  const { act } = useBackend<Data>();
  return (
    <Section title={name}>
      <Table>
        {ticket_list.map((ticket) => (
          <Section key={ticket.name}>
            <Table.Row>
              <Table.Cell bold collapsing>
                <Button
                  color="transparent"
                  onClick={() =>
                    act('view', {
                      id: ticket.id,
                    })
                  }
                >
                  <u>{'#' + ticket.id}</u>
                </Button>
              </Table.Cell>
              <Table.Cell>
                <Button
                  color={ticket.disconnected ? 'bad' : 'transparent'}
                  onClick={() =>
                    act('pm', {
                      id: ticket.id,
                    })
                  }
                >
                  <u>
                    {ticket.initiator_key_name}
                    {ticket.disconnected ? ' [DC]' : ''}
                  </u>
                </Button>
              </Table.Cell>
              {actions.map((action) => (
                <Table.Cell key={action[0]} collapsing>
                  <Button
                    content={ACTION_LABELS[action[0]] || capitalize(action[0])}
                    onClick={() =>
                      act(action[0], {
                        id: ticket.id,
                      })
                    }
                    color={action[1]}
                  />
                </Table.Cell>
              ))}
            </Table.Row>
            <BlockQuote>{ticket.name}</BlockQuote>
            <Box color={ticket.claimed_key_name ? 'good' : 'bad'}>
              {ticket.claimed_key_name
                ? ticket.state < 3
                  ? `Przejął: ${ticket.claimed_key_name}`
                  : ticket.state === 3
                    ? `Zamknął: ${ticket.claimed_key_name}`
                    : `Rozwiązał: ${ticket.claimed_key_name}`
                : 'NIEPRZEJĘTE'}
            </Box>
          </Section>
        ))}
      </Table>
    </Section>
  );
};
