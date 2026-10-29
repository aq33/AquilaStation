import { FeatureChoiced } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const body_model: FeatureChoiced = {
  name: 'Typ ciała',
  component: FeatureButtonedDropdownInput,
};

export const body_size: FeatureChoiced = {
  name: 'Rozmiar ciała',
  component: FeatureButtonedDropdownInput,
};
