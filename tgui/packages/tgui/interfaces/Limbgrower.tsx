import {
  Box,
  Button,
  Dimmer,
  Icon,
  LabeledList,
  Section,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Reagent = {
  reagent_name: string;
  reagent_amount: number;
  reagent_type: string;
};

type Design = {
  parent_category: string;
  name: string;
  id: string;
  needed_reagents: { name: string; amount: number }[];
};

type Category = {
  name: string;
  designs: Design[];
};

type Data = {
  busy: BooleanLike;
  categories: Category[];
  max_reagents: number;
  reagents: Reagent[];
  total_reagents: number;
};

// Nazwy kategorii z DM to identyfikatory, tu tylko etykiety zakładek
const CATEGORY_LABELS = {
  human: 'Ludzie',
  lizard: 'Jaszczuroludzie',
  plasmaman: 'Plazmoludzie',
  ethereal: 'Eterealowie',
  moth: 'Ćmy',
  apid: 'Apidzi',
  other: 'Inne',
};

export const Limbgrower = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    reagents = [],
    total_reagents,
    max_reagents,
    categories = [],
    busy,
  } = data;
  const [tab, setTab] = useSharedState('category', categories[0]?.name);
  const designList =
    categories.find((category) => category.name === tab)?.designs || [];

  return (
    <Window title="Hodowla kończyn" width={500} height={550}>
      {!!busy && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin />
          {' Hodowanie...'}
        </Dimmer>
      )}
      <Window.Content scrollable>
        <Section title="Odczynniki">
          <Box mb={1}>
            Zajęte {total_reagents} / {max_reagents} u pojemności.
          </Box>
          <LabeledList>
            {reagents.map((reagent) => (
              <LabeledList.Item
                key={reagent.reagent_name}
                label={reagent.reagent_name}
                buttons={
                  <Button.Confirm
                    textAlign="center"
                    width="120px"
                    color="bad"
                    confirmContent="Na pewno?"
                    onClick={() =>
                      act('empty_reagent', {
                        reagent_type: reagent.reagent_type,
                      })
                    }
                  >
                    Usuń odczynnik
                  </Button.Confirm>
                }
              >
                {reagent.reagent_amount}u
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Wzory">
          <Tabs fluid>
            {categories.map((category) => (
              <Tabs.Tab
                key={category.name}
                selected={tab === category.name}
                onClick={() => setTab(category.name)}
              >
                {CATEGORY_LABELS[category.name] || category.name}
              </Tabs.Tab>
            ))}
          </Tabs>
          <LabeledList>
            {designList.map((design) => (
              <LabeledList.Item
                key={design.name}
                label={design.name}
                buttons={
                  <Button
                    color="good"
                    onClick={() =>
                      act('make_limb', {
                        design_id: design.id,
                        active_tab: design.parent_category,
                      })
                    }
                  >
                    Wyhoduj
                  </Button>
                }
              >
                {design.needed_reagents.map((reagent) => (
                  <Box key={reagent.name}>
                    {reagent.name}: {reagent.amount}u
                  </Box>
                ))}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
