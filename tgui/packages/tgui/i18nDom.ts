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
  isTranslating,
  loadDictionary,
  setLanguage,
  translateHtml,
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

const isSkipped = (node: Node): boolean => {
  for (let el = node.parentElement; el; el = el.parentElement) {
    if (SKIPPED_TAGS.has(el.tagName) || el.isContentEditable) {
      return true;
    }
  }
  return false;
};

const translateTextNode = (node: Text) => {
  const value = node.nodeValue;
  if (!value || !value.trim() || written.get(node) === value) {
    return;
  }
  if (isSkipped(node)) {
    return;
  }
  const translated = translateHtml(value);
  originals.set(node, value);
  written.set(node, translated);
  if (translated !== value) {
    node.nodeValue = translated;
  }
};

const translateAttributes = (el: Element) => {
  for (const name of ATTRIBUTES) {
    const value = el.getAttribute(name);
    if (!value || el.getAttribute(`data-i18n-${name}`) === value) {
      continue;
    }
    const translated = translateHtml(value);
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
  translateAttributes(root as Element);
  const walker = document.createTreeWalker(
    root,
    NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
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

/** Śledzi config.language z DM (aquila/code/modules/i18n/game_language.dm) */
export const setupDomTranslation = (store: Store) => {
  store.subscribe(() => {
    // stan jak w selectBackend (backend.ts), bez importu: backend ciągnie kod zależny od BYOND
    const language = store.getState()?.backend?.config?.language;
    if (!language || language === getLanguage()) {
      return;
    }
    setLanguage(language);
    if (getLanguage() !== 'en') {
      stopObserver();
      return;
    }
    loadDictionary().then((ready) => {
      if (!ready) {
        // słownik nie doszedł: następna aktualizacja okna z językiem EN spróbuje znowu
        setLanguage('pl');
        return;
      }
      if (isTranslating()) {
        startObserver();
      }
    });
  });
};
