import { Fragment } from 'react';
import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  accessList: any;
  modifying: any;
  theme: any;
};

export const SecondaryID = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme={data.theme} width={580} height={400}>
      <Window.Content scrollable>
        <Section
          title="Dostępy:"
          buttons={
            <>
              <Button
                content="Wysuń obecny identyfikator"
                disabled={!data.modifying}
                icon="eject"
                onClick={() => act('eject')}
              />
              <Button
                content="Zmień przydział"
                disabled={!data.modifying}
                icon="cog"
                onClick={() => act('modifyAssignment')}
              />
              <Button
                content="Zmień imię"
                disabled={!data.modifying}
                icon="pen"
                onClick={() => act('modifyName')}
              />
            </>
          }
        >
          {Object.keys(data.accessList).map((key) => {
            let value = data.accessList[key];
            return (
              <Button
                key={key}
                content={value.title}
                icon={value.hasAccess ? 'check-circle' : 'times'}
                selected={!value.hasAccess}
                disabled={!data.modifying}
                onClick={() => act('accessMod', { access: value.access })}
              />
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
