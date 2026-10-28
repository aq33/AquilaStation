/**
 * Układ panelu statystyk po stronie klienta (Aquila).
 *
 * Komendy przychodzą z DM pogrupowane po `set category`. Tu decydujemy,
 * co gracz widzi: część komend chowamy (są pod klawiszami i guzikami HUD),
 * część przenosimy do innych zakładek, a niektóre zakładki łączymy w jedną
 * z podziałem na sekcje. Same komendy dalej działają z paska poleceń.
 */

/** Zakładki niewidoczne w panelu (ich komendy są gdzie indziej). */
const HIDDEN_TABS = ['Object', 'Preferences', 'Squad'];

/** Komendy chowane w danej zakładce. */
const HIDDEN_VERBS = {
  IC: [
    'Open Language Menu',
    'Rest',
    'Resist',
    'Stop Pulling',
    'Say',
    'Panel emotek',
    'Examine',
  ],
};

/** Komendy przenoszone: zakładka źródłowa -> { komenda: zakładka docelowa }. */
const MOVED_VERBS = {
  IC: {
    Pray: 'Admin',
  },
  Preferences: {
    'Preferencje Gry': 'OOC',
    Klawiszologia: 'OOC',
    'Ghost Customization': 'OOC',
    'Zatrzymaj Dźwięki': 'OOC',
  },
};

/**
 * Zakładki łączone w jedną. Klucz to zakładka docelowa, wartość to lista
 * sekcji: [zakładka źródłowa, nagłówek sekcji]. Zakładki źródłowe poza
 * docelową znikają z paska.
 */
const MERGED_TABS = {
  Admin: [
    ['Admin', 'Administracja'],
    ['Mentor', 'Mentorzy'],
  ],
};

/** Opisy pokazywane w podpowiedzi po najechaniu na komendę. */
const VERB_DESCRIPTIONS = {
  Pray: 'Wysyła modlitwę do administracji, która gra bogów. Admin może odpowiedzieć, zesłać cud albo karę. Nie służy do zgłaszania problemów, od tego jest „Pomoc admina”.',
};

export const getVerbDescription = (verb) => VERB_DESCRIPTIONS[verb];

/** Zakładka, w której gracz zobaczy komendy z zakładki `tab`. */
const mergedTarget = (tab) => {
  for (const target of Object.keys(MERGED_TABS)) {
    if (MERGED_TABS[target].some(([source]) => source === tab)) {
      return target;
    }
  }
  return tab;
};

/**
 * Komendy po przeniesieniu i ukryciu, jako { zakładka: { komenda: dane } }.
 * Przy połączonych zakładkach klucze to nadal zakładki źródłowe, żeby dało
 * się zbudować sekcje.
 */
export const getDisplayVerbs = (verbData) => {
  const result = {};
  if (!verbData) {
    return result;
  }
  const add = (tab, verb, data) => {
    result[tab] = result[tab] || {};
    result[tab][verb] = data;
  };
  for (const tab of Object.keys(verbData)) {
    const verbs = verbData[tab] || {};
    const hidden = HIDDEN_VERBS[tab] || [];
    const moved = MOVED_VERBS[tab] || {};
    for (const verb of Object.keys(verbs)) {
      if (hidden.includes(verb)) {
        continue;
      }
      if (moved[verb]) {
        add(moved[verb], verb, verbs[verb]);
        continue;
      }
      if (HIDDEN_TABS.includes(tab)) {
        continue;
      }
      add(tab, verb, verbs[verb]);
    }
  }
  return result;
};

/** Zakładki widoczne na pasku, w kolejności od serwera. */
export const getDisplayTabs = (statTabs, verbData) => {
  const displayVerbs = getDisplayVerbs(verbData);
  const tabs = [];
  for (const tab of statTabs || []) {
    if (HIDDEN_TABS.includes(tab)) {
      continue;
    }
    const target = mergedTarget(tab);
    // Mentor bez uprawnień admina nie ma zakładki Admin - wtedy zostaje
    // pierwsza istniejąca zakładka z grupy.
    const shown = (statTabs || []).includes(target) ? target : tab;
    if (!tabs.includes(shown)) {
      tabs.push(shown);
    }
  }
  // Zakładka, do której tylko przenieśliśmy komendy (np. brak OOC u gościa).
  for (const tab of Object.keys(displayVerbs)) {
    const target = mergedTarget(tab);
    if (!tabs.includes(target) && !tabs.includes(tab)) {
      tabs.push(tab);
    }
  }
  return tabs;
};

/**
 * Sekcje komend dla wybranej zakładki: [{ title, verbs }]. Zwykła zakładka
 * ma jedną sekcję bez nagłówka.
 */
export const getTabSections = (selectedTab, verbData) => {
  const displayVerbs = getDisplayVerbs(verbData);
  const merged = MERGED_TABS[selectedTab];
  if (!merged) {
    return [{ title: null, verbs: displayVerbs[selectedTab] || {} }];
  }
  const sections = merged
    .map(([source, title]) => ({ title, verbs: displayVerbs[source] || {} }))
    .filter((section) => Object.keys(section.verbs).length > 0);
  if (sections.length === 1) {
    sections[0].title = null;
  }
  return sections;
};
