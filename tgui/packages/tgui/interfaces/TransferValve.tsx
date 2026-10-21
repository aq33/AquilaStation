import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  tank_one: string | null;
  tank_two: string | null;
  attached_device: string | null;
  valve: BooleanLike;
};

export const TransferValve = (props) => {
  const { act, data } = useBackend<Data>();
  const { tank_one, tank_two, attached_device, valve } = data;
  return (
    <Window width={310} height={300}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Zawór">
              <Button
                icon={valve ? 'unlock' : 'lock'}
                content={valve ? 'Otwarty' : 'Zamknięty'}
                disabled={!tank_one || !tank_two}
                onClick={() => act('toggle')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Urządzenie na zaworze"
          buttons={
            <Button
              content="Konfiguruj"
              icon="cog"
              disabled={!attached_device}
              onClick={() => act('device')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Podpięte">
              {attached_device ? (
                <Button
                  icon="eject"
                  content={attached_device}
                  onClick={() => act('remove_device')}
                />
              ) : (
                <Box color="average">Brak urządzenia</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Zbiornik pierwszy">
          <LabeledList>
            <LabeledList.Item label="Podpięty">
              {tank_one ? (
                <Button
                  icon="eject"
                  content={tank_one}
                  onClick={() => act('tankone')}
                />
              ) : (
                <Box color="average">Brak zbiornika</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Zbiornik drugi">
          <LabeledList>
            <LabeledList.Item label="Podpięty">
              {tank_two ? (
                <Button
                  icon="eject"
                  content={tank_two}
                  onClick={() => act('tanktwo')}
                />
              ) : (
                <Box color="average">Brak zbiornika</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
