import {
  CheckboxInput,
  type Feature,
  FeatureSliderInput,
  FeatureToggle,
} from '../base';

export const sound_adminhelp: FeatureToggle = {
  name: 'Dźwięki adminhelpów',
  category: 'ADMIN',
  subcategory: 'Sound',
  component: CheckboxInput,
  important: true,
};

export const sound_ambience_volume: Feature<number> = {
  name: 'Głośność otoczenia',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: `Głośność różnych dźwięków zależnych od obszaru stacji, w którym jesteś.`,
  component: FeatureSliderInput,
  important: true,
};

export const sound_announcements: FeatureToggle = {
  name: 'Dźwięki ogłoszeń',
  category: 'SOUND',
  subcategory: 'IC',
  description:
    'Po włączeniu słyszysz dźwięki raportów dowództwa, komunikatów itp.',
  component: CheckboxInput,
  important: true,
};

export const sound_ghostpoll: FeatureToggle = {
  name: 'Dźwięk naboru duchów',
  category: 'SOUND',
  description:
    'Po włączeniu słyszysz sygnał, gdy trwa nabór na rolę dla ducha.',
  component: CheckboxInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Dźwięk trybu walki',
  category: 'SOUND',
  description: 'Odtwarza dźwięk przy włączaniu i wyłączaniu trybu walki.',
  component: CheckboxInput,
};

export const sound_instruments_volume: Feature<number> = {
  name: 'Głośność instrumentów',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'Głośność instrumentów muzycznych.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_lobby_volume: Feature<number> = {
  name: 'Głośność muzyki w lobby',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'Głośność muzyki na ekranie tytułowym.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_midi_volume: Feature<number> = {
  name: 'Głośność muzyki od adminów',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'Głośność muzyki puszczanej przez adminów.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_prayers: FeatureToggle = {
  name: 'Dźwięki modlitw',
  category: 'ADMIN',
  subcategory: 'Sound',
  component: CheckboxInput,
  important: true,
};

export const sound_adminalert: FeatureToggle = {
  name: 'Dźwięki alertów admina',
  category: 'ADMIN',
  subcategory: 'Sound',
  description:
    'Włącza dźwięk przy różnych powiadomieniach dla adminów, na przykład o midroundach i eventach.',
  component: CheckboxInput,
  important: true,
};

export const sound_ambient_buzz_volume: Feature<number> = {
  name: 'Głośność szumu otoczenia',
  category: 'SOUND',
  subcategory: 'Ambience',
  description:
    'Głośność niskiego buczenia zależnego od obszaru, w którym jesteś.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_weather_volume: Feature<number> = {
  name: 'Głośność pogody',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: 'Głośność dźwięków pogody.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_soundtrack_volume: Feature<number> = {
  name: 'Głośność ścieżki dźwiękowej',
  category: 'SOUND',
  subcategory: 'Music',
  description:
    'Głośność ścieżek dźwiękowych, na przykład odliczania do wybuchu atomówki albo inwazji ksenomorfów.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_ai_vox_volume: Feature<number> = {
  name: 'Głośność ogłoszeń VOX SI',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'Głośność mówionych ogłoszeń SI (tzw. „VOX”).',
  component: FeatureSliderInput,
  important: true,
};

export const sound_radio_noise: FeatureToggle = {
  name: 'Szumy radia',
  category: 'SOUND',
  description:
    'Po włączeniu słyszysz dźwięki mówienia i odbierania rozmów przez radio.',
  component: CheckboxInput,
};
