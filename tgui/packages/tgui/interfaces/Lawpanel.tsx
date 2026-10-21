import { countBy } from 'es-toolkit';
import { useMemo } from 'react';
import {
  Button,
  Collapsible,
  Dimmer,
  Flex,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const lawtype_to_color = {
  inherent: 'white',
  supplied: 'purple',
  hacked: 'orange',
  zeroth: 'red',
  // AQUILA: nasze dodatkowe rodzaje praw
  ion: 'blue',
  devil: 'brown',
} as const;

type Law = {
  lawtype: string;
  // The actual law text
  law: string;
  // Law index in the list
  // Zeroth laws will always be "zero"
  // and hacked/ion laws will have an index of -1
  num: number;
};

type Silicon = {
  // Name of the silicon. Includes PAI and AI
  borg_name: string;
  borg_type: string;
  // List of our laws, this is almost never null. If it is null, that's an error.
  laws: null | Law[];
  // String, name of our master AI. Null means no master or we're not a borg
  master_ai?: null | string;
  // TRUE, we're law-synced to our master AI. FALSE, we're not, null, we're not a borg
  borg_synced?: null | BooleanLike;
  // REF() to our silicon
  ref: string;
};

type Data = {
  all_silicons: Silicon[];
};

const SyncedBorgDimmer = (props: { master: string }) => {
  return (
    <Dimmer>
      <Stack textAlign="center" vertical>
        <Stack.Item>
          <Icon color="green" name="wifi" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px">
          Ten cyborg jest połączony z &quot;{props.master}&quot;.
        </Stack.Item>
        <Stack.Item fontSize="14px">Zmień prawa tamtej SI.</Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const LawPrintout = (props: { cyborg_ref: string; lawset: Law[] }) => {
  const { act } = useBackend<Law>();
  const { cyborg_ref, lawset } = props;

  const num_of_each_lawtype = useMemo(() => {
    return countBy(lawset, (law) => law.lawtype);
  }, [lawset]);

  return (
    <LabeledList>
      {lawset.map((law, index) => (
        <>
          <LabeledList.Item
            key={index}
            label={law.num >= 0 ? `${law.num}` : '?!$'}
            color={lawtype_to_color[law.lawtype] || 'pink'}
            buttons={
              <Stack>
                <Stack.Item>
                  <Button.Confirm
                    icon="trash"
                    confirmContent=""
                    confirmIcon="check"
                    color={'red'}
                    onClick={() =>
                      act('remove_law', {
                        ref: cyborg_ref,
                        law: law.law,
                        lawtype: law.lawtype,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color={'green'}
                    onClick={() =>
                      act('edit_law_text', {
                        ref: cyborg_ref,
                        law: law.law,
                        lawtype: law.lawtype,
                      })
                    }
                  >
                    Edytuj
                  </Button>
                </Stack.Item>
                {law.lawtype === 'inherent' && (
                  <>
                    <Stack.Item>
                      <Button
                        icon="arrow-up"
                        color={'green'}
                        disabled={law.num === 1}
                        onClick={() =>
                          act('move_law', {
                            ref: cyborg_ref,
                            law: law.law,
                            // AQUILA: u nas "up" = wyżej na liście
                            direction: 'up',
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-down"
                        color={'green'}
                        disabled={law.num === num_of_each_lawtype.inherent}
                        onClick={() =>
                          act('move_law', {
                            ref: cyborg_ref,
                            law: law.law,
                            direction: 'down',
                          })
                        }
                      />
                    </Stack.Item>
                  </>
                )}
              </Stack>
            }
          >
            {law.law}
          </LabeledList.Item>
          <LabeledList.Divider />
        </>
      ))}
      <LabeledList.Item label="???">
        <Button
          icon="plus"
          color={'green'}
          content={'Dodaj prawo'}
          onClick={() => act('add_law', { ref: cyborg_ref })}
        />
      </LabeledList.Item>
      <LabeledList.Divider />
    </LabeledList>
  );
};

export const SiliconReadout = (props: { cyborg: Silicon }) => {
  const { data, act } = useBackend<Silicon>();
  const { cyborg } = props;

  return (
    <Flex>
      <Flex.Item grow>
        <Collapsible title={`${cyborg.borg_type}: ${cyborg.borg_name}`}>
          <Section backgroundColor={'black'}>
            {cyborg.master_ai && !!cyborg.borg_synced && (
              <SyncedBorgDimmer master={cyborg.master_ai} />
            )}
            <Stack vertical>
              <Stack.Item>
                {cyborg.laws === null ? (
                  <Button
                    fluid
                    textAlign="center"
                    color="danger"
                    content={`Ta jednostka nie ma zestawu praw (null). To nie
                      powinno się zdarzyć! Zgłoś błąd, a potem kliknij,
                      żeby nadać jej nowy.`}
                    onClick={() => act('give_law_datum', { ref: cyborg.ref })}
                  />
                ) : (
                  <LawPrintout lawset={cyborg.laws} cyborg_ref={cyborg.ref} />
                )}
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="bullhorn"
                      content={'Wymuś ogłoszenie praw'}
                      tooltip={`Zmusza jednostkę do ogłoszenia
                        wszystkich swoich praw.`}
                      onClick={() =>
                        act('force_state_laws', { ref: cyborg.ref })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="message"
                      content={'Pokaż prawa jednostce'}
                      tooltip={`Wyświetla wszystkie prawa jednostki
                        na jej czacie. U SI także wszystkim
                        połączonym cyborgom.`}
                      onClick={() =>
                        act('announce_law_changes', { ref: cyborg.ref })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="bell"
                      content={'Alert „Zmiana praw”'}
                      tooltip={`Pokazuje jednostce alert o zmianie praw,
                        wypisuje prawa na czacie i powiadamia
                        deadchat.`}
                      onClick={() =>
                        act('laws_updated_alert', { ref: cyborg.ref })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        </Collapsible>
      </Flex.Item>
    </Flex>
  );
};

export const Lawpanel = (props) => {
  const { data, act } = useBackend<Data>();
  const { all_silicons } = data;

  return (
    <Window title="Panel praw" theme="admin" width={800} height={600}>
      <Window.Content>
        <Section fill title="Prawa wszystkich jednostek krzemowych" scrollable>
          <Stack vertical>
            {all_silicons.length ? (
              all_silicons.map((silicon, index) => (
                <Stack.Item key={index}>
                  <SiliconReadout cyborg={silicon} />
                </Stack.Item>
              ))
            ) : (
              <Stack.Item>
                <NoticeBox>Nie istnieje żadna jednostka krzemowa.</NoticeBox>
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
