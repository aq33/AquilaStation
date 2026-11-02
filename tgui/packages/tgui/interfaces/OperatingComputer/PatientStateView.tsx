import {
  AnimatedNumber,
  Blink,
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { BodyZone, BodyZoneSelector } from '../common/BodyZoneSelector';
import { recommendedTool } from './helpers';
import {
  ComputerTabs,
  damageTypes,
  type OperatingComputerData,
  type PatientData,
  STAT_LABELS,
} from './types';

type PatientStateViewProps = {
  setTab: (tab: number) => void;
  setSearchText: (text: string) => void;
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
};

export const PatientStateView = (props: PatientStateViewProps) => {
  const { data } = useBackend<OperatingComputerData>();
  const { table, patient } = data;

  if (!table) {
    return (
      <Section fill>
        <NoticeBox color="yellow" align="center">
          Nie wykryto stołu
        </NoticeBox>
      </Section>
    );
  }
  if (!patient) {
    return (
      <Section fill>
        <NoticeBox color="red" align="center">
          Nie wykryto pacjenta
        </NoticeBox>
      </Section>
    );
  }
  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item>
          <PatientStateMainStateView patient={patient} />
        </Stack.Item>
        <Stack.Item p={1}>
          <PatientStateSurgeryStateView patient={patient} />
        </Stack.Item>
        <Stack.Item grow>
          <PatientStateNextOperationsView {...props} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type PatientStateMainStateViewProps = {
  patient: PatientData;
};

const PatientStateMainStateView = (props: PatientStateMainStateViewProps) => {
  const { patient } = props;
  const bloodLevel = patient.blood_level;
  const standardBlood = patient.standard_blood_level || 1;

  return (
    <LabeledList>
      <LabeledList.Item label="Stan" color={patient.statstate}>
        {STAT_LABELS[patient.stat] || patient.stat}
      </LabeledList.Item>
      <LabeledList.Item label="Grupa krwi">
        {patient.blood_type || 'Nie da się ustalić grupy krwi'}
      </LabeledList.Item>
      <LabeledList.Item label="Zdrowie">
        <ProgressBar
          value={patient.health}
          minValue={patient.minHealth}
          maxValue={patient.maxHealth}
          color={patient.health >= 0 ? 'good' : 'average'}
        >
          <AnimatedNumber
            value={patient.health}
            format={(value) => `${Math.round(value)}%`}
          />
        </ProgressBar>
      </LabeledList.Item>
      {bloodLevel !== undefined && (
        <LabeledList.Item label="Poziom krwi">
          <ProgressBar
            value={bloodLevel}
            minValue={0}
            maxValue={standardBlood}
            color={
              bloodLevel >= standardBlood * 0.7
                ? 'good'
                : bloodLevel >= standardBlood * 0.45
                  ? 'average'
                  : 'bad'
            }
          >
            <AnimatedNumber
              value={bloodLevel / standardBlood}
              format={(value) => `${Math.round(value * 100)}%`}
            />
          </ProgressBar>
        </LabeledList.Item>
      )}
      {damageTypes.map((type) => (
        <LabeledList.Item key={type.type} label={type.label}>
          <ProgressBar
            value={patient[type.type] / patient.maxHealth}
            color="bad"
          >
            <AnimatedNumber value={patient[type.type]} />
          </ProgressBar>
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};

type PatientStateSurgeryStateViewProps = {
  patient: PatientData;
};

/** Sylwetka do wyboru strefy i stan chirurgiczny tej strefy */
const PatientStateSurgeryStateView = (
  props: PatientStateSurgeryStateViewProps,
) => {
  const { act, data } = useBackend<OperatingComputerData>();
  const { patient } = props;
  const { target_zone = BodyZone.Chest } = data;
  const surgeryState = patient.surgery_state || [];

  return (
    <Stack>
      <Stack.Item>
        <BodyZoneSelector
          onClick={(zone) =>
            zone !== target_zone && act('change_zone', { new_zone: zone })
          }
          selectedZone={target_zone}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical>
          {surgeryState.length === 0 && (
            <Stack.Item color="label">Bez zmian chirurgicznych</Stack.Item>
          )}
          {surgeryState.map((state) => (
            <Stack.Item key={state}>- {state}</Stack.Item>
          ))}
          {!!patient.ongoing && (
            <Stack.Item color="good">
              <Icon name="spinner" spin mr={1} />
              Trwa: {patient.ongoing}
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

/** Operacje, które da się zrobić dalej w wybranej strefie (tg: „Possible Operations”) */
const PatientStateNextOperationsView = (props: PatientStateViewProps) => {
  const { data } = useBackend<OperatingComputerData>();
  const { surgery_catalog = [], next_operations = [], patient } = data;
  const { pinnedOperations, setPinnedOperations, setTab, setSearchText } =
    props;

  const possibleNext = surgery_catalog.filter((operation) =>
    next_operations.includes(operation.id),
  );

  const allTools = ['wszystkie narzędzia'].concat(
    possibleNext
      .map((operation) => recommendedTool(operation))
      .filter((tool, index, self) => self.indexOf(tool) === index),
  );

  const [filterByTool, setFilterByTool] = useSharedState<string>(
    'filter_by_tool',
    allTools[0],
  );

  const isPinned = (id: string) => pinnedOperations.includes(id);
  possibleNext.sort((a, b) => {
    if (a.priority !== b.priority) {
      return a.priority ? -1 : 1;
    }
    if (isPinned(a.id) !== isPinned(b.id)) {
      return isPinned(a.id) ? -1 : 1;
    }
    return 0;
  });

  const shown = possibleNext.filter(
    (operation) =>
      filterByTool === allTools[0] ||
      recommendedTool(operation) === filterByTool,
  );

  return (
    <Section
      title="Możliwe operacje"
      scrollable
      fill
      buttons={
        <Button
          icon="filter"
          tooltip="Filtruj po zalecanym narzędziu. Prawy klik resetuje."
          tooltipPosition="top"
          width="120px"
          ellipsis
          selected={filterByTool !== allTools[0]}
          onClick={() =>
            setFilterByTool(
              allTools[(allTools.indexOf(filterByTool) + 1) % allTools.length],
            )
          }
          onContextMenu={() => setFilterByTool(allTools[0])}
        >
          {filterByTool}
        </Button>
      }
    >
      <Stack vertical fill>
        {possibleNext.length === 0 ? (
          <Stack.Item>
            {patient?.prepped ? (
              <NoticeBox color="green" align="center">
                Brak dostępnych operacji
              </NoticeBox>
            ) : (
              <NoticeBox color="yellow" align="center">
                Przygotuj pacjenta do operacji: połóż serwety albo prześcieradło
                na wybranej strefie ciała.
              </NoticeBox>
            )}
          </Stack.Item>
        ) : (
          shown.map((operation) => (
            <Stack.Item key={operation.id}>
              <Button
                fluid
                tooltip={
                  <Stack vertical>
                    {operation.priority && (
                      <Stack.Item color="orange">
                        <Icon name="exclamation" mr={1} />
                        Zalecany następny krok
                      </Stack.Item>
                    )}
                    {isPinned(operation.id) && (
                      <Stack.Item color="yellow">
                        <Icon name="thumbtack" mr={1} />
                        Przypięta
                      </Stack.Item>
                    )}
                    <Stack.Item>{operation.desc}</Stack.Item>
                    <Stack.Item italic fontSize="0.9rem">
                      {`Lewy klik ${isPinned(operation.id) ? 'odpina' : 'przypina'} operację na górze.`}
                    </Stack.Item>
                    <Stack.Item italic fontSize="0.9rem">
                      Prawy klik otwiera opis w katalogu.
                    </Stack.Item>
                  </Stack>
                }
                tooltipPosition="bottom"
                color={
                  operation.priority
                    ? 'caution'
                    : isPinned(operation.id)
                      ? 'danger'
                      : undefined
                }
                onContextMenu={() => {
                  setTab(ComputerTabs.OperationCatalog);
                  setSearchText(operation.name);
                }}
                onClick={() =>
                  setPinnedOperations(
                    isPinned(operation.id)
                      ? pinnedOperations.filter((op) => op !== operation.id)
                      : pinnedOperations.concat(operation.id),
                  )
                }
              >
                <Stack fill>
                  <Stack.Item
                    style={{
                      textOverflow: 'ellipsis',
                      overflow: 'hidden',
                    }}
                  >
                    {operation.name}
                  </Stack.Item>
                  {operation.priority && (
                    <Stack.Item>
                      <Blink interval={500} time={500}>
                        <Icon name="exclamation" />
                      </Blink>
                    </Stack.Item>
                  )}
                  {isPinned(operation.id) && (
                    <Stack.Item>
                      <Icon name="thumbtack" />
                    </Stack.Item>
                  )}
                  <Stack.Item grow />
                  <Stack.Item>
                    <Box italic fontSize="0.9rem">
                      {recommendedTool(operation)}
                    </Box>
                  </Stack.Item>
                </Stack>
              </Button>
            </Stack.Item>
          ))
        )}
      </Stack>
    </Section>
  );
};
