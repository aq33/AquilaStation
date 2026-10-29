/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Gas = {
  id: string;
  path: string;
  name: string;
  label: string;
  color: string;
};

// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#c06616',
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    service: '#7cc46a',
    centcom: '#00c100',
    other: '#c38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
  // reagent / chemistry related colours
  reagent: {
    acidicbuffer: '#fbc314',
    basicbuffer: '#3853a4',
  },
} as const;

// Colors defined in CSS
export const CSS_COLORS = [
  'black',
  'white',
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'good',
  'average',
  'bad',
  'label',
];

export const RADIO_CHANNELS = [
  {
    name: 'Syndykat',
    freq: 1213,
    color: '#8f4a4b',
  },
  {
    name: 'Czerwona Drużyna',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Niebieska Drużyna',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'Centrala',
    freq: 1337,
    color: '#2681a5',
  },
  {
    name: 'Dostawy',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Służba',
    freq: 1349,
    color: '#6ca729',
  },
  {
    // Kanał wyłączony w DM (RADIO_CHANNEL_EXPLORATION zakomentowany); tu tylko etykieta po częstotliwości
    name: 'Eksploracja',
    freq: 1361,
    color: '#7ed4c2',
  },
  {
    name: 'Naukowy',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Dowództwo',
    freq: 1353,
    color: '#fcdf03',
  },
  {
    name: 'Medyczny',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Inżynieria',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Policja',
    freq: 1359,
    color: '#7c8be6',
  },
  {
    name: 'Prywatny AI',
    freq: 1447,
    color: '#d65d95',
  },
  {
    name: 'Ogólny',
    freq: 1459,
    color: '#1ecc43',
  },
] as const;

const GASES = [
  {
    id: 'o2',
    path: '/datum/gas/oxygen',
    name: 'Tlen',
    label: 'O₂',
    color: 'blue',
  },
  {
    id: 'n2',
    path: '/datum/gas/nitrogen',
    name: 'Azot',
    label: 'N₂',
    color: 'yellow',
  },
  {
    id: 'co2',
    path: '/datum/gas/carbon_dioxide',
    name: 'Dwutlenek węgla',
    label: 'CO₂',
    color: 'grey',
  },
  {
    id: 'plasma',
    path: '/datum/gas/plasma',
    name: 'Plazma',
    label: 'Plazma',
    color: 'pink',
  },
  {
    id: 'water_vapor',
    path: '/datum/gas/water_vapor',
    name: 'Para wodna',
    label: 'H₂O',
    color: 'lightsteelblue',
  },
  {
    id: 'hypernoblium',
    path: '/datum/gas/hypernoblium',
    name: 'Hipernoblium',
    label: 'Hipernoblium',
    color: 'teal',
  },
  {
    id: 'n2o',
    path: '/datum/gas/nitrous_oxide',
    name: 'Podtlenek azotu',
    label: 'N₂O',
    color: 'bisque',
  },
  {
    // AQUILA: u nas no2 to dwutlenek azotu (/datum/gas/nitryl), nie nitrium z tg
    id: 'no2',
    path: '/datum/gas/nitryl',
    name: 'Dwutlenek azotu',
    label: 'NO₂',
    color: 'brown',
  },
  {
    id: 'tritium',
    path: '/datum/gas/tritium',
    name: 'Tryt',
    label: 'Tryt',
    color: 'limegreen',
  },
  {
    id: 'bz',
    path: '/datum/gas/bz',
    name: 'BZ',
    label: 'BZ',
    color: 'mediumpurple',
  },
  {
    id: 'pluoxium',
    path: '/datum/gas/pluoxium',
    name: 'Pluoksium',
    label: 'Pluoksium',
    color: 'mediumslateblue',
  },
  {
    id: 'freon',
    path: '/datum/gas/freon',
    name: 'Freon',
    label: 'Freon',
    color: 'paleturquoise',
  },
  {
    id: 'hydrogen',
    path: '/datum/gas/hydrogen',
    name: 'Wodór',
    label: 'H₂',
    color: 'white',
  },
  {
    id: 'healium',
    path: '/datum/gas/healium',
    name: 'Healium',
    label: 'Healium',
    color: 'salmon',
  },
  {
    id: 'proto_nitrate',
    path: '/datum/gas/proto_nitrate',
    name: 'Protoazotan',
    label: 'Protoazotan',
    color: 'greenyellow',
  },
  {
    id: 'zauker',
    path: '/datum/gas/zauker',
    name: 'Zauker',
    label: 'Zauker',
    color: 'darkgreen',
  },
  {
    id: 'halon',
    path: '/datum/gas/halon',
    name: 'Halon',
    label: 'Halon',
    color: 'purple',
  },
  {
    id: 'helium',
    path: '/datum/gas/helium',
    name: 'Hel',
    label: 'He',
    color: 'aliceblue',
  },
  {
    id: 'antinoblium',
    path: '/datum/gas/antinoblium',
    name: 'Antynoblium',
    label: 'Antynoblium',
    color: 'maroon',
  },
  {
    id: 'nitrium',
    path: '/datum/gas/nitrium',
    name: 'Nitrium',
    label: 'Nitrium',
    color: 'brown',
  },
  // AQUILA: id gazów z naszego DM (code/__DEFINES/atmospherics.dm), inne niż w tg
  {
    id: 'nob',
    path: '/datum/gas/hypernoblium',
    name: 'Hipernoblium',
    label: 'Hipernoblium',
    color: 'teal',
  },
  {
    id: 'pluox',
    path: '/datum/gas/pluoxium',
    name: 'Pluoksium',
    label: 'Pluoksium',
    color: 'mediumslateblue',
  },
  {
    id: 'stim',
    path: '/datum/gas/stimulum',
    name: 'Stymulum',
    label: 'Stymulum',
    color: 'gold',
  },
  {
    id: 'constricted_plasma',
    path: '/datum/gas/constricted_plasma',
    name: 'Skondensowana plazma',
    label: 'Skondensowana plazma',
    color: 'hotpink',
  },
  {
    id: 'nucleium',
    path: '/datum/gas/nucleium',
    name: 'Nukleium',
    label: 'Nukleium',
    color: 'olive',
  },
  {
    id: 'miasma',
    path: '/datum/gas/miasma',
    name: 'Miazma',
    label: 'Miazma',
    color: 'olivedrab',
  },
] as const;

// Returns gas label based on gasId
export const getGasLabel = (gasId: string, fallbackValue?: string) => {
  if (!gasId) return fallbackValue || 'Brak';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].label;
    }
  }

  return fallbackValue || 'Brak';
};

// Returns gas color based on gasId
export const getGasColor = (gasId: string) => {
  if (!gasId) return 'black';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].color;
    }
  }

  return 'black';
};

// Returns gas object based on gasId
export const getGasFromId = (gasId: string): Gas | undefined => {
  if (!gasId) return;

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx];
    }
  }
};

// Returns gas object based on gasPath
export const getGasFromPath = (gasPath: string): Gas | undefined => {
  if (!gasPath) return;

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].path === gasPath) {
      return GASES[idx];
    }
  }
};

// --- tgstation additions used by windows ported from tg
export enum Direction {
  NONE = 0,
  NORTH = 1,
  SOUTH = 2,
  EAST = 4,
  WEST = 8,
  NORTHEAST = NORTH | EAST,
  NORTHWEST = NORTH | WEST,
  SOUTHEAST = SOUTH | EAST,
  SOUTHWEST = SOUTH | WEST,
  VERTICAL = NORTH | SOUTH,
  HORIZONTAL = EAST | WEST,
  ALL = NORTH | SOUTH | EAST | WEST,
}

export type CssColor = (typeof CSS_COLORS)[number];
