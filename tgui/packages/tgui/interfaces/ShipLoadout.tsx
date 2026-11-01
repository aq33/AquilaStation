import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: any;
};

export const ShipLoadout = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="syndicate" width={500} height={500}>
      <Window.Content scrollable>
        <Section title="Informacje:">
          <p>
            Skan sieci energetycznej: zakończony. Urządzenie wykryło kilka
            niezasilanych podsystemów, ale rdzeń mocy może zasilić tylko jeden.
            Wybieraj rozważnie!
          </p>
        </Section>
        <Section title="Wykryte podsystemy:">
          {Object.keys(data.categories).map((key) => {
            let value = data.categories[key];
            return (
              <Section
                key={key}
                title={value.name}
                buttons={
                  <Button
                    content="Wybierz"
                    icon="check-circle"
                    onClick={() => act('select', { target_id: value.id })}
                  />
                }
              >
                <p>{value.desc}</p>
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
