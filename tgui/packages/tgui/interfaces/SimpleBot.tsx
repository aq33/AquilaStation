import {
  Box,
  Button,
  Icon,
  LabeledControls,
  NoticeBox,
  NumberInput,
  Section,
  Slider,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  can_hack: BooleanLike;
  custom_controls: Record<string, number | string>;
  emagged: BooleanLike;
  hacked: BooleanLike;
  has_access: BooleanLike;
  locked: BooleanLike;
  settings: Settings;
  // AQUILA: atmosbot - filtrowane gazy
  scrub_gases?: ScrubGas[];
};

type Settings = {
  airplane_mode: BooleanLike;
  allow_possession: BooleanLike;
  maintenance_open: BooleanLike;
  pai_inserted: BooleanLike;
  pai_active: BooleanLike;
  patrol_station: BooleanLike;
  power: BooleanLike;
};

type ScrubGas = {
  id: string;
  name: string;
  enabled: BooleanLike;
};

/** Polskie etykiety ustawień przychodzących z DM (klucz = nazwa akcji) */
const CONTROL_LABELS: Record<string, string> = {
  clean_blood: 'Krew',
  clean_trash: 'Śmieci',
  clean_graffiti: 'Graffiti',
  pest_control: 'Szkodniki',
  check_id: 'Brak ID',
  check_weapons: 'Nielegalna broń',
  check_records: 'Nakazy',
  detain_only: 'Tylko zatrzymanie',
  declare_arrests: 'Zgłaszanie',
  extinguish_fires: 'Gaszenie pożarów',
  extinguish_people: 'Gaszenie ludzi',
  stationary_mode: 'Stacjonarny',
  tile_stack: 'Płytki specjalne',
  place_tiles: 'Układanie',
  replace_tiles: 'Wymiana płytek',
  fix_floors: 'Naprawa podłóg',
  auto_tile: 'Nowe poszycie',
  traction_magnets: 'Magnesy',
  line_mode: 'Tryb liniowy',
  heal_threshold: 'Próg leczenia',
  speaker: 'Głośnik',
  critical_alerts: 'Alarmy krytyczne',
  search_tech: 'Technologie',
  breach_pressure: 'Ciśnienie wyłomu',
  temperature_control: 'Kontrola temperatury',
  ideal_temperature: 'Temp. docelowa',
  max_sanity: 'Maks. poczytalność',
  hug_mode: 'Tryb pracy',
  pink_wire: 'Różowy przewód',
  water_trays: 'Podlewanie',
};

const CONTROL_TOOLTIPS: Record<string, string> = {
  clean_blood: 'Sprzątanie krwi.',
  clean_trash: 'Sprzątanie śmieci.',
  clean_graffiti: 'Usuwanie graffiti.',
  pest_control: 'Tępienie szkodników.',
  check_id: 'Aresztuje osoby bez identyfikatora.',
  check_weapons: 'Aresztuje za broń bez zezwolenia.',
  check_records: 'Aresztuje na podstawie nakazów w aktach.',
  detain_only: 'Zatrzymuje zamiast skuwać.',
  declare_arrests: 'Zgłasza aresztowania przez radio.',
  stationary_mode: 'Bot nie rusza się z miejsca.',
  place_tiles: 'Kładzie płytki podłogowe.',
  replace_tiles: 'Zastępuje istniejące płytki płytkami specjalnymi.',
  fix_floors: 'Naprawia uszkodzone płytki i poszycie.',
  auto_tile: 'Kładzie płytki na nowym poszyciu.',
  traction_magnets: 'Przytwierdza bota do podłoża.',
  speaker: 'Włącza lub wyłącza głośnik.',
  critical_alerts: 'Zgłasza pacjentów w stanie krytycznym.',
  temperature_control: 'Utrzymuje temperaturę docelową.',
  water_trays: 'Podlewa tace hydroponiczne.',
};

const LINE_DIRECTIONS: Record<string, string> = {
  north: 'Pn',
  east: 'Wsch',
  south: 'Pd',
  west: 'Zach',
};

export function SimpleBot(props) {
  const { data } = useBackend<Data>();
  const { can_hack, locked, scrub_gases } = data;
  const access = !locked || !!can_hack;

  return (
    <Window width={450} height={scrub_gases ? 460 : 320}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BotSettings />
          </Stack.Item>
          {!!access && (
            <Stack.Item grow>
              <BotControl />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

export function BotSettings(props) {
  const { data } = useBackend<Data>();
  const { can_hack, locked } = data;
  const access = !locked || !!can_hack;
  return (
    <Section title="Ustawienia" buttons={<TabDisplay />}>
      {!access ? <NoticeBox>Zablokowane!</NoticeBox> : <SettingsDisplay />}
    </Section>
  );
}

export function BotControl(props) {
  const { act, data } = useBackend<Data>();
  const { custom_controls = {}, scrub_gases } = data;
  const controls = Object.entries(custom_controls);
  if (!controls.length && !scrub_gases) {
    return null;
  }
  return (
    <Section fill scrollable title="Sterowanie">
      <LabeledControls wrap>
        {controls.map((control) => (
          <LabeledControls.Item
            pb={2}
            key={control[0]}
            label={
              CONTROL_LABELS[control[0]] ||
              capitalizeAll(control[0].replace('_', ' '))
            }
          >
            <ControlHelper control={control} />
          </LabeledControls.Item>
        ))}
      </LabeledControls>
      {!!scrub_gases && (
        <Section title="Filtrowane gazy">
          {scrub_gases.map((gas) => (
            <Button.Checkbox
              key={gas.id}
              checked={gas.enabled}
              onClick={() => act('toggle_gas', { gas: gas.id })}
            >
              {gas.name}
            </Button.Checkbox>
          ))}
        </Section>
      )}
    </Section>
  );
}

/** Przyciski nad ustawieniami: hakowanie, pAI, blokada */
function TabDisplay(props) {
  const { act, data } = useBackend<Data>();
  const {
    can_hack,
    emagged,
    has_access,
    locked,
    settings: { allow_possession },
  } = data;

  return (
    <>
      {!!can_hack && (
        <Button
          color="danger"
          icon={emagged ? 'bug' : 'lock'}
          onClick={() => act('hack')}
          selected={!emagged}
          tooltip={
            !emagged
              ? 'Wyłącza system zapobiegania krzywdzie.'
              : 'Resetuje oprogramowanie bota.'
          }
        >
          {emagged ? 'NIEBEZPIECZEŃSTWO' : 'Blokada bezpieczeństwa'}
        </Button>
      )}
      {!!allow_possession && <PaiButton />}
      <Button
        color="transparent"
        disabled={!has_access && !can_hack}
        icon={locked ? 'lock' : 'lock-open'}
        onClick={() => act('lock')}
        selected={locked}
        tooltip={`${locked ? 'Odblokuj' : 'Zablokuj'} panel sterowania.`}
      >
        Blokada
      </Button>
    </>
  );
}

/** Stan karty pAI i jej wysuwanie */
function PaiButton(props) {
  const { act, data } = useBackend<Data>();
  const {
    settings: { pai_inserted, pai_active },
  } = data;

  if (!pai_inserted) {
    return (
      <Button
        color="transparent"
        icon="robot"
        tooltip="Włóż aktywną kartę pAI, aby sterować tym botem."
      >
        Brak pAI
      </Button>
    );
  }

  return (
    <Button
      icon="eject"
      onClick={() => act('eject_pai')}
      tooltip={`Wysuwa kartę pAI (${pai_active ? 'aktywna' : 'nieaktywna'}).`}
    >
      Wysuń pAI
    </Button>
  );
}

/** Podstawowe ustawienia bota: zasilanie, patrol itd. */
function SettingsDisplay(props) {
  const { act, data } = useBackend<Data>();
  const {
    settings: { airplane_mode, patrol_station, power, maintenance_open },
  } = data;

  return (
    <LabeledControls>
      <LabeledControls.Item label="Zasilanie">
        <Tooltip content={`${power ? 'Wyłącza' : 'Włącza'} bota.`}>
          <Icon
            size={2}
            name="power-off"
            color={power ? 'good' : 'gray'}
            onClick={() => act('power')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Tryb samolotowy">
        <Tooltip
          content={`${
            !airplane_mode ? 'Odcina' : 'Przywraca'
          } zdalne sterowanie z konsoli i PDA.`}
        >
          <Icon
            size={2}
            name="plane"
            color={airplane_mode ? 'yellow' : 'gray'}
            onClick={() => act('airplane')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Patrol">
        <Tooltip
          content={`${
            patrol_station ? 'Wyłącza' : 'Włącza'
          } automatyczne patrolowanie stacji.`}
        >
          <Icon
            size={2}
            name="map-signs"
            color={patrol_station ? 'good' : 'gray'}
            onClick={() => act('patrol')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Panel serwisowy">
        <Tooltip
          content={
            maintenance_open
              ? 'Panel serwisowy jest otwarty.'
              : 'Panel serwisowy jest zamknięty.'
          }
        >
          <Icon
            size={2}
            name="toolbox"
            color={maintenance_open ? 'yellow' : 'gray'}
          />
        </Tooltip>
      </LabeledControls.Item>
    </LabeledControls>
  );
}

enum ControlType {
  MedbotThreshold = 'heal_threshold',
  MedbotTech = 'search_tech',
  FloorbotTiles = 'tile_stack',
  FloorbotLine = 'line_mode',
  AtmosbotPressure = 'breach_pressure',
  AtmosbotTemperature = 'ideal_temperature',
  HugbotSanity = 'max_sanity',
  HugbotMode = 'hug_mode',
  HugbotWire = 'pink_wire',
}

const HUG_MODES: Record<string, string> = {
  hug: 'Przytulanie',
  pat: 'Głaskanie',
  boop: 'Pstryczek',
};

type ControlProps = {
  control: [string, number | string];
};

/** Wybiera rodzaj kontrolki dla ustawienia */
function ControlHelper(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { control } = props;

  switch (control[0]) {
    case ControlType.MedbotThreshold:
      return <MedbotThreshold control={control} />;
    case ControlType.MedbotTech:
      return (
        <Button
          icon="search"
          onClick={() => act(control[0])}
          tooltip="Szuka w sieci badań postępów chirurgii, które zwiększą skuteczność leczenia."
        >
          Szukaj
        </Button>
      );
    case ControlType.FloorbotTiles:
      return <FloorbotTiles control={control} />;
    case ControlType.FloorbotLine:
      return <FloorbotLine control={control} />;
    case ControlType.AtmosbotPressure:
      return (
        <NumberInput
          value={Number(control[1])}
          minValue={0}
          maxValue={100}
          step={1}
          unit="kPa"
          width="70px"
          onChange={(value) => act(control[0], { value })}
        />
      );
    case ControlType.AtmosbotTemperature:
      return (
        <NumberInput
          value={Number(control[1])}
          minValue={273.15}
          maxValue={313.15}
          step={1}
          unit="K"
          width="70px"
          onChange={(value) => act(control[0], { value })}
        />
      );
    case ControlType.HugbotSanity:
      return (
        <NumberInput
          value={Number(control[1])}
          minValue={25}
          maxValue={125}
          step={10}
          width="60px"
          onChange={(value) => act(control[0], { value })}
        />
      );
    case ControlType.HugbotMode:
      return (
        <Button
          icon="hand-holding-heart"
          onClick={() => act(control[0])}
          tooltip="Kliknij, by zmienić tryb pracy."
        >
          {HUG_MODES[String(control[1])] || String(control[1])}
        </Button>
      );
    case ControlType.HugbotWire:
      return (
        <Button
          icon="scissors"
          color={control[1] ? 'bad' : 'default'}
          onClick={() => act(control[0])}
          tooltip="Odsłonięty różowy przewód."
        >
          {control[1] ? 'Przecięty' : 'Nienaruszony'}
        </Button>
      );
    default:
      return (
        <Tooltip content={CONTROL_TOOLTIPS[control[0]] || ''}>
          <Icon
            color={control[1] ? 'good' : 'gray'}
            name={control[1] ? 'toggle-on' : 'toggle-off'}
            size={2}
            onClick={() => act(control[0])}
          />
        </Tooltip>
      );
  }
}

/** Suwak progu leczenia medbota */
function MedbotThreshold(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { control } = props;

  return (
    <Tooltip content="Ile obrażeń musi mieć pacjent, by medbot zaczął leczyć.">
      <Box width="120px">
        <Slider
          minValue={5}
          maxValue={75}
          ranges={{
            good: [-Infinity, 15],
            average: [15, 55],
            bad: [55, Infinity],
          }}
          step={5}
          value={Number(control[1])}
          onChange={(_, value) => act(control[0], { threshold: value })}
        />
      </Box>
    </Tooltip>
  );
}

/** Płytki specjalne floorbota: liczba i wysuwanie */
function FloorbotTiles(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { control } = props;

  return (
    <Button
      disabled={!control[1]}
      icon={control[1] ? 'eject' : ''}
      onClick={() => act('eject_tiles')}
      tooltip="Liczba płytek specjalnych w bocie."
    >
      {control[1] ? `${control[1]}` : 'Pusto'}
    </Button>
  );
}

/** Kierunek układania w trybie liniowym floorbota */
function FloorbotLine(props: ControlProps) {
  const { act } = useBackend<Data>();
  const { control } = props;
  const direction = control[1] ? String(control[1]) : '';

  return (
    <Tooltip content="Układanie płytek w linii prostej; kliknij, by zmienić kierunek.">
      <Box
        inline
        onClick={() => act('line_mode')}
        style={{ cursor: 'pointer' }}
      >
        <Icon
          color={direction ? 'good' : 'gray'}
          name={direction ? 'compass' : 'toggle-off'}
          size={!direction ? 2 : 1.5}
        />
        {direction ? ` ${LINE_DIRECTIONS[direction] || direction}` : ''}
      </Box>
    </Tooltip>
  );
}
