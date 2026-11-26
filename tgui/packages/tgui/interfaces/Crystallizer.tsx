import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasColor } from '../constants';
import { Window } from '../layouts';

// AQUILA: okno krystalizatora z tg (plan maszynowni E14), maszyna w aquila/code/modules/atmospherics/machinery/crystallizer/.
// Różnica względem tg: wymagania receptury przychodzą jako dane, a tekst składa okno.

type Requirement = {
  id: string;
  name: string;
  amount: number;
};

type Recipe = {
  id: string;
  name: string;
  min_temp: number;
  max_temp: number | null;
  energy_release: number;
  requirements: Requirement[];
};

type Gas = {
  id: string;
  name: string;
  amount: number;
};

type Data = {
  on: BooleanLike;
  selected: string;
  recipes: Recipe[];
  internal_temperature: number;
  progress_bar: number;
  gas_input: number;
  max_gas_input: number;
  internal_gas_data: Gas[];
};

const logScale = (value: number) => Math.log2(16 + Math.max(0, value)) - 4;

export const Crystallizer = (props) => {
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Controls />
        <Requirements />
        <Gases />
      </Window.Content>
    </Window>
  );
};

const Controls = (props) => {
  const { act, data } = useBackend<Data>();
  const { gas_input, max_gas_input, on, selected, recipes = [] } = data;

  return (
    <Section title="Sterowanie">
      <LabeledList>
        <LabeledList.Item label="Moc">
          <Button
            icon={on ? 'power-off' : 'times'}
            selected={on}
            onClick={() => act('power')}
          >
            {on ? 'Włączony' : 'Wyłączony'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Receptura">
          <Button
            selected={selected === ''}
            onClick={() => act('recipe', { mode: '' })}
          >
            Brak
          </Button>
          {recipes.map(({ id, name }) => (
            <Button
              key={id}
              selected={id === selected}
              onClick={() => act('recipe', { mode: id })}
            >
              {name}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Wlot gazu">
          <NumberInput
            animated
            step={0.1}
            value={gas_input}
            width="63px"
            unit="mol/s"
            minValue={0}
            maxValue={max_gas_input}
            onChange={(value) => act('gas_input', { gas_input: value })}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const RecipeText = (props: { recipe?: Recipe }) => {
  const { recipe } = props;
  if (!recipe) {
    return <Box>Wybierz recepturę, żeby zobaczyć wymagania.</Box>;
  }
  const maxTemp = recipe.max_temp === null ? '∞' : recipe.max_temp;
  return (
    <Box>
      <Box>Na jedną sztukę potrzeba:</Box>
      {recipe.requirements.map((requirement) => (
        <Box key={requirement.id} color={getGasColor(requirement.id)}>
          {`- ${requirement.amount} mol: ${requirement.name}`}
        </Box>
      ))}
      <Box mt={1}>
        {`Temperatura wnętrza od ${recipe.min_temp} K do ${maxTemp} K`}
      </Box>
      <Box>
        {recipe.energy_release > 0
          ? 'Reakcja grzeje wnętrze (egzotermiczna).'
          : recipe.energy_release < 0
            ? 'Reakcja chłodzi wnętrze (endotermiczna).'
            : 'Reakcja nie zmienia temperatury.'}
      </Box>
    </Box>
  );
};

const Requirements = (props) => {
  const { data } = useBackend<Data>();
  const { recipes = [], selected, internal_temperature, progress_bar } = data;
  const recipe = recipes.find((entry) => entry.id === selected);

  return (
    <Section title="Wymagania i postęp">
      <LabeledList>
        <LabeledList.Item label="Postęp">
          <ProgressBar
            value={progress_bar / 100}
            ranges={{
              good: [0.67, 1],
              average: [0.34, 0.66],
              bad: [0, 0.33],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Receptura">
          <RecipeText recipe={recipe} />
        </LabeledList.Item>
        <LabeledList.Item label="Temperatura">
          <ProgressBar
            value={logScale(internal_temperature)}
            minValue={0}
            maxValue={logScale(10000)}
            ranges={{
              teal: [-Infinity, logScale(80)],
              good: [logScale(80), logScale(600)],
              average: [logScale(600), logScale(5000)],
              bad: [logScale(5000), Infinity],
            }}
          >
            {`${toFixed(internal_temperature)} K`}
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Gases = (props) => {
  const { data } = useBackend<Data>();
  const { internal_gas_data = [] } = data;

  return (
    <Section title="Gazy we wnętrzu">
      <LabeledList>
        {internal_gas_data.map(({ id, name, amount }) => (
          <LabeledList.Item key={id} label={name}>
            <ProgressBar
              color={getGasColor(id)}
              value={amount}
              minValue={0}
              maxValue={1000}
            >
              {`${toFixed(amount, 2)} mol`}
            </ProgressBar>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
