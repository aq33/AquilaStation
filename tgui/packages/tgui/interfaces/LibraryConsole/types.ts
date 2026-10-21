import type { BooleanLike } from 'tgui-core/react';

type CheckoutEntry = {
  borrower: string;
  due_in_minutes: number;
  id: number;
  overdue: BooleanLike;
  ref: string;
  // AQUILA: ile minut temu wypożyczono
  taken_minutes: number;
  title: string;
};

type InventoryEntry = {
  author: string;
  ref: string;
  title: string;
};

type Page = {
  author: string;
  category: string;
  id: string;
  title: string;
};

export type LibraryConsoleData = {
  active_newscaster_cooldown: BooleanLike;
  author: string;
  bible_name: string;
  book_id: string;
  cache_author: string;
  cache_content: string;
  cache_title: string;
  can_connect: BooleanLike;
  can_db_request: BooleanLike;
  category: string;
  checkout_page_count: number;
  checkout_page: number;
  checkout_title: string | null;
  checkouts: CheckoutEntry[];
  cooldown_string: string;
  default_category: string;
  deity: string;
  display_lore: BooleanLike;
  has_cache: BooleanLike;
  has_checkout: BooleanLike;
  has_inventory: BooleanLike;
  has_scanner: BooleanLike;
  inventory_page_count: number;
  inventory_page: number;
  inventory: InventoryEntry[];
  // AQUILA: tytuły z katalogu do wyboru przy wypożyczeniu
  inventory_titles: string[];
  our_page: number;
  page_count: number;
  pages: Page[];
  params_changed: BooleanLike;
  // AQUILA: drukarka bez cooldownu
  printer_ready: BooleanLike;
  religion: string;
  screen_state: number;
  search_categories: string[];
  show_dropdown: BooleanLike;
  title: string;
  upload_categories: string[];
};

/** Kategorie książek z bazy danych (wartości z DM zostają po angielsku) */
export const CATEGORY_NAMES: Record<string, string> = {
  Any: 'Dowolna',
  Fiction: 'Beletrystyka',
  'Non-Fiction': 'Literatura faktu',
  Adult: 'Dla dorosłych',
  Reference: 'Encyklopedie i poradniki',
  Religion: 'Religia',
  Technical: 'Techniczne',
};
