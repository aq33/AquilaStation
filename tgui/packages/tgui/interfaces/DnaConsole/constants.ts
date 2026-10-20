export const CHROMOSOME_NEVER = 0;
export const CHROMOSOME_NONE = 1;
export const CHROMOSOME_USED = 2;

export const CONSOLE_MODE_ENZYMES = 'enzymes';
export const CONSOLE_MODE_SEQUENCER = 'sequencer';
export const CONSOLE_MODE_STORAGE = 'storage';

export const GENES = ['A', 'T', 'C', 'G'];
export const GENE_COLORS = {
  A: 'green',
  T: 'green',
  G: 'blue',
  C: 'blue',
  X: 'grey',
};

export const MUT_NORMAL = 1;
export const MUT_EXTRA = 2;
export const MUT_OTHER = 3;

export const STORAGE_CONS_SUBMODE_MUTATIONS = 'mutations';
export const STORAGE_CONS_SUBMODE_CHROMOSOMES = 'chromosomes';

export const STORAGE_DISK_SUBMODE_MUTATIONS = 'mutations';
export const STORAGE_DISK_SUBMODE_ENZYMES = 'diskenzymes';

export const STORAGE_MODE_CONSOLE = 'console';
export const STORAGE_MODE_DISK = 'disk';
export const STORAGE_MODE_ADVINJ = 'injector';

// Stałe stat z naszego DM (bez HARD_CRIT, jak w Bee)
export const SUBJECT_CONCIOUS = 0;
export const SUBJECT_SOFT_CRIT = 1;
export const SUBJECT_UNCONSCIOUS = 2;
export const SUBJECT_DEAD = 3;
export const SUBJECT_TRANSFORMING = 4;

export const RADIATION_STRENGTH_MAX = 15;
export const RADIATION_DURATION_MAX = 30;

// __DEFINES/DNA.dm - Mutation "Quality"
const POSITIVE = 1;
const NEGATIVE = 2;
const MINOR_NEGATIVE = 4;
export const MUT_COLORS = {
  [POSITIVE]: 'good',
  [NEGATIVE]: 'bad',
  [MINOR_NEGATIVE]: 'average',
};

/** Polskie nazwy źródeł mutacji (wartości `Source` z DM). */
export const SOURCE_NAMES = {
  occupant: 'obiektu',
  console: 'konsoli',
  disk: 'dysku',
  injector: 'iniektora',
};

export type Mutation = {
  Alias: string;
  Name: string;
  Description: string;
  Instability: number;
  Quality: number;
  Source: string;
  Sequence: string;
  DefaultSeq: string;
  Discovered: boolean;
  Active: boolean;
  Scrambled: boolean;
  Class: number;
  CanChromo: number;
  ByondRef: string;
  Type: string;
  Image: string;
  ValidChromos: string;
  AppliedChromo: string;
  ValidStoredChromos: string[];
};

export type Chromosome = {
  Name: string;
  Description: string;
  Index: number;
};

export type Makeup = {
  name?: string;
  label?: string;
  blood_type?: string;
  UE?: string;
  UI?: string;
};

export type AdvInjector = {
  name: string;
  mutations: Mutation[];
};

export type Data = {
  view: Record<string, any>;
  storage: {
    occupant?: Mutation[];
    console?: Mutation[];
    disk?: Mutation[];
    injector?: AdvInjector[];
  };
  isScannerConnected: boolean;
  scannerOpen: boolean;
  scannerLocked: boolean;
  scannerBoltWireCut: boolean;
  radStrength: number;
  radDuration: number;
  stdDevStr: number;
  stdDevAcc: string;
  isViableSubject: boolean;
  subjectName: string;
  subjectStatus: number;
  subjectHealth: number;
  subjectRads: number;
  subjectEnzymes: string;
  isMonkey: boolean;
  subjectUNI: string;
  hasDelayedAction: boolean;
  isScrambleReady: boolean;
  isJokerReady: boolean;
  isInjectorReady: boolean;
  scrambleSeconds: number;
  jokerSeconds: number;
  injectorSeconds: number;
  isPulsingRads: boolean;
  radPulseSeconds: number;
  hasDisk: boolean;
  diskCapacity: number;
  diskReadOnly: boolean;
  diskHasMakeup: boolean;
  diskMakeupBuffer: Makeup | null;
  mutationCapacity: number;
  chromoCapacity: number;
  chromoStorage: Chromosome[];
  makeupCapacity: number;
  makeupStorage: Record<string, Makeup>;
  maxAdvInjectors: number;
};
