import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  beaker?: Beaker;
  beaker_empty?: BooleanLike;
  blood?: Blood;
  has_beaker: BooleanLike;
  has_blood: BooleanLike;
  is_ready: BooleanLike;
  resistances?: Resistance[];
  viruses?: Virus[];
  // static - AQUILA: katalog wszystkich symptomów
  symptom_catalog?: CatalogSymptom[];
};

type Beaker = {
  volume: number;
  capacity: number;
};

type Blood = {
  dna: string;
  type: string;
};

type Resistance = {
  id: string;
  name: string;
};

export type Virus = {
  name: string;
  can_rename: BooleanLike;
  is_adv: BooleanLike;
  symptoms?: Symptom[];
  resistance: number;
  stealth: number;
  stage_speed: number;
  transmission: number;
  symptom_severity: number;
  index: number;
  agent: string;
  description: string;
  spread: string;
  cure: string;
  danger: string;
};

export type Symptom = {
  name: string;
  desc: string;
  stealth: number;
  resistance: number;
  stage_speed: number;
  transmission: number;
  severity: number;
  level: number;
  neutered?: BooleanLike;
  /** U nas to gotowy HTML z DM (threshold_desc) */
  threshold_desc: string;
};

export type CatalogSymptom = Symptom & {
  id: string;
  natural: boolean;
  sources: string[];
};
