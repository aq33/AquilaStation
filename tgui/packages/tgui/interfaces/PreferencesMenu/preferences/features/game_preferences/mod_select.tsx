import { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const mod_select: Feature<string> = {
  name: 'Klawisz aktywnego modułu MOD',
  category: 'GAMEPLAY',
  description: 'Klawisz, którym używasz aktywnego modułu MODsuitu.',
  component: FeatureDropdownInput,
};
