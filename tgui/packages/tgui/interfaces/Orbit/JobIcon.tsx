import { Box } from 'tgui-core/components';

import type { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
  realNameDisplay: boolean;
};

/** Zwraca klasę ikony ze spritesheetów job-icon / antag-hud, jeśli jest */
export function getIconClass(
  item: Observable | Antagonist,
  realNameDisplay: boolean,
): string | undefined {
  // AQUILA EDIT - zamiast DmIcon z tg używamy naszych spritesheetów (orbit.dm)
  if ('antag_icon' in item && item.antag_icon && !realNameDisplay) {
    return `antag-hud16x16 antag-hud-${item.antag_icon}`;
  }

  const roleIcon = realNameDisplay
    ? item.mind_role_icon || item.role_icon
    : item.role_icon;
  if (!roleIcon || roleIcon === 'hudunknown') {
    return;
  }

  return `job-icon16x16 job-icon-${roleIcon}`;
}

export function JobIcon(props: Props) {
  const { item, realNameDisplay } = props;
  const iconClass = getIconClass(item, realNameDisplay);

  return (
    <div className="JobIcon">
      {!!iconClass && <Box className={iconClass} />}
    </div>
  );
}
