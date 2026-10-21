import { BackButton } from '../components';
import type { Page, ServerState } from '../EscapeMenu';

type Props = {
  serverState: ServerState;
  onNavigate: (page: Page) => void;
  onAction: (action: string) => void;
  onClose: () => void;
};

export function LeaveBodyPage({
  serverState,
  onNavigate,
  onAction,
  onClose,
}: Props) {
  return (
    <>
      <BackButton onClick={() => onNavigate('home')} />
      <div className="escape-menu__leave-body">
        <button
          type="button"
          className="escape-menu__large-button"
          onClick={() => {
            onAction('suicide');
            onClose();
          }}
        >
          <div className="escape-menu__icon-button">
            <span className="escape-menu-icons96x96 leave-template" />
            {!!serverState.suicideIcon && (
              <img
                className="escape-menu__suicide-icon-overlay"
                src={`data:image/png;base64,${serverState.suicideIcon}`}
                alt=""
              />
            )}
          </div>
          <div className="escape-menu__large-button-label">Samobójstwo</div>
        </button>
        <button
          type="button"
          className="escape-menu__large-button"
          onClick={() => {
            onAction('ghost');
            onClose();
          }}
        >
          <div className="escape-menu__icon-button">
            <span className="escape-menu-icons96x96 leave-template" />
            <span className="escape-menu-icons96x96 leave-ghost escape-menu__icon-overlay" />
          </div>
          <div className="escape-menu__large-button-label">Duch</div>
        </button>
      </div>
    </>
  );
}
