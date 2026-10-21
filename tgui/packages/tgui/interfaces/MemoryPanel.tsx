import { useState } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: w tg panel pokazuje "wspomnienia" z oceną jakości (system memory
// datumów, którego nie mamy). U nas to okno werbu "Notes": notatki postaci,
// wspomnienia antagonisty, cele i cele opcjonalne oraz dodawanie notatek.

type Objective = {
  text: string;
  optional: BooleanLike;
  accomplices: string[];
};

type Data = {
  has_mind: BooleanLike;
  name: string;
  notes: string | null;
  antag_memories: string[];
  objectives: Objective[];
  crew_objectives: string[];
};

const HtmlBlock = (props: { html: string }) => (
  <div
    style={{ wordBreak: 'break-word' }}
    // Notatki i wspomnienia antagonisty to HTML z DM (jak w starym oknie).
    // eslint-disable-next-line react/no-danger
    dangerouslySetInnerHTML={{ __html: props.html }}
  />
);

export const MemoryPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_mind,
    name,
    notes,
    antag_memories = [],
    objectives = [],
    crew_objectives = [],
  } = data;
  const [newNote, setNewNote] = useState('');

  const isEmpty =
    !notes &&
    !antag_memories.length &&
    !objectives.length &&
    !crew_objectives.length;

  return (
    <Window title="Notatki" width={450} height={550}>
      <Window.Content scrollable>
        {!has_mind ? (
          <NoticeBox>
            Nie masz umysłu, więc nie możesz przeglądać notatek.
          </NoticeBox>
        ) : (
          <>
            <Section
              title={`Wspomnienia: ${name}`}
              buttons={
                <Button
                  color="transparent"
                  icon="info"
                  tooltip="Tu trafiają twoje notatki, ważne informacje (np. kody
                    i hasła) oraz cele. Notatki możesz dopisywać poniżej."
                  tooltipPosition="bottom-start"
                />
              }
            >
              {isEmpty && <Box color="label">Nie masz jeszcze notatek.</Box>}
              {!!notes && <HtmlBlock html={notes} />}
              {antag_memories.map((memory, index) => (
                <Box key={index} mt={1}>
                  <HtmlBlock html={memory} />
                </Box>
              ))}
            </Section>
            {objectives.length > 0 && (
              <Section title="Cele">
                <Stack vertical>
                  {objectives.map((objective, index) => (
                    <Stack.Item key={index}>
                      <Box>
                        <Box inline bold>
                          Cel nr {index + 1}:
                        </Box>{' '}
                        {objective.text}
                      </Box>
                      {!!objective.optional && (
                        <Box color="label" italic>
                          Ten cel jest opcjonalny i nie jest sprawdzany, więc po
                          prostu baw się dobrze!
                        </Box>
                      )}
                      {objective.accomplices.length > 0 && (
                        <Box color="label">
                          Wspólnicy: {objective.accomplices.join(', ')}
                        </Box>
                      )}
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            )}
            {crew_objectives.length > 0 && (
              <Section title="Cele opcjonalne">
                <Stack vertical>
                  {crew_objectives.map((objective, index) => (
                    <Stack.Item key={index}>{objective}</Stack.Item>
                  ))}
                </Stack>
              </Section>
            )}
            <Section
              title="Nowa notatka"
              buttons={
                <Button
                  icon="plus"
                  disabled={!newNote.trim()}
                  onClick={() => {
                    act('add_note', { text: newNote });
                    setNewNote('');
                  }}
                >
                  Dodaj
                </Button>
              }
            >
              <TextArea
                fluid
                height="5rem"
                value={newNote}
                placeholder="Zapisz coś, o czym chcesz pamiętać..."
                onChange={setNewNote}
              />
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
