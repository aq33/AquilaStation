import type { BodyZone } from '../common/BodyZoneSelector';

export type SurgeryTool = {
  name: string;
  speed: number;
};

/** Operacja z katalogu (aquila/code/modules/surgery/surgery_catalog.dm) */
export type CatalogOperation = {
  id: string;
  name: string;
  desc: string;
  tools: SurgeryTool[];
  /** Wymagane wszystkie, wymagane jedno z, opcjonalne, blokujące */
  requirements: string[][];
  time: number;
  locked: boolean;
  mechanic: boolean;
  priority: boolean;
  looping: boolean;
};

export type PatientData = {
  health: number;
  blood_type: string;
  stat: 'Conscious' | 'Unconscious' | 'Dead';
  statstate: 'good' | 'average' | 'bad';
  minHealth: number;
  maxHealth: number;
  bruteLoss: number;
  fireLoss: number;
  toxLoss: number;
  oxyLoss: number;
  blood_level?: number;
  standard_blood_level?: number;
  surgery_state?: string[];
  prepped?: boolean;
  ongoing?: string | null;
};

export type OperatingComputerData = {
  table?: unknown;
  patient?: PatientData | null;
  target_zone?: BodyZone;
  /** Typy operacji możliwych dalej w wybranej strefie */
  next_operations?: string[];
  /** Typy zablokowanych operacji wczytanych z dysków i badań */
  surgeries: string[];
  // static
  surgery_catalog: CatalogOperation[];
};

export type damageType = {
  label: string;
  type: 'bruteLoss' | 'fireLoss' | 'toxLoss' | 'oxyLoss';
};

export const damageTypes: damageType[] = [
  {
    label: 'Obrażenia',
    type: 'bruteLoss',
  },
  {
    label: 'Oparzenia',
    type: 'fireLoss',
  },
  {
    label: 'Toksyny',
    type: 'toxLoss',
  },
  {
    label: 'Oddech',
    type: 'oxyLoss',
  },
];

export const STAT_LABELS = {
  Conscious: 'Przytomny',
  Unconscious: 'Nieprzytomny',
  Dead: 'Martwy',
};

export enum ComputerTabs {
  PatientState = 1,
  OperationCatalog = 2,
}
