import {
  Button,
  Dropdown,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  buffered_mass: any;
  current_capacity: any;
  current_direction: any;
  ideal_capacity: any;
  inFlight: any;
  max_size: any;
  name: any;
  preferred_direction: any;
  shuttleId: any;
  shuttle_mass: any;
};

export const ShuttleDesignator = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    shuttleId = null,
    inFlight = false,
    name = null,
    shuttle_mass = 0,
    buffered_mass = 0,
    current_capacity = 0,
    ideal_capacity = 0,
    max_size = 0,
    current_direction = null,
    preferred_direction = null,
  } = data;

  const directions = ['North', 'South', 'East', 'West'];
  // AQUILA: kierunki idą do DM, tłumaczymy tylko napis
  const DIRECTION_NAMES = {
    North: 'Północ',
    South: 'Południe',
    East: 'Wschód',
    West: 'Zachód',
  };
  const directionOptions = directions.map((dir) => ({
    value: dir,
    displayText: DIRECTION_NAMES[dir],
  }));

  return (
    <Window width={500} height={500}>
      <Window.Content />
      {shuttleId && (
        <Section title="Informacje o promie">
          Nazwa promu: {name}
          <br />
          Masa promu: {shuttle_mass / 10} t
          <br />
          Masa w buforze: {buffered_mass / 10} t
          <br />
          Obecna ładowność: {current_capacity / 10} t
          <br />
          Idealna ładowność: {ideal_capacity / 10} t
        </Section>
      )}
      <Section title="Wyznaczanie promu">
        {inFlight ? (
          <NoticeBox color="Red">
            Prom w locie, wyznaczanie niedostępne.
          </NoticeBox>
        ) : (
          <>
            {!!shuttleId || (
              <NoticeBox color="yellow">No linked shuttle.</NoticeBox>
            )}
            Pojemność bufora:
            <ProgressBar
              value={buffered_mass / max_size}
              ranges={{
                good: [-Infinity, current_capacity / max_size],
                average: [
                  current_capacity / max_size,
                  ideal_capacity / max_size,
                ],
                bad: [ideal_capacity / max_size, Infinity],
              }}
            />
            <Button
              content="Wyznacz obszar"
              textAlign="center"
              onClick={() => act('designate')}
            />
          </>
        )}
      </Section>
      {shuttleId && !inFlight && (
        <Section title="Konfiguracja promu">
          Obecny kierunek:
          <Dropdown
            selected={current_direction}
            displayText={
              DIRECTION_NAMES[current_direction] || current_direction
            }
            options={directionOptions}
            onSelected={(dir) => act('current_direction', { direction: dir })}
          />
          Kierunek lotu:
          <Dropdown
            selected={preferred_direction}
            displayText={
              DIRECTION_NAMES[preferred_direction] || preferred_direction
            }
            options={directionOptions}
            onSelected={(dir) => act('preferred_direction', { direction: dir })}
          />
        </Section>
      )}
    </Window>
  );
};
