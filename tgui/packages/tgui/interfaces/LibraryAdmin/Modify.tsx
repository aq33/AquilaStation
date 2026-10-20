import { useState } from 'react';
import { Button, NoticeBox, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { useModifyState } from './hooks';
import { type LibraryAdminData, ModifyTypes } from './types';

// AQUILA: tg pokazuje tu historię akcji z tabeli library_action, której nie mamy.
// Powód trafia do logów admina (message_admins + log_admin).
export function ModifyPage(props) {
  const { act, data } = useBackend<LibraryAdminData>();

  const { can_db_request } = data;
  const { modifyMethodState, modifyTargetState } = useModifyState();

  const [modifyMethod, setModifyMethod] = modifyMethodState;
  const [modifyTarget, setModifyTarget] = modifyTargetState;
  const [reason, setReason] = useState('');

  const isDelete = modifyMethod === ModifyTypes.Delete;

  return (
    <Window.Content scrollable>
      <NoticeBox>
        Uwaga! W grze nie da się całkowicie usunąć książki.
        <br />
        To, co tu robisz, to tylko przycisk „nie pokazuj tego nikomu”.
        <br />
        Jeśli z jakiegoś powodu trzeba całkowicie wymazać książkę, porozmawiaj z
        administratorem bazy danych.
      </NoticeBox>
      <Stack>
        <Stack.Item fontSize="25px" pb={2}>
          Dlaczego chcesz {isDelete ? 'usunąć' : 'przywrócić'} książkę #
          {modifyTarget}?
        </Stack.Item>
        <Stack.Item fontSize="17px">
          <Button
            onClick={() =>
              act('view_book', {
                book_id: modifyTarget,
              })
            }
            icon="book-reader"
          >
            Podgląd
          </Button>
        </Stack.Item>
      </Stack>
      <TextArea
        fluid
        height="20vh"
        width="100%"
        backgroundColor="black"
        textColor="white"
        placeholder="Powód (trafi do logów admina)"
        value={reason}
        onChange={setReason}
      />
      <Stack justify="center" align="center" pt={1} pb={1}>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            icon="upload"
            fontSize="18px"
            color="good"
            onClick={() => {
              act(isDelete ? 'hide_book' : 'unhide_book', {
                book_id: modifyTarget,
                reason: reason,
              });
              setModifyMethod('');
              setModifyTarget(0);
            }}
            lineHeight={2}
          >
            {isDelete ? 'Usuń' : 'Przywróć'}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            fontSize="18px"
            color="bad"
            onClick={() => {
              setModifyMethod('');
              setModifyTarget(0);
            }}
            lineHeight={2}
          >
            Wróć
          </Button>
        </Stack.Item>
      </Stack>
    </Window.Content>
  );
}
