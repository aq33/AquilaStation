import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AlertPane } from './AlertPane';
import type { MainData } from './data';
import { ModulesPane } from './ModulesPane';

// AQUILA: panel na naszych danych. Z wersji tg pominięte: podgląd mecha
// (ByondUi), przetaktowanie, diagnostyka, edycja dostępów w oknie
// (u nas dostęp wgrywa się kartą ID z zewnątrz) i sloty modułów.
export const Mecha = (props) => {
  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="380px">
            <Stack vertical fill>
              <Stack.Item grow>
                <MainPane />
              </Stack.Item>
              <Stack.Item>
                <AlertPane />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <ModulesPane />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const { name, actions = [] } = data;
  return (
    <Section
      fill
      scrollable
      title={name}
      buttons={
        <Button
          icon="edit"
          tooltip="Zmień nazwę"
          tooltipPosition="left"
          onClick={() => act('changename')}
        />
      }
    >
      <LabeledList>
        <IntegrityBar />
        <PowerBar />
        <LightsItem />
        <AirItems />
        <DNALock />
        <AccessItems />
        <RadioItems />
        {actions.map((action) => (
          <LabeledList.Item
            key={action.key}
            label={action.name}
            buttons={
              <Button
                icon="power-off"
                selected={!!action.active}
                onClick={() => act('toggle_action', { key: action.key })}
              >
                {action.key === 'smoke' ? 'Użyj' : 'Przełącz'}
              </Button>
            }
          >
            {action.state}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PowerBar = (props) => {
  const { data } = useBackend<MainData>();
  const { power_level, power_max, has_cell } = data;
  return (
    <LabeledList.Item label="Energia">
      <ProgressBar
        value={power_max ? power_level / power_max : 0}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {!has_cell
          ? 'Brak ogniwa zasilającego'
          : power_max
            ? `${Math.round((power_level / power_max) * 100)}% (${power_level} / ${power_max})`
            : power_level}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const IntegrityBar = (props) => {
  const { data } = useBackend<MainData>();
  const { integrity, integrity_max } = data;
  return (
    <LabeledList.Item label="Wytrzymałość">
      <ProgressBar
        value={integrity_max ? integrity / integrity_max : 0}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {`${integrity} / ${integrity_max}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const LightsItem = (props) => {
  const { act, data } = useBackend<MainData>();
  const { lights, has_lights } = data;
  return (
    <LabeledList.Item label="Światła">
      <Button
        icon="lightbulb"
        selected={!!lights}
        disabled={!has_lights}
        onClick={() => act('toggle_lights')}
      >
        {lights ? 'Włączone' : 'Wyłączone'}
      </Button>
    </LabeledList.Item>
  );
};

const AirItems = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    enclosed,
    has_tank,
    use_internal_tank,
    tank_pressure,
    tank_temperature,
    port_connected,
    cabin_pressure,
    cabin_temperature,
    warning_high_pressure,
  } = data;
  if (!has_tank) {
    return (
      <LabeledList.Item label="Powietrze">
        <Box color="label">Otoczenie (brak zbiornika)</Box>
      </LabeledList.Item>
    );
  }
  return (
    <>
      <LabeledList.Item
        label="Źródło powietrza"
        buttons={
          <Button
            icon={use_internal_tank ? 'mask-ventilator' : 'wind'}
            selected={!!use_internal_tank}
            disabled={!enclosed}
            onClick={() => act('toggle_internals')}
          >
            Przełącz
          </Button>
        }
      >
        {use_internal_tank ? 'Wewnętrzny zbiornik' : 'Otoczenie'}
      </LabeledList.Item>
      <LabeledList.Item label="Zbiornik">
        {tank_pressure} kPa, {tank_temperature} K
      </LabeledList.Item>
      <LabeledList.Item
        label="Kabina"
        color={cabin_pressure > warning_high_pressure ? 'bad' : undefined}
      >
        {cabin_pressure} kPa, {cabin_temperature} K
      </LabeledList.Item>
      <LabeledList.Item
        label="Port gazowy"
        buttons={
          <Button
            icon={port_connected ? 'unlink' : 'link'}
            onClick={() => act('toggle_port')}
          >
            {port_connected ? 'Odłącz' : 'Podłącz'}
          </Button>
        }
      >
        {port_connected ? 'Podłączony' : 'Niepodłączony'}
      </LabeledList.Item>
    </>
  );
};

const DNALock = (props) => {
  const { act, data } = useBackend<MainData>();
  const { dna_lock } = data;
  return (
    <LabeledList.Item label="Blokada DNA">
      <Button
        onClick={() => act('dna_lock')}
        icon="syringe"
        tooltip="Powiąż z twoim DNA"
        selected={!!dna_lock}
        tooltipPosition="top"
      >
        {dna_lock ? 'Włączona' : 'Brak'}
      </Button>
      {!!dna_lock && (
        <>
          <Button
            icon="key"
            tooltip={`Enzym klucza: ${dna_lock}`}
            tooltipPosition="top"
          />
          <Button
            onClick={() => act('reset_dna')}
            icon="ban"
            tooltip="Zresetuj blokadę DNA"
            tooltipPosition="top"
          />
        </>
      )}
    </LabeledList.Item>
  );
};

const AccessItems = (props) => {
  const { act, data } = useBackend<MainData>();
  const { id_upload, maint_access, maint_protocols } = data;
  return (
    <>
      <LabeledList.Item label="Wgrywanie ID">
        <Button
          icon={id_upload ? 'lock-open' : 'lock'}
          selected={!!id_upload}
          tooltip="Pozwala ustawić wymagane dostępy, przeciągając kartę ID po mechu."
          onClick={() => act('toggle_id_upload')}
        >
          {id_upload ? 'Odblokowane' : 'Zablokowane'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Protokoły serwisowe">
        <Button
          icon="wrench"
          selected={!!maint_access}
          disabled={!!maint_protocols}
          tooltip={
            maint_protocols
              ? 'Protokoły serwisowe są w toku.'
              : 'Pozwala technikom otworzyć mecha kartą ID.'
          }
          onClick={() => act('toggle_maint_access')}
        >
          {maint_access ? 'Dozwolone' : 'Zabronione'}
        </Button>
      </LabeledList.Item>
    </>
  );
};

const RadioItems = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    has_radio,
    radio_broadcasting,
    radio_listening,
    radio_frequency = 1459,
    min_frequency,
    max_frequency,
  } = data;
  if (!has_radio) {
    return (
      <LabeledList.Item label="Radio">
        <Box color="bad">Błąd</Box>
      </LabeledList.Item>
    );
  }
  return (
    <LabeledList.Item label="Radio">
      <Button
        icon={radio_broadcasting ? 'microphone' : 'microphone-slash'}
        selected={!!radio_broadcasting}
        tooltip="Mikrofon"
        onClick={() => act('rmictoggle')}
      />
      <Button
        icon={radio_listening ? 'volume-up' : 'volume-mute'}
        selected={!!radio_listening}
        tooltip="Głośnik"
        onClick={() => act('rspktoggle')}
      />
      <NumberInput
        ml={1}
        animated
        unit="kHz"
        step={0.2}
        stepPixelSize={10}
        minValue={min_frequency / 10}
        maxValue={max_frequency / 10}
        value={radio_frequency / 10}
        format={(value) => value.toFixed(1)}
        onChange={(value) =>
          act('rfreq', { frequency: Math.round(value * 10) })
        }
      />
    </LabeledList.Item>
  );
};
