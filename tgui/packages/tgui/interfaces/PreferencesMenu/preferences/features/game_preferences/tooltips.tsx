import { multiline } from 'common/string';

import {
  CheckboxInput,
  Feature,
  FeatureNumberInput,
  FeatureToggle,
} from '../base';

export const enable_tips: FeatureToggle = {
  name: 'Podpowiedzi',
  category: 'UI',
  subcategory: 'Tooltips',
  description: multiline`
    Czy chcesz widzieć podpowiedzi po najechaniu kursorem na przedmiot?
  `,
  component: CheckboxInput,
};

export const tip_delay: Feature<number> = {
  name: 'Opóźnienie podpowiedzi (ms)',
  category: 'UI',
  subcategory: 'Tooltips',
  description: multiline`
    Po jakim czasie od najechania na przedmiot ma się pojawić podpowiedź?
  `,
  component: FeatureNumberInput,
};
