import { map } from 'es-toolkit/compat';

import { useBackend } from '../../backend';
import type { DesignCache, NodeCache, TechWebData } from './types';

// Data reshaping / ingestion (thanks stylemistake for the help, very cool!)
// This is primarily necessary due to measures that are taken to reduce the size
// of the sent static JSON payload to as minimal of a size as possible
// as larger sizes cause a delay for the user when opening the UI.

const remappingIdCache = {};

function remapId(id: string | number): string {
  return remappingIdCache[id];
}

function selectRemappedStaticData(data: TechWebData) {
  // Handle reshaping of node cache to fill in unsent fields, and
  // decompress the node IDs
  const node_cache: Record<string, NodeCache> = {};
  for (const id of Object.keys(data.static_data.node_cache)) {
    const node = data.static_data.node_cache[id];
    node_cache[remapId(id)] = {
      ...node,
      id: remapId(id),
      prereq_ids: map(node.prereq_ids || [], remapId),
      design_ids: map(node.design_ids || [], remapId),
      unlock_ids: map(node.unlock_ids || [], remapId),
    };
  }

  // Do the same as the above for the design cache
  const design_cache: Record<string, DesignCache> = {};
  for (const id of Object.keys(data.static_data.design_cache)) {
    const [name, classes] = data.static_data.design_cache[id];
    design_cache[remapId(id)] = {
      name: name,
      class: classes.startsWith('design') ? classes : `design32x32 ${classes}`,
    };
  }

  return {
    node_cache,
    design_cache,
  };
}

let remappedStaticData: ReturnType<typeof selectRemappedStaticData>;

/** True once the static data has arrived and has been remapped */
export const isTechwebReady = () => !!remappedStaticData;

export function useRemappedBackend() {
  const { data, ...rest } = useBackend<TechWebData>();

  // Only remap the static data once, cache for future use
  if (!remappedStaticData) {
    const id_cache = data.static_data?.id_cache;
    // Static data can arrive after the first render when the window is reopened
    if (!id_cache) {
      return { data, ...rest };
    }
    for (let i = 0; i < id_cache.length; i++) {
      remappingIdCache[i + 1] = id_cache[i];
    }
    remappedStaticData = selectRemappedStaticData(data);
  }

  return {
    data: {
      ...data,
      static_data: undefined,
      ...remappedStaticData,
    },
    ...rest,
  };
}

// Nazwy typów punktów przychodzą z DM po angielsku (klucze), tu tylko je wyświetlamy
const pointNames = {
  'General Research': 'Badania ogólne',
  'Discovery Research': 'Badania odkrywcze',
  'Nanite Research': 'Badania nanitów',
  'Wormhole Research': 'Badania tuneli',
};

const pointAbbreviations = {
  'General Research': 'Ogólne',
  'Discovery Research': 'Odkrycia',
  'Nanite Research': 'Nanity',
  'Wormhole Research': 'Tunele',
};

export function pointName(type: string): string {
  return pointNames[type] ?? type;
}

export function abbreviatePoint(type: string): string {
  return pointAbbreviations[type] ?? type;
}
