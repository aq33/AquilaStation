import { useState } from 'react';
import {
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  mentors: string[];
  db_connected: boolean;
};

export const MentorPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { mentors = [] } = data;
  const [newMentor, setNewMentor] = useState('');
  const addMentor = () => {
    act('add', { ckey: newMentor });
    setNewMentor('');
  };
  return (
    <Window title="Panel mentorów" theme="admin" width={420} height={520}>
      <Window.Content>
        <Stack vertical fill>
          {!data.db_connected && (
            <Stack.Item>
              <NoticeBox danger>Brak połączenia z bazą danych.</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Klucz nowego mentora..."
                  value={newMentor}
                  onChange={(value) => setNewMentor(value)}
                  onEnter={addMentor}
                />
              </Stack.Item>
              <Stack.Item>
                <Button icon="plus" color="good" onClick={addMentor}>
                  Dodaj mentora
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="sync"
                  tooltip="Odśwież"
                  onClick={() => act('refresh')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title={`Mentorzy (${mentors.length})`}>
              {mentors.length === 0 && <NoticeBox>Brak mentorów.</NoticeBox>}
              <Table>
                {mentors.map((mentor) => (
                  <Table.Row key={mentor} className="candystripe">
                    <Table.Cell py={0.25}>{mentor}</Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        icon="times"
                        color="bad"
                        tooltip="Odbierz rangę mentora"
                        onClick={() => act('remove', { ckey: mentor })}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
