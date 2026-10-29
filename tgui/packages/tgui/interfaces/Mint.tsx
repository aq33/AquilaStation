import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  chosen_material: any;
  inserted_materials: any;
  processing: any;
  produced_coins: any;
};

export const Mint = (props) => {
  const { act, data } = useBackend<Data>();
  const inserted_materials = data.inserted_materials || [];
  return (
    <Window width={300} height={250}>
      <Window.Content>
        <Section
          title="Materiały"
          buttons={
            <Button
              icon={data.processing ? 'times' : 'power-off'}
              content={data.processing ? 'Zatrzymaj' : 'Uruchom'}
              selected={data.processing}
              onClick={() => act(data.processing ? 'stoppress' : 'startpress')}
            />
          }
        >
          <LabeledList>
            {inserted_materials.map((material) => (
              <LabeledList.Item
                key={material.material}
                label={material.material}
                buttons={
                  <Button.Checkbox
                    checked={data.chosen_material === material.material}
                    onClick={() =>
                      act('changematerial', {
                        material_name: material.material,
                      })
                    }
                  />
                }
              >
                {material.amount} cm³
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section>Monety wybite w tym cyklu: {data.produced_coins}.</Section>
      </Window.Content>
    </Window>
  );
};
