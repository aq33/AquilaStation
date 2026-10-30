import {
  Box,
  Button,
  Collapsible,
  Icon,
  Input,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend, useSharedState } from '../../backend';
import { extractRequirementMap, formatTools, recommendedTool } from './helpers';
import type { CatalogOperation, OperatingComputerData } from './types';

type SortType = 'default' | 'name' | 'tool';

const SORT_LABELS: Record<SortType, string> = {
  default: 'Domyślnie',
  name: 'Nazwa',
  tool: 'Narzędzie',
};

type SurgeryRequirementsInnerProps = {
  cat_text: string;
  cat_contents: string[];
};

export const SurgeryRequirementsInner = (
  props: SurgeryRequirementsInnerProps,
) => {
  const { cat_text, cat_contents } = props;

  return (
    <Stack.Item>
      <Stack.Item italic pb={1}>
        {cat_text}
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          {cat_contents.map((req, i) => (
            <Stack.Item key={i}>- {capitalizeFirst(req)}</Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </Stack.Item>
  );
};

type SurgeryProceduresViewProps = {
  searchedSurgeries: CatalogOperation[];
  searchText: string;
  setSearchText: (text: string) => void;
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
};

export const SurgeryProceduresView = (props: SurgeryProceduresViewProps) => {
  const { act, data } = useBackend<OperatingComputerData>();
  const { surgery_catalog = [], surgeries = [] } = data;
  const {
    searchedSurgeries,
    searchText,
    setSearchText,
    pinnedOperations,
    setPinnedOperations,
  } = props;
  const [sortType, setSortType] = useSharedState<SortType>(
    'catalog_sort_type',
    'default',
  );
  const [filterRobotic, setFilterRobotic] = useSharedState(
    'catalog_filter',
    false,
  );

  const rawSurgeryList = searchText ? searchedSurgeries : surgery_catalog;

  const surgeryList = rawSurgeryList
    .filter((surgery) => !filterRobotic || !surgery.mechanic)
    .filter(
      (surgery, index, self) =>
        index === self.findIndex((s) => s.id === surgery.id),
    );

  if (sortType === 'name') {
    surgeryList.sort((a, b) => (a.name > b.name ? 1 : -1));
  } else if (sortType === 'tool') {
    surgeryList.sort((a, b) =>
      recommendedTool(a) > recommendedTool(b) ? 1 : -1,
    );
  }

  if (pinnedOperations.length > 0) {
    surgeryList.sort((a, b) => {
      const aPinned = pinnedOperations.includes(a.id);
      const bPinned = pinnedOperations.includes(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });
  }

  return (
    <Section
      title="&nbsp;"
      scrollable
      fill
      buttons={
        <>
          <Input
            width="140px"
            placeholder="Szukaj…"
            value={searchText}
            onChange={setSearchText}
          />
          <Button
            icon="filter"
            tooltip="Ukryj operacje robotycznych części ciała."
            onClick={() => setFilterRobotic(!filterRobotic)}
            selected={filterRobotic}
          >
            Bez mech.
          </Button>
          <Button
            width="95px"
            icon="sort"
            tooltip="Zmień sortowanie."
            onClick={() =>
              setSortType(
                sortType === 'default'
                  ? 'name'
                  : sortType === 'name'
                    ? 'tool'
                    : 'default',
              )
            }
          >
            {SORT_LABELS[sortType]}
          </Button>
          <Button
            icon="download"
            tooltip="Synchronizuj zaawansowane operacje z bazą badań"
            tooltipPosition="bottom-start"
            onClick={() => act('sync')}
          />
        </>
      }
    >
      {surgeryList.map((surgery) => {
        const pinned = pinnedOperations.includes(surgery.id);
        const unlocked = !surgery.locked || surgeries.includes(surgery.id);

        return (
          <Stack vertical key={surgery.id} pb={2}>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item>
                  <Button
                    icon="thumbtack"
                    tooltip={pinned ? 'Odepnij' : 'Przypnij na górze'}
                    tooltipPosition="top"
                    color={pinned ? 'danger' : undefined}
                    onClick={() =>
                      setPinnedOperations(
                        pinned
                          ? pinnedOperations.filter((op) => op !== surgery.id)
                          : pinnedOperations.concat(surgery.id),
                      )
                    }
                  />
                </Stack.Item>
                <Stack.Item bold fontSize="1.2rem">
                  {surgery.name}
                </Stack.Item>
                {!unlocked && (
                  <Stack.Item color="average">
                    <Tooltip content="Wymaga dysku z operacją albo technologii z badań - wczytaj dysk albo zsynchronizuj bazę">
                      <Icon name="lock" />
                    </Tooltip>
                  </Stack.Item>
                )}
                <Stack.Item grow />
                <Stack.Item italic textAlign="right" fontSize="0.9rem">
                  {recommendedTool(surgery)}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Box
                style={{
                  borderStyle: 'solid',
                  borderBottom: '0',
                  borderRight: '0',
                  borderWidth: '2px',
                  paddingTop: '2px',
                  paddingLeft: '4px',
                }}
                color="label"
              >
                <Stack vertical>
                  <Stack.Item bold>{surgery.desc}</Stack.Item>
                  <Stack.Item italic fontSize="0.9rem">
                    {`${surgery.time} s${surgery.looping ? ', powtarza się' : ''} · ${formatTools(surgery.tools)}`}
                  </Stack.Item>
                  <Stack.Item>
                    <Collapsible title="Wymagania" open={pinned}>
                      <Stack
                        pl={1}
                        ml={0.5}
                        style={{
                          borderStyle: 'dashed',
                          borderBottom: '0',
                          borderRight: '0',
                          borderTop: '0',
                          borderWidth: '2px',
                          flexDirection: 'column',
                        }}
                      >
                        {Object.entries(extractRequirementMap(surgery)).map(
                          ([cat_text, cat_contents], i) =>
                            cat_contents.length > 0 ? (
                              <SurgeryRequirementsInner
                                key={i}
                                cat_text={cat_text}
                                cat_contents={cat_contents}
                              />
                            ) : null,
                        )}
                        {!unlocked && (
                          <SurgeryRequirementsInner
                            cat_text="Odblokowanie:"
                            cat_contents={[
                              'dysk z operacją albo technologia z badań (zsynchronizuj bazę)',
                            ]}
                          />
                        )}
                      </Stack>
                    </Collapsible>
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          </Stack>
        );
      })}
    </Section>
  );
};
