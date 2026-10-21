import { LabeledList, NumberInput } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  chem_temp: number;
  target_temperature: number;
  max_volume: number;
  acclimate_state: number;
};

const States = ['Napełnianie', 'Grzanie', 'Chłodzenie', 'Opróżnianie'] as const;

export const ChemAcclimator = (props) => {
  const { act, data } = useBackend<Data>();
  const { chem_temp, target_temperature, max_volume, acclimate_state } = data;

  return (
    <Window width={340} height={130}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Obecna temperatura">
            {chem_temp} K
          </LabeledList.Item>
          <LabeledList.Item label="Docelowa temperatura">
            <NumberInput
              value={target_temperature}
              unit="K"
              width="59px"
              minValue={1}
              maxValue={1000}
              step={5}
              stepPixelSize={2}
              onChange={(value) =>
                act('set_target_temperature', {
                  temperature: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Bufor">
            <NumberInput
              value={max_volume}
              unit="u"
              width="50px"
              minValue={1}
              maxValue={200}
              step={2}
              stepPixelSize={2}
              onChange={(value) =>
                act('change_volume', {
                  volume: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Stan">
            {States[acclimate_state]}
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
