import { CheckboxInput, FeatureToggle } from '../base';

export const show_credits: FeatureToggle = {
  name: 'Pokaż napisy końcowe',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Włącza przewijane napisy końcowe na koniec rundy.',
  component: CheckboxInput,
};
