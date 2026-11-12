import {
  isTranslating,
  setDictionary,
  setLanguage,
  translateHtml,
  translateUiText,
} from './i18n';

const RUSSIAN = {
  version: 2,
  exact: {
    'skrzynka narzędziowa': 'ящик для инструментов',
  },
  ui: {},
  templates: [
    ['podnosi', ['', ' podnosi ', '.'], [[0], ' поднимает ', [1, 'the'], '.']],
  ],
};

describe('i18n: zmiana języka', () => {
  afterEach(() => {
    setLanguage('pl');
    setDictionary(null);
  });

  it('tłumaczy po rosyjsku słownikiem rosyjskim, bez angielskich przedimków', () => {
    setLanguage('ru');
    setDictionary(RUSSIAN as any, 'ru');
    expect(isTranslating()).toBe(true);
    expect(translateUiText('skrzynka narzędziowa')).toBe(
      'ящик для инструментов',
    );
    expect(translateHtml('Jan podnosi skrzynka narzędziowa.')).toBe(
      'Jan поднимает ящик для инструментов.',
    );
  });

  it('zmiana z angielskiego na rosyjski wyrzuca angielski słownik', () => {
    setLanguage('en');
    setDictionary(
      {
        version: 2,
        exact: { 'skrzynka narzędziowa': 'toolbox' },
        ui: {},
        templates: [],
      } as any,
      'en',
    );
    expect(translateUiText('skrzynka narzędziowa')).toBe('toolbox');
    setLanguage('ru');
    // rosyjski słownik jeszcze nie doszedł: nic nie tłumaczymy (bez angielskiego zamiast rosyjskiego)
    expect(isTranslating()).toBe(false);
    expect(translateUiText('skrzynka narzędziowa')).toBe(
      'skrzynka narzędziowa',
    );
  });

  it('nieznany język to polski', () => {
    setLanguage('de');
    expect(isTranslating()).toBe(false);
  });
});
