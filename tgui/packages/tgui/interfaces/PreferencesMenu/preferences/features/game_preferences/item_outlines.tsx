import {
  CheckboxInput,
  Feature,
  FeatureColorInput,
  FeatureToggle,
} from '../base';

export const itemoutline_pref: FeatureToggle = {
  name: 'Obrysy przedmiotów',
  category: 'UI',
  subcategory: 'HUD',
  description:
    'Po włączeniu najechanie kursorem na przedmiot pokazuje jego obrys.',
  component: CheckboxInput,
};

export const outline_color: Feature<string> = {
  name: 'Kolor obrysu przedmiotów',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Kolor obrysu przedmiotów pod kursorem.',
  component: FeatureColorInput,
  important: true,
};
