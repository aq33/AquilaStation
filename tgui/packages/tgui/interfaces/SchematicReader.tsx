// AQUILA: czytnik schematów mechanika (kolejka skanów i baza schematów sieci badań)
import {
  Box,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type KnownSchematic = {
  name: string;
  tier: number;
  illegal: BooleanLike;
};

type Data = {
  current: string | null;
  progress: number;
  queue: string[];
  known: KnownSchematic[];
};

export const SchematicReader = (props) => {
  const { data } = useBackend<Data>();
  const { current, progress, queue, known } = data;

  return (
    <Window width={420} height={520} title="Czytnik schematów">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Odczyt">
              {current ? (
                <>
                  <Box mb={1}>{toTitleCase(current)}</Box>
                  <ProgressBar value={progress} />
                </>
              ) : (
                <NoticeBox info>
                  Wgraj skany, klikając czytnik skanerem maszyn.
                </NoticeBox>
              )}
              {queue.length > 0 && (
                <Box mt={1} color="label">
                  W kolejce: {queue.map((name) => toTitleCase(name)).join(', ')}
                </Box>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title={`Baza schematów (${known.length})`}>
              {known.length === 0 ? (
                <NoticeBox>Baza jest pusta.</NoticeBox>
              ) : (
                <Table>
                  {known.map((schematic) => (
                    <Table.Row
                      key={`${schematic.name}-${schematic.tier}`}
                      className="candystripe"
                    >
                      <Table.Cell color={schematic.illegal ? 'bad' : undefined}>
                        {toTitleCase(schematic.name)}
                      </Table.Cell>
                      <Table.Cell collapsing>tier {schematic.tier}</Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
