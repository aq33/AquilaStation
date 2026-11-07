import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

// AQUILA - tgstation/tgstation#89865 (rds_limit); u nas preferencja gracza
export const rds_unlimited: FeatureToggle = {
  name: 'Halucynacje bez limitu',
  category: 'GAMEPLAY',
  description: multiline`
    Dotyczy cechy Zaburzenia Dysocjacyjne. Halucynacje będą częstsze, bardziej natrętne i (zwykle) dziwaczniejsze.
  `,
  component: CheckboxInput,
};
