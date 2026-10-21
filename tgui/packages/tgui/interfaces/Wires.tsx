import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  proper_name: string | null;
  wires: Wire[];
  status: string[];
};

type Wire = {
  color: string;
  cut: BooleanLike;
  attached: BooleanLike;
  wire: string | null;
};

/** Polskie nazwy kolorów przewodów (wartość `color` z DM zostaje bez zmian) */
const COLOR_NAMES: Record<string, string> = {
  blue: 'niebieski',
  brown: 'brązowy',
  crimson: 'karmazynowy',
  cyan: 'cyjanowy',
  gold: 'złoty',
  grey: 'szary',
  green: 'zielony',
  magenta: 'purpurowy',
  orange: 'pomarańczowy',
  pink: 'różowy',
  purple: 'fioletowy',
  red: 'czerwony',
  silver: 'srebrny',
  violet: 'fiołkowy',
  white: 'biały',
  yellow: 'żółty',
};

export const Wires = (props) => {
  const { data } = useBackend<Data>();
  const { proper_name, status = [], wires = [] } = data;
  const dynamicHeight = 150 + wires.length * 30 + (proper_name ? 30 : 0);

  return (
    <Window width={350} height={dynamicHeight}>
      <Window.Content>
        <Stack fill vertical>
          {!!proper_name && (
            <Stack.Item>
              <NoticeBox textAlign="center">
                Konfiguracja przewodów: {proper_name}
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill>
              <WireMap />
            </Section>
          </Stack.Item>
          {!!status.length && (
            <Stack.Item>
              <Section>
                {status.map((status) => (
                  <Box key={status}>{status}</Box>
                ))}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Returns a labeled list of wires */
const WireMap = (props) => {
  const { act, data } = useBackend<Data>();
  const { wires = [] } = data;

  return (
    <LabeledList>
      {wires.map((wire) => (
        <LabeledList.Item
          key={wire.color}
          className="candystripe"
          label={COLOR_NAMES[wire.color] || wire.color}
          labelColor={wire.color.replace(' ', '')}
          color={wire.color.replace(' ', '')}
          buttons={
            <>
              <Button
                onClick={() =>
                  act('cut', {
                    wire: wire.color,
                  })
                }
              >
                {wire.cut ? 'Napraw' : 'Przetnij'}
              </Button>
              <Button
                onClick={() =>
                  act('pulse', {
                    wire: wire.color,
                  })
                }
              >
                Impuls
              </Button>
              <Button
                onClick={() =>
                  act('attach', {
                    wire: wire.color,
                  })
                }
              >
                {wire.attached ? 'Odłącz' : 'Podłącz'}
              </Button>
            </>
          }
        >
          {!!wire.wire && <i>({wire.wire})</i>}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
