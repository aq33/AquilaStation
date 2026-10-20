import { useState } from 'react';
import {
  Button,
  Collapsible,
  Flex,
  Input,
  Section,
  Table,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  Categories: any;
};

const pick = (array) => array[Math.floor(Math.random() * array.length)];
const possTitles = [
  'Pierwsza zasada adminbuse: nie rozmawiamy o adminbuse.',
  'Oj, będzie zabawa.',
  'ADMINIE, ON TO ROBI BOKIEM!',
  'Jaki smak admemów dzisiaj serwujemy?',
  'Masowe Purrbation. Wiesz, że chcesz.',
  'Co robi ten przycisk?',
  'NIEEE NIE MOŻESZ TAK NADUŻYWAĆ WŁADZY',
  'haha maszyna admina robi bwoink',
  'RDM RDM RDM RDM',
  'admin grief ban on',
  'NIEEE ADMIN NISZCZY MI IMERSJĘ NIEEEEEEEEEEEE',
];
const Title = pick(possTitles);

export const AdminSecretsPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { Categories = [] } = data;
  const [searchText, setSearchText] = useState('');

  const Search = createSearch(searchText, (item: string) => {
    return item;
  });

  const filterSearch = (command) => {
    return Search(command[0]);
  };

  const Header = (
    <Section
      title={
        <Table>
          <Table.Row>
            <Table.Cell>{Title}</Table.Cell>
            <Table.Cell textAlign="right">
              <Input
                placeholder="Szukaj"
                value={searchText}
                onChange={(value) => setSearchText(value)}
                mx={1}
              />
            </Table.Cell>
          </Table.Row>
        </Table>
      }
    />
  );

  const makeButton = (command) => {
    return (
      <Flex.Item grow={1} basis="49%" key={command[1]}>
        <Button fluid ellipsis my={0.5} onClick={() => act(command[1])}>
          {command[0]}
        </Button>
      </Flex.Item>
    );
  };

  const makeCategory = (Category) => {
    const Commands = Category[1].filter(filterSearch).map(makeButton);
    if (Commands.length) {
      return (
        <Collapsible
          title={`${Category[0]} (${Commands.length})`}
          bold
          key={Category[0]}
        >
          <Section>
            <Flex spacing={1} wrap="wrap" textAlign="center" justify="center">
              {Commands}
            </Flex>
          </Section>
        </Collapsible>
      );
    }
  };

  const Items = Object.entries(Categories).map(makeCategory);

  return (
    <Window title="Sekrety" theme="admin" width={720} height={480}>
      <Window.Content scrollable>
        {Header}
        <Section>
          {Items}
          {Items && Items.length === 0 && 'Brak wyników.'}
        </Section>
      </Window.Content>
    </Window>
  );
};
