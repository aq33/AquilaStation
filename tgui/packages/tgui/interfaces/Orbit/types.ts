import type { BooleanLike } from 'tgui-core/react';

import type { VIEWMODE } from './constants';

export type Antagonist = Observable & {
  antag: string;
  antag_group: string;
  /** AQUILA EDIT - klasa ze spritesheetu antag-hud zamiast DmIcon */
  antag_icon?: string;
};

export type AntagGroup = [string, Antagonist[]];

export type OrbitData = {
  alive: Observable[];
  antagonists: Antagonist[];
  critical: Critical[];
  dead: Observable[];
  deadchat_controlled: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
  orbiting: Observable | null;
  can_observe: BooleanLike;
};

export type Observable = {
  full_name: string;
  ref: string;
  // Optionals
} & Partial<{
  client: BooleanLike;
  extra: string;
  health: number;
  job: string;
  mind_job: string;
  /** AQUILA EDIT - dział liczony w DM (orbit.dm), zamiast listy prac w tsx */
  department: string;
  /** AQUILA EDIT - ikony prac ze spritesheetu job-icon zamiast DmIcon */
  role_icon: string;
  mind_role_icon: string;
  name: string;
  orbiters: number;
  ckey: string;
}>;

type Critical = {
  extra: string;
  full_name: string;
  ref: string;
};

export type ViewMode = (typeof VIEWMODE)[keyof typeof VIEWMODE];
