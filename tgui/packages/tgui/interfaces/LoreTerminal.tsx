// AQUILA - terminal informacyjny Seegson z NSV13 (nsv13/code/game/machinery/lore_terminal.dm).
// Zastępuje dawne okna HTML (lista plików + plik wypisywany jak na maszynie do
// pisania). Znaki specjalne w treści: ` = nowa linia, ~ = linia pozioma.
import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EntryInfo = {
  name: string;
  ref: string;
};

type Entry = EntryInfo & {
  title: string | null;
  classified: string;
  content: string;
};

type Data = {
  entries: EntryInfo[];
  entry?: Entry;
};

/** Ile znaków dopisywać co takt (takt = 10 ms, jak w starym oknie) */
const CHARS_PER_TICK = 1;
const TICK_MS = 10;

export const LoreTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { entries = [], entry } = data;

  return (
    <Window width={680} height={560} theme="hackerman">
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="30%">
            <Section fill scrollable title="C:/entries/local">
              {entries.length === 0 ? (
                <Box color="label">Brak plików.</Box>
              ) : (
                entries.map((file) => (
                  <Button
                    key={file.ref}
                    fluid
                    ellipsis
                    icon="file-alt"
                    selected={entry?.ref === file.ref}
                    onClick={() => act('selectitem', { ref: file.ref })}
                  >
                    {file.name}
                  </Button>
                ))
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {entry ? (
              <EntryView entry={entry} />
            ) : (
              <Section fill>
                <NoticeBox>Wybierz plik z listy.</NoticeBox>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const EntryView = (props: { entry: Entry }) => {
  const { act } = useBackend<Data>();
  const { entry } = props;
  const text = entry.content || '';
  const [shown, setShown] = useState(0);

  useEffect(() => {
    setShown(0);
    const timer = setInterval(() => {
      setShown((current) => {
        if (current >= text.length) {
          clearInterval(timer);
          return current;
        }
        return current + CHARS_PER_TICK;
      });
    }, TICK_MS);
    return () => clearInterval(timer);
  }, [entry.ref, text]);

  const finished = shown >= text.length;
  // Zamiana znaków specjalnych: ` to nowa linia, ~ to linia pozioma
  const blocks = text.slice(0, shown).replace(/`/g, '\n').split('~');

  return (
    <Section
      fill
      scrollable
      title={`ACCESS FILE: C:/entries/local/${entry.name}`}
      buttons={
        <>
          {!finished && (
            <Button icon="forward" onClick={() => setShown(text.length)}>
              Pomiń
            </Button>
          )}
          <Button icon="times" onClick={() => act('close_entry')} />
        </>
      }
    >
      <Box italic>Klasyfikacja: {entry.classified}</Box>
      <Box fontSize={0.8} color="label">
        - © Seegson systems inc, 2257
      </Box>
      <Divider />
      {!!entry.title && (
        <Box bold fontSize={1.4} mb={1}>
          {entry.title}
        </Box>
      )}
      {blocks.map((block, index) => (
        <Box key={index}>
          {index > 0 && <Divider />}
          <Box
            fontFamily="Lucida Console, monospace"
            style={{ whiteSpace: 'pre-wrap' }}
          >
            {block}
            {!finished && index === blocks.length - 1 && '█'}
          </Box>
        </Box>
      ))}
    </Section>
  );
};
