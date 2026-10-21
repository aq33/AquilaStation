// AQUILA - okno sejfu (aquila/code/game/objects/structures/safe.dm)
// Wygląd z tg (Safe.jsx + styles/interfaces/Safe.scss), mechanika nasza:
// pokrętło 0-71, obrót o kilka ząbków naraz, licznik miejsca w sejfie.
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SafeItem = {
  name: string;
  ref: string;
};

type Data = {
  open: BooleanLike;
  dial: number;
  broken: BooleanLike;
  space: number;
  max_space: number;
  contents: SafeItem[];
};

/** Pokrętło ma 72 pozycje (0-71) */
const DIAL_DEGREES_PER_STEP = 360 / 72;

export const Safe = (_) => {
  const { data } = useBackend<Data>();
  const { dial, open, broken } = data;
  return (
    <Window width={500} height={640} theme="ntos">
      <Window.Content>
        <Box className="Safe__engraving">
          <Dialer />
          <Box>
            <Box className="Safe__engraving-hinge" top="25%" />
            <Box className="Safe__engraving-hinge" top="75%" />
          </Box>
          {!!broken && <NoticeBox danger>Zamek jest rozbity.</NoticeBox>}
          <Icon
            className="Safe__engraving-arrow"
            name="long-arrow-alt-down"
            size={5}
          />
          <br />
          {open ? (
            <Contents />
          ) : (
            <Box
              className="Safe__dial"
              style={{
                transform: `rotate(-${DIAL_DEGREES_PER_STEP * dial}deg)`,
              }}
            >
              <Box className="Safe__dial-marker" />
            </Box>
          )}
        </Box>
        {!open && <Help />}
      </Window.Content>
    </Window>
  );
};

const Dialer = (_) => {
  const { act, data } = useBackend<Data>();
  const { dial, open } = data;
  const dialButton = (amount: number, right?: boolean) => {
    return (
      <Button
        key={`${right ? 'r' : 'l'}${amount}`}
        disabled={open}
        icon={`arrow-${right ? 'right' : 'left'}`}
        iconPosition={right ? 'right' : 'left'}
        onClick={() =>
          act('turn', {
            steps: right ? amount : -amount,
          })
        }
      >
        {`${right ? 'Prawo' : 'Lewo'} ${amount}`}
      </Button>
    );
  };
  return (
    <Box className="Safe__dialer">
      <Button
        icon={open ? 'lock' : 'lock-open'}
        mb="0.5rem"
        onClick={() => act('open')}
      >
        {open ? 'Zamknij' : 'Otwórz'}
      </Button>
      <br />
      <Box position="absolute">
        {[dialButton(10), dialButton(5), dialButton(1)]}
      </Box>
      <Box className="Safe__dialer-right" position="absolute" right="5px">
        {[dialButton(1, true), dialButton(5, true), dialButton(10, true)]}
      </Box>
      <Box className="Safe__dialer-number">{dial}</Box>
    </Box>
  );
};

const Contents = (_) => {
  const { act, data } = useBackend<Data>();
  const { contents = [], space, max_space } = data;
  return (
    <Box className="Safe__contents" overflow="auto">
      <ProgressBar value={space} maxValue={max_space} mb={1}>
        Miejsce: {space} / {max_space}
      </ProgressBar>
      {contents.length === 0 && <Box color="label">Sejf jest pusty.</Box>}
      {contents.map((item) => (
        <Button
          key={item.ref}
          fluid
          mb="0.5rem"
          icon="hand-paper"
          onClick={() =>
            act('retrieve', {
              ref: item.ref,
            })
          }
        >
          {item.name}
        </Button>
      ))}
    </Box>
  );
};

const Help = (_) => {
  return (
    <Section
      className="Safe__help"
      title="Jak otworzyć sejf (bo ciągle zapominacie)"
    >
      <Box>
        1. Weź stetoskop do ręki - tylko wtedy usłyszysz zapadki.
        <br />
        2. Kręć pokrętłem i nasłuchuj, aż pierwszy bębenek trafi na swoje
        miejsce.
        <br />
        3. Zrób to samo z drugim bębenkiem.
        <br />
        4. Otwórz sejf.
      </Box>
      <Box bold>Po zamknięciu przekręć pokrętło, żeby znowu go zablokować.</Box>
    </Section>
  );
};
