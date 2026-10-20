import type { BooleanLike } from 'tgui-core/react';

export enum MODE {
  crafting,
  cooking,
}

// AQUILA EDIT - zostaje nasza zakładka typów jedzenia (tg filtruje kuchnie
// w kategorii Foods, a nasze przepisy nie mają kuchni/dań/posiłków)
export enum TABS {
  category,
  material,
  foodtype,
}

export type AtomData = {
  name: string;
  is_reagent: BooleanLike;
  icon: string;
};

export type Material = {
  atom_id: string;
  occurences: number;
};

export type Recipe = {
  category: string;
  chem_catalysts: Record<number, number>;
  desc: string;
  id: number;
  is_reaction: BooleanLike;
  machinery: string[];
  mass_craftable: BooleanLike;
  name: string;
  non_craftable: BooleanLike;
  ref: string;
  reqs: Record<number, number>;
  steps: string[];
  structures: string[];
  tool_behaviors: string[];
  tool_paths: string[];
  // tylko dla przepisów kuchennych
  foodtypes?: string[];
  complexity?: number;
};

export type Diet = {
  disliked_food: string[];
  liked_food: string[];
  toxic_food: string[];
};

export type CraftingData = {
  // Dynamic
  busy: BooleanLike;
  craftability: Record<string, BooleanLike>;
  display_compact: BooleanLike;
  display_craftable_only: BooleanLike;
  // nasz DM tego nie wysyła - przełącznik trybu jest zawsze widoczny
  forced_mode?: BooleanLike;
  mode: BooleanLike;
  // Static
  atom_data: AtomData[];
  categories: string[];
  diet: Diet;
  foodtypes: string[];
  icon_data: Record<number, string>;
  material_occurences: Material[];
  recipes: Recipe[];
};
