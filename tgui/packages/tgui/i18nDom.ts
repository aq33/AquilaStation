/**
 * AQUILA: tłumaczenie okien tgui na angielski (prototyp).
 *
 * Okna mają teksty w JSX i w danych z DM, po polsku. Zamiast przepisywać
 * setki okien na t(), przy języku EN podmieniamy gotowe teksty na stronie:
 * węzły tekstowe oraz atrybuty placeholder i title. MutationObserver łapie
 * każdą zmianę, którą robi React, więc tłumaczenie nadąża za odświeżaniem.
 *
 * Pomijamy pola edycji (input, textarea, contenteditable): tekst wpisany przez
 * gracza zostaje, jaki jest. Wyszukiwarki w oknach dalej szukają po polsku.
 */

import { Store } from 'common/redux';

import {
  getLanguage,
  isProducedText,
  isTranslating,
  loadDictionary,
  POLISH_LEFT,
  setLanguage,
  translateUiText,
} from './i18n';

const ATTRIBUTES = ['placeholder', 'title'];
const SKIPPED_TAGS = new Set(['SCRIPT', 'STYLE', 'TEXTAREA', 'INPUT']);

/** Polski oryginał węzła, żeby po powrocie na PL przywrócić tekst */
const originals = new WeakMap<Node, string>();
/** Ostatnio wpisane tłumaczenie: nasza własna zmiana nie wraca do tłumacza */
const written = new WeakMap<Node, string>();
/** Elementy z przetłumaczonym atrybutem (oryginał w data-i18n-pl-<nazwa>) */
const TRANSLATED_SELECTOR = ATTRIBUTES.map(
  (name) => `[data-i18n-pl-${name}]`,
).join(',');

let observer: MutationObserver | null = null;

/**
 * Obszar bez tłumaczenia: czat w panelu (ma własne i chroni wypowiedzi graczy) oraz
 * treść pisana przez graczy (kartki, książki, wiadomości PDA, Newscaster)
 */
const SKIP_ATTRIBUTE = 'data-i18n-skip';

/** To samo jako klasa: komponenty tgui-core (Box) przekazują className, nie dowolne atrybuty */
const SKIP_CLASS = 'i18n-skip';

const hasSkipMark = (el: Element): boolean =>
  el.hasAttribute(SKIP_ATTRIBUTE) || el.classList.contains(SKIP_CLASS);

const isSkippedElement = (el: Element): boolean =>
  SKIPPED_TAGS.has(el.tagName) ||
  (el as HTMLElement).isContentEditable ||
  hasSkipMark(el);

const isSkipped = (node: Node): boolean => {
  for (let el = node.parentElement; el; el = el.parentElement) {
    if (isSkippedElement(el)) {
      return true;
    }
  }
  return false;
};

/** Polski tekst węzła: oryginał, jeśli w węźle nadal jest nasze tłumaczenie */
const sourceText = (node: Text): string => {
  const value = node.nodeValue || '';
  const original = originals.get(node);
  return original !== undefined && written.get(node) === value
    ? original
    : value;
};

const write = (node: Text, source: string, translated: string) => {
  originals.set(node, source);
  written.set(node, translated);
  if (node.nodeValue !== translated) {
    node.nodeValue = translated;
  }
};

/**
 * Sąsiednie węzły tekstowe wokół węzła. React robi je ze zdania przeciętego
 * wstawką: "Przeciągnij kartę ID, aby {locked ? 'odblokować' : 'zablokować'} ten
 * interfejs." to trzy węzły.
 */
const textGroup = (node: Text): Text[] => {
  let first: ChildNode = node;
  while (first.previousSibling?.nodeType === Node.TEXT_NODE) {
    first = first.previousSibling;
  }
  const group: Text[] = [];
  for (
    let next: ChildNode | null = first;
    next && next.nodeType === Node.TEXT_NODE;
    next = next.nextSibling
  ) {
    group.push(next as Text);
  }
  return group;
};

const translateTextNode = (node: Text) => {
  const value = node.nodeValue;
  if (!value || !value.trim() || written.get(node) === value) {
    return;
  }
  if (isSkipped(node)) {
    return;
  }
  // tekst przetłumaczony przy budowie (t/tt z tgui/i18n-jsx.cjs): drugi raz nie tłumaczymy
  // ("Pan" po angielsku to też polski klucz)
  if (isProducedText(value)) {
    write(node, value, value);
    return;
  }
  const group = textGroup(node);
  if (
    group.some((part) => part !== node && isProducedText(part.nodeValue || ''))
  ) {
    // zdanie złożone przy budowie, ten węzeł to wartość wstawki z danych
    write(node, value, translateUiText(value));
    return;
  }
  if (group.length < 2) {
    write(node, value, translateUiText(value));
    return;
  }
  // całe zdanie naraz: szablon ze słownika zna wstawki (tools/i18n/jsx_runs.py)
  const sources = group.map(sourceText);
  const combined = sources.join('');
  const whole = translateUiText(combined);
  if (whole !== combined) {
    group.forEach((part, i) => write(part, sources[i], i === 0 ? whole : ''));
    return;
  }
  // kawałki osobno ("Ciśnienie:", "101", " kPa"), ale bez mieszania języków
  // w jednym zdaniu ("aby unlock ten"): wtedy całość zostaje po polsku
  const parts = sources.map(translateUiText);
  const mixed =
    parts.some((part, i) => part !== sources[i]) &&
    parts.some((part, i) => part === sources[i] && POLISH_LEFT.test(part));
  group.forEach((part, i) =>
    write(part, sources[i], mixed ? sources[i] : parts[i]),
  );
};

const translateAttributes = (el: Element) => {
  // placeholder pola (input) tłumaczymy; nie ruszamy tylko obszarów oznaczonych do pominięcia
  if (hasSkipMark(el) || isSkipped(el)) {
    return;
  }
  for (const name of ATTRIBUTES) {
    const value = el.getAttribute(name);
    if (!value || el.getAttribute(`data-i18n-${name}`) === value) {
      continue;
    }
    const translated = translateUiText(value);
    if (translated !== value) {
      el.setAttribute(`data-i18n-pl-${name}`, value);
      el.setAttribute(`data-i18n-${name}`, translated);
      el.setAttribute(name, translated);
    } else {
      // React wpisał nowy tekst bez tłumaczenia: stary oryginał już nie obowiązuje
      el.removeAttribute(`data-i18n-pl-${name}`);
      el.removeAttribute(`data-i18n-${name}`);
    }
  }
};

const translateTree = (root: Node) => {
  if (root.nodeType === Node.TEXT_NODE) {
    translateTextNode(root as Text);
    return;
  }
  if (root.nodeType !== Node.ELEMENT_NODE) {
    return;
  }
  if (hasSkipMark(root as Element) || isSkipped(root)) {
    return;
  }
  translateAttributes(root as Element);
  const walker = document.createTreeWalker(
    root,
    NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
    {
      // całe poddrzewo z własnym tłumaczeniem (czat) pomijamy od razu
      acceptNode: (node) =>
        node.nodeType === Node.ELEMENT_NODE && hasSkipMark(node as Element)
          ? NodeFilter.FILTER_REJECT
          : NodeFilter.FILTER_ACCEPT,
    },
  );
  for (let node = walker.nextNode(); node; node = walker.nextNode()) {
    if (node.nodeType === Node.TEXT_NODE) {
      translateTextNode(node as Text);
    } else {
      translateAttributes(node as Element);
    }
  }
};

const startObserver = () => {
  if (observer) {
    return;
  }
  observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type === 'characterData') {
        translateTextNode(mutation.target as Text);
      } else if (mutation.type === 'attributes') {
        translateAttributes(mutation.target as Element);
      } else {
        mutation.addedNodes.forEach(translateTree);
      }
    }
  });
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    characterData: true,
    attributes: true,
    attributeFilter: ATTRIBUTES,
  });
  translateTree(document.body);
};

/** Powrót na polski: przywraca oryginały i zatrzymuje obserwację */
const stopObserver = () => {
  observer?.disconnect();
  observer = null;
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
  for (let node = walker.nextNode(); node; node = walker.nextNode()) {
    const original = originals.get(node);
    if (original !== undefined && written.get(node) === node.nodeValue) {
      node.nodeValue = original;
    }
    written.delete(node);
  }
  document.querySelectorAll(TRANSLATED_SELECTOR).forEach((el) => {
    for (const name of ATTRIBUTES) {
      const original = el.getAttribute(`data-i18n-pl-${name}`);
      if (original === null) {
        continue;
      }
      // tylko jeśli atrybut nadal ma nasze tłumaczenie, a nie nowszą wartość
      if (el.getAttribute(name) === el.getAttribute(`data-i18n-${name}`)) {
        el.setAttribute(name, original);
      }
      el.removeAttribute(`data-i18n-pl-${name}`);
      el.removeAttribute(`data-i18n-${name}`);
    }
  });
};

/**
 * Język okna: "en" albo "ru" włącza tłumaczenie (po wczytaniu słownika), "pl" przywraca
 * polskie teksty. Menu Esc (tgui-escape-menu) woła to wprost z wiadomości DM.
 */
export const setDomLanguage = (
  language: string | undefined,
  onReady?: () => void,
) => {
  if (!language || language === getLanguage()) {
    return;
  }
  // zmiana języka: najpierw polskie oryginały (zmiana EN -> RU tłumaczy od nowa)
  stopObserver();
  setLanguage(language);
  if (getLanguage() === 'pl') {
    return;
  }
  const requested = getLanguage();
  loadDictionary().then((ready) => {
    if (getLanguage() !== requested) {
      return; // w międzyczasie przyszedł inny język
    }
    if (!ready) {
      // słownik nie doszedł: następna wiadomość z tym językiem spróbuje znowu
      setLanguage('pl');
      return;
    }
    if (isTranslating()) {
      startObserver();
      // okno renderuje teksty z t()/tt() dopiero przy następnym renderze
      onReady?.();
    }
  });
};

/** Śledzi config.language z DM (aquila/code/modules/i18n/game_language.dm) */
export const setupDomTranslation = (store: Store) => {
  store.subscribe(() => {
    // stan jak w selectBackend (backend.ts), bez importu: backend ciągnie kod zależny od BYOND
    setDomLanguage(store.getState()?.backend?.config?.language, () =>
      store.dispatch({ type: 'i18n/ready' }),
    );
  });
};
