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
/** Język słownika (en, ru): tools/i18n/ui_coverage.py --lang */
const language = process.env.I18N_LANG || 'en';
const loadWindows = () => {
  setLanguage(language);
  setDictionary(
    JSON.parse(
      readFileSync(`../strings/i18n/${language}_windows.json`, 'utf8'),
    ),
    language,
  );
};

(input ? it : it.skip)('teksty okien w języku słownika', () => {
  loadWindows();
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

const jsxInput = process.env.I18N_JSX;

(jsxInput ? it : it.skip)(
  'teksty owinięte przy budowie w języku słownika',
  () => {
    loadWindows();
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
      .filter(({ en }) => POLISH_LEFT.test(en));
    setLanguage('pl');
    writeFileSync(
      process.env.I18N_JSX_OUT!,
      JSON.stringify(left, null, 1),
      'utf8',
    );
  },
);
