import { Box, Button, Collapsible, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Complaint = {
  number: number;
  title: string;
  text: string;
  time: string;
};

type Data = {
  can_read: BooleanLike;
  count: number;
  complaints?: Complaint[];
};

export const ComplaintBox = (props) => {
  const { act, data } = useBackend<Data>();
  const { can_read, count, complaints = [] } = data;
  return (
    <Window width={420} height={460}>
      <Window.Content scrollable>
        <Section title={`Skargi: ${count}`}>
          {!can_read ? (
            <NoticeBox info>
              Wrzuć zapisaną kartkę, żeby złożyć skargę. Skargi czyta
              dowództwo i prawnik.
            </NoticeBox>
          ) : !complaints.length ? (
            <Box color="label">Nie wpłynęła żadna skarga.</Box>
          ) : (
            complaints.map((complaint) => (
              <Collapsible
                key={complaint.number}
                title={`Nr ${complaint.number}: ${complaint.title}`}
                buttons={
                  <Button
                    icon="print"
                    onClick={() => act('print', { number: complaint.number })}
                  >
                    Drukuj
                  </Button>
                }
              >
                <Box color="label">Wpłynęła: {complaint.time}</Box>
                <Box preserveWhitespace>{complaint.text}</Box>
              </Collapsible>
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
