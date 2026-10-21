import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Stack } from 'tgui-core/components';

import type { LibraryConsoleData } from '../types';

// AQUILA: nasza drukarka nie ma listy plakatów ani podglądu okładki Biblii z tg,
// drukuje Biblię, Kodeks prawa kosmicznego i losowy oficjalny plakat.
export function Print(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { bible_name, deity, religion, printer_ready } = data;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <NoticeBox info={!!printer_ready}>
          {printer_ready
            ? 'Uniwersalny moduł drukujący NTGanda(tm) gotowy do pracy.'
            : 'Drukarka jest obecnie niedostępna, poczekaj chwilę.'}
        </NoticeBox>
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical fill justify="center">
          <Stack.Item
            textAlign="center"
            fontSize="25px"
            italic
            bold
            textColor="#0b94c4"
          >
            {bible_name}
          </Stack.Item>
          <Stack.Item textAlign="center" fontSize="22px" textColor="purple">
            W imię {deity}
          </Stack.Item>
          <Stack.Item textAlign="center" fontSize="22px" textColor="purple">
            Dla dobra {religion}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack justify="space-between">
          <Stack.Item grow>
            <Button
              fluid
              icon="scroll"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              disabled={!printer_ready}
              tooltip="Losowy oficjalny plakat Nanotrasen"
              onClick={() => act('print_poster')}
            >
              Plakat
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="gavel"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              disabled={!printer_ready}
              onClick={() => act('print_spacelaw')}
            >
              Kodeks
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="cross"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              disabled={!printer_ready}
              onClick={() => act('print_bible')}
            >
              Biblia
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}
