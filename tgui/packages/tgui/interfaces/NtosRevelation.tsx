import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  armed: BooleanLike;
};

export const NtosRevelation = (props) => {
  const { act, data } = useBackend<Data>();
  const { armed } = data;

  return (
    <NtosWindow theme="syndicate" width={400} height={250}>
      <NtosWindow.Content>
        <Section>
          <Button.Input
            fluid
            buttonText="Zamaskuj nazwę..."
            onCommit={(value) =>
              act('PRG_obfuscate', {
                new_name: value,
              })
            }
            mb={1}
          />
          <LabeledList>
            <LabeledList.Item
              label="Stan ładunku"
              buttons={
                <Button
                  color={armed ? 'bad' : 'average'}
                  onClick={() => act('PRG_arm')}
                >
                  {armed ? 'UZBROJONY' : 'ROZBROJONY'}
                </Button>
              }
            />
          </LabeledList>
          <Button
            fluid
            bold
            textAlign="center"
            color="bad"
            disabled={!armed}
            onClick={() => act('PRG_activate')}
          >
            AKTYWUJ
          </Button>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
