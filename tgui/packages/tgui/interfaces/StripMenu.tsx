import { range } from 'es-toolkit';
import type { CSSProperties } from 'react';
import { Box, Button, Icon, Image, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

const ROWS = 5;
const COLUMNS = 6;

const BUTTON_DIMENSIONS = '64px';

type GridSpotKey = string;

const getGridSpotKey = (spot: [number, number]): GridSpotKey => {
  return `${spot[0]}/${spot[1]}`;
};

const CornerText = (props: {
  align: 'left' | 'right';
  children: string;
}): React.JSX.Element => {
  const { align, children } = props;

  return (
    <Box
      style={{
        position: 'relative',
        left: align === 'left' ? '2px' : '-2px',
        textAlign: align,
        textShadow: '1px 1px 1px #555',
      }}
    >
      {children}
    </Box>
  );
};

type AlternateAction = {
  icon: string;
  text: string;
};

const ALTERNATE_ACTIONS: Record<string, AlternateAction> = {
  knot: {
    icon: 'shoe-prints',
    text: 'Zawiąż na supeł',
  },

  untie: {
    icon: 'shoe-prints',
    text: 'Rozwiąż',
  },

  unknot: {
    icon: 'shoe-prints',
    text: 'Rozplącz supeł',
  },

  remove_item_cuffs: {
    icon: 'handcuffs',
    text: 'Zdejmij kajdanki',
  },

  enable_internals: {
    icon: 'tg-air-tank',
    text: 'Włącz butlę',
  },

  disable_internals: {
    icon: 'tg-air-tank-slash',
    text: 'Wyłącz butlę',
  },

  adjust_jumpsuit: {
    icon: 'tshirt',
    text: 'Popraw uniform',
  },

  adjust_sensor: {
    icon: 'microchip',
    text: 'Ustaw czujniki',
  },

  // AQUILA: nasz DM używa tej nazwy
  adjust_sensors: {
    icon: 'microchip',
    text: 'Ustaw czujniki',
  },

  strip_accessory: {
    icon: 'ribbon',
    text: 'Zdejmij dodatek',
  },

  deploy: {
    icon: 'plus',
    text: 'Rozłóż MOD',
  },

  undeploy: {
    icon: 'minus',
    text: 'Złóż MOD',
  },

  activate_mod: {
    icon: 'power-off',
    text: 'Włącz MOD',
  },
  deactivate_mod: {
    icon: 'power-off',
    text: 'Wyłącz MOD',
  },

  access_storage: {
    icon: 'box-open',
    text: 'Otwórz',
  },
};

type StripSlot = {
  displayName: string;
  gridSpot: GridSpotKey;
  image?: string;
  additionalComponent?: React.JSX.Element;
};

const SLOTS: Record<string, StripSlot> = {
  eyes: {
    displayName: 'okulary',
    gridSpot: getGridSpotKey([0, 0]),
    image: 'inventory-glasses.png',
  },

  head: {
    displayName: 'nakrycie głowy',
    gridSpot: getGridSpotKey([0, 1]),
    image: 'inventory-head.png',
  },

  neck: {
    displayName: 'szyja',
    gridSpot: getGridSpotKey([1, 0]),
    image: 'inventory-neck.png',
  },

  mask: {
    displayName: 'maska',
    gridSpot: getGridSpotKey([1, 1]),
    image: 'inventory-mask.png',
  },

  pet_collar: {
    displayName: 'obroża',
    gridSpot: getGridSpotKey([1, 0]),
    image: 'inventory-collar.png',
  },

  // AQUILA: obroża korgiego ma u nas inny klucz
  corgi_collar: {
    displayName: 'obroża',
    gridSpot: getGridSpotKey([1, 0]),
    image: 'inventory-collar.png',
  },

  ears: {
    displayName: 'uszy',
    gridSpot: getGridSpotKey([0, 2]),
    image: 'inventory-ears.png',
  },

  parrot_headset: {
    displayName: 'słuchawka',
    gridSpot: getGridSpotKey([0, 2]),
    image: 'inventory-ears.png',
  },

  handcuffs: {
    displayName: 'kajdanki',
    gridSpot: getGridSpotKey([3, 5]),
  },

  legcuffs: {
    displayName: 'kajdany na nogi',
    gridSpot: getGridSpotKey([4, 2]),
  },

  jumpsuit: {
    displayName: 'uniform',
    gridSpot: getGridSpotKey([2, 1]),
    image: 'inventory-uniform.png',
  },

  suit: {
    displayName: 'strój wierzchni',
    gridSpot: getGridSpotKey([2, 2]),
    image: 'inventory-suit.png',
  },

  gloves: {
    displayName: 'rękawice',
    gridSpot: getGridSpotKey([3, 4]),
    image: 'inventory-gloves.png',
  },

  right_hand: {
    displayName: 'prawa ręka',
    gridSpot: getGridSpotKey([2, 4]),
    image: 'inventory-hand_r.png',
    additionalComponent: <CornerText align="left">R</CornerText>,
  },

  left_hand: {
    displayName: 'lewa ręka',
    gridSpot: getGridSpotKey([2, 5]),
    image: 'inventory-hand_l.png',
    additionalComponent: <CornerText align="right">L</CornerText>,
  },

  upper_right_hand: {
    displayName: 'górna prawa ręka',
    gridSpot: getGridSpotKey([1, 4]),
    image: 'inventory-hand_r.png',
    additionalComponent: <CornerText align="left">(U) R</CornerText>,
  },

  upper_left_hand: {
    displayName: 'górna lewa ręka',
    gridSpot: getGridSpotKey([1, 5]),
    image: 'inventory-hand_l.png',
    additionalComponent: <CornerText align="right">L (U)</CornerText>,
  },

  shoes: {
    displayName: 'buty',
    gridSpot: getGridSpotKey([4, 1]),
    image: 'inventory-shoes.png',
  },

  suit_storage: {
    displayName: 'schowek stroju',
    gridSpot: getGridSpotKey([2, 0]),
    image: 'inventory-suit_storage.png',
  },

  id: {
    displayName: 'identyfikator',
    gridSpot: getGridSpotKey([4, 0]),
    image: 'inventory-id.png',
  },

  belt: {
    displayName: 'pas',
    gridSpot: getGridSpotKey([3, 1]),
    image: 'inventory-belt.png',
  },

  back: {
    displayName: 'plecak',
    gridSpot: getGridSpotKey([1, 2]),
    image: 'inventory-back.png',
  },

  left_pocket: {
    displayName: 'lewa kieszeń',
    gridSpot: getGridSpotKey([3, 0]),
    image: 'inventory-pocket.png',
  },

  right_pocket: {
    displayName: 'prawa kieszeń',
    gridSpot: getGridSpotKey([3, 2]),
    image: 'inventory-pocket.png',
  },
};

enum ObscuringLevel {
  Completely = 1,
  Hidden = 2,
  Inaccessible = 3,
}

type Interactable = {
  interacting: BooleanLike;
};

type AlternateActions = {
  alternate?: string[];
  alternate_icons?: Record<string, string> | null;
};

/**
 * Some possible options:
 *
 * null - No interactions, no item, but is an available slot
 * { interacting: 1 } - No item, but we're interacting with it
 * { icon: icon, name: name } - An item with no alternate actions
 *   that we're not interacting with.
 * { icon, name, interacting: 1 } - An item with no alternate actions
 *   that we're interacting with.
 */
type StripMenuItem =
  | null
  | Interactable
  | ((
      | ({
          icon: string;
          name: string;
          obscured: ObscuringLevel;
        } & AlternateActions)
      | ({
          obscured: ObscuringLevel;
        } & AlternateActions)
    ) &
      Partial<Interactable>);

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
  name: string;
};

export const StripMenu = (props) => {
  const { act, data } = useBackend<StripMenuData>();

  const gridSpots = new Map<GridSpotKey, string>();
  for (const key of Object.keys(data.items)) {
    // AQUILA: sloty bez miejsca w siatce (inne moby) pomijamy zamiast wywracać okno
    if (!SLOTS[key]) {
      continue;
    }
    gridSpots.set(SLOTS[key].gridSpot, key);
  }

  return (
    // (64 + 6) * 6 + 6 = 426
    // (64 + 6) * 5 + 6 + 31 (from title) =
    <Window title={`Przeszukujesz: ${data.name}`} width={426} height={387}>
      <Window.Content>
        <Stack fill vertical>
          {range(0, ROWS).map((row) => (
            <Stack.Item key={row}>
              <Stack fill>
                {range(0, COLUMNS).map((column) => {
                  const key = getGridSpotKey([row, column]);
                  const keyAtSpot = gridSpots.get(key);

                  if (!keyAtSpot) {
                    return (
                      <Stack.Item
                        key={key}
                        style={{
                          width: BUTTON_DIMENSIONS,
                          height: BUTTON_DIMENSIONS,
                        }}
                      />
                    );
                  }

                  const item = data.items[keyAtSpot];
                  const slot = SLOTS[keyAtSpot];

                  let content: React.JSX.Element | undefined;
                  let alternateActions: React.JSX.Element[] | undefined;
                  let tooltip: string | undefined;

                  if (item === null) {
                    tooltip = slot.displayName;
                  } else if ('name' in item) {
                    content = (
                      <Image
                        src={`data:image/jpeg;base64,${item.icon}`}
                        width="64px"
                        height="64px"
                        style={{
                          verticalAlign: 'middle',
                        }}
                      />
                    );

                    tooltip = item.name;
                  } else if (
                    'obscured' in item &&
                    (item.obscured === ObscuringLevel.Hidden ||
                      item.obscured === ObscuringLevel.Completely)
                  ) {
                    content = (
                      <Icon
                        name={
                          item.obscured === ObscuringLevel.Completely
                            ? 'ban'
                            : 'eye-slash'
                        }
                        size={3}
                        ml={0}
                        mt={2.5}
                        style={{
                          textAlign: 'center',
                          verticalAlign: 'middle',
                          height: '100%',
                          width: '100%',
                        }}
                      />
                    );

                    tooltip = `zasłonięte: ${slot.displayName}`;
                  }

                  if (item && 'alternate' in item && item.alternate?.length) {
                    alternateActions = item.alternate.map(
                      (alternateKey, idx) => {
                        const alternateAction = ALTERNATE_ACTIONS[
                          alternateKey
                        ] || { icon: 'ellipsis', text: alternateKey };
                        const alternateIcon =
                          item.alternate_icons?.[alternateKey];

                        const alternateActionStyle: CSSProperties = {
                          background: 'rgba(0, 0, 0, 0.6)',
                          position: 'absolute',
                          overflow: 'hidden',
                          margin: '0',
                          width: '20px',
                          height: '20px',
                          zIndex: '2',
                          left: idx === 0 ? '0' : undefined,
                          right: idx === 1 ? '0' : undefined,
                          top: idx === 2 ? '0' : undefined,
                          bottom: '0',
                          padding: '0',
                          textAlign: 'center',
                        };
                        return (
                          <Button
                            key={alternateAction.text}
                            onClick={() => {
                              act('alt', {
                                key: keyAtSpot,
                                alternate_action: alternateKey,
                              });
                            }}
                            tooltip={alternateAction.text}
                            style={alternateActionStyle}
                            disabled={
                              item.obscured === ObscuringLevel.Inaccessible
                            }
                            opacity={
                              item.obscured === ObscuringLevel.Inaccessible
                                ? 0.7
                                : 1
                            }
                          >
                            {alternateIcon ? (
                              <Image
                                src={`data:image/jpeg;base64,${alternateIcon}`}
                                width="20px"
                                height="20px"
                              />
                            ) : (
                              <Icon name={alternateAction.icon} />
                            )}
                          </Button>
                        );
                      },
                    );
                  }

                  return (
                    <Stack.Item
                      key={key}
                      style={{
                        width: BUTTON_DIMENSIONS,
                        height: BUTTON_DIMENSIONS,
                      }}
                    >
                      <Box
                        style={{
                          position: 'relative',
                          width: '100%',
                          height: '100%',
                        }}
                      >
                        <Button
                          onClick={() => {
                            act('use', {
                              key: keyAtSpot,
                            });
                          }}
                          fluid
                          tooltip={tooltip}
                          style={{
                            background: item?.interacting
                              ? 'hsl(39, 73%, 30%)'
                              : undefined,
                            position: 'relative',
                            width: '100%',
                            height: '100%',
                            padding: '0',
                          }}
                        >
                          {slot.image && !(item && 'name' in item) && (
                            <Image
                              className="centered-image"
                              src={resolveAsset(slot.image)}
                              opacity={0.7}
                              width="64px"
                              height="64px"
                            />
                          )}

                          <Box style={{ position: 'relative' }}>{content}</Box>

                          {slot.additionalComponent}
                        </Button>
                        {alternateActions}
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
