import { map } from 'common/collections';
import {
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Data = Record<string, any>;

// Kategorie to klucze z designów nanitów (category[1]) - do DM nic z tego
// nie wraca, tłumaczymy tylko etykietę zakładki.
const CATEGORY_PL: Record<string, string> = {
  'Utility Nanites': 'Użytkowe',
  'Medical Nanites': 'Medyczne',
  'Sensor Nanites': 'Czujnikowe',
  'Augmentation Nanites': 'Wzmacniające',
  'Suppression Nanites': 'Tłumiące',
  'Weaponized Nanites': 'Bojowe',
  'Defective Nanites': 'Wadliwe',
  Protocols: 'Protokoły',
};

export const NaniteProgramHub = (props) => {
  const { act, data } = useBackend<Data>();
  const { detail_view, disk, has_disk, has_program, programs = {} } = data;
  const [selectedCategory, setSelectedCategory] = useSharedState<any>(
    'category',
    undefined,
  );
  const programsInCategory = (programs && programs[selectedCategory]) || [];
  return (
    <Window width={500} height={700}>
      <Window.Content scrollable>
        <Section
          title="Dysk z programem"
          buttons={
            <>
              <Button
                icon="eject"
                content="Wysuń"
                onClick={() => act('eject')}
              />
              <Button
                icon="minus-circle"
                content="Usuń program"
                onClick={() => act('clear')}
              />
            </>
          }
        >
          {has_disk ? (
            has_program ? (
              <LabeledList>
                <LabeledList.Item label="Nazwa programu">
                  {disk.name}
                </LabeledList.Item>
                <LabeledList.Item label="Opis">{disk.desc}</LabeledList.Item>
              </LabeledList>
            ) : (
              <NoticeBox>Brak zainstalowanego programu</NoticeBox>
            )
          ) : (
            <NoticeBox>Włóż dysk</NoticeBox>
          )}
        </Section>
        <Section
          title="Programy"
          buttons={
            <>
              <Button
                icon={detail_view ? 'info' : 'list'}
                content={detail_view ? 'Szczegółowy' : 'Zwięzły'}
                onClick={() => act('toggle_details')}
              />
              <Button
                icon="sync"
                content="Synchronizuj badania"
                onClick={() => act('refresh')}
              />
            </>
          }
        >
          {programs !== null ? (
            <Flex>
              <Flex.Item minWidth="110px">
                <Tabs vertical>
                  {map((cat_contents, category) => {
                    const progs = cat_contents || [];
                    const tabLabel =
                      CATEGORY_PL[category] ??
                      category.replace(/ Nanites$/, '');
                    return (
                      <Tabs.Tab
                        key={category}
                        selected={category === selectedCategory}
                        onClick={() => setSelectedCategory(category)}
                      >
                        {tabLabel}
                      </Tabs.Tab>
                    );
                  })(programs)}
                </Tabs>
              </Flex.Item>
              <Flex.Item grow={1} basis={0}>
                {detail_view ? (
                  programsInCategory.map((program) => (
                    <Section
                      key={program.id}
                      title={program.name}
                      buttons={
                        <Button
                          icon="download"
                          content="Pobierz"
                          disabled={!has_disk}
                          onClick={() =>
                            act('download', {
                              program_id: program.id,
                            })
                          }
                        />
                      }
                    >
                      {program.desc}
                    </Section>
                  ))
                ) : (
                  <LabeledList>
                    {programsInCategory.map((program) => (
                      <LabeledList.Item
                        key={program.id}
                        label={program.name}
                        buttons={
                          <Button
                            icon="download"
                            content="Pobierz"
                            disabled={!has_disk}
                            onClick={() =>
                              act('download', {
                                program_id: program.id,
                              })
                            }
                          />
                        }
                      />
                    ))}
                  </LabeledList>
                )}
              </Flex.Item>
            </Flex>
          ) : (
            <NoticeBox>
              Nie zbadano jeszcze żadnych programów nanitów.
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
