// AQUILA - okno NIFSoftu „Poemat Wspólnych Dusz”, przepisane z NifSoulPoem.jsx z Monkestation (pierwotnie Skyrat/Nova)
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type PoemMessage = {
  identifier: string;
  sender_name: string;
  message: string;
  timestamp: string;
};

type Data = {
  name_to_send: string;
  text_to_send: string;
  messages: PoemMessage[];
  receiving_data: BooleanLike;
  transmitting_data: BooleanLike;
  theme: string;
};

export const NifSoulPoem = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    name_to_send,
    text_to_send,
    messages = [],
    receiving_data,
    transmitting_data,
    theme,
  } = data;

  return (
    <Window
      title="Poemat Wspólnych Dusz"
      width={500}
      height={700}
      theme={theme === 'default' ? undefined : theme}
    >
      <Window.Content scrollable>
        <Section title="Ustawienia">
          <LabeledList>
            <LabeledList.Item label="Podpis">
              <Input
                fluid
                value={name_to_send}
                onBlur={(value) => act('change_name', { new_name: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Twój wers">
              <Input
                fluid
                value={text_to_send}
                onBlur={(value) =>
                  act('change_message', { new_message: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Wysyłanie">
              <Button
                fluid
                icon={transmitting_data ? 'tower-broadcast' : 'ban'}
                color={transmitting_data ? 'green' : 'red'}
                onClick={() => act('toggle_transmitting')}
              >
                {transmitting_data ? 'Włączone' : 'Wyłączone'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Odbieranie">
              <Button
                fluid
                icon={receiving_data ? 'inbox' : 'ban'}
                color={receiving_data ? 'green' : 'red'}
                onClick={() => act('toggle_receiving')}
              >
                {receiving_data ? 'Włączone' : 'Wyłączone'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Zebrane wersy">
          {messages.length ? (
            <Stack vertical>
              {messages.map((message) => (
                <Stack.Item key={message.identifier}>
                  <Box textAlign="center" fontSize="14px">
                    <b>{message.sender_name} </b>
                    <Button
                      icon="trash"
                      tooltip="Usuń ten wers"
                      onClick={() =>
                        act('remove_message', {
                          identifier: message.identifier,
                        })
                      }
                    />
                  </Box>
                  <Divider />
                  <Box>{message.message}</Box>
                  <BlockQuote mt={1}>Odebrano: {message.timestamp}</BlockQuote>
                </Stack.Item>
              ))}
            </Stack>
          ) : (
            <NoticeBox>Nie masz jeszcze żadnych wersów.</NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
