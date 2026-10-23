// AQUILA - magnes na asteroidy (aquila/code/modules/mining/mineral_magnet_ui.dm)
import {
  Box,
  Button,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Asteroid = {
  name: string;
  ref: string;
  ores: string[];
};

type Wreck = {
  name: string;
  ref: string;
};

type Data = {
  cooldown: boolean;
  has_asteroid: boolean;
  asteroids: Asteroid[];
  has_wreck: boolean;
  wreck_name: string | null;
  wreck_health: number | null;
  wrecks: Wreck[];
};

export const AsteroidMagnet = (_) => {
  const { act, data } = useBackend<Data>();
  const {
    cooldown,
    has_asteroid,
    asteroids = [],
    has_wreck,
    wreck_name,
    wreck_health,
    wrecks = [],
  } = data;
  return (
    <Window width={440} height={420}>
      <Window.Content scrollable>
        {!!cooldown && (
          <NoticeBox>Obwody magnesu się ładują, poczekaj chwilę.</NoticeBox>
        )}
        {has_wreck ? (
          <Section title="Wrak w klatce">
            <Box mb={1}>
              {wreck_name}. Rozbierz go młotem i spawarką, a złom zanieś do
              recyklera.
            </Box>
            <ProgressBar
              mb={1}
              value={(wreck_health ?? 0) / 100}
              ranges={{
                good: [0.66, Infinity],
                average: [0.33, 0.66],
                bad: [-Infinity, 0.33],
              }}
            >
              Zostało {wreck_health ?? 0}% wraku
            </ProgressBar>
            <Button.Confirm
              fluid
              icon="trash"
              color="bad"
              disabled={cooldown}
              confirmContent="Na pewno? Wszystko w klatce zniknie"
              onClick={() => act('push')}
            >
              Wypchnij wrak
            </Button.Confirm>
          </Section>
        ) : has_asteroid ? (
          <Section title="Asteroida w klatce">
            <Box mb={1}>
              Asteroida jest przyciągnięta. Zanim ją wypchniesz, upewnij się, że
              nikt nie został w klatce.
            </Box>
            <Button.Confirm
              fluid
              icon="meteor"
              color="bad"
              disabled={cooldown}
              confirmContent="Na pewno? Kliknij jeszcze raz"
              onClick={() => act('push')}
            >
              Wypchnij asteroidę
            </Button.Confirm>
          </Section>
        ) : (
          <>
            <Section title="Wraki w zasięgu">
              {wrecks.length === 0 && (
                <Box color="label">
                  W pobliżu nie ma wraków. Zostają po zestrzelonych okrętach.
                </Box>
              )}
              {wrecks.map((wreck) => (
                <Box key={wreck.ref} mb={0.5}>
                  <Button
                    icon="magnet"
                    disabled={cooldown}
                    onClick={() => act('pull_wreck', { ref: wreck.ref })}
                  >
                    Przyciągnij
                  </Button>{' '}
                  {wreck.name}
                </Box>
              ))}
            </Section>
            <Section title="Asteroidy w zasięgu">
              {asteroids.length === 0 && (
                <Box color="label">
                  W pobliżu statku nie ma asteroid. Podleć bliżej któregoś pola.
                </Box>
              )}
              {asteroids.length > 0 && (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Asteroida</Table.Cell>
                    <Table.Cell>Skład rdzenia</Table.Cell>
                    <Table.Cell collapsing />
                  </Table.Row>
                  {asteroids.map((asteroid) => (
                    <Table.Row key={asteroid.ref} className="candystripe">
                      <Table.Cell>{asteroid.name}</Table.Cell>
                      <Table.Cell color="label">
                        {asteroid.ores.join(', ')}
                      </Table.Cell>
                      <Table.Cell collapsing>
                        <Button
                          icon="magnet"
                          disabled={cooldown}
                          onClick={() => act('pull', { ref: asteroid.ref })}
                        >
                          Przyciągnij
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
