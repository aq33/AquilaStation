import {
  Box,
  Button,
  Icon,
  Image,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  full_capability: BooleanLike;
  selected: string;
  object: RadarObject[];
  target: Target;
  scanning: BooleanLike;
};

type RadarObject = {
  name: string;
  ref: string;
};

type Target = {
  userot: BooleanLike;
  arrowstyle: string;
  rot: number;
  pointer: string;
  color: string;
  locy: number;
  locx: number;
  gpsx: number;
  gpsy: number;
  dist: number;
};

type ContentProps = {
  sig_err?: string;
};

export const NtosRadar = (props) => {
  const { data } = useBackend<Data>();
  const { full_capability } = data;
  return (
    <NtosWindow
      width={full_capability ? 800 : 400}
      height={full_capability ? 600 : 500}
      theme="ntos"
    >
      {full_capability ? (
        <NtosRadarContent sig_err="Utracono sygnał" />
      ) : (
        <NtosRadarContentSmall sig_err="Utracono sygnał" />
      )}
    </NtosWindow>
  );
};

/** AQUILA: uproszczony radar dla PDA (bez mapy, tylko odległość i kierunek) */
export const NtosRadarContentSmall = (props: ContentProps) => {
  const { data } = useBackend<Data>();
  const { selected, target } = data;
  const { sig_err = 'Utracono sygnał' } = props;
  const hasTarget = !!target && Object.keys(target).length > 0;
  return (
    <NtosWindow.Content scrollable>
      <Section>
        {!hasTarget ? (
          selected ? (
            <NoticeBox fontSize="30px" textAlign="center">
              {sig_err}
            </NoticeBox>
          ) : (
            <Box>Nie wybrano celu.</Box>
          )
        ) : (
          <Box>
            Odległość: {target.dist}
            <br />
            Położenie: ({target.gpsx}, {target.gpsy}){' '}
            {!!target.userot && (
              <Icon
                name={target.dist > 0 ? 'arrow-up' : 'crosshairs'}
                style={{
                  transform: `rotate(${target.rot}deg)`,
                }}
              />
            )}
          </Box>
        )}
      </Section>
      <ObjectList />
    </NtosWindow.Content>
  );
};

export const NtosRadarContent = (props: ContentProps) => {
  const { sig_err = 'Utracono sygnał' } = props;
  return (
    <Stack fill>
      <Stack.Item position="relative" width={20.5}>
        <NtosWindow.Content scrollable>
          <ObjectList />
        </NtosWindow.Content>
      </Stack.Item>
      <Stack.Item
        style={{
          backgroundImage: `url("${resolveAsset('ntosradarbackground.png')}")`,
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat',
          top: '20px',
        }}
        position="relative"
        m={1.5}
        width={45}
        height={45}
      >
        <TargetDisplay sig_err={sig_err} />
      </Stack.Item>
    </Stack>
  );
};

/** Lista wykrytych sygnałów */
const ObjectList = (props) => {
  const { act, data } = useBackend<Data>();
  const { object = [], scanning, selected } = data;

  return (
    <Section>
      <Button
        icon="redo-alt"
        color="blue"
        disabled={!!scanning}
        onClick={() => act('scan')}
      >
        {scanning ? 'Skanowanie...' : 'Skanuj'}
      </Button>
      {!object.length && !scanning && <div>Nie wykryto sygnałów.</div>}
      {!scanning &&
        object.map((object) => (
          <div
            key={object.ref}
            title={object.name}
            className={classes([
              'Button',
              'Button--fluid',
              'Button--color--transparent',
              'Button--ellipsis',
              object.ref === selected && 'Button--selected',
            ])}
            onClick={() => {
              act('selecttarget', {
                ref: object.ref,
              });
            }}
          >
            {object.name}
          </div>
        ))}
    </Section>
  );
};

/** Położenie celu na mapie radaru */
const TargetDisplay = (props: ContentProps) => {
  const { data } = useBackend<Data>();
  const { selected, target } = data;
  const { sig_err } = props;

  if (!selected || !target) {
    return null;
  }
  if (!Object.keys(target).length) {
    return (
      <NoticeBox
        position="absolute"
        top={20.6}
        left={1.35}
        width={42}
        fontSize="30px"
        textAlign="center"
      >
        {sig_err}
      </NoticeBox>
    );
  }
  return target.userot ? (
    <Image
      src={resolveAsset(target.arrowstyle)}
      position="absolute"
      top="20px"
      left="243px"
      style={{
        transform: `rotate(${target.rot}deg)`,
      }}
    />
  ) : (
    <Icon
      name={target.pointer}
      position="absolute"
      size={2}
      color={target.color}
      top={`${target.locy * 10 + 19}px`}
      left={`${target.locx * 10 + 16}px`}
    />
  );
};
