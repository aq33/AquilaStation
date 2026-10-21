import { useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  announce_contents: BooleanLike;
  announcer_sounds: string[];
  command_name_presets: string[];
  command_name: string;
  command_report_content: string;
  custom_name: BooleanLike;
  played_sound: string;
  print_report: BooleanLike;
  subheader: string;
};

export function CommandReport() {
  return (
    <Window title="Raport Dowództwa" width={325} height={620} theme="admin">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <CentComName />
            <AnnouncementSound />
          </Stack.Item>
          <Stack.Item>
            <SubHeader />
          </Stack.Item>
          <Stack.Item grow>
            <ReportText />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

/** Allows the user to set the "sender" of the message via dropdown */
function CentComName(props) {
  const { act, data } = useBackend<Data>();
  const { command_name, command_name_presets = [], custom_name } = data;

  const [name, setName] = useState(command_name);

  function sendName(value) {
    setName(value);
    act('update_command_name', {
      updated_name: value,
    });
  }

  return (
    <Section title="Nadawca raportu" textAlign="center">
      <Dropdown
        width="100%"
        selected={name}
        options={command_name_presets}
        onSelected={sendName}
      />
      {!!custom_name && (
        <Input fluid mt={1} value={name} onChange={setName} onBlur={sendName} />
      )}
    </Section>
  );
}

/** Allows the user to set the subheader of the message */
function SubHeader(props) {
  const { act, data } = useBackend<Data>();
  const { subheader } = data;

  return (
    <Section title="Podtytuł raportu" textAlign="center">
      <Input
        fluid
        mt={1}
        value={subheader}
        placeholder="Zostaw puste, żeby pominąć podtytuł"
        onBlur={(value) =>
          act('set_subheader', {
            new_subheader: value,
          })
        }
      />
    </Section>
  );
}

/** Features a section with dropdown for sounds. */
function AnnouncementSound(props) {
  const { act, data } = useBackend<Data>();
  const { announcer_sounds = [], played_sound } = data;

  return (
    <Section title="Dźwięk ogłoszenia" textAlign="center">
      <Dropdown
        width="100%"
        selected={played_sound}
        options={announcer_sounds}
        onSelected={(value) =>
          act('set_report_sound', {
            picked_sound: value,
          })
        }
      />
    </Section>
  );
}

/** Creates the report textarea with a submit button. */
function ReportText(props) {
  const { act, data } = useBackend<Data>();
  const { announce_contents, print_report, command_report_content } = data;
  const [commandReport, setCommandReport] = useState(command_report_content);

  return (
    <Section fill title="Treść raportu" textAlign="center">
      <Stack fill vertical>
        <Stack.Item grow>
          <TextArea
            height="100%"
            fluid
            onBlur={setCommandReport}
            value={commandReport}
            placeholder="Wpisz tutaj treść raportu..."
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!announce_contents}
            onClick={() => act('toggle_announce')}
          >
            Ogłoś treść
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={!!print_report || !announce_contents}
            disabled={!announce_contents}
            onClick={() => act('toggle_printing')}
            tooltip={
              !announce_contents &&
              'Raport musi zostać wydrukowany, skoro jego treść nie jest ogłaszana.'
            }
            tooltipPosition="top"
          >
            Wydrukuj raport
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            fluid
            icon="check"
            textAlign="center"
            confirmContent="Na pewno?"
            onClick={() => act('submit_report', { report: commandReport })}
          >
            Wyślij raport
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
