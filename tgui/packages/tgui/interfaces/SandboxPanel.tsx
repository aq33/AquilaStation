import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ButtonGroup = {
  title: string;
  buttons: { name: string; index: number }[];
};

type Data = {
  admin: boolean;
  groups: ButtonGroup[];
  browse_category: string | null;
  items: string[];
  spawning_enabled: boolean;
  autoclose: boolean;
};

const CATEGORIES: [string, string][] = [
  ['clothing', 'Ubrania'],
  ['reagents', 'Pojemniki z odczynnikami'],
  ['other', 'Inne przedmioty'],
];

const ItemBrowser = (props) => {
  const { act, data } = useBackend<Data>();
  const { items = [], browse_category } = data;
  const [search, setSearch] = useState('');
  const filter = search.toLowerCase();
  const shown = filter
    ? items.filter((item) => item.toLowerCase().includes(filter))
    : items;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs>
          {CATEGORIES.map(([id, name]) => (
            <Tabs.Tab
              key={id}
              selected={browse_category === id}
              onClick={() => act('browse', { category: id })}
            >
              {name}
            </Tabs.Tab>
          ))}
          <Tabs.Tab icon="times" onClick={() => act('browse')}>
            Zamknij
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        <Input
          fluid
          placeholder="Szukaj ścieżki..."
          value={search}
          onChange={(value) => setSearch(value)}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {shown.slice(0, 500).map((item) => (
            <Button
              key={item}
              fluid
              color="transparent"
              onClick={() => act('spawn_item', { path: item })}
            >
              {item}
            </Button>
          ))}
          {shown.length > 500 && (
            <Box color="label" italic>
              Pokazano 500 z {shown.length}, zawęź wyszukiwanie.
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const SandboxPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { groups = [] } = data;

  return (
    <Window title="Panel piaskownicy" width={460} height={640}>
      <Window.Content>
        {data.browse_category ? (
          <ItemBrowser />
        ) : (
          <Section fill scrollable>
            {data.admin ? (
              <Section title="Administracja">
                <Button.Checkbox
                  checked={data.spawning_enabled}
                  onClick={() => act('toggle_spawning')}
                >
                  Spawnowanie obiektów
                </Button.Checkbox>
                <Button.Checkbox
                  checked={data.autoclose}
                  onClick={() => act('toggle_autoclose')}
                >
                  Zamykaj listę po stworzeniu
                </Button.Checkbox>
              </Section>
            ) : (
              <NoticeBox info>
                Administratorzy mogą wyłączyć część spawnowania. Tylko
                administratorzy mogą tworzyć niebezpieczne kanistry.
              </NoticeBox>
            )}
            {groups.map((group) => (
              <Section key={group.title} title={group.title}>
                {group.buttons.map((button) => (
                  <Button
                    key={button.index}
                    onClick={() =>
                      act('button', {
                        group: group.title,
                        index: button.index,
                      })
                    }
                  >
                    {button.name}
                  </Button>
                ))}
              </Section>
            ))}
            <Section title="Więcej przedmiotów">
              {CATEGORIES.map(([id, name]) => (
                <Button
                  key={id}
                  icon="list"
                  disabled={!data.spawning_enabled}
                  onClick={() => act('browse', { category: id })}
                >
                  {name}...
                </Button>
              ))}
            </Section>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
