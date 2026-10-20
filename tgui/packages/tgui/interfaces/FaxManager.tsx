// AQUILA: menedżer faksów dla adminów (code/modules/paperwork/fax_manager.dm).
// tg nie ma odpowiednika — zostaje nasze okno, przetłumaczone.
import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  Modal,
  Section,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FaxManagerData = {
  faxes: FaxInfo[];
  additional_faxes: AdditionalFaxesList[];
  requests: RequestsList[];
};

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  syndicate_network: boolean;
};

type AdditionalFaxesList = {
  fax_name: string;
  button_color: string;
};

type RequestsList = {
  id_message: number;
  time: string;
  sender_name: string;
  sender_fax_id: string;
  sender_fax_name: string;
  receiver_fax_name: string;
  paper_raw_text: string;
};

// Wartość tylko po stronie okna — do DM idzie wpisana nazwa.
const CUSTOM_NAME = 'Własna nazwa';

export const FaxManager = (props) => {
  const { act, data } = useBackend<FaxManagerData>();
  const faxes = data.faxes
    ? sortBy(data.faxes, [(sortFax: FaxInfo) => sortFax.fax_name])
    : [];

  const [messagingAssociates, setMessagingAssociates] = useState(false);
  const [selectedFaxId, setSelectedFaxId] = useState('');
  const [selectedFaxName, setSelectedFaxName] = useState('');
  return (
    <Window title="Menedżer faksów" width={600} height={700} theme="admin">
      <Window.Content scrollable>
        <Section title="Wyślij">
          {faxes.length !== 0 ? (
            <Box mt={0.4}>
              {faxes.map((fax: FaxInfo) => (
                <Button
                  key={fax.fax_id}
                  tooltip={fax.fax_name}
                  color={fax.syndicate_network ? 'red' : 'blue'}
                  onClick={() => {
                    setSelectedFaxId(fax.fax_id);
                    setSelectedFaxName(fax.fax_name);
                    setMessagingAssociates(true);
                  }}
                >
                  {fax.fax_name}
                </Button>
              ))}
            </Box>
          ) : (
            'Menedżer nie wykrył w sieci żadnych faksów.'
          )}
        </Section>
        <Section title="Wiadomości">
          <Flex direction="column">
            {!!data.requests &&
              data.requests.map((request: RequestsList) => (
                <Flex.Item key={request.id_message}>
                  <RequestControl
                    id_message={request.id_message}
                    sender_fax_id={request.sender_fax_id}
                    receiver_fax_name={request.receiver_fax_name}
                    time={request.time}
                    sender_name={request.sender_name}
                    sender_fax_name={request.sender_fax_name}
                  />
                </Flex.Item>
              ))}
          </Flex>
        </Section>
      </Window.Content>
      {!!messagingAssociates && (
        <FaxMessageModal
          selectedFaxId={selectedFaxId}
          selectedFaxName={selectedFaxName}
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(selectedFaxId, selectedSenderName, messageInput) => {
            setMessagingAssociates(false);
            act('send', {
              fax_id: selectedFaxId,
              fax_name: selectedSenderName,
              message: messageInput,
            });
          }}
          onFollow={(selectedFaxId) => {
            act('flw_fax', {
              fax_id: selectedFaxId,
            });
          }}
        />
      )}
    </Window>
  );
};

type FaxMessageModalProps = {
  selectedFaxId: string;
  selectedFaxName: string;
  onBack: () => void;
  onSubmit: (faxId: string, senderName: string, message: string) => void;
  onFollow: (faxId: string) => void;
};

const FaxMessageModal = (props: FaxMessageModalProps) => {
  const { data } = useBackend<FaxManagerData>();
  const [messageInput, setMessageInput] = useState('');

  const additional_faxes: string[] = (data.additional_faxes || []).map(
    (fax) => fax.fax_name,
  );
  additional_faxes.push(CUSTOM_NAME);

  const [selectedSenderName, setSelectedSenderName] = useState(
    additional_faxes[0],
  );
  const [customSenderName, setCustomSenderName] = useState('');

  const isCustom = selectedSenderName === CUSTOM_NAME;
  const senderName = isCustom ? customSenderName : selectedSenderName;
  const canSend = !!messageInput && !!senderName;

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          Wiadomość do {props.selectedFaxName}/{props.selectedFaxId}:
        </Flex.Item>
        <Flex.Item maxWidth="100%">
          <LabeledList>
            <LabeledList.Item label="Nadawca">
              <Dropdown
                options={additional_faxes}
                selected={selectedSenderName}
                onSelected={(value) => setSelectedSenderName(value)}
              />
            </LabeledList.Item>
            {isCustom && (
              <LabeledList.Item label="Własna nazwa nadawcy">
                <Input
                  value={customSenderName}
                  onChange={(value) => setCustomSenderName(value)}
                />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Flex.Item>
        <Flex.Item mr={2} mb={1} mt={1}>
          <TextArea
            fluid
            height="20vh"
            width="80vw"
            backgroundColor="black"
            textColor="white"
            onChange={(value) => {
              setMessageInput(value.substring(0, 5000));
            }}
            value={messageInput}
          />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="paper-plane"
            color="good"
            disabled={!canSend}
            onClick={() => {
              if (!canSend) {
                return;
              }
              props.onSubmit(props.selectedFaxId, senderName, messageInput);
              setCustomSenderName('');
              setMessageInput('');
            }}
          >
            Wyślij
          </Button>
          <Button
            icon="times"
            color="bad"
            onClick={() => {
              props.onBack();
              setMessageInput('');
            }}
          >
            Anuluj
          </Button>
          <Button
            icon="eye"
            onClick={() => {
              props.onFollow(props.selectedFaxId);
            }}
          >
            Obserwuj faks
          </Button>
        </Flex.Item>
      </Flex>
    </Modal>
  );
};

const RequestControl = (props) => {
  const { act } = useBackend<FaxManagerData>();
  return (
    <Section
      title={props.receiver_fax_name}
      buttons={
        <>
          <Button
            onClick={() =>
              act('read_message', { id_message: props.id_message })
            }
            color="good"
          >
            Czytaj
          </Button>
          <Button
            onClick={() => act('flw_fax', { fax_id: props.sender_fax_id })}
          >
            FLW faks
          </Button>
          <Button onClick={() => act('flw', { id_message: props.id_message })}>
            FLW
          </Button>
          <Button onClick={() => act('pp', { id_message: props.id_message })}>
            PP
          </Button>
          <Button onClick={() => act('vv', { id_message: props.id_message })}>
            VV
          </Button>
          <Button onClick={() => act('sm', { id_message: props.id_message })}>
            SM
          </Button>
          <Button onClick={() => act('logs', { id_message: props.id_message })}>
            LOGI
          </Button>
          <Button
            onClick={() => act('smite', { id_message: props.id_message })}
          >
            SMITE
          </Button>
        </>
      }
    >
      [{props.time}] Wiadomość od {props.sender_fax_name}/{props.sender_name}
    </Section>
  );
};
