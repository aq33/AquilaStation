import type { ReactNode } from 'react';
import { Tooltip } from 'tgui-core/components';

export function IconButton({ iconClass }: { iconClass: string }) {
  return (
    <div className="escape-menu__icon-button">
      <span className="escape-menu-icons40x40 template" />
      <span
        className={`escape-menu-icons40x40 ${iconClass} escape-menu__icon-overlay`}
      />
    </div>
  );
}

export function BackButton({ onClick }: { onClick: () => void }) {
  return (
    <button
      type="button"
      className="escape-menu__back-button"
      onClick={onClick}
    >
      <IconButton iconClass="back" />
      <span>Wróć</span>
    </button>
  );
}

type MenuButtonProps = {
  children: ReactNode;
  onClick: () => void;
  disabled?: boolean;
  tooltip?: string;
};

export function MenuButton({
  children,
  onClick,
  disabled,
  tooltip,
}: MenuButtonProps) {
  const button = (
    <button
      type="button"
      className={
        'escape-menu__menu-button' +
        (disabled ? ' escape-menu__menu-button--disabled' : '')
      }
      onClick={disabled ? undefined : onClick}
    >
      {children}
    </button>
  );

  if (tooltip) {
    return <Tooltip content={tooltip}>{button}</Tooltip>;
  }

  return button;
}
