import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { sanitizeText } from 'tgui/sanitize';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { CATEGORY_NAMES, type LibraryConsoleData } from '../types';
import { useLibraryContext } from '../useLibraryContext';

export function Upload(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const {
    active_newscaster_cooldown,
    cache_author,
    cache_content,
    cache_title,
    can_db_request,
    cooldown_string,
    has_cache,
    has_scanner,
  } = data;

  const { uploadToDBState } = useLibraryContext();
  const [uploadToDB, setUploadToDB] = uploadToDBState;

  if (!has_scanner) {
    return (
      <NoticeBox>
        W zasięgu sieci bezprzewodowej nie znaleziono skanera. Zbuduj go, aby
        kontynuować.
      </NoticeBox>
    );
  }

  if (!has_cache) {
    return <NoticeBox>Zeskanuj książkę, aby ją wgrać.</NoticeBox>;
  }

  const contentHtml = {
    __html: sanitizeText(cache_content),
  };

  return (
    <>
      <Stack vertical height="100%">
        <Stack.Item>
          <Box fontSize="20px" textAlign="center" pt="6px">
            Pamięć skanera
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack vertical height="100%">
            <Stack.Item>
              <Stack justify="center">
                <Stack.Item>
                  <Box pt={1} fontSize={'20px'}>
                    Tytuł:
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box pt={1} fontSize="20px" width={22} color="label">
                    {cache_title}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box pt={1} fontSize="20px">
                    Autor:
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    fontSize="20px"
                    value={cache_author}
                    placeholder={cache_author || 'Autor'}
                    mt={0.5}
                    onBlur={(value) =>
                      act('set_cache_author', {
                        author: value,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Section
                fill
                scrollable
                preserveWhitespace
                fontSize="15px"
                title="Treść:"
              >
                <Box dangerouslySetInnerHTML={contentHtml} />
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                disabled={!active_newscaster_cooldown}
                fluid
                tooltip={
                  active_newscaster_cooldown
                    ? 'Opublikuj książkę na kanale stacyjnego serwisu informacyjnego.'
                    : `Poczekaj ${cooldown_string}, zanim znów wyślesz książkę do serwisu informacyjnego!`
                }
                tooltipPosition="top"
                icon="newspaper"
                fontSize="30px"
                lineHeight={2}
                textAlign="center"
                onClick={() => act('news_post')}
              >
                Serwis
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                disabled={!can_db_request}
                fluid
                icon="server"
                fontSize="30px"
                lineHeight={2}
                textAlign="center"
                onClick={() => setUploadToDB(true)}
              >
                Archiwum
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      {!!uploadToDB && <UploadModal />}
    </>
  );
}

function UploadModal(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { upload_categories = [], default_category, can_db_request } = data;

  const { uploadToDBState } = useLibraryContext();
  const [_uploadToDB, setUploadToDB] = uploadToDBState;

  const [uploadCategory, setUploadCategory] = useState('');

  const display_category = uploadCategory || default_category;

  return (
    <Modal width="650px">
      <Box fontSize="20px" pb={2}>
        Czy na pewno chcesz wgrać ten tytuł do archiwum?
      </Box>
      <LabeledList>
        <LabeledList.Item label="Kategoria">
          <Dropdown
            options={upload_categories.map((value) => ({
              value,
              displayText: CATEGORY_NAMES[value] || value,
            }))}
            selected={display_category}
            displayText={CATEGORY_NAMES[display_category] || display_category}
            onSelected={(value) => setUploadCategory(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Stack justify="center" align="center" pt={2}>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            icon="upload"
            fontSize="18px"
            color="good"
            onClick={() => {
              setUploadToDB(false);
              act('upload', {
                category: display_category,
              });
            }}
            lineHeight={2}
          >
            Wgraj do archiwum
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            fontSize="18px"
            color="bad"
            onClick={() => setUploadToDB(false)}
            lineHeight={2}
          >
            Wróć
          </Button>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
