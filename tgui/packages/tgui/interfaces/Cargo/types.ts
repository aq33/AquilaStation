import type { BooleanLike } from 'tgui-core/react';

export type CargoData = {
  /** Program PDA (NtosCargo) - zamówienia z aplikacji są droższe */
  app_cost?: BooleanLike;
  away: BooleanLike;
  can_approve_requests: BooleanLike;
  can_send: BooleanLike;
  cart: CartEntry[];
  department: string;
  docked: BooleanLike;
  loan_dispatched: BooleanLike;
  loan: BooleanLike;
  location: string;
  /** NSV13: przyjmowanie poczty na promie */
  mail?: BooleanLike;
  message: string;
  points: number;
  requests: Request[];
  requestonly: BooleanLike;
  self_paid: BooleanLike;
  supplies: Record<string, SupplyCategory> | SupplyCategory[];
};

export type SupplyCategory = {
  name: string;
  packs: Supply[];
};

export type Supply = {
  access: BooleanLike;
  cost: number;
  desc: string;
  first_item_icon?: string | null;
  first_item_icon_state?: string | null;
  id: string;
  name: string;
  small_item?: BooleanLike;
  contraband?: BooleanLike;
  contains?: SupplyItem[];
};

type SupplyItem = {
  name: string;
  icon: string | null;
  icon_state: string | null;
  amount: number;
};

export type CartEntry = {
  /** Brak w programie PDA - wtedy każdy wpis to jedna sztuka */
  amount?: number;
  cost: number;
  id: string;
  object: string;
  orderer: string;
  /** Konsola: ile sztuk opłacono prywatnie, PDA: czy opłacone przez zamawiającego */
  paid: number | BooleanLike;
};

type Request = {
  cost: number;
  id: string;
  object: string;
  orderer: string;
  account?: string | null;
  reason: string;
};

/** Najwięcej sztuk jednej paczki w koszyku */
export const MAX_ORDER = 50;

/** Waluta wyświetlana przy cenach */
export const CURRENCY = ' cr';
