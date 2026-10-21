import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: 'Obrażenia fizyczne',
    type: 'bruteLoss',
  },
  {
    label: 'Niedotlenienie',
    type: 'oxyLoss',
  },
  {
    label: 'Toksyny',
    type: 'toxLoss',
  },
  {
    label: 'Oparzenia',
    type: 'fireLoss',
  },
] as const;

// Stan pacjenta przychodzi z DM po angielsku, tu tylko wyświetlamy po polsku.
const STAT_NAMES = {
  Conscious: 'Przytomny',
  Unconscious: 'Nieprzytomny',
  Dead: 'Martwy',
};

type Occupant = {
  name: string;
  stat: string;
  // AQUILA: kolory stanu i temperatury liczy nasz DM
  statstate: string;
  temperaturestatus: string;
  bodyTemperature: number;
  health: number;
  maxHealth: number;
  bruteLoss: number;
  oxyLoss: number;
  toxLoss: number;
  fireLoss: number;
};

type BeakerReagent = {
  name: string;
  volume: number;
};

type Data = {
  isOperating: BooleanLike;
  isOpen: BooleanLike;
  autoEject: BooleanLike;
  hasOccupant: BooleanLike;
  occupant: Occupant;
  cellTemperature: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: BeakerReagent[];
  beakerCurrentVolume?: number;
  beakerMaxVolume?: number;
};

export const Cryo = () => {
  const { act, data } = useBackend<Data>();
  const { occupant, hasOccupant, isOperating, isOpen } = data;

  return (
    <Window width={400} height={550}>
      <Window.Content scrollable>
        <Section title="Pacjent">
          <LabeledList>
            <LabeledList.Item label="Pacjent">
              {(hasOccupant && occupant?.name) || 'Brak pacjenta'}
            </LabeledList.Item>
            {!!hasOccupant && (
              <>
                <LabeledList.Item label="Stan" color={occupant.statstate}>
                  {STAT_NAMES[occupant.stat] || occupant.stat}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Temperatura"
                  color={occupant.temperaturestatus}
                >
                  <AnimatedNumber value={round(occupant.bodyTemperature, 0)} />
                  {' K'}
                </LabeledList.Item>
                <LabeledList.Item label="Zdrowie">
                  <ProgressBar
                    value={round(occupant.health / occupant.maxHealth, 2)}
                    color={occupant.health > 0 ? 'good' : 'average'}
                  >
                    <AnimatedNumber value={round(occupant.health, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                {damageTypes.map((damageType) => (
                  <LabeledList.Item
                    key={damageType.type}
                    label={damageType.label}
                  >
                    <ProgressBar
                      value={round(occupant[damageType.type] / 100, 2)}
                    >
                      <AnimatedNumber
                        value={round(occupant[damageType.type], 0)}
                      />
                    </ProgressBar>
                  </LabeledList.Item>
                ))}
              </>
            )}
          </LabeledList>
        </Section>
        <Section title="Komora">
          <LabeledList>
            <LabeledList.Item label="Zasilanie">
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                disabled={isOpen}
                onClick={() => act('power')}
                color={isOperating && 'green'}
              >
                {isOperating ? 'Wł.' : 'Wył.'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Temperatura">
              <AnimatedNumber value={round(data.cellTemperature, 0)} /> K
            </LabeledList.Item>
            <LabeledList.Item label="Drzwi">
              <Button
                icon={isOpen ? 'unlock' : 'lock'}
                onClick={() => act('door')}
              >
                {isOpen ? 'Otwarte' : 'Zamknięte'}
              </Button>
              <Button
                icon={data.autoEject ? 'sign-out-alt' : 'sign-in-alt'}
                tooltip="Wysuwanie pacjenta po wyleczeniu"
                onClick={() => act('autoeject')}
              >
                {data.autoEject ? 'Automatycznie' : 'Ręcznie'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <CryoBeaker />
      </Window.Content>
    </Window>
  );
};

// AQUILA: własna sekcja zlewki zamiast common/BeakerDisplay z tg,
// bo nasz DM wysyła płaską listę i obsługuje akcję 'ejectbeaker'.
const CryoBeaker = () => {
  const { act, data } = useBackend<Data>();
  const {
    isBeakerLoaded,
    beakerContents = [],
    beakerCurrentVolume,
    beakerMaxVolume,
  } = data;

  return (
    <Section
      title="Zlewka"
      buttons={
        !!isBeakerLoaded && (
          <>
            {beakerMaxVolume !== undefined && (
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} u
              </Box>
            )}
            <Button icon="eject" onClick={() => act('ejectbeaker')}>
              Wyjmij
            </Button>
          </>
        )
      }
    >
      <Box color="label">
        {(!isBeakerLoaded && 'Brak zlewki') ||
          (beakerContents.length === 0 && 'Zlewka jest pusta')}
      </Box>
      {beakerContents.map((chemical) => (
        <Box key={chemical.name} color="label">
          <AnimatedNumber initial={0} value={chemical.volume} /> u{' '}
          {chemical.name}
        </Box>
      ))}
    </Section>
  );
};
