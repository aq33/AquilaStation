import { createDropdownInput, Feature } from '../base';

export const pixel_size: Feature<number> = {
  name: 'Skalowanie pikseli',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'Rozmiar gry i jej ikon w oknie mapy. Rozciągnięcie działa przy każdym rozmiarze ekranu, ale skalowanie co do piksela daje czystszy obraz, jeśli któreś pasuje do twojego okna.',
  component: createDropdownInput({
    0: 'Rozciągnij',
    1: 'Co do piksela 1x',
    1.5: 'Co do piksela 1.5x',
    2: 'Co do piksela 2x',
    3: 'Co do piksela 3x',
    4: 'Co do piksela 4x',
    4.5: 'Co do piksela 4.5x',
    5: 'Co do piksela 5x',
  }),
  important: true,
};
