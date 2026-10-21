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
import {
  type CatalogSurgery,
  formatTools,
  type OperatingComputerData,
} from './types';

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

/** Wymagania operacji z danych katalogu */
const extractRequirements = (
  surgery: CatalogSurgery,
  unlocked: boolean,
): Record<string, string[]> => {
  const required: string[] = [];
  const optional: string[] = [];
  if (surgery.locations.length) {
    required.push(`miejsce: ${surgery.locations.join(', ')}`);
  }
  if (surgery.targets.length) {
    required.push(`pacjent: ${surgery.targets.join(', ')}`);
  }
  if (surgery.missingLimb) {
    required.push('brak kończyny w tym miejscu');
  } else if (surgery.bodypart !== 'dowolna') {
    required.push(`część ciała: ${surgery.bodypart}`);
  }
  if (surgery.lying) {
    required.push('pacjent musi leżeć');
  }
  if (surgery.condition) {
    required.push(surgery.condition);
  }
  if (surgery.requiresTech) {
    required.push(
      unlocked
        ? 'technologia z badań (zsynchronizowana)'
        : 'technologia z badań - zsynchronizuj bazę danych',
    );
  }
  if (surgery.ignoreClothes) {
    optional.push('można operować przez ubranie');
  }
  if (surgery.selfOperable) {
    optional.push('można operować samego siebie');
  }
  return {
    'Wymagane:': required,
    'Dodatkowo:': optional,
    'Zastąpiona przez:': surgery.replacedBy ? [surgery.replacedBy] : [],
  };
};

/** Narzędzie pierwszego kroku - podpowiedź jak w tg */
const firstTool = (surgery: CatalogSurgery) =>
  formatTools(surgery.steps[0]?.tools?.slice(0, 1));

const isMechanic = (surgery: CatalogSurgery) =>
  surgery.bodypart === 'robotyczna';

type SurgeryProceduresViewProps = {
  searchedSurgeries: CatalogSurgery[];
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
  const unlockedIds = surgeries.map((surgery) => surgery.id);

  const rawSurgeryList = searchText ? searchedSurgeries : surgery_catalog;

  const surgeryList = rawSurgeryList
    .filter((surgery) => !filterRobotic || !isMechanic(surgery))
    .filter(
      (surgery, index, self) =>
        index === self.findIndex((s) => s.id === surgery.id),
    );

  if (sortType === 'name') {
    surgeryList.sort((a, b) => (a.name > b.name ? 1 : -1));
  } else if (sortType === 'tool') {
    surgeryList.sort((a, b) => (firstTool(a) > firstTool(b) ? 1 : -1));
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
        const unlocked =
          !surgery.requiresTech || unlockedIds.includes(surgery.id);

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
                    <Tooltip content="Wymaga technologii z badań - zsynchronizuj bazę">
                      <Icon name="lock" />
                    </Tooltip>
                  </Stack.Item>
                )}
                <Stack.Item grow />
                <Stack.Item italic textAlign="right" fontSize="0.9rem">
                  {firstTool(surgery)}
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
                  {!!surgery.desc && (
                    <Stack.Item bold>{surgery.desc}</Stack.Item>
                  )}
                  <Stack.Item>
                    <Collapsible title="Kroki" open={pinned}>
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
                        {surgery.steps.map((step, i) => (
                          <Stack.Item key={i}>
                            <Box>
                              {`${i + 1}. ${step.name}`}
                              {step.repeatable && ' (powtarzalny)'}
                              <Box as="span" italic ml={1} fontSize="0.9rem">
                                {`${step.time} s`}
                              </Box>
                            </Box>
                            {step.tools.length > 0 && (
                              <Box italic fontSize="0.9rem" ml={1}>
                                {formatTools(step.tools)}
                              </Box>
                            )}
                            {step.chems.length > 0 && (
                              <Box fontSize="0.9rem" ml={1}>
                                {`Chemikalia (${step.allChems ? 'wszystkie' : 'jedno z'}): ${step.chems.join(', ')}`}
                              </Box>
                            )}
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Collapsible>
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
                        {Object.entries(
                          extractRequirements(surgery, unlocked),
                        ).map(([cat_text, cat_contents], i) =>
                          cat_contents.length > 0 ? (
                            <SurgeryRequirementsInner
                              key={i}
                              cat_text={cat_text}
                              cat_contents={cat_contents}
                            />
                          ) : null,
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
