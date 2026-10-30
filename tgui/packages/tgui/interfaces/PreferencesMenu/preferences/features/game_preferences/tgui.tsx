import { CheckboxInput, FeatureToggle } from '../base';

export const tgui_lock: FeatureToggle = {
  name: 'Okna TGUI na głównym monitorze',
  category: 'UI',
  subcategory: 'TGUI',
  description: 'Zatrzymuje okna TGUI na twoim głównym monitorze.',
  component: CheckboxInput,
};

export const screentips: FeatureToggle = {
  name: 'Podpowiedzi na ekranie',
  category: 'UI',
  subcategory: 'HUD',
  description:
    'Włącza podpowiedzi na ekranie z kontekstowymi wskazówkami o niektórych przedmiotach.',
  component: CheckboxInput,
};

export const tgui_say_show_prefix: FeatureToggle = {
  name: 'Zachowaj prefiks radia',
  category: 'UI',
  subcategory: 'TGUI Say',
  description: 'Czy prefiksy radia mają zostawać w polu czatu po wpisaniu.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Okna wprowadzania TGUI',
  category: 'UI',
  subcategory: 'TGUI Input',
  description:
    'Wyświetla okna wprowadzania w TGUI. Po wyłączeniu używane są stare okna.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Duże przyciski',
  category: 'UI',
  subcategory: 'TGUI Input',
  description: 'Przyciski TGUI wypełniają całe okno.',
  component: CheckboxInput,
  important: true,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Zamień przyciski Zatwierdź/Anuluj',
  category: 'UI',
  subcategory: 'TGUI Input',
  description:
    'Zamienia miejscami przyciski Zatwierdź i Anuluj. Po włączeniu Zatwierdź jest po lewej.',
  component: CheckboxInput,
};

export const tgui_say: FeatureToggle = {
  name: 'TGUI Say',
  category: 'UI',
  subcategory: 'TGUI Say',
  description:
    'Wyświetla pole mowy w TGUI. Po wyłączeniu używane jest stare okno.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Jasny motyw',
  category: 'UI',
  subcategory: 'TGUI Say',
  description: 'Włącza jasny motyw w TGUI Say.',
  component: CheckboxInput,
  important: true,
};

export const tgui_asay: FeatureToggle = {
  name: 'TGUI ASay/MSay/DSay',
  category: 'UI',
  subcategory: 'TGUI Say',
  description:
    'Wyświetla pole ASay/MSay/DSay w TGUI. Po wyłączeniu używane jest stare okno.',
  component: CheckboxInput,
};
