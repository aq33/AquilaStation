import type { BooleanLike } from 'tgui-core/react';

import type { AIR_ALARM_ROUTES } from './AlarmControl';

// AQUILA: typy pod dane z naszego DM (code/modules/atmospherics/machinery/airalarm.dm),
// które różnią się od tg: urządzenia po id_tag, tryby po numerze,
// progi jako lista ustawień min2/min1/max1/max2.

type AlarmStatus = 0 | 1 | 2;

type EnvironmentData = {
  danger_level: AlarmStatus;
  name: string;
  value: number;
  unit: string;
};

type Mode = {
  danger: BooleanLike;
  mode: number;
  name: string;
  selected: BooleanLike;
};

export type ThresholdVar = 'min2' | 'min1' | 'max1' | 'max2';

type ThresholdSetting = {
  env: string;
  val: ThresholdVar;
  selected: number;
};

export type Threshold = {
  name: string;
  settings: ThresholdSetting[];
};

export type VentData = {
  id_tag: string;
  long_name: string;
  power: BooleanLike;
  checks: number;
  excheck: BooleanLike;
  incheck: BooleanLike;
  direction: 'release' | 'siphon';
  external: number;
  internal: number;
  extdefault: BooleanLike;
  intdefault: BooleanLike;
};

export type ScrubberData = {
  id_tag: string;
  long_name: string;
  power: BooleanLike;
  scrubbing: BooleanLike;
  widenet: BooleanLike;
  filter_types: {
    gas_id: string;
    gas_name: string;
    enabled: BooleanLike;
  }[];
};

export type AirAlarmData = {
  atmos_alarm: BooleanLike;
  danger_level: AlarmStatus;
  emagged: BooleanLike;
  environment_data: EnvironmentData[];
  fire_alarm: BooleanLike;
  locked: BooleanLike;
  mode: number;
  modes: Mode[];
  scrubbers: ScrubberData[];
  siliconUser: BooleanLike;
  thresholds: Threshold[];
  vents: VentData[];
};

export type AlarmScreen = keyof typeof AIR_ALARM_ROUTES;

export type EditingModalProps = {
  finish: () => void;
  env: string;
  name: string;
  typeVar: ThresholdVar;
  typeName: string;
  unit: string;
};

export type ActiveModal = EditingModalProps | undefined;

// Numery trybów z airalarm.dm (AALARM_MODE_*)
export const AALARM_MODE_SCRUBBING = 1;
export const AALARM_MODE_PANIC = 3;
