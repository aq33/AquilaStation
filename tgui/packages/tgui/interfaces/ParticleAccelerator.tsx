import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  assembled: any;
  power: any;
  strength: any;
};

export const ParticleAccelerator = (props) => {
  const { act, data } = useBackend<Data>();
  const { assembled, power, strength } = data;
  return (
    <Window width={350} height={185}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Stan"
              buttons={
                <Button
                  icon={'sync'}
                  content={'Skanuj'}
                  onClick={() => act('scan')}
                />
              }
            >
              <Box color={assembled ? 'good' : 'bad'}>
                {assembled
                  ? 'Gotowy – wszystkie części na miejscu'
                  : 'Nie wykryto wszystkich części'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Sterowanie akceleratorem cząstek">
          <LabeledList>
            <LabeledList.Item label="Zasilanie">
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? 'Wł.' : 'Wył.'}
                selected={power}
                disabled={!assembled}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Siła cząstek">
              <Button
                icon="backward"
                disabled={!assembled}
                onClick={() => act('remove_strength')}
              />{' '}
              {String(strength).padStart(1, '0')}{' '}
              <Button
                icon="forward"
                disabled={!assembled}
                onClick={() => act('add_strength')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
