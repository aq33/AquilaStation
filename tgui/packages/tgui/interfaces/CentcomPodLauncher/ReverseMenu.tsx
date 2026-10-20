import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { REVERSE_OPTIONS } from './constants';
import { useTab } from './hooks';
import type { PodLauncherData } from './types';

export function ReverseMenu(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const {
    customDropoff,
    effectReverse,
    picking_dropoff_turf,
    reverseOptionList,
  } = data;

  const [tab, setTab] = useTab();

  return (
    <Section
      buttons={
        <Button
          icon={effectReverse ? 'toggle-on' : 'toggle-off'}
          onClick={() => {
            act('effectReverse');
            if (tab === 2) {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }}
          selected={effectReverse}
          tooltip={`
            Nie wysyła przedmiotów.
            Po lądowaniu wraca do
            miejsca zrzutu (albo do
            zatoki, jeśli go nie ustawiono).`}
          tooltipPosition="bottom"
        />
      }
      fill
      title="Odwrót"
    >
      {!!effectReverse && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              disabled={!effectReverse}
              onClick={() => act('pickDropoffTurf')}
              selected={picking_dropoff_turf}
              tooltip={`
                Dokąd kapsuły odwrotne
                lecą po lądowaniu`}
              tooltipPosition="bottom-end"
            >
              Miejsce zrzutu
            </Button>
            <Button
              disabled={!customDropoff}
              icon="trash"
              inline
              onClick={() => {
                act('clearDropoffTurf');
                if (tab === 2) {
                  setTab(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }}
              tooltip={`
                Usuwa własne miejsce
                zrzutu. Kapsuły odwrotne
                wrócą wtedy do
                wybranej zatoki.`}
              tooltipPosition="bottom"
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                disabled={!effectReverse}
                key={i}
                icon={option.icon}
                inline
                onClick={() =>
                  act('reverseOption', {
                    reverseOption: option.key,
                  })
                }
                selected={!!reverseOptionList[option.key]}
                tooltip={option.title}
              />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}
