import { CheckboxInput, FeatureToggle } from '../base';

export const arrivals_rattle: FeatureToggle = {
  name: 'Przybycia',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'Po włączeniu jako duch dostajesz powiadomienia o nowej załodze.',
  component: CheckboxInput,
};

export const death_rattle: FeatureToggle = {
  name: 'Śmierci',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'Po włączeniu jako duch dostajesz powiadomienie, gdy ktoś umiera.',
  component: CheckboxInput,
};
