import { createDropdownInput, Feature } from '../base';

export const scaling_method: Feature<string> = {
  name: 'Metoda skalowania',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'Algorytm, którym BYOND skaluje obiekty gry. Najlepiej wygląda próbkowanie punktowe, potem najbliższy sąsiad.',
  component: createDropdownInput({
    blur: 'Dwuliniowe',
    distort: 'Najbliższy sąsiad',
    normal: 'Próbkowanie punktowe',
  }),
  important: true,
};
