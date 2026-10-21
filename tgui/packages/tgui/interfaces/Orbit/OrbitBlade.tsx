import { useContext } from 'react';
import {
  Button,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { OrbitContext } from '.';
import {
  DEPARTMENT2COLOR,
  HEALTH,
  VIEWMODE,
  VIEWMODE_NAMES,
} from './constants';
import { getDisplayName } from './helpers';
import { JobIcon } from './JobIcon';
import type { OrbitData } from './types';

/** Slide open menu with more info about the current observable */
export function OrbitBlade(props) {
  const { data } = useBackend<OrbitData>();
  const { orbiting } = data;

  const { setBladeOpen, realNameDisplay, setRealNameDisplay } =
    useContext(OrbitContext);

  return (
    <Stack vertical width="244px">
      <Stack.Item>
        <Section
          buttons={
            <Button
              color="bad"
              icon="times"
              onClick={() => setBladeOpen(false)}
            />
          }
          color="label"
          title="Ustawienia orbity"
        >
          Lista odświeża się sama co chwilę. Przycisk odświeżania wymusza
          natychmiastową aktualizację.
        </Section>
      </Stack.Item>
      <Stack.Item>
        <ViewModeSelector />
      </Stack.Item>
      <Stack.Item>
        <Section
          buttons={
            <Button
              color="transparent"
              icon="passport"
              selected={realNameDisplay}
              onClick={() => setRealNameDisplay(!realNameDisplay)}
            />
          }
          color="label"
          title="Prawdziwe imiona"
        >
          W tym trybie widać prawdziwe imiona postaci i prace z początku rundy
          zamiast danych z noszonego ID. Jeśli ktoś nie ma pracy z początku
          rundy, nadal widać ikonę pracy z jego ID.
        </Section>
      </Stack.Item>
      {!!orbiting && (
        <Stack.Item>
          <OrbitInfo />
        </Stack.Item>
      )}
    </Stack>
  );
}

function ViewModeSelector(props) {
  const { viewMode, setViewMode } = useContext(OrbitContext);

  return (
    <Section title="Tryb widoku">
      <Stack fill vertical>
        <Stack.Item color="label">
          Zmienia kolory i sortowanie pozycji na liście.
        </Stack.Item>

        {Object.entries(VIEWMODE).map(([key, value]) => (
          <Button
            align="center"
            color="transparent"
            fluid
            icon={value}
            key={key}
            onClick={() => setViewMode(value)}
            selected={value === viewMode}
          >
            {VIEWMODE_NAMES[key]}
          </Button>
        ))}
      </Stack>
    </Section>
  );
}

function OrbitInfo(props) {
  const { data } = useBackend<OrbitData>();

  const { orbiting } = data;
  if (!orbiting) return;

  const { name, full_name, health, job, department } = orbiting;

  let showAFK;
  if ('client' in orbiting && !orbiting.client) {
    showAFK = true;
  }

  return (
    <Section title="Orbitujesz">
      <Stack fill vertical>
        <Stack.Item>
          {toTitleCase(getDisplayName(full_name, name))}
          {showAFK && (
            <Tooltip content="Gracz jest AFK" position="bottom-start">
              <Icon ml={1} color="grey" name="bed" />
            </Tooltip>
          )}
        </Stack.Item>

        {!!job && (
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <JobIcon item={orbiting} realNameDisplay={false} />
              </Stack.Item>
              <Stack.Item color="label" grow>
                {job}
              </Stack.Item>
              {!!department && !!DEPARTMENT2COLOR[department] && (
                <Stack.Item color="grey">
                  {DEPARTMENT2COLOR[department].name}
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        )}
        {health !== undefined && (
          <Stack.Item>
            <HealthDisplay health={health} />
          </Stack.Item>
        )}

        <Stack.Item />
      </Stack>
    </Section>
  );
}

function HealthDisplay(props: { health: number }) {
  const { health } = props;

  let icon = 'heart';
  let howDead;
  switch (true) {
    case health <= HEALTH.Ruined:
      howDead = `Bardzo martwy: ${health}`;
      icon = 'skull';
      break;
    case health <= HEALTH.Dead:
      howDead = `Martwy: ${health}`;
      icon = 'heart-broken';
      break;
    case health <= HEALTH.Crit:
      howDead = `Stan krytyczny: ${health}`;
      icon = 'tired';
      break;
    case health <= HEALTH.Bad:
      howDead = `Źle: ${health}`;
      icon = 'heartbeat';
      break;
  }

  return (
    <Stack align="center">
      <Stack.Item>
        <Icon color="grey" name={icon} />
      </Stack.Item>
      <Stack.Item color={howDead && 'bad'} grow>
        {howDead || (
          <ProgressBar
            maxValue={100}
            minValue={0}
            ranges={{
              good: [70, Infinity],
              average: [20, HEALTH.Good],
              bad: [0, HEALTH.Average],
            }}
            value={health}
          />
        )}
      </Stack.Item>
    </Stack>
  );
}
