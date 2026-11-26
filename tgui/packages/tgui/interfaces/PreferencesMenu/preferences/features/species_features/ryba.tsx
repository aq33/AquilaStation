// Cechy akwarianina (rybka w kloszu). Wybór ryby to główna cecha z ikonami i nie potrzebuje tu wpisu.
import { Feature, FeatureChoiced, FeatureColorInput } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const feature_aquarian_water: Feature<string> = {
  name: 'Zabarwienie wody',
  component: FeatureColorInput,
};

export const feature_aquarian_armor: Feature<string> = {
  name: 'Kolor pancerza',
  description:
    'Barwi płyty czerwonego pancerza i wzór na ramionach. Goły metal zostaje szary.',
  component: FeatureColorInput,
};

export const feature_aquarian_body: FeatureChoiced = {
  name: 'Pancerz',
  component: FeatureDropdownInput,
};

export const feature_aquarian_pattern: FeatureChoiced = {
  name: 'Wzór na ramionach',
  component: FeatureDropdownInput,
};

export const feature_aquarian_fish_color: Feature<string> = {
  name: 'Kolor ryby',
  component: FeatureColorInput,
};
