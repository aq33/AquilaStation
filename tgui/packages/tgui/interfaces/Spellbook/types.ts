import type { BooleanLike } from 'tgui-core/react';

export enum SpellCategory {
  Offensive = 'Offensive',
  Defensive = 'Defensive',
  Mobility = 'Mobility',
  Assistance = 'Assistance',
  Rituals = 'Rituals',
}

export type SpellEntry = {
  // Name of the spell
  name: string;
  // Description of what the spell does
  desc: string;
  // Byond REF of the spell entry datum
  ref: string;
  // Whether the spell requires wizard clothing to cast
  requires_wizard_garb: BooleanLike;
  // Spell points required to buy the spell
  cost: number;
  // How many times the spell has been bought
  times: number;
  // Cooldown length of the spell once cast once
  cooldown: number;
  // Category of the spell
  cat: SpellCategory;
  // Whether the spell is refundable
  refundable: BooleanLike;
  // The verb displayed when buying
  buyword: Buywords;
  // AQUILA: czy wpis można teraz kupić (CanBuy z DM: limit, wykluczenia, rytuał już rzucony)
  can_buy: BooleanLike;
  // AQUILA: czy wpis można teraz zwrócić (CanRefund z DM)
  can_refund: BooleanLike;
  // AQUILA: ile sztuk zostało (null = bez limitu)
  limit: number | null;
  // AQUILA: rytuał już rzucony
  active: BooleanLike;
};

export type SpellbookData = {
  owner: string;
  points: number;
  entries: SpellEntry[];
};

export type TabType = {
  title: string;
} & Partial<{
  // AQUILA: kategoria z DM, bo tytuł strony jest przetłumaczony
  category: SpellCategory;
  blurb: string;
  component: (props?: any) => React.JSX.Element;
  locked: boolean;
  scrollable: boolean;
}>;

export enum Buywords {
  Learn = 'Learn',
  Summon = 'Summon',
  Cast = 'Cast',
}

// AQUILA: bez stron Challenges, Loadouts, Randomize i Perks z tg (nie mamy tych mechanik)
export enum Tab {
  EnscribedName = 0,
  TableOfContents = 1,
  Offensive = 2,
  Defensive = 3,
  Mobility = 4,
  Assistance = 5,
  Rituals = 6,
  TableOfContents2 = 7,
}
