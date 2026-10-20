import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  DmIcon,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MatterItem, SiloItem } from './RapidConstructionDevice';

type Data = {
  matterLeft: number;
  silo_upgraded: BooleanLike;
  silo_enabled: BooleanLike;
  categories: Category[];
  selected_category: string;
  selected_recipe: string | null;
  piping_layer: number;
  paint_colors: Record<string, string>;
  selected_color: string;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
};

// AQUILA: ikony z DmIcon zamiast arkusza sprite'ów plumbing-tgui32x32 z tg
type Recipe = {
  name: string;
  icon: string;
  icon_state: string;
  cost: number;
};

const CATEGORY_NAMES: Record<string, string> = {
  Synthesizers: 'Syntezatory',
  Distributors: 'Rozdzielacze',
  Storage: 'Magazynowanie',
};

const LAYER_NAMES = ['Pierwsza', 'Druga', 'Domyślna', 'Czwarta', 'Piąta'];

const PAINT_COLOR_NAMES: Record<string, string> = {
  omni: 'uniwersalny',
  amethyst: 'ametystowy',
  blue: 'niebieski',
  brown: 'brązowy',
  cyan: 'cyjanowy',
  dark: 'ciemny',
  green: 'zielony',
  grey: 'szary',
  orange: 'pomarańczowy',
  purple: 'fioletowy',
  red: 'czerwony',
  violet: 'fiołkowy',
  yellow: 'żółty',
};

// AQUILA: własny wybór koloru, bo u nas rury mają też kolor "omni"
const DuctColorItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { selected_color, paint_colors = {} } = data;
  return (
    <LabeledList.Item label="Kolor">
      {Object.keys(paint_colors).map((colorName) => (
        <ColorBox
          key={colorName}
          height="20px"
          width="20px"
          style={{
            border:
              '3px solid ' +
              (colorName === selected_color ? '#20b142' : '#222'),
          }}
          color={paint_colors[colorName]}
          onClick={() =>
            act('color', {
              paint_color: colorName,
            })
          }
        />
      ))}
      <Box inline ml={2} px={1} bold color={paint_colors[selected_color]}>
        {PAINT_COLOR_NAMES[selected_color] || selected_color}
      </Box>
    </LabeledList.Item>
  );
};

const PlumbingTypeSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selected_category, selected_recipe } = data;
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
            {CATEGORY_NAMES[category.cat_name] || category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe, index) => (
        <Button
          key={index}
          fluid
          color="transparent"
          selected={recipe.name === selected_recipe}
          onClick={() =>
            act('recipe', {
              category: shownCategory.cat_name,
              id: index,
            })
          }
        >
          <Stack align="center">
            <Stack.Item>
              <DmIcon
                icon={recipe.icon}
                icon_state={recipe.icon_state}
                width="32px"
                height="32px"
              />
            </Stack.Item>
            <Stack.Item grow>{capitalizeFirst(recipe.name)}</Stack.Item>
            <Stack.Item color="label">{recipe.cost} jedn.</Stack.Item>
          </Stack>
        </Button>
      ))}
    </Section>
  );
};

export const LayerSelect = (props) => {
  const { act, data } = useBackend<Data>();
  const { piping_layer } = data;
  return (
    <LabeledList.Item label="Warstwa">
      {[1, 2, 3, 4, 5].map((layer) => (
        <Button.Checkbox
          key={layer}
          checked={layer === piping_layer}
          tooltip={LAYER_NAMES[layer - 1]}
          onClick={() =>
            act('piping_layer', {
              piping_layer: layer,
            })
          }
        >
          {layer}
        </Button.Checkbox>
      ))}
    </LabeledList.Item>
  );
};

export const RapidPlumbingDevice = (props) => {
  const { data } = useBackend<Data>();
  const { silo_upgraded } = data;
  return (
    <Window width={480} height={575}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <LabeledList>
                <DuctColorItem />
                <LayerSelect />
                <MatterItem />
                {!!silo_upgraded && <SiloItem />}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <PlumbingTypeSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
