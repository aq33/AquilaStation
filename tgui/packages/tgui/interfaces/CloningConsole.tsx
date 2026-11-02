import { Fragment } from 'react';
import {
  Box,
  Button,
  Collapsible,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  autoprocess: any;
  diskData: any;
  experimental: any;
  hasAutoprocess: any;
  hasOccupant: any;
  lacksMachine: any;
  records: any;
  recordsLength: any;
  scanTemp: any;
  scannerLocked: any;
  temp: any;
  useRecords: any;
};

// NSV13 - removed last_death and experimental checks to enable prescans
export const CloningConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    useRecords,
    hasAutoprocess,
    autoprocess,
    temp,
    scanTemp,
    scannerLocked,
    hasOccupant,
    recordsLength,
    experimental,
  } = data;
  const lacksMachine = data.lacksMachine || [];
  const diskData = data.diskData || [];
  const records = data.records || [];
  return (
    <Window width={400} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Stan kapsuły klonującej">
            <Box backgroundColor="#40638a" p="1px">
              <Box backgroundColor="black" color="white" p="5px">
                {temp}
              </Box>
            </Box>
          </Section>
          {!lacksMachine.length ? (
            <Section title="Funkcje skanera">
              <Box backgroundColor="#40638a" p="1px">
                <Box backgroundColor="black" color="white" p="5px">
                  {scanTemp}
                </Box>
              </Box>
              <br />
              <Button
                content={'Pełny skan'}
                icon={'search'}
                disabled={!hasOccupant}
                onClick={() => act('scan')}
              />
              {!experimental ? (
                <Button
                  content={'Tylko ciało'}
                  disabled={!hasOccupant}
                  icon={'search'}
                  onClick={() => act('scan_body_only')}
                />
              ) : (
                ''
              )}
              <Button
                content={scannerLocked ? 'Odblokuj skaner' : 'Zablokuj skaner'}
                icon={scannerLocked ? 'lock' : 'lock-open'}
                disabled={!hasOccupant && !scannerLocked}
                onClick={() => act('toggle_lock')}
              />
            </Section>
          ) : (
            <Section title="Moduły">
              {lacksMachine.map((machine) => (
                <Box key={machine} color="red">
                  {machine}
                  <br />
                </Box>
              ))}
            </Section>
          )}
          {useRecords ? (
            <Section>
              <Section title="Funkcje bazy danych">
                <NoticeBox>
                  <Collapsible title={recordsLength}>
                    <h2>Obecne akta: </h2>
                    {records.map((record) => (
                      <Section
                        backgroundColor="#191919"
                        color="white"
                        key={record}
                      >
                        <Collapsible
                          title={
                            record['name'] +
                            (record['body_only']
                              ? ' (tylko ciało)'
                              : record['last_death'] < 0
                                ? ' (zapis wstępny)'
                                : '')
                          }
                          color={
                            record['body_only']
                              ? 'yellow'
                              : record['last_death'] < 0
                                ? 'green'
                                : 'blue'
                          }
                        >
                          <div
                            key={record['name']}
                            style={{
                              wordBreak: 'break-all',
                            }}
                          >
                            ID skanu: {record['id']}
                            <br />
                            <Button
                              content="Klonuj"
                              icon="power-off" // NSV13, makes empty clones possible again, removed "disable=body-only && !experimental"
                              onClick={() =>
                                act('clone', {
                                  target: record['id'],
                                })
                              }
                            />
                            <Button
                              content="Usuń akta"
                              icon="user-slash"
                              onClick={() =>
                                act('delrecord', {
                                  target: record['id'],
                                })
                              }
                            />
                            <Button
                              content="Zapisz na dysk"
                              icon="upload"
                              disabled={diskData.length === 0}
                              onClick={() =>
                                act('save', {
                                  target: record['id'],
                                })
                              }
                            />
                            <br />
                            {record['damages'] ? (
                              <>
                                Dane implantu zdrowia
                                <br />
                                <small>
                                  Obrażenia od niedotlenienia:
                                  <br />
                                  <ProgressBar
                                    color="blue"
                                    value={record['damages']['oxy'] / 100}
                                  />
                                  Obrażenia od ognia:
                                  <br />
                                  <ProgressBar
                                    color="orange"
                                    value={record['damages']['burn'] / 100}
                                  />
                                  Obrażenia od toksyn:
                                  <br />
                                  <ProgressBar
                                    color="green"
                                    value={record['damages']['tox'] / 100}
                                  />
                                  Obrażenia fizyczne:
                                  <br />
                                  <ProgressBar
                                    color="red"
                                    value={record['damages']['brute'] / 100}
                                  />
                                </small>
                                <br />
                              </>
                            ) : (
                              <>
                                Brak danych implantu zdrowia
                                <br />
                              </>
                            )}
                            Unikalny identyfikator:
                            <br />
                            {record['UI']}
                            <br />
                            Unikalne enzymy:
                            <br />
                            {record['UE']}
                            <br />
                            Grupa krwi:
                            <br />
                            {record['blood_type']}
                            <br />
                          </div>
                        </Collapsible>
                      </Section>
                    ))}
                  </Collapsible>
                </NoticeBox>
              </Section>
              <Section
                title="Dysk"
                buttons={
                  <Box>
                    <Button
                      content="Wczytaj"
                      icon="download"
                      disabled={!diskData['name']}
                      onClick={() => act('load')}
                    />
                    <Button
                      content="Wysuń dysk"
                      icon="eject"
                      disabled={diskData.length === 0}
                      onClick={() => act('eject')}
                    />
                  </Box>
                }
              >
                {diskData.length !== 0 ? (
                  <Collapsible
                    title={
                      diskData['name']
                        ? diskData['name'] +
                          (diskData['body_only']
                            ? ' (tylko ciało)'
                            : diskData['last_death'] < 0
                              ? ' (zapis wstępny)'
                              : '')
                        : 'Pusty dysk'
                    }
                    color={
                      diskData['name']
                        ? diskData['body_only']
                          ? 'yellow'
                          : diskData['last_death'] < 0
                            ? 'green'
                            : 'blue'
                        : 'grey'
                    }
                  >
                    {diskData['id'] ? (
                      <Box
                        style={{
                          wordBreak: 'break-all',
                        }}
                      >
                        ID: {diskData['id']}
                        <br />
                        UI: {diskData['UI']}
                        <br />
                        UE: {diskData['UE']}
                        <br />
                        Grupa krwi: {diskData['blood_type']}
                        <br />
                      </Box>
                    ) : (
                      'Brak danych'
                    )}
                  </Collapsible>
                ) : (
                  'Brak dysku'
                )}
              </Section>
            </Section>
          ) : null}
        </Section>
      </Window.Content>
    </Window>
  );
};
