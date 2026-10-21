import { useEffect, useReducer, useRef } from 'react';

import { playCloseSounds, playOpenSounds } from './audio';
import { AdminPage } from './pages/AdminPage';
import { HomePage } from './pages/HomePage';
import { LeaveBodyPage } from './pages/LeaveBodyPage';
import { PlayersPage } from './pages/PlayersPage';
import { QuitPage } from './pages/QuitPage';
import { updateScaling } from './scaling';

/** Kontrolka przeglądarki z menu (interface/skin.dmf). */
const MENU_CONTROL = 'mapwindow.escape_menu';

export type Page = 'home' | 'admin' | 'players' | 'leave_body' | 'quit';

export type PlayerInfo = {
  /** REF klienta po stronie serwera, do przełączania ignorowania. */
  ref: string;
  displayName: string;
  rank?: string | null;
  ping?: number;
  ignored: boolean;
  isSelf?: boolean;
};

export type ResourceLink = {
  id: string;
  /** Ikona ze spritesheetu, jeśli inna niż id. */
  icon?: string;
  label: string;
  tooltip: string;
};

export type ServerState = {
  stationName: string;
  roundId: string;
  mapName: string;
  mapWebmap: string | null;
  serverTime: string;
  shiftTime: string;
  timeDilation: string;
  canLeaveBody: boolean;
  canAdminHelp: boolean;
  canSeeNotes: boolean;
  hasTicket: boolean;
  resources: ResourceLink[];
  admins: PlayerInfo[];
  players: PlayerInfo[];
  ignoredOffline: string[];
  suicideIcon: string | null;
};

type State = {
  page: Page;
  isOpen: boolean;
  showResources: boolean;
  serverState: ServerState | null;
};

type Action =
  | { type: 'open' }
  | { type: 'close' }
  | { type: 'navigate'; page: Page }
  | { type: 'toggleResources' }
  | { type: 'serverUpdate'; state: Partial<ServerState> };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'open':
      return { ...state, isOpen: true };
    case 'close':
      return { ...state, isOpen: false, page: 'home', showResources: false };
    case 'navigate':
      return { ...state, page: action.page, showResources: false };
    case 'toggleResources':
      return { ...state, showResources: !state.showResources };
    case 'serverUpdate':
      return {
        ...state,
        serverState: { ...state.serverState!, ...action.state },
      };
  }
}

const initialState: State = {
  page: 'home',
  isOpen: false,
  showResources: false,
  serverState: null,
};

// Wiadomości od serwera przychodzą przez jeden Byond.subscribe w index.tsx.
// Zanim React podepnie obsługę, trzymamy je w kolejce.
type MessageHandler = (type: string, payload: any) => void;
let messageHandler: MessageHandler | null = null;
const pendingMessages: [string, any][] = [];

export function receiveMessage(type: string, payload: any) {
  if (messageHandler) {
    messageHandler(type, payload);
  } else {
    pendingMessages.push([type, payload]);
  }
}

function sendAction(action: string, payload?: Record<string, unknown>) {
  Byond.sendMessage('action', { action, ...payload });
}

let resizeFrozen = false;
export function isResizeFrozen() {
  return resizeFrozen;
}

function openMenu(dispatch: React.Dispatch<Action>) {
  Byond.winset(MENU_CONTROL, { 'is-visible': true });
  setTimeout(() => {
    resizeFrozen = false;
    updateScaling();
  }, 100);
  playOpenSounds();
  sendAction('opened');
  dispatch({ type: 'open' });
}

function closeMenu(dispatch: React.Dispatch<Action>) {
  resizeFrozen = true;
  Byond.winset(MENU_CONTROL, { 'is-visible': false });
  Byond.winset('map', { focus: true });
  playCloseSounds();
  sendAction('closed');
  dispatch({ type: 'close' });
}

export function EscapeMenu() {
  const [state, dispatch] = useReducer(reducer, initialState);
  const isOpenRef = useRef(false);
  isOpenRef.current = state.isOpen;

  useEffect(() => {
    const handler: MessageHandler = (type, payload) => {
      if (type === 'init' || type === 'state') {
        dispatch({ type: 'serverUpdate', state: payload });
        return;
      }
      if (type === 'toggle') {
        // Esc przy otwartym oknie mówienia tylko je zamyka (stan z embedded winget w makrze)
        if (!isOpenRef.current && payload?.say === 'true') {
          return;
        }
        if (isOpenRef.current) {
          closeMenu(dispatch);
        } else {
          openMenu(dispatch);
        }
      }
    };
    messageHandler = handler;
    for (const [type, payload] of pendingMessages.splice(0)) {
      handler(type, payload);
    }
    return () => {
      messageHandler = null;
    };
  }, []);

  if (!state.serverState) {
    return null;
  }

  const navigate = (page: Page) => dispatch({ type: 'navigate', page });

  const handleAction = (action: string, payload?: Record<string, unknown>) => {
    sendAction(action, payload);
  };

  const handleClose = () => closeMenu(dispatch);

  const refocusMap = () => {
    Byond.winset('map', { focus: true });
  };

  return (
    <div className="escape-menu" onClick={refocusMap}>
      <div className="escape-menu__overlay" />
      <div className="escape-menu__content">
        <Details serverState={state.serverState} />
        {state.page === 'home' && (
          <HomePage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
            onClose={handleClose}
            showResources={state.showResources}
            onToggleResources={() => dispatch({ type: 'toggleResources' })}
          />
        )}
        {state.page === 'admin' && (
          <AdminPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
            onClose={handleClose}
          />
        )}
        {state.page === 'players' && (
          <PlayersPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
          />
        )}
        {state.page === 'leave_body' && (
          <LeaveBodyPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
            onClose={handleClose}
          />
        )}
        {state.page === 'quit' && (
          <QuitPage onNavigate={navigate} onAction={handleAction} />
        )}
      </div>
    </div>
  );
}

function Details({ serverState }: { serverState: ServerState }) {
  return (
    <div className="escape-menu__details">
      <div>ID rundy: {serverState.roundId || 'Brak'}</div>
      <div>Czas serwera: {serverState.serverTime}</div>
      <div>Czas zmiany: {serverState.shiftTime}</div>
      <div>
        Mapa: {serverState.mapName || 'Wczytywanie...'}
        {!!serverState.mapWebmap && (
          <span
            className="escape-menu__details-link"
            onClick={() => Byond.command(`.url ${serverState.mapWebmap}`)}
          >
            {' (otwórz mapę)'}
          </span>
        )}
      </div>
      <div>Dylatacja czasu: {serverState.timeDilation}%</div>
    </div>
  );
}
