import {
  CheckboxInput,
  Feature,
  FeatureNumberInput,
  FeatureNumeric,
  FeatureToggle,
} from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const chat_on_map: FeatureToggle = {
  name: 'Włącz runechat',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Wiadomości czatu pojawiają się nad głowami.',
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: 'Runechat nad obiektami',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Wiadomości czatu pojawiają się nad mówiącymi obiektami.',
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: 'Emotki w runechacie',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Emotki pojawiają się nad głowami.',
  component: CheckboxInput,
};

export const max_chat_length: FeatureNumeric = {
  name: 'Maks. długość runechatu',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Maksymalna długość wyświetlanej wiadomości runechatu.',
  component: FeatureNumberInput,
};

export const show_balloon_alerts: Feature<string> = {
  name: 'Pokazuj dymki',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Pokazuje tekst nad przedmiotami przy niektórych interakcjach.',
  component: FeatureButtonedDropdownInput,
};

export const enable_runechat_looc: FeatureToggle = {
  name: 'LOOC w runechacie',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Wiadomości LOOC pojawiają się nad głowami.',
  component: CheckboxInput,
};
