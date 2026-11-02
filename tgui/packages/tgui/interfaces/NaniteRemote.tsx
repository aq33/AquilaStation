import {
  Button,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  code: any;
  comms: any;
  locked: any;
  message: any;
  mode: any;
  program_name: any;
  relay_code: any;
  saved_settings: any;
};

export const NaniteRemote = (props) => {
  return (
    <Window width={420} height={500}>
      <Window.Content scrollable>
        <NaniteRemoteContent />
      </Window.Content>
    </Window>
  );
};

export const NaniteRemoteContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    code,
    locked,
    mode,
    program_name,
    relay_code,
    comms,
    message,
    saved_settings = [],
  } = data;

  const modes = ['Off', 'Local', 'Targeted', 'Area', 'Relay'];
  // AQUILA: tryby to klucze z DM, tłumaczymy tylko napis
  const MODE_NAMES = {
    Off: 'Wył.',
    Local: 'Lokalny',
    Targeted: 'Celowany',
    Area: 'Obszarowy',
    Relay: 'Przekaźnik',
  };

  if (locked) {
    return <NoticeBox>Ten interfejs jest zablokowany.</NoticeBox>;
  }

  return (
    <>
      <Section
        title="Sterowanie nanitami"
        buttons={
          <Button
            icon="lock"
            content="Zablokuj interfejs"
            onClick={() => act('lock')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label="Nazwa">
            <Input
              value={program_name}
              maxLength={14}
              width="130px"
              onBlur={(value) =>
                act('update_name', {
                  name: value,
                })
              }
            />
            <Button icon="save" content="Zapisz" onClick={() => act('save')} />
          </LabeledList.Item>
          <LabeledList.Item label={comms ? 'Kod komunikacji' : 'Kod sygnału'}>
            <NumberInput
              value={code}
              minValue={0}
              maxValue={9999}
              width="47px"
              step={1}
              stepPixelSize={2}
              onChange={(value) =>
                act('set_code', {
                  code: value,
                })
              }
            />
          </LabeledList.Item>
          {!!comms && (
            <LabeledList.Item label="Wiadomość">
              <Input
                value={message}
                width="270px"
                onBlur={(value) =>
                  act('set_message', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
          )}
          {mode === 'Relay' && (
            <LabeledList.Item label="Kod przekaźnika">
              <NumberInput
                value={relay_code}
                minValue={0}
                maxValue={9999}
                width="47px"
                step={1}
                stepPixelSize={2}
                onChange={(value) =>
                  act('set_relay_code', {
                    code: value,
                  })
                }
              />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Tryb sygnału">
            {modes.map((key) => (
              <Button
                key={key}
                content={MODE_NAMES[key] || key}
                selected={mode === key}
                onClick={() =>
                  act('select_mode', {
                    mode: key,
                  })
                }
              />
            ))}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Zapisane ustawienia">
        {saved_settings.length > 0 ? (
          <Table>
            <Table.Row header>
              <Table.Cell width="35%">Nazwa</Table.Cell>
              <Table.Cell width="20%">Tryb</Table.Cell>
              <Table.Cell collapsing>Kod</Table.Cell>
              <Table.Cell collapsing>Przekaźnik</Table.Cell>
            </Table.Row>
            {saved_settings.map((setting) => (
              <Table.Row key={setting.id} className="candystripe">
                <Table.Cell bold color="label">
                  {setting.name}:
                </Table.Cell>
                <Table.Cell>
                  {MODE_NAMES[setting.mode] || setting.mode}
                </Table.Cell>
                <Table.Cell>{setting.code}</Table.Cell>
                <Table.Cell>
                  {setting.mode === 'Relay' && setting.relay_code}
                </Table.Cell>
                <Table.Cell textAlign="right">
                  <Button
                    icon="upload"
                    color="good"
                    onClick={() =>
                      act('load', {
                        save_id: setting.id,
                      })
                    }
                  />
                  <Button
                    icon="minus"
                    color="bad"
                    onClick={() =>
                      act('remove_save', {
                        save_id: setting.id,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        ) : (
          <NoticeBox>Brak zapisanych ustawień</NoticeBox>
        )}
      </Section>
    </>
  );
};
