import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { SOFTWARE_DESC, SOFTWARE_NAME } from './constants';
import type { PaiData, PaiRecord } from './types';

/**
 * Renders two sections: A section of buttons and
 * another section that displays the selected installed
 * software info.
 */
export function InstalledDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { installed = [] } = data;

  const [currentSelection, setCurrentSelection] = useState('');

  const title = !currentSelection
    ? 'Wybierz program'
    : SOFTWARE_NAME[currentSelection] || currentSelection;

  return (
    <Stack fill vertical>
      <Stack.Item grow={2}>
        <Section fill scrollable title={title}>
          {currentSelection && installed.includes(currentSelection) && (
            <Stack fill vertical>
              <Stack.Item>{SOFTWARE_DESC[currentSelection]}</Stack.Item>
              <Stack.Item grow>
                <SoftwareButtons currentSelection={currentSelection} />
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Zainstalowane oprogramowanie">
          {!installed.length ? (
            <NoticeBox>Nic nie zainstalowano!</NoticeBox>
          ) : (
            installed.map((software) => {
              return (
                <Button
                  key={software}
                  selected={software === currentSelection}
                  onClick={() => setCurrentSelection(software)}
                >
                  {SOFTWARE_NAME[software] || software}
                </Button>
              );
            })
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

type SoftwareButtonsProps = {
  currentSelection: string;
};

/**
 * Once a software is selected, generates custom buttons or a default
 * power toggle.
 */
function SoftwareButtons(props: SoftwareButtonsProps) {
  const { currentSelection } = props;

  const { act, data } = useBackend<PaiData>();
  const {
    door_jack,
    door_jack_compatible,
    encryption_keys,
    hack_progress,
    hacking,
    languages,
    med_hud,
    sec_hud,
  } = data;

  const use = (mode?: string, value?: number) =>
    act('software', { software: currentSelection, mode, value });

  switch (currentSelection) {
    case 'door jack':
      return (
        <>
          <Box mb={1}>
            Stan kabla:{' '}
            {!door_jack && (
              <Box inline color="bad">
                zwinięty
              </Box>
            )}
            {door_jack === 'extended' && (
              <Box inline color="average">
                wysunięty
              </Box>
            )}
            {door_jack === 'connected' && (
              <Box inline color="good">
                podłączony
              </Box>
            )}
          </Box>
          {door_jack === 'connected' && !door_jack_compatible && (
            <NoticeBox>
              Oprogramowanie podłączonego urządzenia nie jest zgodne z
              protokołami Door Jack.
            </NoticeBox>
          )}
          {!!hacking && (
            <ProgressBar mb={1} value={hack_progress} maxValue={100}>
              Włamanie: {hack_progress}%
            </ProgressBar>
          )}
          <Button
            disabled={!!door_jack}
            icon="plug"
            onClick={() => use('cable')}
            tooltip="Wysuwa kabel. Podłącz go do zgodnej śluzy."
          >
            Wysuń kabel
          </Button>
          <Button
            color="bad"
            disabled={!door_jack_compatible || !!hacking}
            icon="door-open"
            onClick={() => use('hack')}
            tooltip="Rozpoczyna łamanie zabezpieczeń śluzy."
          >
            Włam się
          </Button>
          <Button
            disabled={!hacking}
            icon="unlink"
            onClick={() => use('cancel')}
          >
            Przerwij
          </Button>
        </>
      );
    case 'host scan':
      return (
        <>
          <Button
            icon="hand-holding-heart"
            onClick={() => use('target')}
            tooltip="Musisz być trzymany w ręku, aby skanować."
          >
            Skanuj nosiciela
          </Button>
          <Button icon="cog" onClick={() => use('mode')}>
            Zmień tryb skanu
          </Button>
        </>
      );
    case 'photography module':
      return (
        <>
          <Button
            icon="camera-retro"
            onClick={() => use('camera')}
            tooltip="Przełącza aparat. Kliknij obszar, aby zrobić zdjęcie."
          >
            Aparat
          </Button>
          <Button
            icon="images"
            onClick={() => use('printer')}
            tooltip="Pokazuje zapisane zdjęcia."
          >
            Zdjęcia
          </Button>
        </>
      );
    case 'remote signaller':
      return <SignalerControls />;
    case 'atmosphere sensor':
      return <AtmosReadout />;
    case 'medical records':
    case 'security records':
      return <RecordsDisplay selection={currentSelection} />;
    case 'medical HUD':
    case 'security HUD': {
      const enabled = currentSelection === 'medical HUD' ? med_hud : sec_hud;
      return (
        <Button icon="power-off" selected={enabled} onClick={() => use()}>
          {enabled ? 'Włączony' : 'Wyłączony'}
        </Button>
      );
    }
    case 'encryption keys':
      return (
        <Button icon="key" onClick={() => use()} disabled={!!encryption_keys}>
          {encryption_keys ? 'Porty kluczy aktywne' : 'Aktywuj porty kluczy'}
        </Button>
      );
    case 'universal translator':
      return (
        <Button icon="download" onClick={() => use()} disabled={!!languages}>
          {!languages ? 'Zainstaluj' : 'Zainstalowano'}
        </Button>
      );
    default:
      return (
        <Button icon="power-off" onClick={() => use()}>
          Uruchom
        </Button>
      );
  }
}

/** AQUILA: nasz zintegrowany sygnalizator nie ma osobnego okna */
function SignalerControls(props) {
  const { act, data } = useBackend<PaiData>();
  const {
    signaler_code,
    signaler_frequency,
    signaler_max_freq,
    signaler_min_freq,
  } = data;

  return (
    <LabeledList>
      <LabeledList.Item label="Częstotliwość">
        <NumberInput
          animated
          unit="kHz"
          step={0.2}
          stepPixelSize={6}
          minValue={signaler_min_freq / 10}
          maxValue={signaler_max_freq / 10}
          value={signaler_frequency / 10}
          format={(value) => value.toFixed(1)}
          width="80px"
          onChange={(value) =>
            act('software', {
              software: 'remote signaller',
              mode: 'freq',
              value: Math.round(value * 10),
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Kod">
        <NumberInput
          animated
          step={1}
          stepPixelSize={6}
          minValue={1}
          maxValue={100}
          value={signaler_code}
          width="80px"
          onChange={(value) =>
            act('software', {
              software: 'remote signaller',
              mode: 'code',
              value,
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Sygnał">
        <Button
          icon="arrow-up"
          onClick={() =>
            act('software', { software: 'remote signaller', mode: 'send' })
          }
        >
          Wyślij sygnał
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
}

/** AQUILA: odczyt czujnika atmosfery na żywo */
function AtmosReadout(props) {
  const { act, data } = useBackend<PaiData>();
  const { atmos } = data;

  if (!atmos) {
    return <NoticeBox>Nie można uzyskać odczytu.</NoticeBox>;
  }

  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Ciśnienie">
          {atmos.pressure} kPa
        </LabeledList.Item>
        <LabeledList.Item label="Temperatura">
          {atmos.temperature}&deg;C
        </LabeledList.Item>
        {atmos.gases.map((gas) => (
          <LabeledList.Item key={gas.name} label={gas.name}>
            {gas.percent}%
          </LabeledList.Item>
        ))}
      </LabeledList>
      <Button
        mt={1}
        icon="search"
        onClick={() => act('software', { software: 'atmosphere sensor' })}
      >
        Pełna analiza
      </Button>
    </>
  );
}

const GENERAL_FIELDS: [string, string][] = [
  ['id', 'ID'],
  ['rank', 'Stanowisko'],
  ['gender', 'Płeć'],
  ['age', 'Wiek'],
  ['fingerprint', 'Odcisk palca'],
  ['p_stat', 'Stan fizyczny'],
  ['m_stat', 'Stan psychiczny'],
];

const MEDICAL_FIELDS: [string, string][] = [
  ['blood_type', 'Grupa krwi'],
  ['b_dna', 'DNA'],
  ['mi_dis', 'Drobne niepełnosprawności'],
  ['mi_dis_d', 'Szczegóły'],
  ['ma_dis', 'Poważne niepełnosprawności'],
  ['ma_dis_d', 'Szczegóły'],
  ['alg', 'Alergie'],
  ['alg_d', 'Szczegóły'],
  ['cdi', 'Obecne choroby'],
  ['cdi_d', 'Szczegóły'],
  ['notes', 'Ważne uwagi'],
];

const SECURITY_FIELDS: [string, string][] = [
  ['criminal', 'Status'],
  ['crim', 'Przestępstwa'],
  ['crim_d', 'Szczegóły'],
  ['notes', 'Ważne uwagi'],
];

/** AQUILA: akta medyczne i ochrony (w tg przeniesione do PDA) */
function RecordsDisplay(props: { selection: string }) {
  const { act, data } = useBackend<PaiData>();
  const { records, records_type } = data;
  const { selection } = props;
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const wantedType = selection === 'medical records' ? 'medical' : 'security';
  if (records_type !== wantedType || !records) {
    return (
      <Button
        icon="folder-open"
        onClick={() => act('software', { software: selection })}
      >
        Otwórz akta
      </Button>
    );
  }

  const selected = records.find((record) => record.id === selectedId);
  const detailFields =
    wantedType === 'medical' ? MEDICAL_FIELDS : SECURITY_FIELDS;

  return (
    <>
      <Button
        icon="folder"
        onClick={() => act('software', { software: selection })}
      >
        Zamknij akta
      </Button>
      {selected ? (
        <RecordDetails
          record={selected}
          fields={detailFields}
          onBack={() => setSelectedId(null)}
        />
      ) : (
        <Box mt={1}>
          {records.length === 0 && <NoticeBox>Brak akt.</NoticeBox>}
          {records.map((record) => (
            <Button
              fluid
              key={record.id}
              onClick={() => setSelectedId(record.id)}
            >
              {record.id}: {decodeHtmlEntities(record.name || '')}
            </Button>
          ))}
        </Box>
      )}
    </>
  );
}

type RecordDetailsProps = {
  fields: [string, string][];
  onBack: () => void;
  record: PaiRecord;
};

function RecordDetails(props: RecordDetailsProps) {
  const { fields, onBack, record } = props;

  return (
    <Box mt={1}>
      <Button icon="arrow-left" onClick={onBack}>
        Wróć
      </Button>
      <Box bold mt={1} mb={1}>
        {decodeHtmlEntities(record.name || '')}
      </Box>
      <LabeledList>
        {[...GENERAL_FIELDS, ...fields].map(([key, label]) => (
          <LabeledList.Item key={key + label} label={label}>
            {record[key] ? decodeHtmlEntities(String(record[key])) : '—'}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Box>
  );
}
