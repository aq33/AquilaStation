import {
  CheckboxInput,
  Feature,
  FeatureColorInput,
  FeatureToggle,
} from '../base';

export const ooccolor: Feature<string> = {
  name: 'Kolor OOC',
  category: 'CHAT',
  subcategory: 'OOC',
  description: 'Kolor twoich wiadomości OOC.',
  component: FeatureColorInput,
  important: true,
};

export const member_public: FeatureToggle = {
  name: 'Pokaż członkostwo BYOND',
  category: 'BYOND MEMBER',
  description: 'Czy pokazywać w OOC twoje członkostwo BYOND.',
  component: CheckboxInput,
  important: true,
};
