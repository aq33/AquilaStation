import type { BooleanLike } from 'tgui-core/react';

/** Wiadomość tak, jak trzyma ją nasz DM (płaska lista w programie komunikatora). */
export type NtMessage = {
  name: string;
  job: string;
  /** Tylko wychodzące: tekst „Imię (Stanowisko)” odbiorcy */
  target?: string;
  /** Tylko wychodzące: REF urządzenia odbiorcy */
  target_ref?: string | null;
  contents: string;
  outgoing: BooleanLike;
  /** Przychodzące: REF urządzenia nadawcy, wychodzące: REF własnego urządzenia */
  ref: string;
  automated?: BooleanLike;
  everyone?: BooleanLike;
  unread?: BooleanLike;
  timestamp?: string;
  emojis?: BooleanLike;
  photo?: string;
  photo_width?: number;
  photo_height?: number;
};

export type NtMessenger = {
  name: string;
  job: string;
  ref?: string;
};

/** Rozmowa składana po stronie okna z płaskiej listy wiadomości. */
export type NtChat = {
  ref: string;
  recipient: NtMessenger;
  messages: NtMessage[];
  can_reply: boolean;
  unread_messages: number;
  /** Indeks ostatniej wiadomości w płaskiej liście, do sortowania od najnowszych */
  last_index: number;
};

export type NtosMessengerData = {
  owner: string | null;
  messages: NtMessage[];
  messengers: NtMessenger[];
  ringer_status: BooleanLike;
  sending_and_receiving: BooleanLike;
  sortByJob: BooleanLike;
  isSilicon: BooleanLike;
  photo: string | null;
  canSpam?: BooleanLike;
  virus_attach?: BooleanLike;
  sending_virus?: BooleanLike;
  // static
  emoji_names: string[];
};

/** Klucz rozmowy z wiadomościami „do wszystkich” */
export const EVERYONE_CHAT = 'everyone';
