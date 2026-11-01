// NSV13

import { Fragment } from 'react';
import { Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  squads_info: any;
};

export const NtosSquadManager = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <NtosWindow resizable width={750} height={800}>
      <NtosWindow.Content scrollable>
        {Object.keys(data.squads_info).map((key) => {
          let value = data.squads_info[key];
          return (
            <Section
              title={`${value.name} - ${value.role_name ?? value.role}`}
              key={key}
              buttons={
                <>
                  <Button
                    content="Wiadomość"
                    icon="reply"
                    onClick={() => act('message', { squad_id: value.id })}
                  />
                  <Button
                    content={
                      value.access_enabled ? 'Pełny dostęp' : 'Brak dostępu'
                    }
                    color={value.access_enabled ? 'good' : 'average'}
                    icon="id-card"
                    tooltip="Czy drużyna może globalnie korzystać z rozszerzonego dostępu. Zwykle obejmuje to dostęp do amunicji."
                    onClick={() => act('toggle_access', { squad_id: value.id })}
                  />
                  <Button
                    content={
                      value.weapons_clearance
                        ? 'Zezwolenie na broń'
                        : 'Brak zezwolenia na broń'
                    }
                    icon={value.weapons_clearance ? 'fist-raised' : 'peace'}
                    color={value.weapons_clearance ? 'bad' : 'good'}
                    tooltip="Czy drużyna ma dostęp do lekkiej broni w automatach drużyny. Broń szturmową wydaje naczelnik."
                    onClick={() =>
                      act('toggle_beararms', { squad_id: value.id })
                    }
                  />
                </>
              }
            >
              <p>{value.desc}</p>
              <Table>
                <Table.Row>
                  <Table.Cell width="50%">
                    <Section
                      title="Rozkazy główne"
                      buttons={
                        <Button
                          content="Zmień"
                          color={value.role ? 'good' : 'average'}
                          icon="bullseye"
                          tooltip="Ustaw główny cel dla tej drużyny."
                          onClick={() =>
                            act('primary_objective', { squad_id: value.id })
                          }
                        />
                      }
                    >
                      {!!value.role && (value.role_name ?? value.role)}
                    </Section>
                  </Table.Cell>
                  <Table.Cell width="50%">
                    <Section
                      title="Rozkazy dodatkowe"
                      buttons={
                        <Button
                          content="Zmień"
                          icon="dot-circle"
                          color={value.secondary_objective ? 'good' : 'average'}
                          tooltip="Ustaw dodatkowy cel dla tej drużyny."
                          onClick={() =>
                            act('secondary_objective', { squad_id: value.id })
                          }
                        />
                      }
                    >
                      {!!value.secondary_objective && value.secondary_objective}
                    </Section>
                  </Table.Cell>
                </Table.Row>
              </Table>
              <Section
                title="Członkowie"
                buttons={
                  <>
                    <Button
                      content={
                        value.hidden ? 'Bez autoprzydziału' : 'Autoprzydział'
                      }
                      icon={value.hidden ? 'eye-slash' : 'eye'}
                      color={value.hidden ? 'bad' : 'good'}
                      tooltip="Włącz automatyczny przydział nowej załogi dołączającej do zmiany do tej drużyny."
                      onClick={() =>
                        act('toggle_hidden', { squad_id: value.id })
                      }
                    />
                    <Button
                      content="Drukuj smycz"
                      tooltip="Wydrukuj smycz, żeby ktoś mógł dołączyć do drużyny. Wystarczy, że kliknie ją w ręce!"
                      icon="print"
                      color="good"
                      onClick={() => act('print_pass', { squad_id: value.id })}
                    />
                  </>
                }
              >
                <Table>
                  <Table.Row header>
                    <Table.Cell width="50%">Dowódca</Table.Cell>
                    <Table.Cell width="50%">Skład</Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell width="50%">
                      {!!value.squad_leader_id && (
                        <LabeledList>
                          <LabeledList.Item label={value.squad_leader_name}>
                            <Button
                              content="Zdegraduj"
                              icon={'user-cog'}
                              onClick={() =>
                                act('demote_leader', {
                                  id: value.squad_leader_id,
                                })
                              }
                            />
                            <Button
                              content="Przenieś"
                              icon={'arrows-alt'}
                              onClick={() =>
                                act('transfer', { id: value.squad_leader_id })
                              }
                            />
                          </LabeledList.Item>
                        </LabeledList>
                      )}
                    </Table.Cell>
                    <Table.Cell width="50%">
                      <Section>
                        {Object.keys(value.members).map((key) => {
                          let member = value.members[key];
                          return (
                            <LabeledList key={key}>
                              {!!member.name && (
                                <LabeledList.Item label={member.name}>
                                  <Button
                                    content="Awansuj"
                                    icon={'user-cog'}
                                    onClick={() =>
                                      act('set_leader', { id: member.id })
                                    }
                                  />
                                  <Button
                                    content="Przenieś"
                                    icon={'arrows-alt'}
                                    onClick={() =>
                                      act('transfer', { id: member.id })
                                    }
                                  />
                                </LabeledList.Item>
                              )}
                            </LabeledList>
                          );
                        })}
                      </Section>
                    </Table.Cell>
                  </Table.Row>
                </Table>
              </Section>
            </Section>
          );
        })}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
