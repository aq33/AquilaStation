import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Floating,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { BeakerDisplay, legacyBeaker } from './Chemistry/BeakerDisplay';
import type { BeakerReagent } from './common/BeakerDisplay';
import {
  type Recipe,
  RecipeLookup,
  type RecipeReagent,
} from './common/RecipeLookup';

enum DropdownState {
  NO_DROPDOWN = 0,
  DROPDOWN_CLOSED = 1,
  DROPDOWN_OPEN = 2,
}

type DispensableReagent = {
  title: string;
  id: string;
  color?: string;
};

type Data = {
  amount: number;
  energy: number;
  maxEnergy: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: BeakerReagent[];
  beakerPh: number | null;
  beakerCurrentVolume: number | null;
  beakerMaxVolume: number | null;
  beakerTransferAmounts: number[] | null;
  hasBeakerInHand: BooleanLike;
  chemicals: DispensableReagent[];
  recipes: Record<string, Record<string, number>>;
  recordingRecipe: Record<string, number> | null;
  // static - AQUILA: katalog receptur z GLOB.chemical_reactions_list
  recipeCatalog: Recipe[];
};

export const ChemDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const recording = !!data.recordingRecipe;
  const {
    recipes = {},
    hasBeakerInHand,
    chemicals = [],
    recipeCatalog = [],
  } = data;
  const [showReactionList, setShowReactionList] = useSharedState(
    'showreactions',
    false,
  );
  const [searchTerm, setSearchTerm] = useSharedState('searchterm', '');
  const [pinnedReactions, setPinnedReactions] = useSharedState<string[]>(
    'pinnedreactions',
    [],
  );
  // AQUILA - wyszukiwarka przepisów (RecipeLookup)
  const [showLookup, setShowLookup] = useState(false);

  const beaker = legacyBeaker(
    data.isBeakerLoaded,
    data.beakerCurrentVolume,
    data.beakerMaxVolume,
    data.beakerContents,
    data.beakerPh,
  );
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const recordedContents =
    recording &&
    Object.keys(data.recordingRecipe || {}).map((id) => ({
      id,
      name: toTitleCase(id.replace(/_/, ' ')),
      volume: data.recordingRecipe?.[id] || 0,
    }));
  const recipeNames = Object.keys(recipes);

  const reactionSearch = createSearch(
    searchTerm,
    (reaction: Recipe) => reaction.name,
  );

  // Najpierw bez podstawowych odczynników z dispensera, potem wg wyszukiwania
  const filteredReactions = recipeCatalog
    .filter((reaction) => {
      if (
        reaction.results.some((result) =>
          chemicals.find((chem) => chem.id === result.id),
        )
      ) {
        return false;
      }
      return reactionSearch(reaction);
    })
    .sort((a, b) => (a.name > b.name ? 1 : -1))
    .sort((a, b) => {
      // przypięte receptury na górze
      const aPinned = pinnedReactions.includes(a.id);
      const bPinned = pinnedReactions.includes(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });

  const mainWidth = 565;
  const reactionWidth = 245;
  const windowWidth = mainWidth + (showReactionList ? reactionWidth : 0);

  return (
    <Window width={windowWidth} height={620}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item width={`${mainWidth}px`} grow>
            <Stack vertical fill>
              <Stack.Item>
                <Section
                  title="Stan"
                  buttons={
                    <>
                      {recording && (
                        <Box inline mx={1} color="red">
                          <Icon name="circle" mr={1} />
                          Nagrywanie
                        </Box>
                      )}
                      <Button
                        icon={showReactionList ? 'arrow-left' : 'arrow-right'}
                        tooltip="Lista reakcji chemicznych"
                        tooltipPosition="bottom-start"
                        onClick={() => setShowReactionList(!showReactionList)}
                      >
                        Receptury
                      </Button>
                    </>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Energia">
                      <ProgressBar value={data.energy / data.maxEnergy}>
                        {`${toFixed(data.energy)} / ${toFixed(data.maxEnergy)} u`}
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Własne receptury"
                  buttons={
                    <>
                      {!recording && (
                        <Box inline mx={1}>
                          <Button
                            color="transparent"
                            onClick={() => act('clear_recipes')}
                          >
                            Wyczyść receptury
                          </Button>
                        </Box>
                      )}
                      {!recording && (
                        <Button
                          icon="circle"
                          disabled={!beaker}
                          onClick={() => act('record_recipe')}
                        >
                          Nagraj
                        </Button>
                      )}
                      {recording && (
                        <Button
                          icon="ban"
                          color="transparent"
                          onClick={() => act('cancel_recording')}
                        >
                          Odrzuć
                        </Button>
                      )}
                      {recording && (
                        <Button
                          icon="save"
                          color="green"
                          onClick={() => act('save_recording')}
                        >
                          Zapisz
                        </Button>
                      )}
                    </>
                  }
                >
                  <Box mr={-1}>
                    {recipeNames.map((recipe) => (
                      <Button
                        key={recipe}
                        icon="tint"
                        width="129.5px"
                        lineHeight={1.75}
                        onClick={() =>
                          act('dispense_recipe', {
                            recipe: recipe,
                          })
                        }
                      >
                        {recipe}
                      </Button>
                    ))}
                    {recipeNames.length === 0 && (
                      <Box color="light-gray">Brak receptur.</Box>
                    )}
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Wydawanie"
                  buttons={beakerTransferAmounts.map((amount) => (
                    <Button
                      key={amount}
                      icon="plus"
                      selected={amount === data.amount}
                      onClick={() =>
                        act('amount', {
                          target: amount,
                        })
                      }
                    >
                      {amount}
                    </Button>
                  ))}
                >
                  <Stack wrap>
                    {chemicals.map((chemical) => (
                      <Stack.Item width="24.5%" key={chemical.id} mr={-0.5}>
                        <ReagentDispenseButton chemical={chemical} />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Zlewka"
                  buttons={beakerTransferAmounts.map((amount) => (
                    <Button
                      key={amount}
                      icon="minus"
                      disabled={recording}
                      onClick={() => act('remove', { amount })}
                    >
                      {amount}
                    </Button>
                  ))}
                >
                  {beaker || recording ? (
                    <BeakerDisplay
                      beaker={beaker}
                      title_label={recording && 'Wirtualna zlewka'}
                      replace_contents={recordedContents}
                      showpH={!recording}
                    />
                  ) : (
                    <Box
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                      }}
                    >
                      <Box color="label">Nie włożono zlewki.</Box>
                      <Button
                        icon="eject"
                        onClick={() => act('insert')}
                        disabled={!hasBeakerInHand}
                        tooltip={
                          !hasBeakerInHand && 'Musisz trzymać pojemnik w ręce!'
                        }
                        tooltipPosition="left-start"
                      >
                        Włóż
                      </Button>
                    </Box>
                  )}
                </Section>
              </Stack.Item>
              {/* AQUILA - wyszukiwarka przepisów */}
              <Stack.Item>
                <Section
                  title="Wyszukiwarka przepisów"
                  buttons={
                    <Button
                      icon={showLookup ? 'chevron-up' : 'search'}
                      onClick={() => setShowLookup(!showLookup)}
                    >
                      {showLookup ? 'Schowaj' : 'Szukaj'}
                    </Button>
                  }
                >
                  {showLookup && (
                    <RecipeLookup
                      recipes={recipeCatalog}
                      dispensable={chemicals.map((chemical) => chemical.id)}
                      onDispense={(id) => act('dispense', { reagent: id })}
                      beakerContents={data.beakerContents || []}
                    />
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {showReactionList && (
            <Stack.Item width={`${reactionWidth}px`}>
              <Section title="Receptury" fill>
                <Stack vertical fill>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <Input
                          placeholder="Szukaj reakcji…"
                          value={searchTerm}
                          fluid
                          onChange={(value) => setSearchTerm(value)}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          tooltip="Wyczyść wyszukiwanie"
                          disabled={searchTerm === ''}
                          onClick={() => setSearchTerm('')}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="thumbtack"
                          tooltip="Odepnij wszystkie"
                          disabled={pinnedReactions.length === 0}
                          onClick={() => setPinnedReactions([])}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Divider />
                  <Stack.Item grow mt={1}>
                    <Section scrollable fill>
                      <Stack vertical>
                        {filteredReactions.length > 0 ? (
                          filteredReactions.map((reaction) => (
                            <Stack.Item key={reaction.id}>
                              <ReactionDisplay
                                dropdownState={
                                  pinnedReactions.includes(reaction.id)
                                    ? DropdownState.DROPDOWN_OPEN
                                    : DropdownState.DROPDOWN_CLOSED
                                }
                                reaction={reaction}
                                pinnedReactions={pinnedReactions}
                                setPinnedReactions={setPinnedReactions}
                              />
                            </Stack.Item>
                          ))
                        ) : (
                          <NoticeBox>Nie znaleziono reakcji.</NoticeBox>
                        )}
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type ReagentDispenseButtonProps = {
  chemical: DispensableReagent;
  prefix?: string;
};

const ReagentDispenseButton = (props: ReagentDispenseButtonProps) => {
  const { chemical, prefix } = props;
  const { act } = useBackend<Data>();

  return (
    <Button
      key={chemical.id}
      icon="tint"
      fluid
      textColor={chemical.color}
      lineHeight={1.75}
      style={{
        textShadow: '1px 1px 0 black',
        textOverflow: 'ellipsis',
        overflow: 'hidden',
      }}
      onClick={() =>
        act('dispense', {
          reagent: chemical.id,
        })
      }
    >
      <span
        style={{
          color: 'white',
          textShadow: 'none',
          textOverflow: 'ellipsis',
          overflow: 'hidden',
        }}
      >
        {prefix}
        {chemical.title}
      </span>
    </Button>
  );
};

type ReactionDisplayProps = {
  // Jak wyświetlić rozwijaną listę:
  // NO_DROPDOWN - sama receptura, DROPDOWN_CLOSED - zwinięta,
  // DROPDOWN_OPEN - rozwinięta.
  dropdownState?: DropdownState;
  reaction: Recipe;
  // Id przypiętych receptur
  pinnedReactions: string[];
  setPinnedReactions: (reactions: string[]) => void;
  // Pozwala trzymać otwarte okienko rodzica
  setParentForceFloating?: (force: boolean) => void;
};

const ReactionDisplay = (props: ReactionDisplayProps) => {
  const {
    dropdownState,
    reaction,
    pinnedReactions,
    setPinnedReactions,
    setParentForceFloating,
  } = props;
  const temperatureMessage = getTemperatureMessage(reaction);

  const recipeList = (
    <BlockQuote>
      <Stack vertical>
        <Stack.Item>
          <HorizontalBarWithText text="Skład" />
        </Stack.Item>
        {reaction.reagents.map((reagent) => (
          <Stack.Item key={`${reaction.id}-${reagent.id}-req`}>
            <ReactionComponentDisplay
              reagentComponent={reagent}
              pinnedReactions={pinnedReactions}
              setPinnedReactions={setPinnedReactions}
              setParentForceFloating={setParentForceFloating}
            />
          </Stack.Item>
        ))}
        {reaction.catalysts.length > 0 && (
          <>
            <Stack.Item>
              <HorizontalBarWithText
                text={
                  reaction.catalysts.length === 1
                    ? 'Katalizator'
                    : 'Katalizatory'
                }
              />
            </Stack.Item>
            {reaction.catalysts.map((catalyst) => (
              <Stack.Item key={`${reaction.id}-${catalyst.id}-cat`}>
                <ReactionComponentDisplay
                  reagentComponent={catalyst}
                  pinnedReactions={pinnedReactions}
                  setPinnedReactions={setPinnedReactions}
                  setParentForceFloating={setParentForceFloating}
                />
              </Stack.Item>
            ))}
          </>
        )}
        {!!temperatureMessage && (
          <>
            <Stack.Item>
              <HorizontalBarWithText text="Temperatura" />
            </Stack.Item>
            <Stack.Item fontSize="0.9em">{temperatureMessage}</Stack.Item>
          </>
        )}
        {!!reaction.container && (
          <>
            <Stack.Item>
              <HorizontalBarWithText text="Pojemnik" />
            </Stack.Item>
            <Stack.Item fontSize="0.9em">{reaction.container}</Stack.Item>
          </>
        )}
        {reaction.results.length > 0 && (
          <>
            <Stack.Item>
              <HorizontalBarWithText text="Wynik" />
            </Stack.Item>
            <Stack.Item fontSize="0.9em">
              {reaction.results
                .map((result) => formatReagentName(result.amount, result.name))
                .join(', ')}
            </Stack.Item>
          </>
        )}
      </Stack>
    </BlockQuote>
  );

  return (
    <Stack
      p={1}
      style={{
        borderRadius: '4px',
        flexDirection: 'column',
        backgroundColor: 'black',
      }}
    >
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Button
              icon="thumbtack"
              tooltip="Przypnij (prawy przycisk: tylko ta)"
              onClick={() => {
                if (pinnedReactions.includes(reaction.id)) {
                  setPinnedReactions(
                    pinnedReactions.filter((rid) => rid !== reaction.id),
                  );
                } else {
                  setPinnedReactions([...pinnedReactions, reaction.id]);
                }
              }}
              onContextMenu={() => {
                setPinnedReactions([reaction.id]);
              }}
              selected={pinnedReactions.includes(reaction.id)}
            />
          </Stack.Item>
          <Stack.Item
            grow
            style={{
              overflow: 'hidden',
              whiteSpace: 'nowrap',
              textOverflow: 'ellipsis',
            }}
          >
            {reaction.name}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        {dropdownState === DropdownState.NO_DROPDOWN ? (
          recipeList
        ) : (
          <Collapsible
            title="Receptura"
            open={dropdownState === DropdownState.DROPDOWN_OPEN}
          >
            {recipeList}
          </Collapsible>
        )}
      </Stack.Item>
    </Stack>
  );
};

// U nas reakcja ma jeden próg temperatury (required_temp) i flagę is_cold_recipe
function getTemperatureMessage(reaction: Recipe): string | null {
  if (!reaction.temp) {
    return null;
  }
  if (reaction.cold) {
    return `Schłodź poniżej ${reaction.temp} K`;
  }
  return `Podgrzej do co najmniej ${reaction.temp} K`;
}

type ReactionComponentDisplayProps = {
  reagentComponent: RecipeReagent;
  pinnedReactions: string[];
  setPinnedReactions: (reactions: string[]) => void;
  setParentForceFloating?: (force: boolean) => void;
};

// Składnik receptury:
// - podstawowy odczynnik z dispensera - klik wydaje go,
// - inna receptura - po najechaniu pokazuje jej skład,
// - nic z tych - nieaktywny przycisk.
const ReactionComponentDisplay = (props: ReactionComponentDisplayProps) => {
  const {
    reagentComponent,
    pinnedReactions,
    setPinnedReactions,
    setParentForceFloating,
  } = props;
  const { data } = useBackend<Data>();
  const { chemicals = [], recipeCatalog = [] } = data;
  const [forceFloating, setForceFloating] = useState(false);

  const baseReagent = chemicals.find((chem) => chem.id === reagentComponent.id);

  if (baseReagent) {
    return (
      <ReagentDispenseButton
        chemical={baseReagent}
        prefix={formatReagentName(reagentComponent.amount)}
      />
    );
  }

  const foundRecipe = recipeCatalog.find((reaction) =>
    reaction.results.some((result) => result.id === reagentComponent.id),
  );

  if (!foundRecipe) {
    return (
      <Button fluid ellipsis disabled icon="question">
        {formatReagentName(reagentComponent.amount, reagentComponent.name)}
      </Button>
    );
  }

  return (
    <Floating
      // `|| undefined`, bo `false` oznacza zamknięte na sztywno,
      // a `undefined` - otwieranie i zamykanie normalnie.
      handleOpen={forceFloating || undefined}
      disabled={forceFloating}
      placement="left"
      closeAfterInteract={false}
      hoverOpen
      hoverSafePolygon
      onOpenChange={(state) => {
        if (setParentForceFloating) {
          setParentForceFloating(state);
        }
        if (!state) {
          setForceFloating(false);
        }
      }}
      content={
        <Box
          p={0.5}
          backgroundColor="hsl(0, 0%, 15%)"
          style={{
            borderRadius: '4px',
            backdropFilter: 'blur(12px)',
          }}
        >
          <Stack
            backgroundColor="black"
            p={1}
            style={{
              borderRadius: '4px',
              flexDirection: 'column',
            }}
          >
            <Stack.Item>
              <ReactionDisplay
                dropdownState={DropdownState.NO_DROPDOWN}
                reaction={foundRecipe}
                pinnedReactions={pinnedReactions}
                setPinnedReactions={setPinnedReactions}
                setParentForceFloating={setForceFloating}
              />
            </Stack.Item>
          </Stack>
        </Box>
      }
    >
      <Button icon="book" fluid ellipsis backgroundColor="default">
        {formatReagentName(reagentComponent.amount, reagentComponent.name)}
      </Button>
    </Floating>
  );
};

function formatReagentName(amount: number, name?: string) {
  if (!name) return `${amount} cz. `;

  return `${amount} cz. ${name}`;
}

const HorizontalBarWithText = (props: { text: string }) => {
  const { text } = props;
  return (
    <Stack>
      <Stack.Item grow>
        <hr />
      </Stack.Item>
      <Stack.Item fontSize="0.95em">{text}</Stack.Item>
      <Stack.Item grow>
        <hr />
      </Stack.Item>
    </Stack>
  );
};
