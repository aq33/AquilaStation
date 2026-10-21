import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { NoticeBox, Stack, Tabs } from 'tgui-core/components';

import { AvailableDisplay } from './Available';
import { PAI_TAB } from './constants';
import { DirectiveDisplay } from './Directives';
import { InstalledDisplay } from './Installed';
import { SystemDisplay } from './System';
import type { PaiData } from './types';

export function PaiInterface(props) {
  const { data } = useBackend<PaiData>();
  const [tab, setTab] = useState(PAI_TAB.System);

  return (
    <Window title="Interfejs oprogramowania pAI v2.5" width={420} height={560}>
      <Window.Content>
        {data.dead ? (
          <NoticeBox danger>
            ÈRrÖR Ða†Ä ÇÖRrÚþ†Ìoñ – nie znaleziono hasha indeksu programów
          </NoticeBox>
        ) : (
          <Stack fill vertical>
            <Stack.Item grow>
              {tab === PAI_TAB.System && <SystemDisplay />}
              {tab === PAI_TAB.Directive && <DirectiveDisplay />}
              {tab === PAI_TAB.Installed && <InstalledDisplay />}
              {tab === PAI_TAB.Available && <AvailableDisplay />}
            </Stack.Item>
            <Stack.Item>
              <Tabs fluid>
                <Tabs.Tab
                  icon="list"
                  onClick={() => setTab(PAI_TAB.System)}
                  selected={tab === PAI_TAB.System}
                >
                  System
                </Tabs.Tab>
                <Tabs.Tab
                  icon="list"
                  onClick={() => setTab(PAI_TAB.Directive)}
                  selected={tab === PAI_TAB.Directive}
                >
                  Dyrektywy
                </Tabs.Tab>
                <Tabs.Tab
                  icon="list"
                  onClick={() => setTab(PAI_TAB.Installed)}
                  selected={tab === PAI_TAB.Installed}
                >
                  Programy
                </Tabs.Tab>
                <Tabs.Tab
                  icon="list"
                  onClick={() => setTab(PAI_TAB.Available)}
                  selected={tab === PAI_TAB.Available}
                >
                  Pobieranie
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
}
