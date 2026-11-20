// Cechy Voxa z Yogstation. Główne cechy z ikonami (łuski, pióra, znaczenia) nie potrzebują tu wpisu.
import { Feature, FeatureChoiced, FeatureColorInput } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const feature_vox_quills_color: Feature<string> = {
  name: 'Kolor piór',
  component: FeatureColorInput,
};

export const feature_vox_facial_quills_color: Feature<string> = {
  name: 'Kolor piór na twarzy',
  component: FeatureColorInput,
};

export const feature_vox_quills_gradient: FeatureChoiced = {
  name: 'Gradient piór',
  component: FeatureButtonedDropdownInput,
};

export const feature_vox_quills_gradient_color: Feature<string> = {
  name: 'Kolor gradientu piór',
  component: FeatureColorInput,
};

export const feature_vox_tail_markings_color: Feature<string> = {
  name: 'Kolor znaczeń ogona',
  component: FeatureColorInput,
};

export const feature_vox_mask: FeatureChoiced = {
  name: 'Maska na start',
  component: FeatureButtonedDropdownInput,
};

export const feature_vox_tank: FeatureChoiced = {
  name: 'Butla z azotem na start',
  component: FeatureButtonedDropdownInput,
};
