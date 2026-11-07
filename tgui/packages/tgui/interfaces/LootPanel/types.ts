export type SearchItem = {
  name: string;
  /** null dla mobów i pól (DM wysyła typ tylko dla obiektów) */
  path: string | null;
  ref: string;
} & Partial<{
  icon: string;
  icon_state: string;
}>;

export type SearchGroup = {
  amount: number;
  item: SearchItem;
};
