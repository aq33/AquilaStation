import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const windowflashing: FeatureToggle = {
  name: 'Miganie okna',
  category: 'UI',
  subcategory: 'Misc',
  description: multiline`
    Po włączeniu przy ważnych wydarzeniach ikona gry miga na pasku
    zadań.
  `,
  component: CheckboxInput,
};
