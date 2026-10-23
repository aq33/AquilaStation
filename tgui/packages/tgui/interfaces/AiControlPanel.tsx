import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  authenticated: BooleanLike;
  has_access: BooleanLike;
  username: string;
  can_log_out: BooleanLike;
  intellicard: BooleanLike;
  intellicard_ai: string | null;
  intellicard_ai_health: number;
  can_upload: BooleanLike;
  downloading: string | null;
  download_progress: number;
  downloading_ref: string;
  current_ai_ref: string;
  ais: AiData[];
};

type AiData = {
  name: string;
  ref: string;
  can_download: BooleanLike;
  health: number;
  active: BooleanLike;
  in_core: BooleanLike;
};

const HEALTH_RANGES: Record<string, [number, number]> = {
  good: [75, Infinity],
  average: [25, 75],
  bad: [-Infinity, 25],
};

const PanelButtons = () => {
  const { act, data } = useBackend<Data>();
  const { intellicard, can_log_out } = data;
  return (
    <>
      <Button
        onClick={() => act('eject_intellicard')}
        color="bad"
        icon="eject"
        tooltip="Wysuwa IntelliCard i przerywa trwające pobieranie."
        disabled={!intellicard}
      >
        Wysuń IntelliCard
      </Button>
      <Button
        icon="sign-out-alt"
        color="bad"
        tooltip={
          !can_log_out
            ? 'Ta konsola ma uprawnienia administratora i nie można się z niej wylogować.'
            : undefined
        }
        disabled={!can_log_out}
        onClick={() => act('log_out')}
      >
        Wyloguj
      </Button>
    </>
  );
};

const UploadTab = () => {
  const { act, data } = useBackend<Data>();
  const { intellicard, intellicard_ai, intellicard_ai_health, can_upload } =
    data;
  return (
    <Section title="Wgrywanie" buttons={<PanelButtons />}>
      <NoticeBox info>
        SI można też wgrać, wkładając MMI albo mózg pozytronowy.
      </NoticeBox>
      {(!intellicard && <NoticeBox>Brak IntelliCard.</NoticeBox>) ||
        (!intellicard_ai && (
          <NoticeBox>IntelliCard nie zawiera SI.</NoticeBox>
        )) || (
          <Stack justify="center">
            <Stack.Item width="60%">
              <Section textAlign="center" title={intellicard_ai}>
                <ProgressBar
                  ranges={HEALTH_RANGES}
                  mb={0.75}
                  minValue={0}
                  maxValue={100}
                  value={intellicard_ai_health}
                >
                  Integralność: {intellicard_ai_health}%
                </ProgressBar>
                <Button
                  color="good"
                  icon="upload"
                  disabled={!can_upload}
                  tooltip={
                    !can_upload
                      ? 'Najczęstsza przyczyna: brak działającego rdzenia danych SI.'
                      : undefined
                  }
                  onClick={() => act('upload_intellicard')}
                >
                  Wgraj
                </Button>
              </Section>
            </Stack.Item>
          </Stack>
        )}
    </Section>
  );
};

const DownloadTab = () => {
  const { act, data } = useBackend<Data>();
  const {
    intellicard,
    downloading,
    download_progress,
    downloading_ref,
    current_ai_ref,
    ais = [],
  } = data;

  if (downloading) {
    return (
      <Section title="Pobieranie SI" buttons={<PanelButtons />}>
        <NoticeBox danger mb={0.5}>
          Trwa pobieranie: {downloading}
        </NoticeBox>
        <ProgressBar
          color="bad"
          minValue={0}
          value={download_progress}
          maxValue={100}
        />
        <Button.Confirm
          mt={0.5}
          fluid
          color="bad"
          icon="stop"
          textAlign="center"
          confirmContent="Na pewno?"
          onClick={() => act('stop_download')}
        >
          Przerwij pobieranie
        </Button.Confirm>
        {!!current_ai_ref && current_ai_ref === downloading_ref && (
          <Button.Confirm
            mt={0.5}
            fluid
            color="average"
            icon="download"
            textAlign="center"
            confirmContent="Na pewno?"
            onClick={() => act('skip_download')}
          >
            Zakończ pobieranie od razu
          </Button.Confirm>
        )}
      </Section>
    );
  }

  const available = ais.filter((ai) => !!ai.in_core);

  return (
    <Section title="SI dostępne do pobrania" buttons={<PanelButtons />}>
      {available.length === 0 && <NoticeBox>Brak SI w rdzeniach.</NoticeBox>}
      {available.map((ai) => (
        <Section
          key={ai.ref}
          title={
            <Box inline color={ai.active ? 'good' : 'bad'}>
              {ai.name} | {ai.active ? 'Aktywna' : 'Nieaktywna'}
            </Box>
          }
          buttons={
            <Button
              color={ai.can_download ? 'good' : 'bad'}
              tooltip={
                !intellicard
                  ? ai.can_download
                    ? 'Wymaga IntelliCard.'
                    : '&¤!65%'
                  : undefined
              }
              disabled={!intellicard || !ai.can_download}
              icon="download"
              onClick={() =>
                act('start_download', {
                  download_target: ai.ref,
                })
              }
            >
              {ai.can_download ? 'Pobierz' : '&gr4&!/'}
            </Button>
          }
        >
          <ProgressBar
            minValue={0}
            ranges={HEALTH_RANGES}
            value={ai.health}
            maxValue={100}
          >
            Integralność: {ai.health}%
          </ProgressBar>
        </Section>
      ))}
    </Section>
  );
};

const LoginScreen = () => {
  const { act, data } = useBackend<Data>();
  const { username, has_access } = data;
  const [code, setCode] = useState('');

  const submitCode = (value: string) => {
    const digits = value.replace(/\D/g, '');
    if (digits.length !== 6) {
      return;
    }
    act('log_in_control_code', { control_code: digits });
    setCode('');
  };

  return (
    <Section title="Witaj" fill>
      <Box textAlign="center" fontSize="18px" bold my={1}>
        <Icon name="user-circle" verticalAlign="middle" size={4.5} mr="1rem" />
        {username || 'Nieznany'}
      </Box>
      <NoticeBox textAlign="center" color={has_access ? 'good' : 'bad'}>
        {has_access ? 'Dostęp przyznany' : 'Brak dostępu'}
      </NoticeBox>
      <Button
        icon="sign-in-alt"
        color={has_access ? 'good' : 'bad'}
        fluid
        textAlign="center"
        onClick={() => act('log_in')}
      >
        Zaloguj
      </Button>
      <Stack mt={1}>
        <Stack.Item grow>
          <Input
            fluid
            maxLength={6}
            placeholder="123456"
            value={code}
            onChange={(value) => setCode(value)}
            onEnter={(value) => submitCode(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="key"
            disabled={code.replace(/\D/g, '').length !== 6}
            onClick={() => submitCode(code)}
          >
            Użyj kodu
          </Button>
        </Stack.Item>
      </Stack>
      <NoticeBox mt={1} danger>
        Możesz też użyć kodu kontrolnego SI jako hasła jednorazowego. Stacja
        zostanie powiadomiona o twoim położeniu i nazwisku.
      </NoticeBox>
    </Section>
  );
};

export const AiControlPanel = (props) => {
  const { data } = useBackend<Data>();
  const { authenticated } = data;

  const [tab, setTab] = useState(1);

  return (
    <Window width={520} height={400} title="Panel sterowania SI">
      <Window.Content scrollable>
        {(!!authenticated && (
          <>
            <Tabs fluid>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                Wgrywanie
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                Pobieranie
              </Tabs.Tab>
            </Tabs>
            {tab === 1 && <UploadTab />}
            {tab === 2 && <DownloadTab />}
          </>
        )) || <LoginScreen />}
      </Window.Content>
    </Window>
  );
};
