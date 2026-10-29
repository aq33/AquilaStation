import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const chat_bankcard: FeatureToggle = {
  name: 'Powiadomienia o dochodach',
  category: 'CHAT',
  subcategory: 'IC',
  description: 'Otrzymuj powiadomienia o swoim koncie bankowym.',
  component: CheckboxInput,
};

export const chat_followghostmindless: FeatureToggle = {
  name: '(F) przy bezmyślnych',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'Po włączeniu przed bezmyślnymi istotami w czacie umarłych pojawia się (F). Po wyłączeniu (F) pojawia się tylko przy istotach z umysłem.',
  component: CheckboxInput,
};

export const chat_ghostears: FeatureToggle = {
  name: 'Mowa',
  category: 'GHOST',
  subcategory: 'Chat',
  description: multiline`
    Po włączeniu jako duch słyszysz całą mowę.
    Po wyłączeniu słyszysz tylko mowę w pobliżu.
  `,
  component: CheckboxInput,
  important: true,
};

export const chat_ghostlaws: FeatureToggle = {
  name: 'Zmiany praw',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'Po włączeniu jako duch dostajesz powiadomienia o zmianach praw.',
  component: CheckboxInput,
};

export const chat_ghostpda: FeatureToggle = {
  name: 'Wiadomości PDA',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'Po włączeniu jako duch dostajesz powiadomienia o wiadomościach PDA.',
  component: CheckboxInput,
};

export const chat_ghostradio: FeatureToggle = {
  name: 'Radio',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'Po włączeniu jako duch dostajesz powiadomienia o wiadomościach radiowych.',
  component: CheckboxInput,
};

export const chat_ghostsight: FeatureToggle = {
  name: 'Emotki',
  category: 'GHOST',
  subcategory: 'Chat',
  description: 'Po włączeniu jako duch widzisz wszystkie emotki.',
  component: CheckboxInput,
  important: true,
};

export const chat_ghostwhisper: FeatureToggle = {
  name: 'Szepty',
  category: 'GHOST',
  subcategory: 'Chat',
  description: multiline`
    Po włączeniu jako duch słyszysz wszystkie szepty.
    Po wyłączeniu słyszysz tylko szepty w pobliżu.
  `,
  component: CheckboxInput,
  important: true,
};

export const chat_ooc: FeatureToggle = {
  name: 'Włącz OOC',
  category: 'CHAT',
  subcategory: 'OOC',
  component: CheckboxInput,
};

export const chat_pullr: FeatureToggle = {
  name: 'Powiadomienia o pull requestach',
  category: 'CHAT',
  subcategory: 'OOC',
  description:
    'Dostawaj powiadomienia, gdy ktoś otworzy, zamknie albo scali pull request.',
  component: CheckboxInput,
};

// Admin

export const chat_dead: FeatureToggle = {
  name: 'Słysz czat umarłych',
  category: 'ADMIN',
  subcategory: 'Chat',
  description: 'Słysz cały czat umarłych, gdy masz uprawnienia admina.',
  component: CheckboxInput,
  important: true,
};

export const chat_prayer: FeatureToggle = {
  name: 'Słysz modlitwy',
  category: 'ADMIN',
  subcategory: 'Chat',
  component: CheckboxInput,
  important: true,
};

export const chat_radio: FeatureToggle = {
  name: 'Słysz radio',
  category: 'ADMIN',
  subcategory: 'Chat',
  description:
    'Słysz wszystkie wiadomości radiowe, gdy masz uprawnienia admina.',
  component: CheckboxInput,
  important: true,
};

export const examine_messages: FeatureToggle = {
  name: 'Komunikaty o oglądaniu',
  category: 'CHAT',
  subcategory: 'IC',
  description: 'Dostawaj w czacie komunikaty „gracz ogląda x”.',
  component: CheckboxInput,
};

export const whole_word_examine_links: FeatureToggle = {
  name: 'Linki oglądania na całym słowie',
  category: 'CHAT',
  subcategory: 'IC',
  description: 'Linki do oglądania obejmują całe słowo zamiast dopisanego [?].',
  component: CheckboxInput,
};
