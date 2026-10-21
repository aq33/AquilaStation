import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Chem = {
  name: string;
  id: string;
  allowed: BooleanLike;
};

type Occupant = {
  name?: string;
  stat?: string;
  statstate?: string;
  health: number;
  maxHealth: number;
  minHealth: number;
  bruteLoss: number;
  oxyLoss: number;
  toxLoss: number;
  fireLoss: number;
  cloneLoss: number;
  brainLoss: number;
  reagents: { name: string; volume: number }[];
};

type Data = {
  chems: Chem[];
  occupant: Occupant;
  occupied: BooleanLike;
  open: BooleanLike;
};

const damageTypes = [
  {
    label: 'Obrażenia',
    type: 'bruteLoss',
  },
  {
    label: 'Oparzenia',
    type: 'fireLoss',
  },
  {
    label: 'Toksyny',
    type: 'toxLoss',
  },
  {
    label: 'Niedotlenienie',
    type: 'oxyLoss',
  },
] as const;

// Stan pacjenta przychodzi z DM po angielsku
const STAT_LABELS = {
  Conscious: 'Przytomny',
  Unconscious: 'Nieprzytomny',
  Dead: 'Martwy',
};

export const Sleeper = (props) => {
  const { act, data } = useBackend<Data>();

  const { open, occupied } = data;
  const occupant = data.occupant || ({} as Occupant);

  const chems = [...(data.chems || [])].sort((a, b) =>
    a.name.toLowerCase().localeCompare(b.name.toLowerCase()),
  );

  return (
    <Window width={310} height={520}>
      <Window.Content>
        <Section
          title={occupant.name ? occupant.name : 'Brak pacjenta'}
          minHeight="250px"
          buttons={
            !!occupant.stat && (
              <Box inline bold color={occupant.statstate}>
                {STAT_LABELS[occupant.stat] || occupant.stat}
              </Box>
            )
          }
        >
          {!!occupied && (
            <>
              <ProgressBar
                value={occupant.health}
                minValue={occupant.minHealth}
                maxValue={occupant.maxHealth}
                ranges={{
                  good: [50, Infinity],
                  average: [0, 50],
                  bad: [-Infinity, 0],
                }}
              />
              <Box mt={1} />
              <LabeledList>
                {damageTypes.map((type) => (
                  <LabeledList.Item key={type.type} label={type.label}>
                    <ProgressBar
                      value={occupant[type.type]}
                      minValue={0}
                      maxValue={occupant.maxHealth}
                      color="bad"
                    />
                  </LabeledList.Item>
                ))}
                <LabeledList.Item
                  label="Komórki"
                  color={occupant.cloneLoss ? 'bad' : 'good'}
                >
                  {occupant.cloneLoss ? 'Uszkodzone' : 'Zdrowe'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Mózg"
                  color={occupant.brainLoss ? 'bad' : 'good'}
                >
                  {occupant.brainLoss ? 'Nieprawidłowy' : 'Zdrowy'}
                </LabeledList.Item>
                <LabeledList.Item label="Odczynniki">
                  <Box color="label">
                    {(occupant.reagents || []).length === 0 && '—'}
                    {(occupant.reagents || []).map((chemical) => (
                      <Box key={chemical.name}>
                        {`${chemical.name}: `}
                        <AnimatedNumber
                          value={chemical.volume}
                          format={(value) => toFixed(value, 1)}
                        />
                        {' u'}
                      </Box>
                    ))}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </>
          )}
        </Section>
        <Section
          title="Leki"
          minHeight="205px"
          buttons={
            <Button
              icon={open ? 'door-open' : 'door-closed'}
              onClick={() => act('door')}
            >
              {open ? 'Otwarta' : 'Zamknięta'}
            </Button>
          }
        >
          {chems.map((chem) => (
            <Button
              key={chem.name}
              icon="flask"
              disabled={!occupied || !chem.allowed}
              width="140px"
              onClick={() =>
                act('inject', {
                  chem: chem.id,
                })
              }
            >
              {chem.name}
            </Button>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
