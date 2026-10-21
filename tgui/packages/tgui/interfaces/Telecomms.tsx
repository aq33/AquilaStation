import {
  Box,
  Button,
  Input,
  LabeledControls,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type Data = {
  broadcasting: any;
  changefrequency: any;
  currfrequency: any;
  frequencies: any;
  frequency: any;
  id: any;
  linked: any;
  maxfreq: any;
  minfreq: any;
  multibuff: any;
  multitool: any;
  network: any;
  prefab: any;
  receiving: any;
  toggled: any;
  type: any;
};

export const Telecomms = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    type,
    minfreq,
    maxfreq,
    frequency,
    multitool,
    multibuff,
    toggled,
    id,
    network,
    prefab,
    changefrequency,
    currfrequency,
    broadcasting,
    receiving,
  } = data;
  const linked = data.linked || [];
  const frequencies = data.frequencies || [];
  return (
    <Window title={id} width={400} height={600}>
      <Window.Content scrollable>
        {!multitool && <NoticeBox>Do zmian potrzebujesz multitoola.</NoticeBox>}
        <Section title="Ustawienia">
          <LabeledList>
            <LabeledList.Item
              label="Zasilanie"
              buttons={
                <Button
                  icon={toggled ? 'power-off' : 'times'}
                  content={toggled ? 'Wł.' : 'Wył.'}
                  color={toggled ? 'good' : 'bad'}
                  disabled={!multitool}
                  onClick={() => act('toggle')}
                />
              }
            />
            <LabeledList.Item
              label="Identyfikator"
              buttons={
                <Input
                  width={13}
                  value={id}
                  onBlur={(value) => act('id', { value })}
                />
              }
            />
            <LabeledList.Item
              label="Sieć"
              buttons={
                <Input
                  width={10}
                  value={network}
                  placeholder="tcommsat"
                  onBlur={(value) => act('network', { value })}
                />
              }
            />
            <LabeledList.Item
              label="Prefabrykat"
              buttons={
                <Button
                  icon={prefab ? 'check' : 'times'}
                  color={prefab ? 'good' : 'bad'}
                  content={prefab ? 'Tak' : 'Nie'}
                  disabled
                />
              }
            />
          </LabeledList>
        </Section>
        {!!(toggled && multitool) && (
          <Box>
            {type === 'bus' && (
              <Section title="Magistrala">
                <Table>
                  <Table.Row>
                    <Table.Cell>Zmiana częstotliwości:</Table.Cell>
                    <Table.Cell>
                      {RADIO_CHANNELS.find(
                        (channel) => channel.freq === changefrequency,
                      ) && (
                        <Box
                          inline
                          color={
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === changefrequency,
                            )?.color
                          }
                          ml={2}
                        >
                          [
                          {
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === changefrequency,
                            )?.name
                          }
                          ]
                        </Box>
                      )}
                    </Table.Cell>
                    <NumberInput
                      animated
                      unit="GHz"
                      step={0.2}
                      stepPixelSize={10}
                      minValue={minfreq / 10}
                      maxValue={maxfreq / 10}
                      value={changefrequency / 10}
                      onChange={(value) => act('change_freq', { value })}
                    />
                    <Button
                      icon="times"
                      color="bad"
                      disabled={changefrequency === 0}
                      onClick={() => act('change_freq', { value: 10001 })}
                    />
                  </Table.Row>
                </Table>
              </Section>
            )}
            {type === 'relay' && (
              <Section title="Przekaźnik">
                <Button
                  content={'Odbiór'}
                  icon={receiving ? 'volume-up' : 'volume-mute'}
                  color={receiving ? '' : 'bad'}
                  onClick={() => act('receive')}
                />
                <Button
                  content={'Nadawanie'}
                  icon={broadcasting ? 'microphone' : 'microphone-slash'}
                  color={broadcasting ? '' : 'bad'}
                  onClick={() => act('broadcast')}
                />
              </Section>
            )}
            <Section title="Połączone urządzenia sieci">
              <Table>
                {linked.map((entry) => (
                  <Table.Row key={entry.id} className="candystripe">
                    <Table.Cell bold>
                      {entry.index}. {entry.id} ({entry.name})
                    </Table.Cell>
                    {!!multitool && (
                      <Button
                        icon="times"
                        color="bad"
                        disabled={!multitool}
                        onClick={() => act('unlink', { value: entry.index })}
                      />
                    )}
                  </Table.Row>
                ))}
              </Table>
            </Section>
            <Section title="Filtrowane częstotliwości">
              <Table>
                {frequencies.map((entry) => (
                  <Table.Row key={entry} className="candystripe">
                    <Table.Cell bold>{entry / 10} GHz</Table.Cell>
                    <Table.Cell>
                      {RADIO_CHANNELS.find(
                        (channel) => channel.freq === entry,
                      ) && (
                        <Box
                          inline
                          color={
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === entry,
                            )?.color
                          }
                          ml={2}
                        >
                          [
                          {
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === entry,
                            )?.name
                          }
                          ]
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell />
                    {!!multitool && (
                      <Button
                        icon="times"
                        color="bad"
                        disabled={!multitool}
                        onClick={() => act('delete', { value: entry })}
                      />
                    )}
                  </Table.Row>
                ))}
                {!!multitool && (
                  <Table.Row className="candystripe">
                    <Table.Cell>Dodaj częstotliwość</Table.Cell>
                    <Table.Cell>
                      {RADIO_CHANNELS.find(
                        (channel) => channel.freq === frequency,
                      ) && (
                        <Box
                          inline
                          color={
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === frequency,
                            )?.color
                          }
                          ml={2}
                        >
                          [
                          {
                            RADIO_CHANNELS.find(
                              (channel) => channel.freq === frequency,
                            )?.name
                          }
                          ]
                        </Box>
                      )}
                    </Table.Cell>
                    <Table.Cell>
                      <NumberInput
                        animated
                        unit="GHz"
                        step={0.2}
                        stepPixelSize={10}
                        minValue={minfreq / 10}
                        maxValue={maxfreq / 10}
                        value={frequency / 10}
                        onChange={(value) => act('tempfreq', { value })}
                      />
                    </Table.Cell>
                    <Button
                      icon={'plus'}
                      color={'good'}
                      disabled={!multitool}
                      onClick={() => act('freq')}
                    />
                  </Table.Row>
                )}
              </Table>
            </Section>
            {!!multitool && (
              <Section title="Multitool">
                {!!multibuff && (
                  <Box bold m={1}>
                    W buforze: {multibuff}
                  </Box>
                )}
                <LabeledControls m={1}>
                  <Button
                    icon={'plus'}
                    content={'Dodaj urządzenie'}
                    disabled={!multitool}
                    onClick={() => act('buffer')}
                  />
                  <Button
                    icon={'link'}
                    content={'Połącz'}
                    disabled={!multibuff}
                    onClick={() => act('link')}
                  />
                  <Button
                    icon="times"
                    color="bad"
                    content={'Wyczyść'}
                    disabled={!multibuff}
                    onClick={() => act('flush')}
                  />
                </LabeledControls>
              </Section>
            )}
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
