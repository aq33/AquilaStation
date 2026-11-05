import { BooleanLike } from 'common/react';

import { Button } from '../../../../../components';
import { Feature, FeatureValueProps } from '../base';

type FeatureToggleDeadminServerData = {
  forced: BooleanLike;
};

type FeatureToggleDeadmin = Feature<
  BooleanLike,
  boolean,
  FeatureToggleDeadminServerData
>;

const DeadminCheckboxInput = (
  props: FeatureValueProps<
    BooleanLike,
    boolean,
    FeatureToggleDeadminServerData
  >,
) => {
  const forced = props.serverData?.forced;
  return (
    <Button
      color="transparent"
      style={forced ? { backgroundColor: '#cc0000' } : undefined}
      tooltip={forced ? 'Wymuszone przez konfigurację serwera' : null}
      tooltipPosition="right"
      icon={
        forced ? 'minus-square-o' : props.value ? 'check-square-o' : 'square-o'
      }
      selected={!!forced || !!props.value}
      onClick={() => {
        if (!forced) {
          props.handleSetValue(!props.value);
        }
      }}
    />
  );
};

export const deadmin_always: FeatureToggleDeadmin = {
  name: 'Zawsze zrzucaj uprawnienia',
  category: 'ADMIN',
  subcategory: 'Deadmin',
  description: 'Czy zawsze zrzucasz uprawnienia admina, dołączając do rundy.',
  component: DeadminCheckboxInput,
  important: true,
};

export const deadmin_antagonist: FeatureToggleDeadmin = {
  name: 'Zrzucaj jako antagonista',
  category: 'ADMIN',
  subcategory: 'Deadmin',
  description:
    'Czy zawsze zrzucasz uprawnienia admina, dołączając do rundy jako antagonista.',
  component: DeadminCheckboxInput,
  important: true,
};

export const deadmin_position_head: FeatureToggleDeadmin = {
  name: 'Zrzucaj jako szef działu',
  category: 'ADMIN',
  subcategory: 'Deadmin',
  description:
    'Czy zawsze zrzucasz uprawnienia admina, dołączając do rundy jako szef działu.',
  component: DeadminCheckboxInput,
  important: true,
};

export const deadmin_position_security: FeatureToggleDeadmin = {
  name: 'Zrzucaj jako ochrona',
  category: 'ADMIN',
  subcategory: 'Deadmin',
  description:
    'Czy zawsze zrzucasz uprawnienia admina, dołączając do rundy jako ochrona.',
  component: DeadminCheckboxInput,
  important: true,
};

export const deadmin_position_silicon: FeatureToggleDeadmin = {
  name: 'Zrzucaj jako syntetyk',
  category: 'ADMIN',
  subcategory: 'Deadmin',
  description:
    'Czy zawsze zrzucasz uprawnienia admina, dołączając do rundy jako syntetyk.',
  component: DeadminCheckboxInput,
  important: true,
};
