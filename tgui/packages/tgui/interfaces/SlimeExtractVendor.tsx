// AQUILA - automat ekstraktów szlamu: xenobiolodzy wystawiają ekstrakty, załoga kupuje je kartą
// i widzi przy każdym, co robi (reakcje z programu PDA „Ekstrakty”)
import {
  Box,
  Button,
  DmIcon,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { RecipeReagent } from './common/RecipeLookup';

type ExtractReaction = {
  id: string;
  name: string;
  desc: string | null;
  reagents: RecipeReagent[];
  results: RecipeReagent[];
};

type StockEntry = {
  id: string;
  name: string;
  icon: string;
  icon_state: string;
  amount: number;
  price: number;
};

type Data = {
  stock: StockEntry[];
  reactions: Record<string, ExtractReaction[]>;
  can_manage: BooleanLike;
  balance: number | null;
};

const listReagents = (reagents: RecipeReagent[]) =>
  reagents.map((r) => `${r.amount}× ${r.name}`).join(' + ');

export const SlimeExtractVendor = (props) => {
  const { data } = useBackend<Data>();
  const { can_manage, balance } = data;
  const stock = [...(data.stock || [])].sort((a, b) =>
    a.name.localeCompare(b.name),
  );

  return (
    <Window width={620} height={680}>
      <Window.Content scrollable>
        <Section>
          <Stack align="center">
            <Stack.Item grow>
              {balance === null ? (
                <Box color="bad">Nie wykryto karty z kontem.</Box>
              ) : (
                <Box>
                  Stan konta: <b>{balance} kr</b>
                </Box>
              )}
            </Stack.Item>
            {!!can_manage && (
              <Stack.Item color="label">
                Wystawiasz ekstrakty, wkładając je albo torbę bio do automatu.
              </Stack.Item>
            )}
          </Stack>
        </Section>
        {stock.length === 0 && (
          <NoticeBox>
            Automat jest pusty. Xenobiolodzy jeszcze nic nie wystawili.
          </NoticeBox>
        )}
        {stock.map((entry) => (
          <ExtractOffer key={entry.id} entry={entry} />
        ))}
      </Window.Content>
    </Window>
  );
};

const ExtractOffer = (props: { entry: StockEntry }) => {
  const { act, data } = useBackend<Data>();
  const { entry } = props;
  const reactions = data.reactions?.[entry.id] ?? [];
  const tooPoor = data.balance !== null && data.balance < entry.price;

  return (
    <Section
      title={
        <Stack align="center">
          <Stack.Item>
            <DmIcon
              icon={entry.icon}
              icon_state={entry.icon_state}
              width="48px"
              height="48px"
            />
          </Stack.Item>
          <Stack.Item>
            <Box fontSize={1.2}>{entry.name}</Box>
            <Box color="label">W automacie: {entry.amount}</Box>
          </Stack.Item>
        </Stack>
      }
      buttons={
        <Stack align="center">
          {!!data.can_manage && (
            <>
              <Stack.Item>
                <NumberInput
                  value={entry.price}
                  minValue={1}
                  maxValue={5000}
                  step={5}
                  width="5em"
                  unit="kr"
                  onChange={(value) =>
                    act('set_price', { id: entry.id, price: value })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  tooltip="Wyjmij jeden ekstrakt bez płacenia"
                  onClick={() => act('take', { id: entry.id })}
                />
              </Stack.Item>
            </>
          )}
          <Stack.Item>
            <Button
              icon="cart-shopping"
              color={tooPoor ? 'bad' : 'good'}
              disabled={data.balance === null || tooPoor}
              onClick={() => act('buy', { id: entry.id, price: entry.price })}
            >
              Kup za {entry.price} kr
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      {reactions.length === 0 ? (
        <Box color="label">Ten ekstrakt nie ma znanych reakcji.</Box>
      ) : (
        reactions.map((reaction) => (
          <Box key={reaction.id} mb={1}>
            <Box bold>{reaction.name}</Box>
            <Box color="label">
              Aktywacja: {listReagents(reaction.reagents) || 'brak'}
              {reaction.results.length > 0 &&
                ` → ${listReagents(reaction.results)}`}
            </Box>
            {!!reaction.desc && <Box>{reaction.desc}</Box>}
          </Box>
        ))
      )}
    </Section>
  );
};
