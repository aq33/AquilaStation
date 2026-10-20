import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  name: string;
  currentSection: number;
};

// Napisy na przyciskach to zarazem akcje porównywane w DM z listami
// diabelskich imion — nie tłumaczyć.
const PREFIXES = [
  'Dark',
  'Hellish',
  'Fallen',
  'Fiery',
  'Sinful',
  'Blood',
  'Fluffy',
] as const;

const TITLES = [
  'Lord',
  'Prelate',
  'Count',
  'Viscount',
  'Vizier',
  'Elder',
  'Adept',
] as const;

const NAMES = [
  'hal',
  've',
  'odr',
  'neit',
  'ci',
  'quon',
  'mya',
  'folth',
  'wren',
  'geyr',
  'hil',
  'niet',
  'twou',
  'phi',
  'coa',
] as const;

const SUFFIXES = [
  'the Red',
  'the Soulless',
  'the Master',
  'the Lord of all things',
  'Jr.',
] as const;

export const CodexGigas = (props) => {
  const { act, data } = useBackend<Data>();
  const { name, currentSection } = data;

  return (
    <Window width={450} height={450}>
      <Window.Content>
        <Section>
          {name}
          <LabeledList>
            <Prefixes />
            <Titles />
            <Names />
            <Suffixes />
            <LabeledList.Item label="Zatwierdź">
              <Button
                disabled={currentSection < 4}
                onClick={() => act('search')}
              >
                Szukaj
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

const Prefixes = (props) => {
  const { act, data } = useBackend<Data>();
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Przedrostek">
      {PREFIXES.map((prefix) => (
        <Button
          key={prefix.toLowerCase()}
          disabled={currentSection !== 1}
          onClick={() => act(`${prefix} `)}
        >
          {prefix}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

// Nasz DM: tytuły w GLOB.devil_title kończą się spacją, a sekcje to
// PRE_TITLE=1, TITLE=2, SYLLABLE=3, MULTIPLE_SYLLABLE=4, SUFFIX=5.
const Titles = (props) => {
  const { act, data } = useBackend<Data>();
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Tytuł">
      {TITLES.map((title) => (
        <Button
          key={title.toLowerCase()}
          disabled={currentSection > 2}
          onClick={() => act(`${title} `)}
        >
          {title}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

const Names = (props) => {
  const { act, data } = useBackend<Data>();
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Imię">
      {NAMES.map((name) => (
        <Button
          key={name.toLowerCase()}
          disabled={currentSection > 4}
          onClick={() => act(name)}
        >
          {name}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

const Suffixes = (props) => {
  const { act, data } = useBackend<Data>();
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Przydomek">
      {SUFFIXES.map((suffix) => (
        <Button
          key={suffix.toLowerCase()}
          disabled={currentSection !== 4}
          onClick={() => act(` ${suffix}`)}
        >
          {suffix}
        </Button>
      ))}
    </LabeledList.Item>
  );
};
