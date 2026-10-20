import type { BooleanLike } from 'tgui-core/react';

// AQUILA: dane z naszego /obj/mecha (stary system modułów), nie z tg.
export type MainData = {
  name: string;
  integrity: number;
  integrity_max: number;
  has_cell: BooleanLike;
  power_level: number;
  power_max: number;
  internal_damage: number;
  internal_damage_keys: Record<string, number>;
  warning_high_pressure: number;

  lights: BooleanLike;
  has_lights: BooleanLike;
  enclosed: BooleanLike;
  has_tank: BooleanLike;
  use_internal_tank: BooleanLike;
  tank_pressure?: number;
  tank_temperature?: number;
  port_connected?: BooleanLike;
  cabin_pressure: number;
  cabin_temperature: number;

  dna_lock: string | null;
  id_upload: BooleanLike;
  maint_access: BooleanLike;
  maint_protocols: BooleanLike;

  has_radio: BooleanLike;
  radio_broadcasting?: BooleanLike;
  radio_listening?: BooleanLike;
  radio_frequency?: number;
  min_frequency: number;
  max_frequency: number;

  actions: MechAction[];
  modules: MechModule[];
  max_equip: number;

  has_cargo: BooleanLike;
  cargo?: CargoItem[];

  /** AQUILA: dźwięki HONK (tylko H.O.N.K) */
  honk_sounds?: HonkSound[];
};

export type MechAction = {
  key: string;
  name: string;
  state: string;
  active: BooleanLike;
};

export type MechModule = {
  ref: string;
  name: string;
  /** HTML z get_equip_info() – zawiera odnośniki do akcji modułu */
  info: string | null;
  selected: BooleanLike;
  selectable: BooleanLike;
  detachable: BooleanLike;
  ready: BooleanLike;
};

export type CargoItem = {
  name: string;
  ref: string;
};

export type HonkSound = {
  key: string;
  name: string;
};
