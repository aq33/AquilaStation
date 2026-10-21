import type { BooleanLike } from 'tgui-core/react';

export type AtmosReading = {
  gases: { name: string; percent: number }[];
  pressure: number;
  temperature: number;
};

/** Akta z GLOB.data_core: pola ogólne + medyczne albo ochrony */
export type PaiRecord = Record<string, string> & {
  id: string;
  name: string;
};

export type PaiData = {
  atmos: AtmosReading | null;
  available: Record<string, number>;
  dead: BooleanLike;
  directives: string[];
  door_jack: 'extended' | 'connected' | null;
  door_jack_compatible: BooleanLike;
  encryption_keys: BooleanLike;
  hack_progress: number;
  hacking: BooleanLike;
  installed: ReadonlyArray<string>;
  languages: BooleanLike;
  master_dna: string | null;
  master_name: string | null;
  med_hud: BooleanLike;
  prime_directive: string | null;
  ram: number;
  records: PaiRecord[] | null;
  records_type: 'medical' | 'security' | null;
  sec_hud: BooleanLike;
  signaler_code: number;
  signaler_frequency: number;
  signaler_max_freq: number;
  signaler_min_freq: number;
};
