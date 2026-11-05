import { classes } from 'common/react';

import { useBackend } from '../../backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Icon,
  Section,
  Stack,
  Tooltip,
} from '../../components';
import { CharacterPreview } from '../common/CharacterPreview';
import {
  createSetPreference,
  Food,
  Perk,
  PreferencesMenuData,
  ServerData,
  Species,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const FOOD_ICONS = {
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'bacon',
  [Food.Fruit]: 'apple-alt',
  [Food.Grain]: 'bread-slice',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'hamburger',
  [Food.Raw]: 'drumstick-bite',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
};

const FOOD_NAMES: Record<keyof typeof FOOD_ICONS, string> = {
  [Food.Bugs]: 'Robaki',
  [Food.Cloth]: 'Ubrania',
  [Food.Dairy]: 'Nabiał',
  [Food.Fried]: 'Smażone jedzenie',
  [Food.Fruit]: 'Owoce',
  [Food.Grain]: 'Zboża',
  [Food.Gross]: 'Obrzydliwe jedzenie',
  [Food.Junkfood]: 'Śmieciowe jedzenie',
  [Food.Meat]: 'Mięso',
  [Food.Raw]: 'Surowe',
  [Food.Sugar]: 'Słodycze',
  [Food.Toxic]: 'Toksyczne jedzenie',
  [Food.Vegetables]: 'Warzywa',
};

const IGNORE_UNLESS_LIKED: Set<Food> = new Set([
  Food.Bugs,
  Food.Cloth,
  Food.Gross,
  Food.Toxic,
]);

const notIn = function <T>(set: Set<T>) {
  return (value: T) => {
    return !set.has(value);
  };
};

const FoodList = (props: {
  food: Food[];
  icon: string;
  name: string;
  className: string;
}) => {
  if (props.food.length === 0) {
    return null;
  }

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Icon name={props.icon} /> <b>{props.name}</b>
          <Divider />
          <Box>
            {props.food
              .reduce((names, food) => {
                const foodName = FOOD_NAMES[food];
                return foodName ? names.concat(foodName) : names;
              }, [])
              .join(', ')}
          </Box>
        </Box>
      }
    >
      <Stack ml={2}>
        {props.food.map((food) => {
          return (
            FOOD_ICONS[food] && (
              <Stack.Item>
                <Icon
                  className={props.className}
                  size={1.4}
                  key={food}
                  name={FOOD_ICONS[food]}
                />
              </Stack.Item>
            )
          );
        })}
      </Stack>
    </Tooltip>
  );
};

const Diet = (props: { diet: Species['diet'] }) => {
  if (!props.diet) {
    return null;
  }

  const { liked_food, disliked_food, toxic_food } = props.diet;

  return (
    <Stack>
      <Stack.Item>
        <FoodList
          food={liked_food}
          icon="heart"
          name="Lubiane jedzenie"
          className="color-pink"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={disliked_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="thumbs-down"
          name="Nielubiane jedzenie"
          className="color-red"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={toxic_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="biohazard"
          name="Toksyczne jedzenie"
          className="color-olive"
        />
      </Stack.Item>
    </Stack>
  );
};

const SpeciesPerk = (props: { className: string; perk: Perk }) => {
  const { className, perk } = props;

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Box as="b">{perk.name}</Box>
          <Divider />
          <Box>{perk.description}</Box>
        </Box>
      }
    >
      <Box className={className} width="32px" height="32px">
        <Icon
          name={perk.ui_icon}
          size={1.5}
          ml={0}
          mt={1}
          style={{
            textAlign: 'center',
            height: '100%',
            width: '100%',
          }}
        />
      </Box>
    </Tooltip>
  );
};

const SpeciesPerks = (props: { perks: Species['perks'] }) => {
  const { positive, negative, neutral } = props.perks;

  return (
    <Stack fill justify="space-between">
      <Stack.Item>
        <Stack>
          {positive.map((perk) => {
            return (
              <Stack.Item key={perk.name}>
                <SpeciesPerk className="color-bg-green" perk={perk} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      <Stack>
        {neutral.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-grey" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>

      <Stack>
        {negative.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-red" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>
    </Stack>
  );
};

const SpeciesPageInner = (props: {
  handleClose: () => void;
  species: ServerData['species'];
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const setSpecies = createSetPreference(act, 'species');

  let species: [string, Species][] = Object.entries(props.species).map(
    ([species, data]) => {
      return [species, data];
    },
  );

  // Humans are always the top of the list
  const humanIndex = species.findIndex(([species]) => species === 'human');
  const swapWith = species[0];
  species[0] = species[humanIndex];
  species[humanIndex] = swapWith;

  const currentSpecies = species.filter(([speciesKey]) => {
    return speciesKey === data.character_preferences.misc.species;
  })[0][1];

  let selectableSpecies: [string, Species][] = species.filter(
    ([_, s]) => s.selectable,
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Button icon="arrow-left" onClick={props.handleClose} content="Wróć" />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <Box
              height="calc(100vh - 170px)"
              overflowY="auto"
              overflowX="hidden"
              mr={3}
            >
              {selectableSpecies.map(([speciesKey, species]) => {
                return !currentSpecies.selectable ? (
                  <Button.Confirm
                    confirmContent="Na pewno?"
                    key={speciesKey}
                    onClick={() => setSpecies(speciesKey)}
                    selected={
                      data.character_preferences.misc.species === speciesKey
                    }
                    tooltip={
                      <>
                        <Box>{species.name}</Box>
                        <Box textColor="red">
                          <strong>
                            Po zmianie rasy nie wybierzesz już ponownie rasy
                            {currentSpecies.name}. Na pewno?
                          </strong>
                        </Box>
                      </>
                    }
                    content={
                      <Box
                        className={classes(['species64x64', species.icon])}
                        ml={-1}
                      />
                    }
                    style={{
                      display: 'block',
                      height: '64px',
                      width: '64px',
                    }}
                  />
                ) : (
                  <Button
                    key={speciesKey}
                    onClick={() => setSpecies(speciesKey)}
                    selected={
                      data.character_preferences.misc.species === speciesKey
                    }
                    tooltip={species.name}
                    content={
                      <Box
                        className={classes(['species64x64', species.icon])}
                        ml={-1}
                      />
                    }
                    style={{
                      display: 'block',
                      height: '64px',
                      width: '64px',
                    }}
                  />
                );
              })}
              {!currentSpecies.selectable && (
                <Button
                  selected
                  tooltip={
                    <>
                      <Box>{currentSpecies.name}</Box>
                      <Box textColor="red">
                        <strong>
                          Niedostępna dla nowych postaci, ale dozwolona przez
                          roundstart_no_hard_check. Po zmianie rasy nie
                          wybierzesz jej już ponownie.
                        </strong>
                      </Box>
                    </>
                  }
                  content={
                    <Box
                      className={classes(['species64x64', currentSpecies.icon])}
                      ml={-1}
                    />
                  }
                  style={{
                    display: 'block',
                    height: '64px',
                    width: '64px',
                  }}
                />
              )}
            </Box>
          </Stack.Item>

          <Stack.Item grow>
            <Box>
              <Box>
                <Stack fill>
                  <Stack.Item width="70%">
                    <Section
                      title={currentSpecies.name}
                      buttons={
                        // NOHUNGER species have no diet (diet = null),
                        // so we have nothing to show
                        currentSpecies.diet && (
                          <Diet diet={currentSpecies.diet} />
                        )
                      }
                    >
                      <Section
                        title="Opis"
                        buttons={
                          !currentSpecies.selectable && (
                            <Box textColor="red">
                              <strong>
                                Niedostępna, ale dozwolona dla twojej
                                istniejącej postaci.
                              </strong>
                            </Box>
                          )
                        }
                      >
                        {currentSpecies.desc}
                      </Section>

                      <Section title="Cechy">
                        <SpeciesPerks perks={currentSpecies.perks} />
                      </Section>
                    </Section>
                  </Stack.Item>

                  <Stack.Item width="30%">
                    <CharacterPreview
                      id={data.character_preview_view}
                      height="100%"
                    />
                  </Stack.Item>
                </Stack>
              </Box>

              {currentSpecies.lore && (
                <Box mt={1}>
                  <Section title="Historia">
                    <BlockQuote>
                      {currentSpecies.lore.map((text, index) => (
                        <Box key={index} maxWidth="100%">
                          {text}
                          {index !== (currentSpecies.lore || []).length - 1 && (
                            <>
                              <br />
                              <br />
                            </>
                          )}
                        </Box>
                      ))}
                    </BlockQuote>
                  </Section>
                </Box>
              )}
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const SpeciesPage = (props: { closeSpecies: () => void }) => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (serverData) {
          return (
            <SpeciesPageInner
              handleClose={props.closeSpecies}
              species={serverData.species}
            />
          );
        } else {
          return <Box>Wczytywanie ras...</Box>;
        }
      }}
    />
  );
};
