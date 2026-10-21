// AQUILA - polska wersja common/BeakerDisplay z tg dla okien chemii.
// Typy są te same co w common/BeakerDisplay, więc dane z DM pasują 1:1.
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import {
  type Beaker,
  type BeakerReagent,
  PurityLabel,
} from '../common/BeakerDisplay';

export type { Beaker, BeakerReagent };

/** Składa obiekt zlewki ze starych kluczy Bee (isBeakerLoaded, beakerContents...) */
export const legacyBeaker = (
  loaded: BooleanLike,
  currentVolume: number | null | undefined,
  maxVolume: number | null | undefined,
  contents: BeakerReagent[] | null | undefined,
  ph?: number | null,
): Beaker | null => {
  if (!loaded) {
    return null;
  }
  return {
    currentVolume: currentVolume || 0,
    maxVolume: maxVolume || 0,
    pH: ph ?? 7,
    contents: contents || [],
  };
};

type BeakerProps = {
  beaker: Beaker | null;
  replace_contents?: BeakerReagent[] | false;
  title_label?: string | false;
  showpH?: BooleanLike;
  /** AQUILA - fermichem: czystość obok każdego odczynnika */
  showPurity?: BooleanLike;
};

type BeakerSectionProps = BeakerProps & {
  showInsertButton?: boolean;
  hasBeakerInHand?: BooleanLike;
};

const ReagentLine = (props: {
  chemical: BeakerReagent;
  showPurity?: BooleanLike;
}) => {
  const { chemical, showPurity } = props;
  return (
    <Box color="label">
      {chemical.name}: <AnimatedNumber initial={0} value={chemical.volume} /> u
      {!!showPurity && <PurityLabel purity={chemical.purity} />}
    </Box>
  );
};

export const BeakerDisplay = (props: BeakerProps) => {
  const { act } = useBackend();
  const { beaker, replace_contents, title_label, showpH, showPurity } = props;
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
              {beaker.maxVolume} u
            </>
          )) ||
          'Brak zlewki'}
      </LabeledList.Item>
      <LabeledList.Item label="Zawartość">
        <Box color="label">
          {(!title_label && !beaker && '—') ||
            (beakerContents.length === 0 && 'Pusto')}
        </Box>
        {beakerContents.map((chemical) => (
          <ReagentLine
            key={chemical.name}
            chemical={chemical}
            showPurity={showPurity}
          />
        ))}
        {beakerContents.length > 0 && !!showpH && !!beaker && (
          <Box>
            pH: <AnimatedNumber value={beaker.pH} />
          </Box>
        )}
      </LabeledList.Item>
    </LabeledList>
  );
};

export const BeakerSectionDisplay = (props: BeakerSectionProps) => {
  const { act } = useBackend();
  const {
    beaker,
    replace_contents,
    title_label,
    showpH,
    showPurity,
    showInsertButton = false,
    hasBeakerInHand,
  } = props;

  const beakerContents = replace_contents || beaker?.contents || [];

  return (
    <Section
      title={title_label || 'Zlewka'}
      buttons={
        beaker ? (
          <>
            <Box inline color="label" mr={2}>
              {beaker.currentVolume} / {beaker.maxVolume} u
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
              tooltip={!hasBeakerInHand && 'Musisz trzymać pojemnik w ręce.'}
              tooltipPosition="bottom-start"
            >
              Włóż
            </Button>
          )
        )
      }
    >
      <Box color="label">
        {(!beaker && 'Nie włożono zlewki.') ||
          (beakerContents.length === 0 && 'Pusto')}
      </Box>
      {beakerContents.map((chemical) => (
        <ReagentLine
          key={chemical.name}
          chemical={chemical}
          showPurity={showPurity}
        />
      ))}
      {beakerContents.length > 0 && !!showpH && !!beaker && (
        <Box>
          pH: <AnimatedNumber value={beaker.pH} />
        </Box>
      )}
    </Section>
  );
};
