// AQUILA - rynek ekstraktów szlamu (port SLIMECORE z Monkestation 2.0)
import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Price = {
  name: string;
  icon: string;
  icon_state: string;
  price: number;
  ratio: number;
};

type Request = {
  name: string;
  ref: string;
  icon: string;
  icon_state: string;
  amount: number;
  amount_given: number;
  payout: number;
  points: number;
  ready: boolean;
};

type ShopItem = {
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
  cost: number;
  ref: string;
};

type Data = {
  points: number;
  prices: Price[];
  requests: Request[];
  has_request_pad: boolean;
  shop_items: ShopItem[];
};

export const XenobioMarket = () => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState(1);

  return (
    <Window width={620} height={560}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="chart-line"
                selected={tab === 1}
                onClick={() => setTab(1)}
              >
                Ceny
              </Tabs.Tab>
              <Tabs.Tab
                icon="clipboard-list"
                selected={tab === 2}
                onClick={() => setTab(2)}
              >
                Zamówienia ({data.requests.length})
              </Tabs.Tab>
              <Tabs.Tab
                icon="store"
                selected={tab === 3}
                onClick={() => setTab(3)}
              >
                Sklep
              </Tabs.Tab>
              <Box inline ml={2} mt={1} bold color="good">
                {Math.round(data.points)} xenobio points
              </Box>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              {tab === 1 && <Prices />}
              {tab === 2 && <Requests />}
              {tab === 3 && <Shop />}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Prices = () => {
  const { data } = useBackend<Data>();

  return (
    <Table>
      {data.prices.map((price) => (
        <Table.Row key={price.name} className="candystripe">
          <Table.Cell collapsing>
            <DmIcon
              icon={price.icon}
              icon_state={price.icon_state}
              width="32px"
              height="32px"
            />
          </Table.Cell>
          <Table.Cell verticalAlign="middle">{price.name}</Table.Cell>
          <Table.Cell collapsing verticalAlign="middle" textAlign="right">
            <Box bold>{price.price} pkt</Box>
          </Table.Cell>
          <Table.Cell width="35%" verticalAlign="middle" pl={1}>
            <ProgressBar
              value={price.ratio}
              minValue={0.1}
              maxValue={2}
              ranges={{
                good: [1.2, 2],
                average: [0.6, 1.2],
                bad: [0, 0.6],
              }}
            >
              {Math.round(price.ratio * 100)}% ceny bazowej
            </ProgressBar>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const Requests = () => {
  const { data } = useBackend<Data>();

  if (!data.has_request_pad) {
    return (
      <NoticeBox>
        Brak połączonego padu zamówień. Połącz go multitoolem przy otwartym
        panelu.
      </NoticeBox>
    );
  }
  if (!data.requests.length) {
    return <NoticeBox info>Nikt nie zamówił ekstraktów.</NoticeBox>;
  }
  return (
    <>
      <NoticeBox info>
        Zamówienie realizujesz, wkładając pasujący ekstrakt do padu rynku.
      </NoticeBox>
      <Table>
        {data.requests.map((request) => (
          <Table.Row key={request.ref} className="candystripe">
            <Table.Cell collapsing>
              <DmIcon
                icon={request.icon}
                icon_state={request.icon_state}
                width="32px"
                height="32px"
              />
            </Table.Cell>
            <Table.Cell verticalAlign="middle">{request.name}</Table.Cell>
            <Table.Cell collapsing verticalAlign="middle" pr={1}>
              {request.payout} kr + {request.points} pkt
            </Table.Cell>
            <Table.Cell width="30%" verticalAlign="middle">
              <ProgressBar
                value={request.amount_given}
                maxValue={request.amount}
                color={request.ready ? 'good' : 'average'}
              >
                {request.ready
                  ? 'Czeka na odbiór'
                  : `${request.amount_given} / ${request.amount}`}
              </ProgressBar>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </>
  );
};

const Shop = () => {
  const { data, act } = useBackend<Data>();

  return (
    <Table>
      {data.shop_items.map((item) => (
        <Table.Row key={item.ref} className="candystripe">
          <Table.Cell collapsing>
            <DmIcon
              icon={item.icon}
              icon_state={item.icon_state}
              width="32px"
              height="32px"
            />
          </Table.Cell>
          <Table.Cell verticalAlign="middle">
            <Box bold>{item.name}</Box>
            <Box color="label">{item.desc}</Box>
          </Table.Cell>
          <Table.Cell collapsing verticalAlign="middle">
            <Button
              icon="cart-shopping"
              disabled={data.points < item.cost}
              onClick={() => act('buy', { ref: item.ref })}
            >
              {item.cost} pkt
            </Button>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
