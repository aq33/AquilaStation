// AQUILA - konsola kontroli ruchu telekomunikacji (NTSL), port z Monkestation (Monkestation/Monkestation2.0#2199)
// Backend: aquila/code/modules/ntsl/traffic_control.dm
import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Input,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { UI_UPDATE } from 'tgui-core/constants';
import type { BooleanLike } from 'tgui-core/react';
import { sleep } from 'tgui-core/timer';

import { useBackend } from '../backend';
import { AceEditor } from '../components/Ace/Editor';
import { Window } from '../layouts';

type Data = {
  admin_view: BooleanLike;
  emagged: BooleanLike;
  stored_code: string;
  user_name: string;
  network: string;
  compiler_output: string[];
  access_log: string[];
  server_data: ServerData[];
};

type ServerData = {
  run_code: BooleanLike;
  server: string;
  server_id: string;
  server_name: string;
};

type CodeState = [string, (code: string) => void];

export const NTSLCoding = (props) => {
  const { act, data } = useBackend<Data>();
  const { emagged, user_name, admin_view, stored_code } = data;
  // Make sure we don't start larger than 50%/80% of screen width/height.
  const winWidth = Math.min(
    user_name ? 900 : 260,
    window.screen.availWidth * 0.5,
  );
  const winHeight = Math.min(
    user_name ? 600 : 240,
    window.screen.availHeight * 0.8,
  );

  // Reset local edits when the saved code or the logged in user changes
  const [code, setCode] = useState(stored_code);
  useEffect(() => {
    setCode(stored_code);
  }, [stored_code, user_name]);
  const codeState: CodeState = [code, setCode];
  const [tabIndex, setTabIndex] = useState(1);

  return (
    <Window
      title="Kontrola ruchu telekomunikacji"
      width={winWidth}
      height={winHeight}
    >
      <Window.Content>
        <Stack fill>
          {!!user_name && (
            <Stack.Item grow>
              <ScriptEditor codeState={codeState} />
            </Stack.Item>
          )}
          <Stack.Item width="250px">
            <Stack fill vertical>
              {!!admin_view && (
                <Stack.Item>
                  <Button.Confirm
                    fluid
                    icon="power-off"
                    color="red"
                    confirmContent="Na pewno?"
                    onClick={() => act('admin_reset')}
                  >
                    (ADMIN) wyczyść kod i skompiluj
                  </Button.Confirm>
                </Stack.Item>
              )}
              <Stack.Item>
                <Section>
                  {user_name ? (
                    <Stack align="center">
                      <Stack.Item>
                        <Button
                          icon="power-off"
                          color="purple"
                          disabled={!!emagged}
                          onClick={() => act('log_out')}
                        >
                          Wyloguj
                        </Button>
                      </Stack.Item>
                      <Stack.Item grow>{user_name}</Stack.Item>
                    </Stack>
                  ) : (
                    <Button
                      icon="power-off"
                      color="green"
                      onClick={() => act('log_in')}
                    >
                      Zaloguj
                    </Button>
                  )}
                </Section>
              </Stack.Item>
              {!!user_name && (
                <Stack.Item grow>
                  <Section fill>
                    <Stack fill vertical>
                      <Stack.Item>
                        <Tabs fluid>
                          <Tabs.Tab
                            selected={tabIndex === 1}
                            onClick={() => setTabIndex(1)}
                          >
                            Kod
                          </Tabs.Tab>
                          <Tabs.Tab
                            selected={tabIndex === 2}
                            onClick={() => setTabIndex(2)}
                          >
                            Sieć
                          </Tabs.Tab>
                          <Tabs.Tab
                            selected={tabIndex === 3}
                            onClick={() => setTabIndex(3)}
                          >
                            Log
                          </Tabs.Tab>
                          <Tabs.Tab
                            selected={tabIndex === 4}
                            onClick={() => setTabIndex(4)}
                          >
                            Pomoc
                          </Tabs.Tab>
                        </Tabs>
                      </Stack.Item>
                      <Stack.Item grow>
                        {tabIndex === 1 && (
                          <CompilerOutput codeState={codeState} />
                        )}
                        {tabIndex === 2 && <ServerList />}
                        {tabIndex === 3 && <LogViewer />}
                        {tabIndex === 4 && <Guide />}
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ScriptEditor = (props: { codeState: CodeState }) => {
  const { act, data, config } = useBackend<Data>();
  const { stored_code, user_name } = data;
  const [_code, setCode] = props.codeState;

  return (
    <Box width="100%" height="100%">
      <AceEditor
        value={stored_code}
        language="ntsl"
        width="100%"
        height="100%"
        onChange={setCode}
        onCtrlS={(value) => {
          if (value === '') return false;
          act('save_code', { saved_code: value });
          return true;
        }}
        onCtrlShiftB={(value) => {
          act('save_code', { saved_code: value });
          sleep(150).then(() => act('compile_code'));
          return true;
        }}
        readOnly={!user_name || config.status <= UI_UPDATE}
      />
    </Box>
  );
};

const CompilerOutput = (props: { codeState: CodeState }) => {
  const { act, data } = useBackend<Data>();
  const { compiler_output } = data;
  const [code] = props.codeState;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button
          fluid
          icon="save"
          disabled={code === ''}
          tooltip="Zapisz przed kompilacją (w edytorze: Ctrl+S)."
          onClick={() => act('save_code', { saved_code: code })}
        >
          Zapisz
        </Button>
        <Button
          fluid
          icon="running"
          tooltip="Wgrywa zapisany kod na wszystkie serwery sieci (w edytorze: Ctrl+Shift+B zapisuje i kompiluje)."
          onClick={() => act('compile_code')}
        >
          Skompiluj i uruchom
        </Button>
        <Divider />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {compiler_output?.length
            ? compiler_output.map((message, index) => (
                <Box key={index}>{message}</Box>
              ))
            : 'Brak błędów kompilacji.'}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ServerList = (props) => {
  const { act, data } = useBackend<Data>();
  const { network, server_data } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button fluid icon="sync" onClick={() => act('refresh_servers')}>
          Połącz ponownie z siecią
        </Button>
        <Input
          fluid
          mt={1}
          value={network}
          onBlur={(value) => act('set_network', { new_network: value })}
        />
        <Divider />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {server_data.length
            ? server_data.map((server) => (
                <Box key={server.server}>
                  <Button.Checkbox
                    mb={0.5}
                    checked={!!server.run_code}
                    tooltip="Czy serwer wykonuje skrypt dla każdej wiadomości."
                    onClick={() =>
                      act('toggle_code_execution', {
                        selected_server: server.server,
                      })
                    }
                  >
                    {server.server_name}
                  </Button.Checkbox>
                </Box>
              ))
            : 'Nie znaleziono serwerów w tej sieci.'}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const LogViewer = (props) => {
  const { act, data } = useBackend<Data>();
  const { access_log } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button fluid icon="trash" onClick={() => act('clear_logs')}>
          Wyczyść log
        </Button>
        <Divider />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {access_log?.map((message, index) => (
            <Box key={index}>{message}</Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// Names match the channels.* enum in telecomms_translator.dm
const CHANNELS = [
  { key: 'common', freq: 1459, color: '#2cdb2c' },
  { key: 'command', freq: 1353, color: '#fcdf03' },
  { key: 'security', freq: 1359, color: '#dd3535' },
  { key: 'engineering', freq: 1357, color: '#f37746' },
  { key: 'science', freq: 1351, color: '#c68cfa' },
  { key: 'medical', freq: 1355, color: '#57b8f0' },
  { key: 'supply', freq: 1347, color: '#b88646' },
  { key: 'service', freq: 1349, color: '#6ca729' },
  { key: 'munitions', freq: 1345, color: '#ff9900' },
  { key: 'atc', freq: 1237, color: '#a8a8a8' },
  { key: 'exploration', freq: 1361, color: '#85b8bf' },
  { key: 'aiprivate', freq: 1447, color: '#d65d95' },
  { key: 'centcom', freq: 1337, color: '#2681a5' },
];

// Numbers match the languages.* enum in telecomms_translator.dm
const LANGUAGES = [
  'common',
  'monkey',
  'robot',
  'draconic',
  'beachtounge',
  'sylvan',
  'voltaic',
  'calcic',
  'moffic',
  'uncommon',
  'slime',
  'mushroom',
  'terrum',
  'apidite',
];

const EXAMPLE = `def process_signal(sig){
  if(sig.source == "Poly"){
    sig.pass = false;
  }
  sig.source = sig.source + " (" + sig.job + ")";
  return sig;
}`;

const Guide = (props) => {
  return (
    <Section fill scrollable>
      <Box bold>Jak to działa</Box>
      Każdy serwer z włączonym kodem wywołuje dla każdej wiadomości funkcję{' '}
      <b>process_signal(sig)</b>. Zwróć sig, żeby wiadomość poszła dalej.
      Zwrócenie czegoś innego albo pusta treść blokuje wiadomość.
      <Box as="pre" mt={1} fontSize="0.9em">
        {EXAMPLE}
      </Box>
      <Divider />
      <Box bold>Pola sygnału</Box>
      content: treść wiadomości
      <br />
      source: wyświetlane imię
      <br />
      job: praca
      <br />
      freq: częstotliwość (kanał)
      <br />
      pass: false blokuje wiadomość
      <br />
      filters: lista stylów, patrz niżej
      <br />
      language: język, patrz niżej
      <br />
      say, ask, yell, exclaim: czasowniki mowy
      <br />
      sector, uuid: tylko do odczytu
      <Divider />
      <Box bold>Kanały (channels.nazwa)</Box>
      {CHANNELS.map((channel) => (
        <Box key={channel.key} color={channel.color}>
          {channel.key}: {channel.freq / 10}
        </Box>
      ))}
      <Divider />
      <Box bold>Style (filter_types.nazwa)</Box>
      robot, wacky, <i>emphasis</i>, <b>loud</b>, commanding
      <Divider />
      <Box bold>Języki (languages.nazwa)</Box>
      {LANGUAGES.map((language, index) => (
        <Box key={language}>
          {index + 1}: {language}
        </Box>
      ))}
      Tłumaczyć można tylko między common, robot, draconic i uncommon.
      <Divider />
      <Box bold>Funkcje telekomów</Box>
      signal(treść, freq, źródło, praca, style): nowy sygnał
      <br />
      broadcast(sig): nadaje sygnał (najwyżej 3 razy na wiadomość)
      <br />
      mem(klucz), mem(klucz, wartość): pamięć serwera
      <br />
      clearmem(): czyści pamięć
      <br />
      remote_signal(freq, kod): jak zdalny sygnalizator
      <Divider />
      <Box bold>Pozostałe funkcje</Box>
      pick, find, substr, length, lower, upper, explode, implode, repeat,
      reverse, tonum, tostring, proper, replace, max, min, prob, rand, sqrt,
      abs, floor, ceil, round, clamp, inrange, sin, cos, asin, acos, log, time,
      timestamp
      <Divider />
      <Box bold>Limity</Box>
      900 instrukcji na wiadomość, 100 obrotów pętli, 15 000 znaków kodu.
      Wiadomości nadane przez broadcast() nie przechodzą przez skrypty.
    </Section>
  );
};
