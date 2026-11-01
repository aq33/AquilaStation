import { CheckboxInput, FeatureToggle } from '../base';

export const lowgraphicsquality: FeatureToggle = {
  name: 'Niska jakość grafiki',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Mocno obniża jakość grafiki, żeby zużywać mniej pamięci karty graficznej. Przydaje się tylko wtedy, gdy masz problemy z renderowaniem, których nie naprawia wyczyszczenie pamięci podręcznej.',
  component: CheckboxInput,
  important: false,
};
