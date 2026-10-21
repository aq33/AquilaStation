// Podgrzewacz chemiczny z fermichemem tg: bufory pH, podgląd trwających reakcji
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  Icon,
  NumberInput,
  ProgressBar,
  RoundGauge,
  Section,
  Table,
} from 'tgui-core/components';
import { round, toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { type Beaker, BeakerSectionDisplay } from './Chemistry/BeakerDisplay';

export type ActiveReaction = {
  name: string;
  danger: BooleanLike;
  overheat: BooleanLike;
  purityAlert: number;
  quality: number;
  inverse: number;
  minPure: number;
  reactedVol: number;
  targetVol: number;
};

type Data = {
  targetTemp: number;
  isActive: BooleanLike;
  upgradeLevel: number;
  beaker: Beaker | null;
  currentTemp: number;
  activeReactions: ActiveReaction[];
  isFlashing: number;
  acidicBufferVol: number;
  basicBufferVol: number;
  dispenseVolume: number;
  hasBeakerInHand: BooleanLike;
};

type ReactionDisplayProps = {
  beaker: Beaker;
  isFlashing: number;
  activeReactions: ActiveReaction[];
  highQualityDisplay: BooleanLike;
  highDangerDisplay: BooleanLike;
};

/** Skala pH jak papierek wskaźnikowy */
export const PH_RANGES: Record<string, [number, number]> = {
  red: [-0.22, 1.5],
  orange: [1.5, 3],
  yellow: [3, 4.5],
  olive: [4.5, 5],
  good: [5, 6],
  green: [6, 8.5],
  teal: [8.5, 9.5],
  blue: [9.5, 11],
  purple: [11, 12.5],
  violet: [12.5, 14],
};

/** Wartość alertAfter, przy której zegar nigdy nie miga (jak DISABLE_FLASHING w DM) */
const DISABLE_FLASHING = 14;

/** Kolor odczytu pH (te same progi co na zegarze) */
const phColor = (ph: number) =>
  Object.keys(PH_RANGES).find(
    (color) => ph >= PH_RANGES[color][0] && ph <= PH_RANGES[color][1],
  ) || 'label';

/** Jaśniejsze odcienie buforów, czytelne na ciemnym tle */
export const BUFFER_COLORS = {
  acidic: COLORS.reagent.acidicbuffer,
  basic: '#7f9cff',
};

type PhReadoutProps = {
  ph: number;
  isFlashing?: number;
};

/** Duży, kolorowy odczyt pH z zegarem */
export const PhReadout = (props: PhReadoutProps) => {
  const { ph, isFlashing = DISABLE_FLASHING } = props;
  return (
    <Flex align="center" mb={1}>
      <Flex.Item color="label" mr={1}>
        pH:
      </Flex.Item>
      <Flex.Item bold fontSize={1.6} color={phColor(ph)} mr={1.5}>
        <AnimatedNumber value={ph} format={(value) => toFixed(value, 2)} />
      </Flex.Item>
      <Flex.Item>
        <RoundGauge
          size={1.8}
          value={ph}
          minValue={0}
          maxValue={14}
          alertAfter={isFlashing}
          format={() => ''}
          ranges={PH_RANGES}
        />
      </Flex.Item>
    </Flex>
  );
};

export const ReactionDisplay = (props: ReactionDisplayProps) => {
  const {
    beaker,
    isFlashing,
    activeReactions,
    highQualityDisplay,
    highDangerDisplay,
  } = props;

  return (
    <Section title="Reakcje">
      <PhReadout ph={beaker.pH} isFlashing={isFlashing} />
      {(activeReactions.length === 0 && (
        <Box color="label">Brak trwających reakcji.</Box>
      )) || (
        <Table>
          <Table.Row>
            <Table.Cell bold color="label">
              Reakcja
            </Table.Cell>
            <Table.Cell bold color="label">
              {!highQualityDisplay ? 'Stan' : 'Jakość reakcji'}
            </Table.Cell>
            <Table.Cell bold color="label">
              Cel
            </Table.Cell>
          </Table.Row>
          {activeReactions.map((reaction) => (
            <Table.Row key={reaction.name}>
              <Table.Cell width="60px" color={reaction.danger && 'red'}>
                {reaction.name}
              </Table.Cell>
              <Table.Cell width="100px" pr="10px">
                {!highQualityDisplay ? (
                  <Icon
                    name={reaction.danger ? 'exclamation-triangle' : 'spinner'}
                    color={reaction.danger && 'red'}
                    spin={!reaction.danger}
                    ml={2.5}
                  />
                ) : (
                  <RoundGauge
                    size={1.3}
                    value={reaction.quality}
                    minValue={0}
                    maxValue={1}
                    alertAfter={reaction.purityAlert}
                    format={() => ''}
                    ml={5}
                    ranges={{
                      red: [0, reaction.minPure],
                      orange: [reaction.minPure, reaction.inverse],
                      yellow: [reaction.inverse, 0.8],
                      green: [0.8, 1],
                    }}
                  />
                )}
              </Table.Cell>
              <Table.Cell width="100px">
                {highDangerDisplay ? (
                  <>
                    {!!reaction.overheat && (
                      <Icon
                        name="thermometer-full"
                        color="red"
                        style={{ transform: 'scale(1.7)' }}
                        mr="5px"
                      />
                    )}
                    <ProgressBar
                      value={reaction.reactedVol}
                      minValue={0}
                      maxValue={reaction.targetVol}
                      textAlign="center"
                      width={8}
                      color={reaction.overheat ? 'red' : 'label'}
                    >
                      {reaction.targetVol}j.
                    </ProgressBar>
                  </>
                ) : (
                  <Box color={reaction.danger && 'red'} ml={2}>
                    {reaction.targetVol}j.
                  </Box>
                )}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

export const ChemHeater = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    targetTemp,
    isActive,
    isFlashing,
    beaker,
    currentTemp,
    acidicBufferVol,
    basicBufferVol,
    dispenseVolume,
    upgradeLevel,
    activeReactions = [],
    hasBeakerInHand,
  } = data;
  const isBeakerLoaded = !!beaker;

  return (
    <Window width={360} height={400}>
      <Window.Content scrollable>
        <Section
          title="Sterowanie"
          buttons={
            <Button
              icon={isActive ? 'power-off' : 'times'}
              selected={isActive}
              onClick={() => act('power')}
            >
              {isActive ? 'Wł.' : 'Wył.'}
            </Button>
          }
        >
          <Table>
            <Table.Row>
              <Table.Cell bold collapsing color="label">
                Grzanie
              </Table.Cell>
              <Table.Cell />
              <Table.Cell bold collapsing color="label">
                Bufory
              </Table.Cell>
              <Table.Cell />
              <Table.Cell>
                <NumberInput
                  width="45px"
                  unit="j."
                  step={1}
                  stepPixelSize={3}
                  value={dispenseVolume}
                  minValue={1}
                  maxValue={10}
                  tickWhileDragging
                  onChange={(value) =>
                    act('disp_vol', {
                      target: value,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell collapsing color="label">
                Cel:
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  width="65px"
                  unit="K"
                  step={10}
                  stepPixelSize={3}
                  value={round(targetTemp, 0)}
                  minValue={0}
                  maxValue={1000}
                  tickWhileDragging
                  onChange={(value) =>
                    act('temperature', {
                      target: value,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell collapsing color="label">
                Kwaśny:
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon="syringe"
                  disabled={!acidicBufferVol}
                  tooltip="Wstrzyknij"
                  tooltipPosition="left"
                  onClick={() =>
                    act('acidBuffer', {
                      target: 1,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell bold color={BUFFER_COLORS.acidic} textAlign="center">
                {`${acidicBufferVol}j.`}
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon="upload"
                  tooltip="Pobierz wszystko ze zlewki"
                  tooltipPosition="top"
                  disabled={acidicBufferVol === 100}
                  onClick={() =>
                    act('acidBuffer', {
                      target: -100,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell collapsing color="label">
                Odczyt:
              </Table.Cell>
              <Table.Cell collapsing color="default">
                <Box width="60px" textAlign="right">
                  {(isBeakerLoaded && (
                    <AnimatedNumber
                      value={currentTemp}
                      format={(value) => `${toFixed(value)} K`}
                    />
                  )) ||
                    '—'}
                </Box>
              </Table.Cell>
              <Table.Cell collapsing color="label">
                Zasadowy:
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon="syringe"
                  tooltip="Wstrzyknij"
                  tooltipPosition="left"
                  disabled={!basicBufferVol}
                  onClick={() =>
                    act('basicBuffer', {
                      target: 1,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell bold color={BUFFER_COLORS.basic} textAlign="center">
                {`${basicBufferVol}j.`}
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon="upload"
                  tooltip="Pobierz wszystko ze zlewki"
                  disabled={basicBufferVol === 100}
                  onClick={() =>
                    act('basicBuffer', {
                      target: -100,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
        {!!beaker && (
          <ReactionDisplay
            beaker={beaker}
            isFlashing={isFlashing}
            activeReactions={activeReactions}
            highQualityDisplay={upgradeLevel >= 4}
            highDangerDisplay={upgradeLevel >= 2}
          />
        )}
        <BeakerSectionDisplay
          beaker={beaker}
          showpH={false}
          showPurity
          showInsertButton
          hasBeakerInHand={hasBeakerInHand}
        />
      </Window.Content>
    </Window>
  );
};
