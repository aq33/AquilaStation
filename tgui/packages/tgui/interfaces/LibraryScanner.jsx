import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const LibraryScanner = (props) => {
  return (
    <Window title="Skaner biblioteczny" width={350} height={150}>
      <BookScanning />
    </Window>
  );
};

const BookScanning = (props) => {
  const { act, data } = useBackend();
  const { has_book, has_cache, book } = data;
  if (!has_book && !has_cache) {
    return <NoticeBox>Włóż książkę do zeskanowania</NoticeBox>;
  }
  return (
    <Stack direction="column" height="100%" justify="flex-end">
      <Stack.Item grow>
        <Section textAlign="center" height="100%" title={book.author}>
          {book.title}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              onClick={() => act('eject')}
              disabled={!has_book}
            >
              Wyjmij książkę
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              onClick={() => act('scan')}
              color="good"
              icon="qrcode"
              disabled={!has_book}
            >
              Skanuj
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="fire"
              onClick={() => act('clear')}
              color="bad"
              disabled={!has_cache}
            >
              Wyczyść pamięć
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
