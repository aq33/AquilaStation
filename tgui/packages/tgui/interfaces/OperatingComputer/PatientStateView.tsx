import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  ComputerTabs,
  damageTypes,
  formatTools,
  type OperatingComputerData,
  type PatientData,
  type Procedure,
  STAT_LABELS,
  type SurgeryTool,
} from './types';

type PatientStateViewProps = {
  setTab: (tab: number) => void;
  setSearchText: (text: string) => void;
};

export const PatientStateView = (props: PatientStateViewProps) => {
  const { data } = useBackend<OperatingComputerData>();
  const { setTab, setSearchText } = props;
  const { table, patient, procedures = [] } = data;

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
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <PatientStateMainStateView patient={patient} />
        </Stack.Item>
        <Stack.Item>
          <Section title="Trwające operacje">
            {procedures.length === 0 ? (
              <NoticeBox color="green" align="center">
                Brak trwających operacji
              </NoticeBox>
            ) : (
              <Stack vertical>
                {procedures.map((procedure) => (
                  <Stack.Item key={procedure.name}>
                    <ProcedureView
                      procedure={procedure}
                      onShowInCatalog={() => {
                        setTab(ComputerTabs.OperationCatalog);
                        setSearchText(procedure.surgery_name || procedure.name);
                      }}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            )}
          </Section>
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

type StepLineProps = {
  step: string;
  tools?: SurgeryTool[];
  chems?: string;
};

const StepLine = (props: StepLineProps) => {
  const { step, tools, chems } = props;
  return (
    <>
      <Box bold>{step}</Box>
      {!!tools?.length && (
        <Box italic fontSize="0.9rem" color="label">
          Narzędzie: {formatTools(tools)}
        </Box>
      )}
      {!!chems && (
        <Box fontSize="0.9rem">
          <b>Wymagane chemikalia:</b> {chems}
        </Box>
      )}
    </>
  );
};

type ProcedureViewProps = {
  procedure: Procedure;
  onShowInCatalog: () => void;
};

const ProcedureView = (props: ProcedureViewProps) => {
  const { procedure, onShowInCatalog } = props;
  return (
    <Box
      p={1}
      style={{
        borderStyle: 'solid',
        borderBottom: '0',
        borderRight: '0',
        borderWidth: '2px',
      }}
    >
      <Stack align="center" mb={1}>
        <Stack.Item grow bold fontSize="1.1rem">
          {procedure.name}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="book"
            tooltip="Pokaż w katalogu operacji"
            tooltipPosition="left"
            onClick={onShowInCatalog}
          />
        </Stack.Item>
      </Stack>
      <LabeledList>
        <LabeledList.Item label="Następny krok">
          <StepLine
            step={procedure.next_step}
            tools={procedure.next_tools}
            chems={procedure.chems_needed}
          />
        </LabeledList.Item>
        {!!procedure.alternative_step && (
          <LabeledList.Item label="Albo">
            <StepLine
              step={procedure.alternative_step}
              tools={procedure.alt_tools}
              chems={procedure.alt_chems_needed}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Box>
  );
};
