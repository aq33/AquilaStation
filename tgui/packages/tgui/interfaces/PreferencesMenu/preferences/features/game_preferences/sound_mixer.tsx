// AQUILA: mikser dźwięku, suwaki z aquila/code/modules/client/sound_mixer.dm
import { FeatureNumeric, FeatureSliderInput } from '../base';

export const sound_mixer_ship_alerts: FeatureNumeric = {
  name: 'Alarmy okrętu',
  category: 'SOUND',
  subcategory: 'Mixer',
  description:
    'Alarm bojowy, rozruch napędu FTL, alarmy reaktora i kadłuba, namierzanie.',
  component: FeatureSliderInput,
};

export const sound_mixer_ship_fx: FeatureNumeric = {
  name: 'Broń i efekty okrętu',
  category: 'SOUND',
  subcategory: 'Mixer',
  description:
    'Salwy i trafienia w walce okrętów, manewry, skrzypienie kadłuba.',
  component: FeatureSliderInput,
};

export const sound_mixer_guns: FeatureNumeric = {
  name: 'Broń ręczna',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Strzały z broni ręcznej, także odległe.',
  component: FeatureSliderInput,
};

export const sound_mixer_emotes: FeatureNumeric = {
  name: 'Emotki',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Dźwięki emotek: krzyk, śmiech, kaszel, klaskanie.',
  component: FeatureSliderInput,
};

export const sound_mixer_voices: FeatureNumeric = {
  name: 'Mowa postaci',
  category: 'SOUND',
  subcategory: 'Mixer',
  description:
    'Dźwięki mowy postaci. Rodzaj głosu wybierasz w ustawieniu dźwięków mowy.',
  component: FeatureSliderInput,
};

export const sound_mixer_bots: FeatureNumeric = {
  name: 'Głosy botów',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Nagrane kwestie medibotów, secbotów i innych botów.',
  component: FeatureSliderInput,
};

export const sound_mixer_tts: FeatureNumeric = {
  name: 'Synteza mowy',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Czytane rozkazy drużyny i ogłoszenia SI.',
  component: FeatureSliderInput,
};

export const sound_mixer_announcements: FeatureNumeric = {
  name: 'Ogłoszenia',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Dźwięki ogłoszeń dowództwa i komunikatów.',
  component: FeatureSliderInput,
};

export const sound_mixer_ambience: FeatureNumeric = {
  name: 'Otoczenie',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Dźwięki otoczenia i szum statku w tle.',
  component: FeatureSliderInput,
};

export const sound_mixer_ambient_music: FeatureNumeric = {
  name: 'Muzyka otoczenia',
  category: 'SOUND',
  subcategory: 'Mixer',
  description: 'Muzyka grająca w tle w niektórych miejscach.',
  component: FeatureSliderInput,
};
