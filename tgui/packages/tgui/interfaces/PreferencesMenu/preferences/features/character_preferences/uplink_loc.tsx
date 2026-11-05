import { FeatureChoiced } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const uplink_loc: FeatureChoiced = {
  name: 'Zapasowe miejsce uplinku',
  description:
    'Gdzie pojawia się uplink antagonistów, którzy nie dostają go jako ukrytego implantu (np. braci krwi).',
  component: FeatureButtonedDropdownInput,
};
