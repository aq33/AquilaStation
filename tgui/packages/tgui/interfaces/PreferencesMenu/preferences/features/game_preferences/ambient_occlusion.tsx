import { CheckboxInput, FeatureToggle } from '../base';

export const ambientocclusion: FeatureToggle = {
  name: 'Okluzja otoczenia',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description: 'Dodaje miękkie cienie wokół krawędzi obiektów.',
  component: CheckboxInput,
};
