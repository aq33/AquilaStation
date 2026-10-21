import { Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Goal = {
  name: string;
  ref: string;
};

type Data = {
  goals: Goal[];
  has_mode: boolean;
};

export const StationGoalsPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { goals = [] } = data;
  return (
    <Window title="Cele stacji" theme="admin" width={460} height={400}>
      <Window.Content scrollable>
        <Section
          title="Cele stacji"
          buttons={
            <Button
              icon="plus"
              color="good"
              disabled={!data.has_mode}
              onClick={() => act('add')}
            >
              Dodaj cel
            </Button>
          }
        >
          {!data.has_mode && (
            <NoticeBox>Tryb gry nie jest jeszcze wybrany.</NoticeBox>
          )}
          {!!data.has_mode && goals.length === 0 && (
            <NoticeBox>Brak celów stacji.</NoticeBox>
          )}
          <Table>
            {goals.map((goal) => (
              <Table.Row key={goal.ref} className="candystripe">
                <Table.Cell py={0.25}>{goal.name}</Table.Cell>
                <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
                  <Button
                    icon="bullhorn"
                    onClick={() => act('announce', { ref: goal.ref })}
                  >
                    Ogłoś
                  </Button>
                  <Button
                    icon="trash"
                    color="bad"
                    onClick={() => act('remove', { ref: goal.ref })}
                  >
                    Usuń
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
