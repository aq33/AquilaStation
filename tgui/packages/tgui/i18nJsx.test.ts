/**
 * AQUILA: teksty okien owijane przy budowie (tgui/i18n-jsx.cjs) i ich tłumaczenie (i18n.ts).
 */
import { isValidElement, type ReactElement } from 'react';

import { setDictionary, setLanguage, t, ts, tt } from './i18n';

const loader = require('../../i18n-jsx.cjs');

const collect = (source: string) =>
  loader
    .collect(source, 'Okno.tsx')
    .map(({ kind, texts, slots }) => ({ kind, texts, slots }));

describe('loader i18n-jsx', () => {
  it('liczy biały znak tekstu JSX jak React', () => {
    expect(loader.cleanJsxText('\n    Przeciągnij kartę ID, aby ')).toBe(
      'Przeciągnij kartę ID, aby ',
    );
    expect(loader.cleanJsxText(' ten\n      interfejs.\n    ')).toBe(
      ' ten interfejs.',
    );
    expect(loader.cleanJsxText('\n  \n')).toBe('');
  });

  it('składa zdanie z wstawkami i dzieli je na elemencie', () => {
    const source = `const A = () => (
      <Box>
        Przeciągnij kartę ID, aby {locked ? 'odblokować' : 'zablokować'} ten
        interfejs.<b>Uwaga</b> {count} szt.
      </Box>
    );`;
    expect(collect(source)).toEqual([
      {
        kind: 'tt',
        texts: ['Przeciągnij kartę ID, aby ', ' ten interfejs.'],
        slots: ["locked ? 'odblokować' : 'zablokować'"],
      },
      { kind: 'tt', texts: [' ', ' szt.'], slots: ['count'] },
      { kind: 't', texts: ['Uwaga'], slots: [] },
    ]);
  });

  it('owija napisy w wybranych atrybutach, a encje i klucze zostawia', () => {
    const source = `const A = () => (
      <Section title="Ciśnienie" color="bad" tooltip={\`Stan: \${x}\`}>
        Coś&nbsp;tam
      </Section>
    );`;
    const out = loader.transform(source, 'Okno.tsx');
    expect(out).toContain('title={__i18nT("Ciśnienie")}');
    expect(out).toContain('color="bad"');
    expect(out).toContain('tooltip={__i18nTS(["Stan: ",""], [x])}');
    expect(out).toContain('Coś&nbsp;tam');
  });

  it('nie rusza pliku bez tekstów', () => {
    const source = 'const A = () => <Box>{data.value}</Box>;';
    expect(loader.transform(source, 'Okno.tsx')).toBe(source);
  });
});

const DICTIONARY = {
  version: 2,
  exact: { odblokować: 'unlock', Ciśnienie: 'Pressure' },
  ui: {},
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
    ['stan', ['Stan: ', ''], ['Status: ', [0]]],
  ],
};

/** Tekst fragmentu z tt() (sklejone dzieci) */
const textOf = (node: unknown): string => {
  if (!isValidElement(node)) {
    return String(node ?? '');
  }
  const children = (node as ReactElement<{ children?: unknown }>).props
    .children;
  return (Array.isArray(children) ? children : [children]).map(textOf).join('');
};

describe('t, tt, ts', () => {
  beforeEach(() => setDictionary(DICTIONARY as any));
  afterEach(() => setLanguage('pl'));
  afterAll(() => setDictionary(null));

  it('dla gracza z PL nic nie zmienia', () => {
    setLanguage('pl');
    expect(t('Ciśnienie')).toBe('Ciśnienie');
    expect(
      textOf(
        tt(['Przeciągnij kartę ID, aby ', ' ten interfejs.'], ['zablokować']),
      ),
    ).toBe('Przeciągnij kartę ID, aby zablokować ten interfejs.');
    expect(ts(['Stan: ', ''], [3])).toBe('Stan: 3');
  });

  it('tłumaczy zdanie z gałęzią warunku i zachowuje spacje na brzegach', () => {
    setLanguage('en');
    expect(t('Ciśnienie')).toBe('Pressure');
    expect(
      textOf(
        tt([' Przeciągnij kartę ID, aby ', ' ten interfejs. '], ['zablokować']),
      ),
    ).toBe(' Swipe an ID card to lock this interface. ');
    expect(ts(['Stan: ', ''], ['odblokować'])).toBe('Status: unlock');
  });

  it('bez szablonu w słowniku zostawia polskie zdanie', () => {
    setLanguage('en');
    expect(textOf(tt(['Nieznane ', ' zdanie'], [5]))).toBe('Nieznane 5 zdanie');
    expect(ts(['Inne ', ''], [null])).toBe('Inne null');
  });
});
