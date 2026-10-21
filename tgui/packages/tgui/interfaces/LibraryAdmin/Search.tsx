import {
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { CATEGORY_NAMES } from '../LibraryConsole/types';
import { useModifyState } from './hooks';
import { type Book, type LibraryAdminData, ModifyTypes } from './types';

type AdminBook = Book & {
  author_ckey: string;
  deleted: BooleanLike;
};

export function SearchAndDisplay(props) {
  const { act, data } = useBackend<LibraryAdminData>();

  const { modifyMethodState, modifyTargetState } = useModifyState();
  const [, setModifyMethod] = modifyMethodState;
  const [, setModifyTarget] = modifyTargetState;

  const {
    can_db_request,
    search_categories = [],
    book_id,
    title,
    category,
    author,
    author_ckey,
    pages = [],
    params_changed,
    show_deleted,
  } = data;

  const books = pages as AdminBook[];

  return (
    <Section>
      <Stack justify="space-between">
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Input
                value={book_id ? String(book_id) : ''}
                placeholder="ID"
                width="70px"
                onBlur={(value) =>
                  act('set_search_id', {
                    id: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Dropdown
                width="120px"
                options={search_categories.map((value) => ({
                  value,
                  displayText: CATEGORY_NAMES[value] || value,
                }))}
                selected={category}
                displayText={CATEGORY_NAMES[category] || category}
                onSelected={(value) =>
                  act('set_search_category', {
                    category: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={title}
                placeholder="Tytuł"
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_title', {
                    title: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={author}
                placeholder="Autor"
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_author', {
                    author: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={author_ckey}
                placeholder="Ckey"
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_ckey', {
                    ckey: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button
                disabled={!can_db_request}
                textAlign="right"
                onClick={() => act('refresh')}
                color={params_changed ? 'good' : ''}
                icon="rotate-right"
              >
                Odśwież
              </Button>
              <Button
                disabled={!can_db_request}
                textAlign="right"
                onClick={() => act('clear_data')}
                color="bad"
                icon="fire"
              >
                Wyczyść
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                textAlign="right"
                onClick={() => act('toggle_deleted')}
                color={show_deleted ? 'purple' : 'green'}
                icon={show_deleted ? 'trash' : 'mountain-sun'}
                tooltip="Czy pokazywać też ukryte (usunięte) książki"
              >
                {show_deleted ? 'Wszystkie' : 'Bez usuniętych'}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Table>
        <Table.Row>
          <Table.Cell fontSize={1.5}>#</Table.Cell>
          <Table.Cell fontSize={1.5}>Kategoria</Table.Cell>
          <Table.Cell fontSize={1.5}>Tytuł</Table.Cell>
          <Table.Cell fontSize={1.5}>Autor</Table.Cell>
          <Table.Cell fontSize={1.5}>Ckey</Table.Cell>
          <Table.Cell fontSize={1.5}>Usuń/przywróć</Table.Cell>
        </Table.Row>
        {books.map((book) => (
          <Table.Row key={book.id}>
            <Table.Cell>
              <Button
                onClick={() =>
                  act('view_book', {
                    book_id: book.id,
                  })
                }
                icon="book-reader"
                tooltip="Podgląd treści"
              >
                {book.id}
              </Button>
            </Table.Cell>
            <Table.Cell>
              {CATEGORY_NAMES[book.category] || book.category}
            </Table.Cell>
            <Table.Cell>{book.title}</Table.Cell>
            <Table.Cell>{book.author}</Table.Cell>
            <Table.Cell>{book.author_ckey}</Table.Cell>
            <Table.Cell>
              {book.deleted ? (
                <Button
                  onClick={() => {
                    setModifyTarget(book.id);
                    setModifyMethod(ModifyTypes.Restore);
                  }}
                  icon="undo"
                  color="blue"
                >
                  Przywróć
                </Button>
              ) : (
                <Button
                  onClick={() => {
                    setModifyTarget(book.id);
                    setModifyMethod(ModifyTypes.Delete);
                  }}
                  icon="hammer"
                  color="violet"
                >
                  Usuń
                </Button>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}
