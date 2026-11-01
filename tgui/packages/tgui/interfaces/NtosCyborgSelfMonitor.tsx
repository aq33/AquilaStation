import { Fragment } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  Laws: any;
  PC_device_theme: any;
  borgLog: any;
  borgUpgrades: any;
  charge: any;
  cover: any;
  designation: any;
  integrity: any;
  lampIntensity: any;
  locomotion: any;
  masterAI: any;
  maxcharge: any;
  name: any;
  printerPictures: any;
  printerToner: any;
  printerTonerMax: any;
  selfDestructAble: any;
  sensors: any;
  thrustersInstalled: any;
  thrustersStatus: any;
  wireAI: any;
  wireCamera: any;
  wireLaw: any;
  wireModule: any;
};

// Stany przychodzą z DM jako klucze (porównywane niżej przy kolorach),
// więc tłumaczymy je tylko przy wyświetlaniu.
const STATUS_PL: Record<string, string> = {
  ACTIVE: 'WŁĄCZONO',
  DISABLED: 'WYŁĄCZONO',
  ENABLED: 'WŁĄCZONO',
  LOCKED: 'ZABLOKOWANO',
  UNLOCKED: 'ODBLOKOWANO',
  FAULT: 'USTERKA',
  NOMINAL: 'W NORMIE',
  CONNECTED: 'POŁĄCZONO',
  READY: 'GOTOWOŚĆ',
};

const statusText = (value: string) => STATUS_PL[value] ?? value;

export const NtosCyborgSelfMonitor = (props) => {
  const { act, data } = useBackend<Data>();
  const { PC_device_theme } = data;
  return (
    <NtosWindow width={800} height={600} theme={PC_device_theme}>
      <NtosWindow.Content>
        <NtosCyborgSelfMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCyborgSelfMonitorContent = (props) => {
  const { act, data } = useBackend<Data>();
  const [tab_main, setTab_main] = useSharedState('tab_main', 1);
  const [tab_sub, setTab_sub] = useSharedState('tab_sub', 1);
  const {
    charge,
    maxcharge,
    integrity,
    lampIntensity,
    cover,
    locomotion,
    wireModule,
    wireCamera,
    wireAI,
    wireLaw,
    sensors,
    printerPictures,
    printerToner,
    printerTonerMax,
    thrustersInstalled,
    thrustersStatus,
    selfDestructAble,
  } = data;
  const borgName = data.name || [];
  const borgType = data.designation || [];
  const masterAI = data.masterAI || [];
  const laws = data.Laws || [];
  const borgLog = data.borgLog || [];
  const borgUpgrades = data.borgUpgrades || [];
  return (
    <Flex direction={'column'}>
      <Flex.Item position="relative" mb={1}>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}
          >
            Stan
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}
          >
            Logi
          </Tabs.Tab>
        </Tabs>
      </Flex.Item>
      {tab_main === 1 && (
        <>
          <Flex direction={'row'}>
            <Flex.Item width="30%">
              <Section title="Konfiguracja" fill>
                <LabeledList>
                  <LabeledList.Item label="Jednostka">
                    {borgName.slice(0, 17)}
                  </LabeledList.Item>
                  <LabeledList.Item label="Typ">{borgType}</LabeledList.Item>
                  <LabeledList.Item label="SI">
                    {masterAI.slice(0, 17)}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} ml={1}>
              <Section title="Stan">
                Ładunek:
                <Button
                  content="Alarm zasilania"
                  disabled={charge}
                  onClick={() => act('alertPower')}
                />
                <ProgressBar
                  value={charge / maxcharge}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.1, 0.5],
                    bad: [-Infinity, 0.1],
                  }}
                >
                  <AnimatedNumber value={charge} />
                </ProgressBar>
                Integralność obudowy:
                <ProgressBar
                  value={integrity}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    bad: [-Infinity, 25],
                    average: [25, 75],
                    good: [75, Infinity],
                  }}
                />
              </Section>
              <Section title="Moc lampy">
                <Slider
                  value={lampIntensity}
                  step={1}
                  stepPixelSize={25}
                  maxValue={5}
                  minValue={1}
                  onChange={(e, value) =>
                    act('lampIntensity', {
                      ref: value,
                    })
                  }
                />
                Pobór mocy lampy: {lampIntensity / 2} W
              </Section>
            </Flex.Item>
            <Flex.Item width="50%" ml={1}>
              <Section fitted>
                <Tabs fluid textAlign="center">
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 1}
                    onClick={() => setTab_sub(1)}
                  >
                    Akcje
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 2}
                    onClick={() => setTab_sub(2)}
                  >
                    Ulepszenia
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 3}
                    onClick={() => setTab_sub(3)}
                  >
                    Diagnostyka
                  </Tabs.Tab>
                </Tabs>
              </Section>
              {tab_sub === 1 && (
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Pokrywa serwisowa">
                      <Button.Confirm
                        confirmContent="Na pewno?"
                        content="Odblokuj"
                        disabled={cover === 'UNLOCKED'}
                        onClick={() => act('coverunlock')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Nakładka czujników">
                      <Button
                        content={statusText(sensors)}
                        onClick={() => act('toggleSensors')}
                      />
                    </LabeledList.Item>
                    {/* NSV added manfiest to borg computer start */}
                    <LabeledList.Item label={'Lista załogi'}>
                      <Button
                        content="Otwórz"
                        onClick={() => act('crewmanifest')}
                      />
                    </LabeledList.Item>
                    {/* NSV added manfiest to borg computer end */}
                    <LabeledList.Item
                      label={'Zapisane zdjęcia (' + printerPictures + ')'}
                    >
                      <Button
                        content="Pokaż"
                        disabled={!printerPictures}
                        onClick={() => act('viewImage')}
                      />
                      <Button
                        content="Drukuj"
                        disabled={!printerPictures}
                        onClick={() => act('printImage')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Toner drukarki">
                      <ProgressBar value={printerToner / printerTonerMax} />
                    </LabeledList.Item>
                    {!!thrustersInstalled && (
                      <LabeledList.Item label="Silniki manewrowe">
                        <Button
                          content={statusText(thrustersStatus)}
                          onClick={() => act('toggleThrusters')}
                        />
                      </LabeledList.Item>
                    )}
                    {!!selfDestructAble && (
                      <LabeledList.Item label="Autodestrukcja">
                        <Button.Confirm
                          confirmContent="Na pewno?"
                          content="AKTYWUJ"
                          color="red"
                          onClick={() => act('selfDestruct')}
                        />
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              )}
              {tab_sub === 2 && (
                <Section>
                  {borgUpgrades.map((upgrade) => (
                    <Box mb={1} key={upgrade}>
                      {upgrade}
                    </Box>
                  ))}
                </Section>
              )}
              {tab_sub === 3 && (
                <Section>
                  <LabeledList>
                    <LabeledList.Item
                      label="Połączenie z SI"
                      color={
                        wireAI === 'FAULT'
                          ? 'red'
                          : wireAI === 'READY'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {statusText(wireAI)}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Synchronizacja praw"
                      color={wireLaw === 'FAULT' ? 'red' : 'green'}
                    >
                      {statusText(wireLaw)}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Kamera"
                      color={
                        wireCamera === 'FAULT'
                          ? 'red'
                          : wireCamera === 'DISABLED'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {statusText(wireCamera)}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Kontroler modułów"
                      color={wireModule === 'FAULT' ? 'red' : 'green'}
                    >
                      {statusText(wireModule)}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Kontroler napędu"
                      color={
                        locomotion === 'FAULT'
                          ? 'red'
                          : locomotion === 'DISABLED'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {statusText(locomotion)}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Pokrywa serwisowa"
                      color={cover === 'UNLOCKED' ? 'red' : 'green'}
                    >
                      {statusText(cover)}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              )}
            </Flex.Item>
          </Flex>
          <Flex.Item height={21} mt={1}>
            <Section
              title="Prawa"
              fill
              scrollable
              buttons={
                <>
                  <Button
                    content="Ogłoś prawa"
                    onClick={() => act('lawstate')}
                  />
                  <Button icon="volume-off" onClick={() => act('lawchannel')} />
                </>
              }
            >
              {laws.map((law) => (
                <Box mb={1} key={law}>
                  {law}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </>
      )}
      {tab_main === 2 && (
        <Flex.Item height={40}>
          <Section fill scrollable backgroundColor="black">
            {borgLog.map((log) => (
              <Box mb={1} key={log}>
                <span style={{ color: 'green' }}>{log}</span>
              </Box>
            ))}
          </Section>
        </Flex.Item>
      )}
    </Flex>
  );
};
