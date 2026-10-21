import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  outfits: {
    name: string;
    ref: string;
  }[];
};

export const OutfitManager = (props) => {
  const { act, data } = useBackend<Data>();
  const { outfits } = data;
  return (
    <Window title="Menedżer strojów" width={300} height={300} theme="admin">
      <Window.Content>
        <Section
          fill
          scrollable
          title="Własne stroje"
          buttons={
            <>
              <Button
                icon="file-upload"
                tooltip="Wczytaj strój z pliku"
                tooltipPosition="left"
                onClick={() => act('load')}
              />
              <Button
                icon="copy"
                tooltip="Skopiuj istniejący strój"
                tooltipPosition="left"
                onClick={() => act('copy')}
              />
              <Button
                icon="plus"
                tooltip="Utwórz nowy strój"
                tooltipPosition="left"
                onClick={() => act('new')}
              />
            </>
          }
        >
          <Stack vertical>
            {outfits?.map((outfit) => (
              <Stack.Item key={outfit.ref}>
                <Stack>
                  <Stack.Item
                    grow={1}
                    shrink={1}
                    style={{
                      overflow: 'hidden',
                      whiteSpace: 'nowrap',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    <Button
                      fluid
                      ellipsis
                      onClick={() => act('edit', { outfit: outfit.ref })}
                    >
                      {outfit.name}
                    </Button>
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      icon="save"
                      tooltip="Zapisz strój do pliku"
                      tooltipPosition="left"
                      onClick={() => act('save', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                  <Stack.Item ml={0.5}>
                    <Button
                      color="bad"
                      icon="trash-alt"
                      tooltip="Usuń strój"
                      tooltipPosition="left"
                      onClick={() => act('delete', { outfit: outfit.ref })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
