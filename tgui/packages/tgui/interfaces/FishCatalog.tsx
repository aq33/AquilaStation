import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA EDIT - bez wskazówek wędkarskich, wagi, rozmiaru i piękna z tg
// (nie mamy wędkarstwa)
type FishInfo = {
  name: string;
  desc: string;
  fluid: string;
  temp_min: number;
  temp_max: number;
  feed: string;
  source: string;
  icon: string;
};

type FishCatalogData = {
  fish_info: FishInfo[] | null;
  sponsored_by: string;
};

export const FishCatalog = (props) => {
  const { data } = useBackend<FishCatalogData>();
  const { fish_info, sponsored_by } = data;
  const fish_by_name = sortBy(fish_info || [], [(fish: FishInfo) => fish.name]);
  const [currentFish, setCurrentFish] = useState<FishInfo | null>(null);
  return (
    <Window width={500} height={300}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="140px">
            <Section fill scrollable>
              {fish_by_name.map((f) => (
                <Button
                  key={f.name}
                  fluid
                  color="transparent"
                  selected={f === currentFish}
                  onClick={() => {
                    setCurrentFish(f);
                  }}
                >
                  {f.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title={
                currentFish
                  ? capitalize(currentFish.name)
                  : `Katalog ryb ${sponsored_by}`
              }
            >
              {currentFish && (
                <LabeledList>
                  <LabeledList.Item label="Opis">
                    {currentFish.desc}
                  </LabeledList.Item>
                  <LabeledList.Item label="Rodzaj wody">
                    {currentFish.fluid}
                  </LabeledList.Item>
                  <LabeledList.Item label="Temperatura">
                    od {currentFish.temp_min} do {currentFish.temp_max} K
                  </LabeledList.Item>
                  <LabeledList.Item label="Pokarm">
                    {currentFish.feed}
                  </LabeledList.Item>
                  <LabeledList.Item label="Skąd zdobyć">
                    {currentFish.source}
                  </LabeledList.Item>
                  <LabeledList.Item label="Ilustracja">
                    <Box className={classes(['fish32x32', currentFish.icon])} />
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
