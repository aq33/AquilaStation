import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  admin_mode: BooleanLike;
  creator_key: string;
  creator_name: string;
  has_liked: BooleanLike;
  has_disliked: BooleanLike;
  hidden_message: string;
  is_creator: BooleanLike;
  num_likes: number;
  num_dislikes: number;
  realdate: string;
};

export const EngravedMessage = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    admin_mode,
    creator_key,
    creator_name,
    has_liked,
    has_disliked,
    hidden_message,
    is_creator,
    num_likes,
    num_dislikes,
    realdate,
  } = data;
  return (
    <Window width={600} height={300}>
      <Window.Content scrollable>
        <Section>
          <Box bold textAlign="center" fontSize="20px" mb={2}>
            {decodeHtmlEntities(hidden_message)}
          </Box>
          <Stack>
            <Stack.Item grow={1.05}>
              <Button
                fluid
                icon="arrow-up"
                tooltip="Podoba mi się"
                disabled={is_creator}
                selected={has_liked}
                textAlign="center"
                fontSize="16px"
                lineHeight="24px"
                onClick={() => act('like')}
              >
                {` ${num_likes}`}
              </Button>
            </Stack.Item>
            <Stack.Item grow={1}>
              <Button
                fluid
                icon="circle"
                tooltip="Bez oceny"
                disabled={is_creator}
                selected={!has_disliked && !has_liked}
                textAlign="center"
                fontSize="16px"
                lineHeight="24px"
                onClick={() => act('neutral')}
              />
            </Stack.Item>
            <Stack.Item grow={1.05}>
              <Button
                fluid
                icon="arrow-down"
                tooltip="Nie podoba mi się"
                disabled={is_creator}
                selected={has_disliked}
                textAlign="center"
                fontSize="16px"
                lineHeight="24px"
                onClick={() => act('dislike')}
              >
                {` ${num_dislikes}`}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Wyryto">{realdate}</LabeledList.Item>
          </LabeledList>
        </Section>
        {!!admin_mode && (
          <Section
            title="Panel admina"
            buttons={
              <Button icon="times" color="bad" onClick={() => act('delete')}>
                Usuń
              </Button>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Ckey autora">
                {creator_key}
              </LabeledList.Item>
              <LabeledList.Item label="Postać autora">
                {creator_name}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
