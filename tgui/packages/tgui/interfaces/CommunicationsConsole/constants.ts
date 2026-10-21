import { capitalize } from 'tgui-core/string';

// Used for whether or not you need to swipe to confirm an alert level change
export const SWIPE_NEEDED = 'SWIPE_NEEDED';

export const ILLEGAL_SHUTTLE_NOTICE =
  'Uwaga: zabezpieczenia wyłączone. Ten prom nie ma certyfikatu. Zamawiasz na własne ryzyko.';

// NSV13 - poziomy alarmu statku.
// Nazwy do wyświetlania (klucze to wartości z DM, nie zmieniać)
export const ALERT_LEVELS = [
  'condition 3',
  'condition 2',
  'general quarters',
  'condition zebra',
];

const ALERT_LEVEL_NAMES = {
  'condition 3': 'Stan 3',
  'condition 2': 'Stan 2',
  'general quarters': 'Alarm bojowy',
  'condition zebra': 'Stan Zebra',
};

export const alertLevelName = (level: string) =>
  ALERT_LEVEL_NAMES[level] || capitalize(level);

// NSV13 - rozgłos statku (wartości z DM)
const NOTORIETY_NAMES = {
  Extreme: 'Skrajny',
  'Very High': 'Bardzo wysoki',
  High: 'Wysoki',
  Medium: 'Średni',
  Low: 'Niski',
};

export const notorietyName = (notoriety: string) =>
  NOTORIETY_NAMES[notoriety] || notoriety;
