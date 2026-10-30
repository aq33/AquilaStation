import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { BooleanLike } from '../../common/react';
import { classes } from '../../common/react';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  biomass: any;
  categories: any;
  max_visual_biomass: any;
  replicating: any;
  selected_temperature: any;
  temperatures: any;
};

type ReplicatorData = {
  replicating: BooleanLike;
  biomass: number;
  max_visual_biomass: number;
  selected_temperature: string;
  temperatures: string[];
  categories: Category[];
};

type Category = {
  name: string;
  items: Design[];
};

type Design = {
  id: number;
  name: string;
  disable: BooleanLike;
  cost: number;
};

// AQUILA: temperatury idą do DM (change_temperature), tłumaczymy tylko napis
const TEMPERATURE_NAMES: Record<string, string> = {
  cold: 'zimne',
  warm: 'ciepłe',
  hot: 'gorące',
  'extra hot': 'bardzo gorące',
  'well done': 'dobrze wysmażone',
};

export const Replicator = (props) => {
  const { act, data } = useBackend<ReplicatorData>();
  const {
    replicating,
    biomass,
    max_visual_biomass,
    categories,
    selected_temperature,
    temperatures,
  } = data;

  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    'category',
    data.categories[0]?.name,
  );
  const items =
    categories.find((category) => category.name === selectedCategory)?.items ||
    [];
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <NoticeBox info>
                To urządzenie obsługuje się głosem i dotykiem.
                <br />
                Powiedz replikatorowi, co wybierasz, w jednym z poniższych
                formatów (słowa kluczowe po angielsku):
                <br />
                Computer/Alexa/Google/AI/Voice.
                <br />
                Wybrane jedzenie.
                <br />
                Cold/Warm/Hot/Extra Hot/Well Done.
              </NoticeBox>
              <LabeledList>
                <LabeledList.Item label="Biomasa">
                  <ProgressBar
                    value={biomass}
                    minValue={0}
                    maxValue={max_visual_biomass}
                    color="good"
                  >
                    <Box
                      lineHeight={1.9}
                      style={{
                        textShadow: '1px 1px 0 black',
                      }}
                    >
                      {`${parseFloat(biomass.toFixed(2))} j.`}
                    </Box>
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Temperatura">
                  <Dropdown
                    width="100%"
                    selected={selected_temperature}
                    displayText={
                      TEMPERATURE_NAMES[selected_temperature] ||
                      selected_temperature
                    }
                    options={temperatures.map((temperature) => ({
                      value: temperature,
                      displayText:
                        TEMPERATURE_NAMES[temperature] || temperature,
                    }))}
                    onSelected={(value) =>
                      act('change_temperature', {
                        updated_temperature: value,
                      })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              {categories.map((category) => (
                <Tabs.Tab
                  align="center"
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}
                >
                  {category.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow mt={'2px'}>
            <Section fill scrollable>
              <Table>
                <ItemList
                  replicating={replicating}
                  biomass={biomass}
                  items={items}
                />
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props) => {
  const { act } = useBackend<Data>();
  const items = props.items.map((item) => {
    const disabled = props.replicating || props.biomass < Math.ceil(item.cost);
    return {
      ...item,
      disabled,
    };
  });
  return items.map((item) => (
    <Table.Row key={item.id}>
      <Table.Cell>
        <span
          className={classes(['design32x32', item.id])}
          style={{
            verticalAlign: 'middle',
          }}
        />{' '}
        <b>{item.name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          fluid
          align="right"
          content={parseFloat(item.cost.toFixed(2)) + ' BIO'}
          disabled={!item.disabled}
          onClick={() =>
            act('replicate', {
              id: item.id,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  ));
};
