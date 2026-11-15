import { multiline } from 'common/string';

import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const preferred_engine: FeatureChoiced = {
  name: 'Preferowany silnik statku',
  category: 'GAMEPLAY',
  description: multiline`
    Gdy dostaniesz profesję Głównego Inżyniera albo Inżyniera, statek
    dostanie na start rundy ten silnik. Decyduje Główny Inżynier, a bez
    niego większość inżynierów. Działa na statkach z kilkoma wariantami
    silnika (Atlas, Trawnik, Padalec), jeśli dany silnik jest na tym
    statku.
  `,
  component: FeatureDropdownInput,
};
