export type SurgeryTool = {
  name: string;
  speed: number;
};

export type SurgeryStep = {
  name: string;
  tools: SurgeryTool[];
  time: number;
  repeatable: boolean;
  chems: string[];
  allChems: boolean;
};

/** Pozycja z katalogu operacji (aquila/code/modules/surgery/surgery_catalog.dm) */
export type CatalogSurgery = {
  id: string;
  name: string;
  desc: string | null;
  locations: string[];
  targets: string[];
  bodypart: string;
  missingLimb: boolean;
  requiresTech: boolean;
  replacedBy: string | null;
  condition: string | null;
  lying: boolean;
  selfOperable: boolean;
  ignoreClothes: boolean;
  steps: SurgeryStep[];
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
};

export type Procedure = {
  name: string;
  surgery_name?: string;
  next_step: string;
  chems_needed: string;
  alternative_step?: string;
  alt_chems_needed?: string;
  next_tools?: SurgeryTool[];
  alt_tools?: SurgeryTool[];
};

/** Operacje zaawansowane zsynchronizowane z bazą badań */
export type AdvancedSurgery = {
  id: string;
  name: string;
  desc: string;
};

export type OperatingComputerData = {
  table?: unknown;
  patient?: PatientData | null;
  procedures?: Procedure[];
  surgeries: AdvancedSurgery[];
  // static
  surgery_catalog: CatalogSurgery[];
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

/** „skalpel / nóż (55%)” - narzędzia kroku, najlepsze pierwsze */
export const formatTools = (tools: SurgeryTool[] = []) =>
  [...tools]
    .sort((a, b) => b.speed - a.speed)
    .map((tool) =>
      tool.speed >= 100 ? tool.name : `${tool.name} (${tool.speed}%)`,
    )
    .join(' / ');
