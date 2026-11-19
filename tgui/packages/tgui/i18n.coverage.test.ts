/**
 * AQUILA: test pokrycia tłumaczenia okien (tools/i18n/ui_coverage.py).
 * Bez zmiennej I18N_COVERAGE (zwykłe `jest`) nic nie robi.
 */
import { readFileSync, writeFileSync } from 'fs';
import { isValidElement, type ReactElement } from 'react';

import { setDictionary, setLanguage, t, translateUiText, ts, tt } from './i18n';

/** Polski tekst po tłumaczeniu: polskie litery albo częste polskie słowa (bez "do", "na" itp., które są też angielskie) */
const POLISH_LEFT =
  /[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]|(?<!\p{L})(?:aby|ani|bez|dla|jest|jak|lub|nie|oraz|się|już|przy|albo|że|czy|jeśli|można|brak|jesteś|masz|twój|twoja)(?!\p{L})/iu;

const input = process.env.I18N_COVERAGE;

(input ? it : it.skip)('teksty okien po angielsku', () => {
  setDictionary(
    JSON.parse(readFileSync('../strings/i18n/en_windows.json', 'utf8')),
  );
  const texts: { text: string; file: string; key: string }[] = JSON.parse(
    readFileSync(input!, 'utf8'),
  );
  const left = texts
    .map(({ text, file, key }) => ({
      text,
      file,
      key,
      en: translateUiText(text),
    }))
    .filter(({ en }) => POLISH_LEFT.test(en));
  writeFileSync(
    process.env.I18N_COVERAGE_OUT!,
    JSON.stringify(left, null, 1),
    'utf8',
  );
});

/** Tekst fragmentu z tt() */
const textOf = (node: unknown): string => {
  if (!isValidElement(node)) {
    return String(node ?? '');
  }
  const children = (node as ReactElement<{ children?: unknown }>).props
    .children;
  return (Array.isArray(children) ? children : [children]).map(textOf).join('');
};

/** Polskie zdanie tak, jak pokazałoby je okno bez tłumaczenia (fragmenty przeplecione wstawkami) */
const polishOf = (texts: string[], slots: string[]): string =>
  texts.reduce(
    (out, text, i) => out + text + (i < slots.length ? slots[i] : ''),
    '',
  );

/** Zdanie zostało po polsku: polskie litery lub słowa albo wynik bez zmiany. Wejście to same polskie
 * teksty, więc bez zmiany ("Mapa taktyczna", "Mapa sektora 7") też zostało po polsku */
const leftPolish = (item: { en: string; texts: string[]; slots: string[] }) =>
  POLISH_LEFT.test(item.en) || item.en === polishOf(item.texts, item.slots);

it('niezmienione zdanie bez ogonków liczy się jako nieprzetłumaczone', () => {
  const texts = ['Mapa sektora ', ''];
  const slots = ['7'];
  expect(leftPolish({ en: 'Mapa sektora 7', texts, slots })).toBe(true);
  expect(leftPolish({ en: 'Sector map 7', texts, slots })).toBe(false);
  expect(
    leftPolish({ en: 'Mapa taktyczna', texts: ['Mapa taktyczna'], slots: [] }),
  ).toBe(true);
});

const jsxInput = process.env.I18N_JSX;

(jsxInput ? it : it.skip)('teksty owinięte przy budowie po angielsku', () => {
  setDictionary(
    JSON.parse(readFileSync('../strings/i18n/en_windows.json', 'utf8')),
  );
  setLanguage('en');
  const items: {
    file: string;
    kind: string;
    texts: string[];
    slots: string[];
  }[] = JSON.parse(readFileSync(jsxInput!, 'utf8'));
  const left = items
    .map((item) => ({
      ...item,
      en:
        item.kind === 't'
          ? t(item.texts[0])
          : item.kind === 'ts'
            ? ts(item.texts, item.slots)
            : textOf(tt(item.texts, item.slots)),
    }))
    .filter(leftPolish);
  setLanguage('pl');
  writeFileSync(
    process.env.I18N_JSX_OUT!,
    JSON.stringify(left, null, 1),
    'utf8',
  );
});
