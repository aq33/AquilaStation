import {
  CheckboxInput,
  FeatureNumberInput,
  FeatureNumeric,
  FeatureToggle,
} from '../base';

export const gun_cursor: FeatureToggle = {
  name: 'Kursor rozrzutu broni',
  category: 'GAMEPLAY',
  description:
    'Z odbezpieczoną bronią w ręku kursor zmienia się w celownik. Rogi rozsuwają się, gdy rośnie rozrzut: w ruchu, z jednej ręki i przy długiej serii.',
  component: CheckboxInput,
};

export const face_cursor_combat: FeatureToggle = {
  name: 'Patrz na kursor w trybie walki',
  category: 'GAMEPLAY',
  description:
    'W trybie walki (albo na intencji krzywdzenia) postać zawsze patrzy w stronę kursora, także gdy idzie w bok albo do tyłu.',
  component: CheckboxInput,
};

export const recoil_camera_strength: FeatureNumeric = {
  name: 'Siła odrzutu ekranu',
  category: 'GAMEPLAY',
  description:
    'Jak mocno ekran podskakuje przy strzale (w procentach). 0 wyłącza kopnięcie kamery, odrzut nadal psuje celność.',
  component: FeatureNumberInput,
};
