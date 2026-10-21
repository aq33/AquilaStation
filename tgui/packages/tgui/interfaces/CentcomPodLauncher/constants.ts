import { TabBay, TabDrop, TabPod } from './Tabs';
import type { PodDelay, PodEffect } from './types';

export const POD_GREY = {
  color: 'grey',
} as const;

export const TABPAGES = [
  {
    title: 'Podgląd kapsuły',
    component: TabPod,
  },
  {
    title: 'Podgląd zatoki',
    component: TabBay,
  },
  {
    title: 'Podgląd miejsca zrzutu',
    component: TabDrop,
  },
] as const;

type Option = {
  title: string;
  key: string;
  icon?: string;
};

// Klucze muszą zgadzać się z reverseOptionList w supplypod.dm.
// Opcja „Mechs” z tg pominięta: nasz DM jej nie obsługuje.
export const REVERSE_OPTIONS: Option[] = [
  {
    title: 'Moby',
    key: 'Mobs',
    icon: 'user',
  },
  {
    title: 'Obiekty\nnieprzytwierdzone',
    key: 'Unanchored',
    icon: 'cube',
  },
  {
    title: 'Obiekty\nprzytwierdzone',
    key: 'Anchored',
    icon: 'anchor',
  },
  {
    title: 'Pod podłogą',
    key: 'Underfloor',
    icon: 'eye-slash',
  },
  {
    title: 'Na ścianach',
    key: 'Wallmounted',
    icon: 'link',
  },
  {
    title: 'Podłogi',
    key: 'Floors',
    icon: 'border-all',
  },
  {
    title: 'Ściany',
    key: 'Walls',
    icon: 'square',
  },
];

export const DELAYS: PodDelay[] = [
  {
    title: 'Przed',
    tooltip: 'Czas, zanim kapsuła dotrze na stację',
  },
  {
    title: 'Spadek',
    tooltip: 'Czas trwania\nanimacji spadania',
  },
  {
    title: 'Otwarcie',
    tooltip: 'Czas otwierania kapsuły po lądowaniu',
  },
  {
    title: 'Odlot',
    tooltip: 'Czas do odlotu\nkapsuły po otwarciu',
  },
];

export const REV_DELAYS: PodDelay[] = [
  {
    title: 'Przed',
    tooltip: 'Czas, zanim kapsuła pojawi się nad miejscem zrzutu',
  },
  {
    title: 'Spadek',
    tooltip: 'Czas trwania\nanimacji spadania',
  },
  {
    title: 'Otwarcie',
    tooltip: 'Czas otwierania kapsuły po lądowaniu',
  },
  {
    title: 'Odlot',
    tooltip: 'Czas do odlotu\nkapsuły po otwarciu',
  },
];

export const SOUNDS = [
  {
    title: 'Spadek',
    act: 'fallingSound',
    tooltip: 'Gra podczas spadania, kończy się przy lądowaniu',
  },
  {
    title: 'Lądowanie',
    act: 'landingSound',
    tooltip: 'Gra po wylądowaniu kapsuły',
  },
  {
    title: 'Otwarcie',
    act: 'openingSound',
    tooltip: 'Gra przy otwarciu kapsuły',
  },
  {
    title: 'Odlot',
    act: 'leavingSound',
    tooltip: 'Gra przy odlocie kapsuły',
  },
];

export const BAYS = [
  { title: '1' },
  { title: '2' },
  { title: '3' },
  { title: '4' },
  { title: 'ERT' },
] as const;

export const EFFECTS_LOAD: PodEffect[] = [
  {
    act: 'launchAll',
    choiceNumber: 0,
    icon: 'globe',
    selected: 'launchChoice',
    title: 'Wyślij wszystkie pola',
  },
  {
    act: 'launchOrdered',
    choiceNumber: 1,
    icon: 'sort-amount-down-alt',
    selected: 'launchChoice',
    title: 'Wysyłaj pola po kolei',
  },
  {
    act: 'launchRandomTurf',
    choiceNumber: 2,
    icon: 'dice',
    selected: 'launchChoice',
    title: 'Losowe pole',
  },
  {
    divider: true,
  },
  {
    act: 'launchWholeTurf',
    choiceNumber: 0,
    icon: 'expand',
    selected: 'launchRandomItem',
    title: 'Wyślij całe pole',
  },
  {
    act: 'launchRandomItem',
    choiceNumber: 1,
    icon: 'dice',
    selected: 'launchRandomItem',
    title: 'Losowy przedmiot',
  },
  {
    divider: true,
  },
  {
    act: 'launchClone',
    icon: 'clone',
    soloSelected: 'launchClone',
    title: 'Klonuj',
  },
];

export const EFFECTS_NORMAL: PodEffect[] = [
  {
    act: 'effectTarget',
    icon: 'user-check',
    soloSelected: 'effectTarget',
    title: 'Konkretny cel',
  },
  {
    act: 'effectBluespace',
    choiceNumber: 0,
    icon: 'hand-paper',
    selected: 'effectBluespace',
    title: 'Kapsuła zostaje',
  },
  {
    act: 'effectStealth',
    icon: 'user-ninja',
    soloSelected: 'effectStealth',
    title: 'Ukryty cel',
  },
  {
    act: 'effectQuiet',
    icon: 'volume-mute',
    soloSelected: 'effectQuiet',
    title: 'Cisza',
  },
  {
    act: 'effectMissile',
    icon: 'rocket',
    soloSelected: 'effectMissile',
    title: 'Tryb pocisku',
  },
  {
    act: 'effectBurst',
    icon: 'certificate',
    soloSelected: 'effectBurst',
    title: 'Salwa',
  },
  {
    act: 'effectCircle',
    icon: 'ruler-combined',
    soloSelected: 'effectCircle',
    title: 'Dowolny kąt opadania',
  },
  {
    act: 'effectAnnounce',
    choiceNumber: 0,
    icon: 'ghost',
    selected: 'effectAnnounce',
    title:
      'Bez powiadomienia duchów\n(jeśli nie chcesz zabawiać\nznudzonych duchów)',
  },
];

// Efekt „create_sparks” z tg pominięty: nasz DM go nie obsługuje.
export const EFFECTS_HARM: PodEffect[] = [
  {
    act: 'explosionCustom',
    choiceNumber: 1,
    icon: 'bomb',
    selected: 'explosionChoice',
    title: 'Własny wybuch',
  },
  {
    act: 'explosionBus',
    choiceNumber: 2,
    icon: 'bomb',
    selected: 'explosionChoice',
    title: 'Wybuch adminbusa\nCo ci zrobią, zbanują?',
  },
  {
    divider: true,
  },
  {
    act: 'damageCustom',
    choiceNumber: 1,
    icon: 'skull',
    selected: 'damageChoice',
    title: 'Własne obrażenia',
  },
  {
    act: 'damageGib',
    choiceNumber: 2,
    icon: 'skull-crossbones',
    selected: 'damageChoice',
    title: 'Rozerwanie na strzępy',
  },
  {
    divider: true,
  },
  {
    act: 'effectShrapnel',
    details: true,
    icon: 'cloud-meatball',
    soloSelected: 'effectShrapnel',
    title: 'Chmura pocisków',
  },
  {
    act: 'effectStun',
    icon: 'sun',
    soloSelected: 'effectStun',
    title: 'Ogłuszenie',
  },
  {
    act: 'effectLimb',
    icon: 'socks',
    soloSelected: 'effectLimb',
    title: 'Odcięcie kończyny',
  },
  {
    act: 'effectOrgans',
    icon: 'book-dead',
    soloSelected: 'effectOrgans',
    title: 'Wyrzut organów',
  },
];

type Effect = {
  list: typeof EFFECTS_LOAD | typeof EFFECTS_NORMAL | typeof EFFECTS_HARM;
  label: string;
  alt_label?: string;
  tooltipPosition: string;
};

export const EFFECTS_ALL: Effect[] = [
  {
    list: EFFECTS_LOAD,
    label: 'Ładunek z zatoki',
    alt_label: 'Ładunek',
    tooltipPosition: 'right',
  },
  {
    list: EFFECTS_NORMAL,
    label: 'Efekty zwykłe',
    tooltipPosition: 'bottom',
  },
  {
    list: EFFECTS_HARM,
    label: 'Efekty szkodliwe',
    tooltipPosition: 'bottom',
  },
];
