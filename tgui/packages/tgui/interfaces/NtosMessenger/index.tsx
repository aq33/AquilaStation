import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Icon,
  Image,
  Input,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { NtosWindow } from '../../layouts';
import { ChatScreen } from './ChatScreen';
import {
  EVERYONE_CHAT,
  type NtChat,
  type NtMessage,
  type NtMessenger,
  type NtosMessengerData,
} from './types';

export { MessageContent } from './MessageContent';

/** Klucz rozmowy dla wiadomości z płaskiej listy DM */
const chatKeyOf = (message: NtMessage) => {
  if (!message.outgoing) {
    return message.ref;
  }
  if (message.everyone) {
    return EVERYONE_CHAT;
  }
  return message.target_ref || `target:${message.target}`;
};

/**
 * AQUILA: nasz DM trzyma wiadomości jako jedną listę, więc rozmowy (jak w tg)
 * składamy po stronie okna.
 */
const buildChats = (
  messages: NtMessage[],
  messengers: NtMessenger[],
): Record<string, NtChat> => {
  const chats: Record<string, NtChat> = {};
  messages.forEach((message, index) => {
    const key = chatKeyOf(message);
    let chat = chats[key];
    if (!chat) {
      chat = {
        ref: key,
        recipient: { name: '', job: '', ref: undefined },
        messages: [],
        can_reply: false,
        unread_messages: 0,
        last_index: index,
      };
      chats[key] = chat;
    }
    chat.messages.push(message);
    chat.last_index = index;
    if (!message.outgoing && message.unread) {
      chat.unread_messages++;
    }
  });
  for (const chat of Object.values(chats)) {
    if (chat.ref === EVERYONE_CHAT) {
      chat.recipient = { name: 'Wszyscy', job: '' };
      continue;
    }
    const messenger = messengers.find((m) => m.ref === chat.ref);
    const lastIncoming = chat.messages.findLast((m) => !m.outgoing);
    if (messenger) {
      chat.recipient = messenger;
    } else if (lastIncoming) {
      chat.recipient = {
        name: lastIncoming.name,
        job: lastIncoming.job,
        ref: lastIncoming.ref,
      };
    } else {
      // tylko wychodzące do kogoś, kogo już nie ma na liście
      chat.recipient = { name: chat.messages[0].target || '?', job: '' };
    }
    chat.can_reply = !!messenger || (!!lastIncoming && !lastIncoming.automated);
  }
  return chats;
};

export const NtosMessenger = (props) => {
  const { data } = useBackend<NtosMessengerData>();
  const { messages = [], messengers = [] } = data;
  const [openChat, setOpenChat] = useState<string | null>(null);

  const chats = buildChats(messages, messengers);

  let content: React.JSX.Element;
  const savedChat = openChat !== null ? chats[openChat] : undefined;
  const temporaryRecipient =
    openChat !== null ? messengers.find((m) => m.ref === openChat) : undefined;
  if (openChat !== null && (savedChat || temporaryRecipient)) {
    content = (
      <ChatScreen
        key={openChat}
        chatRef={openChat}
        saved={!!savedChat}
        canReply={savedChat ? savedChat.can_reply : !!temporaryRecipient}
        messages={savedChat ? savedChat.messages : []}
        recipient={savedChat ? savedChat.recipient : temporaryRecipient!}
        unreads={savedChat ? savedChat.unread_messages : 0}
        onBack={() => setOpenChat(null)}
      />
    );
  } else {
    content = <ContactsScreen chats={chats} onOpenChat={setOpenChat} />;
  }

  return (
    <NtosWindow width={600} height={850}>
      <NtosWindow.Content>{content}</NtosWindow.Content>
    </NtosWindow>
  );
};

type ContactsScreenProps = {
  chats: Record<string, NtChat>;
  onOpenChat: (ref: string) => void;
};

const ContactsScreen = (props: ContactsScreenProps) => {
  const { act, data } = useBackend<NtosMessengerData>();
  const {
    owner,
    ringer_status,
    sending_and_receiving,
    messengers = [],
    sortByJob,
    canSpam,
    isSilicon,
    photo,
    virus_attach,
    sending_virus,
  } = data;
  const { chats, onOpenChat } = props;

  const [searchUser, setSearchUser] = useState('');

  const searchChatByName = createSearch(
    searchUser,
    (chat: NtChat) => chat.recipient.name + chat.recipient.job,
  );
  const searchMessengerByName = createSearch(
    searchUser,
    (messenger: NtMessenger) => messenger.name + messenger.job,
  );

  // najpierw nieprzeczytane, potem od najnowszej rozmowy
  const openChatsArray = Object.values(chats)
    .sort(
      (a, b) =>
        Number(b.unread_messages > 0) - Number(a.unread_messages > 0) ||
        b.last_index - a.last_index,
    )
    .filter(searchChatByName);

  const chatButtons = openChatsArray.map((chat) => (
    <ChatButton
      key={chat.ref}
      name={
        chat.recipient.job
          ? `${chat.recipient.name} (${chat.recipient.job})`
          : chat.recipient.name
      }
      chatRef={chat.ref}
      unreads={chat.unread_messages}
      onOpen={onOpenChat}
    />
  ));

  const messengerButtons = messengers
    .filter(
      (messenger) => !chats[messenger.ref!] && searchMessengerByName(messenger),
    )
    .map((messenger) => (
      <ChatButton
        key={messenger.ref}
        name={`${messenger.name} (${messenger.job})`}
        chatRef={messenger.ref!}
        unreads={0}
        onOpen={onOpenChat}
      />
    ));

  const noId = !owner && !isSilicon;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" mr={1} />
              SpaceMessenger V6.5.4
            </Box>
            <Box italic opacity={0.3} mt={1}>
              Łączność odporna na szpiegów od 2467 roku.
            </Box>
            <Divider hidden />
            <Box>
              <Button
                icon="bell"
                selected={!!ringer_status}
                onClick={() => act('PDA_ringer_status')}
              >
                {ringer_status ? 'Dzwonek: wł.' : 'Dzwonek: wył.'}
              </Button>
              <Button
                icon="address-card"
                selected={!!sending_and_receiving}
                onClick={() => act('PDA_sAndR')}
              >
                {sending_and_receiving
                  ? 'Wysyłanie/odbiór: wł.'
                  : 'Wysyłanie/odbiór: wył.'}
              </Button>
              <Button icon="bell" onClick={() => act('PDA_ringSet')}>
                Ustaw dzwonek
              </Button>
              <Button icon="sort" onClick={() => act('PDA_changeSortStyle')}>
                {`Sortuj wg: ${sortByJob ? 'stanowiska' : 'nazwiska'}`}
              </Button>
              {!!virus_attach && (
                <Button
                  icon="bug"
                  color="bad"
                  onClick={() => act('PDA_toggleVirus')}
                >
                  {`Dołącz wirusa: ${sending_virus ? 'tak' : 'nie'}`}
                </Button>
              )}
            </Box>
          </Stack>
          <Divider hidden />
          <Stack justify="space-between">
            <Box m={0.5}>
              <Icon name="magnifying-glass" mr={1} />
              Szukaj użytkownika
            </Box>
            <Input
              width="220px"
              placeholder="Szukaj po nazwisku lub stanowisku..."
              value={searchUser}
              onChange={setSearchUser}
            />
          </Stack>
        </Section>
      </Stack.Item>
      {/* AQUILA: zdjęcie zeskanowane PDA czeka jako załącznik do następnej wiadomości */}
      {!!photo && (
        <Stack.Item>
          <Section
            title="Załączone zdjęcie"
            buttons={
              <Button icon="times" onClick={() => act('PDA_clearPhoto')}>
                Usuń
              </Button>
            }
          >
            <Image src={photo} />
          </Section>
        </Stack.Item>
      )}
      {chatButtons.length > 0 && (
        <Stack.Item grow={1}>
          <Stack vertical fill>
            <Section
              title={
                <>
                  <Icon name="comments" mr={1} />
                  Poprzednie rozmowy
                </>
              }
              buttons={
                // AQUILA: czyszczenie całej skrzynki naraz
                <Button.Confirm
                  icon="trash"
                  confirmContent="Na pewno?"
                  onClick={() => act('PDA_clearMessages')}
                >
                  Usuń wszystkie
                </Button.Confirm>
              }
            />
            <Section fill scrollable>
              <Stack vertical>{chatButtons}</Stack>
            </Section>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow={2}>
        <Stack vertical fill>
          <Section>
            <Stack>
              <Box m={0.5}>
                <Icon name="address-card" mr={1} />
                Wykryte komunikatory
              </Box>
            </Stack>
          </Section>
          <Section fill scrollable>
            <Stack vertical pb={1} fill>
              {messengerButtons.length === 0 && (
                <Stack align="center" justify="center" fill pl={4}>
                  <Icon color="gray" name="user-slash" size={2} />
                  <Stack.Item fontSize={1.5} ml={3}>
                    Nie znaleziono użytkowników.
                  </Stack.Item>
                </Stack>
              )}
              {messengerButtons}
            </Stack>
          </Section>
        </Stack>
      </Stack.Item>
      {!!canSpam && (
        <Stack.Item>
          <SendToAllSection />
        </Stack.Item>
      )}
      {noId && <NoIDDimmer />}
    </Stack>
  );
};

type ChatButtonProps = {
  name: string;
  unreads: number;
  chatRef: string;
  onOpen: (ref: string) => void;
};

const ChatButton = (props: ChatButtonProps) => {
  const { name, unreads, chatRef, onOpen } = props;
  const hasUnreads = unreads > 0;
  return (
    <Button
      icon={hasUnreads ? 'envelope' : undefined}
      fluid
      onClick={() => onOpen(chatRef)}
    >
      {hasUnreads && `[nieprzeczytane: ${unreads <= 9 ? unreads : '9+'}]`}{' '}
      {name}
    </Button>
  );
};

const SendToAllSection = (props) => {
  const { act } = useBackend<NtosMessengerData>();
  const [message, setMessage] = useState('');

  const send = (value: string) => {
    if (!value) {
      return;
    }
    act('PDA_sendEveryone', { message: value });
    setMessage('');
  };

  return (
    <>
      <Section>
        <Stack justify="space-between">
          <Stack.Item align="center">
            <Icon name="satellite-dish" mr={1} ml={0.5} />
            Wyślij do wszystkich
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrow-right"
              disabled={message === ''}
              onClick={() => send(message)}
            >
              Wyślij
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <TextArea
          height={6}
          width="100%"
          value={message}
          placeholder="Wiadomość do wszystkich..."
          onChange={setMessage}
          selfClear
          onEnter={(value) => send(value)}
        />
      </Section>
    </>
  );
};

const NoIDDimmer = () => {
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack ml={-2}>
          <Icon color="red" name="address-card" size={10} />
        </Stack>
        <Stack.Item fontSize="18px">
          Nadrukuj ID na urządzeniu, aby kontynuować.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
