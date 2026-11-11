import {
  CheckboxInput,
  createDropdownInput,
  Feature,
  FeatureToggle,
} from '../base';

export const soft_lighting: FeatureToggle = {
  name: 'Miękkie światło',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Wygładza przejścia między światłem a cieniem, zamiast kafelkowych schodków. Liczy to tylko karta graficzna.',
  component: CheckboxInput,
};

export const glow_level: Feature<number> = {
  name: 'Poświata',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Miękka poświata wokół świecących rzeczy: ekranów, lamp, pocisków energetycznych. Wyłączenie trochę odciąża kartę graficzną.',
  component: createDropdownInput({
    0: 'Wyłączona',
    1: 'Słaba',
    2: 'Średnia',
    3: 'Mocna',
  }),
};

export const light_glare: FeatureToggle = {
  name: 'Promienie świateł',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Smugi światła od lamp, ekranów i laserów, rozchodzące się od środka ekranu. Działa tylko z włączoną poświatą.',
  component: CheckboxInput,
};
