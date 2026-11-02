import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  roles: any;
  selected_role: any;
};

export const SyndieJobSelect = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="syndicate" width={500} height={500}>
      <Window.Content scrollable>
        <Section title="Wybrana rola:">
          <p>{data.selected_role}</p>
        </Section>
        <Section title="Dostępne role:">
          {Object.keys(data.roles).map((key) => {
            let value = data.roles[key];
            return (
              <Section
                key={key}
                title={value.name}
                buttons={
                  <Button
                    content="Wybierz"
                    icon="check-circle"
                    onClick={() => act('select', { role_id: value.id })}
                  />
                }
              >
                <p>{value.desc}</p>
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
