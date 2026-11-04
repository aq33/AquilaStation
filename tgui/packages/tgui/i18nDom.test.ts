import { setDictionary, setLanguage } from './i18n';
import { setupDomTranslation } from './i18nDom';

const DICTIONARY = {
  version: 1,
  exact: {
    'skrzynka narzędziowa': 'toolbox',
    Szukaj: 'Search',
  },
  templates: [],
};

// Udaje store tgui: wystarczy subscribe i stan z config.language
const createStore = () => {
  let listener = () => {};
  let language = 'pl';
  return {
    subscribe: (fn: () => void) => {
      listener = fn;
    },
    getState: () => ({ backend: { config: { language } } }),
    setLanguage: (value: string) => {
      language = value;
      listener();
    },
  };
};

const flush = () => new Promise((resolve) => setTimeout(resolve, 0));

describe('setupDomTranslation', () => {
  beforeEach(() => {
    setLanguage('pl');
    setDictionary(DICTIONARY as any);
    document.body.innerHTML = '';
  });
  afterAll(() => setDictionary(null));

  it('tłumaczy teksty i placeholder, pomija pola i wraca na polski', async () => {
    document.body.innerHTML =
      '<div id="a">skrzynka narzędziowa</div><input id="b" placeholder="Szukaj"><textarea id="c">skrzynka narzędziowa</textarea>';
    const store = createStore();
    setupDomTranslation(store as any);
    store.setLanguage('en');
    await flush();
    expect(document.getElementById('a')!.textContent).toBe('toolbox');
    expect(document.getElementById('b')!.getAttribute('placeholder')).toBe(
      'Search',
    );
    expect(document.getElementById('c')!.textContent).toBe(
      'skrzynka narzędziowa',
    );

    // nowy węzeł dodany przez React po włączeniu
    const added = document.createElement('span');
    added.textContent = 'skrzynka narzędziowa';
    document.body.appendChild(added);
    await flush();
    expect(added.textContent).toBe('toolbox');

    store.setLanguage('pl');
    await flush();
    expect(document.getElementById('a')!.textContent).toBe(
      'skrzynka narzędziowa',
    );
    expect(document.getElementById('b')!.getAttribute('placeholder')).toBe(
      'Szukaj',
    );
  });
});
