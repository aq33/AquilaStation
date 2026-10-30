// NSV13

import { Fragment } from 'react';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Slider,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  current_description: any;
  current_difficulty: any;
  current_escalation: any;
  current_gamemode: any;
  game_started: any;
  hard_mode: any;
  objectives_list: any;
  reminder_interval: any;
  reminder_stacks: any;
  reminder_time_remaining: any;
  threat_elevation: any;
  threat_per_size_point: any;
  toggle_ghost_boarders: any;
  toggle_ghost_ships: any;
  toggle_override: any;
  toggle_reminder: any;
};

export const OvermapGamemodeController = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="ntos" width={640} height={800}>
      <Window.Content scrollable>
        <Section title="Panel sterowania trybem overmapy">
          <Flex spacing={1}>
            <Flex.Item width="600px">
              <Section>
                <LabeledList>
                  <LabeledList.Item label="Obecny tryb">
                    {data.current_gamemode}
                    <br />
                    <br />
                    {data.current_description}
                    <br />
                    <br />
                    <Button
                      icon="shield-alt"
                      content={
                        data.game_started
                          ? 'Nie można zmienić trybu'
                          : 'Zmień tryb'
                      }
                      color={data.game_started ? 'grey' : 'green'}
                      onClick={() => act('change_gamemode')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Zagrożenie">
                    {'Obecne punkty zagrożenia: ' + data.threat_elevation}
                    <br />
                    {'Punkty potrzebne na punkt wielkości floty: ' +
                      data.threat_per_size_point +
                      ' | efektywny bonus do wielkości floty: ' +
                      Math.floor(
                        data.threat_elevation / data.threat_per_size_point,
                      )}
                    <br />
                    <br />
                    <Button
                      icon="exchange-alt"
                      content="Zmień zagrożenie"
                      color="grey"
                      onClick={() => act('adjust_threat')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Trudność">
                    <Button
                      icon="skull-crossbones"
                      color={data.hard_mode && 'green'}
                      content={
                        'TRYB TRUDNY: ' +
                        (data.hard_mode ? 'WŁĄCZONY' : 'WYŁĄCZONY')
                      }
                      onClick={() => act('toggle_hardmode')}
                    />
                    <br />
                    Obecna globalna trudność: {data.current_difficulty}
                    <br />
                    <br />
                    Zmień globalną trudność
                    <Slider
                      tickWhileDragging
                      value={data.current_escalation}
                      minValue={-5}
                      maxValue={5}
                      step={1}
                      stepPixelSize={50}
                      onChange={(e, value) =>
                        act('current_escalation', {
                          adjust: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Przypomnienie">
                    <Flex spacing={1}>
                      <Flex.Item width="220px">
                        Następne przypomnienie za:{' '}
                        {data.reminder_time_remaining} s
                        <br />
                        <br />
                        Odstęp przypomnień: {data.reminder_interval} min
                        <br />
                        <br />
                        Liczba przypomnień: {data.reminder_stacks}
                      </Flex.Item>
                      <Flex.Item width="220px">
                        <Button
                          icon={data.toggle_reminder ? 'check' : 'times'}
                          content={
                            data.toggle_reminder
                              ? 'Włącz przypomnienie'
                              : 'Wyłącz przypomnienie'
                          }
                          color={data.toggle_reminder ? 'green' : 'red'}
                          onClick={() => act('toggle_reminder')}
                        />
                        <Button
                          icon="stopwatch"
                          content="Przedłuż przypomnienie"
                          color="green"
                          onClick={() => act('extend_reminder')}
                        />
                        <Button
                          icon="hourglass-start"
                          content="Wyzeruj licznik"
                          color="green"
                          onClick={() => act('reset_stage')}
                        />
                      </Flex.Item>
                    </Flex>
                  </LabeledList.Item>
                  <LabeledList.Item label="Inne">
                    <Button
                      icon="ghost"
                      content="Stwórz statek-widmo"
                      color="orange"
                      onClick={() => act('spawn_ghost_ship')}
                    />
                    <Button
                      icon={data.toggle_ghost_ships ? 'check' : 'times'}
                      content={
                        data.toggle_ghost_ships
                          ? 'Włącz statki-widma'
                          : 'Wyłącz statki-widma'
                      }
                      color={data.toggle_ghost_ships ? 'green' : 'red'}
                      onClick={() => act('toggle_ghost_ships')}
                    />
                    <Button
                      icon={data.toggle_ghost_boarders ? 'check' : 'times'}
                      content={
                        data.toggle_ghost_boarders
                          ? 'Włącz abordażystów-duchy'
                          : 'Wyłącz abordażystów-duchy'
                      }
                      color={data.toggle_ghost_boarders ? 'green' : 'red'}
                      onClick={() => act('toggle_ghost_boarders')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Divider size={1} />
                </LabeledList>
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
        <Section>
          <Flex spacing={1}>
            <Flex.Item width="600px">
              <Section title="Cele:">
                <Button
                  icon={data.toggle_override ? 'check' : 'times'}
                  content={
                    data.toggle_override
                      ? 'Włącz wykonywanie celów'
                      : 'Wyłącz wykonywanie celów'
                  }
                  color={data.toggle_override ? 'green' : 'red'}
                  onClick={() => act('override_completion')}
                />
                <br />
                <Section>
                  {Object.keys(data.objectives_list).map((key) => {
                    let value = data.objectives_list[key];
                    return (
                      <Fragment key={key}>
                        <Section title={`${value.name}`}>
                          {value.desc}: {value.status}
                          <br />
                          <br />
                          <Box mb={1}>
                            <Button
                              icon="search"
                              content="Pokaż zmienne"
                              color="blue"
                              onClick={() =>
                                act('view_vars', { target: value.datum })
                              }
                            />
                            <Button
                              icon="exchange-alt"
                              content="Zmień stan"
                              color="green"
                              onClick={() =>
                                act('change_objective_state', {
                                  target: value.datum,
                                })
                              }
                            />
                            <Button
                              icon="minus"
                              content="Usuń cel"
                              color="red"
                              onClick={() =>
                                act('remove_objective', { target: value.datum })
                              }
                            />
                          </Box>
                        </Section>
                      </Fragment>
                    );
                  })}
                </Section>
                <Button
                  icon="plus"
                  content="Dodaj cel"
                  color="green"
                  onClick={() => act('add_objective')}
                />
                <Button
                  icon="plus"
                  content="Dodaj własny cel"
                  color="green"
                  onClick={() => act('add_custom_objective')}
                />
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
