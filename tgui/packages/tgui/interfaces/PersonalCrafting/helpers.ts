import type { BooleanLike } from 'tgui-core/react';

import {
  CATEGORY_ICONS_COOKING,
  CATEGORY_ICONS_CRAFTING,
  CATEGORY_NAMES,
  FOODTYPE_NAMES,
  TOOL_NAMES,
} from './constants';
import type { CraftingData } from './types';

export function findIcon(atom_id: number, data: CraftingData): string {
  let icon: string = data.icon_data[atom_id];
  if (!icon) {
    icon = `${data.mode ? 'cooking32x32' : 'crafting32x32'} a${atom_id}`;
  }

  return icon;
}

export function getFAIcon(category: string, mode: BooleanLike): string {
  const icons = mode ? CATEGORY_ICONS_COOKING : CATEGORY_ICONS_CRAFTING;
  return icons[category] || 'circle';
}

export function categoryName(category: string): string {
  return CATEGORY_NAMES[category] || category;
}

export function foodtypeName(foodtype: string): string {
  return FOODTYPE_NAMES[foodtype] || foodtype.toLowerCase();
}

export function toolName(tool: string): string {
  return TOOL_NAMES[tool] || tool;
}
