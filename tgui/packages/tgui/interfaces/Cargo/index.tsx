import { Button, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { CargoCartButtons } from './CargoButtons';
import { CargoCart } from './CargoCart';
import { CargoCatalog } from './CargoCatalog';
import { CargoHelp } from './CargoHelp';
import { CargoRequests } from './CargoRequests';
import { CargoStatus } from './CargoStatus';
import { entryAmount } from './helpers';
import type { CargoData } from './types';

enum TAB {
  Catalog = 'catalog',
  Requests = 'active requests',
  Cart = 'cart',
  Help = 'help',
}

const TAB_TITLES: Record<TAB, string> = {
  [TAB.Catalog]: 'Katalog',
  [TAB.Requests]: 'Aktywne prośby',
  [TAB.Cart]: 'Koszyk',
  [TAB.Help]: 'Pomoc',
};

export function Cargo(props) {
  return (
    <Window width={800} height={750}>
      <Window.Content>
        <CargoContent />
      </Window.Content>
    </Window>
  );
}

export function CargoContent(props) {
  const { act, data } = useBackend<CargoData>();
  const { cart = [], requests = [], requestonly } = data;
  const [tab, setTab] = useSharedState('cargotab', TAB.Catalog);

  let amount = 0;
  for (let i = 0; i < cart.length; i++) {
    amount += entryAmount(cart[i]);
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <CargoStatus />
      </Stack.Item>
      <Stack.Item>
        <Section
          title={TAB_TITLES[tab] || ''}
          buttons={
            <>
              {tab === TAB.Requests && !requestonly && (
                <Button
                  icon="times"
                  color="transparent"
                  onClick={() => act('denyall')}
                >
                  Wyczyść
                </Button>
              )}
              {(tab === TAB.Catalog || tab === TAB.Cart) && (
                <CargoCartButtons />
              )}
            </>
          }
        >
          <Tabs fluid m={-1}>
            <Tabs.Tab
              icon="list"
              selected={tab === TAB.Catalog}
              onClick={() => setTab(TAB.Catalog)}
            >
              Katalog
            </Tabs.Tab>
            <Tabs.Tab
              icon="envelope"
              textColor={
                tab !== TAB.Requests && requests.length > 0
                  ? 'yellow'
                  : undefined
              }
              selected={tab === TAB.Requests}
              onClick={() => setTab(TAB.Requests)}
            >
              Prośby ({requests.length})
            </Tabs.Tab>
            {!requestonly && (
              <>
                <Tabs.Tab
                  icon="shopping-cart"
                  textColor={
                    tab !== TAB.Cart && amount > 0 ? 'yellow' : undefined
                  }
                  selected={tab === TAB.Cart}
                  onClick={() => setTab(TAB.Cart)}
                >
                  Koszyk ({amount})
                </Tabs.Tab>
                <Tabs.Tab
                  icon="question"
                  selected={tab === TAB.Help}
                  onClick={() => setTab(TAB.Help)}
                >
                  Pomoc
                </Tabs.Tab>
              </>
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow mt={-1}>
        {tab === TAB.Catalog && <CargoCatalog />}
        {tab === TAB.Requests && <CargoRequests />}
        {tab === TAB.Cart && <CargoCart />}
        {tab === TAB.Help && <CargoHelp />}
      </Stack.Item>
    </Stack>
  );
}
