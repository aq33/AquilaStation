import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

export type BeakerReagent = {
  name: string;
  volume: number;
  /** AQUILA - fermichem: czystość 0-1 */
  purity?: number;
};

/** AQUILA - fermichem: czystość jako procent, zielona = czysta, czerwona = nieczysta */
export const PurityLabel = (props: { purity?: number }) => {
  const { purity } = props;
  if (purity === undefined || purity === null) {
    return null;
  }
  const color = purity >= 0.8 ? 'good' : purity >= 0.5 ? 'average' : 'bad';
  return (
    <Box inline color={color} ml={1}>
      ({Math.round(purity * 100)}%)
    </Box>
  );
};

export type Beaker = {
  maxVolume: number;
  pH: number;
  currentVolume: number;
  contents: BeakerReagent[];
};

type BeakerProps = {
  beaker: Beaker;
  replace_contents?: BeakerReagent[];
  title_label?: string;
  showpH?: BooleanLike;
  // eslint-disable-next-line react/no-unused-prop-types
  showInsertButton?: boolean;
  // eslint-disable-next-line react/no-unused-prop-types
  hasBeakerInHand?: BooleanLike;
};

export const BeakerDisplay = (props: BeakerProps) => {
  const { act } = useBackend();
  const { beaker, replace_contents, title_label, showpH } = props;
  const beakerContents = replace_contents || beaker?.contents || [];

  return (
    <LabeledList>
      <LabeledList.Item
        label="Zlewka"
        buttons={
          !!beaker && (
            <Button icon="eject" onClick={() => act('eject')}>
              Wysuń
            </Button>
          )
        }
      >
        {title_label ||
          (!!beaker && (
            <>
              <AnimatedNumber initial={0} value={beaker.currentVolume} />/
              {beaker.maxVolume} j.
            </>
          )) ||
          'Brak zlewki'}
      </LabeledList.Item>
      <LabeledList.Item label="Zawartość">
        <Box color="label">
          {(!title_label && !beaker && 'N/A') ||
            (beakerContents.length === 0 && 'Pusta')}
        </Box>
        {beakerContents.map((chemical) => (
          <Box key={chemical.name} color="label">
            <AnimatedNumber initial={0} value={chemical.volume} /> j.{' '}
            {chemical.name}
          </Box>
        ))}
        {beakerContents.length > 0 && !!showpH && (
          <Box>
            pH:
            <AnimatedNumber value={beaker.pH} />
          </Box>
        )}
      </LabeledList.Item>
    </LabeledList>
  );
};

export const BeakerSectionDisplay = (props: BeakerProps) => {
  const { act } = useBackend();
  const {
    beaker,
    replace_contents,
    title_label,
    showpH,
    showInsertButton = false,
    hasBeakerInHand,
  } = props;

  const beakerContents = replace_contents || beaker?.contents || [];
  const isBeakerLoaded = !!beaker;

  return (
    <Section
      title={title_label || 'Zlewka'}
      buttons={
        isBeakerLoaded ? (
          <>
            <Box inline color="label" mr={2}>
              {beaker.currentVolume} / {beaker.maxVolume} j.
            </Box>
            <Button icon="eject" onClick={() => act('eject')}>
              Wysuń
            </Button>
          </>
        ) : (
          showInsertButton && (
            <Button
              icon="eject"
              onClick={() => act('insert')}
              style={{
                opacity: hasBeakerInHand ? 1 : 0.5,
              }}
              tooltip={!hasBeakerInHand && 'Musisz trzymać pojemnik w ręce'}
              tooltipPosition="bottom-start"
            >
              Włóż
            </Button>
          )
        )
      }
    >
      <Box color="label">
        {(!beaker && 'Nie włożono zlewki') ||
          (beakerContents.length === 0 && 'Pusta')}
      </Box>
      {beakerContents.map((chemical) => (
        <Box key={chemical.name} color="label">
          <AnimatedNumber initial={0} value={chemical.volume} /> j.{' '}
          {chemical.name}
        </Box>
      ))}
      {beakerContents.length > 0 && !!showpH && (
        <Box>
          pH:
          <AnimatedNumber value={beaker.pH} />
        </Box>
      )}
    </Section>
  );
};
