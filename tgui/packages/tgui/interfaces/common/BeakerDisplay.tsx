// Zlewka z zawartością, pH i czystością (port tg common/BeakerDisplay pod fermichem)
import { AnimatedNumber, Box, Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

export type BeakerReagent = {
  name: string;
  volume: number;
  purity?: number;
};

export type Beaker = {
  maxVolume: number;
  pH: number;
  currentVolume: number;
  contents: BeakerReagent[];
};

type BeakerProps = {
  beaker: Beaker | null;
  title_label?: string;
  showpH?: BooleanLike;
  showPurity?: BooleanLike;
  showInsertButton?: boolean;
  hasBeakerInHand?: BooleanLike;
};

/** Czystość jako procent, z kolorem jak w tg (zielona = czysta, czerwona = nieczysta) */
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

export const BeakerSectionDisplay = (props: BeakerProps) => {
  const { act } = useBackend();
  const {
    beaker,
    title_label,
    showpH,
    showPurity,
    showInsertButton = false,
    hasBeakerInHand,
  } = props;

  const beakerContents = beaker?.contents || [];
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
            <Button icon="eject" content="Wysuń" onClick={() => act('eject')} />
          </>
        ) : (
          showInsertButton && (
            <Button
              icon="eject"
              content="Włóż"
              onClick={() => act('insert')}
              style={{
                opacity: hasBeakerInHand ? 1 : 0.5,
              }}
              tooltip={!hasBeakerInHand && 'Musisz trzymać pojemnik w ręce'}
              tooltipPosition="bottom-start"
            />
          )
        )
      }
    >
      <Box color="label">
        {(!beaker && 'Brak zlewki') || (beakerContents.length === 0 && 'Pusta')}
      </Box>
      {beakerContents.map((chemical) => (
        <Box key={chemical.name} color="label">
          <AnimatedNumber initial={0} value={chemical.volume} /> j.{' '}
          {chemical.name}
          {!!showPurity && <PurityLabel purity={chemical.purity} />}
        </Box>
      ))}
      {beakerContents.length > 0 && !!showpH && (
        <Box>
          pH: <AnimatedNumber value={beaker!.pH} />
        </Box>
      )}
    </Section>
  );
};
