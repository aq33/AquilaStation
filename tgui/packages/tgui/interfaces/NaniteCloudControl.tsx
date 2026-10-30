import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';
import { naniteSettingName, naniteValueName } from './NaniteProgrammer';

type Data = {
  cloud_backup: any;
  cloud_backups: any;
  cloud_programs: any;
  current_view: any;
  disk: any;
  has_disk: any;
  has_program: any;
  new_backup_id: any;
};

export const NaniteDiskBox = (props) => {
  const { data } = useBackend<Data>();
  const { has_disk, has_program, disk } = data;

  if (!has_disk) {
    return <NoticeBox>Nie włożono dysku</NoticeBox>;
  }

  if (!has_program) {
    return <NoticeBox>Na włożonym dysku nie ma programu</NoticeBox>;
  }

  return <NaniteInfoBox program={disk} />;
};

export const NaniteInfoBox = (props) => {
  const { program } = props;

  const {
    name,
    desc,
    activated,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activation_code,
    deactivation_code,
    kill_code,
    trigger_code,
    timer_restart,
    timer_shutdown,
    timer_trigger,
    timer_trigger_delay,
  } = program;

  const extra_settings = program.extra_settings || [];

  return (
    <Section
      title={name}
      buttons={
        <Box inline bold color={activated ? 'good' : 'bad'}>
          {activated ? 'Aktywny' : 'Nieaktywny'}
        </Box>
      }
    >
      <Grid>
        <Grid.Column mr={1}>{desc}</Grid.Column>
        <Grid.Column size={0.5}>
          <LabeledList>
            <LabeledList.Item label="Zużycie">{use_rate}</LabeledList.Item>
            {!!can_trigger && (
              <>
                <LabeledList.Item label="Koszt wyzwolenia">
                  {trigger_cost}
                </LabeledList.Item>
                <LabeledList.Item label="Odnowienie wyzwolenia">
                  {trigger_cooldown}
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title="Kody" mr={1}>
            <LabeledList>
              <LabeledList.Item label="Aktywacja">
                {activation_code}
              </LabeledList.Item>
              <LabeledList.Item label="Dezaktywacja">
                {deactivation_code}
              </LabeledList.Item>
              <LabeledList.Item label="Zniszczenie">
                {kill_code}
              </LabeledList.Item>
              {!!can_trigger && (
                <LabeledList.Item label="Wyzwolenie">
                  {trigger_code}
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="Opóźnienia" mr={1}>
            <LabeledList>
              <LabeledList.Item label="Restart">
                {timer_restart} s
              </LabeledList.Item>
              <LabeledList.Item label="Wyłączenie">
                {timer_shutdown} s
              </LabeledList.Item>
              {!!can_trigger && (
                <>
                  <LabeledList.Item label="Wyzwolenie">
                    {timer_trigger} s
                  </LabeledList.Item>
                  <LabeledList.Item label="Opóźnienie wyzwolenia">
                    {timer_trigger_delay} s
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Section title="Dodatkowe ustawienia">
        <LabeledList>
          {extra_settings.map((setting) => {
            const naniteTypesDisplayMap = {
              number: (
                <>
                  {setting.value}
                  {setting.unit}
                </>
              ),
              text: setting.value,
              type: naniteValueName(setting.value, setting.name),
              boolean: setting.value ? setting.true_text : setting.false_text,
            };
            return (
              <LabeledList.Item
                key={setting.name}
                label={naniteSettingName(setting.name)}
              >
                {naniteTypesDisplayMap[setting.type]}
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
    </Section>
  );
};

export const NaniteCloudBackupList = (props) => {
  const { act, data } = useBackend<Data>();
  const cloud_backups = data.cloud_backups || [];
  return cloud_backups.map((backup) => (
    <Button
      fluid
      key={backup.cloud_id}
      content={'Kopia nr ' + backup.cloud_id}
      textAlign="center"
      onClick={() =>
        act('set_view', {
          view: backup.cloud_id,
        })
      }
    />
  ));
};

export const NaniteCloudBackupDetails = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_view, disk, has_program, cloud_backup } = data;

  const can_rule = (disk && disk.can_rule) || false;

  if (!cloud_backup) {
    return <NoticeBox>BŁĄD: nie znaleziono kopii</NoticeBox>;
  }

  const cloud_programs = data.cloud_programs || [];

  return (
    <Section
      title={'Kopia nr ' + current_view}
      buttons={
        !!has_program && (
          <Button
            icon="upload"
            content="Wgraj z dysku"
            color="good"
            onClick={() => act('upload_program')}
          />
        )
      }
    >
      {cloud_programs.map((program) => {
        const rules = program.rules || [];
        return (
          <Collapsible
            key={program.name}
            title={program.name}
            buttons={
              <Button
                icon="minus-circle"
                color="bad"
                onClick={() =>
                  act('remove_program', {
                    program_id: program.id,
                  })
                }
              />
            }
          >
            <Section>
              <NaniteInfoBox program={program} />
              {!!(can_rule || program.has_rules) && (
                <Section
                  mt={-2}
                  title="Reguły"
                  buttons={
                    !!can_rule && (
                      <Button
                        icon="plus"
                        content="Dodaj regułę z dysku"
                        color="good"
                        onClick={() =>
                          act('add_rule', {
                            program_id: program.id,
                          })
                        }
                      />
                    )
                  }
                >
                  {program.has_rules ? (
                    rules.map((rule) => (
                      <Box key={rule.display}>
                        <Button
                          icon="minus-circle"
                          color="bad"
                          onClick={() =>
                            act('remove_rule', {
                              program_id: program.id,
                              rule_id: rule.id,
                            })
                          }
                        />
                        {rule.display}
                      </Box>
                    ))
                  ) : (
                    <Box color="bad">Brak aktywnych reguł</Box>
                  )}
                </Section>
              )}
            </Section>
          </Collapsible>
        );
      })}
    </Section>
  );
};

export const NaniteCloudControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_disk, current_view, new_backup_id } = data;

  return (
    <Window width={375} height={700}>
      <Window.Content scrollable>
        <Section
          title="Dysk z programem"
          buttons={
            <Button
              icon="eject"
              content="Wysuń"
              disabled={!has_disk}
              onClick={() => act('eject')}
            />
          }
        >
          <NaniteDiskBox />
        </Section>
        <Section
          title="Pamięć w chmurze"
          buttons={
            current_view ? (
              <Button
                icon="arrow-left"
                content="Wróć"
                onClick={() =>
                  act('set_view', {
                    view: 0,
                  })
                }
              />
            ) : (
              <>
                {'Nowa kopia: '}
                <NumberInput
                  step={1}
                  value={new_backup_id}
                  minValue={1}
                  maxValue={100}
                  stepPixelSize={4}
                  width="39px"
                  onChange={(value) =>
                    act('update_new_backup_value', {
                      value: value,
                    })
                  }
                />
                <Button icon="plus" onClick={() => act('create_backup')} />
              </>
            )
          }
        >
          {!data.current_view ? (
            <NaniteCloudBackupList />
          ) : (
            <NaniteCloudBackupDetails />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
