/**
 * AQUILA: angielska wersja językowa (czat w panelu i okna tgui).
 *
 * Serwer wysyła teksty po polsku. Gracz z językiem EN dostaje słownik
 * i18n_en_chat.json (tools/i18n/build_chat_dict.py), a klient podmienia tekst
 * przy wyświetlaniu: szablony z osadzeniami ("[user] uderza [target]!") i stałe
 * teksty. Czat robi to w rendererze (zapisana historia zostaje po polsku, więc
 * zmiana języka działa też wstecz), okna tgui w i18nDom.ts.
 */

import { resolveAsset } from './assets';

/**
 * Element angielskiej strony: tekst, [nr osadzenia PL, przedimek?] albo
 * ["?", nr osadzenia PL, [EN dla alternatywy A, EN dla B]] (gałąź warunku).
 */
type EnPart =
  | string
  | [number]
  | [number, string]
  | ['?', number, [string, string]];
/** Alternatywy osadzeń: nr osadzenia -> [A, B] z [warunek ? "A" : "B"] */
type Alternatives = Record<string, [string, string]>;
/** [kotwica albo kotwice, stałe fragmenty PL, części EN, alternatywy?] */
type Template =
  | [string | string[], string[], EnPart[]]
  | [string | string[], string[], EnPart[], Alternatives];

type Dictionary = {
  version: number;
  exact: Record<string, string>;
  /** Stałe z kodu okien: w oknach mają pierwszeństwo przed exact */
  ui?: Record<string, string>;
  templates: Template[];
};

const DICTIONARY_ASSET = 'i18n_en_chat.json';
// od dwóch liter: "ma", "na" bywają jedynym słowem szablonu (jak w build_chat_dict.py)
const WORD = /[a-ząćęłńóśźż]{2,}/g;
const TEXT_NODE = />([^<>]+)</g;

let language = 'pl';
let dictionary: Dictionary | null = null;
let loading: Promise<boolean> | null = null;
let byAnchor = new Map<string, number[]>();
const regexCache = new Map<number, RegExp | null>();

export const getLanguage = () => language;

/** Czy panel ma teraz pokazywać angielski (wybrany EN i słownik wczytany) */
export const isTranslating = () => language === 'en' && dictionary !== null;

export const setLanguage = (lang: string) => {
  language = lang === 'en' ? 'en' : 'pl';
};

/** Ile razy próbujemy pobrać słownik (łącznie około 2 minut) */
const FETCH_ATTEMPTS = 30;
const FETCH_MAX_DELAY = 5000;

const fetchDictionary = async (): Promise<Dictionary | null> => {
  // Plik (~9 MB) dochodzi do cache klienta po mapowaniu, przy wolnym łączu nawet
  // kilkadziesiąt sekund, więc próbujemy długo i z rosnącą przerwą
  for (let attempt = 0; attempt < FETCH_ATTEMPTS; attempt++) {
    try {
      const response = await fetch(resolveAsset(DICTIONARY_ASSET));
      if (response.ok) {
        return (await response.json()) as Dictionary;
      }
    } catch {
      // jeszcze nie ma pliku
    }
    const delay = Math.min(1000 * 1.5 ** attempt, FETCH_MAX_DELAY);
    await new Promise((resolve) => setTimeout(resolve, delay));
  }
  return null;
};

/** Ustawia słownik i indeks słów-kotwic (też w testach) */
export const setDictionary = (data: Dictionary | null) => {
  // Bez prototypu: tekst "constructor" czy "toString" nie może trafić na funkcję Object
  if (data) {
    Object.setPrototypeOf(data.exact, null);
    if (data.ui) {
      Object.setPrototypeOf(data.ui, null);
    }
  }
  dictionary = data;
  byAnchor = new Map();
  regexCache.clear();
  data?.templates.forEach(([anchors], index) => {
    for (const anchor of Array.isArray(anchors) ? anchors : [anchors]) {
      const list = byAnchor.get(anchor);
      if (list) {
        list.push(index);
      } else {
        byAnchor.set(anchor, [index]);
      }
    }
  });
};

/** Wczytuje słownik (raz). Zwraca TRUE, gdy jest gotowy. */
export const loadDictionary = (): Promise<boolean> => {
  if (dictionary) {
    return Promise.resolve(true);
  }
  if (!loading) {
    loading = fetchDictionary().then((data) => {
      loading = null;
      if (!data) {
        return false;
      }
      setDictionary(data);
      return true;
    });
  }
  return loading;
};

const NO_ALTERNATIVES: Alternatives = {};

const alternativesOf = (index: number): Alternatives =>
  (dictionary!.templates[index][3] as Alternatives | undefined) ??
  NO_ALTERNATIVES;

const escapeRegex = (text: string) =>
  text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/\s+/g, '\\s+');

/**
 * Wyrażenie dla szablonu. Osadzenie na początku lub końcu nie wychodzi poza
 * węzeł tekstowy, osadzenie w środku może zawierać znaczniki.
 */
const templateRegex = (index: number): RegExp | null => {
  if (regexCache.has(index)) {
    return regexCache.get(index)!;
  }
  const texts = dictionary!.templates[index][1];
  const alts = alternativesOf(index);
  let source = '';
  texts.forEach((text, i) => {
    if (i > 0) {
      const edgeStart = i === 1 && texts[0] === '';
      const edgeEnd = i === texts.length - 1 && text === '';
      const options = alts[i - 1];
      if (options) {
        // [warunek ? "A" : "B"]: jedna z dwóch wartości, dłuższa najpierw
        source +=
          '(' +
          [...options]
            .sort((a, b) => b.length - a.length)
            .map(escapeRegex)
            .join('|') +
          ')';
      } else if (edgeStart) {
        source += '([^<>\\n]*?)';
      } else if (edgeEnd) {
        source += '([^<>\\n]*)';
      } else {
        source += '([\\s\\S]*?)';
      }
    }
    // odstępy na skrajach szablonu ("...: [n].\n") łapie kotwica, linia po podziale ich nie ma
    let edge = text;
    if (i === 0) {
      edge = edge.replace(/^\s+/, '');
    }
    if (i === texts.length - 1) {
      edge = edge.replace(/\s+$/, '');
    }
    source += escapeRegex(edge);
  });
  let regex: RegExp | null = null;
  try {
    // Szablon musi objąć cały węzeł tekstowy (od ">" do "<"). Inaczej krótki
    // ogólny szablon ("[a] jest [b]") wchodzi w środek zdania, którego
    // szablonu nie ma, i robi mieszankę języków.
    // Granicą jest też nowa linia: examine skleja linie (każda ze swoim <span>) znakiem \n.
    regex = new RegExp(
      '(?<=(?:^|>|\\n)[^\\S\\n]*)' + source + '(?=[^\\S\\n]*(?:<|$|\\n))',
      'g',
    );
  } catch {
    regex = null;
  }
  regexCache.set(index, regex);
  return regex;
};

/** Ile razy tłumaczymy wartości wstawione w szablon (wartość też bywa złożona) */
const MAX_DEPTH = 2;

/**
 * Wartość wstawiona w szablon: nazwa ("kubek" -> "mug") albo złożony
 * kawałek (" w klatkę piersiową", komunikat emotki).
 */
const translateValue = (value: string, depth: number): string => {
  const trimmed = value.trim();
  if (!trimmed) {
    return value;
  }
  const found = lookupExact(trimmed);
  if (found !== undefined) {
    return value.replace(trimmed, found);
  }
  const list = translateList(trimmed);
  if (list !== undefined) {
    return value.replace(trimmed, list);
  }
  return depth < MAX_DEPTH ? translateHtml(value, depth + 1) : value;
};

/** Element listy: opcjonalna liczba z przodu ("2 szkło", "1x kondensator") i nazwa */
const LIST_ITEM = /^(\d+(?:[.,]\d+)?\s*(?:x\s*)?)?(.+)$/;

/**
 * Lista składana w kodzie (english_list po polsku): "1 szkło, 2 kondensator i
 * 1 zwój kabla". Każdy element osobno, tylko gdy wszystkie mają tłumaczenie.
 */
const translateList = (text: string): string | undefined => {
  // nazwa z dopiskiem w nawiasie ("zakrzywiający ekstrakt (żółty)"): obie części osobno
  const suffix = /^(.+?)\s*\(([^()]+)\)$/.exec(text);
  if (suffix) {
    const head =
      lookupExact(suffix[1].trim()) ?? translateList(suffix[1].trim());
    const tail =
      lookupExact(suffix[2].trim()) ?? translateList(suffix[2].trim());
    if (head !== undefined && tail !== undefined) {
      return `${head} (${tail})`;
    }
  }
  if (!/,| i | oraz /.test(text)) {
    // pojedynczy element z liczbą ("1 zasobnik materii")
    const single = /^(\d+(?:[.,]\d+)?\s*(?:x\s*)?)(\D.*)$/.exec(text);
    const name = single && lookupExact(single[2].trim());
    return single && name !== undefined ? single[1] + name : undefined;
  }
  const parts = text.split(/,\s*|\s+(?:i|oraz)\s+/);
  if (parts.length < 2) {
    return undefined;
  }
  const items: string[] = [];
  for (const part of parts) {
    const m = LIST_ITEM.exec(part.trim());
    const name = m && lookupExact(m[2].trim());
    if (!m || name === undefined) {
      return undefined;
    }
    items.push((m[1] || '') + name);
  }
  return items.length === 2
    ? `${items[0]} and ${items[1]}`
    : `${items.slice(0, -1).join(', ')}, and ${items[items.length - 1]}`;
};

/**
 * Stały tekst ze słownika. Kod często dokleja znak końca zdania albo
 * dwukropek sam (emotki: "krzyczy" + "."), więc szukamy też bez niego.
 */
const lookupExact = (text: string): string | undefined => {
  const found = lookupCased(text);
  if (found !== undefined || !text) {
    return found;
  }
  // BYOND dokleja "the" przed wstawionym obiektem ("the dysk R.O.B.U.S.T."):
  // tłumaczymy samą nazwę, przedimek zostaje
  const article = /^(the|The) (.+)$/.exec(text);
  if (article) {
    const name = lookupExact(article[2]);
    if (name !== undefined) {
      return `${article[1]} ${name}`;
    }
  }
  // etykiety w oknach dostają dwukropek w JSX ("Ciśnienie:"), słownik ma samo słowo
  const last = text.charAt(text.length - 1);
  if ('.!?:'.includes(last)) {
    const base = lookupCased(text.slice(0, -1));
    if (base !== undefined) {
      return /[.!?:]$/.test(base) ? base : base + last;
    }
  }
  return undefined;
};

/**
 * Stała z tolerancją wielkości pierwszej litery: okna i kod często piszą nazwę
 * małą literą ("amoniak" z "Amoniak"). Wynik dostaje wielkość litery tekstu.
 */
const lookupCased = (text: string): string | undefined => {
  const exact = dictionary!.exact;
  const found = exact[text];
  if (found !== undefined || !text) {
    return found;
  }
  const first = text.charAt(0);
  const lower = first.toLowerCase();
  const swapped =
    (first === lower ? first.toUpperCase() : lower) + text.slice(1);
  const other = exact[swapped];
  if (other === undefined || !other) {
    return other;
  }
  const head = other.charAt(0);
  return (
    (first === lower ? head.toLowerCase() : head.toUpperCase()) + other.slice(1)
  );
};

const isKnown = (value: string) =>
  lookupExact(value.trim()) !== undefined ||
  translateList(value.trim()) !== undefined;

/**
 * Ile nierozpoznanego tekstu (liter w słowach pisanych małą literą) może
 * zostać w wartościach na jedną literę tekstu rozpoznanego. Imiona są
 * z wielkiej litery, więc się nie liczą.
 */
const MAX_UNKNOWN_RATIO = 1.5;

/** Najdłuższy tekst, do którego dopasowujemy szablony */
const MAX_TEMPLATE_INPUT = 2000;

const lowercaseLetters = (value: string) =>
  (
    value.replace(/<[^>]*>/g, ' ').match(/(?<![\p{L}])\p{Ll}\p{L}*/gu) || []
  ).join('').length;

/** Najwięcej spacji w ciągu wstawek, przy którym jeszcze szukamy podziału */
const MAX_SPLIT_POINTS = 14;

/**
 * Leniwe dopasowanie tnie sąsiednie wstawki ("[user] [verb] [target][strefa]")
 * na pierwszych spacjach, a imiona mają po kilka słów. W ciągu wstawek
 * rozdzielonych samymi spacjami (albo niczym) wybieramy podział, przy którym
 * najwięcej wartości ma tłumaczenie.
 */
const realignCaptures = (
  texts: string[],
  captures: string[],
  alts: Alternatives = NO_ALTERNATIVES,
): string[] => {
  const result = captures.slice();
  let start = 0;
  while (start < captures.length) {
    let end = start;
    // alternatywa ma stałą wartość, więc przerywa ciąg wstawek do podziału
    while (
      end + 1 < captures.length &&
      /^\s*$/.test(texts[end + 1]) &&
      !alts[end] &&
      !alts[end + 1]
    ) {
      end++;
    }
    if (end > start) {
      realignRun(texts.slice(start + 1, end + 1), result, start, end);
    }
    start = end + 1;
  }
  return result;
};

const realignRun = (
  separators: string[],
  captures: string[],
  start: number,
  end: number,
) => {
  let combined = captures[start];
  for (let i = start + 1; i <= end; i++) {
    combined += separators[i - start - 1] + captures[i];
  }
  const runs = [...combined.matchAll(/\s+/g)].map((m) => [
    m.index!,
    m.index! + m[0].length,
  ]);
  if (runs.length > MAX_SPLIT_POINTS) {
    return;
  }
  const count = end - start + 1;
  // dłuższa rozpoznana wartość waży więcej: "robustuje" przed imieniem "Marek"
  const score = (values: string[]) =>
    values.reduce(
      (sum, value) => sum + (isKnown(value) ? value.trim().length : 0),
      0,
    );
  let best = captures.slice(start, end + 1);
  let bestScore = score(best);

  // j = numer wstawki w ciągu, pos = gdzie się zaczyna
  const search = (j: number, from: number, pos: number, values: string[]) => {
    if (j === count - 1) {
      const last = combined.slice(pos);
      if (!last.trim()) {
        return;
      }
      const candidate = [...values, last];
      const candidateScore = score(candidate);
      if (candidateScore > bestScore) {
        best = candidate;
        bestScore = candidateScore;
      }
      return;
    }
    const empty = separators[j] === '';
    for (let r = from; r < runs.length; r++) {
      const [runStart, runEnd] = runs[r];
      const value = combined.slice(pos, runStart);
      if (!value.trim()) {
        continue;
      }
      // pusty separator: następna wstawka zaczyna się od spacji (" w głowę")
      search(j + 1, r + (empty ? 0 : 1), empty ? runStart : runEnd, [
        ...values,
        value,
      ]);
    }
  };
  search(0, 0, 0, []);
  for (let i = 0; i < count; i++) {
    captures[start + i] = best[i];
  }
};

const withArticle = (value: string, article: string): string => {
  const first = value.trimStart().charAt(0);
  // nazwy własne i wstawki HTML bez przedimka
  if (!first || first === '<' || first !== first.toLowerCase()) {
    return value;
  }
  const lower = article.toLowerCase();
  let word = lower === 'the' ? 'the' : /^[aeiou]/i.test(value) ? 'an' : 'a';
  if (article.charAt(0) !== lower.charAt(0)) {
    word = word.charAt(0).toUpperCase() + word.slice(1);
  }
  return `${word} ${value}`;
};

const sameText = (a: string, b: string) =>
  a.replace(/\s+/g, ' ').trim() === b.replace(/\s+/g, ' ').trim();

const renderTemplate = (
  parts: EnPart[],
  captures: string[],
  depth: number,
  alts: Alternatives = NO_ALTERNATIVES,
): string => {
  let out = '';
  for (const part of parts) {
    if (typeof part === 'string') {
      out += part;
      continue;
    }
    if (part[0] === '?') {
      // gałąź warunku: ta, której polska alternatywa wystąpiła w wiadomości
      const [, index, options] = part;
      const branch = (alts[index] || []).findIndex((option) =>
        sameText(option, captures[index] ?? ''),
      );
      out += options[branch === 1 ? 1 : 0];
      continue;
    }
    const value = translateValue(captures[part[0]] ?? '', depth);
    out += part.length > 1 ? withArticle(value, part[1] as string) : value;
  }
  return out;
};

/**
 * Tłumaczy HTML wiadomości. Najpierw dłuższe szablony (bardziej konkretne),
 * potem stałe teksty w węzłach tekstowych.
 */
/** Wypowiedź: <span class='message'>mówi, "TEKST"</span> (code/game/say.dm, say_quote) */
const SPOKEN = /(<span class=['"]message['"]>[^"<]*")([\s\S]*?)("\s*<\/span>)/g;

/**
 * Tłumaczy HTML wiadomości. Treść wypowiedzi zostaje, jak ją napisał gracz:
 * tłumaczymy czasownik mowy i resztę wiadomości, nie to, co ktoś powiedział.
 */
export const translateHtml = (html: string, depth = 0): string => {
  if (
    depth > 0 ||
    !html ||
    !(html.includes("class='message'") || html.includes('class="message"'))
  ) {
    return translateMarkup(html, depth);
  }
  const spoken: string[] = [];
  const masked = html.replace(SPOKEN, (_match, open, text, close) => {
    spoken.push(text);
    return `${open}\u0003${spoken.length - 1}\u0004${close}`;
  });
  return translateMarkup(masked, depth).replace(
    /\u0003(\d+)\u0004/g,
    (_match, n: string) => spoken[Number(n)],
  );
};

const translateMarkup = (html: string, depth: number): string => {
  if (!dictionary || !html) {
    return html;
  }
  const whole = lookupExact(html.trim());
  if (whole !== undefined) {
    return whole;
  }
  // Długie wiadomości (examine, raporty) tylko przez stałe teksty: szablon z
  // sąsiednimi leniwymi grupami mógłby na nich długo blokować wątek UI
  const words =
    html.length > MAX_TEMPLATE_INPUT
      ? new Set<string>()
      : new Set(html.toLowerCase().match(WORD) || []);
  const candidates: number[] = [];
  for (const word of words) {
    const list = byAnchor.get(word);
    if (list) {
      candidates.push(...list);
    }
  }
  const templates = dictionary.templates;

  // Wszystkie dopasowania kandydatów, potem najlepsze nienakładające się.
  // Ocena: stały tekst bez znaczników + rozpoznane wartości. Dzięki temu
  // "[user] [verb] [target][strefa], używając [I]!" wygrywa z wersją bez
  // strefy, choć ta ma w szablonie <span> i dłuższy surowy tekst.
  const matches: {
    start: number;
    end: number;
    index: number;
    captures: string[];
    score: number;
  }[] = [];
  for (const index of new Set(candidates)) {
    const regex = templateRegex(index);
    if (!regex) {
      continue;
    }
    const texts = templates[index][1];
    const fixed = texts.join('').replace(/<[^>]*>/g, '').length;
    regex.lastIndex = 0;
    for (const match of html.matchAll(regex)) {
      const captures = realignCaptures(
        texts,
        match.slice(1, texts.length) as string[],
        alternativesOf(index),
      );
      let known = 0;
      let unknownLower = 0;
      for (const value of captures) {
        if (isKnown(value)) {
          known += value.trim().length;
        } else {
          unknownLower += lowercaseLetters(value);
        }
      }
      // Za ogólny szablon na całe zdanie ("[x] jest [y]!" na "Ból mija,
      // twarz znowu jest normalna!") zostawia dużo polskiego w wartościach.
      // Wtedy lepiej nic nie tłumaczyć niż zrobić mieszankę.
      if (unknownLower > MAX_UNKNOWN_RATIO * (fixed + known)) {
        continue;
      }
      matches.push({
        start: match.index!,
        end: match.index! + match[0].length,
        index,
        captures,
        score: fixed + known,
      });
    }
  }
  matches.sort((a, b) => b.score - a.score);
  const chosen: typeof matches = [];
  for (const match of matches) {
    if (chosen.every((c) => match.end <= c.start || match.start >= c.end)) {
      chosen.push(match);
    }
  }
  chosen.sort((a, b) => b.start - a.start);

  // Fragmenty już przetłumaczone chowamy za znacznikami, żeby przejście
  // po stałych tekstach nie ruszało angielskiego wyniku.
  const done: string[] = [];
  let result = html;
  for (const match of chosen) {
    done.push(
      renderTemplate(
        templates[match.index][2],
        match.captures,
        depth,
        alternativesOf(match.index),
      ),
    );
    result =
      result.slice(0, match.start) +
      `\u0001${depth}.${done.length - 1}\u0002` +
      result.slice(match.end);
  }
  result = `>${result}<`.replace(TEXT_NODE, (match, text: string) => {
    const found = lookupExact(text.trim());
    if (found !== undefined) {
      return `>${text.replace(text.trim(), found)}<`;
    }
    // Examine skleja linie (nazwa, opis, zawartość) znakiem nowej linii w jeden
    // węzeł: każda linia osobno, stałą albo szablonem
    if (!text.includes('\n') || depth >= MAX_DEPTH) {
      return match;
    }
    const lines = text
      .split('\n')
      .map((line) =>
        line.trim() && line.length <= MAX_TEMPLATE_INPUT
          ? translateMarkup(line, depth + 1).replace(/\n+$/, '')
          : line,
      );
    return `>${lines.join('\n')}<`;
  });
  result = result.slice(1, -1);
  return result.replace(
    /\u0001(\d+)\.(\d+)\u0002/g,
    // znacznik z wywołania wyżej (linia examine tłumaczona osobno) zostaje dla niego
    (match, level: string, n: string) =>
      Number(level) === depth ? done[Number(n)] : match,
  );
};

/**
 * Tekst z okna tgui: najpierw tablica tekstów z kodu okien (ten sam polski
 * tekst bywa w DM z innym oryginałem), potem jak w czacie.
 */
export const translateUiText = (text: string): string => {
  const trimmed = text.trim();
  const ui = dictionary?.ui;
  const found = ui?.[trimmed];
  if (found !== undefined) {
    return text.replace(trimmed, found);
  }
  if (ui && trimmed.endsWith(':')) {
    const base = ui[trimmed.slice(0, -1)];
    if (base !== undefined) {
      return text.replace(trimmed, base.endsWith(':') ? base : base + ':');
    }
  }
  return translateHtml(text);
};
