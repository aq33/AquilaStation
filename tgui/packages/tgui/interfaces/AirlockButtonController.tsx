import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  interior_door: string;
  exterior_door: string;
  interior_door_closed: BooleanLike;
  exterior_door_closed: BooleanLike;
  busy: BooleanLike;
};

export const AirlockButtonController = (props) => {
  const { data } = useBackend<Data>();
  const { interior_door, exterior_door } = data;
  return (
    <Window width={500} height={130}>
      <Window.Content>
        <Section title="Kontroler śluzy" textAlign="center">
          {!interior_door && !exterior_door ? (
            <NoticeBox danger>Nie wykryto drzwi</NoticeBox>
          ) : (
            <Stack>
              {interior_door && (
                <Stack.Item grow textAlign="center">
                  <RetrieveButton airlockType={interior_door} />
                </Stack.Item>
              )}
              {exterior_door && (
                <Stack.Item grow textAlign="center">
                  <RetrieveButton airlockType={exterior_door} />
                </Stack.Item>
              )}
            </Stack>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RetrieveButton = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    interior_door,
    exterior_door,
    interior_door_closed,
    exterior_door_closed,
    busy,
  } = data;
  const { airlockType } = props;
  const isInterior = airlockType === interior_door;
  const our_door_closed = isInterior
    ? interior_door_closed
    : exterior_door_closed;
  const opposite_door_closed = isInterior
    ? exterior_door_closed
    : interior_door_closed;
  const opposite_door = isInterior ? exterior_door : interior_door;
  const doorName = isInterior ? 'wewnętrzne drzwi' : 'zewnętrzne drzwi';
  const cycleName = isInterior ? 'wewnętrznych drzwi' : 'zewnętrznych drzwi';

  return (
    <Button
      mt={2}
      icon={our_door_closed ? 'lock-open' : 'lock'}
      color="green"
      fontSize={1.5}
      textAlign="center"
      lineHeight="1.5"
      disabled={busy}
      onClick={() => {
        if (!our_door_closed) {
          act('close', {
            requested_door: airlockType,
          });
        } else {
          act('open', {
            requested_door: airlockType,
          });
        }
      }}
    >
      {!our_door_closed
        ? `Zamknij ${doorName}`
        : !opposite_door_closed && opposite_door
          ? `Cykl do ${cycleName}`
          : `Otwórz ${doorName}`}
    </Button>
  );
};
