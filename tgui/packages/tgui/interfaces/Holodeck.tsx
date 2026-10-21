import { Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Program = {
  id: string;
  name: string;
};

type Data = {
  can_toggle_safety: BooleanLike;
  default_programs: Program[] | null;
  emag_programs: Program[] | null;
  emagged: BooleanLike;
  program: string | null;
};

export const Holodeck = (props) => {
  const { act, data } = useBackend<Data>();
  const { can_toggle_safety, emagged, program } = data;
  const default_programs = data.default_programs || [];
  const emag_programs = data.emag_programs || [];
  return (
    <Window title="Holodek" width={400} height={500}>
      <Window.Content scrollable>
        <Section
          title="Programy standardowe"
          buttons={
            <Button
              icon={emagged ? 'unlock' : 'lock'}
              color="bad"
              disabled={!can_toggle_safety}
              selected={!emagged}
              onClick={() => act('safety')}
            >
              Zabezpieczenia
            </Button>
          }
        >
          {default_programs.map((def_program) => (
            <Button
              fluid
              key={def_program.id}
              textAlign="center"
              selected={def_program.id === program}
              onClick={() =>
                act('load_program', {
                  id: def_program.id,
                })
              }
            >
              {def_program.name.substring(11)}
            </Button>
          ))}
        </Section>
        {!!emagged && (
          <Section title="Niebezpieczne programy">
            {emag_programs.map((emag_program) => (
              <Button
                fluid
                key={emag_program.id}
                color="bad"
                textAlign="center"
                selected={emag_program.id === program}
                onClick={() =>
                  act('load_program', {
                    id: emag_program.id,
                  })
                }
              >
                {emag_program.name.substring(11)}
              </Button>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
