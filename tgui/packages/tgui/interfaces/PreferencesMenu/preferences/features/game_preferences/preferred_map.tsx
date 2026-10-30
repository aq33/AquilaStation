import { multiline } from 'common/string';

import { FeatureChoiced } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const preferred_map: FeatureChoiced = {
  name: 'Preferowana mapa',
  category: 'GAMEPLAY',
  description: multiline`
    Przy rotacji map ta mapa jest wybierana chętniej.
    Nie wpływa na głosowanie, tylko na losową rotację, gdy nie ma
    głosowania.
  `,
  component: FeatureButtonedDropdownInput,
};
