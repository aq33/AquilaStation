import { Button, ProgressBar, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  auto_spool_enabled: any;
  await_emergency_ftl_confirm: any;
  can_auto_spool: any;
  goal: any;
  jumping: any;
  powered: any;
  progress: any;
  pylons: any;
};

// AQUILA: PYLON_STATE_* z DM to klucze, tłumaczymy tylko napis
const PYLON_STATUS_NAMES: Record<string, string> = {
  offline: 'wyłączony',
  shutdown: 'zatrzymany',
  starting: 'uruchamianie',
  warmup: 'rozgrzewanie',
  spooling: 'rozkręcanie',
  active: 'aktywny',
};

export const FTLComputerModular = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window
      theme={data.await_emergency_ftl_confirm ? 'malfunction' : 'hackerman'}
      width={600}
      height={550}
    >
      <Window.Content scrollable>
        {(data.await_emergency_ftl_confirm && (
          <Section>
            <Section title="NADPISANIE">
              <Button
                icon="exclamation-triangle"
                fluid
                color="red"
                onClick={() => act('emergency_jump')}
                content="POTWIERDZIĆ SKOK AWARYJNY?"
              />
            </Section>
          </Section>
        )) || (
          <Section>
            <Section title="Sterowanie pylonami:">
              <Table.Row>
                {Object.keys(data.pylons).map((key) => {
                  let value = data.pylons[key];
                  return (
                    <Table.Cell key={key}>
                      <Section title={`${value.name}`}>
                        <Button
                          content="Przełącz zasilanie"
                          icon="power-off"
                          color={
                            value.status === 'shutdown'
                              ? 'average'
                              : value.status === 'offline'
                                ? 'bad'
                                : 'good'
                          }
                          disabled={value.status === 'shutdown'}
                          onClick={() => act('pylon_power', { id: value.id })}
                        />
                        <Button
                          content={
                            value.shielded ? 'Otwórz osłonę' : 'Zamknij osłonę'
                          }
                          icon="exclamation-triangle"
                          color={value.shielded && 'average'}
                          onClick={() => act('toggle_shield', { id: value.id })}
                        />
                        <br />
                        Stan cyklu:{' '}
                        <b>
                          {PYLON_STATUS_NAMES[value.status] || value.status}
                        </b>
                        <br />
                        <br />
                        Prędkość żyroskopu:
                        <ProgressBar
                          value={value.gyro}
                          ranges={{
                            good: [1, 2],
                            average: [0.5, 0.99],
                            bad: [0, 0.49],
                          }}
                        />
                        <br />
                        Ładunek kondensatora:
                        <ProgressBar
                          value={value.capacitor}
                          ranges={{
                            good: [1, 2],
                            average: [0.5, 0.99],
                            bad: [0, 0.49],
                          }}
                        />
                        <br />
                        Pobór mocy: <b>{value.draw}</b>
                        <br />
                        Nucleium: <b>{value.nucleium}</b> mol
                        {value.nucleium !== 1 ? 's' : ''} / s
                      </Section>
                    </Table.Cell>
                  );
                })}
              </Table.Row>
              <Button
                content="Znajdź pylony"
                icon="search"
                onClick={() => act('find_pylons')}
              />
            </Section>
            <Section title="Sterowanie kolektorem:">
              <Button
                color={!!data.powered && 'green'}
                disabled={data.jumping || !data.pylons.length}
                content={data.progress ? 'Wyłącz napęd' : 'Rozkręć napęd'}
                onClick={() => act('toggle_power')}
              />
              <Button
                color={!!data.auto_spool_enabled && 'green'}
                disabled={!data.can_auto_spool}
                content={
                  data.auto_spool_enabled
                    ? 'Wyłącz autorozkręcanie'
                    : 'Włącz autorozkręcanie'
                }
                onClick={() => act('toggle_autospool')}
              />
            </Section>
            <Section title="Rozkręcanie FTL:">
              <ProgressBar
                value={data.progress / data.goal}
                ranges={{
                  good: [0.95, Infinity],
                  average: [0.15, 0.95],
                  bad: [-Infinity, 0.15],
                }}
              />
            </Section>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
