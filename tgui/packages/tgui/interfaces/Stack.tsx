// Port okna StackCrafting z tgstation pod naszą nazwą "Stack"
import { useState } from 'react';
import {
  Button,
  Collapsible,
  ImageButton,
  NoticeBox,
  Section,
  Stack as StackLayout,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';

type Recipe = {
  ref: string;
  req_amount: number;
  icon?: string | null;
  icon_state?: string | null;
  image?: string;

  // for multiplier buttons
  res_amount: number;
  max_res_amount: number;
};

/** Format przepisu wysyłany przez nasz DM (lista, z podlistami i odstępami) */
type RawRecipe = Partial<Recipe> & {
  title?: string;
  sub_recipes?: RawRecipe[];
  spacer?: boolean;
};

type RecipeList = {
  [key: string]: Recipe | RecipeList;
};

type Data = {
  amount: number;
  recipes: RawRecipe[];
};

type MultiplierProps = {
  recipe: Recipe;
  maxMultiplier: number;
};

type RecipeBoxProps = {
  title: string;
  recipe: Recipe;
};

// RecipeList converted via Object.entries() for filterRecipeList
type RecipeListFilterableEntry = [string, RecipeList | Recipe];

/**
 * Type guard for recipe vs recipe list
 * @param value the value to test
 * @returns type guard boolean
 */
function isRecipeList(value: Recipe | RecipeList): value is RecipeList {
  return (value as Recipe).ref === undefined;
}

/** Zamienia listę przepisów z naszego DM na słownik używany przez okno z tg */
function toRecipeList(raw: RawRecipe[] = []): RecipeList {
  const list: RecipeList = {};
  for (const recipe of raw) {
    if (recipe.spacer || recipe.title === undefined) {
      continue;
    }
    let key = recipe.title;
    for (let i = 2; key in list; i++) {
      key = `${recipe.title} (${i})`;
    }
    list[key] = recipe.sub_recipes
      ? toRecipeList(recipe.sub_recipes)
      : (recipe as Recipe);
  }
  return list;
}

/**
 * Filter recipe list by keys, resursing into subcategories.
 * Returns the filtered list, or undefined, if there is no list left.
 * @param list the recipe list to filter
 * @param filter the filter function for recipes
 */
const filterRecipeList = (
  list: RecipeList,
  keyFilter: (key: string) => boolean,
): RecipeList | undefined => {
  const filteredList = Object.fromEntries(
    Object.entries(list)
      .flatMap((entry): RecipeListFilterableEntry[] => {
        const [key, recipe] = entry;

        // If category name matches, return the whole thing.
        if (keyFilter(key)) {
          return [entry];
        }

        if (isRecipeList(recipe)) {
          // otherwise, filter sub-entries.
          const subEntries = filterRecipeList(recipe, keyFilter);
          if (subEntries !== undefined) {
            return [[key, subEntries]];
          }
        }

        return [];
      })

      // Sort items so that lists are on top and recipes underneath.
      // Plus everything is in alphabetical order.
      .sort(([aKey, aValue], [bKey, bValue]) =>
        isRecipeList(aValue) !== isRecipeList(bValue)
          ? isRecipeList(aValue)
            ? -1
            : 1
          : aKey.localeCompare(bKey),
      ),
  );

  return Object.keys(filteredList).length ? filteredList : undefined;
};

export const Stack = (_props) => {
  const { data } = useBackend<Data>();
  const { amount } = data;
  const recipes = toRecipeList(data.recipes);

  const [searchText, setSearchText] = useState('');
  const testSearch = createSearch(searchText, (item: string) => item);
  const filteredRecipes = filterRecipeList(recipes, testSearch);

  const height: number = clamp(96 + Object.keys(recipes).length * 37, 250, 500);

  return (
    <Window width={400} height={height}>
      <Window.Content>
        <Section
          fill
          scrollable
          title={`Ilość: ${amount}`}
          buttons={
            <SearchBar
              autoFocus
              expensive
              style={{ width: '15em' }}
              query={searchText}
              placeholder="Szukaj..."
              onSearch={(value) => setSearchText(value)}
            />
          }
        >
          {filteredRecipes ? (
            <RecipeListBox recipes={filteredRecipes} />
          ) : (
            <NoticeBox>Nie znaleziono przepisów.</NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RecipeListBox = (props: { recipes: RecipeList }) => {
  const { recipes } = props;

  return (
    <>
      {Object.keys(recipes).map((title) => {
        const recipe = recipes[title];
        if (isRecipeList(recipe)) {
          return (
            <Collapsible
              key={title}
              title={toTitleCase(title || '')}
              child_mt={0}
              childStyles={{
                padding: '0.5em',
                backgroundColor: 'rgba(62, 97, 137, 0.15)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                borderTop: 'none',
                borderRadius: '0 0 0.33em 0.33em',
              }}
            >
              <RecipeListBox recipes={recipe} />
            </Collapsible>
          );
        } else {
          return <RecipeBox key={title} title={title} recipe={recipe} />;
        }
      })}
    </>
  );
};

const buildMultiplier = (recipe: Recipe, amount: number) => {
  if (recipe.req_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.req_amount);
};

const Multipliers = (props: MultiplierProps) => {
  const { act } = useBackend();

  const { recipe, maxMultiplier } = props;

  const maxM = Math.min(
    maxMultiplier,
    Math.floor(recipe.max_res_amount / recipe.res_amount),
  );

  const multipliers = [5, 10, 25];

  const finalResult: React.JSX.Element[] = [];

  for (const multiplier of multipliers) {
    if (maxM >= multiplier) {
      finalResult.push(
        <Button
          key={multiplier}
          bold
          color="transparent"
          fontSize={0.75}
          width="32px"
          onClick={() =>
            act('make', {
              ref: recipe.ref,
              multiplier: multiplier,
            })
          }
        >
          {`${multiplier * recipe.res_amount}x`}
        </Button>,
      );
    }
  }

  if (multipliers.indexOf(maxM) === -1) {
    finalResult.push(
      <Button
        key="max"
        bold
        color="transparent"
        fontSize={0.75}
        width="32px"
        onClick={() =>
          act('make', {
            ref: recipe.ref,
            multiplier: maxM,
          })
        }
      >
        {`${maxM * recipe.res_amount}x`}
      </Button>,
    );
  }

  return finalResult;
};

/** Polska odmiana słowa "arkusz" */
const sheetWord = (count: number) => {
  if (count === 1) {
    return 'arkusz';
  }
  const lastDigit = count % 10;
  const lastTwo = count % 100;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14)) {
    return 'arkusze';
  }
  return 'arkuszy';
};

const RecipeBox = (props: RecipeBoxProps) => {
  const { act, data } = useBackend<Data>();
  const { amount } = data;
  const { recipe, title } = props;
  const {
    res_amount,
    max_res_amount,
    req_amount,
    ref,
    icon,
    icon_state,
    image,
  } = recipe;

  const resAmountLabel = res_amount > 1 ? `${res_amount}x ` : '';
  const buttonName = `${resAmountLabel}${title}`;
  const reqSheets = `${req_amount} ${sheetWord(req_amount)}`;

  const maxMultiplier = buildMultiplier(recipe, amount);

  return (
    <ImageButton
      fluid
      base64={
        image
      } /* Use base64 image if we have it. DmIcon cannot paint grayscale images yet */
      dmIcon={icon || null}
      dmIconState={icon_state || null}
      imageSize={32}
      disabled={!maxMultiplier}
      buttons={
        max_res_amount > 1 &&
        maxMultiplier > 1 && (
          <Multipliers recipe={recipe} maxMultiplier={maxMultiplier} />
        )
      }
      onClick={() =>
        act('make', {
          ref: ref,
          multiplier: 1,
        })
      }
    >
      <StackLayout textAlign="left">
        <StackLayout.Item grow>{toTitleCase(buttonName)}</StackLayout.Item>
        <StackLayout.Item align="center" fontSize={0.8} color="gray">
          {reqSheets}
        </StackLayout.Item>
      </StackLayout>
    </ImageButton>
  );
};
