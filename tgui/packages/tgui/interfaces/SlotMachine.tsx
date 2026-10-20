import { useEffect, useMemo, useRef, useState } from 'react';
import { Blink, Box, Button, Section, Stack } from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  symbols: SlotSymbol[];
  reels: Reel[];
  balance: number;
  working: number;
  winning: number;
  money: number;
  cost: number;
  plays: number;
  jackpots: number;
  jackpot: number;
  paymode: number;
  jackpot_id: string;
};

// AQUILA: symbole to znaki z kolorem (u nas bez spritesheetu z tg)
type SlotSymbol = {
  id: string;
  color: string;
};

type Reel = {
  symbols: string[];
};

/** Odmiana „kredyt” po polsku */
const credits = (amount: number) => {
  if (amount === 1) {
    return 'kredyt';
  }
  const lastDigit = amount % 10;
  const lastTwo = amount % 100;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14)) {
    return 'kredyty';
  }
  return 'kredytów';
};

/** Odmiana „raz/razy” */
const times = (amount: number) => (amount === 1 ? 'raz' : 'razy');

const pickRandomMany = <T,>(items: T[], n: number) => {
  const result: T[] = [];
  for (let i = 0; i < n; i += 1) {
    result.push(pickRandom(items));
  }
  return result;
};

const pickRandom = <T,>(items: T[]) => {
  return items[Math.floor(Math.random() * items.length)];
};

const SymbolGlyph = (props: { symbol?: SlotSymbol }) => {
  const { symbol } = props;
  if (!symbol) {
    return null;
  }
  return (
    <Box inline className="SlotMachine__Glyph" color={symbol.color}>
      {symbol.id}
    </Box>
  );
};

export const SlotMachine = () => {
  const { act, data } = useBackend<Data>();
  const { symbols = [], cost, reels = [], balance } = data;
  const spinning = data.working === 1;

  const symbolsById = useMemo(() => {
    const map: Record<string, SlotSymbol> = {};
    for (const symbol of symbols) {
      map[symbol.id] = symbol;
    }
    return map;
  }, [symbols]);

  const jackpotSymbol = symbolsById[data.jackpot_id];

  return (
    <Window width={300} height={445}>
      <Window.Content>
        <Banner />
        <Section>
          <div className={'SlotMachine__Reels'}>
            {reels.map((reel, i) => (
              <div key={i} className={'SlotMachine__Reel'}>
                <IconStrip
                  symbols={symbols}
                  symbolsById={symbolsById}
                  symbolsNeeded={reel.symbols}
                  spinning={spinning}
                />
              </div>
            ))}
          </div>
        </Section>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill align={'center'}>
              <Box inline textAlign={'center'} color="good" bold mr={1}>
                Jackpot: pięć razy
              </Box>
              <SymbolGlyph symbol={jackpotSymbol} />
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Stack align={'stretch'}>
              <Stack.Item grow={1}>
                <Section
                  fill
                  title="Saldo"
                  buttons={
                    <Button
                      onClick={() => act('payout')}
                      disabled={balance <= 0}
                    >
                      Zwrot
                    </Button>
                  }
                >
                  <Box textAlign={'center'} fontSize={2}>
                    {formatMoney(balance)} cr
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fill>
                  <Button
                    fluid
                    textAlign={'center'}
                    fontSize={3}
                    color={'green'}
                    onClick={() => act('spin')}
                    disabled={spinning || balance < cost}
                  >
                    Graj!
                  </Button>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const getBannerPages = () => [
  BannerTitle,
  BannerOnlyFewCreds,
  BannerPrizeMoney,
  BannerTitle,
  BannerJackpot,
  BannerStats,
];

// Maks. 14 znaków (animacja liter w SlotMachine.scss)
const BANNER_TEXTS = [
  'KRĘĆ! KRĘĆ!',
  'ROZGRZANY!',
  'GORĄCE SLOTY',
  'KRĘĆ I WYGRAJ',
  'UWIERZ W TO!',
  'OD ZERA DO $',
  'JESZCZE RAZ',
  'KOŁO FORTUNY',
  'CZAS NA BONUS',
  'NIC NIE TRACISZ',
  'ŁADNY OBRÓT!',
  'KTO NIE GRA...',
  'POSTAW I ZAPOMNIJ',
  'HONK NA SZCZĘŚCIE',
  'DŁUG NA ŻYCIE',
  'MIASTO SLOTÓW',
  'JACKPOT TUŻ TUŻ',
  'TWÓJ DZIEŃ!',
  'FORTUNA WOŁA',
  'ZŁOTO OD RĘKI',
  'MARZ ŚMIELEJ!',
  'TYLKO WYGRANI',
  'GRA TO ŻYCIE',
  'SZCZĘŚLIWY RZUT',
  'WYPŁATA? NIE!',
].filter((text) => text.length <= 14);

const WINNING_TEXTS = [
  null,
  'DARMOWE GRY!',
  'WYGRANA!',
  'WIELKA WYGRANA',
  'JACKPOT!!!',
];

const Banner = () => {
  const { data } = useBackend<Data>();
  const [page, setPage] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setPage((page) => (page + 1) % getBannerPages().length);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const winningText = !data.working && WINNING_TEXTS[data.winning];
  if (winningText) {
    return (
      <Section className={'SlotMachine__Banner SlotMachine__Banner--winning'}>
        <BannerTitle text={winningText} />
      </Section>
    );
  }

  const Component = getBannerPages()[page];

  return (
    <Section className={'SlotMachine__Banner'}>
      <Component />
    </Section>
  );
};

type BannerTitleProps = {
  text?: string;
};

const BannerTitle = (props: BannerTitleProps) => {
  const { data } = useBackend<Data>();
  const defaultText = useRef(pickRandom(BANNER_TEXTS));
  let text = props.text;
  if (!text) {
    if (data.balance <= 0) {
      text = 'WRZUĆ MONETĘ';
    } else if (data.balance <= data.cost) {
      text = 'OSTATNIA GRA';
    } else {
      text = defaultText.current;
    }
  }
  const letters = text.split('');
  return (
    <div className={'SlotMachine__BannerTitle'}>
      {letters.map((letter, i) => (
        <span key={i}>{letter}</span>
      ))}
    </div>
  );
};

const BannerOnlyFewCreds = () => {
  const { data } = useBackend<Data>();
  const variant = useRef(pickRandom([0, 1]));

  if (variant.current === 1) {
    return (
      <div>
        Tylko{' '}
        <Blink interval={200} time={200}>
          <b>{data.cost}</b>
        </Blink>{' '}
        {credits(data.cost)}!
        <br />
        <Box inline fontSize={'12px'}>
          Rozwiąż wszystkie swoje problemy!
        </Box>
      </div>
    );
  }

  return (
    <div>
      Tylko{' '}
      <Blink interval={200} time={200}>
        <b>{data.cost}</b>
      </Blink>{' '}
      {credits(data.cost)} za szansę
      <br />
      na <b>wielką</b> wygraną!
    </div>
  );
};

const BannerPrizeMoney = () => {
  const { data } = useBackend<Data>();
  return (
    <div>
      Dostępna pula nagród:
      <br />
      <b>
        {data.money} {credits(data.money)}
      </b>
    </div>
  );
};

const BannerJackpot = () => {
  const { data } = useBackend<Data>();
  const total = data.money + data.jackpot;
  return (
    <div>
      Obecny jackpot:
      <br />
      <b>
        {total} {credits(total)}!
      </b>
    </div>
  );
};

const BannerStats = () => {
  const { data } = useBackend<Data>();
  return (
    <div>
      <Box inline fontSize={'13px'}>
        Dziś zagrano już{' '}
        <b>
          {data.plays} {times(data.plays)}
        </b>
      </Box>
      <br />i padło{' '}
      <b>
        {data.jackpots} {data.jackpots === 1 ? 'jackpot' : 'jackpotów'}!
      </b>
    </div>
  );
};

const ICON_STRIP_LENGTH = 30;

type IconStripProps = {
  symbols: SlotSymbol[];
  symbolsById: Record<string, SlotSymbol>;
  symbolsNeeded: string[];
  spinning?: boolean;
};

const IconStrip = (props: IconStripProps) => {
  const { symbols, symbolsById, symbolsNeeded, spinning } = props;
  const symbolIds = useMemo(() => symbols.map((s) => s.id), [symbols]);

  const [drawnSymbols, setDrawnSymbols] = useState<string[]>([
    ...pickRandomMany(symbolIds, ICON_STRIP_LENGTH - 3),
    ...symbolsNeeded,
  ]);

  useEffect(() => {
    if (spinning) {
      setDrawnSymbols((drawn) => [
        ...drawn.slice(-3),
        ...pickRandomMany(symbolIds, ICON_STRIP_LENGTH - 6),
        ...symbolsNeeded,
      ]);
    } else {
      setDrawnSymbols([
        ...pickRandomMany(symbolIds, ICON_STRIP_LENGTH - 3),
        ...symbolsNeeded,
      ]);
    }
  }, [spinning]);

  return (
    <div
      className={classes([
        'SlotMachine__IconStrip',
        spinning && 'SlotMachine__IconStrip--spinning',
      ])}
    >
      {drawnSymbols.map((symbolId, i) => (
        <div key={i} className="SlotMachine__Symbol">
          <SymbolGlyph symbol={symbolsById[symbolId]} />
        </div>
      ))}
    </div>
  );
};
