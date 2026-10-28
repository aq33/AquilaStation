import { useEffect, useState } from 'react';
import { Tooltip } from 'tgui-core/components';

import { IconButton, MenuButton } from '../components';
import type { Page, ServerState } from '../EscapeMenu';

type Props = {
  serverState: ServerState;
  onNavigate: (page: Page) => void;
  onAction: (action: string) => void;
  onClose: () => void;
  showResources: boolean;
  onToggleResources: () => void;
};

const COLLAPSE_DURATION = 400;

export function HomePage({
  serverState,
  onNavigate,
  onAction,
  onClose,
  showResources,
  onToggleResources,
}: Props) {
  const [mounted, setMounted] = useState(false);
  const [collapsing, setCollapsing] = useState(false);

  useEffect(() => {
    if (showResources) {
      setMounted(true);
      setCollapsing(false);
    } else if (mounted) {
      setCollapsing(true);
      const timer = setTimeout(() => {
        setMounted(false);
        setCollapsing(false);
      }, COLLAPSE_DURATION);
      return () => clearTimeout(timer);
    }
  }, [showResources]);

  return (
    <>
      <div className="escape-menu__home-column">
        <div className="escape-menu__title">
          <div className="escape-menu__subtitle">Kolejny dzień na...</div>
          <div className="escape-menu__station-name">
            {serverState.stationName}
          </div>
        </div>
        <div className="escape-menu__buttons">
          <MenuButton onClick={onClose}>Wróć do gry</MenuButton>
          <MenuButton
            onClick={() => {
              onAction('character');
              onClose();
            }}
          >
            Postać
          </MenuButton>
          <MenuButton
            onClick={() => {
              onAction('settings');
              onClose();
            }}
          >
            Ustawienia
          </MenuButton>
          <MenuButton onClick={() => onNavigate('players')}>Gracze</MenuButton>
          <MenuButton onClick={() => onNavigate('help')}>Pomoc</MenuButton>
          <MenuButton
            onClick={() => onNavigate('admin')}
            tooltip={
              serverState.hasTicket
                ? 'Masz otwarte zgłoszenie do adminów'
                : undefined
            }
          >
            Pomoc admina
          </MenuButton>
          <MenuButton
            onClick={() => onNavigate('leave_body')}
            disabled={!serverState.canLeaveBody}
          >
            Opuść ciało
          </MenuButton>
          <MenuButton onClick={() => onNavigate('quit')}>Wyjdź</MenuButton>
        </div>
      </div>
      <div className="escape-menu__resources">
        {mounted && (
          <div
            className={
              'escape-menu__resource-list' +
              (collapsing ? ' escape-menu__resource-list--collapsing' : '')
            }
          >
            {serverState.resources.map((resource) => (
              <Tooltip
                key={resource.id}
                position="top"
                content={resource.tooltip}
              >
                <button
                  type="button"
                  className="escape-menu__resource-button"
                  onClick={() => onAction(`resource_${resource.id}`)}
                >
                  <IconButton iconClass={resource.icon || resource.id} />
                  <span className="escape-menu__resource-button-label">
                    {resource.label}
                  </span>
                </button>
              </Tooltip>
            ))}
          </div>
        )}
        <button
          type="button"
          className="escape-menu__resource-toggle"
          onClick={onToggleResources}
        >
          <IconButton iconClass="resources" />
          <span className="escape-menu__resource-label">Zasoby</span>
        </button>
      </div>
    </>
  );
}
