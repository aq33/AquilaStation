import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const game_language: FeatureChoiced = {
  name: 'Język gry / Game language',
  category: 'UI',
  description:
    'Wersja testowa: tłumaczy czat, examine i panel statystyk; okna i nazwy obiektów zostają na razie po polsku. / Experimental: translates the chat, examine and the stat panel; windows and object names stay Polish for now.',
  component: FeatureDropdownInput,
};
