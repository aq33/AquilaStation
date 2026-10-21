import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  closed_interviews: any;
  open_interviews: any;
};

export const InterviewManager = (props) => {
  const { act, data } = useBackend<Data>();
  const { open_interviews, closed_interviews } = data;

  const colorMap = (status) => {
    switch (status) {
      case 'interview_approved':
        return 'good';
      case 'interview_denied':
        return 'bad';
      case 'interview_pending':
        return 'average';
    }
  };

  return (
    <Window title="Menedżer ankiet" theme="admin" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Aktywne ankiety">
          {open_interviews.map(({ id, ckey, status, queued, disconnected }) => (
            <Button
              key={id}
              content={ckey + (disconnected ? ' (DC)' : '')}
              color={queued ? 'default' : colorMap(status)}
              onClick={() => act('open', { id: id })}
            />
          ))}
        </Section>
        <Section title="Zamknięte ankiety">
          {closed_interviews.map(({ id, ckey, status, disconnected }) => (
            <Button
              key={id}
              content={ckey + (disconnected ? ' (DC)' : '')}
              color={colorMap(status)}
              onClick={() => act('open', { id: id })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
