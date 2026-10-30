import { CheckboxInputInverse, Feature, FeatureToggle } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const hotkeys: FeatureToggle = {
  name: 'Klasyczne skróty klawiszowe',
  category: 'GAMEPLAY',
  description:
    'Po włączeniu wracają stare skróty klawiszowe, które używają paska wprowadzania zamiast okienek.',
  component: CheckboxInputInverse,
};

export const zone_select: Feature<string> = {
  name: 'Tryb celowania w części ciała',
  category: 'GAMEPLAY',
  description:
    'W trybie uproszczonym części ciała są połączone w 3 grupy: ręce, nogi i tułów/klatka piersiowa. Zalecane, jeśli nie masz klawiatury numerycznej albo wolisz prostsze sterowanie.',
  component: FeatureButtonedDropdownInput,
  important: true,
};
