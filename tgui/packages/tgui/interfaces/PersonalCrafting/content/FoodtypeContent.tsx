import { Icon, Stack, Tooltip } from 'tgui-core/components';

import { CAN_MAKE, TYPE_ICONS } from '../constants';
import { foodtypeName } from '../helpers';
import type { Diet } from '../types';

type Props = {
  craftableCount?: number;
  diet: Diet;
  type: string;
};

export function FoodtypeContent(props: Props) {
  const { type, diet, craftableCount } = props;
  let iconName = '',
    iconColor = '',
    iconTooltip = '';

  // We use iconName in the return to see if this went through.
  if (type !== CAN_MAKE && diet) {
    if (diet.liked_food.includes(type)) {
      iconName = 'face-laugh-beam';
      iconColor = 'good';
      iconTooltip = 'Lubisz to';
    } else if (diet.disliked_food.includes(type)) {
      iconName = 'face-tired';
      iconColor = 'average';
      iconTooltip = 'Nie lubisz tego';
    } else if (diet.toxic_food.includes(type)) {
      iconName = 'skull-crossbones';
      iconColor = 'bad';
      iconTooltip = 'Szkodzi ci';
    }
  }

  return (
    <Stack>
      <Stack.Item width="14px" textAlign="center">
        <Icon name={TYPE_ICONS[type] || 'circle'} />
      </Stack.Item>
      <Stack.Item grow style={{ textTransform: 'capitalize' }}>
        {foodtypeName(type)}
      </Stack.Item>
      <Stack.Item>
        {type === CAN_MAKE
          ? craftableCount
          : iconName && (
              <Tooltip content={iconTooltip}>
                <Icon name={iconName} color={iconColor} />
              </Tooltip>
            )}
      </Stack.Item>
    </Stack>
  );
}
