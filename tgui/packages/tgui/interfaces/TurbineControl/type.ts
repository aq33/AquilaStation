/**
 * @file
 * @copyright 2026
 * @author Sovexe  (https://github.com/Sovexe)
 * @license MIT
 *
 * AQUILA: port z goonstation, dane z aquila/code/modules/power/blade_turbine.dm.
 */

import type { BooleanLike } from 'tgui-core/react';

export interface TurbineHistorySample {
  rpm: number;
  load: number;
  power: number;
  temperature: number;
  pressure: number;
  outletTemperature: number;
  outletPressure: number;
}

export interface TurbineBladeData {
  installed: BooleanLike;
  healthPercent: number;
  material: string | null;
}

export interface TurbineStatorData {
  installed: BooleanLike;
  material: string | null;
}

export interface TurbineControlData {
  connected: BooleanLike;
  rpm: number;
  load: number;
  power: number;
  volume: number;
  volumeMax: number;
  history: TurbineHistorySample[];
  optimalRPM: number;
  overspeedRPM: number;
  statorLoadMin: number;
  statorLoadMax: number;
  flowRateMin: number;
  minimumTemperature: number;
  overtempWarning: number;
  overtempLimit: number;
  inletTemperature: number;
  inletPressure: number;
  outletTemperature: number;
  outletPressure: number;
  overspeed: BooleanLike;
  overtemp: BooleanLike;
  undertemp: BooleanLike;
  stalling: BooleanLike;
  ruined: BooleanLike;
  blade: TurbineBladeData | null;
  stator: TurbineStatorData | null;
}
