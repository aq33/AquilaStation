/**
 * AQUILA: tłumaczenie na żywo (aquila/code/modules/i18n/live_translation.dm).
 *
 * Serwer wysyła najpierw zwykłą linijkę z oryginałem w znaczniku
 * `<span class="aq-tr aq-tr-pending" data-aq-tr="id">`, a gdy tłumacz odpowie,
 * wiadomość `internal/aq_translation` z tym samym id i gotowym HTML-em
 * tłumaczenia (po sanitize na serwerze) albo z null, gdy się nie udało.
 * Panel podmienia treść znacznika z krótką animacją litera po literze i
 * zapisuje wynik w historii, więc po przebudowie czatu zostaje tłumaczenie.
 */

export const MESSAGE_TYPE_AQ_TRANSLATION = 'internal/aq_translation';

const PENDING_CLASS = 'aq-tr-pending';
/** Czas całej animacji i jednej klatki (ms) */
const MORPH_DURATION = 500;
const MORPH_FRAME = 50;
/** Ile znaków przed miejscem odsłonięcia miga losowymi literami */
const MORPH_SCRAMBLE = 3;
const GLYPHS = 'abcdefghijklmnopqrstuvwxyz';

type TranslationPayload = {
  id: string;
  html?: string | null;
};

type ChatMessage = {
  html?: string;
  node?: HTMLElement | string;
};

const selectorFor = (id: string) => `[data-aq-tr="${id}"]`;

const scramble = (char: string) =>
  char.trim() ? GLYPHS[Math.floor(Math.random() * GLYPHS.length)] : char;

/** Tekst bez znaczników, w szablonie, żeby nic się nie ładowało */
const htmlToText = (html: string) => {
  const template = document.createElement('template');
  template.innerHTML = html;
  return template.content.textContent || '';
};

/** Nowa treść w zapisanym HTML-u wiadomości (historia, przebudowa czatu) */
const rewriteHtml = (html: string, payload: TranslationPayload) => {
  const template = document.createElement('template');
  template.innerHTML = html;
  const target = template.content.querySelector(selectorFor(payload.id));
  if (!target) {
    return html;
  }
  target.classList.remove(PENDING_CLASS);
  if (payload.html) {
    target.innerHTML = payload.html;
  }
  return template.innerHTML;
};

/** Oryginał przechodzi w tłumaczenie od lewej, z kilkoma migającymi literami na granicy */
const morph = (element: Element, html: string) => {
  const source = element.textContent || '';
  const target = htmlToText(html);
  const frames = Math.max(1, Math.round(MORPH_DURATION / MORPH_FRAME));
  let frame = 0;
  const timer = setInterval(() => {
    frame++;
    if (frame >= frames || !element.isConnected) {
      clearInterval(timer);
      element.innerHTML = html;
      return;
    }
    const reveal = Math.floor((target.length * frame) / frames);
    let text = target.slice(0, reveal);
    for (let i = 0; i < MORPH_SCRAMBLE && reveal + i < target.length; i++) {
      text += scramble(target[reveal + i]);
    }
    text += source.slice(reveal + MORPH_SCRAMBLE);
    element.textContent = text;
  }, MORPH_FRAME);
};

/** Szuka linijki od końca (tłumaczenie przychodzi zaraz po niej) i podmienia treść */
export const applyAqTranslation = (
  messages: ChatMessage[],
  payload: TranslationPayload,
) => {
  if (!payload?.id) {
    return;
  }
  const marker = `data-aq-tr="${payload.id}"`;
  for (let i = messages.length - 1; i >= 0; i--) {
    const message = messages[i];
    if (typeof message.html !== 'string' || !message.html.includes(marker)) {
      continue;
    }
    message.html = rewriteHtml(message.html, payload);
    const node = message.node;
    const element =
      typeof node === 'object'
        ? node.querySelector(selectorFor(payload.id))
        : null;
    if (element) {
      element.classList.remove(PENDING_CLASS);
      if (payload.html) {
        morph(element, payload.html);
      }
    }
    return;
  }
};
