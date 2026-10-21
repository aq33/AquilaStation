// AQUILA - konsola promu (aquila/code/modules/shuttle/shuttle_console_ui.dm)
// Wygląd z tg, dane i akcje nasze: lista celów z DM, własne lądowisko, prośba o autoryzację.
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Destination = {
  id: string;
  name: string;
};

type Data = {
  shuttle_name: string | null;
  status: string | null;
  mode: string | null;
  timer_str: string | null;
  custom_landing: BooleanLike;
  admin_controlled: BooleanLike;
  can_request: BooleanLike;
  destinations: Destination[];
};

// Klucze to wartości SHUTTLE_* z code/__DEFINES/shuttles.dm
const MODE_LABELS: Record<string, [string, string]> = {
  idle: ['Bezczynny', 'average'],
  igniting: ['Rozruch', 'average'],
  called: ['W locie', 'good'],
  recalled: ['W locie', 'good'],
  docked: ['Zadokowany', 'good'],
  stranded: ['Unieruchomiony', 'bad'],
  escape: ['Ewakuacja', 'good'],
  recharging: ['Ładowanie', 'average'],
  landing: ['Lądowanie', 'good'],
};

export const ShuttleConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    shuttle_name,
    status,
    mode,
    timer_str,
    custom_landing,
    admin_controlled,
    can_request,
    destinations = [],
  } = data;
  const [selected, setSelected] = useState<string | null>(null);
  const locked = destinations.length === 0 && !custom_landing;
  const [modeLabel, modeColor] = (mode && MODE_LABELS[mode]) || [
    'Niedostępny',
    'bad',
  ];
  const selectedDestination =
    destinations.length === 1
      ? destinations[0]
      : destinations.find((destination) => destination.id === selected);

  return (
    <Window width={350} height={290}>
      <Window.Content scrollable>
        <Section title={shuttle_name || 'Prom'}>
          <Box bold fontSize="26px" textAlign="center" fontFamily="monospace">
            {timer_str || '00:00'}
          </Box>
          <Box textAlign="center" fontSize="14px" mb={1}>
            <Box inline bold>
              STAN:
            </Box>
            <Box inline color={status ? modeColor : 'bad'} ml={1}>
              {status ? modeLabel : 'Brak połączenia z promem'}
            </Box>
          </Box>
          {!!status && (
            <Section title="Sterowanie promem">
              {locked && (
                <NoticeBox danger>
                  Prom zablokowany
                  {!!admin_controlled && ' — tylko dla upoważnionego personelu'}
                </NoticeBox>
              )}
              <LabeledList>
                <LabeledList.Item label="Położenie">{status}</LabeledList.Item>
                <LabeledList.Item label="Cel">
                  {(destinations.length === 0 && (
                    <Box color="bad">Brak dostępnych celów</Box>
                  )) ||
                    (destinations.length === 1 && (
                      <Box color="average">{destinations[0].name}</Box>
                    )) || (
                      <Dropdown
                        width="100%"
                        options={destinations.map(
                          (destination) => destination.name,
                        )}
                        selected={selectedDestination?.name || 'Wybierz cel'}
                        onSelected={(value) =>
                          setSelected(
                            destinations.find(
                              (destination) => destination.name === value,
                            )?.id || null,
                          )
                        }
                      />
                    )}
                </LabeledList.Item>
              </LabeledList>
              <Button
                fluid
                mt={1}
                icon="arrow-up"
                textAlign="center"
                disabled={!selectedDestination}
                onClick={() =>
                  selectedDestination &&
                  act('move', { id: selectedDestination.id })
                }
              >
                Odlot
              </Button>
              {!!custom_landing && (
                <Button
                  fluid
                  mt={0.5}
                  icon="map-marker-alt"
                  textAlign="center"
                  onClick={() => act('designate')}
                >
                  Wyznacz miejsce lądowania
                </Button>
              )}
              {locked && !!admin_controlled && !!can_request && (
                <Button
                  fluid
                  mt={0.5}
                  icon="arrow-circle-right"
                  color="bad"
                  textAlign="center"
                  onClick={() => act('request')}
                >
                  Poproś o autoryzację
                </Button>
              )}
            </Section>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
