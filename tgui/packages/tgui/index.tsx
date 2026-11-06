/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';

import { perf } from 'common/perf';
import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';

import { App } from './App';
import { setGlobalStore } from './backend';
import { setupGlobalEvents } from './events';
import { setupHotKeys } from './hotkeys';
import { selectWindowDictionary } from './i18n';
import { setupDomTranslation } from './i18nDom';
import { captureExternalLinks } from './links';
import { render } from './renderer';
import { configureStore } from './store';

perf.mark('inception', window.performance?.timeOrigin);
perf.mark('init');

const store = configureStore();

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setGlobalStore(store);

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // AQUILA: okna po angielsku dla gracza z językiem EN (i18nDom.ts, i18n-jsx.cjs). Przed
  // renderem, żeby aktualizacja z nowym językiem renderowała się już w nim
  selectWindowDictionary();
  setupDomTranslation(store);
  store.subscribe(() => render(<App />));

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept(['./debug', './layouts', './routes', './App'], () => {
      render(<App />);
    });
  }
}

setupApp();
