// AQUILA - liczenie wyroku wspólne dla terminala GenPop i programu PDA „Prawo kosmiczne”
import { clamp, toFixed } from 'common/math';

// Te same stałe co w code/modules/security/crimes.dm (decysekundy).
export const PRESET_SHORT = 3000;
export const PRESET_LONG = 9000;
export const MAX_TIMER = 360000;

export const formatSentence = (time: number) =>
  time >= MAX_TIMER ? 'dożywocie' : `${toFixed(time / 600, 1)} min`;

export type SentenceModifiers = {
  adjust?: number;
  attempted?: boolean;
  elevated?: boolean;
  resisted?: boolean;
};

/** Ta sama reguła co calculate_sentence() w genpop.dm. */
export const calculateSentence = (
  baseTime: number,
  modifiers: SentenceModifiers = {},
) => {
  const { adjust = 0, attempted, elevated, resisted } = modifiers;
  let time = clamp(baseTime + adjust, 0, MAX_TIMER);
  if (attempted) {
    time = time >= MAX_TIMER ? PRESET_LONG : time - PRESET_SHORT;
  }
  if (elevated) {
    time = time >= PRESET_LONG ? MAX_TIMER : time + PRESET_SHORT;
  }
  if (resisted) {
    time *= 1.2;
  }
  return clamp(Math.round(time / 10) * 10, 0, MAX_TIMER);
};

// Podpowiedź formy kary w programie PDA „Prawo kosmiczne”
/** Mandat za jedno wykroczenie (kredyty) */
export const FINE_PER_MINOR = 150;
/** Punkty gułagu za minutę wyroku */
export const GULAG_POINTS_PER_MINUTE = 20;
/** Najmniej i najwięcej punktów gułagu (okno konsoli gułagu pozwala ustawić do 1000) */
export const GULAG_POINTS_MIN = 100;
export const GULAG_POINTS_MAX = 1000;

/** Co jest na mapie: terminal GenPop, teleporter gułagu, netpod do cyfrowego wygnania */
export type Facilities = {
  genpop: boolean;
  gulag: boolean;
  exile: boolean;
};

export type Punishment =
  | { kind: 'fine'; amount: number; time: number }
  | { kind: 'brig'; time: number }
  | { kind: 'genpop'; time: number }
  | { kind: 'gulag'; points: number }
  | { kind: 'permanent_cell' }
  | { kind: 'gulag_permanent' }
  | { kind: 'exile' };

export type PunishmentInput = {
  /** Wyroki zarzutów (decysekundy), każdy osobno */
  charges: number[];
  /** Wyrok po modyfikatorach (calculateSentence) */
  total: number;
  elevated?: boolean;
  resisted?: boolean;
  facilities: Facilities;
  maxFine: number;
};

/**
 * Formy kary pasujące do wyroku, od najlżejszej. Do trzech wykroczeń bez recydywy i oporu: mandat (albo areszt).
 * Do 15 min: areszt w celi z zegarem. Dłużej: GenPop albo gułag z punktami, jeśli są na mapie (bez nich areszt).
 * Dożywocie: stała cela, gułag bez zwolnienia, cyfrowe wygnanie (decyzja Komendanta lub Kapitana).
 */
export const suggestPunishment = (input: PunishmentInput): Punishment[] => {
  const { charges, total, elevated, resisted, facilities, maxFine } = input;
  if (charges.length === 0) {
    return [];
  }
  if (total >= MAX_TIMER) {
    const result: Punishment[] = [{ kind: 'permanent_cell' }];
    if (facilities.gulag) {
      result.push({ kind: 'gulag_permanent' });
    }
    if (facilities.exile) {
      result.push({ kind: 'exile' });
    }
    return result;
  }
  const onlyMinor = charges.every((sentence) => sentence <= PRESET_SHORT);
  if (
    onlyMinor &&
    total <= PRESET_LONG &&
    !elevated &&
    !resisted &&
    maxFine > 0
  ) {
    return [
      {
        kind: 'fine',
        amount: Math.min(FINE_PER_MINOR * charges.length, maxFine),
        time: total,
      },
    ];
  }
  if (total <= PRESET_LONG) {
    return [{ kind: 'brig', time: total }];
  }
  const result: Punishment[] = [];
  if (facilities.genpop) {
    result.push({ kind: 'genpop', time: total });
  }
  if (facilities.gulag) {
    const points = Math.round((total / 600) * GULAG_POINTS_PER_MINUTE);
    result.push({
      kind: 'gulag',
      points: clamp(points, GULAG_POINTS_MIN, GULAG_POINTS_MAX),
    });
  }
  if (result.length === 0) {
    result.push({ kind: 'brig', time: total });
  }
  return result;
};
