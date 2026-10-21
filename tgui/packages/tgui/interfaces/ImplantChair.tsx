import { Button, Icon, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  occupied: BooleanLike;
  open: BooleanLike;
  occupant: {
    name?: string;
    stat?: number;
  };
  special_name: string | null;
  ready_implants: number;
  ready: BooleanLike;
  replenishing: BooleanLike;
};

export const ImplantChair = (props) => {
  const { act, data } = useBackend<Data>();
  const { occupant = {} } = data;
  return (
    <Window width={375} height={280}>
      <Window.Content>
        <Section title="Pacjent" textAlign="center">
          <LabeledList>
            <LabeledList.Item label="Imię">
              {occupant.name || 'Brak pacjenta'}
            </LabeledList.Item>
            {!!data.occupied && (
              <LabeledList.Item
                label="Stan"
                color={
                  occupant.stat === 0
                    ? 'good'
                    : occupant.stat === 1
                      ? 'average'
                      : 'bad'
                }
              >
                {occupant.stat === 0
                  ? 'Przytomny'
                  : occupant.stat === 1
                    ? 'Nieprzytomny'
                    : 'Martwy'}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section title="Obsługa" textAlign="center">
          <LabeledList>
            <LabeledList.Item label="Drzwi">
              <Button
                icon={data.open ? 'unlock' : 'lock'}
                color={data.open ? 'default' : 'red'}
                onClick={() => act('door')}
              >
                {data.open ? 'Otwarte' : 'Zamknięte'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Wszczep pacjentowi">
              <Button
                icon="code-branch"
                disabled={!data.ready}
                onClick={() => act('implant')}
              >
                {data.ready ? data.special_name || 'Wszczep' : 'Ładowanie'}
              </Button>
              {!data.ready && <Icon name="cog" color="orange" spin />}
            </LabeledList.Item>
            <LabeledList.Item label="Pozostałe implanty">
              {data.ready_implants}
              {!!data.replenishing && <Icon name="sync" color="red" spin />}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
