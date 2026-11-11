import { useState } from 'react';
import { createPortal } from 'react-dom';
import {
  Box,
  Button,
  Flex,
  Modal,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { AlertButton } from './AlertButton';
import { ALERT_LEVELS, alertLevelName } from './constants';
import { MessageModal } from './MessageModal';
import type { CommsConsoleData } from './types';

type Props = {
  // AQUILA: okna dialogowe idą na cały ekran konsoli, nie do wąskiej lewej kolumny
  modalRoot: HTMLElement | null;
};

export function PageMain(props: Props) {
  const { modalRoot } = props;
  const { act, data } = useBackend<CommsConsoleData>();
  const {
    alertLevel,
    callShuttleReasonMinLength,
    canMakeAnnouncement,
    canMessageAssociates,
    canPrintAIControlCode,
    canRecallShuttles,
    canRequestNuke,
    canRequestERT,
    canSendToSectors,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    canToggleNightShift,
    emagged,
    emergencyAccess,
    nightShiftDisabled,
    importantActionReady,
    reinforcementActionReady,
    crewWakeActionReady,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const [callingShuttle, setCallingShuttle] = useState(false);
  const [messagingAssociates, setMessagingAssociates] = useState(false);
  const [messagingSector, setMessagingSector] = useState(false);
  const [requestingNukeCodes, setRequestingNukeCodes] = useState(false);
  // AQUILA: ERT i wybudzanie załogi
  const [requestingResponseTeam, setRequestingResponseTeam] = useState(false);
  const [requestingCrewWake, setRequestingCrewWake] = useState(false);

  const [newAlertLevel, setNewAlertLevel] = useState('');
  const showAlertLevelConfirm = newAlertLevel && newAlertLevel !== alertLevel;

  const modals = (
    <>
      {!!canMessageAssociates && messagingAssociates && (
        <MessageModal
          label={`Wiadomość do przesłania ${
            emagged ? 'pod [NIEPRAWIDŁOWE WSPÓŁRZĘDNE ROUTINGU]' : 'do CentComu'
          } przez splątanie kwantowe`}
          notice="Pamiętaj, że ten proces jest bardzo kosztowny, a nadużycia skończą się... zwolnieniem. Przesłanie nie gwarantuje odpowiedzi. Szefowie działów mogą z tego korzystać tylko w sytuacji awaryjnej."
          icon="bullhorn"
          buttonText="Wyślij"
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(message) => {
            setMessagingAssociates(false);
            act('messageAssociates', {
              message,
            });
          }}
        />
      )}

      {!!canRequestNuke && requestingNukeCodes && (
        <MessageModal
          label="Powód prośby o kody autodestrukcji jądrowej"
          notice="Nadużycia systemu próśb o kody jądrowe nie będą tolerowane w żadnych okolicznościach. Przesłanie nie gwarantuje odpowiedzi."
          icon="bomb"
          buttonText="Poproś o kody"
          onBack={() => setRequestingNukeCodes(false)}
          onSubmit={(reason) => {
            setRequestingNukeCodes(false);
            act('requestNukeCodes', {
              reason,
            });
          }}
        />
      )}

      {!!canRequestERT && requestingResponseTeam && (
        <MessageModal
          label="Powód wezwania zespołu reagowania kryzysowego"
          notice="Nadużycia systemu wzywania zespołu reagowania nie będą tolerowane w żadnych okolicznościach. Przesłanie nie gwarantuje odpowiedzi."
          icon="bomb"
          buttonText="Wezwij ERT"
          onBack={() => setRequestingResponseTeam(false)}
          onSubmit={(reason) => {
            setRequestingResponseTeam(false);
            act('requestERT', {
              reason,
            });
          }}
        />
      )}

      {!!canRequestERT && requestingCrewWake && (
        <MessageModal
          label="Powód wybudzenia dodatkowej załogi z kriostazy"
          notice="Wybudzeni zostaną ochotnicy jako Majtkowie, przy komorach snu. Prośba nie gwarantuje odpowiedzi."
          icon="snowflake"
          buttonText="Wybudź załogę"
          onBack={() => setRequestingCrewWake(false)}
          onSubmit={(reason) => {
            setRequestingCrewWake(false);
            act('requestCrewWake', {
              reason,
            });
          }}
        />
      )}

      {!!callingShuttle && (
        <MessageModal
          label="Rodzaj zagrożenia"
          icon="space-shuttle"
          buttonText="Wezwij prom"
          minLength={callShuttleReasonMinLength}
          onBack={() => setCallingShuttle(false)}
          onSubmit={(reason) => {
            setCallingShuttle(false);
            act('callShuttle', {
              reason,
            });
          }}
        />
      )}

      {!!canSendToSectors && messagingSector && (
        <MessageModal
          label="Wiadomość do sojuszniczej stacji"
          notice="Pamiętaj, że ten proces jest bardzo kosztowny, a nadużycia skończą się... zwolnieniem."
          icon="bullhorn"
          buttonText="Wyślij"
          onBack={() => setMessagingSector(false)}
          onSubmit={(message) => {
            act('sendToOtherSector', {
              message,
            });
            setMessagingSector(false);
          }}
        />
      )}

      {!!canSetAlertLevel && showAlertLevelConfirm && (
        <Modal>
          <Flex direction="column" textAlign="center" width="300px">
            <Flex.Item fontSize="16px" mb={2}>
              Przeciągnij ID, by potwierdzić zmianę
            </Flex.Item>

            <Flex.Item mr={2} mb={1}>
              <Button
                icon="id-card-o"
                color="good"
                fontSize="16px"
                onClick={() => {
                  act('changeSecurityLevel', {
                    newSecurityLevel: newAlertLevel,
                  });
                  setNewAlertLevel('');
                }}
              >
                Przeciągnij ID
              </Button>

              <Button
                icon="times"
                color="bad"
                fontSize="16px"
                onClick={() => setNewAlertLevel('')}
              >
                Anuluj
              </Button>
            </Flex.Item>
          </Flex>
        </Modal>
      )}
    </>
  );

  return (
    <Box>
      <Section title="Prom ewakuacyjny">
        {shuttleCalled ? (
          <Button.Confirm
            icon="space-shuttle"
            color="bad"
            confirmContent="Na pewno odwołać?"
            disabled={!canRecallShuttles || !shuttleRecallable}
            tooltip={
              canRecallShuttles
                ? !shuttleRecallable &&
                  'Na odwołanie promu ewakuacyjnego jest już za późno.'
                : 'Nie masz uprawnień do odwołania promu ewakuacyjnego.'
            }
            tooltipPosition="bottom-end"
            onClick={() => act('recallShuttle')}
          >
            Odwołaj prom ewakuacyjny
          </Button.Confirm>
        ) : (
          <Button
            icon="space-shuttle"
            disabled={shuttleCanEvacOrFailReason !== 1}
            tooltip={
              shuttleCanEvacOrFailReason !== 1
                ? shuttleCanEvacOrFailReason
                : undefined
            }
            tooltipPosition="bottom-end"
            onClick={() => setCallingShuttle(true)}
          >
            Wezwij prom ewakuacyjny
          </Button>
        )}
        {!!shuttleCalledPreviously &&
          (shuttleLastCalled ? (
            <Box>
              Ostatnie wezwanie/odwołanie promu namierzono do:{' '}
              <b>{shuttleLastCalled}</b>
            </Box>
          ) : (
            <Box>
              Nie udało się namierzyć ostatniego sygnału wezwania/odwołania
              promu.
            </Box>
          ))}
      </Section>

      {!!canSetAlertLevel && (
        <Section title="Poziom alarmu">
          <Box mb={1}>
            Obecnie: <b>{alertLevelName(alertLevel)}</b>
          </Box>
          {ALERT_LEVELS.map((level) => (
            <AlertButton
              key={level}
              alertLevel={level}
              onClick={() => setNewAlertLevel(level)}
            />
          ))}
        </Section>
      )}

      <Section title="Funkcje">
        <Flex direction="column">
          {!!canMakeAnnouncement && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="bullhorn"
                onClick={() => act('makePriorityAnnouncement')}
              >
                Nadaj ogłoszenie priorytetowe
              </Button>
            </Flex.Item>
          )}

          {!!canToggleEmergencyAccess && (
            <Flex.Item mt={0.3}>
              <Button.Confirm
                fluid
                icon="id-card-o"
                confirmIcon="id-card-o"
                confirmContent="Na pewno?"
                color={emergencyAccess ? 'bad' : undefined}
                onClick={() => act('toggleEmergencyAccess')}
              >
                {emergencyAccess ? 'Wyłącz' : 'Włącz'} awaryjny dostęp do tuneli
                technicznych
              </Button.Confirm>
            </Flex.Item>
          )}

          {!!canToggleNightShift && (
            <Flex.Item mt={0.3}>
              <Button.Confirm
                fluid
                icon="moon"
                confirmIcon="moon"
                confirmContent="Na pewno?"
                color={nightShiftDisabled ? 'bad' : undefined}
                onClick={() => act('toggleNightShift')}
              >
                {nightShiftDisabled
                  ? 'Przywróć automatyczne oświetlenie nocne'
                  : 'Wyłącz oświetlenie nocne'}
              </Button.Confirm>
            </Flex.Item>
          )}

          {!!canMessageAssociates && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="comment-o"
                disabled={!importantActionReady}
                onClick={() => setMessagingAssociates(true)}
              >
                Wyślij wiadomość do {emagged ? '[NIEZNANE]' : 'CentComu'}
              </Button>
            </Flex.Item>
          )}

          {!!canRequestNuke && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="radiation"
                disabled={!importantActionReady}
                onClick={() => setRequestingNukeCodes(true)}
              >
                Poproś o kody uwierzytelniania ładunku jądrowego
              </Button>
            </Flex.Item>
          )}

          {!!canRequestERT && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="dumpster-fire"
                disabled={!reinforcementActionReady}
                onClick={() => setRequestingResponseTeam(true)}
              >
                Wezwij zespół reagowania kryzysowego
              </Button>
            </Flex.Item>
          )}

          {!!canRequestERT && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="snowflake"
                disabled={!crewWakeActionReady}
                onClick={() => setRequestingCrewWake(true)}
              >
                Wybudź załogę z kriostazy
              </Button>
            </Flex.Item>
          )}

          {!!canPrintAIControlCode && (
            <Flex.Item mt={0.3}>
              <Button.Confirm
                fluid
                icon="key"
                disabled={!importantActionReady}
                confirmContent="Unieważnić stary kod?"
                onClick={() => act('printAIControlCode')}
              >
                Wydrukuj nowy kod kontrolny SI
              </Button.Confirm>
            </Flex.Item>
          )}

          {!!emagged && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="undo"
                onClick={() => act('restoreBackupRoutingData')}
              >
                Przywróć zapasowe dane routingu
              </Button>
            </Flex.Item>
          )}

          {!canMakeAnnouncement &&
            !canToggleEmergencyAccess &&
            !canToggleNightShift &&
            !canMessageAssociates &&
            !canRequestNuke &&
            !canRequestERT &&
            !emagged && <Flex.Item>Brak dostępnych funkcji</Flex.Item>}
        </Flex>
      </Section>

      {!!canSendToSectors && (
        <Section title="Sektory sojusznicze">
          <Button
            fluid
            icon="satellite-dish"
            disabled={!importantActionReady}
            onClick={() => setMessagingSector(true)}
          >
            Wyślij wiadomość do sojuszniczych stacji
          </Button>
        </Section>
      )}

      <ShipPASection />

      {modalRoot ? createPortal(modals, modalRoot) : modals}
    </Box>
  );
}

// AQUILA: nagłośnienie statku, wcześniej osobny program NtOS na konsolach dowodzenia
function ShipPASection() {
  const { act, data } = useBackend<CommsConsoleData>();
  const { canControlPA, paOnShip, paJukeboxes = [] } = data;
  if (!canControlPA) {
    return null;
  }
  return (
    <Section title="Nagłośnienie statku">
      <Box color="label" mb={1}>
        Nadający jukebox gra przez głośniki nagłośnienia na korytarzach; w
        pomieszczeniach i maintach słychać je przez ściany, ciszej. Na raz może
        nadawać tylko jeden. Kto jest bliżej innego grającego jukeboxa, słyszy
        ten głośniejszy.
      </Box>
      {!paOnShip && (
        <NoticeBox danger>Ta konsola nie jest na żadnym statku.</NoticeBox>
      )}
      {paJukeboxes.length === 0 ? (
        <Box color="label">Brak jukeboxów na tym statku.</Box>
      ) : (
        <Table>
          {paJukeboxes.map((jukebox) => (
            <Table.Row key={jukebox.ref} className="candystripe">
              <Table.Cell>
                <Box bold>{jukebox.name}</Box>
                <Box color="label">{jukebox.area}</Box>
              </Table.Cell>
              <Table.Cell>
                {jukebox.playing ? (
                  jukebox.title || 'Łączenie...'
                ) : (
                  <Box color="label">Cisza</Box>
                )}
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon={jukebox.shipwide ? 'volume-up' : 'volume-off'}
                  selected={!!jukebox.shipwide}
                  tooltip={
                    jukebox.shipwide
                      ? 'Wyłącz nadawanie na cały statek'
                      : 'Puść ten jukebox na cały statek'
                  }
                  tooltipPosition="left"
                  onClick={() => act('togglePA', { ref: jukebox.ref })}
                >
                  {jukebox.shipwide ? 'Nadaje' : 'Nadawaj'}
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}
