import { CheckboxInput, FeatureToggle } from '../base';

export const antag_target_opt_in: FeatureToggle = {
  name: 'Chcę być celem antagonistów',
  description:
    'Gdy antagonista losuje cel (zabójstwo, porwanie, ochrona i inne), w pierwszej kolejności wybiera graczy, których postać ma tę opcję.',
  component: CheckboxInput,
};
