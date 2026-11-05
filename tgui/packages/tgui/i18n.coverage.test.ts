/**
 * AQUILA: test pokrycia tłumaczenia okien (tools/i18n/ui_coverage.py).
 * Bez zmiennej I18N_COVERAGE (zwykłe `jest`) nic nie robi.
 */
import { readFileSync, writeFileSync } from 'fs';

import { setDictionary, translateUiText } from './i18n';

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
