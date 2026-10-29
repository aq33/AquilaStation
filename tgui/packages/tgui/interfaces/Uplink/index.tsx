// AQUILA: wygląd uplinka z tg (ikony, kategorie z boku, widok zwarty) na danych
// naszego code/datums/components/uplink.dm. Bez celów głównych, reputacji,
// populacji i blokady sklepu z tg - tych mechanik nie mamy.
import { Box, Button, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { GenericUplink, type Item } from './GenericUplink';

export { GenericUplink, type Item } from './GenericUplink';

// Kategorie są kluczami w DM (filtered_uplink_items, team_discounts),
// więc tłumaczymy je tylko przy wyświetlaniu.
const UPLINK_CATEGORY_PL: Record<string, string> = {
  'Discounted Gear': 'Przeceniony sprzęt',
  'Discounted Team Gear': 'Przeceniony sprzęt drużyny',
  'Limited Stock Team Gear': 'Sprzęt drużyny (ograniczony nakład)',
  Discounts: 'Zniżki',
  Bundles: 'Zestawy',
  'Conspicuous Weapons': 'Rzucająca się w oczy broń',
  'Stealthy Weapons': 'Dyskretna broń',
  Ammunition: 'Amunicja',
  Explosives: 'Materiały wybuchowe',
  'Support and Exosuits': 'Wsparcie i egzoszkielety',
  'Stealth Gadgets': 'Gadżety do ukrywania się',
  'Space Suits': 'Skafandry kosmiczne',
  'Misc. Gadgets': 'Różne gadżety',
  Implants: 'Implanty',
  'Species-Restricted': 'Tylko dla gatunku',
  'Role-Restricted': 'Tylko dla roli',
  '(Pointless) Badassery': '(Bezsensowny) szpan',
  Services: 'Usługi',
  'Infiltration Gear': 'Sprzęt infiltracyjny',
  'Spy Unique': 'Unikaty szpiega',
};

const categoryName = (name: string) => UPLINK_CATEGORY_PL[name] ?? name;

type UplinkItem = {
  name: string;
  cost: number;
  desc: string;
  icon?: string;
  icon_state?: string;
  limited_stock?: number;
};

type UplinkCategory = {
  name: string;
  items: UplinkItem[] | null;
};

type UplinkData = {
  telecrystals: number;
  lockable: BooleanLike;
  compactMode: BooleanLike;
  categories: UplinkCategory[];
};

export const Uplink = (props) => {
  const { act, data } = useBackend<UplinkData>();
  const { telecrystals = 0, lockable, compactMode, categories = [] } = data;

  const categoryNames = categories.map((category) =>
    categoryName(category.name),
  );
  const items: Item[] = [];
  for (const category of categories) {
    for (const item of category.items || []) {
      items.push({
        id: item.name,
        name: decodeHtmlEntities(item.name),
        icon: item.icon || '',
        icon_state: item.icon_state || '',
        category: categoryName(category.name),
        desc: (
          <>
            <Box>{decodeHtmlEntities(item.desc)}</Box>
            {item.limited_stock !== undefined && item.limited_stock > 0 && (
              <Box mt={0.5} color="average">
                Pozostało sztuk: {item.limited_stock}
              </Box>
            )}
          </>
        ),
        cost: <Box>{`${item.cost} TC`}</Box>,
        population_tooltip: '',
        insufficient_population: false,
        disabled: telecrystals < item.cost,
      });
    }
  }

  return (
    <Window width={700} height={600} theme="syndicate">
      <Window.Content>
        <Stack fill vertical>
          {!!lockable && (
            <Stack.Item>
              <Section fitted>
                <Stack fill>
                  <Stack.Item grow />
                  <Stack.Item>
                    <Button
                      lineHeight={2.5}
                      textAlign="center"
                      icon="lock"
                      color="transparent"
                      px={2}
                      onClick={() => act('lock')}
                    >
                      Zablokuj
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <GenericUplink
              currency={`${telecrystals} TC`}
              categories={categoryNames}
              items={items}
              compactMode={compactMode}
              onCompactToggle={() => act('compact_toggle')}
              handleBuy={(item) => act('buy', { name: item.id })}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
