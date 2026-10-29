import { BackButton } from '../components';
import type { ControlSection, Page, ServerState } from '../EscapeMenu';

type Props = {
  serverState: ServerState;
  onNavigate: (page: Page) => void;
};

/** Sterowanie, którego nie da się przepisać w ustawieniach klawiszy. */
const FIXED_SECTIONS: ControlSection[] = [
  {
    title: 'Mysz',
    entries: [
      { name: 'Użyj, podnieś, zaatakuj', keys: ['Lewy przycisk'] },
      {
        name: 'Akcja dodatkowa (np. rozbrojenie w trybie walki)',
        keys: ['Prawy przycisk'],
      },
      { name: 'Obejrzyj', keys: ['Shift + klik'] },
      { name: 'Ciągnij', keys: ['Ctrl + klik'] },
      { name: 'Akcja alternatywna przedmiotu', keys: ['Alt + klik'] },
      { name: 'Zamień ręce', keys: ['Środkowy przycisk'] },
      { name: 'Wskaż', keys: ['Shift + środkowy przycisk'] },
    ],
  },
  {
    title: 'Czat',
    entries: [
      { name: 'Mów', keys: ['T'] },
      { name: 'Emotka (Me)', keys: ['M'] },
      { name: 'Radio', keys: ['Y'] },
      { name: 'OOC', keys: ['O'] },
      { name: 'LOOC', keys: ['L'] },
      { name: 'Zmień kanał w oknie czatu', keys: ['Tab'] },
      {
        name: 'Zamknij okna i koła wyboru, potem to menu',
        keys: ['Esc'],
      },
    ],
  },
];

export function HelpPage({ serverState, onNavigate }: Props) {
  const sections = [...FIXED_SECTIONS, ...(serverState.controls || [])];
  return (
    <>
      <BackButton onClick={() => onNavigate('home')} />
      <div className="escape-menu__player-list">
        {sections.map((section) => (
          <div key={section.title} className="escape-menu__player-section">
            <div className="escape-menu__player-section-title">
              {section.title}
            </div>
            <div className="escape-menu__help-grid">
              {section.entries.map((entry) => (
                <div key={entry.name} className="escape-menu__help-entry">
                  <span className="escape-menu__help-name">{entry.name}</span>
                  <span className="escape-menu__help-keys">
                    {entry.keys.join(', ')}
                  </span>
                </div>
              ))}
            </div>
          </div>
        ))}
        <div className="escape-menu__player-hint">
          Klawisze zmienisz w Ustawieniach, zakładka „Klawisze”.
        </div>
      </div>
    </>
  );
}
