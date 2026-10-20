import { useEffect, useRef, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Image,
  Input,
  Modal,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { MessageContent } from './MessageContent';
import {
  EVERYONE_CHAT,
  type NtMessage,
  type NtMessenger,
  type NtosMessengerData,
} from './types';

type ChatScreenProps = {
  canReply: boolean;
  chatRef: string;
  /** Czy rozmowa jest już zapisana (ma wiadomości), a nie tylko otwarta z listy */
  saved: boolean;
  messages: NtMessage[];
  recipient: NtMessenger;
  unreads: number;
  onBack: () => void;
};

const READ_UNREADS_TIME_MS = 1000;
const SEND_COOLDOWN_MS = 1000;

export const ChatScreen = (props: ChatScreenProps) => {
  const { act, data } = useBackend<NtosMessengerData>();
  const { isSilicon, photo, sending_virus, emoji_names = [] } = data;
  const { canReply, chatRef, saved, messages, recipient, unreads, onBack } =
    props;

  const [message, setMessage] = useState('');
  const [canSend, setCanSend] = useState(true);
  const [previewingImage, setPreviewingImage] = useState<string>();
  const scrollRef = useRef<HTMLDivElement | null>(null);

  // Przewijanie na dół przy nowej wiadomości
  useEffect(() => {
    const scroll = scrollRef.current;
    if (scroll) {
      scroll.scrollTop = scroll.scrollHeight;
    }
  }, [messages.length]);

  // Po chwili oglądania rozmowy oznaczamy wiadomości jako przeczytane
  useEffect(() => {
    if (unreads <= 0) {
      return;
    }
    const timeout = setTimeout(
      () => act('PDA_clearUnreads', { ref: chatRef }),
      READ_UNREADS_TIME_MS,
    );
    return () => clearTimeout(timeout);
  }, [unreads, messages.length, chatRef]);

  const handleSendMessage = (value: string = message) => {
    if (value === '' || !canSend) {
      return;
    }
    act('PDA_sendMessage', {
      ref: recipient.ref || chatRef,
      name: recipient.name,
      job: recipient.job,
      message: value,
    });
    setMessage('');
    setCanSend(false);
    setTimeout(() => setCanSend(true), SEND_COOLDOWN_MS);
  };

  const filteredMessages: React.JSX.Element[] = [];
  for (let index = 0; index < messages.length; index++) {
    const msg = messages[index];
    const isSwitch = !(
      index === 0 || messages[index - 1].outgoing === msg.outgoing
    );
    if (unreads > 0 && index === messages.length - unreads) {
      filteredMessages.push(
        <ChatDivider key={`divider-${index}`} mt={isSwitch ? 3 : 1} />,
      );
    }
    filteredMessages.push(
      <Stack.Item key={index} mt={isSwitch ? 3 : 1}>
        <ChatMessage
          message={msg}
          emojiNames={emoji_names}
          onPreviewImage={
            msg.photo ? () => setPreviewingImage(msg.photo) : undefined
          }
        />
      </Stack.Item>,
    );
  }

  let sendingBar: React.JSX.Element;
  if (!canReply) {
    sendingBar = (
      <Section fill>
        <Box width="100%" italic color="gray" ml={1}>
          {chatRef === EVERYONE_CHAT
            ? 'To są Twoje wiadomości do wszystkich.'
            : 'Nie możesz odpowiedzieć temu użytkownikowi.'}
        </Box>
      </Section>
    );
  } else {
    const attachmentButton = sending_virus ? (
      <Button
        tooltip="BŁĄD: niezweryfikowany podpis pliku. Skontaktuj się ze stażystą wsparcia NT."
        icon="triangle-exclamation"
        color="red"
      />
    ) : (
      // AQUILA: załączniki wybiera u nas tylko krzem (zdjęcia z kamery SI);
      // reszta załącza zdjęcie zeskanowane PDA, widoczne nad polem wiadomości.
      !!isSilicon && (
        <Button
          tooltip="Dodaj załącznik"
          icon="image"
          onClick={() => act('PDA_selectPhoto')}
        />
      )
    );

    sendingBar = (
      <Section fill>
        <Stack vertical>
          {!!photo && (
            <Stack.Item>
              <Button
                pt={1}
                onClick={() => act('PDA_clearPhoto')}
                tooltip="Usuń załącznik"
              >
                <Image src={photo} />
              </Button>
            </Stack.Item>
          )}
          <Stack.Item>
            <Stack fill align="center">
              <Stack.Item grow>
                <Input
                  placeholder={`Wiadomość do: ${recipient.name}...`}
                  fluid
                  autoFocus
                  value={message}
                  maxLength={1024}
                  onChange={setMessage}
                  onEnter={(value) => handleSendMessage(value)}
                  selfClear
                />
              </Stack.Item>
              {!!attachmentButton && (
                <Stack.Item>{attachmentButton}</Stack.Item>
              )}
              <Stack.Item>
                <Button
                  tooltip="Wyślij"
                  icon="arrow-right"
                  onClick={() => handleSendMessage()}
                  disabled={!canSend}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }

  return (
    <Stack vertical fill>
      <Section>
        <Button icon="arrow-left" onClick={onBack}>
          Wstecz
        </Button>
        {saved && (
          <Button.Confirm
            icon="trash-can"
            confirmContent="Na pewno?"
            onClick={() => {
              act('PDA_clearMessages', { ref: chatRef });
              onBack();
            }}
          >
            Usuń rozmowę
          </Button.Confirm>
        )}
      </Section>
      <Stack.Item grow={1}>
        <Section
          scrollable
          fill
          fitted
          title={
            recipient.job
              ? `${recipient.name} (${recipient.job})`
              : recipient.name
          }
          ref={scrollRef}
        >
          <Stack vertical className="NtosChatLog">
            {!!(messages.length > 0 && canReply) && (
              <>
                <Stack.Item textAlign="center" fontSize={1}>
                  Początek rozmowy z {recipient.name}.
                </Stack.Item>
                <Stack.Divider />
              </>
            )}
            {filteredMessages}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>{sendingBar}</Stack.Item>
      {!!previewingImage && (
        <Modal className="NtosChatLog__ImagePreview">
          <Section
            title="Podgląd zdjęcia"
            buttons={
              <Button
                icon="arrow-left"
                tooltipPosition="left"
                onClick={() => setPreviewingImage(undefined)}
              >
                Wstecz
              </Button>
            }
          >
            <Image src={previewingImage} />
          </Section>
        </Modal>
      )}
    </Stack>
  );
};

type ChatMessageProps = {
  message: NtMessage;
  emojiNames: string[];
  onPreviewImage?: () => void;
};

const ChatMessage = (props: ChatMessageProps) => {
  const { message, emojiNames, onPreviewImage } = props;
  const { outgoing, everyone, automated, timestamp, photo } = message;

  return (
    <Box className={`NtosChatMessage${outgoing ? '_outgoing' : ''}`}>
      <Box className="NtosChatMessage__content">
        <Box as="span">
          {/* AQUILA: emotki w treści zamiast surowego HTML z tg */}
          <MessageContent
            contents={message.contents}
            emojis={message.emojis}
            emoji_names={emojiNames}
          />
        </Box>
        {!!timestamp && (
          <Tooltip content={timestamp} position={outgoing ? 'left' : 'right'}>
            <Icon
              className="NtosChatMessage__timestamp"
              name="clock-o"
              size={0.8}
            />
          </Tooltip>
        )}
      </Box>
      {!!everyone && (
        <Box className="NtosChatMessage__everyone">Wysłano do wszystkich</Box>
      )}
      {!!automated && (
        <Box className="NtosChatMessage__everyone">Wiadomość automatyczna</Box>
      )}
      {!!photo && (
        <Button
          tooltip="Pokaż zdjęcie"
          className="NtosChatMessage__image"
          color="transparent"
          onClick={onPreviewImage}
        >
          <Image src={photo} mt={1} />
        </Button>
      )}
    </Box>
  );
};

const ChatDivider = (props: { mt: number }) => {
  return (
    <Box className="UnreadDivider" m={0} mt={props.mt}>
      <div />
      <span>Nieprzeczytane wiadomości</span>
      <div />
    </Box>
  );
};
