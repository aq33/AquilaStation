import type { BooleanLike } from 'tgui-core/react';

type StoredNodes = Record<string, BooleanLike>;

type DesignDisk = {
  max_blueprints: number;
  blueprints: (string | null)[];
};

type TechDisk = {
  stored_research: StoredNodes;
};

// Węzeł tak, jak przychodzi z DM (ID skompresowane)
type DefaultNode = {
  name: string;
  description: string;
  node_tier: number;
  prereq_ids?: number[];
  design_ids?: number[];
  unlock_ids?: number[];
};

// Węzeł po rozpakowaniu ID
export type NodeCache = {
  id: string;
  name: string;
  description: string;
  node_tier: number;
  prereq_ids: string[];
  design_ids: string[];
  unlock_ids: string[];
};

export type DesignCache = {
  name: string;
  class: string;
};

// Węzły widoczne w sieci badań
export type TechwebNode = {
  id: string;
  can_unlock?: BooleanLike;
  costs?: Record<string, number>;
  /** 0 = zbadany, 1 = dostępny, 2+ = przyszły */
  tier?: number;
};

type StaticData = {
  design_cache: Record<string, [string, string]>;
  id_cache: string[];
  node_cache: Record<string, DefaultNode>;
};

export type TechWebData = {
  analyzeritem: string | null;
  analyzertechs: Record<string, number> | null;
  compact: BooleanLike;
  d_disk: DesignDisk | null;
  itemmats: string[] | null;
  itempoints: string[] | null;
  linkedanalyzer: BooleanLike;
  locked: BooleanLike;
  nodes: TechwebNode[];
  points_last_tick: Record<string, number>;
  points: Record<string, number>;
  researchable: BooleanLike;
  researched_designs: Record<string, BooleanLike>;
  sec_protocols: BooleanLike;
  static_data: StaticData;
  t_disk: TechDisk | null;
  tech_tier: number;
  web_org: string;
};
