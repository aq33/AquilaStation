import { Box, Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { sanitizeText } from '../../sanitize';
import type { CommsConsoleData } from './types';

export function PageMessages(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const { messages = [] } = data;

  return (
    <Section fill scrollable title="Wiadomości">
      {messages.length === 0 && <NoticeBox>Brak wiadomości.</NoticeBox>}
      {messages
        .map((message, messageIndex) => {
          const possibleAnswers = Object.entries(message.possibleAnswers || {});
          const textHtml = {
            __html: sanitizeText(message.content),
          };

          return (
            <Section
              title={message.title}
              key={messageIndex}
              buttons={
                <Button.Confirm
                  icon="trash"
                  color="red"
                  confirmContent="Na pewno?"
                  onClick={() =>
                    act('deleteMessage', {
                      message: messageIndex + 1,
                    })
                  }
                >
                  Usuń
                </Button.Confirm>
              }
            >
              <Box dangerouslySetInnerHTML={textHtml} />

              {possibleAnswers.length > 0 && (
                <Box mt={1}>
                  {possibleAnswers.map(([answerKey, answerText]) => (
                    <Button
                      key={answerKey}
                      color={
                        message.answered === answerKey ? 'good' : undefined
                      }
                      onClick={
                        message.answered
                          ? undefined
                          : () =>
                              act('answerMessage', {
                                message: messageIndex + 1,
                                answer: answerKey,
                              })
                      }
                    >
                      {String(answerText)}
                    </Button>
                  ))}
                </Box>
              )}
            </Section>
          );
        })
        .reverse()}
    </Section>
  );
}
