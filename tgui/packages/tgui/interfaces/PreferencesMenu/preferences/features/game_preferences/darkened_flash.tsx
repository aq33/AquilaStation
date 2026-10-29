import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const darkened_flash: FeatureToggle = {
  name: 'Przyciemnione oślepienie',
  category: 'GAMEPLAY',
  description: multiline`
    Po włączeniu oślepienie fleszem pokazuje ciemny ekran zamiast
    jasnego.
  `,
  component: CheckboxInput,
  important: true,
};
