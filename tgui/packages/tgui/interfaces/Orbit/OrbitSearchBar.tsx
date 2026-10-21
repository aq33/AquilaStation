import { useContext } from 'react';
import { Button, Icon, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { OrbitContext } from '.';
import { VIEWMODE, VIEWMODE_NAMES } from './constants';
import { isJobCkeyOrNameMatch, sortByOrbiters } from './helpers';
import type { OrbitData } from './types';

/** Search bar for the orbit ui. Has a few buttons to switch between view modes and auto-observe */
export function OrbitSearchBar(props) {
  const {
    autoObserve,
    bladeOpen,
    realNameDisplay,
    searchQuery,
    viewMode,
    setAutoObserve,
    setBladeOpen,
    setRealNameDisplay,
    setSearchQuery,
    setViewMode,
  } = useContext(OrbitContext);

  const { act, data } = useBackend<OrbitData>();

  /** Gets a list of Observables, then filters the most relevant to orbit */
  function orbitMostRelevant() {
    const mostRelevant = [
      data.alive,
      data.antagonists,
      data.critical,
      data.deadchat_controlled,
      data.dead,
      data.ghosts,
      data.misc,
      data.npcs,
    ]
      .flat()
      .filter((observable) => isJobCkeyOrNameMatch(observable, searchQuery))
      .sort(sortByOrbiters)[0];

    if (mostRelevant !== undefined) {
      act('orbit', {
        ref: mostRelevant.ref,
        auto_observe: autoObserve,
      });
    }
  }

  /** Iterates through the view modes and switches to the next one */
  function swapViewMode() {
    const thisIndex = Object.values(VIEWMODE).indexOf(viewMode);
    const nextIndex = (thisIndex + 1) % Object.values(VIEWMODE).length;

    setViewMode(Object.values(VIEWMODE)[nextIndex]);
  }

  const viewModeTitle = Object.entries(VIEWMODE).find(
    ([_key, value]) => value === viewMode,
  )?.[0];

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Icon name="search" />
        </Stack.Item>
        <Stack.Item grow>
          <Input
            autoFocus
            fluid
            onEnter={orbitMostRelevant}
            onChange={setSearchQuery}
            placeholder="Szukaj..."
            value={searchQuery}
            expensive
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Button
            color="transparent"
            icon={viewMode}
            onClick={swapViewMode}
            tooltip={`Kolory: ${viewModeTitle ? VIEWMODE_NAMES[viewModeTitle] : ''}`}
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        {!!data.can_observe && (
          <Stack.Item>
            <Button
              color={autoObserve ? 'good' : 'transparent'}
              icon={autoObserve ? 'toggle-on' : 'toggle-off'}
              onClick={() => setAutoObserve(!autoObserve)}
              tooltip={`Automatyczna obserwacja. Po włączeniu widzisz
            interfejs i ekwipunek tego, kogo orbitujesz.`}
              tooltipPosition="bottom-start"
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            color="transparent"
            icon="sync-alt"
            onClick={() => act('refresh')}
            tooltip="Odśwież"
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="passport"
            onClick={() => setRealNameDisplay(!realNameDisplay)}
            selected={realNameDisplay}
            tooltip="Prawdziwe imiona. Po włączeniu orbita pokazuje prawdziwe
            imiona zamiast przebrań."
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="sliders-h"
            onClick={() => setBladeOpen(!bladeOpen)}
            selected={bladeOpen}
            tooltip="Panel ustawień"
            tooltipPosition="left-end"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
