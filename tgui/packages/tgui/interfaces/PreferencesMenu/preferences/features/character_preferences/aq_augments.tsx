// AQUILA - augmentacje wybierane w lobby (aquila/code/modules/robotics/lobby_augments.dm)
import { FeatureChoiced } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

const limbDescription =
  'Proteza zakładana od startu rundy. Marki różnią się wyglądem i cechami, kinetyczna nie pozwala strzelać, zaawansowana jest najmocniejsza.';

const organDescription =
  'Organ wymieniany od startu rundy na cybernetyczny. Cybernetyka obciąża psychikę (cyberpsychoza).';

export const aq_aug_l_arm: FeatureChoiced = {
  name: 'Lewa ręka',
  description: limbDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_r_arm: FeatureChoiced = {
  name: 'Prawa ręka',
  description: limbDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_l_leg: FeatureChoiced = {
  name: 'Lewa noga',
  description: limbDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_r_leg: FeatureChoiced = {
  name: 'Prawa noga',
  description: limbDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_heart: FeatureChoiced = {
  name: 'Serce',
  description: organDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_lungs: FeatureChoiced = {
  name: 'Płuca',
  description: organDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_liver: FeatureChoiced = {
  name: 'Wątroba',
  description: organDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_stomach: FeatureChoiced = {
  name: 'Żołądek',
  description: organDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_eyes: FeatureChoiced = {
  name: 'Oczy',
  description: organDescription,
  component: FeatureButtonedDropdownInput,
};

export const aq_aug_ears: FeatureChoiced = {
  name: 'Uszy',
  description: organDescription,
  component: FeatureButtonedDropdownInput,
};
