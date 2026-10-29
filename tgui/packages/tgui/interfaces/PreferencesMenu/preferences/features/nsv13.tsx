// AQUILA: ustawienia, których nie ma w BeeStation (NSV13 i nasze), do okna PreferencesMenu
import { Box, Button, Stack } from 'tgui-core/components';

import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureNumeric,
  FeatureSliderInput,
  FeatureToggle,
  FeatureValueProps,
} from './base';
import { FeatureButtonedDropdownInput } from './dropdowns';

// Postać

export const feature_ethcolor: FeatureChoiced = {
  name: 'Kolor eteryka',
  component: FeatureButtonedDropdownInput,
};

export const feature_ipc_chassis: FeatureChoiced = {
  name: 'Obudowa',
  component: FeatureButtonedDropdownInput,
};

export const preferred_pilot_role: FeatureChoiced = {
  name: 'Preferowana rola pilota',
  component: FeatureButtonedDropdownInput,
};

export const preferred_squad: FeatureChoiced = {
  name: 'Preferowana drużyna (GQ)',
  component: FeatureButtonedDropdownInput,
};

export const lizard_hiss_style: FeatureChoiced = {
  name: 'Syk jaszczura',
  component: FeatureButtonedDropdownInput,
};

export const preferred_syndie_role: Feature<string> = {
  name: 'Preferowana rola w Syndykacie',
  component: (props: FeatureValueProps<string>) => {
    const { act, value } = props;

    return (
      <Stack align="center">
        <Stack.Item grow>{value}</Stack.Item>
        <Stack.Item>
          <Button icon="pen" onClick={() => act('open_syndie_roles')}>
            Zmień
          </Button>
        </Stack.Item>
      </Stack>
    );
  },
};

/** Długi tekst edytowany w okienku serwera, tu tylko podgląd */
const TextPreferenceInput = (props: FeatureValueProps<string>) => {
  const { act, featureId, value } = props;

  return (
    <Stack align="center">
      <Stack.Item grow basis={0} style={{ overflow: 'hidden' }}>
        <Box
          color={value ? undefined : 'label'}
          style={{
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {value || 'Pusto'}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="pen"
          tooltip={value || undefined}
          onClick={() => act('edit_text_preference', { preference: featureId })}
        >
          Edytuj
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const flavor_text: Feature<string> = {
  name: 'Opis postaci',
  predictable: false,
  component: TextPreferenceInput,
};

export const silicon_flavor_text: Feature<string> = {
  name: 'Opis syntetyka',
  predictable: false,
  component: TextPreferenceInput,
};

export const general_record: Feature<string> = {
  name: 'Akta ogólne',
  predictable: false,
  component: TextPreferenceInput,
};

export const security_record: Feature<string> = {
  name: 'Akta ochrony',
  predictable: false,
  component: TextPreferenceInput,
};

export const medical_record: Feature<string> = {
  name: 'Akta medyczne',
  predictable: false,
  component: TextPreferenceInput,
};

// Ustawienia gry

export const sound_lobby: FeatureToggle = {
  name: 'Muzyka w lobby',
  category: 'SOUND',
  subcategory: 'Music',
  component: CheckboxInput,
  important: true,
};

export const sound_midi: FeatureToggle = {
  name: 'Muzyka od adminów',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'Odtwarzaj muzykę puszczaną przez adminów.',
  component: CheckboxInput,
  important: true,
};

export const sound_instruments: FeatureToggle = {
  name: 'Instrumenty',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'Słysz instrumenty, na których grają inni gracze.',
  component: CheckboxInput,
  important: true,
};

export const sound_ambience: FeatureToggle = {
  name: 'Dźwięki otoczenia',
  category: 'SOUND',
  subcategory: 'Ambience',
  component: CheckboxInput,
  important: true,
};

export const sound_ship_ambience: FeatureToggle = {
  name: 'Odgłosy statku',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: 'Szum statku w tle.',
  component: CheckboxInput,
  important: true,
};

export const tesla_volume: FeatureNumeric = {
  name: 'Głośność tesli',
  category: 'SOUND',
  subcategory: 'IC',
  component: FeatureSliderInput,
};

export const chat_looc: FeatureToggle = {
  name: 'Widzisz LOOC',
  category: 'CHAT',
  subcategory: 'OOC',
  component: CheckboxInput,
};

export const widescreen: FeatureToggle = {
  name: 'Panoramiczny widok',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  component: CheckboxInput,
  important: true,
};

export const walk_animation: FeatureToggle = {
  name: 'Animacja chodu',
  category: 'GRAPHICS',
  subcategory: 'Misc',
  description: 'Animuje ręce i nogi twojej postaci podczas chodzenia.',
  component: CheckboxInput,
};

export const tgui_fancy: FeatureToggle = {
  name: 'Ozdobne okna TGUI',
  category: 'UI',
  subcategory: 'TGUI',
  description: 'Okna TGUI bez ramek systemowych.',
  component: CheckboxInput,
};

export const announce_login: FeatureToggle = {
  name: 'Ogłaszaj logowanie',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Admini dostają powiadomienie, gdy się logujesz.',
  component: CheckboxInput,
};
