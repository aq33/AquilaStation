import { Section, Stack, Tabs } from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { PatientStateView } from './PatientStateView';
import { SurgeryProceduresView } from './SurgeryProceduresView';
import {
  type CatalogOperation,
  ComputerTabs,
  type OperatingComputerData,
} from './types';

// Styl motywu jest w styles/interfaces/OperatingComputer.scss (ładowany w main.scss)

export const OperatingComputer = () => {
  const [tab, setTab] = useSharedState('tab', 1);
  const { data } = useBackend<OperatingComputerData>();
  const { surgery_catalog = [] } = data;

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: surgery_catalog,
    matchStrategy: 'aggressive',
    getSearchString: (item: CatalogOperation) =>
      `${item.name} ${item.tools.map((tool) => tool.name).join(' ')}`,
  });

  const [pinnedOperations, setPinnedOperations] = useSharedState<string[]>(
    'pinned_operation',
    [],
  );

  return (
    <Window
      width={tab === ComputerTabs.PatientState ? 350 : 470}
      height={610}
      theme="operating_computer"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === ComputerTabs.PatientState}
                onClick={() => setTab(ComputerTabs.PatientState)}
              >
                Stan pacjenta
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === ComputerTabs.OperationCatalog}
                onClick={() => setTab(ComputerTabs.OperationCatalog)}
              >
                Katalog operacji
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === ComputerTabs.PatientState && (
              <PatientStateView
                setTab={setTab}
                setSearchText={setQuery}
                pinnedOperations={pinnedOperations}
                setPinnedOperations={setPinnedOperations}
              />
            )}
            {tab === ComputerTabs.OperationCatalog && (
              <SurgeryProceduresView
                searchedSurgeries={results}
                searchText={query}
                setSearchText={setQuery}
                pinnedOperations={pinnedOperations}
                setPinnedOperations={setPinnedOperations}
              />
            )}
          </Stack.Item>
          <Stack.Item textAlign="right" color="label" fontSize="0.7em">
            <Section>
              DefOS 1.0 &copy; Nanotrasen-Deforest Corporation. Wszelkie prawa
              zastrzeżone.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
