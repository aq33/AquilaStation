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

// AQUILA: w tg panel pokazuje tylko wspomnienia (memory datumy) z oceną
// wartości historii. U nas to okno werbu "Notes": notatki postaci, wspomnienia
// z tg, wspomnienia antagonisty, cele i cele opcjonalne oraz dodawanie notatek.

type Objective = {
  text: string;
  optional: BooleanLike;
  accomplices: string[];
};

type Memory = {
  name: string;
  quality: number;
};

type Data = {
  has_mind: BooleanLike;
  name: string;
  notes: string | null;
  memories: Memory[];
  antag_memories: string[];
  objectives: Objective[];
  crew_objectives: string[];
};

// Wartości STORY_VALUE_* z aquila/code/__DEFINES/memory.dm
const MEMORY_QUALITIES: Record<
  number,
  { icon: string; background?: string; tooltip: string }
> = {
  [-1]: {
    icon: 'key',
    tooltip:
      'To ważne wspomnienie. Zawiera informacje, które warto czasem sprawdzić.',
  },
  0: {
    icon: 'poop',
    tooltip:
      'To wspomnienie w ogóle nie jest ciekawe. Nie wyjdzie z niego dobra sztuka i raczej nie przetrwa do przyszłych pokoleń.',
  },
  1: {
    icon: 'star',
    tooltip:
      'To dość nijakie wspomnienie. Wyszłaby z niego przeciętna sztuka i raczej nie przetrwa do przyszłych pokoleń.',
  },
  2: {
    icon: 'star',
    background:
      'linear-gradient(to right, #964B30, #D68B60, #B66B30, #D68B60, #964B30)',
    tooltip:
      'To niezbyt ciekawe wspomnienie. Może wyjść z niego niezła historia, ale nie licz na to.',
  },
  3: {
    icon: 'star',
    background:
      'linear-gradient(to right, #636363, #a3a3a3, #6e6e6e, #a3a3a3, #636363)',
    tooltip:
      'To całkiem dobre wspomnienie! Da się z niego opowiedzieć niezłą historię i może nawet wrócić w przyszłych pokoleniach.',
  },
  4: {
    icon: 'star',
    background:
      'linear-gradient(to right, #AA771C, #BCB68A, #B38728, #BCB68A, #AA771C)',
    tooltip:
      'To świetne wspomnienie! Wyjdzie z niego wspaniała historia, która ma spore szanse przetrwać do przyszłych pokoleń!',
  },
  5: {
    icon: 'crown',
    background:
      'linear-gradient(to right, #56A5B3, #75D4E2, #56A5B3, #75D4E2, #56A5B3)',
    tooltip:
      'To wspomnienie godne legend! Wyjdzie z niego legendarna sztuka, która pewnie przetrwa do przyszłych pokoleń.',
  },
};

const MemoryQuality = (props: { quality: number }) => {
  const quality = MEMORY_QUALITIES[props.quality];
  if (!quality) {
    return (
      <Button
        icon="question"
        color="transparent"
        tooltipPosition="right"
        tooltip="To wspomnienie nie ma oceny. To błąd w grze, zgłoś go!"
      />
    );
  }
  return (
    <Button
      icon={quality.icon}
      color="transparent"
      style={quality.background ? { background: quality.background } : {}}
      tooltipPosition="right"
      tooltip={quality.tooltip}
    />
  );
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
    memories = [],
    antag_memories = [],
    objectives = [],
    crew_objectives = [],
  } = data;
  const [newNote, setNewNote] = useState('');

  const isEmpty =
    !notes &&
    !memories.length &&
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
            {memories.length > 0 && (
              <Section
                title="Wspomnienia"
                buttons={
                  <Button
                    color="transparent"
                    icon="info"
                    tooltip="Wspomnienia zbierasz, robiąc i widząc niezwykłe rzeczy. Możesz je wyryć dłutem w ścianie albo wytatuować."
                    tooltipPosition="bottom-start"
                  />
                }
              >
                <Stack vertical>
                  {memories.map((memory, index) => (
                    <Stack.Item key={index}>
                      <MemoryQuality quality={memory.quality} /> {memory.name}
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            )}
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
