// AQUILA - wózek z jedzeniem (code/modules/food_and_drinks/kitchen_machinery/food_cart.dm).
// tg obsługuje wózek bez okna, więc to własne okno w miejsce dawnego HTML:
// napoje, mikser, nalewanie do szklanek i wydawanie jedzenia.
import {
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Reagent = {
  name: string;
  volume: number;
  id: string;
};

type Food = {
  name: string;
  amount: number;
};

type Data = {
  glasses: number;
  portion: number;
  drinks: Reagent[];
  mixer: Reagent[];
  food: Food[];
};

export const FoodCart = (props) => {
  const { act, data } = useBackend<Data>();
  const { glasses, portion } = data;
  const drinks = data.drinks || [];
  const mixer = data.mixer || [];
  const food = data.food || [];
  const noGlasses = glasses <= 0;

  return (
    <Window width={500} height={520} title="Wózek z jedzeniem">
      <Window.Content scrollable>
        <Section title="Zmagazynowane składniki i napoje">
          <LabeledList>
            <LabeledList.Item label="Pozostałe szklanki">
              {glasses}
            </LabeledList.Item>
            <LabeledList.Item label="Porcja">
              <NumberInput
                value={portion}
                minValue={0}
                maxValue={50}
                step={1}
                unit="u"
                width="60px"
                onChange={(value) => act('portion', { amount: value })}
              />
            </LabeledList.Item>
          </LabeledList>
          {drinks.length === 0 ? (
            <NoticeBox mt={1}>Brak napojów.</NoticeBox>
          ) : (
            <Table mt={1}>
              {drinks.map((reagent) => (
                <Table.Row key={reagent.id} className="candystripe">
                  <Table.Cell>
                    {reagent.name}: {reagent.volume}u
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="trash"
                      color="bad"
                      tooltip="Wylej"
                      onClick={() => act('purge', { id: reagent.id })}
                    />
                    <Button
                      icon="glass-whiskey"
                      disabled={noGlasses}
                      onClick={() => act('pour', { id: reagent.id })}
                    >
                      Nalej do szklanki
                    </Button>
                    <Button
                      icon="blender"
                      onClick={() => act('mix', { id: reagent.id })}
                    >
                      Do miksera
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section title="Zawartość miksera">
          {mixer.length === 0 ? (
            <NoticeBox>Mikser jest pusty.</NoticeBox>
          ) : (
            <Table>
              {mixer.map((reagent) => (
                <Table.Row key={reagent.id} className="candystripe">
                  <Table.Cell>
                    {reagent.name}: {reagent.volume}u
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="undo"
                      onClick={() => act('transfer', { id: reagent.id })}
                    >
                      Przelej z powrotem
                    </Button>
                    <Button
                      icon="glass-whiskey"
                      disabled={noGlasses}
                      onClick={() => act('m_pour', { id: reagent.id })}
                    >
                      Nalej do szklanki
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section title="Zmagazynowane jedzenie">
          {food.length === 0 ? (
            <NoticeBox>Brak jedzenia.</NoticeBox>
          ) : (
            <Table>
              {food.map((item) => (
                <Table.Row key={item.name} className="candystripe">
                  <Table.Cell>
                    {item.name}: {item.amount}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="hand-holding"
                      onClick={() => act('dispense', { name: item.name })}
                    >
                      Wydaj
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
