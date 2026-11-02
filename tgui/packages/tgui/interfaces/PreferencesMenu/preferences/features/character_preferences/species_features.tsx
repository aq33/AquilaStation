import {
  Feature,
  FeatureChoiced,
  FeatureColorInput,
  FeatureValueProps,
} from '../base';
import {
  FeatureButtonedDropdownInput,
  StandardizedPalette,
} from '../dropdowns';

const eyePresets = {
  '#aaccff': 'Błękitny',
  '#0099bb': 'Niebieskozielony',
  '#3399ff': 'Jasnoniebieski',
  '#0066ff': 'Niebieski',
  '#337788': 'Morski',
  '#005577': 'Ciemny lazurowy',
  '#889988': 'Karczochowy',
  '#447766': 'Zielononiebieski',
  '#117744': 'Morska zieleń',
  '#336611': 'Leśna zieleń',
  '#aaaa66': 'Piwny',
  '#554411': 'Brązowozielony',
  '#664433': 'Brązowy',
  '#663300': 'Głęboki brąz',
  '#441100': 'Ciemny brąz',
  '#884400': 'Bursztynowy',
  '#667788': 'Szary',
  '#445566': 'Ciemnoszary',
  '#eeeeee': 'Biały (albinos)',
  '#ccaaaa': 'Różowy (albinos)',
  '#bbddee': 'Niebieski (albinos)',
};

export const eye_color: Feature<string> = {
  name: 'Kolor oczu',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(eyePresets)}
        displayNames={eyePresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="100%"
        includeHex
      />
    );
  },
};

const hairPresets = {
  '#111111': 'Czarny',
  '#222222': 'Prawie czarny',
  '#332222': 'Ciemny brąz',
  '#443322': 'Ciemnobrązowy',
  '#443333': 'Średni ciemny brąz',
  '#553333': 'Ciemny kasztan',
  '#664444': 'Jasny kasztan',
  '#554433': 'Ciemny złoty brąz',
  '#997766': 'Jasny popielaty brąz',
  '#aa8866': 'Jasny złoty brąz',
  '#bb9977': 'Ciemny miodowy blond',
  '#ddbb99': 'Jasny popielaty blond',
  '#eeccaa': 'Jasny blond',
  '#eeddbb': 'Rozjaśniony blond',
  '#666666': 'Ciemnoszary',
  '#999999': 'Średnioszary',
  '#bbbbbb': 'Jasnoszary',
  '#ffeeee': 'Biały',
  '#884444': 'Miękki kasztanowy rudy',
  '#bb5544': 'Miękka terakota',
  '#aa5500': 'Rudobrązowy',
  '#cc5522': 'Rudy',
  '#ff0000': 'Jaskrawa czerwień',
  '#aa0000': 'Czerwony',
  '#ff7700': 'Jaskrawy pomarańcz',
  '#ffff00': 'Jaskrawa żółć',
  '#aa9900': 'Żółty',
  '#00ff00': 'Jaskrawa zieleń',
  '#00aa00': 'Zielony',
  '#00ccaa': 'Turkusowy',
  '#00ffff': 'Jaskrawy cyjan',
  '#00aaaa': 'Cyjan',
  '#229988': 'Morski',
  '#0000ff': 'Jaskrawy niebieski',
  '#0000aa': 'Niebieski',
  '#6600ff': 'Jaskrawy indygo',
  '#9922ff': 'Purpurowy',
  '#8800ff': 'Fioletowy',
  '#550088': 'Ciemna purpura',
  '#ff00ff': 'Jaskrawa magenta',
  '#aa00aa': 'Magenta',
  '#ff0066': 'Malinowy',
  '#ff2288': 'Jaskraworóżowy',
  '#ff99bb': 'Różowy',
  '#ee8888': 'Blady róż',
};

export const facial_hair_color: Feature<string> = {
  name: 'Kolor zarostu',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const facial_hair_gradient: FeatureChoiced = {
  name: 'Gradient zarostu',
  component: FeatureButtonedDropdownInput,
};

export const facial_hair_gradient_color: Feature<string> = {
  name: 'Kolor gradientu zarostu',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const hair_color: Feature<string> = {
  name: 'Kolor włosów',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const gradient_style: FeatureChoiced = {
  name: 'Gradient włosów',
  component: FeatureButtonedDropdownInput,
};

export const gradient_color: Feature<string> = {
  name: 'Kolor gradientu',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(hairPresets)}
        displayNames={hairPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="385px"
        includeHex
      />
    );
  },
};

export const feature_lizard_legs: FeatureChoiced = {
  name: 'Typ nóg',
  component: FeatureButtonedDropdownInput,
};

export const feature_mcolor: Feature<string> = {
  name: 'Kolor mutanta',
  component: FeatureColorInput,
};

export const underwear_color: Feature<string> = {
  name: 'Kolor bielizny',
  component: FeatureColorInput,
};

export const helmet_style: FeatureChoiced = {
  name: 'Styl hełmu',
  component: FeatureButtonedDropdownInput,
};

export const feature_ipc_antenna_color: Feature<string> = {
  name: 'Kolor anteny',
  component: FeatureColorInput,
};

export const feature_ipc_screen_color: Feature<string> = {
  name: 'Kolor ekranu',
  component: FeatureColorInput,
};

export const feature_human_tail: FeatureChoiced = {
  name: 'Ogon',
  component: FeatureButtonedDropdownInput,
};

export const feature_human_ears: FeatureChoiced = {
  name: 'Uszy',
  component: FeatureButtonedDropdownInput,
};

export const feature_insect_type: FeatureChoiced = {
  name: 'Typ owada',
  component: FeatureButtonedDropdownInput,
};

export const feature_moth_eyes: FeatureChoiced = {
  name: 'Typ oczu',
  component: FeatureButtonedDropdownInput,
};
