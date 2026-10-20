export const NULL_REF = '[0x0]';
export const ABSOLUTE_Y_OFFSET = -32;

export const MOUSE_BUTTON_LEFT = 0;
// in milliseconds
export const TIME_UNTIL_PORT_RELEASE_WORKS = 100;
export const noop = (..._args: any[]) => {};

// AQUILA: nasz DM wysyła connected_to jako pojedynczy REF (porty wejściowe
// mają jedno połączenie), a tg jako listę. Sprowadzamy to do listy.
export const getConnectedRefs = (port): string[] => {
  const connected = port?.connected_to;
  if (!connected) {
    return [];
  }
  if (Array.isArray(connected)) {
    return connected;
  }
  return connected === NULL_REF ? [] : [connected];
};

// AQUILA: polskie nazwy typów portów (null w DM oznacza „dowolny”).
export const DATATYPE_NAMES: Record<string, string> = {
  any: 'dowolny',
  string: 'tekst',
  number: 'liczba',
  entity: 'obiekt',
  signal: 'sygnał',
  list: 'lista',
  table: 'tabela',
};
