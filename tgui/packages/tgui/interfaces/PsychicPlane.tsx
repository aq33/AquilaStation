import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  hives: any;
};

export const PsychicPlane = (props) => {
  const { act, data } = useBackend<Data>();
  const { hives = [] } = data;
  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>
        {hives.map((hive) => (
          <Section
            key={hive.hive}
            title={'Rój ' + hive.hive}
            buttons={
              <Button
                icon="brain"
                content="Śledź"
                color="good"
                onClick={() =>
                  act('track', {
                    hiveref: hive.hive,
                  })
                }
              />
            }
          >
            <LabeledList key={hive.hive}>
              <LabeledList.Item>{hive.type}</LabeledList.Item>
              <LabeledList.Item>Liczba naczyń: {hive.size}</LabeledList.Item>
              <LabeledList.Item>Ładunki: {hive.charges}</LabeledList.Item>
              <LabeledList.Item>
                Integracje: {hive.Integrations}
              </LabeledList.Item>
              <LabeledList.Item>
                Przebudzone naczynia: {hive.avessel_number}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
