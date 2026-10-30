import { CheckboxInput, FeatureToggle } from '../base';

export const auto_fit_viewport: FeatureToggle = {
  name: 'Automatyczne dopasowanie widoku',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'Automatycznie dopasowuje proporcje panelu mapy i panelu czatu do rozmiaru mapy, usuwając czarne pasy z krawędzi widoku.',
  component: CheckboxInput,
  important: true,
};
