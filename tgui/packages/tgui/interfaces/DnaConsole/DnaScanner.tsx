import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  type Data,
  SUBJECT_CONCIOUS,
  SUBJECT_DEAD,
  SUBJECT_SOFT_CRIT,
  SUBJECT_TRANSFORMING,
  SUBJECT_UNCONSCIOUS,
} from './constants';

const DnaScannerButtons = (props) => {
  const { data, act } = useBackend<Data>();
  const {
    hasDelayedAction,
    isPulsingRads,
    isScannerConnected,
    isScrambleReady,
    isViableSubject,
    scannerLocked,
    scannerOpen,
    scannerBoltWireCut,
    scrambleSeconds,
  } = data;
  if (!isScannerConnected) {
    return (
      <Button onClick={() => act('connect_scanner')}>Podłącz skaner</Button>
    );
  }
  return (
    <>
      {!!hasDelayedAction && (
        <Button onClick={() => act('cancel_delay')}>
          Anuluj opóźnioną akcję
        </Button>
      )}
      {!!isViableSubject && (
        <Button
          disabled={!isScrambleReady || isPulsingRads}
          onClick={() => act('scramble_dna')}
        >
          Wymieszaj DNA
          {!isScrambleReady && ` (${scrambleSeconds}s)`}
        </Button>
      )}
      <Box inline mr={1} />
      <Button
        icon={scannerLocked ? 'lock' : 'lock-open'}
        color={scannerLocked ? 'bad' : undefined}
        disabled={scannerBoltWireCut}
        onClick={() => act('toggle_lock')}
      >
        {scannerLocked ? 'Zablokowany' : 'Odblokowany'}
      </Button>
      <Button disabled={scannerLocked} onClick={() => act('toggle_door')}>
        {scannerOpen ? 'Zamknij' : 'Otwórz'}
      </Button>
    </>
  );
};

/**
 * Displays subject status based on the value of the status prop.
 */
const SubjectStatus = (props) => {
  const { status } = props;
  if (status === SUBJECT_CONCIOUS) {
    return (
      <Box inline color="good">
        Przytomny
      </Box>
    );
  }
  if (status === SUBJECT_UNCONSCIOUS) {
    return (
      <Box inline color="average">
        Nieprzytomny
      </Box>
    );
  }
  if (status === SUBJECT_SOFT_CRIT) {
    return (
      <Box inline color="average">
        Stan krytyczny
      </Box>
    );
  }
  if (status === SUBJECT_DEAD) {
    return (
      <Box inline color="bad">
        Martwy
      </Box>
    );
  }
  if (status === SUBJECT_TRANSFORMING) {
    return (
      <Box inline color="bad">
        W trakcie transformacji
      </Box>
    );
  }
  return <Box inline>Nieznany</Box>;
};

const DnaScannerContent = (props) => {
  const { data } = useBackend<Data>();
  const {
    subjectName,
    isScannerConnected,
    isViableSubject,
    subjectHealth,
    subjectRads,
    subjectStatus,
  } = data;
  if (!isScannerConnected) {
    return <Box color="bad">Skaner DNA nie jest podłączony.</Box>;
  }
  if (!isViableSubject) {
    return (
      <Box color="average">W skanerze DNA nie ma odpowiedniego obiektu.</Box>
    );
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Stan">
        {subjectName}
        <Icon mx={1} color="label" name="long-arrow-alt-right" />
        <SubjectStatus status={subjectStatus} />
      </LabeledList.Item>
      <LabeledList.Item label="Zdrowie">
        <ProgressBar
          value={subjectHealth}
          minValue={0}
          maxValue={100}
          ranges={{
            olive: [101, Infinity],
            good: [70, 101],
            average: [30, 70],
            bad: [-Infinity, 30],
          }}
        >
          {subjectHealth}%
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Promieniowanie">
        <ProgressBar
          value={subjectRads}
          minValue={0}
          maxValue={100}
          ranges={{
            bad: [71, Infinity],
            average: [30, 71],
            good: [0, 30],
            olive: [-Infinity, 0],
          }}
        >
          {subjectRads}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};

export const DnaScanner = (props) => {
  return (
    <Section title="Skaner DNA" buttons={<DnaScannerButtons />}>
      <DnaScannerContent />
    </Section>
  );
};
