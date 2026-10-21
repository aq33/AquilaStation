// AQUILA - Orion Trail (aquila/code/game/machinery/computer/orion_trail_ui.dm)
// Wygląd przeniesiony z okna OrionGame z tg; logika gry zostaje nasza
// (dawny Topic() z arcade.dm, zdarzenia rozbierane z HTML w DM).
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const STATUS_START = 1;
const STATUS_GAMEOVER = 3;

type EventButton = {
  key: string;
  value: string;
  label: string;
};

type OrionEvent = {
  text: string;
  buttons: EventButton[];
};

type Data = {
  status: number;
  food: number;
  fuel: number;
  engine: number;
  hull: number;
  electronics: number;
  settlers: string[];
  turn: number;
  emagged: boolean;
  event: OrionEvent | null;
  starved?: boolean;
  out_of_fuel?: boolean;
  stop?: string;
  blurb?: string;
  black_hole?: boolean;
};

const goodstyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const partstyle = {
  color: 'yellow',
  fontWeight: 'bold',
};

const fuelstyle = {
  color: 'olive',
  fontWeight: 'bold',
};

// Ikony dla przycisków zdarzeń (klucze dawnego Topic() z arcade.dm)
const TOPIC_ICONS: Record<string, string> = {
  continue: 'arrow-right',
  eventclose: 'arrow-right',
  search: 'door-open',
  slow: 'arrow-left',
  keepspeed: 'tachometer-alt',
  pastblack: 'redo',
  blackhole: 'tachometer-alt',
  holedeath: 'circle',
  useengine: 'rocket',
  useelec: 'server',
  usehull: 'wrench',
  wait: 'clock',
  buycrew: 'user-plus',
  sellcrew: 'user-minus',
  leave_spaceport: 'arrow-right',
  raid_spaceport: 'skull',
  buyparts: 'wrench',
  trade: 'exchange-alt',
};

const TopicButton = (props: {
  topic: string;
  value?: string;
  label: string;
  color?: string;
  icon?: string;
  fluid?: boolean;
  disabled?: boolean;
}) => {
  const { act } = useBackend<Data>();
  const { topic, value, label, color, icon, fluid, disabled } = props;
  return (
    <Button
      icon={icon || TOPIC_ICONS[topic]}
      color={color}
      fluid={fluid}
      disabled={disabled}
      lineHeight={2}
      onClick={() => act('topic', { key: topic, value: value || '1' })}
    >
      {label}
    </Button>
  );
};

const ResourceBadges = (props: {
  food: number;
  fuel: number;
  hull: number;
  electronics: number;
  engine: number;
}) => {
  const { food, fuel, hull, electronics, engine } = props;
  return (
    <Stack vertical fill justify="center">
      <Stack.Item>
        <Button fluid icon="hamburger" color={food < 20 ? 'bad' : 'green'}>
          {`Jedzenie: ${food}`}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid icon="gas-pump" color={fuel < 15 ? 'bad' : 'olive'}>
          {`Paliwo: ${fuel}`}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid icon="wrench" color="average">
          {`Płyty kadłuba: ${hull}`}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid icon="server" color="blue">
          {`Elektronika: ${electronics}`}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid icon="rocket" color="violet">
          {`Części silnika: ${engine}`}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const AdventureStatus = () => {
  const { data } = useBackend<Data>();
  const { food, fuel, engine, hull, electronics, settlers = [], event } = data;
  return (
    <Section
      title="Stan wyprawy"
      buttons={
        <TopicButton
          topic="killcrew"
          icon="skull"
          color="red"
          label="Zabij członka załogi"
          disabled={!!event}
        />
      }
    >
      <Stack fill g={0}>
        <Stack.Item grow>
          {settlers.map((settler) => (
            <Box key={settler} py={0.5}>
              {settler}
            </Box>
          ))}
        </Stack.Item>
        <Divider vertical />
        <Stack.Item>
          <ResourceBadges
            food={food}
            fuel={fuel}
            hull={hull}
            electronics={electronics}
            engine={engine}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const OrionTrail = (_) => {
  const { data } = useBackend<Data>();
  const { status, event, emagged } = data;
  const [instructions, setInstructions] = useState(false);
  const inGame = status !== STATUS_START && status !== STATUS_GAMEOVER;
  return (
    <Window
      title="The Orion Trail"
      width={440}
      height={600}
      theme={emagged ? 'syndicate' : undefined}
    >
      <Window.Content scrollable>
        {status === STATUS_START &&
          (instructions ? (
            <InstructionsScreen onBack={() => setInstructions(false)} />
          ) : (
            <StartScreen onInstructions={() => setInstructions(true)} />
          ))}
        {status === STATUS_GAMEOVER && <GameOverScreen />}
        {inGame && (
          <Stack vertical fill>
            <Stack.Item grow>
              {event ? <EventScreen event={event} /> : <TravelScreen />}
            </Stack.Item>
            <Stack.Item>
              <AdventureStatus />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

const StartScreen = (props: { onInstructions: () => void }) => (
  <Section fill>
    <Stack vertical textAlign="center" fill>
      <Stack.Item grow={1} />
      <Stack.Item fontSize="32px">The Orion Trail</Stack.Item>
      <Stack.Item grow fontSize="15px" color="label">
        „Przeżyj podróż swoich przodków!”
      </Stack.Item>
      <Stack.Item fontSize="15px">
        <TopicButton fluid topic="newgame" icon="play" label="Nowa gra" />
      </Stack.Item>
      <Stack.Item fontSize="15px">
        <Button
          lineHeight={2}
          fluid
          icon="info"
          onClick={() => props.onInstructions()}
        >
          Instrukcja
        </Button>
      </Stack.Item>
      <Stack.Item grow={3} />
    </Stack>
  </Section>
);

const InstructionsScreen = (props: { onBack: () => void }) => {
  const fake_settlers = ['John', 'William', 'Alice', 'Tom'];
  return (
    <>
      <Section
        color="label"
        title="Cel gry"
        buttons={
          <Button icon="arrow-left" onClick={() => props.onBack()}>
            Wróć do menu
          </Button>
        }
      >
        <Box fontSize="11px">
          W XXIII wieku szlak do Oriona stał się niebezpieczną, ale kuszącą
          drogą przez kosmos dla tych, którzy chcieli zaryzykować. Wielu
          pionierów szukających nowego życia na galaktycznym pograniczu
          znajdowało dokładnie to, czego szukało... albo ginęło po drodze.
        </Box>
      </Section>
      <Section title="Przykładowy stan">
        <Stack>
          <Stack.Item basis={70} grow align="center">
            {fake_settlers.map((settler) => (
              <Box key={settler} py={0.5}>
                {settler}
              </Box>
            ))}
          </Stack.Item>
          <Divider vertical />
          <Stack.Item>
            To panel stanu twoich pionierów. Każdy z nich zjada jedzenie za
            każdym razem, gdy lecisz dalej w stronę{' '}
            <span style={goodstyle}>Oriona</span>. Po drodze możesz znaleźć
            nowych członków załogi i stracić ich równie szybko.
            <br />
            <br />
            Jeśli skończy się jedzenie albo załoga, to dla ciebie{' '}
            <span style={badstyle}>KONIEC GRY</span>!
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Zasoby">
        <Stack>
          <Stack.Item grow>
            Jeśli chcesz dotrzeć do <span style={goodstyle}>Oriona</span>,
            musisz pilnować zasobów:
            <br />
            <span style={goodstyle}>Jedzenie</span>: zjada je załoga. Im więcej
            ludzi, tym szybciej znika!
            <br />
            <span style={fuelstyle}>Paliwo</span>: zużywasz je przy każdym
            skoku. Nie pozwól, żeby się skończyło.
            <br />
            <span style={partstyle}>Części</span>: służą do naprawy awarii. Nikt
            nie lubi tracić czasu na naprawy!
          </Stack.Item>
          <Divider vertical />
          <Stack.Item>
            <ResourceBadges
              food={80}
              fuel={60}
              hull={1}
              electronics={1}
              engine={1}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

const GameOverScreen = () => {
  const { data } = useBackend<Data>();
  const { settlers = [], starved, out_of_fuel } = data;
  return (
    <Section fill>
      <Stack vertical textAlign="center" fill>
        <Stack.Item grow={1} />
        <Stack.Item color="red" fontSize="32px">
          Koniec gry
        </Stack.Item>
        <Stack.Item fontSize="15px" color="label">
          Jak wielu przed tobą, twoja załoga nigdy nie dotarła do Oriona.
        </Stack.Item>
        <Stack.Item grow fontSize="15px">
          {settlers.length === 0 && (
            <NoticeBox danger>
              Zginęła cała załoga, a statek dołączył do floty widm dryfujących
              po galaktyce.
            </NoticeBox>
          )}
          {settlers.length > 0 && !!starved && (
            <NoticeBox danger>
              Skończyło się jedzenie i załoga umarła z głodu.
            </NoticeBox>
          )}
          {settlers.length > 0 && !!out_of_fuel && (
            <NoticeBox danger>
              Skończyło się paliwo i statek powoli wpłynął w gwiazdę.
            </NoticeBox>
          )}
        </Stack.Item>
        <Stack.Item fontSize="15px">
          <TopicButton
            fluid
            topic="menu"
            icon="arrow-left"
            label="Niech spoczywają w pokoju"
          />
        </Stack.Item>
        <Stack.Item grow={3} />
      </Stack>
    </Section>
  );
};

const TravelScreen = () => {
  const { data } = useBackend<Data>();
  const { stop, blurb, black_hole, turn } = data;
  return (
    <Section
      title="Lokacja"
      fill
      buttons={<Box color="label">Etap {turn} / 9</Box>}
    >
      <Stack fill textAlign="center" vertical>
        <Stack.Item grow>
          <Box bold fontSize="15px">
            {stop}
          </Box>
          <br />
          <Box fontSize="15px">{blurb}</Box>
        </Stack.Item>
        <Stack.Item>
          {black_hole ? (
            <>
              <Box mb={1}>
                <TopicButton topic="pastblack" label="Omiń" />
              </Box>
              <Box mb={1}>
                <TopicButton topic="blackhole" label="Leć dalej" />
              </Box>
            </>
          ) : (
            <Box mb={1}>
              <TopicButton topic="continue" label="Leć dalej" />
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EventScreen = (props: { event: OrionEvent }) => {
  const { event } = props;
  return (
    <Section title="Zdarzenie" fill>
      <Stack fill textAlign="center" vertical>
        <Stack.Item grow fontSize="14px">
          <Box dangerouslySetInnerHTML={{ __html: event.text }} />
        </Stack.Item>
        <Stack.Item>
          <Stack wrap justify="center">
            {event.buttons.map((button, index) => (
              <Stack.Item key={index} mb={1}>
                <TopicButton
                  topic={button.key}
                  value={button.value}
                  label={button.label}
                />
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
