export const NULL_REF = '[0x0]';
export const ABSOLUTE_Y_OFFSET = -32;

export const MOUSE_BUTTON_LEFT = 0;
export const OPTION_DROPDOWN_LARGE_CHAR_AMOUNT = 12;
// in milliseconds
export const TIME_UNTIL_PORT_RELEASE_WORKS = 100;
export const DEFAULT_COMPONENT_MENU_LIMIT = 6;
export const noop = () => {};

export const VARIABLE_NOT_A_LIST = 1;
export const VARIABLE_LIST = 2;
export const VARIABLE_ASSOC_LIST = 3;

// AQUILA: polskie nazwy typów portów, tylko do wyświetlania.
// Do serwera zawsze idzie oryginalna (angielska) nazwa typu.
export const DATATYPE_NAMES: Record<string, string> = {
  any: 'dowolny',
  string: 'tekst',
  number: 'liczba',
  signal: 'sygnał',
  'instant signal': 'sygnał natychmiastowy',
  'response signal': 'sygnał odpowiedzi',
  table: 'tabela',
  option: 'opcja',
  boolean: 'logiczny',
  list: 'lista',
  'assoc list': 'lista asocjacyjna',
  entity: 'obiekt',
  datum: 'datum',
  user: 'użytkownik',
  unknown: 'nieznany',
};

const DATATYPE_REGEX = new RegExp(
  `\\b(?:${Object.keys(DATATYPE_NAMES)
    .sort((a, b) => b.length - a.length)
    .join('|')})\\b`,
  'g',
);

// Tłumaczy też typy złożone, np. "list<number>" -> "lista<liczba>".
export const translateDatatype = (datatype?: string | null): string => {
  if (!datatype) {
    return DATATYPE_NAMES.unknown;
  }
  return datatype.replace(DATATYPE_REGEX, (match) => DATATYPE_NAMES[match]);
};

export const datatypeOptions = (types: string[] = []) =>
  types.map((type) => ({ value: type, displayText: translateDatatype(type) }));

// AQUILA: polskie nazwy kategorii komponentów, tylko do wyświetlania.
export const CATEGORY_NAMES: Record<string, string> = {
  All: 'Wszystkie',
  Abstract: 'Abstrakcyjne',
  Action: 'Akcje',
  Admin: 'Admin',
  BCI: 'BCI',
  Entity: 'Obiekty',
  Fun: 'Zabawa',
  ID: 'ID',
  List: 'Listy',
  Math: 'Matematyka',
  NTNet: 'NTNet',
  Sensor: 'Czujniki',
  String: 'Tekst',
  Utility: 'Narzędzia',
  Unassigned: 'Bez kategorii',
};

export const translateCategory = (category: string): string =>
  CATEGORY_NAMES[category] || category;
