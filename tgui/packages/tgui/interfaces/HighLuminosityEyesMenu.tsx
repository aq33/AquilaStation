import {
  Button,
  ColorBox,
  Input,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: u nas oczy zawsze mają kolor światła (brak osobnego koloru
// lewego/prawego oka z tg), więc okno ma tylko kolor i zasięg.
type Data = {
  lightColor: string;
  range: number;
  maxRange: number;
};

const LightColorDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { lightColor } = data;
  return (
    <LabeledList.Item label="Kolor">
      <ColorBox color={lightColor} />{' '}
      <Button
        icon="palette"
        onClick={() => act('pick_color')}
        tooltip="Otwiera okno wyboru koloru światła."
      />
      <Button
        icon="dice"
        onClick={() => act('random_color')}
        tooltip="Losuje kolor światła."
      />
      <Input
        value={lightColor}
        width={6}
        maxLength={7}
        onBlur={(value) =>
          act('enter_color', {
            new_color: value,
          })
        }
      />
    </LabeledList.Item>
  );
};

const RangeDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { range, maxRange } = data;
  return (
    <LabeledList.Item label="Zasięg">
      <Button
        icon="minus-square-o"
        disabled={range <= 0}
        onClick={() => act('set_range', { new_range: range - 1 })}
        tooltip="Zmniejsza zasięg światła."
      />
      <Button
        icon="plus-square-o"
        disabled={range >= maxRange}
        onClick={() => act('set_range', { new_range: range + 1 })}
        tooltip="Zwiększa zasięg światła."
      />
      <NumberInput
        animated
        width="35px"
        step={1}
        stepPixelSize={5}
        value={range}
        minValue={0}
        maxValue={maxRange}
        onChange={(value) =>
          act('set_range', {
            new_range: value,
          })
        }
      />
    </LabeledList.Item>
  );
};

export const HighLuminosityEyesMenu = (props) => {
  return (
    <Window title="Oczy o wysokiej jasności" width={262} height={135}>
      <Window.Content>
        <Section fill title="Ustawienia">
          <LabeledList>
            <LightColorDisplay />
            <RangeDisplay />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
