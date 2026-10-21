import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  ImageButton,
  LabeledList,
  Section,
  Stack,
  StyleableSection,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const ROOT_CATEGORIES = ['Atmospherics', 'Disposals', 'Transit Tubes'] as const;

/** Kategoria rur dla Plumberinatora (DM: PLUMBING_CATEGORY) */
const PLUMBING_CATEGORY = 3;

export const ICON_BY_CATEGORY_NAME = {
  Atmospherics: 'wrench',
  Binary: 'arrows-left-right',
  Devices: 'microchip',
  'Disposal Pipes': 'grip-lines',
  Disposals: 'trash-alt',
  'Fluid Ducts': 'faucet',
  'Heat Exchange': 'thermometer-half',
  Pipes: 'grip-lines',
  'Station Equipment': 'microchip',
  'Transit Tubes': 'bus',
} as const;

/** Polskie nazwy kategorii (klucze z DM zostają bez zmian) */
const CATEGORY_NAMES: Record<string, string> = {
  Atmospherics: 'Atmosfera',
  Binary: 'Dwuportowe',
  Devices: 'Urządzenia',
  'Disposal Pipes': 'Rury zsypowe',
  Disposals: 'Zsypy',
  'Fluid Ducts': 'Przewody płynów',
  'Heat Exchange': 'Wymiana ciepła',
  Pipes: 'Rury',
  'Station Equipment': 'Wyposażenie stacji',
  'Transit Tubes': 'Rury transportowe',
};

const categoryName = (name: string) => CATEGORY_NAMES[name] || name;

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

// Bity trybów jak w DM: BUILD_MODE, WRENCH_MODE, DESTROY_MODE, PAINT_MODE
const TOOLS = [
  {
    name: 'Wydawanie',
    bitmask: 1,
  },
  {
    name: 'Podłączanie',
    bitmask: 2,
  },
  {
    name: 'Niszczenie',
    bitmask: 4,
  },
  {
    name: 'Malowanie',
    bitmask: 8,
  },
] as const;

const PIPING_LAYERS = [1, 2, 3, 4, 5];
// Warstwy przewodów płynów to bity (FIRST_DUCT_LAYER ... FIFTH_DUCT_LAYER)
const DUCT_LAYERS = [1, 2, 4, 8, 16];

type Category = {
  cat_name: string;
  recipes: Recipe[];
};

type Recipe = {
  pipe_index: number;
  pipe_name: string;
  selected: BooleanLike;
  all_layers: BooleanLike;
  previews: Preview[];
};

type Preview = {
  dir_name: string;
  dir: string;
  flipped: BooleanLike;
  icon_state: string;
  selected: BooleanLike;
};

type Data = {
  categories: Category[];
  category: number;
  ducting_layer: number;
  locked: BooleanLike;
  mode: number;
  paint_colors: Record<string, string>;
  piping_layer: number;
  selected_category: string;
  selected_color: string;
};

export function ColorItem(props) {
  const { act, data } = useBackend<Data>();
  const { selected_color, paint_colors = {} } = data;
  const colorNames = Object.keys(paint_colors);

  return (
    <LabeledList.Item label="Kolor">
      {colorNames.map((colorName) => (
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
}

function ModeItem(props) {
  const { act, data } = useBackend<Data>();
  const { mode } = data;

  return (
    <LabeledList.Item label="Tryby">
      {TOOLS.map((tool) => (
        <Button.Checkbox
          key={tool.bitmask}
          checked={mode & tool.bitmask}
          onClick={() =>
            act('mode', {
              mode: tool.bitmask,
            })
          }
        >
          {tool.name}
        </Button.Checkbox>
      ))}
    </LabeledList.Item>
  );
}

function CategoryItem(props) {
  const { act, data } = useBackend<Data>();
  const { category: rootCategoryIndex } = data;

  return (
    <LabeledList.Item label="Kategoria">
      {ROOT_CATEGORIES.map((name, i) => (
        <Button
          key={name}
          selected={rootCategoryIndex === i}
          icon={ICON_BY_CATEGORY_NAME[name]}
          color="transparent"
          onClick={() => act('category', { category: i })}
        >
          {categoryName(name)}
        </Button>
      ))}
    </LabeledList.Item>
  );
}

function LayerSelect(props) {
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
}

// AQUILA: warstwy przewodów płynów (Plumberinator)
function DuctLayerSelect(props) {
  const { act, data } = useBackend<Data>();
  const { ducting_layer } = data;

  return (
    <LabeledList.Item label="Warstwa">
      {DUCT_LAYERS.map((layer, i) => (
        <Button.Checkbox
          key={layer}
          checked={layer === ducting_layer}
          onClick={() => act('ducting_layer', { ducting_layer: layer })}
        >
          {i + 1}
        </Button.Checkbox>
      ))}
    </LabeledList.Item>
  );
}

function SelectionSection(props) {
  const { data } = useBackend<Data>();
  const { category: rootCategoryIndex, locked } = data;
  const isAtmos = rootCategoryIndex === 0;
  const isPlumbing = rootCategoryIndex === PLUMBING_CATEGORY;

  return (
    <Section fill>
      <LabeledList>
        {!locked && <CategoryItem />}
        <ModeItem />
        {(isAtmos || isPlumbing) && <ColorItem />}
        {isAtmos && <LayerSelect />}
        {isPlumbing && <DuctLayerSelect />}
      </LabeledList>
    </Section>
  );
}

type RecipeRowProps = {
  recipe: Recipe;
  shownCategory: Category;
};

function RecipeRow(props: RecipeRowProps) {
  const { act } = useBackend<Data>();
  const { recipe, shownCategory } = props;

  return (
    <StyleableSection
      textStyle={{
        color: 'var(--color-label)',
        fontSize: '1em',
        fontWeight: 'normal',
        textAlign: 'right',
      }}
      title={recipe.pipe_name}
      titleStyle={{
        borderBottom: '1px solid var(--color-border)',
        padding: 0,
      }}
    >
      <Stack fill wrap>
        {(recipe.previews || []).map((preview) => (
          <Stack.Item key={preview.dir}>
            <ImageButton
              asset={['pipes32x32', `${preview.dir}-${preview.icon_state}`]}
              color="blue"
              imageSize={58}
              assetSize={30}
              onClick={() => {
                act('pipe_type', {
                  pipe_type: recipe.pipe_index,
                  category: shownCategory.cat_name,
                });
                act('setdir', {
                  dir: preview.dir,
                  flipped: preview.flipped,
                });
              }}
              selected={preview.selected}
              tooltip={preview.dir_name}
              tooltipPosition="bottom"
            />
          </Stack.Item>
        ))}
      </Stack>
    </StyleableSection>
  );
}

function PipeTypeSection(props) {
  const { data } = useBackend<Data>();
  const { categories = [], selected_category } = data;
  const [shownName, setShownName] = useState(selected_category);

  const shownCategory =
    categories.find((category) => category.cat_name === shownName) ||
    categories[0];

  return (
    <Stack fill vertical>
      <Tabs mb={-1}>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.cat_name}
            icon={ICON_BY_CATEGORY_NAME[category.cat_name]}
            selected={category.cat_name === shownCategory?.cat_name}
            onClick={() => setShownName(category.cat_name)}
          >
            {categoryName(category.cat_name)}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Section fill scrollable>
        {shownCategory?.recipes.map((recipe) => (
          <RecipeRow
            key={recipe.pipe_name}
            recipe={recipe}
            shownCategory={shownCategory}
          />
        ))}
      </Section>
    </Stack>
  );
}

export function RapidPipeDispenser(props) {
  return (
    <Window width={550} height={580}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SelectionSection />
          </Stack.Item>
          <Stack.Item grow>
            <PipeTypeSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
