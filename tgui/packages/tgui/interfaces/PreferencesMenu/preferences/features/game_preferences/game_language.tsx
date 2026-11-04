import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const game_language: FeatureChoiced = {
  name: 'Język gry / Game language',
  category: 'UI',
  description:
    'Wersja testowa: na razie zapisuje sam wybór, tłumaczenie interfejsu przyjdzie w kolejnych wersjach. / Experimental: only the choice is saved for now.',
  component: FeatureDropdownInput,
};
