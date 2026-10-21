import type { Page } from '../EscapeMenu';

type Props = {
  onNavigate: (page: Page) => void;
  onAction: (action: string) => void;
};

export function QuitPage({ onNavigate, onAction }: Props) {
  return (
    <div className="escape-menu__quit">
      <div className="escape-menu__quit-prompt">
        Na pewno chcesz wyjść z gry?
      </div>
      <div className="escape-menu__quit-buttons">
        <button
          type="button"
          className="escape-menu__menu-button"
          onClick={() => onAction('quit')}
        >
          Tak
        </button>
        <button
          type="button"
          className="escape-menu__menu-button"
          onClick={() => onNavigate('home')}
        >
          Nie
        </button>
      </div>
    </div>
  );
}
