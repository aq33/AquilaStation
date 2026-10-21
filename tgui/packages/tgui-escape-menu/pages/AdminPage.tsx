import { BackButton, MenuButton } from '../components';
import type { Page, ServerState } from '../EscapeMenu';

type Props = {
  serverState: ServerState;
  onNavigate: (page: Page) => void;
  onAction: (action: string) => void;
  onClose: () => void;
};

export function AdminPage({
  serverState,
  onNavigate,
  onAction,
  onClose,
}: Props) {
  return (
    <>
      <BackButton onClick={() => onNavigate('home')} />
      <div className="escape-menu__buttons escape-menu__buttons--page">
        <MenuButton
          onClick={() => {
            onAction('create_ticket');
            onClose();
          }}
          disabled={!serverState.canAdminHelp}
          tooltip={
            serverState.canAdminHelp
              ? undefined
              : 'Adminhelp jest chwilowo niedostępny'
          }
        >
          {serverState.hasTicket ? 'Napisz do adminów' : 'Utwórz zgłoszenie'}
        </MenuButton>
        <MenuButton
          onClick={() => {
            onAction('admin_notice');
            onClose();
          }}
        >
          Ogłoszenia adminów
        </MenuButton>
        <MenuButton
          onClick={() => {
            onAction('pray');
            onClose();
          }}
        >
          Módl się
        </MenuButton>
        {!!serverState.canSeeNotes && (
          <MenuButton
            onClick={() => {
              onAction('see_notes');
              onClose();
            }}
          >
            Moje notatki
          </MenuButton>
        )}
      </div>
    </>
  );
}
