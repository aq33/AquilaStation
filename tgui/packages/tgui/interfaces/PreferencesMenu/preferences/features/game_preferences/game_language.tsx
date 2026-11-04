import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const game_language: FeatureChoiced = {
  name: 'Język gry / Game language',
  category: 'UI',
  description:
    'Wersja testowa: tłumaczy czat, examine, panel statystyk, okna, dymki, runechat i screentipy. Otwarte okno zmienia język przy następnym odświeżeniu. Nazwy obiektów pod kursorem zostają po polsku. / Experimental: translates the chat, examine, the stat panel, windows, balloon alerts, runechat and screentips. An open window switches on its next refresh. Object names under the cursor stay Polish.',
  component: FeatureDropdownInput,
};
