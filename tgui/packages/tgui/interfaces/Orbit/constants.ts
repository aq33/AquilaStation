/** Kolory grup antagonistów (nazwy drużyn/antagonistów z DM). Reszta: 'bad'. */
export const ANTAG2COLOR: Record<string, string> = {
  Abductors: 'pink',
  'Emergency Response Team': 'teal',
};

type Department = {
  color: string;
  name: string;
};

/**
 * AQUILA EDIT - dział przychodzi z DM (get_department w orbit.dm), więc
 * zamiast list prac trzymamy tu tylko kolor i polską nazwę.
 */
export const DEPARTMENT2COLOR: Record<string, Department> = {
  cargo: { color: 'brown', name: 'Zaopatrzenie' },
  command: { color: 'blue', name: 'Dowództwo' },
  engineering: { color: 'orange', name: 'Inżynieria' },
  medical: { color: 'teal', name: 'Medyczny' },
  munitions: { color: 'yellow', name: 'Amunicja' },
  science: { color: 'pink', name: 'Nauka' },
  security: { color: 'red', name: 'Ochrona' },
  service: { color: 'green', name: 'Cywile' },
  silicon: { color: 'violet', name: 'Syntetyki' },
};

export const THREAT = {
  Low: 1,
  Medium: 5,
  High: 8,
} as const;

export const HEALTH = {
  Good: 69, // nice
  Average: 19,
  Bad: 0,
  Crit: -30,
  Dead: -100,
  Ruined: -200,
} as const;

export const VIEWMODE = {
  Health: 'heart',
  Orbiters: 'ghost',
  Department: 'id-badge',
} as const;

/** AQUILA EDIT - polskie nazwy trybów widoku */
export const VIEWMODE_NAMES: Record<string, string> = {
  Health: 'Zdrowie',
  Orbiters: 'Orbitujący',
  Department: 'Dział',
};
