import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import { Flex, Input, Section, Tabs, VirtualList } from 'tgui-core/components';

import { useRemappedBackend } from './helpers';
import { TechNode } from './nodes/TechNode';
import type { TechwebNode } from './types';

enum Tab {
  RESEARCHED,
  AVAILABLE,
  FUTURE,
  // AQUILA: widok trzech kolumn obok siebie (z NSV13)
  COLUMNS,
}

export function TechwebOverview(props) {
  const { data } = useRemappedBackend();
  const { nodes, node_cache, design_cache } = data;
  const [tabIndex, setTabIndex] = useState(Tab.COLUMNS);
  const [searchText, setSearchText] = useState('');

  // Only search when 2 or more characters have been input
  const query = searchText.trim().toLowerCase();
  const searching = query.length > 1;

  const byName = (list: TechwebNode[]) =>
    sortBy(list, [(x) => node_cache[x.id].name]);
  const ofTier = (tier: Tab) =>
    byName(
      tier < Tab.FUTURE
        ? nodes.filter((x) => x.tier === tier)
        : nodes.filter((x) => (x.tier ?? 0) >= Tab.FUTURE),
    );

  let displayedNodes = nodes;
  if (searching) {
    displayedNodes = nodes.filter((x) => {
      const n = node_cache[x.id];
      return (
        n.name.toLowerCase().includes(query) ||
        n.description.toLowerCase().includes(query) ||
        n.design_ids.some((e) =>
          design_cache[e]?.name.toLowerCase().includes(query),
        )
      );
    });
  } else if (tabIndex !== Tab.COLUMNS) {
    displayedNodes = ofTier(tabIndex);
  }

  function switchTab(tab: Tab) {
    setTabIndex(tab);
    setSearchText('');
  }

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Sieć badań
          </Flex.Item>
          <Flex.Item grow>
            <Tabs>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.COLUMNS}
                onClick={() => switchTab(Tab.COLUMNS)}
              >
                Przegląd
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.RESEARCHED}
                onClick={() => switchTab(Tab.RESEARCHED)}
              >
                Zbadane
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.AVAILABLE}
                onClick={() => switchTab(Tab.AVAILABLE)}
              >
                Dostępne
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.FUTURE}
                onClick={() => switchTab(Tab.FUTURE)}
              >
                Przyszłe
              </Tabs.Tab>
              {!!searching && <Tabs.Tab selected>Wyniki wyszukiwania</Tabs.Tab>}
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Input
              value={searchText}
              onChange={setSearchText}
              placeholder="Szukaj..."
              expensive
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__OverviewNodes" grow minHeight={0}>
        {!searching && tabIndex === Tab.COLUMNS ? (
          <Flex height="100%">
            {[Tab.RESEARCHED, Tab.AVAILABLE, Tab.FUTURE].map((tier) => (
              <Flex.Item key={tier} grow basis={0} mr={1}>
                <Section
                  fill
                  scrollable
                  title={
                    (tier === Tab.RESEARCHED && 'Zbadane') ||
                    (tier === Tab.AVAILABLE && 'Dostępne') ||
                    'Przyszłe'
                  }
                >
                  <VirtualList>
                    {ofTier(tier).map((n) => (
                      <TechNode node={n} key={n.id} />
                    ))}
                  </VirtualList>
                </Section>
              </Flex.Item>
            ))}
          </Flex>
        ) : (
          <Section fill scrollable>
            <VirtualList>
              {displayedNodes.map((n) => (
                <TechNode node={n} key={n.id} />
              ))}
            </VirtualList>
          </Section>
        )}
      </Flex.Item>
    </Flex>
  );
}
