import { CheckboxInput, FeatureToggle } from '../base';

export const fullscreen: FeatureToggle = {
  name: 'Pełny ekran',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Po włączeniu okno gry zajmuje cały ekran i zasłania pasek zadań.',
  component: CheckboxInput,
  important: true,
};
