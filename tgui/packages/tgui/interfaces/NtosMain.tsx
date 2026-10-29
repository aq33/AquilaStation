import { Button, ColorBox, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Program = {
  name: string;
  desc: string;
  running: boolean;
  icon: string;
  alert: boolean;
};

type Login = {
  IDName?: string;
  IDJob?: string;
};

type Data = {
  PC_device_theme: string;
  show_imprint: boolean;
  programs: Program[];
  has_light: boolean;
  light_on: boolean;
  comp_light_color: string;
  removable_media: string[];
  // AQUILA: czytnik ID jest osobnym podzespołem, a nadruk może być automatyczny
  cardholder: boolean;
  auto_imprint: boolean;
  login: Login;
  proposed_login: Login;
  // AQUILA: dysk z programami pracy (role SSD)
  disk: unknown;
  disk_name: string;
  disk_programs: Program[];
  stored_pai: boolean;
  stored_pai_name: string;
};

// Nazwy nośników przychodzą z DM i są też parametrem akcji, więc tłumaczymy tylko wyświetlanie.
const MEDIA_NAMES: Record<string, string> = {
  'removable storage disk': 'Wysuń dysk przenośny',
  intelliCard: 'Wysuń intelliCard',
  'secondary RFID card': 'Wysuń drugą kartę RFID',
};

export const NtosMain = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    PC_device_theme,
    show_imprint,
    has_light,
    light_on,
    comp_light_color,
    removable_media = [],
    cardholder,
    auto_imprint,
    login = {},
    proposed_login = {},
    disk,
    disk_name,
    disk_programs = [],
    stored_pai,
    stored_pai_name,
  } = data;

  return (
    <NtosWindow
      title={
        (PC_device_theme === 'syndicate' && 'Menu główne Syndix') ||
        'Menu główne NtOS'
      }
      width={400}
      height={500}
    >
      <NtosWindow.Content scrollable>
        {!!removable_media.length && (
          <Section>
            <Stack wrap>
              {removable_media.map((device) => (
                <Stack.Item key={device}>
                  <Button
                    icon="eject"
                    onClick={() => act('PC_Eject_Disk', { name: device })}
                    disabled={!device}
                  >
                    {MEDIA_NAMES[device] || device}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        )}
        <Section title="Szczegóły">
          {/* AQUILA: przyciski w treści, a nie w nagłówku: w tgui-core 6 nagłówek ich nie zawija i zasłaniały tytuł */}
          {(!!has_light || !!cardholder) && (
            <Stack wrap mb={1}>
              {!!has_light && (
                <>
                  <Stack.Item>
                    <Button
                      tooltip="Kolor latarki"
                      onClick={() => act('PC_light_color')}
                    >
                      <ColorBox color={comp_light_color} />
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="lightbulb"
                      color={light_on ? 'good' : 'bad'}
                      selected={light_on}
                      tooltip={light_on ? 'Wyłącz latarkę' : 'Włącz latarkę'}
                      onClick={() => act('PC_toggle_light')}
                    />
                  </Stack.Item>
                </>
              )}
              {!!cardholder && (
                <Stack.Item>
                  <Button
                    icon="eject"
                    disabled={!proposed_login.IDName}
                    onClick={() => act('PC_Eject_Disk', { name: 'ID' })}
                  >
                    Wysuń ID
                  </Button>
                </Stack.Item>
              )}
              {!!cardholder && !!show_imprint && (
                <>
                  <Stack.Item>
                    <Button
                      icon="dna"
                      disabled={
                        !proposed_login.IDName ||
                        (proposed_login.IDName === login.IDName &&
                          proposed_login.IDJob === login.IDJob)
                      }
                      onClick={() => act('PC_Imprint_ID', { name: 'ID' })}
                    >
                      Nadrukuj ID
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button.Checkbox
                      checked={auto_imprint}
                      tooltip="Automatycznie nadrukowuj włożone ID"
                      onClick={() => act('PC_Toggle_Auto_Imprint')}
                    >
                      Auto
                    </Button.Checkbox>
                  </Stack.Item>
                </>
              )}
            </Stack>
          )}
          {cardholder ? (
            <Table>
              <Table.Row>
                Właściciel: {login.IDName}
                {proposed_login.IDName ? ` (${proposed_login.IDName})` : ''}
              </Table.Row>
              <Table.Row>
                Stanowisko: {login.IDJob}
                {proposed_login.IDJob ? ` (${proposed_login.IDJob})` : ''}
              </Table.Row>
            </Table>
          ) : (
            'Brak czytnika kart ID.'
          )}
        </Section>
        {!!stored_pai && (
          <Section title={stored_pai_name ? `pAI (${stored_pai_name})` : 'pAI'}>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="eject"
                    color="transparent"
                    onClick={() =>
                      act('PC_Pai_Interact', {
                        option: 'eject',
                      })
                    }
                  >
                    Wysuń pAI
                  </Button>
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="cat"
                    color="transparent"
                    onClick={() =>
                      act('PC_Pai_Interact', {
                        option: 'interact',
                      })
                    }
                  >
                    Konfiguruj pAI
                  </Button>
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        )}
        <ProgramsTable />
        {!!disk && (
          <Section
            title={
              disk_name
                ? disk_name.substring(0, disk_name.length - 5)
                : 'Brak dysku pracy'
            }
            buttons={
              <Button
                icon="eject"
                disabled={!disk_name}
                onClick={() => act('PC_Eject_Disk', { name: 'job disk' })}
              >
                Wysuń dysk pracy
              </Button>
            }
          >
            <ProgramList programs={disk_programs} is_disk />
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const ProgramsTable = (props) => {
  const { data } = useBackend<Data>();
  const { programs = [] } = data;

  return (
    <Section title="Programy">
      <ProgramList programs={programs} is_disk={false} />
    </Section>
  );
};

const ProgramList = (props: { programs: Program[]; is_disk: boolean }) => {
  const { act } = useBackend();
  const { programs, is_disk } = props;

  return (
    <Table>
      {programs.map((program) => (
        <Table.Row key={program.name}>
          <Table.Cell>
            <Button
              fluid
              color={program.alert ? 'yellow' : 'transparent'}
              icon={program.icon}
              onClick={() =>
                act('PC_runprogram', {
                  name: program.name,
                  is_disk: is_disk,
                })
              }
            >
              {program.desc}
            </Button>
          </Table.Cell>
          <Table.Cell collapsing width="18px">
            {!!program.running && (
              <Button
                color="transparent"
                icon="times"
                tooltip="Zamknij program"
                tooltipPosition="left"
                onClick={() =>
                  act('PC_killprogram', {
                    name: program.name,
                  })
                }
              />
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
