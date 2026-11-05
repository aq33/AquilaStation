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
  cloud_id: any;
  has_nanites: any;
  locked: any;
  mob_programs: any;
  nanite_volume: any;
  occupant_name: any;
  regen_rate: any;
  safety_threshold: any;
  scan_level: any;
  status_msg: any;
};

export const NaniteChamberControl = (props) => {
  return (
    <Window width={380} height={570}>
      <Window.Content scrollable>
        <NaniteChamberControlContent />
      </Window.Content>
    </Window>
  );
};

export const NaniteChamberControlContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    status_msg,
    locked,
    occupant_name,
    has_nanites,
    nanite_volume,
    regen_rate,
    safety_threshold,
    cloud_id,
    scan_level,
  } = data;

  if (status_msg) {
    return <NoticeBox textAlign="center">{status_msg}</NoticeBox>;
  }

  const mob_programs = data.mob_programs || [];

  return (
    <Section
      title={'Komora: ' + occupant_name}
      buttons={
        <Button
          icon={locked ? 'lock' : 'lock-open'}
          content={locked ? 'Zablokowana' : 'Odblokowana'}
          color={locked ? 'bad' : 'default'}
          onClick={() => act('toggle_lock')}
        />
      }
    >
      {!has_nanites ? (
        <>
          <Box bold color="bad" textAlign="center" fontSize="30px" mb={1}>
            Nie wykryto nanitów
          </Box>
          <Button
            fluid
            bold
            icon="syringe"
            content=" Wszczep nanity"
            color="green"
            textAlign="center"
            fontSize="30px"
            lineHeight="50px"
            onClick={() => act('nanite_injection')}
          />
        </>
      ) : (
        <>
          <Section
            title="Stan"
            buttons={
              <Button
                icon="exclamation-triangle"
                content="Zniszcz nanity"
                color="bad"
                onClick={() => act('remove_nanites')}
              />
            }
          >
            <Grid>
              <Grid.Column>
                <LabeledList>
                  <LabeledList.Item label="Ilość nanitów">
                    {nanite_volume}
                  </LabeledList.Item>
                  <LabeledList.Item label="Tempo wzrostu">
                    {regen_rate}
                  </LabeledList.Item>
                </LabeledList>
              </Grid.Column>
              <Grid.Column>
                <LabeledList>
                  <LabeledList.Item label="Próg bezpieczeństwa">
                    <NumberInput
                      step={1}
                      value={safety_threshold}
                      minValue={0}
                      maxValue={500}
                      width="39px"
                      onChange={(value) =>
                        act('set_safety', {
                          value: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="ID chmury">
                    <NumberInput
                      value={cloud_id}
                      minValue={0}
                      maxValue={100}
                      step={1}
                      stepPixelSize={3}
                      width="39px"
                      onChange={(value) =>
                        act('set_cloud', {
                          value: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Grid.Column>
            </Grid>
          </Section>
          <Section title="Programy">
            {mob_programs.map((program) => {
              const extra_settings = program.extra_settings || [];
              const rules = program.rules || [];
              return (
                <Collapsible key={program.name} title={program.name}>
                  <Section>
                    <Grid>
                      <Grid.Column>{program.desc}</Grid.Column>
                      {scan_level >= 2 && (
                        <Grid.Column size={0.6}>
                          <LabeledList>
                            <LabeledList.Item label="Stan aktywacji">
                              <Box color={program.activated ? 'good' : 'bad'}>
                                {program.activated ? 'Aktywny' : 'Nieaktywny'}
                              </Box>
                            </LabeledList.Item>
                            <LabeledList.Item label="Zużycie nanitów">
                              {program.use_rate}/s
                            </LabeledList.Item>
                          </LabeledList>
                        </Grid.Column>
                      )}
                    </Grid>
                    {scan_level >= 2 && (
                      <Grid>
                        {!!program.can_trigger && (
                          <Grid.Column>
                            <Section title="Wyzwalacze">
                              <LabeledList>
                                <LabeledList.Item label="Koszt wyzwolenia">
                                  {program.trigger_cost}
                                </LabeledList.Item>
                                <LabeledList.Item label="Odnowienie wyzwolenia">
                                  {program.trigger_cooldown}
                                </LabeledList.Item>
                                {!!program.timer_trigger_delay && (
                                  <LabeledList.Item label="Opóźnienie wyzwolenia">
                                    {program.timer_trigger_delay} s
                                  </LabeledList.Item>
                                )}
                                {!!program.timer_trigger && (
                                  <LabeledList.Item label="Powtarzanie wyzwolenia">
                                    {program.timer_trigger} s
                                  </LabeledList.Item>
                                )}
                              </LabeledList>
                            </Section>
                          </Grid.Column>
                        )}
                        {!!(
                          program.timer_restart || program.timer_shutdown
                        ) && (
                          <Grid.Column>
                            <Section>
                              <LabeledList>
                                {/* I mean, bruh, this indentation level
                                    is ABSOLUTELY INSANE!!! */}
                                {program.timer_restart && (
                                  <LabeledList.Item label="Czas do restartu">
                                    {program.timer_restart} s
                                  </LabeledList.Item>
                                )}
                                {program.timer_shutdown && (
                                  <LabeledList.Item label="Czas do wyłączenia">
                                    {program.timer_shutdown} s
                                  </LabeledList.Item>
                                )}
                              </LabeledList>
                            </Section>
                          </Grid.Column>
                        )}
                      </Grid>
                    )}
                    {scan_level >= 3 && !!program.has_extra_settings && (
                      <Section title="Dodatkowe ustawienia">
                        <LabeledList>
                          {extra_settings.map((extra_setting) => (
                            <LabeledList.Item
                              key={extra_setting.name}
                              label={naniteSettingName(extra_setting.name)}
                            >
                              {extra_setting.type === 'type'
                                ? naniteValueName(
                                    extra_setting.value,
                                    extra_setting.name,
                                  )
                                : extra_setting.value}
                            </LabeledList.Item>
                          ))}
                        </LabeledList>
                      </Section>
                    )}
                    {scan_level >= 4 && (
                      <Grid>
                        <Grid.Column>
                          <Section title="Kody">
                            <LabeledList>
                              {!!program.activation_code && (
                                <LabeledList.Item label="Aktywacja">
                                  {program.activation_code}
                                </LabeledList.Item>
                              )}
                              {!!program.deactivation_code && (
                                <LabeledList.Item label="Dezaktywacja">
                                  {program.deactivation_code}
                                </LabeledList.Item>
                              )}
                              {!!program.kill_code && (
                                <LabeledList.Item label="Zniszczenie">
                                  {program.kill_code}
                                </LabeledList.Item>
                              )}
                              {!!program.can_trigger &&
                                !!program.trigger_code && (
                                  <LabeledList.Item label="Wyzwolenie">
                                    {program.trigger_code}
                                  </LabeledList.Item>
                                )}
                            </LabeledList>
                          </Section>
                        </Grid.Column>
                        {program.has_rules && (
                          <Grid.Column>
                            <Section title="Reguły">
                              {rules.map((rule) => (
                                <Box key={rule.display}>{rule.display}</Box>
                              ))}
                            </Section>
                          </Grid.Column>
                        )}
                      </Grid>
                    )}
                  </Section>
                </Collapsible>
              );
            })}
          </Section>
        </>
      )}
    </Section>
  );
};
