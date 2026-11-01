import { CheckboxInput, FeatureToggle } from '../base';

export const buttons_locked: FeatureToggle = {
  name: 'Zablokuj przyciski akcji',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Po włączeniu przyciski akcji są zablokowane w miejscu.',
  component: CheckboxInput,
};
