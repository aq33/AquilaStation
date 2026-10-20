import type { BooleanLike } from 'tgui-core/react';

export enum ModifyTypes {
  Delete = 'delete',
  Restore = 'restore',
}

export type Book = {
  author: string;
  category: string;
  title: string;
  id: number;
};

export type LibraryAdminData = {
  author_ckey: string;
  author: string;
  book_id: number;
  can_connect: BooleanLike;
  can_db_request: BooleanLike;
  category: string;
  our_page: number;
  page_count: number;
  pages: Book[];
  params_changed: BooleanLike;
  search_categories: string[];
  show_deleted: BooleanLike;
  title: string;
};
