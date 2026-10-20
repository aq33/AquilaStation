import type { ReactNode } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  type Data,
  type Makeup,
  RADIATION_DURATION_MAX,
  RADIATION_STRENGTH_MAX,
} from './constants';
import { GeneticMakeupInfo } from './GeneticMakeupInfo';

// Typy profilu obsługiwane przez nasz DM (bez 'uf' z tg).
const MAKEUP_TYPES = [
  { type: 'ue', label: 'Enzymy' },
  { type: 'ui', label: 'Tożsamość' },
  { type: 'mixed', label: 'Pełny profil' },
];

type BufferInfoProps = {
  index: number;
  makeup: Makeup | undefined;
};

const GeneticMakeupBufferInfo = (props: BufferInfoProps) => {
  const { index, makeup } = props;
  const { act, data } = useBackend<Data>();
  const { isViableSubject, hasDisk, diskReadOnly, isInjectorReady } = data;
  // Type of the action for applying makeup
  const ACTION_MAKEUP_APPLY = isViableSubject ? 'makeup_apply' : 'makeup_delay';
  if (!makeup) {
    return <Box color="average">Brak zapisanych danych obiektu.</Box>;
  }
  return (
    <>
      <GeneticMakeupInfo makeup={makeup} />
      <Divider />
      <Box bold color="label" mb={1}>
        Działania na profilu
      </Box>
      <LabeledList>
        {MAKEUP_TYPES.map(({ type, label }) => (
          <LabeledList.Item key={type} label={label}>
            <Button
              icon="syringe"
              disabled={!isInjectorReady}
              onClick={() =>
                act('makeup_injector', {
                  index,
                  type,
                })
              }
            >
              Drukuj
            </Button>
            <Button
              icon="exchange-alt"
              onClick={() =>
                act(ACTION_MAKEUP_APPLY, {
                  index,
                  type,
                })
              }
            >
              Przenieś
              {!isViableSubject && ' (z opóźnieniem)'}
            </Button>
          </LabeledList.Item>
        ))}
        <LabeledList.Item>
          <Button
            icon="save"
            disabled={!hasDisk || diskReadOnly}
            onClick={() =>
              act('save_makeup_disk', {
                index,
              })
            }
          >
            Eksportuj na dysk
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </>
  );
};

const GeneticMakeupBuffers = (props) => {
  const { data, act } = useBackend<Data>();
  const {
    diskHasMakeup,
    hasDisk,
    isViableSubject,
    makeupCapacity = 3,
    makeupStorage = {},
  } = data;
  const elements: ReactNode[] = [];
  for (let i = 1; i <= makeupCapacity; i++) {
    const makeup = makeupStorage[i];
    const element = (
      <Collapsible
        key={i}
        title={makeup ? makeup.label || makeup.name : `Miejsce ${i}`}
        buttons={
          <>
            {!!(hasDisk && diskHasMakeup) && (
              <Button
                mr={1}
                disabled={!hasDisk || !diskHasMakeup}
                onClick={() =>
                  act('load_makeup_disk', {
                    index: i,
                  })
                }
              >
                Importuj z dysku
              </Button>
            )}
            <Button
              disabled={!isViableSubject}
              onClick={() =>
                act('save_makeup_console', {
                  index: i,
                })
              }
            >
              Zapisz
            </Button>
            <Button
              ml={1}
              icon="times"
              color="red"
              disabled={!makeup}
              tooltip="Usuń"
              onClick={() =>
                act('del_makeup_console', {
                  index: i,
                })
              }
            />
          </>
        }
      >
        <GeneticMakeupBufferInfo index={i} makeup={makeup} />
      </Collapsible>
    );
    elements.push(element);
  }
  return <Section title="Bufory profilu genetycznego">{elements}</Section>;
};

const RadiationEmitterProbs = (props) => {
  const { data } = useBackend<Data>();
  const { stdDevAcc, stdDevStr } = data;
  return (
    <Section title="Prawdopodobieństwo" minHeight="100%">
      <LabeledList>
        <LabeledList.Item label="Celność" textAlign="right">
          {stdDevAcc}
        </LabeledList.Item>
        <LabeledList.Item label={`P(±${stdDevStr})`} textAlign="right">
          68 %
        </LabeledList.Item>
        <LabeledList.Item label={`P(±${stdDevStr * 2})`} textAlign="right">
          95 %
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const RadiationEmitterPulseBoard = (props) => {
  const { data, act } = useBackend<Data>();
  const { subjectUNI = '' } = data;
  // Build blocks of buttons of unique enzymes
  const blocks: ReactNode[] = [];
  let buffer: ReactNode[] = [];
  for (let i = 0; i < subjectUNI.length; i++) {
    const char = subjectUNI.charAt(i);
    // Push a button into the buffer
    const button = (
      <Button
        fluid
        key={i}
        textAlign="center"
        onClick={() =>
          act('makeup_pulse', {
            index: i + 1,
          })
        }
      >
        {char}
      </Button>
    );
    buffer.push(button);
    // Create a block from the current buffer
    if (buffer.length >= 3) {
      const block = (
        <Box key={i} inline width="22px" mx="1px">
          {buffer}
        </Box>
      );
      blocks.push(block);
      // Clear the buffer
      buffer = [];
    }
  }
  return (
    <Section title="Unikalne enzymy" minHeight="100%" position="relative">
      {(blocks.length && <Box mx="-1px">{blocks}</Box>) || (
        <Box color="label">Brak danych.</Box>
      )}
    </Section>
  );
};

const RadiationEmitterSettings = (props) => {
  const { data, act } = useBackend<Data>();
  const { radStrength, radDuration } = data;
  return (
    <Section title="Emiter promieniowania" minHeight="100%">
      <LabeledList>
        <LabeledList.Item label="Moc">
          <NumberInput
            animated
            tickWhileDragging
            width="32px"
            step={1}
            stepPixelSize={10}
            value={radStrength}
            minValue={1}
            maxValue={RADIATION_STRENGTH_MAX}
            onChange={(value) =>
              act('set_pulse_strength', {
                val: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Czas impulsu">
          <NumberInput
            animated
            tickWhileDragging
            width="32px"
            step={1}
            stepPixelSize={10}
            value={radDuration}
            minValue={1}
            maxValue={RADIATION_DURATION_MAX}
            onChange={(value) =>
              act('set_pulse_duration', {
                val: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const DnaConsoleEnzymes = (props) => {
  const { data } = useBackend<Data>();
  const { isScannerConnected } = data;
  if (!isScannerConnected) {
    return <Section color="bad">Skaner DNA nie jest podłączony.</Section>;
  }
  return (
    <>
      <Stack mb={1}>
        <Stack.Item width="155px">
          <RadiationEmitterSettings />
        </Stack.Item>
        <Stack.Item width="140px">
          <RadiationEmitterProbs />
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <RadiationEmitterPulseBoard />
        </Stack.Item>
      </Stack>
      <GeneticMakeupBuffers />
    </>
  );
};
