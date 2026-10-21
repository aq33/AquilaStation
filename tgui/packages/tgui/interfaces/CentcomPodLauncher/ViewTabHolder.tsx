import { Button, ByondUi, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { POD_GREY, TABPAGES } from './constants';
import { useTab } from './hooks';
import type { PodLauncherData } from './types';

export function ViewTabHolder(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { mapRef, customDropoff, effectReverse, renderLighting } = data;

  const [tab, setTab] = useTab();

  const TabPageComponent = TABPAGES[tab].component;

  return (
    <Section
      buttons={
        <>
          {!!customDropoff && !!effectReverse && (
            <Button
              color="transparent"
              icon="arrow-circle-down"
              inline
              onClick={() => {
                setTab(2);
                act('tabSwitch', { tabIndex: 2 });
              }}
              selected={tab === 2}
              tooltip="Podgląd miejsca zrzutu"
            />
          )}
          <Button
            color="transparent"
            icon="rocket"
            inline
            onClick={() => {
              setTab(0);
              act('tabSwitch', { tabIndex: 0 });
            }}
            selected={tab === 0}
            tooltip="Podgląd kapsuły"
          />
          <Button
            color="transparent"
            icon="th"
            inline
            onClick={() => {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }}
            selected={tab === 1}
            tooltip="Podgląd zatoki źródłowej"
          />
          <span style={POD_GREY}>|</span>
          {/* Z Bee: tg usunął ten przycisk, nasz DM nadal obsługuje renderLighting */}
          {!!customDropoff && !!effectReverse && (
            <Button
              color="transparent"
              icon="lightbulb"
              inline
              onClick={() => {
                act('renderLighting');
                act('refreshView');
              }}
              selected={renderLighting}
              tooltip="Pokaż oświetlenie w podglądzie miejsca zrzutu"
            />
          )}
          <Button
            color="transparent"
            icon="sync-alt"
            inline
            onClick={() => {
              setTab(tab);
              act('refreshView');
            }}
            tooltip="Odśwież podgląd, jeśli się zepsuje"
          />
        </>
      }
      fill
      title="Podgląd"
    >
      <Stack fill vertical>
        <Stack.Item>
          <TabPageComponent />
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            params={{
              id: mapRef,
              type: 'map',
              zoom: 0,
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
