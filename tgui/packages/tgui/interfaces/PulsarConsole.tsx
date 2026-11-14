// AQUILA - konsola orbity pulsara (aquila/code/modules/power/pulsar.dm)
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  grid: number;
  pulsar: number;
  sat_x: number;
  sat_y: number;
  power: number;
  shield: number;
  shield_required: number;
  effective: number;
  effective_mw: number;
  has_tank: boolean;
  fuel: number;
  thrust_cost: number;
  decay_minutes: number;
  connected: boolean;
  storm_eta: number | null;
  storm_active: boolean;
  overcharge_eta: number | null;
  overcharge_active: boolean;
};

const CELL = 17;
const BEAM = '#82C2D8';

// Kierunki BYOND
const NORTH = 1;
const SOUTH = 2;
const EAST = 4;
const WEST = 8;

const cellColor = (x: number, y: number, pulsar: number) => {
  if (Math.abs(x - pulsar) <= 1 && Math.abs(y - pulsar) <= 1) {
    return '#f5f0c8';
  }
  if (x === y) {
    return BEAM;
  }
  if (Math.abs(x - y) === 1) {
    return 'rgba(130, 194, 216, 0.4)';
  }
  return 'rgba(0, 0, 0, 0.5)';
};

const OrbitMap = (props) => {
  const { data } = useBackend<Data>();
  const { grid, pulsar, sat_x, sat_y } = data;
  const rows: number[] = [];
  for (let y = grid; y >= 1; y--) {
    rows.push(y);
  }
  const columns: number[] = [];
  for (let x = 1; x <= grid; x++) {
    columns.push(x);
  }
  return (
    <Box
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${grid}, ${CELL}px)`,
        gap: '1px',
        width: 'fit-content',
        margin: '0 auto',
      }}
    >
      {rows.map((y) =>
        columns.map((x) => (
          <Box
            key={`${x}-${y}`}
            width={`${CELL}px`}
            height={`${CELL}px`}
            textAlign="center"
            style={{
              backgroundColor: cellColor(x, y, pulsar),
              lineHeight: `${CELL}px`,
            }}
          >
            {x === sat_x && y === sat_y && (
              <Icon name="satellite" color="#ffb347" size={0.9} />
            )}
          </Box>
        )),
      )}
    </Box>
  );
};

export const PulsarConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    power,
    shield,
    shield_required,
    effective,
    effective_mw,
    has_tank,
    fuel,
    thrust_cost,
    decay_minutes,
    connected,
    storm_eta,
    storm_active,
    overcharge_eta,
    overcharge_active,
  } = data;
  return (
    <Window width={720} height={480}>
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <Section title="Orbita satelity" fill>
              <OrbitMap />
              <Stack mt={1} justify="center">
                <Stack.Item>
                  <Button
                    icon="arrow-left"
                    onClick={() => act('move', { dir: WEST })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="arrow-up"
                    onClick={() => act('move', { dir: NORTH })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="arrow-down"
                    onClick={() => act('move', { dir: SOUTH })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="arrow-right"
                    onClick={() => act('move', { dir: EAST })}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Moc i osłona" fill>
              {!connected && (
                <NoticeBox>
                  Mostek mocy jest rozłączony: pulsar nie zasila okrętu, ale też
                  nie grozi burzą ani przeciążeniem.
                </NoticeBox>
              )}
              {storm_active && (
                <NoticeBox danger>
                  Burza promieniowania! Wyprowadź satelitę z głównej wiązki.
                </NoticeBox>
              )}
              {storm_eta !== null && (
                <NoticeBox danger>
                  Satelita w głównej wiązce: burza za {storm_eta} s.
                </NoticeBox>
              )}
              {overcharge_active && (
                <NoticeBox danger>
                  Przeciążenie! Podnieś osłonę, żeby zamknąć szczeliny.
                </NoticeBox>
              )}
              {overcharge_eta !== null && (
                <NoticeBox danger>
                  Za słaba osłona: przeciążenie za {overcharge_eta} s.
                </NoticeBox>
              )}
              <LabeledList>
                <LabeledList.Item label="Moc pulsara">
                  {power}%
                </LabeledList.Item>
                <LabeledList.Item label="Wymagana osłona">
                  {shield_required}%
                </LabeledList.Item>
                <LabeledList.Item label="Osłona">
                  <Slider
                    minValue={0}
                    maxValue={99}
                    step={1}
                    value={shield}
                    unit="%"
                    color={shield < shield_required ? 'bad' : 'good'}
                    onChange={(_, value) => act('set_shield', { value })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Moc do mostka">
                  <ProgressBar
                    value={effective / 100}
                    maxValue={1.5}
                    ranges={{
                      good: [0.3, Infinity],
                      average: [0.1, 0.3],
                      bad: [-Infinity, 0.1],
                    }}
                  >
                    {Math.round(effective)}% ({effective_mw} MW)
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Rozpad orbity">
                  za {decay_minutes} min
                </LabeledList.Item>
                <LabeledList.Item
                  label="Paliwo"
                  buttons={
                    <Button icon="search" onClick={() => act('scan_tank')}>
                      Szukaj zbiornika
                    </Button>
                  }
                >
                  {has_tank ? (
                    <>
                      {fuel} moli, ruch kosztuje {thrust_cost} moli
                    </>
                  ) : (
                    <Box color="bad">Brak zbiornika w pomieszczeniu</Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
              <Box color="label" mt={1}>
                Bliżej gwiazdy jest więcej mocy, ale potrzeba mocniejszej
                osłony. Tuż przy wiązce moc rośnie do 150%. Satelita w głównej
                wiązce ściąga na okręt burzę promieniowania.
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
