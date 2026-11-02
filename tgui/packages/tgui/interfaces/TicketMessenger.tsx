import {
  Box,
  Button,
  Divider,
  Input,
  Section,
  Table,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  antag_status: any;
  claimee: any;
  claimee_key: any;
  disconnected: any;
  id: any;
  messages: any;
  sender: any;
  ticket_state: any;
  time_closed: any;
  time_opened: any;
  world_time: any;
};

export const TicketMessenger = (props) => {
  return (
    <Window title="Zgłoszenie" theme="admin" width={620} height={500}>
      <Window.Content>
        <Section height="85px">
          <TicketActionBar />
        </Section>
        <Section>
          <TicketChatWindow />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketActionBar = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    disconnected,
    time_opened,
    time_closed,
    world_time,
    ticket_state,
    claimee,
    claimee_key,
    antag_status,
    id,
    sender,
  } = data;
  return (
    <Box>
      <Box bold inline>
        Zgłoszenie do adminów #{id}: {sender}
      </Box>
      <Box inline color={antag_status === 'None' ? 'green' : 'red'}>
        Antagonista: {antag_status === 'None' ? 'brak' : antag_status}
      </Box>
      <Box />
      <Box inline color={claimee_key ? 'blue' : 'red'} bold>
        Przejął: {claimee_key ? claimee_key : 'nikt'}
      </Box>
      <Box inline>|</Box>
      <Box inline bold>
        Otwarte {round((world_time - time_opened) / 600, 0)} min temu
      </Box>
      <Box inline>
        {' |'}
        <Button
          color="transparent"
          content="Zmień tytuł"
          onClick={() => act('retitle')}
        />
        |
        <Button
          color="transparent"
          content="Otwórz ponownie"
          onClick={() => act('reopen')}
        />
        |
      </Box>
      <Divider />
      <Box>
        {disconnected ? 'ROZŁĄCZONY' : <TicketFullMonty />}
        <TicketClosureStates />
      </Box>
    </Box>
  );
};

export const TicketFullMonty = (props) => {
  const { act } = useBackend<Data>();
  return (
    <Box inline>
      <Button color="purple" content="?" onClick={() => act('moreinfo')} />
      <Button color="blue" content="PP" onClick={() => act('playerpanel')} />
      <Button color="blue" content="VV" onClick={() => act('viewvars')} />
      <Button color="blue" content="SM" onClick={() => act('subtlemsg')} />
      <Button color="blue" content="FLW" onClick={() => act('flw')} />
      <Button color="blue" content="TP" onClick={() => act('traitorpanel')} />
      <Button color="green" content="LOG" onClick={() => act('viewlogs')} />
      <Button
        color="green"
        content="HIST"
        tooltip="Historia ticketów gracza"
        onClick={() => act('tickethistory')}
      />
      <Button color="red" content="SMITE" onClick={() => act('smite')} />
    </Box>
  );
};

export const TicketClosureStates = (props) => {
  const { act } = useBackend<Data>();
  return (
    <Box inline>
      <Button content="REJT" onClick={() => act('reject')} />
      <Button content="IC" onClick={() => act('markic')} />
      <Button content="CLOSE" onClick={() => act('close')} />
      <Button content="RSLVE" onClick={() => act('resolve')} />
      <Button content="MHELP" onClick={() => act('mentorhelp')} />
    </Box>
  );
};

export const TicketChatWindow = (props) => {
  const { act, data } = useBackend<Data>();
  const { messages = [] } = data;
  return (
    <Box>
      <Box overflowY="scroll" height="315px">
        <Table>
          {messages.map((message) => (
            <Section key={message.time}>
              <Table.Row>
                <Table.Cell>{message.time}</Table.Cell>
                <Table.Cell color={message.color}>
                  <Box>
                    <Box inline bold>
                      {message.from && message.to
                        ? `PW od ${decodeHtmlEntities(message.from)} do ${decodeHtmlEntities(message.to)}`
                        : decodeHtmlEntities(message.from)
                          ? `Odpowiedź od ${decodeHtmlEntities(message.from)}`
                          : decodeHtmlEntities(message.to)
                            ? `PW do ${decodeHtmlEntities(message.to)}`
                            : ''}
                    </Box>
                    <Box inline>{decodeHtmlEntities(message.message)}</Box>
                  </Box>
                </Table.Cell>
              </Table.Row>
            </Section>
          ))}
        </Table>
      </Box>
      <Divider />
      <Input
        fluid
        selfClear
        onEnter={(value) =>
          act('sendpm', {
            text: value,
          })
        }
      />
    </Box>
  );
};
