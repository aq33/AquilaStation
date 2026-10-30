// NSV13

import { Fragment } from 'react';
import { Box, Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  additional_weapon_info: any;
  weapons: any;
};

export const OrdnanceConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const tabIndex = 1;
  return (
    <Window theme="retro" width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section
            title="Uzbrojenie:"
            buttons={
              <Button
                icon="cog"
                color={data.additional_weapon_info ? 'good' : 'bad'}
                content="Więcej informacji"
                onClick={() => act('toggle_additional_weapon_info')}
              />
            }
          >
            {Object.keys(data.weapons).map((key) => {
              let value = data.weapons[key];
              return (
                <Fragment key={key}>
                  {!!value.maxammo && (
                    <Section title={`${value.name}`}>
                      <ProgressBar
                        value={(value.ammo / value.maxammo) * 100 * 0.01}
                        ranges={{
                          good: [0.95, Infinity],
                          average: [0.15, 0.9],
                          bad: [-Infinity, 0.15],
                        }}
                      />
                      {!!value.controllers && (
                        <Box>
                          <br />
                          {'Kontrolery broni: ' + value.controllers}
                        </Box>
                      )}
                      {!!value.ammo_filter && (
                        <Box>
                          <br />
                          {'Filtr amunicji: ' + value.ammo_filter}
                        </Box>
                      )}
                    </Section>
                  )}
                </Fragment>
              );
            })}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
