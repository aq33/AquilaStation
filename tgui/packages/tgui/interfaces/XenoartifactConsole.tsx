import {
  BlockQuote,
  Button,
  Divider,
  Flex,
  Icon,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { formatMoney } from '../format';
import { Window } from '../layouts';

type Stock = {
  name: string;
  description: string;
  id: string;
  cost: number;
};

type Seller = {
  name: string;
  dialogue: string;
  stock: Stock[];
  id: string;
};

type Request = {
  object: string;
  cost: number;
  supply: number;
  orderer: string;
  reason: string;
  id: number;
};

type Data = {
  sellers: Seller[];
  money: number;
  purchase_radio: boolean;
  solved_radio: boolean;
  history: string[];
  active_request: Request[];
};

export const XenoartifactConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useSharedState('tab', 'listings');
  const { money, purchase_radio, solved_radio } = data;
  return (
    <Window width={888} height={500}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <b>{`Budżet działu badań: ${money} kr`}</b>
            </Flex.Item>
            <Flex.Item ml="auto">
              <Button
                icon="microphone"
                color={purchase_radio ? 'green' : 'red'}
                tooltip="Komunikaty radiowe o zakupach"
                onClick={() => act('toggle_purchase_audio')}
              />
              <Button
                icon="microphone"
                color={solved_radio ? 'green' : 'red'}
                tooltip="Komunikaty radiowe o rozwiązanych artefaktach"
                onClick={() => act('toggle_solved_audio')}
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Divider />
        <Tabs>
          <Tabs.Tab
            onClick={() => setTab('listings')}
            selected={tab === 'listings'}
          >
            <Icon name="shopping-cart" /> Oferty
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setTab('requests')}
            selected={tab === 'requests'}
          >
            <Icon name="list" /> Zamówienia
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setTab('history')}
            selected={tab === 'history'}
          >
            <Icon name="search" /> Historia
          </Tabs.Tab>
        </Tabs>
        <Divider />
        {tab === 'listings' && <XenoartifactConsoleSellerTab />}
        {tab === 'requests' && <XenoartifactConsoleRequestsTab />}
        {tab === 'history' && <XenoartifactConsoleHistoryTab />}
      </Window.Content>
    </Window>
  );
};

const XenoartifactConsoleSellerTab = (props) => {
  const { data } = useBackend<Data>();
  const sellers = data.sellers || [];
  return (
    <Flex wrap="wrap">
      {sellers.map((seller) => (
        <XenoartifactConsoleSellerEntry seller={seller} key={seller.id} />
      ))}
    </Flex>
  );
};

const XenoartifactConsoleSellerEntry = (props: { seller: Seller }) => {
  const { act } = useBackend<Data>();
  const { seller } = props;
  const stock = seller.stock || [];
  return (
    <Flex.Item ml={1} my={0.5}>
      <Section title={seller.name} px={2} py={1}>
        <BlockQuote>{seller.dialogue}</BlockQuote>
        <Divider />
        {stock.map((listing) => (
          <Section
            title={listing.name}
            mx={5}
            key={listing.id}
            buttons={
              <Button
                icon="shopping-cart"
                onClick={() =>
                  act('stock_purchase', {
                    item_id: listing.id,
                    seller_id: seller.id,
                  })
                }
              >
                {`${listing.cost} kr`}
              </Button>
            }
          >
            <BlockQuote>{listing.description}</BlockQuote>
            <Divider />
          </Section>
        ))}
      </Section>
    </Flex.Item>
  );
};

const XenoartifactConsoleRequestsTab = (props) => {
  const { data } = useBackend<Data>();
  const requests = data.active_request || [];
  return (
    <Table>
      {requests.map((request) => (
        <Table.Row key={request.id} className="candystripe">
          <Table.Cell collapsing color="label">
            #{request.id}
          </Table.Cell>
          <Table.Cell>{request.object}</Table.Cell>
          <Table.Cell>
            <b>{request.orderer}</b>
          </Table.Cell>
          <Table.Cell width="25%">
            <i>{request.reason}</i>
          </Table.Cell>
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            {formatMoney(request.cost)} kr
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const XenoartifactConsoleHistoryTab = (props) => {
  const { data } = useBackend<Data>();
  const history = data.history || [];
  return (
    <Flex wrap="wrap">
      {history.map((entry, index) => (
        <BlockQuote key={index} fontSize={1.2}>
          {entry}
        </BlockQuote>
      ))}
    </Flex>
  );
};
