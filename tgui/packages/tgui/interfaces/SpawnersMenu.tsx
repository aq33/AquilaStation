import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  spawners: Spawner[];
};

type Spawner = {
  name: string;
  amount_left: number;
  infinite: BooleanLike;
} & Partial<{
  desc: string;
  short_desc: string;
  flavor_text: string;
  important_info: string;
}>;

export const SpawnersMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { spawners = [] } = data;

  return (
    <Window title="Menu spawnerów" width={700} height={525}>
      <Window.Content scrollable>
        <Stack vertical>
          {spawners.map((spawner) => (
            <Stack.Item key={spawner.name}>
              <Section
                fill
                title={capitalizeAll(spawner.name)}
                buttons={
                  <Stack>
                    <Stack.Item fontSize="14px" color="green">
                      {spawner.infinite
                        ? 'Bez limitu'
                        : `Zostało: ${spawner.amount_left}`}
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        onClick={() =>
                          act('jump', {
                            name: spawner.name,
                          })
                        }
                      >
                        Skocz
                      </Button>
                      <Button
                        onClick={() =>
                          act('spawn', {
                            name: spawner.name,
                          })
                        }
                      >
                        Odródź się
                      </Button>
                    </Stack.Item>
                  </Stack>
                }
              >
                <LabeledList>
                  {spawner.desc ? (
                    <LabeledList.Item label="Opis">
                      {spawner.desc}
                    </LabeledList.Item>
                  ) : (
                    <>
                      <LabeledList.Item label="Pochodzenie">
                        {spawner.short_desc || 'Nieznane'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Wytyczne">
                        {spawner.flavor_text || 'Brak'}
                      </LabeledList.Item>
                      <LabeledList.Item color="bad" label="Warunki">
                        {spawner.important_info || 'Brak'}
                      </LabeledList.Item>
                    </>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
