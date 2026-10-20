import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  VirtualList,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  CAN_MAKE,
  CATEGORY_ICONS_COOKING,
  CATEGORY_ICONS_CRAFTING,
} from './constants';
import { FoodtypeContent } from './content/FoodtypeContent';
import { MaterialContent } from './content/MaterialContent';
import { RecipeContent, RecipeContentCompact } from './content/RecipeContent';
import { categoryName, getFAIcon } from './helpers';
import {
  type CraftingData,
  type Material,
  MODE,
  type Recipe,
  TABS,
} from './types';

// AQUILA EDIT - układ z tg (PersonalCrafting/), na naszym komponencie
// aquila/code/datums/components/crafting/crafting.dm (port Bee #12485).
// Zostaje nasza zakładka "Typ" dla gotowania zamiast filtrów kuchni z tg.
export function PersonalCrafting(props) {
  const { act, data } = useBackend<CraftingData>();
  const {
    mode,
    busy,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
    atom_data,
  } = data;

  const [searchText, setSearchText] = useState('');
  const [pages, setPages] = useState(1);

  const DEFAULT_CAT_CRAFTING = Object.keys(CATEGORY_ICONS_CRAFTING)[1];
  const DEFAULT_CAT_COOKING = Object.keys(CATEGORY_ICONS_COOKING)[1];

  const [activeCategory, setCategory] = useState(
    Object.keys(craftability).length
      ? CAN_MAKE
      : mode === MODE.cooking
        ? DEFAULT_CAT_COOKING
        : DEFAULT_CAT_CRAFTING,
  );
  const [activeType, setFoodType] = useState(
    Object.keys(craftability).length ? CAN_MAKE : data.foodtypes[0],
  );

  const material_occurences = sortBy(data.material_occurences, [
    (material) => -material.occurences,
  ]);
  const [activeMaterial, setMaterial] = useState(
    material_occurences[0]?.atom_id,
  );
  const [tabMode, setTabMode] = useState(TABS.category);

  const searchName = createSearch(searchText, (item: Recipe) => item.name);

  const getMaterialName = (atomId: string): string => {
    const atom = atom_data[Number(atomId) - 1];
    return atom?.name || atomId;
  };

  const searchMaterial = createSearch(searchText, (material: Material) =>
    getMaterialName(material.atom_id),
  );

  const filteredMaterials =
    searchText.length > 0 && tabMode === TABS.material
      ? filter(material_occurences, searchMaterial)
      : material_occurences;

  function categoryMatch(recipe: Recipe): boolean {
    if (tabMode === TABS.material) {
      return Object.keys(recipe.reqs).includes(activeMaterial);
    }
    if (tabMode === TABS.foodtype && mode === MODE.cooking) {
      if (activeType === CAN_MAKE) {
        return Boolean(craftability[recipe.ref]);
      }
      return !!recipe.foodtypes?.includes(activeType);
    }
    if (activeCategory === CAN_MAKE) {
      return Boolean(craftability[recipe.ref]);
    }
    return recipe.category === activeCategory;
  }

  // W zakładce materiałów wyszukiwarka filtruje materiały, nie przepisy
  const searchingRecipes = searchText.length > 0 && tabMode !== TABS.material;

  let recipes = filter(
    data.recipes,
    (recipe) =>
      // If craftable only is selected, then filter by craftability
      (!display_craftable_only || Boolean(craftability[recipe.ref])) &&
      // Ignore categories and types when searching
      (searchingRecipes || categoryMatch(recipe)),
  );
  recipes = sortBy(recipes, [
    (recipe) =>
      activeCategory === CAN_MAKE
        ? 99 - Object.keys(recipe.reqs).length
        : Number(craftability[recipe.ref]),
    (recipe) => recipe.name.toLowerCase(),
  ]);
  if (searchingRecipes) {
    recipes = filter(recipes, searchName);
  }

  const canMake = [CAN_MAKE];
  const categories = canMake
    .concat(data.categories.sort())
    .filter((i) => (i === 'Weaponry' ? true : i));
  const foodtypes = canMake.concat(data.foodtypes.sort());

  const pageSize = searchingRecipes
    ? display_compact
      ? 20
      : 10
    : display_compact
      ? 60
      : 30;
  const displayLimit = pageSize * pages;
  const content = document.getElementById('content');

  const resetScroll = () => {
    setPages(1);
    if (content) {
      content.scrollTop = 0;
    }
    if (searchText.length > 0) {
      setSearchText('');
    }
  };

  return (
    <Window title="Tworzenie" width={700} height={720}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="200px">
            <Section fill>
              <Stack fill vertical justify="space-between">
                <Stack.Item>
                  <Input
                    autoFocus
                    expensive
                    placeholder={
                      tabMode === TABS.material
                        ? mode === MODE.cooking
                          ? 'Szukaj składnika...'
                          : 'Szukaj materiału...'
                        : `Szukaj w ${data.recipes.length} ${
                            mode === MODE.cooking ? 'przepisach' : 'projektach'
                          }...`
                    }
                    value={searchText}
                    onChange={(value) => {
                      setPages(1);
                      setSearchText(value);
                    }}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Tabs fluid textAlign="center">
                    <Tabs.Tab
                      selected={tabMode === TABS.category}
                      onClick={() => {
                        if (tabMode === TABS.category) {
                          return;
                        }
                        setTabMode(TABS.category);
                        setPages(1);
                        setCategory(
                          Object.keys(craftability).length
                            ? CAN_MAKE
                            : data.categories[0],
                        );
                      }}
                    >
                      Kategoria
                    </Tabs.Tab>
                    {mode === MODE.cooking && (
                      <Tabs.Tab
                        selected={tabMode === TABS.foodtype}
                        onClick={() => {
                          if (tabMode === TABS.foodtype) {
                            return;
                          }
                          setTabMode(TABS.foodtype);
                          setPages(1);
                          setFoodType(
                            Object.keys(craftability).length
                              ? CAN_MAKE
                              : data.foodtypes[0],
                          );
                        }}
                      >
                        Typ
                      </Tabs.Tab>
                    )}
                    <Tabs.Tab
                      selected={tabMode === TABS.material}
                      onClick={() => {
                        if (tabMode === TABS.material) {
                          return;
                        }
                        setTabMode(TABS.material);
                        setPages(1);
                        setMaterial(material_occurences[0]?.atom_id);
                      }}
                    >
                      {mode === MODE.cooking ? 'Składnik' : 'Materiał'}
                    </Tabs.Tab>
                  </Tabs>
                </Stack.Item>
                <Stack.Item grow m={-1} style={{ overflowY: 'auto' }}>
                  <Box height="100%" p={1}>
                    <Tabs vertical>
                      {tabMode === TABS.foodtype &&
                        mode === MODE.cooking &&
                        foodtypes.map((foodtype) => (
                          <Tabs.Tab
                            key={foodtype}
                            selected={
                              activeType === foodtype && searchText.length === 0
                            }
                            onClick={() => {
                              setFoodType(foodtype);
                              resetScroll();
                            }}
                          >
                            <FoodtypeContent
                              type={foodtype}
                              diet={diet}
                              craftableCount={Object.keys(craftability).length}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.material &&
                        filteredMaterials.map((material) => (
                          <Tabs.Tab
                            key={material.atom_id}
                            selected={activeMaterial === material.atom_id}
                            onClick={() => {
                              setMaterial(material.atom_id);
                              resetScroll();
                            }}
                          >
                            <MaterialContent
                              atom_id={material.atom_id}
                              occurences={material.occurences}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.category &&
                        categories.map((category) => (
                          <Tabs.Tab
                            key={category}
                            selected={
                              activeCategory === category &&
                              searchText.length === 0
                            }
                            onClick={() => {
                              setCategory(category);
                              resetScroll();
                            }}
                          >
                            <Stack>
                              <Stack.Item width="14px" textAlign="center">
                                <Icon
                                  color={
                                    category === 'Blood Cult'
                                      ? 'red'
                                      : 'default'
                                  }
                                  name={getFAIcon(category, mode)}
                                />
                              </Stack.Item>
                              <Stack.Item
                                grow
                                color={
                                  category === 'Blood Cult' ? 'red' : 'default'
                                }
                              >
                                {categoryName(category)}
                              </Stack.Item>
                              {category === CAN_MAKE && (
                                <Stack.Item>
                                  {Object.keys(craftability).length}
                                </Stack.Item>
                              )}
                            </Stack>
                          </Tabs.Tab>
                        ))}
                    </Tabs>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Divider />
                  <Button.Checkbox
                    fluid
                    checked={display_craftable_only}
                    onClick={() => {
                      act('toggle_recipes');
                    }}
                  >
                    Tylko możliwe do zrobienia
                  </Button.Checkbox>
                  <Button.Checkbox
                    fluid
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  >
                    Zwarta lista
                  </Button.Checkbox>
                </Stack.Item>
                {!forced_mode && (
                  <Stack.Item>
                    <Stack textAlign="center">
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          checked={mode === MODE.crafting}
                          icon="hammer"
                          style={{
                            border:
                              '2px solid ' +
                              (mode === MODE.crafting ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.crafting) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_CRAFTING);
                            act('toggle_mode');
                          }}
                        >
                          Tworzenie
                        </Button.Checkbox>
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          checked={mode === MODE.cooking}
                          icon="utensils"
                          style={{
                            border:
                              '2px solid ' +
                              (mode === MODE.cooking ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.cooking) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_COOKING);
                            act('toggle_mode');
                          }}
                        >
                          Gotowanie
                        </Button.Checkbox>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow my={-1}>
            <Box
              id="content"
              height="100%"
              pr={1}
              pt={1}
              mr={-1}
              style={{ overflowY: 'auto' }}
            >
              {recipes.length > 0 ? (
                <VirtualList>
                  {recipes
                    .slice(0, displayLimit)
                    .map((item) =>
                      display_compact ? (
                        <RecipeContentCompact key={item.ref} item={item} />
                      ) : (
                        <RecipeContent key={item.ref} item={item} />
                      ),
                    )}
                </VirtualList>
              ) : (
                <NoticeBox m={1} p={1}>
                  Nie znaleziono przepisów.
                </NoticeBox>
              )}
              {recipes.length > displayLimit && (
                <Section
                  mb={1}
                  textAlign="center"
                  style={{ cursor: 'pointer' }}
                  onClick={() => setPages(pages + 1)}
                >
                  Wczytaj kolejne (
                  {Math.min(pageSize, recipes.length - displayLimit)})...
                </Section>
              )}
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
