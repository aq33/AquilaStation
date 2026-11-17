// Cechy ras z Monkestation2.0 (małpolud, floranin). Główne cechy z ikonami (ogon, liście) nie potrzebują tu wpisu.
import { Feature, FeatureColorInput, FeatureNumberInput } from '../base';

export const feature_floran_leaves_color: Feature<string> = {
  name: 'Kolor liści',
  component: FeatureColorInput,
};

export const feature_floran_hiss: Feature<number> = {
  name: 'Długość syku',
  component: FeatureNumberInput,
};
