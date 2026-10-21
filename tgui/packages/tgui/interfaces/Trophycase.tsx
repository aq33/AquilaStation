import {
  Box,
  Button,
  Dimmer,
  Icon,
  Image,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  has_showpiece: BooleanLike;
  historian_mode: BooleanLike;
  holographic_showpiece: BooleanLike;
  max_length: number;
  showpiece_name?: string;
  showpiece_description?: string | null;
  showpiece_icon?: string;
};

export const Trophycase = (props) => {
  return (
    <Window width={300} height={380}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <ShowpieceName />
          </Stack.Item>
          <Stack.Item>
            <ShowpieceImage />
          </Stack.Item>
          <Stack.Item grow>
            <ShowpieceDescription />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item>
            <HistorianPanel />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HistorianPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_showpiece,
    historian_mode,
    holographic_showpiece,
    showpiece_description,
  } = data;

  return (
    <Section align="left">
      {!historian_mode && (
        <Button icon="key" onClick={() => act('insert_key')}>
          Włóż klucz kuratora
        </Button>
      )}
      {!!historian_mode && (
        <div>
          <Button icon="times" onClick={() => act('lock')}>
            Zamknij gablotę
          </Button>
          <Button
            icon="pencil"
            disabled={!has_showpiece || holographic_showpiece}
            onClick={() => act('change_message')}
          >
            Edytuj opis
          </Button>
        </div>
      )}
      {!!historian_mode && !!holographic_showpiece && (
        <Box>
          W gablocie jest już holograficzne trofeum. Włóż nowe trofeum, aby
          rozpocząć nowy zapis.
        </Box>
      )}
      {!!historian_mode && !has_showpiece && <Box>Brak trofeów.</Box>}
      {!!historian_mode &&
        !!has_showpiece &&
        !holographic_showpiece &&
        !!showpiece_description && (
          <Box>
            Zapis rozpoczęty. Dane trofeum zostaną zachowane na kolejne zmiany.
          </Box>
        )}
      {!!historian_mode &&
        !!has_showpiece &&
        !holographic_showpiece &&
        !showpiece_description && (
          <Box>Wykryto nowe trofeum. Dodaj opis, aby je zarchiwizować.</Box>
        )}
    </Section>
  );
};

const ShowpieceDescription = (props) => {
  const { data } = useBackend<Data>();
  const { has_showpiece, holographic_showpiece, showpiece_description } = data;
  return (
    <Section fill align="center">
      {!has_showpiece && (
        <Box className="Trophycase-description">
          <b>Ta gablota jest pusta. Historia czeka na twój wkład!</b>
        </Box>
      )}
      {!!holographic_showpiece && (
        <b>{decodeHtmlEntities(showpiece_description || '')}</b>
      )}
      {!holographic_showpiece && !!has_showpiece && (
        <Box className="Trophycase-description">
          {showpiece_description
            ? decodeHtmlEntities(showpiece_description)
            : 'Ta wystawa jest w przygotowaniu. Zdobądź klucz kuratora, aby dokończyć swój wkład!'}
        </Box>
      )}
    </Section>
  );
};

const ShowpieceImage = (props) => {
  const { data } = useBackend<Data>();
  const { showpiece_icon } = data;
  return showpiece_icon ? (
    <Section align="center">
      <Image
        m={1}
        src={`data:image/jpeg;base64,${showpiece_icon}`}
        height="96px"
        width="96px"
      />
    </Section>
  ) : (
    <Section align="center">
      <Box height="96px" width="96px">
        <Dimmer fontSize="32px">
          <Icon name="landmark" />
        </Dimmer>
      </Box>
    </Section>
  );
};

const ShowpieceName = (props) => {
  const { data } = useBackend<Data>();
  const { showpiece_name } = data;
  return (
    <Section align="center">
      <b>
        {showpiece_name
          ? decodeHtmlEntities(showpiece_name)
          : 'W przygotowaniu.'}
      </b>
    </Section>
  );
};
