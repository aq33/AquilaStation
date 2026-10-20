import { useState } from 'react';
import {
  Button,
  Icon,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AirLockMainSection } from './AirlockElectronics';

type Data = {
  matterLeft: number;
  silo_upgraded: BooleanLike;
  silo_enabled: BooleanLike;
  root_categories: string[];
  selected_root: string;
  categories: Category[];
  selected_category: string | null;
  selected_design: string | null;
  display_tabs: BooleanLike;
};

type Category = {
  cat_name: string;
  designs: Design[];
};

// AQUILA: zamiast arkusza sprite'ów rcd-tgui32x32 z tg projekty mają
// ikony FontAwesome, a "projekty" to nasze tryby i ustawienia RCD.
type Design = {
  title: string;
  icon: string;
};

const ROOT_LABELS: Record<string, string> = {
  construction: 'Konstrukcja',
  access: 'Dostęp śluzy',
};

export const MatterItem = (props) => {
  const { data } = useBackend<Data>();
  const { matterLeft } = data;
  return (
    <LabeledList.Item label="Pozostało">
      &nbsp;{matterLeft} jedn.
    </LabeledList.Item>
  );
};

export const SiloItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { silo_enabled } = data;
  return (
    <LabeledList.Item label="Magazyn zdalny">
      <Button.Checkbox
        checked={silo_enabled}
        color="transparent"
        onClick={() => act('toggle_silo')}
      >
        {silo_enabled ? 'Połączony' : 'Rozłączony'}
      </Button.Checkbox>
    </LabeledList.Item>
  );
};

const CategoryItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { root_categories = [], selected_root } = data;
  return (
    <LabeledList.Item label="Kategoria">
      {root_categories.map((root) => (
        <Button
          key={root}
          selected={selected_root === root}
          color="transparent"
          onClick={() => act('root_category', { root_category: root })}
        >
          {ROOT_LABELS[root] || root}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

export const InfoSection = (props) => {
  const { data } = useBackend<Data>();
  const { silo_upgraded } = data;

  return (
    <Section>
      <LabeledList>
        <MatterItem />
        {!!silo_upgraded && <SiloItem />}
        <CategoryItem />
      </LabeledList>
    </Section>
  );
};

const DesignSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selected_category, selected_design } = data;
  const [categoryName, setCategoryName] = useState(selected_category);
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.cat_name}
            selected={category.cat_name === shownCategory?.cat_name}
            onClick={() => setCategoryName(category.cat_name)}
          >
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.designs.map((design, i) => (
        <Button
          key={i + 1}
          fluid
          height="31px"
          color="transparent"
          selected={
            design.title === selected_design &&
            shownCategory.cat_name === selected_category
          }
          onClick={() =>
            act('design', {
              category: shownCategory.cat_name,
              index: i + 1,
            })
          }
        >
          <Stack align="center" height="100%">
            <Stack.Item width="32px" textAlign="center">
              <Icon name={design.icon} size={1.5} />
            </Stack.Item>
            <Stack.Item>{capitalizeFirst(design.title)}</Stack.Item>
          </Stack>
        </Button>
      ))}
    </Section>
  );
};

const ConfigureSection = (props) => {
  const { data } = useBackend<Data>();
  const { selected_root } = data;

  return (
    <Stack.Item grow>
      {selected_root === 'access' ? <AirLockMainSection /> : <DesignSection />}
    </Stack.Item>
  );
};

export const RapidConstructionDevice = (props) => {
  return (
    <Window width={450} height={590}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <InfoSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <ConfigureSection />
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
