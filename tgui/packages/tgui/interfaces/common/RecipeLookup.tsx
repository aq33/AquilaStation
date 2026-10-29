// AQUILA - wyszukiwarka receptur chemicznych (dispensery i program PDA „Receptury”)
// Wygląd kafelków wzorowany na dispenserze z Bee#12349 (style w styles/interfaces/RecipeLookup.scss)
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

export type RecipeReagent = {
  name: string;
  id: string;
  amount: number;
};

export type Recipe = {
  id: string;
  name: string;
  results: RecipeReagent[];
  reagents: RecipeReagent[];
  catalysts: RecipeReagent[];
  temp: number;
  cold: boolean;
  container: string | null;
  // fermichem
  instant: boolean;
  optimalTemp: number;
  overheatTemp: number | null;
  phMin: number;
  phMax: number;
  /** 1 = wydziela ciepło, -1 = pochłania ciepło */
  thermic: number;
  purityMin: number;
};

type Props = {
  recipes: Recipe[];
  /** Id odczynników, które można wydać w tej maszynie */
  dispensable?: string[];
  /** Wydaje odczynnik o danym id (tylko w dispenserze) */
  onDispense?: (id: string) => void;
  /** Zawartość zlewki w maszynie - składniki, których już starczy, świecą na zielono */
  beakerContents?: { name: string; volume: number }[];
};

const MAX_SHOWN = 40;
/** Temperatura pokojowa - wymagania niższe od niej są spełnione bez grzania */
const ROOM_TEMPERATURE = 300;

type SearchMode = 'product' | 'ingredient';

export const RecipeLookup = (props: Props) => {
  const { recipes, dispensable, onDispense, beakerContents = [] } = props;
  const [query, setQuery] = useState('');
  const [mode, setMode] = useState<SearchMode>('product');
  const [onlyHere, setOnlyHere] = useState(false);

  const canDispense = (id: string) => !!dispensable && dispensable.includes(id);
  const inBeaker = (reagent: RecipeReagent) =>
    beakerContents.some(
      (r) => r.name === reagent.name && r.volume >= reagent.amount,
    );
  const producible = new Set<string>();
  for (const recipe of recipes) {
    for (const result of recipe.results) {
      producible.add(result.id);
    }
  }

  const needle = query.trim().toLowerCase();
  const matches = (text: string) => text.toLowerCase().includes(needle);
  const filtered = recipes
    .filter((recipe) => {
      if (
        onlyHere &&
        ![...recipe.reagents, ...recipe.catalysts].every((r) =>
          canDispense(r.id),
        )
      ) {
        return false;
      }
      if (!needle) {
        return onlyHere;
      }
      if (mode === 'ingredient') {
        return (
          recipe.reagents.some((r) => matches(r.name)) ||
          recipe.catalysts.some((r) => matches(r.name))
        );
      }
      return (
        matches(recipe.name) || recipe.results.some((r) => matches(r.name))
      );
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  const searchFor = (name: string) => {
    setMode('product');
    setQuery(name);
  };

  return (
    <Box className="RecipeLookup">
      <Stack mb={1}>
        <Stack.Item grow>
          <Input
            fluid
            autoFocus
            placeholder={
              mode === 'product' ? 'Czego szukasz?' : 'Co masz pod ręką?'
            }
            value={query}
            onChange={(value) => setQuery(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            selected={mode === 'product'}
            tooltip="Szukaj po tym, co powstaje"
            onClick={() => setMode('product')}
          >
            Produkt
          </Button>
          <Button
            selected={mode === 'ingredient'}
            tooltip="Szukaj receptur, w których jest dany składnik"
            onClick={() => setMode('ingredient')}
          >
            Składnik
          </Button>
          {!!dispensable && (
            <Button.Checkbox
              checked={onlyHere}
              tooltip="Tylko receptury, których wszystkie składniki i katalizatory wyda ta maszyna"
              onClick={() => setOnlyHere(!onlyHere)}
            >
              Tylko stąd
            </Button.Checkbox>
          )}
        </Stack.Item>
      </Stack>
      {!needle && !onlyHere && (
        <div className="RecipeLookup__empty">
          <div>Wpisz nazwę, żeby znaleźć recepturę.</div>
          <div>
            Kliknij składnik, żeby zobaczyć, jak go zrobić
            {!!onDispense && ', albo kroplę na nim, żeby go wydać'}.
          </div>
        </div>
      )}
      {(!!needle || onlyHere) && filtered.length === 0 && (
        <NoticeBox>Nic nie znaleziono.</NoticeBox>
      )}
      <div className="RecipeLookup__grid">
        {filtered.slice(0, MAX_SHOWN).map((recipe) => (
          <RecipeEntry
            key={recipe.id}
            recipe={recipe}
            canDispense={canDispense}
            inBeaker={inBeaker}
            producible={producible}
            onDispense={onDispense}
            searchFor={searchFor}
          />
        ))}
      </div>
      {filtered.length > MAX_SHOWN && (
        <Box color="label" mt={1} textAlign="center">
          …i jeszcze {filtered.length - MAX_SHOWN}. Zawęź wyszukiwanie.
        </Box>
      )}
    </Box>
  );
};

type EntryProps = {
  recipe: Recipe;
  canDispense: (id: string) => boolean;
  inBeaker: (reagent: RecipeReagent) => boolean;
  producible: Set<string>;
  onDispense?: (id: string) => void;
  searchFor: (name: string) => void;
};

/** Ikonka z podpowiedzią w nagłówku kafelka */
const Hint = (props: { icon: string; color: string; content: string }) => (
  <Tooltip content={props.content}>
    <Icon name={props.icon} color={props.color} mr={0.75} />
  </Tooltip>
);

const RecipeEntry = (props: EntryProps) => {
  const { recipe, canDispense, inBeaker, producible, onDispense, searchFor } =
    props;
  const output = recipe.results.length
    ? recipe.results.map((r) => `${r.amount}× ${r.name}`).join(', ')
    : 'efekt bez produktu';
  const craftable = [...recipe.reagents, ...recipe.catalysts].every(
    (r) => canDispense(r.id) || inBeaker(r),
  );
  const chipProps = {
    canDispense,
    inBeaker,
    producible,
    onDispense,
    searchFor,
  };
  return (
    <div className={classes(['RecipeLookup__box', craftable && 'craftable'])}>
      <div className="RecipeLookup__title">
        {(recipe.cold || recipe.temp > ROOM_TEMPERATURE) &&
          (recipe.cold ? (
            <Hint
              icon="snowflake"
              color="blue"
              content={`Temperatura poniżej ${recipe.temp} K`}
            />
          ) : (
            <Hint
              icon="fire-flame-curved"
              color="orange"
              content={`Temperatura co najmniej ${recipe.temp} K`}
            />
          ))}
        {!recipe.instant &&
          (recipe.cold || recipe.optimalTemp > ROOM_TEMPERATURE) && (
            <Hint
              icon="gauge-high"
              color={recipe.cold ? 'blue' : 'orange'}
              content={`Najszybciej ${recipe.cold ? 'poniżej' : 'od'} ${recipe.optimalTemp} K`}
            />
          )}
        {!recipe.instant &&
          recipe.overheatTemp !== null &&
          recipe.overheatTemp > 0 && (
            <Hint
              icon="temperature-high"
              color="red"
              content={`Przegrzewa się ${recipe.cold ? 'poniżej' : 'powyżej'} ${recipe.overheatTemp} K`}
            />
          )}
        {!recipe.instant && (recipe.phMin > 0 || recipe.phMax < 14) && (
          <Hint
            icon="vial"
            color="teal"
            content={`Najczystsza przy pH ${recipe.phMin}–${recipe.phMax}`}
          />
        )}
        {!recipe.instant && recipe.thermic !== 0 && (
          <Hint
            icon={recipe.thermic > 0 ? 'sun' : 'icicles'}
            color="label"
            content={
              recipe.thermic > 0 ? 'Wydziela ciepło' : 'Pochłania ciepło'
            }
          />
        )}
        {!recipe.instant && recipe.purityMin > 0 && (
          <Hint
            icon="triangle-exclamation"
            color="yellow"
            content={`Psuje się poniżej ${Math.round(recipe.purityMin * 100)}% czystości`}
          />
        )}
        {!!recipe.instant && (
          <Hint icon="bolt" color="label" content="Reaguje od razu" />
        )}
        {!!recipe.container && (
          <Hint
            icon="flask"
            color="purple"
            content={`Tylko w: ${recipe.container}`}
          />
        )}
        <span className={classes([craftable && 'create'])}>{recipe.name}</span>
      </div>
      <div className="RecipeLookup__output">→ {output}</div>
      <div className="RecipeLookup__required">
        {recipe.reagents.map((reagent) => (
          <ReagentChip key={reagent.id} reagent={reagent} {...chipProps} />
        ))}
        {recipe.catalysts.map((reagent) => (
          <ReagentChip
            key={reagent.id}
            reagent={reagent}
            catalyst
            {...chipProps}
          />
        ))}
      </div>
    </div>
  );
};

type ChipProps = {
  reagent: RecipeReagent;
  catalyst?: boolean;
  canDispense: (id: string) => boolean;
  inBeaker: (reagent: RecipeReagent) => boolean;
  producible: Set<string>;
  onDispense?: (id: string) => void;
  searchFor: (name: string) => void;
};

const ReagentChip = (props: ChipProps) => {
  const {
    reagent,
    catalyst,
    canDispense,
    inBeaker,
    producible,
    onDispense,
    searchFor,
  } = props;
  const here = canDispense(reagent.id);
  const craftable = producible.has(reagent.id);
  const satisfied = inBeaker(reagent);
  const tooltip = [
    catalyst && 'Katalizator: nie zużywa się.',
    satisfied && 'Już jest w zlewce.',
    craftable
      ? 'Kliknij, żeby zobaczyć, jak to zrobić.'
      : here
        ? 'Dostępne w tej maszynie.'
        : 'Brak receptury, trzeba to zdobyć.',
  ]
    .filter(Boolean)
    .join(' ');
  return (
    <Tooltip content={tooltip}>
      <div
        className={classes([
          'RecipeLookup__ingredient',
          satisfied && 'satisfied',
          here && 'insertable',
          catalyst && 'catalyst',
          craftable && 'clickable',
        ])}
        onClick={() => craftable && searchFor(reagent.name)}
      >
        {reagent.amount} {reagent.name}
        {here && !!onDispense && (
          <span
            className="RecipeLookup__dispense"
            onClick={(e) => {
              e.stopPropagation();
              onDispense(reagent.id);
            }}
          >
            <Icon name="tint" />
          </span>
        )}
      </div>
    </Tooltip>
  );
};
