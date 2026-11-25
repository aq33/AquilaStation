// AQUILA - program PDA „Katalog NIFSoftów”, przepisany z NtosNifsoftCatalog.jsx z Monkestation (pierwotnie Skyrat/Nova)
// Bez punktów nagród.
import { useState } from 'react';
import {
  BlockQuote,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Product = {
  name: string;
  desc: string;
  price: number;
  ui_icon: string;
  reference: string;
};

type ProductCategory = {
  name: string;
  products: Product[];
};

type Data = {
  product_list: ProductCategory[];
  paying_account: BooleanLike;
  current_balance: number;
  has_nif: BooleanLike;
};

export const NtosNifsoftCatalog = (props) => {
  const { data } = useBackend<Data>();
  const { product_list = [], current_balance, paying_account, has_nif } = data;
  const [tab, setTab] = useState(product_list[0]?.name);

  const products =
    product_list.find((category) => category.name === tab)?.products || [];

  return (
    <NtosWindow width={500} height={700}>
      <NtosWindow.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Środki na koncie">
              {paying_account ? `${current_balance} kr.` : 'Brak karty ID'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!has_nif && (
          <NoticeBox>
            Nie masz NIF-u. Kupione NIFSofty instalują się od razu w NIF-ie
            kupującego.
          </NoticeBox>
        )}
        <Tabs fluid>
          {product_list.map((category) => (
            <Tabs.Tab
              key={category.name}
              textAlign="center"
              onClick={() => setTab(category.name)}
              selected={tab === category.name}
            >
              <b>{category.name}</b>
            </Tabs.Tab>
          ))}
        </Tabs>
        <Stack vertical>
          {products.map((product) => (
            <Stack.Item key={product.reference}>
              <ProductEntry product={product} />
            </Stack.Item>
          ))}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const ProductEntry = (props: { product: Product }) => {
  const { act, data } = useBackend<Data>();
  const { paying_account, current_balance, has_nif } = data;
  const { product } = props;

  return (
    <Section
      title={
        <span>
          <Icon name={product.ui_icon} /> {product.name}
        </span>
      }
    >
      <Collapsible title="Opis programu">
        <BlockQuote>{product.desc}</BlockQuote>
      </Collapsible>
      <Button
        icon="shopping-bag"
        color="green"
        fluid
        disabled={
          !has_nif || !paying_account || current_balance < product.price
        }
        onClick={() =>
          act('purchase_product', { product_to_buy: product.reference })
        }
      >
        {product.price ? `Kup za ${product.price} kr.` : 'Zainstaluj za darmo'}
      </Button>
    </Section>
  );
};
