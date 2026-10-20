import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Układ jak w tg. Nasz DM nie ma zapasu papieru, kolejki ani rodzajów papieru,
// a formularze drukuje z nazwy i treści (config/blanks.json), nie z kodu.
type Data = {
  has_item: BooleanLike;
  has_toner: BooleanLike;
  has_enough_toner: BooleanLike;
  can_AI_print: BooleanLike;
  isAI: BooleanLike;
  is_photo: BooleanLike;
  forms_exist: BooleanLike;
  color_mode: string;
  num_copies: number;
  max_copies: number;
  max_toner: number;
  current_toner: number;
  blanks?: Blank[];
};

type Blank = {
  name: string;
  category: string;
  code: string;
  info: string[];
};

const ALL_BLANKS = 'Wszystkie formularze';

export const Photocopier = (props) => {
  const [selectedBlank, setSelectedBlank] = useState<Blank | null>(null);
  const [selectedCategory, setSelectedCategory] = useState('');

  return (
    <Window
      title="Kserokopiarka"
      width={selectedCategory ? 550 : 325}
      height={525}
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item basis={selectedCategory ? '40%' : '100%'}>
            <Stack fill vertical>
              <Stack.Item>
                <Status selectedBlank={selectedBlank} />
              </Stack.Item>
              <Stack.Item>
                <Actions selectedBlank={selectedBlank} />
              </Stack.Item>
              <Stack.Item grow>
                <Categories
                  selectedCategory={selectedCategory}
                  setSelectedCategory={setSelectedCategory}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {!!selectedCategory && (
            <Stack.Item basis="60%">
              <Blanks
                selectedCategory={selectedCategory}
                selectedBlank={selectedBlank}
                setSelectedBlank={setSelectedBlank}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SelectedBlankProps = {
  selectedBlank: Blank | null;
};

const Status = (props: SelectedBlankProps) => {
  const { act, data } = useBackend<Data>();
  const { selectedBlank } = props;
  const { has_toner, current_toner, max_toner } = data;

  const average_toner = max_toner * 0.66;
  const bad_toner = max_toner * 0.33;

  return (
    <Section
      fill
      title="Stan"
      buttons={
        <Button
          icon="eject"
          disabled={!has_toner}
          onClick={() => act('remove_toner')}
        >
          Wyjmij toner
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Toner">
          {has_toner ? (
            <ProgressBar
              minValue={0}
              value={current_toner}
              maxValue={max_toner}
              ranges={{
                good: [average_toner, Infinity],
                average: [bad_toner, average_toner],
                bad: [-Infinity, bad_toner],
              }}
            />
          ) : (
            <ProgressBar color="bad" minValue={0} value={0} maxValue={1}>
              Brak kartridża
            </ProgressBar>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Formularz">
          <b>{selectedBlank ? selectedBlank.name : 'Nie wybrano'}</b>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Actions = (props: SelectedBlankProps) => {
  const { act, data } = useBackend<Data>();
  const { selectedBlank } = props;
  const {
    has_item,
    has_toner,
    has_enough_toner,
    is_photo,
    num_copies,
    max_copies = 10,
    color_mode,
    isAI,
    can_AI_print,
  } = data;

  return (
    <Section fill title="Działania">
      <Stack fill vertical textAlign="center">
        <Stack.Item>
          <Stack align="center" textAlign="left">
            <Stack.Item grow color="label">
              Liczba kopii:
            </Stack.Item>
            <Stack.Item grow>
              <Slider
                animated
                step={1}
                minValue={1}
                value={num_copies}
                maxValue={max_copies}
                stepPixelSize={10}
                onChange={(e, value) =>
                  act('set_copies', {
                    num_copies: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!!isAI && (
          <Stack.Item>
            <Button
              fluid
              icon="images"
              disabled={!can_AI_print}
              onClick={() => act('ai_photo')}
            >
              Wydrukuj zdjęcie z bazy danych
            </Button>
          </Stack.Item>
        )}
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="print"
                disabled={!selectedBlank || !has_toner}
                onClick={() =>
                  selectedBlank &&
                  act('print_blank', {
                    name: selectedBlank.name,
                    info: selectedBlank.info,
                  })
                }
              >
                Drukuj
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="copy"
                disabled={!has_item || !has_enough_toner}
                tooltip={
                  has_item && !has_enough_toner
                    ? 'Za mało tonera na tyle kopii'
                    : undefined
                }
                onClick={() => act('make_copy')}
              >
                Kopiuj
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!!has_item && !!is_photo && (
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="palette"
                  selected={color_mode === 'Color'}
                  onClick={() =>
                    act('color_mode', {
                      mode: 'Color',
                    })
                  }
                >
                  Kolor
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="pen"
                  selected={color_mode === 'Greyscale'}
                  onClick={() =>
                    act('color_mode', {
                      mode: 'Greyscale',
                    })
                  }
                >
                  Skala szarości
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            fluid
            icon={has_item ? 'eject' : 'times'}
            disabled={!has_item}
            onClick={() => act('remove')}
          >
            Wyjmij przedmiot
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type CategoriesProps = {
  selectedCategory: string | null;
  setSelectedCategory: (category: string) => void;
};

const Categories = (props: CategoriesProps) => {
  const { data } = useBackend<Data>();
  const { forms_exist, blanks = [] } = data;
  const { selectedCategory, setSelectedCategory } = props;

  const categories: string[] = [];
  for (const blank of blanks) {
    if (!categories.includes(blank.category)) {
      categories.push(blank.category);
    }
  }
  categories.sort();

  return (
    <Section
      fill
      scrollable
      title="Formularze"
      buttons={
        <Button
          icon="times"
          tooltip="Zamknij wybraną kategorię"
          disabled={!selectedCategory}
          onClick={() => {
            setSelectedCategory('');
          }}
        />
      }
    >
      {!forms_exist ? (
        <Box color="average">
          Nie znaleziono formularzy. Skontaktuj się z administratorem systemu.
        </Box>
      ) : (
        <Stack fill vertical zebra g={0.2}>
          <Stack.Item>
            <Button
              fluid
              icon="chevron-right"
              color="transparent"
              selected={selectedCategory === ALL_BLANKS}
              onClick={() => {
                setSelectedCategory(ALL_BLANKS);
              }}
            >
              {ALL_BLANKS}
            </Button>
          </Stack.Item>
          {categories.map((category) => (
            <Stack.Item key={category}>
              <Button
                fluid
                icon="chevron-right"
                color="transparent"
                selected={selectedCategory === category}
                onClick={() => {
                  setSelectedCategory(category);
                }}
              >
                {category}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

type BlanksProps = {
  selectedCategory: string;
  selectedBlank: Blank | null;
  setSelectedBlank: (blank: Blank) => void;
};

const Blanks = (props: BlanksProps) => {
  const { data } = useBackend<Data>();
  const { selectedCategory, selectedBlank, setSelectedBlank } = props;
  const { blanks = [] } = data;

  const [searchText, setSearchText] = useState('');
  const search = createSearch(searchText, (blank: Blank) => blank.name);
  const sortedBlanks = [...blanks].sort((a, b) => (a.name > b.name ? 1 : -1));
  const visibleBlanks = searchText
    ? sortedBlanks.filter(search)
    : selectedCategory === ALL_BLANKS
      ? sortedBlanks
      : sortedBlanks.filter((blank) => blank.category === selectedCategory);

  return (
    <Section
      fill
      scrollable
      title={selectedCategory}
      buttons={
        <Input
          width={8.75}
          value={searchText}
          placeholder="Szukaj formularza..."
          onChange={setSearchText}
        />
      }
    >
      <Stack fill vertical zebra g={0.5}>
        {visibleBlanks.map((blank) => (
          <Stack.Item key={blank.code}>
            <Button
              fluid
              ellipsis
              color="transparent"
              tooltip={blank.code}
              selected={blank.code === selectedBlank?.code}
              onClick={() => setSelectedBlank(blank)}
            >
              {blank.name}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
