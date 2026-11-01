import { Feature, FeatureChoiced, FeatureColorInput } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const pda_theme: FeatureChoiced = {
  name: 'Motyw PDA',
  component: FeatureButtonedDropdownInput,
};

export const pda_classic_color: Feature<string> = {
  name: 'Kolor Thinktronic Classic',
  component: FeatureColorInput,
};
