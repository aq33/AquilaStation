import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const game_language: FeatureChoiced = {
  name: 'Język gry / Game language',
  category: 'UI',
  description:
    'Tłumaczy czat, okna, panel, menu Esc, dymki, runechat, screentipy, okienka i napisy na guzikach HUD-u. Otwarte okno zmienia język przy następnym odświeżeniu. Tekst pisany przez graczy zostaje bez zmian. / Translates the chat, windows, the panel, the Esc menu, balloon alerts, runechat, screentips, dialogs and HUD button labels. An open window switches on its next refresh. Text written by players stays as it is.',
  component: FeatureDropdownInput,
};
