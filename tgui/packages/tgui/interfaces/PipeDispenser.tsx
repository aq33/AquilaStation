import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: nasze rury nie mają "smart pipe" (wyboru kierunków połączeń),
// więc z wersji tg zostały: kolor, warstwa i lista przepisów.
// Komponenty kolorów/warstw są tu lokalnie, żeby okno nie zależało od RPD.

type Data = {
  category: number;
  piping_layer: number;
  categories: Category[];
  selected_color: string;
  paint_colors: Record<string, string>;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
};

type Recipe = {
  pipe_name: string;
  pipe_index: number;
  all_layers: BooleanLike;
  dir: number;
};

/** Kategoria dozownika (DM: ATMOS_PIPEDISPENSER) */
const ATMOS_PIPEDISPENSER = 0;

const ICON_BY_CATEGORY_NAME: Record<string, string> = {
  Devices: 'microchip',
  'Disposal Pipes': 'grip-lines',
  'Heat Exchange': 'thermometer-half',
  Pipes: 'grip-lines',
  'Station Equipment': 'microchip',
  'Transit Tubes': 'bus',
};

/** Polskie nazwy kategorii (klucze z DM zostają bez zmian) */
const CATEGORY_NAMES: Record<string, string> = {
  Devices: 'Urządzenia',
  'Disposal Pipes': 'Rury zsypowe',
  'Heat Exchange': 'Wymiana ciepła',
  Pipes: 'Rury',
  'Station Equipment': 'Wyposażenie stacji',
  'Transit Tubes': 'Rury transportowe',
};

/** Polskie nazwy kolorów farby (klucze z DM zostają bez zmian) */
const PAINT_COLOR_NAMES: Record<string, string> = {
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

const PIPING_LAYERS = [1, 2, 3, 4, 5];

const ColorItem = (props) => {
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
            cursor: 'pointer',
          }}
          color={paint_colors[colorName]}
          onClick={() => act('color', { paint_color: colorName })}
        />
      ))}
      <Box inline ml={2} px={1} bold color={paint_colors[selected_color]}>
        {PAINT_COLOR_NAMES[selected_color] || selected_color}
      </Box>
    </LabeledList.Item>
  );
};

const LayerSelect = (props) => {
  const { act, data } = useBackend<Data>();
  const { piping_layer } = data;
  return (
    <LabeledList.Item label="Warstwa">
      {PIPING_LAYERS.map((layer) => (
        <Button.Checkbox
          key={layer}
          checked={layer === piping_layer}
          onClick={() => act('piping_layer', { piping_layer: layer })}
        >
          {layer}
        </Button.Checkbox>
      ))}
    </LabeledList.Item>
  );
};

const PipeTypeSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [] } = data;
  const [categoryName, setCategoryName] = useState(categories[0]?.cat_name);
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.cat_name}
            icon={ICON_BY_CATEGORY_NAME[category.cat_name]}
            selected={category.cat_name === shownCategory?.cat_name}
            onClick={() => setCategoryName(category.cat_name)}
          >
            {CATEGORY_NAMES[category.cat_name] || category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe) => (
        <Button
          key={`${recipe.pipe_index}-${recipe.dir}`}
          fluid
          ellipsis
          tooltip={recipe.pipe_name}
          onClick={() =>
            act('pipe_type', {
              pipe_type: recipe.pipe_index,
              pipe_dir: recipe.dir,
              category: shownCategory.cat_name,
            })
          }
        >
          {recipe.pipe_name}
        </Button>
      ))}
    </Section>
  );
};

export const PipeDispenser = (props) => {
  const { data } = useBackend<Data>();
  const { category: rootCategoryIndex } = data;
  return (
    <Window width={450} height={530}>
      <Window.Content>
        <Stack fill vertical>
          {rootCategoryIndex === ATMOS_PIPEDISPENSER && (
            <Stack.Item>
              <Section>
                <LabeledList>
                  <ColorItem />
                  <LayerSelect />
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <PipeTypeSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
