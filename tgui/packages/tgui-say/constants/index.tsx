/** Radio channels */
export const CHANNELS = [
  'Say',
  'Radio',
  'Me',
  'OOC',
  'LOOC',
  'Asay',
  'Dsay',
  'Msay',
];
export const CYCLEABLE_CHANNELS = ['Say', 'Radio', 'Me', 'OOC', 'LOOC'];
export const NO_RADIO_CHANNELS = ['Me', 'OOC', 'LOOC'];
/** Polskie etykiety kanałów (same kanały zostają po angielsku, bo idą do DM). */
export const CHANNEL_LABELS: Record<string, string> = {
  Say: 'Mów',
  Radio: 'Radio',
  Me: 'Akcja',
};

export const RESTRICTED_CHANNELS = ['Asay', 'Dsay', 'Msay'];

/**
 * AQUILA: etykiety po angielsku dla gracza z językiem EN (język przychodzi w
 * wiadomości i18n/setLanguage z aquila/code/modules/i18n/game_language.dm). Polska etykieta ->
 * angielska; kanały (Say, Radio, Me) mają angielskie nazwy same z siebie.
 */
const ENGLISH_LABELS: Record<string, string> = {
  Rój: 'Hive',
  Dow: 'Cmd',
  Inż: 'Engi',
  Lewo: 'Left',
  Nauk: 'Sci',
  SI: 'AI',
  Prawo: 'Right',
  Żand: 'Sec',
  Zaop: 'Supp',
  Usł: 'Svc',
  Amun: 'Muni',
};

/**
 * Etykiety po rosyjsku: kanał (Say, Radio, Me) albo polska etykieta przedrostka radia.
 * Krótkie jak polskie, bo przycisk jest wąski.
 */
const RUSSIAN_LABELS: Record<string, string> = {
  Say: 'Речь',
  Radio: 'Радио',
  Me: 'Эмоция',
  Rój: 'Рой',
  Dow: 'Ком',
  Upl: 'Загр',
  Inż: 'Инж',
  Holo: 'Голо',
  Inter: 'Интер',
  Lewo: 'Лево',
  Med: 'Мед',
  Nauk: 'Наук',
  SI: 'ИИ',
  Explo: 'Экспл',
  Prawo: 'Право',
  Żand: 'СБ',
  Synd: 'Синд',
  Zaop: 'Снаб',
  Usł: 'Серв',
  CCom: 'ЦК',
  Uzbr: 'Воор',
  Amun: 'Боеп',
};

let sayLanguage = 'pl';

export const setSayLanguage = (language: string | undefined) => {
  sayLanguage = language || 'pl';
};

/** Napis na przycisku kanału w języku gracza */
export const channelLabel = (content: string): string => {
  if (sayLanguage === 'en') {
    return ENGLISH_LABELS[content] || content;
  }
  if (sayLanguage === 'ru') {
    return RUSSIAN_LABELS[content] || content;
  }
  return CHANNEL_LABELS[content] || content;
};

/** Window sizes in pixels */
export enum WINDOW_SIZES {
  small = 30,
  medium = 50,
  large = 70,
  width = 231,
}

/** Line lengths for autoexpand */
export enum LINE_LENGTHS {
  small = 19,
  medium = 35,
}

/**
 * Radio prefixes.
 * Contains the properties:
 * id - string. css class identifier.
 * label - string. button label.
 */
export const RADIO_PREFIXES = {
  ':a ': {
    id: 'hive',
    label: 'Rój',
  },
  ':b ': {
    id: 'binary',
    label: '0101',
  },
  ':c ': {
    id: 'command',
    label: 'Dow',
  },
  ':d ': {
    id: 'uplink',
    label: 'Upl',
  },
  ':e ': {
    id: 'engi',
    label: 'Inż',
  },
  ':h ': {
    id: 'holo',
    label: 'Holo',
  },
  ':i ': {
    id: 'intercom',
    label: 'Inter',
  },
  ':l ': {
    id: 'left',
    label: 'Lewo',
  },
  ':m ': {
    id: 'medical',
    label: 'Med',
  },
  ':n ': {
    id: 'science',
    label: 'Nauk',
  },
  ':o ': {
    id: 'ai',
    label: 'SI',
  },
  ':q ': {
    id: 'exploration',
    label: 'Explo',
  },
  ':r ': {
    id: 'right',
    label: 'Prawo',
  },
  ':s ': {
    id: 'security',
    label: 'Żand',
  },
  ':t ': {
    id: 'syndicate',
    label: 'Synd',
  },
  ':u ': {
    id: 'supply',
    label: 'Zaop',
  },
  ':v ': {
    id: 'service',
    label: 'Usł',
  },
  ':y ': {
    id: 'centcom',
    label: 'CCom',
  },
  ':p ': {
    id: 'holoparasite',
    label: 'HPara',
  },
  ':w ': {
    id: 'munition',
    label: 'Uzbr',
  },
  ':z ': {
    id: 'space_pirate',
    label: 'SP',
  },
  // NSV13 - End of NSV13 Comms
} as const;
