/** Mapa nazw assetów (np. "esc_open.ogg") na adresy URL podesłane przez serwer. */
export const assetMap: Record<string, string> = {};

export function loadStyleSheet(payload: string): void {
  Byond.loadCss(payload);
}

/** Zapisuje mapowania assetów i od razu ładuje arkusze stylów (np. fonts.css). */
export function loadMappings(payload: Record<string, string>): void {
  for (const name in payload) {
    const url = payload[name];
    assetMap[name] = url;
    if (name.split('.').pop() === 'css') {
      Byond.loadCss(url);
    }
  }
}
