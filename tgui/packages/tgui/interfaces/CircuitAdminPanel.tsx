import { Button, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type CircuitAdminPanelData = {
  circuits: {
    ref: string;
    name: string;
    creator: string;
    has_inserter: BooleanLike;
  }[];
};

export const CircuitAdminPanel = (props) => {
  const { act, data } = useBackend<CircuitAdminPanelData>();

  return (
    <Window title="Panel admina układów" width={1200} height={500}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow />
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('disable_circuit_sound');
                  }}
                >
                  Wyłącz wszystkie emitery dźwięku w układach
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Table>
              <Table.Row header>
                <Table.Cell>Nazwa układu</Table.Cell>

                <Table.Cell>Twórca</Table.Cell>

                <Table.Cell>Akcje</Table.Cell>
              </Table.Row>

              {data.circuits.map((circuit) => {
                const createAct = (action: string) => () => {
                  act(action, { circuit: circuit.ref });
                };

                return (
                  <Table.Row key={circuit.ref}>
                    <Table.Cell>{circuit.name}</Table.Cell>

                    <Table.Cell>{circuit.creator}</Table.Cell>

                    <Table.Cell>
                      <Button onClick={createAct('follow_circuit')}>
                        Śledź
                      </Button>

                      <Button onClick={createAct('open_circuit')}>
                        Otwórz
                      </Button>

                      <Button onClick={createAct('vv_circuit')}>VV</Button>

                      <Button onClick={createAct('save_circuit')}>
                        Zapisz
                      </Button>

                      <Button onClick={createAct('duplicate_circuit')}>
                        Duplikuj
                      </Button>

                      {!!circuit.has_inserter && (
                        <Button onClick={createAct('open_player_panel')}>
                          Panel gracza
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
