// AQUILA - konsola magazynu kriogenicznego (code/game/machinery/cryopod.dm).
// tg nie ma odpowiednika; zastępuje dawne okno HTML: log przechowywania,
// lista przedmiotów, odzyskiwanie jednego lub wszystkich przedmiotów.
import { useState } from 'react';
import {
  Button,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FrozenItem = {
  name: string;
  ref: string;
};

type Data = {
  storage_name: string;
  storage_type: string;
  user_name: string;
  allow_items: BooleanLike;
  frozen_crew: string[];
  frozen_items: FrozenItem[];
};

export const CryopodConsole = (props) => {
  const { data } = useBackend<Data>();
  const { storage_name, user_name, allow_items } = data;
  const [tab, setTab] = useState(0);
  const showItems = !!allow_items && tab === 1;

  return (
    <Window width={400} height={480} title={storage_name}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox info>Witaj, {user_name}.</NoticeBox>
          </Stack.Item>
          {!!allow_items && (
            <Stack.Item>
              <Tabs fluid>
                <Tabs.Tab
                  icon="list"
                  selected={tab === 0}
                  onClick={() => setTab(0)}
                >
                  Log przechowywania
                </Tabs.Tab>
                <Tabs.Tab
                  icon="box"
                  selected={tab === 1}
                  onClick={() => setTab(1)}
                >
                  Przedmioty
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
          )}
          <Stack.Item grow>{showItems ? <ItemList /> : <CrewLog />}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewLog = (props) => {
  const { data } = useBackend<Data>();
  const { storage_type, frozen_crew = [] } = data;
  return (
    <Section fill scrollable title={`Ostatnio przechowane: ${storage_type}`}>
      {frozen_crew.length === 0 ? (
        <NoticeBox>Log jest pusty.</NoticeBox>
      ) : (
        <Table>
          {frozen_crew.map((person, index) => (
            <Table.Row key={index} className="candystripe">
              <Table.Cell p={0.5}>{person}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const ItemList = (props) => {
  const { act, data } = useBackend<Data>();
  const { frozen_items = [] } = data;
  return (
    <Section
      fill
      scrollable
      title="Ostatnio przechowane przedmioty"
      buttons={
        <Button
          icon="eject"
          disabled={frozen_items.length === 0}
          onClick={() => act('allitems')}
        >
          Odzyskaj wszystkie
        </Button>
      }
    >
      {frozen_items.length === 0 ? (
        <NoticeBox>W magazynie nie ma nic do odzyskania.</NoticeBox>
      ) : (
        <Table>
          {frozen_items.map((item) => (
            <Table.Row key={item.ref} className="candystripe">
              <Table.Cell p={0.5}>{item.name}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  icon="eject"
                  onClick={() => act('item', { ref: item.ref })}
                >
                  Odzyskaj
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
