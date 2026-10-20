import { Fragment } from 'react';
import { Box, Button, Divider, Image, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  current_page: number;
  scribble_message: string | null;
  channel_has_messages: BooleanLike;
  channels: ChannelNames[];
  channel_data: ChannelData[];
  wanted_criminal: string | null;
  wanted_body: string | null;
  wanted_photo: string | null;
};

type ChannelNames = {
  name: string | null;
  page_number: number;
};

type ChannelData = {
  channel_name: string | null;
  author_name: string | null;
  is_censored: BooleanLike;
  channel_messages: ChannelMessages[];
};

type ChannelMessages = {
  message: string | null;
  photo: string | null;
  author: string | null;
};

export const Newspaper = (props) => {
  const { act, data } = useBackend<Data>();
  const { channels = [], current_page, scribble_message } = data;

  return (
    <Window width={300} height={400}>
      <Window.Content backgroundColor="#858387" scrollable>
        <Section>
          <Button
            icon="arrow-left"
            width="49%"
            disabled={!current_page}
            onClick={() => act('prev_page')}
          >
            Poprzednia
          </Button>
          <Button
            icon="arrow-right"
            width="50%"
            disabled={current_page === channels.length + 1}
            onClick={() => act('next_page')}
          >
            Następna
          </Button>
        </Section>
        {current_page === channels.length + 1 ? (
          <NewspaperEnding />
        ) : current_page ? (
          <NewspaperChannel />
        ) : (
          <NewspaperIntro />
        )}
        {!!scribble_message && (
          <Box
            italic
            style={{
              borderTop: '3px dotted rgba(255, 255, 255, 0.8)',
              borderBottom: '3px dotted rgba(255, 255, 255, 0.8)',
            }}
          >
            Na dole strony ktoś coś nabazgrał: „{scribble_message}”
          </Box>
        )}
        <Box textAlign="center" mt={1}>
          {current_page + 1}
        </Box>
      </Window.Content>
    </Window>
  );
};

const NewspaperIntro = (props) => {
  const { data } = useBackend<Data>();
  const { channels = [], wanted_criminal } = data;

  return (
    <Section>
      <Box bold fontSize="30px" textAlign="center">
        The Griffon
      </Box>
      <Box bold fontSize="15px" textAlign="center">
        Tylko do użytku na placówkach kosmicznych!
      </Box>
      {!channels.length && !wanted_criminal ? (
        <Box italic mt={1}>
          Poza tytułem reszta gazety jest niezadrukowana...
        </Box>
      ) : (
        <>
          <Box fontSize="12px" mt={1}>
            Spis treści:
          </Box>
          {channels.map((channel) => (
            <Box key={channel.page_number}>
              Strona {(channel.page_number || 0) + 1}: {channel.name}
            </Box>
          ))}
          {!!wanted_criminal && (
            <Box bold color="red">
              Ostatnia strona: ważny komunikat ochrony
            </Box>
          )}
        </>
      )}
    </Section>
  );
};

const NewspaperChannel = (props) => {
  const { data } = useBackend<Data>();
  const { channel_has_messages, channel_data = [] } = data;

  return (
    <Section>
      {channel_data.map((individual_channel) => (
        <Box key={individual_channel.channel_name}>
          <Box bold fontSize="15px">
            {individual_channel.channel_name}
          </Box>
          <Box fontSize="12px">
            Autor kanału: {individual_channel.author_name}
          </Box>
          <Divider />
          {individual_channel.is_censored
            ? 'Ten kanał uznano za zagrożenie dla dobra stacji i opatrzono go zakazem klasy D. Jego treści nie trafiły do gazety w chwili druku.'
            : channel_has_messages
              ? individual_channel.channel_messages.map((message, i) => (
                  <Fragment key={i}>
                    <Box>
                      <Box style={{ whiteSpace: 'pre-wrap' }}>
                        {message.message}
                      </Box>
                      {!!message.photo && (
                        <Image src={message.photo} width="180px" />
                      )}
                      <Box fontSize="11px">Napisał(a): {message.author}</Box>
                    </Box>
                    <Divider />
                  </Fragment>
                ))
              : 'W tym kanale nie ma żadnych artykułów...'}
        </Box>
      ))}
    </Section>
  );
};

const NewspaperEnding = (props) => {
  const { data } = useBackend<Data>();
  const { wanted_criminal, wanted_body, wanted_photo } = data;

  return (
    <Section>
      {wanted_criminal ? (
        <>
          <Box bold fontSize="15px">
            List gończy
          </Box>
          <Box fontSize="12px">Poszukiwany: {wanted_criminal}</Box>
          <Box>Opis: {wanted_body}</Box>
          {wanted_photo ? (
            <Image src={wanted_photo} width="180px" />
          ) : (
            <Box>Zdjęcie: brak</Box>
          )}
        </>
      ) : (
        'Poza kilkoma nudnymi ogłoszeniami drobnymi na tej stronie nie ma nic...'
      )}
    </Section>
  );
};
