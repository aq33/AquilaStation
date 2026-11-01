// NSV13

import { Fragment } from 'react';
import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  fighters: any;
  filter_types: any;
};

export const FighterController = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        <Section
          title="Ustawienia"
          buttons={
            <>
              <Button
                content="Przełącz bezpieczniki broni wszystkim"
                icon="bullseye"
                color="average"
                onClick={() => act('global_toggle')}
              />
              <Button
                content="KATAPULTUJ WSZYSTKICH PILOTÓW"
                icon="eject"
                color="bad"
                onClick={() => act('global_eject')}
              />
            </>
          }
        />
        <Section title="Filtry:">
          {Object.keys(data.filter_types).map((key) => {
            let value = data.filter_types[key];
            return (
              <Button
                key={key}
                content={`Widoczne: ${value.class}`}
                icon="eject"
                color={value.visible && 'green'}
                onClick={() => act('filter', { filter: value.class })}
              />
            );
          })}
        </Section>
        <Section title="Telemetria:">
          {Object.keys(data.fighters).map((key) => {
            let value = data.fighters[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name} - ${value.class}`}>
                  <Button
                    content="Katapultuj pilota"
                    icon="eject"
                    color={'average'}
                    onClick={() => act('eject', { target: value.name })}
                  />
                  <Button
                    content="Przełącz bezpieczniki"
                    icon="bullseye"
                    color={value.safeties && 'green'}
                    onClick={() =>
                      act('toggle_safeties', { target: value.name })
                    }
                  />
                  <Button
                    content="Przełącz dokowanie"
                    icon="anchor"
                    color={value.docking_mode && 'green'}
                    onClick={() =>
                      act('toggle_docking', { target: value.name })
                    }
                  />
                  <ProgressBar
                    value={(value.integrity / value.max_integrity) * 100 * 0.01}
                    ranges={{
                      good: [0.95, Infinity],
                      average: [0.15, 0.9],
                      bad: [-Infinity, 0.15],
                    }}
                  />
                </Section>
              </Fragment>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
