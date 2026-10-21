import type { ReactNode } from 'react';

import { BackButton } from '../components';
import type { Page, PlayerInfo, ServerState } from '../EscapeMenu';

type Props = {
  serverState: ServerState;
  onNavigate: (page: Page) => void;
  onAction: (action: string, payload?: Record<string, unknown>) => void;
};

export function PlayersPage({ serverState, onNavigate, onAction }: Props) {
  return (
    <>
      <BackButton onClick={() => onNavigate('home')} />
      <div className="escape-menu__player-list">
        {serverState.admins.length > 0 ? (
          <PlayerSection title="Admini">
            {serverState.admins.map((admin) => (
              <PlayerEntry
                key={admin.ref}
                player={admin}
                onToggleIgnore={() =>
                  onAction('toggle_ignore', { ref: admin.ref })
                }
              />
            ))}
          </PlayerSection>
        ) : (
          <div className="escape-menu__player-section-title">
            Brak adminów online!
          </div>
        )}
        <PlayerSection title={`Gracze (${serverState.players.length})`}>
          {serverState.players.map((player) => (
            <PlayerEntry
              key={player.ref}
              player={player}
              onToggleIgnore={() =>
                onAction('toggle_ignore', { ref: player.ref })
              }
            />
          ))}
        </PlayerSection>
        {serverState.ignoredOffline.length > 0 && (
          <PlayerSection title="Ignorowani (offline)">
            {serverState.ignoredOffline.map((key) => (
              <div
                key={key}
                className="escape-menu__player-entry escape-menu__player-entry--ignored"
              >
                <span
                  className="escape-menu__player-name"
                  onClick={() => onAction('toggle_ignore', { key })}
                >
                  {key}
                </span>
              </div>
            ))}
          </PlayerSection>
        )}
        <div className="escape-menu__player-hint">
          Kliknij gracza, żeby ignorować jego wiadomości OOC (albo przestać).
        </div>
      </div>
    </>
  );
}

function PlayerSection({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}) {
  return (
    <div className="escape-menu__player-section">
      <div className="escape-menu__player-section-title">{title}</div>
      <div className="escape-menu__player-grid">{children}</div>
    </div>
  );
}

function PlayerEntry({
  player,
  onToggleIgnore,
}: {
  player: PlayerInfo;
  onToggleIgnore: () => void;
}) {
  return (
    <div
      className={
        'escape-menu__player-entry' +
        (player.ignored ? ' escape-menu__player-entry--ignored' : '')
      }
    >
      <span
        className="escape-menu__player-name"
        onClick={player.isSelf ? undefined : onToggleIgnore}
      >
        {player.displayName}
        {player.ping !== undefined && (
          <span className="escape-menu__player-ping"> ({player.ping} ms)</span>
        )}
      </span>
      {!!player.rank && (
        <span className="escape-menu__player-rank">{player.rank}</span>
      )}
    </div>
  );
}
