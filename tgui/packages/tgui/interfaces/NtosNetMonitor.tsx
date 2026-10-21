import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  config_communication: BooleanLike;
  config_peertopeer: BooleanLike;
  config_softwaredownload: BooleanLike;
  config_systemcontrol: BooleanLike;
  idsalarm: BooleanLike;
  idsstatus: BooleanLike;
  maxlogs: number;
  minlogs: number;
  ntnetlogs: { entry: string }[];
  ntnetmaxlogs: number;
  ntnetrelays: number;
  ntnetstatus: BooleanLike;
};

export const NtosNetMonitor = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    ntnetrelays,
    ntnetstatus,
    config_softwaredownload,
    config_peertopeer,
    config_communication,
    config_systemcontrol,
    idsalarm,
    idsstatus,
    ntnetmaxlogs,
    maxlogs,
    minlogs,
    ntnetlogs = [],
  } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <NoticeBox>
          UWAGA: wyłączenie nadajników bezprzewodowych z urządzenia
          bezprzewodowego może uniemożliwić ich ponowne włączenie!
        </NoticeBox>
        <Section
          title="Łączność bezprzewodowa"
          buttons={
            <Button.Confirm
              confirmContent="Na pewno?"
              icon={ntnetstatus ? 'power-off' : 'times'}
              content={ntnetstatus ? 'WŁĄCZONE' : 'WYŁĄCZONE'}
              selected={ntnetstatus}
              onClick={() => act('toggleWireless')}
            />
          }
        >
          {ntnetrelays ? (
            <LabeledList>
              <LabeledList.Item label="Aktywne przekaźniki NTNet">
                {ntnetrelays}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            'Brak połączonych przekaźników'
          )}
        </Section>
        <Section title="Konfiguracja zapory">
          <LabeledList>
            <LabeledList.Item
              label="Pobieranie oprogramowania"
              buttons={
                <Button
                  icon={config_softwaredownload ? 'power-off' : 'times'}
                  content={config_softwaredownload ? 'WŁĄCZONE' : 'WYŁĄCZONE'}
                  selected={config_softwaredownload}
                  onClick={() => act('toggle_function', { id: '1' })}
                />
              }
            />
            <LabeledList.Item
              label="Ruch peer-to-peer"
              buttons={
                <Button
                  icon={config_peertopeer ? 'power-off' : 'times'}
                  content={config_peertopeer ? 'WŁĄCZONE' : 'WYŁĄCZONE'}
                  selected={config_peertopeer}
                  onClick={() => act('toggle_function', { id: '2' })}
                />
              }
            />
            <LabeledList.Item
              label="Systemy komunikacji"
              buttons={
                <Button
                  icon={config_communication ? 'power-off' : 'times'}
                  content={config_communication ? 'WŁĄCZONE' : 'WYŁĄCZONE'}
                  selected={config_communication}
                  onClick={() => act('toggle_function', { id: '3' })}
                />
              }
            />
            <LabeledList.Item
              label="Zdalne sterowanie systemami"
              buttons={
                <Button
                  icon={config_systemcontrol ? 'power-off' : 'times'}
                  content={config_systemcontrol ? 'WŁĄCZONE' : 'WYŁĄCZONE'}
                  selected={config_systemcontrol}
                  onClick={() => act('toggle_function', { id: '4' })}
                />
              }
            />
          </LabeledList>
        </Section>
        <Section title="Systemy bezpieczeństwa">
          {!!idsalarm && (
            <>
              <NoticeBox>WYKRYTO WŁAMANIE DO SIECI</NoticeBox>
              <Box italic>
                W sieci wykryto nietypową aktywność. Szczegóły znajdziesz w
                logach systemu.
              </Box>
            </>
          )}
          <LabeledList>
            <LabeledList.Item
              label="Status IDS"
              buttons={
                <>
                  <Button
                    icon={idsstatus ? 'power-off' : 'times'}
                    content={idsstatus ? 'WŁĄCZONE' : 'WYŁĄCZONE'}
                    selected={idsstatus}
                    onClick={() => act('toggleIDS')}
                  />
                  <Button
                    icon="sync"
                    content="Resetuj"
                    color="bad"
                    onClick={() => act('resetIDS')}
                  />
                </>
              }
            />
            <LabeledList.Item
              label="Maks. liczba wpisów"
              buttons={
                <NumberInput
                  step={1}
                  value={ntnetmaxlogs}
                  minValue={minlogs}
                  maxValue={maxlogs}
                  width="39px"
                  onChange={(value) =>
                    act('updatemaxlogs', {
                      new_number: value,
                    })
                  }
                />
              }
            />
          </LabeledList>
          <Section
            title="Log systemu"
            buttons={
              <Button.Confirm
                confirmContent="Na pewno?"
                icon="trash"
                content="Wyczyść logi"
                onClick={() => act('purgelogs')}
              />
            }
          >
            {ntnetlogs.map((log) => (
              <Box key={log.entry} className="candystripe">
                {log.entry}
              </Box>
            ))}
          </Section>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
