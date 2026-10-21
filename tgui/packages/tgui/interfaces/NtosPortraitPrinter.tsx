import { useState } from 'react';
import {
  Button,
  Image,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Painting = {
  title: string;
  md5: string;
};

// Pusta kategoria przychodzi z DM jako 0
type Library = Painting[] | 0;

type Data = {
  library: Library;
  library_private: Library;
  library_secure: Library;
};

export const NtosPortraitPrinter = (props) => {
  const { act, data } = useBackend<Data>();
  const [tabIndex, setTabIndex] = useState(0);
  const [listIndex, setListIndex] = useState(0);
  const [searchText, setSearchText] = useState('');
  const { library, library_secure, library_private } = data;
  const TABS = [
    {
      name: 'Ogólne',
      asset_prefix: 'library',
      list: library,
    },
    {
      name: 'Chronione',
      asset_prefix: 'library_secure',
      list: library_secure,
    },
    {
      name: 'Prywatne',
      asset_prefix: 'library_private',
      list: library_private,
    },
  ];
  const currentTab = TABS[tabIndex];
  const fullList = currentTab.list || [];
  // Indeks z pełnej listy jest potrzebny DM przy drukowaniu
  const search = createSearch(searchText, (item: Painting) => item.title);
  const paintings = fullList
    .map((painting, index) => ({ painting, index }))
    .filter(({ painting }) => !searchText || search(painting));
  const gotPaintings = paintings.length > 0;
  const current = gotPaintings
    ? paintings[Math.min(listIndex, paintings.length - 1)]
    : null;
  return (
    <NtosWindow title="Galaktyka Sztuki" width={400} height={500}>
      <NtosWindow.Content>
        <Stack vertical fill>
          <Stack.Item>
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
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Input
                fluid
                placeholder="Szukaj obrazów..."
                value={searchText}
                onChange={(value) => {
                  setSearchText(value);
                  setListIndex(0);
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Section fill>
              <Stack
                height="100%"
                align="center"
                justify="center"
                direction="column"
              >
                {current ? (
                  <>
                    <Stack.Item>
                      <Image
                        src={resolveAsset(
                          `${currentTab.asset_prefix}_${current.painting.md5}`,
                        )}
                        height="128px"
                        width="128px"
                        style={{
                          verticalAlign: 'middle',
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item className="Section__titleText">
                      {current.painting.title}
                    </Stack.Item>
                  </>
                ) : (
                  <Stack.Item className="Section__titleText">
                    Nie znaleziono obrazów.
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item>
                  <Button
                    icon="angle-double-left"
                    disabled={listIndex === 0}
                    onClick={() => setListIndex(0)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    disabled={listIndex === 0}
                    icon="chevron-left"
                    onClick={() => setListIndex(listIndex - 1)}
                  />
                </Stack.Item>
                <Stack.Item grow textAlign="center">
                  <Button
                    icon="print"
                    disabled={!current}
                    onClick={() =>
                      current &&
                      act('select', {
                        tab: tabIndex + 1,
                        selected: current.index + 1,
                      })
                    }
                  >
                    Drukuj obraz
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="chevron-right"
                    disabled={listIndex >= paintings.length - 1}
                    onClick={() => setListIndex(listIndex + 1)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="angle-double-right"
                    disabled={listIndex >= paintings.length - 1}
                    onClick={() => setListIndex(paintings.length - 1)}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox info>
              Wydruk płótna zużywa 10 kartek papieru z drukarki w urządzeniu.
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
