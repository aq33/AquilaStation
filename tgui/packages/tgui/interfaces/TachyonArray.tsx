import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

// Our counterpart of tg's DopplerArray window. Records are printed on paper
// instead of saved to a data disk, and there are no reaction results.

type TachyonRecord = {
  name: string;
  timestamp: string;
  coordinates: string;
  displacement: number;
  factual_epicenter_radius: number;
  factual_outer_radius: number;
  factual_shockwave_radius: number;
  theory_epicenter_radius?: number | null;
  theory_outer_radius?: number | null;
  theory_shockwave_radius?: number | null;
  ref: string;
};

type Data = {
  records: TachyonRecord[];
};

export const TachyonArray = (props) => {
  const { data } = useBackend<Data>();
  const { records = [] } = data;
  return (
    <Window width={650} height={320}>
      <Window.Content scrollable>
        {!records.length ? (
          <NoticeBox>Brak zapisów</NoticeBox>
        ) : (
          <TachyonArrayContent />
        )}
      </Window.Content>
    </Window>
  );
};

/** A measured radius, with the theoretical one in brackets when known. */
const Radius = (props: { factual: number; theory?: number | null }) => (
  <>
    {props.factual}
    {!!props.theory && ` (teoretycznie: ${props.theory})`}
  </>
);

const TachyonArrayContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { records = [] } = data;
  const [activeRecordName, setActiveRecordName] = useSharedState(
    'activeRecord',
    records[0]?.name,
  );
  const activeRecord = records.find((record) => {
    return record.name === activeRecordName;
  });
  return (
    <Section>
      <Stack>
        <Stack.Item mr={2}>
          <Tabs vertical>
            {records.map((record) => (
              <Tabs.Tab
                icon="file"
                key={record.ref}
                selected={record.name === activeRecordName}
                onClick={() => setActiveRecordName(record.name)}
              >
                {record.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        {activeRecord ? (
          <Stack.Item grow>
            <Section
              title={activeRecord.name}
              buttons={
                <>
                  <Button.Confirm
                    icon="trash"
                    color="bad"
                    confirmContent="Na pewno?"
                    onClick={() =>
                      act('delete_record', {
                        ref: activeRecord.ref,
                      })
                    }
                  >
                    Usuń
                  </Button.Confirm>
                  <Button
                    icon="print"
                    tooltip="Wydrukuj wybrany zapis na papierze."
                    tooltipPosition="bottom"
                    onClick={() =>
                      act('print_record', {
                        ref: activeRecord.ref,
                      })
                    }
                  >
                    Drukuj
                  </Button>
                </>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Czas">
                  {activeRecord.timestamp}
                </LabeledList.Item>
                <LabeledList.Item label="Współrzędne">
                  {activeRecord.coordinates}
                </LabeledList.Item>
                <LabeledList.Item label="Przesunięcie">
                  {activeRecord.displacement} s
                </LabeledList.Item>
                <LabeledList.Item label="Promień epicentrum">
                  <Radius
                    factual={activeRecord.factual_epicenter_radius}
                    theory={activeRecord.theory_epicenter_radius}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Promień zewnętrzny">
                  <Radius
                    factual={activeRecord.factual_outer_radius}
                    theory={activeRecord.theory_outer_radius}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Promień fali uderzeniowej">
                  <Radius
                    factual={activeRecord.factual_shockwave_radius}
                    theory={activeRecord.theory_shockwave_radius}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        ) : (
          <Stack.Item grow={1} basis={0}>
            <NoticeBox>Nie wybrano zapisu</NoticeBox>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
