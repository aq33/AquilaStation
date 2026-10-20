import {
  Box,
  Button,
  Dimmer,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  CONSOLE_MODE_ENZYMES,
  CONSOLE_MODE_SEQUENCER,
  CONSOLE_MODE_STORAGE,
  type Data,
  STORAGE_MODE_CONSOLE,
} from './constants';
import { DnaConsoleEnzymes } from './DnaConsoleEnzymes';
import { DnaConsoleSequencer } from './DnaConsoleSequencer';
import { DnaConsoleStorage } from './DnaConsoleStorage';
import { DnaScanner } from './DnaScanner';

export const DnaConsole = (props) => {
  const { data } = useBackend<Data>();
  const { isPulsingRads, radPulseSeconds } = data;
  const { consoleMode } = data.view;

  return (
    <Window title="Konsola DNA" width={550} height={710}>
      {!!isPulsingRads && (
        <Dimmer fontSize="14px" textAlign="center">
          <Icon mr={1} name="spinner" spin />
          Trwa impuls promieniowania...
          <Box mt={1} />
          {radPulseSeconds}s
        </Dimmer>
      )}
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <DnaScanner />
          </Stack.Item>
          <Stack.Item>
            <DnaConsoleCommands />
          </Stack.Item>
          <Stack.Item grow>
            {consoleMode === CONSOLE_MODE_STORAGE && <DnaConsoleStorage />}
            {consoleMode === CONSOLE_MODE_SEQUENCER && <DnaConsoleSequencer />}
            {consoleMode === CONSOLE_MODE_ENZYMES && <DnaConsoleEnzymes />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DnaConsoleCommands = (props) => {
  const { data, act } = useBackend<Data>();
  const { hasDisk, isInjectorReady, injectorSeconds } = data;
  const { consoleMode } = data.view;

  return (
    <Section
      title="Konsola DNA"
      buttons={
        !isInjectorReady && (
          <Box lineHeight="20px" color="label">
            Iniektor się ładuje ({injectorSeconds}s)
          </Box>
        )
      }
    >
      <LabeledList>
        <LabeledList.Item label="Tryb">
          <Button
            selected={consoleMode === CONSOLE_MODE_STORAGE}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_STORAGE,
              })
            }
          >
            Magazyn
          </Button>
          <Button
            disabled={!data.isViableSubject}
            selected={consoleMode === CONSOLE_MODE_SEQUENCER}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_SEQUENCER,
              })
            }
          >
            Sekwenser
          </Button>
          <Button
            selected={consoleMode === CONSOLE_MODE_ENZYMES}
            onClick={() =>
              act('set_view', {
                consoleMode: CONSOLE_MODE_ENZYMES,
              })
            }
          >
            Enzymy
          </Button>
        </LabeledList.Item>
        {!!hasDisk && (
          <LabeledList.Item label="Dysk">
            <Button
              icon="eject"
              onClick={() => {
                act('eject_disk');
                act('set_view', {
                  storageMode: STORAGE_MODE_CONSOLE,
                });
              }}
            >
              Wysuń
            </Button>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
