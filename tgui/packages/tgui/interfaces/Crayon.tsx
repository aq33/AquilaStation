import { Button, ColorBox, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  has_cap: BooleanLike;
  can_change_colour: BooleanLike;
  current_colour: string;
  drawables: Drawable[];
  is_capped: BooleanLike;
  selected_stencil: string;
  text_buffer: string;
};

type Drawable = {
  items: { item: string }[];
  name: string;
};

export const Crayon = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_cap,
    can_change_colour,
    current_colour,
    drawables = [],
    is_capped,
    selected_stencil,
    text_buffer,
  } = data;
  const capOrChanges = has_cap || can_change_colour;

  return (
    <Window width={600} height={600}>
      <Window.Content scrollable>
        {!!capOrChanges && (
          <Section title="Podstawowe">
            <LabeledList>
              {!!has_cap && (
                <LabeledList.Item label="Nakrętka">
                  <Button
                    icon={is_capped ? 'power-off' : 'times'}
                    selected={is_capped}
                    onClick={() => act('toggle_cap')}
                  >
                    {is_capped ? 'Założona' : 'Zdjęta'}
                  </Button>
                </LabeledList.Item>
              )}
              {!!can_change_colour && (
                <LabeledList.Item label="Kolor">
                  {!!current_colour && (
                    <ColorBox color={current_colour} mr={1} />
                  )}
                  <Button onClick={() => act('select_colour')}>
                    Wybierz kolor
                  </Button>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        )}
        <Section title="Szablon">
          <LabeledList>
            {drawables.map((drawable) => {
              const items = drawable.items || [];
              return (
                <LabeledList.Item key={drawable.name} label={drawable.name}>
                  {items.map((item) => (
                    <Button
                      key={item.item}
                      selected={item.item === selected_stencil}
                      onClick={() =>
                        act('select_stencil', {
                          item: item.item,
                        })
                      }
                    >
                      {item.item}
                    </Button>
                  ))}
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
        <Section title="Tekst">
          <LabeledList>
            <LabeledList.Item label="Bieżący tekst">
              {text_buffer}
            </LabeledList.Item>
          </LabeledList>
          <Button onClick={() => act('enter_text')}>Nowy tekst</Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
