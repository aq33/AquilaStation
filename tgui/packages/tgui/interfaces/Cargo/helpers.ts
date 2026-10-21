import { filter } from 'es-toolkit/compat';
import { flow } from 'tgui-core/fp';

import type { CargoData, Supply, SupplyCategory } from './types';

/**
 * Take entire supplies tree
 * and return a flat supply pack list that matches search,
 * sorted by name and only the first page.
 * @param {Supply[]} supplies Supplies list, from useSupplies()
 * @param {string} search The search term
 * @returns {Supply[]} The flat list of supply packs.
 */
export function searchForSupplies(
  supplies: SupplyCategory[],
  search: string,
): Supply[] {
  const lowerSearch = search.toLowerCase();

  return flow([
    // Flat categories
    (initialSupplies: SupplyCategory[]) =>
      initialSupplies.flatMap((category) => category.packs),
    // Filter by name or desc
    (flatMapped: Supply[]) =>
      filter(
        flatMapped,
        (pack: Supply) =>
          pack.name?.toLowerCase().includes(lowerSearch) ||
          pack.desc?.toLowerCase().includes(lowerSearch),
      ),
    // Just the first page
    (filtered: Supply[]) => filtered.slice(0, 25),
  ])(supplies);
}

/**
 * AQUILA: nasz DM wysyła katalog od razu w danych okna (słownik grup),
 * zamiast pliku katalogu pobieranego osobno jak w tg.
 */
export function getSupplies(data: CargoData): SupplyCategory[] {
  const { supplies } = data;
  if (!supplies) {
    return [];
  }
  const categories = Array.isArray(supplies)
    ? supplies
    : Object.values(supplies);
  return categories.filter((category) => category.packs?.length > 0);
}

/** Ilość sztuk we wpisie koszyka (program PDA nie wysyła ilości) */
export function entryAmount(entry: { amount?: number }): number {
  return entry.amount ?? 1;
}
