import { CheckboxInput, FeatureToggle } from '../base';

export const hide_bodily_functions: FeatureToggle = {
  name: 'Cenzura wypróżniania',
  category: 'GAMEPLAY',
  description:
    'Ukrywa komunikaty i dźwięki wypróżniania i oddawania moczu. Kupę i plamy moczu widzisz jako zwykły brud, a mocz w kałużach jako amoniak.',
  component: CheckboxInput,
};
