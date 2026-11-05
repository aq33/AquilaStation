import { setDictionary, setLanguage } from './i18n';
import { setupDomTranslation } from './i18nDom';

const DICTIONARY = {
  version: 1,
  exact: {
    'skrzynka narzędziowa': 'toolbox',
    Szukaj: 'Search',
    Wróć: 'Recall',
    odblokować: 'unlock',
    zablokować: 'lock',
    Ciśnienie: 'Pressure',
  },
  // teksty z kodu okien mają w oknach pierwszeństwo
  ui: { Wróć: 'Back' },
  templates: [
    [
      'przeciągnij',
      ['Przeciągnij kartę ID, aby ', ' ten interfejs.'],
      [
        'Swipe an ID card to ',
        ['?', 0, ['unlock', 'lock']],
        ' this interface.',
      ],
      { '0': ['odblokować', 'zablokować'] },
    ],
  ],
};

/** Element z kilkoma węzłami tekstowymi, jak robi je React ze zdania z wstawką */
const textNodes = (...parts: string[]) => {
  const el = document.createElement('div');
  const nodes = parts.map((part) => document.createTextNode(part));
  nodes.forEach((node) => el.appendChild(node));
  document.body.appendChild(el);
  return { el, nodes };
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
      '<div id="a">skrzynka narzędziowa</div><button id="d">Wróć</button><input id="b" placeholder="Szukaj"><textarea id="c">skrzynka narzędziowa</textarea>';
    const store = createStore();
    setupDomTranslation(store as any);
    store.setLanguage('en');
    await flush();
    expect(document.getElementById('a')!.textContent).toBe('toolbox');
    expect(document.getElementById('d')!.textContent).toBe('Back');
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

    // React wpisuje nowy placeholder bez tłumaczenia: powrót na PL go nie nadpisze
    const other = document.createElement('input');
    other.setAttribute('placeholder', 'Szukaj');
    document.body.appendChild(other);
    await flush();
    other.setAttribute('placeholder', 'Coś nowego');
    await flush();

    store.setLanguage('pl');
    await flush();
    expect(document.getElementById('a')!.textContent).toBe(
      'skrzynka narzędziowa',
    );
    expect(document.getElementById('b')!.getAttribute('placeholder')).toBe(
      'Szukaj',
    );
    expect(other.getAttribute('placeholder')).toBe('Coś nowego');
  });

  it('tłumaczy zdanie przecięte wstawką i etykietę z dwukropkiem', async () => {
    const sentence = textNodes(
      'Przeciągnij kartę ID, aby ',
      'odblokować',
      ' ten interfejs.',
    );
    const label = textNodes('Ciśnienie:');
    // nieznane zdanie ze znanym słowem w środku: bez mieszania języków
    const unknown = textNodes('Kliknij, aby ', 'odblokować', ' drzwi.');
    const store = createStore();
    setupDomTranslation(store as any);
    store.setLanguage('en');
    await flush();
    expect(sentence.el.textContent).toBe(
      'Swipe an ID card to unlock this interface.',
    );
    expect(label.el.textContent).toBe('Pressure:');
    expect(unknown.el.textContent).toBe('Kliknij, aby odblokować drzwi.');

    // React zmienia tylko węzeł wstawki
    sentence.nodes[1].nodeValue = 'zablokować';
    await flush();
    expect(sentence.el.textContent).toBe(
      'Swipe an ID card to lock this interface.',
    );

    store.setLanguage('pl');
    await flush();
    expect(sentence.el.textContent).toBe(
      'Przeciągnij kartę ID, aby zablokować ten interfejs.',
    );
    expect(sentence.nodes.map((node) => node.nodeValue)).toEqual([
      'Przeciągnij kartę ID, aby ',
      'zablokować',
      ' ten interfejs.',
    ]);
    expect(label.el.textContent).toBe('Ciśnienie:');
  });

  it('pomija czat i treść pisaną przez graczy', async () => {
    document.body.innerHTML =
      '<div id="ui">skrzynka narzędziowa</div>' +
      '<div data-i18n-skip=""><span id="chat">skrzynka narzędziowa</span></div>' +
      '<div class="Paper__Page i18n-skip"><p id="paper">skrzynka narzędziowa</p></div>';
    const store = createStore();
    setupDomTranslation(store as any);
    store.setLanguage('en');
    await flush();
    expect(document.getElementById('ui')!.textContent).toBe('toolbox');
    expect(document.getElementById('chat')!.textContent).toBe(
      'skrzynka narzędziowa',
    );
    expect(document.getElementById('paper')!.textContent).toBe(
      'skrzynka narzędziowa',
    );
    // nowa wiadomość w czacie po włączeniu też zostaje
    const message = document.createElement('div');
    message.textContent = 'skrzynka narzędziowa';
    document.querySelector('[data-i18n-skip]')!.appendChild(message);
    await flush();
    expect(message.textContent).toBe('skrzynka narzędziowa');
    store.setLanguage('pl');
    await flush();
  });
});
