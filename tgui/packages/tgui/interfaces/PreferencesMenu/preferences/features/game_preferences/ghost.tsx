import { binaryInsertWith } from 'common/collections';
import { multiline } from 'common/string';
import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { PreferencesMenuData } from '../../../data';
import {
  CheckboxInput,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureToggle,
  FeatureValueProps,
} from '../base';
import {
  FeatureButtonedDropdownInput,
  FeatureDropdownInput,
} from '../dropdowns';

export const ghost_accs: FeatureChoiced = {
  name: 'Dodatki ducha',
  category: 'GHOST',
  subcategory: 'Appearance',
  description: 'Określa, jakie dodatki ma twój duch.',
  component: FeatureButtonedDropdownInput,
  important: true,
};

type GhostForm = {
  displayText: ReactNode;
  value: string;
};

const insertGhostForm = (collection: GhostForm[], value: GhostForm) =>
  binaryInsertWith(collection, value, ({ value }) => value);

const GhostFormInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  const { data } = useBackend<PreferencesMenuData>();

  const serverData = props.serverData;
  if (!serverData) {
    return <> </>;
  }

  const displayNames = serverData.display_names;
  if (!displayNames) {
    return <Box color="red">Brak nazw wyświetlanych dla ghost_form!</Box>;
  }

  const displayTexts = {};
  let options: {
    displayText: ReactNode;
    value: string;
  }[] = [];

  for (const [name, displayName] of Object.entries(displayNames)) {
    const displayText = (
      <Stack>
        <Stack.Item>
          <Box
            className={classes([
              `${serverData.icon_sheet}32x32`,
              serverData.icons![name],
            ])}
            style={{ verticalAlign: 'bottom' }}
          />
        </Stack.Item>

        <Stack.Item grow style={{ lineHeight: '32px' }}>
          {displayName}
        </Stack.Item>
      </Stack>
    );

    displayTexts[name] = displayText;

    const optionEntry = {
      displayText,
      value: name,
    };

    // Put the default ghost on top
    if (name === 'ghost') {
      options.unshift(optionEntry);
    } else {
      options = insertGhostForm(options, optionEntry);
    }
  }

  return (
    <Dropdown
      autoScroll={false}
      disabled={!data.content_unlocked}
      selected={props.value}
      placeholder={props.value ? displayTexts[props.value] : null}
      clipSelectedText={false}
      onSelected={props.handleSetValue}
      width="100%"
      options={options}
      buttons
    />
  );
};

export const ghost_form: FeatureChoiced = {
  name: 'Wygląd ducha',
  category: 'BYOND MEMBER',
  description: 'Wygląd twojego ducha. Wymaga członkostwa BYOND.',
  component: GhostFormInput,
  important: true,
};

export const ghost_hud: FeatureToggle = {
  name: 'HUD ducha',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Włącza przyciski HUD dla duchów.',
  component: CheckboxInput,
};

export const ghost_orbit: FeatureChoiced = {
  name: 'Kształt orbity ducha',
  category: 'BYOND MEMBER',
  description: multiline`
    Kształt, po którym krąży twój duch.
    Wymaga członkostwa BYOND.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    const { data } = useBackend<PreferencesMenuData>();

    return (
      <FeatureDropdownInput
        buttons
        {...props}
        disabled={!data.content_unlocked}
      />
    );
  },
  important: true,
};

export const ghost_others: FeatureChoiced = {
  name: 'Duchy innych',
  category: 'GHOST',
  subcategory: 'Appearance',
  description: multiline`
    Czy duchy innych mają wyglądać według ich własnych ustawień, jak ich
    domyślne sprite'y, czy zawsze jak domyślny biały duch?
  `,
  component: FeatureButtonedDropdownInput,
  important: true,
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Ciekawski duch',
  category: 'GHOST',
  subcategory: 'Behavior',
  description: 'Kliknięcie czegoś jako duch ogląda to.',
  component: CheckboxInput,
};
