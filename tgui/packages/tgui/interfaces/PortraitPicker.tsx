import { useState } from 'react';
import { Button, Flex, NoticeBox, Section, Tabs } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Painting = {
  title: string;
  md5: string;
};

// Nasz DM wysyła 0 zamiast listy, gdy w danej bibliotece nie ma obrazów.
type Data = {
  library: Painting[] | 0;
  library_private: Painting[] | 0;
  library_secure: Painting[] | 0;
};

// AQUILA: zostaje nasz podział na biblioteki (tg ma jedną listę z
// wyszukiwarką, która wymaga nowego systemu obrazów po stronie DM).
export const PortraitPicker = (props) => {
  const { act, data } = useBackend<Data>();
  const [tabIndex, setTabIndex] = useState(0);
  const [listIndex, setListIndex] = useState(0);
  const { library, library_secure, library_private } = data;
  const TABS = [
    {
      name: 'Ogólne',
      asset_prefix: 'library',
      list: library || [],
    },
    {
      name: 'Zabezpieczone',
      asset_prefix: 'library_secure',
      list: library_secure || [],
    },
    {
      name: 'Prywatne',
      asset_prefix: 'library_private',
      list: library_private || [],
    },
  ];
  const tab2list = TABS[tabIndex].list;
  const got_paintings = !!tab2list.length;
  const current = got_paintings ? tab2list[listIndex] : undefined;
  const current_portrait_title = current?.title;
  const current_portrait_asset_name =
    current && `${TABS[tabIndex].asset_prefix}_${current.md5}`;
  return (
    <Window theme="ntos" title="Wybór portretu" width={400} height={406}>
      <Window.Content>
        <Flex height="100%" direction="column">
          <Flex.Item mb={1}>
            <Section fitted>
              <Tabs fluid textAlign="center">
                {TABS.map((tabObj, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === tabIndex}
                    onClick={() => {
                      setListIndex(0);
                      setTabIndex(i);
                    }}
                  >
                    {tabObj.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item mb={1} grow={2}>
            <Section fill>
              <Flex
                height="100%"
                align="center"
                justify="center"
                direction="column"
              >
                {current_portrait_asset_name ? (
                  <>
                    <Flex.Item>
                      <img
                        src={resolveAsset(current_portrait_asset_name)}
                        height="128px"
                        width="128px"
                        style={{
                          verticalAlign: 'middle',
                          imageRendering: 'pixelated',
                        }}
                      />
                    </Flex.Item>
                    <Flex.Item className="Section__titleText">
                      {current_portrait_title}
                    </Flex.Item>
                  </>
                ) : (
                  <Flex.Item className="Section__titleText">
                    Nie znaleziono obrazów.
                  </Flex.Item>
                )}
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Flex>
              <Flex.Item grow={3}>
                <Section height="100%">
                  <Flex justify="space-between">
                    <Flex.Item grow={1}>
                      <Button
                        icon="angle-double-left"
                        disabled={listIndex === 0}
                        onClick={() => setListIndex(0)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={3}>
                      <Button
                        disabled={listIndex === 0}
                        icon="chevron-left"
                        onClick={() => setListIndex(listIndex - 1)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={3}>
                      <Button
                        icon="check"
                        disabled={!got_paintings}
                        onClick={() =>
                          act('select', {
                            tab: tabIndex + 1,
                            selected: listIndex + 1,
                          })
                        }
                      >
                        Wybierz portret
                      </Button>
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex >= tab2list.length - 1}
                        onClick={() => setListIndex(listIndex + 1)}
                      />
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex >= tab2list.length - 1}
                        onClick={() => setListIndex(tab2list.length - 1)}
                      />
                    </Flex.Item>
                  </Flex>
                </Section>
              </Flex.Item>
            </Flex>
            <Flex.Item mt={1}>
              <NoticeBox info>
                Wyświetlić można tylko obrazy z płócien 23x23 lub 24x24. Zanim
                zanurzysz się w cudowny świat ekspresji artystycznej, przeczytaj
                ostrzeżenie poniżej!
              </NoticeBox>
            </Flex.Item>
            <Flex.Item>
              <NoticeBox danger>
                OSTRZEŻENIE: Centrala kocha sztukę tak samo jak ty, ale wybór
                sztuki erotycznej będzie miał poważne konsekwencje. Centrala
                zastrzega sobie też prawo do żądania zmiany portretu z dowolnego
                powodu.
              </NoticeBox>
            </Flex.Item>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
