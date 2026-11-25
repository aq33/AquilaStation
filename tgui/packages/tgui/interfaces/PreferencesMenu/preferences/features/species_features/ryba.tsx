// Cechy akwarianina (rybka w kloszu). Wybór ryby to główna cecha z ikonami i nie potrzebuje tu wpisu.
import { Feature, FeatureColorInput } from '../base';

export const feature_aquarian_water: Feature<string> = {
  name: 'Zabarwienie wody',
  component: FeatureColorInput,
};

export const feature_aquarian_armor: Feature<string> = {
  name: 'Kolor pancerza',
  component: FeatureColorInput,
};
