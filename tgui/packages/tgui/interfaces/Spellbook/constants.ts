import { EnscribedName } from './EnscribedName';
import { TableOfContents } from './TableOfContents';
import { SpellCategory, type TabType } from './types';

export const TAB2NAME: TabType[] = [
  {
    title: 'Wpisane imię',
    blurb:
      'Ta księga słucha tylko swojego właściciela i oczywiście musi go mieć. Trwałość paktu między księgą a właścicielem sprawia, że tak potężny artefakt nie wpadnie w ręce wroga ani nie posłuży do łamania zasad Federacji, choćby do handlu zaklęciami.',
    component: EnscribedName,
  },
  {
    title: 'Spis treści',
    component: TableOfContents,
  },
  {
    title: 'Ofensywne',
    category: SpellCategory.Offensive,
    blurb: 'Zaklęcia i przedmioty do osłabiania i niszczenia.',
    scrollable: true,
  },
  {
    title: 'Defensywne',
    category: SpellCategory.Defensive,
    blurb:
      'Zaklęcia i przedmioty zwiększające szanse na przetrwanie lub osłabiające ataki wrogów.',
    scrollable: true,
  },
  {
    title: 'Mobilność',
    category: SpellCategory.Mobility,
    blurb:
      'Zaklęcia i przedmioty poprawiające twoją mobilność. Warto wziąć choć jedno.',
    scrollable: true,
  },
  {
    title: 'Wsparcie',
    category: SpellCategory.Assistance,
    blurb:
      'Zaklęcia i przedmioty sprowadzające zewnętrzne siły do pomocy lub ulepszające inne przedmioty i zdolności.',
    scrollable: true,
  },
  {
    title: 'Rytuały',
    category: SpellCategory.Rituals,
    blurb:
      'Te potężne zaklęcia zmieniają samą tkankę rzeczywistości. Nie zawsze na twoją korzyść.',
    scrollable: true,
  },
  {
    title: 'Spis treści',
    component: TableOfContents,
  },
];

export const BUYWORD2ICON = {
  Learn: 'plus',
  Summon: 'hat-wizard',
  Cast: 'meteor',
};

export const BUYWORD2NAME = {
  Learn: 'Naucz się',
  Summon: 'Przywołaj',
  Cast: 'Rzuć',
};

// Do wyszukiwania po polskiej nazwie kategorii
export const CATEGORY2NAME = {
  Offensive: 'ofensywne',
  Defensive: 'defensywne',
  Mobility: 'mobilność',
  Assistance: 'wsparcie',
  Rituals: 'rytuały',
};
