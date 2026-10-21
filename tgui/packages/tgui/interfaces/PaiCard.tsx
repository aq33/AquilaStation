import {
  BlockQuote,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  candidates: ReadonlyArray<Candidate>;
  pai: Pai | null;
};

type Candidate = Readonly<{
  comments: string;
  description: string;
  name: string;
  ref: string;
  // AQUILA: preferowana rola kandydata
  role: string;
}>;

type Pai = {
  can_holo: BooleanLike;
  dna: string;
  has_radio: BooleanLike;
  // AQUILA: tylko właściciel może przełączać holomatrycę i usuwać dyrektywę główną
  is_master: BooleanLike;
  laws: string[];
  master: string;
  name: string;
  prime_directive: string;
  receive: BooleanLike;
  transmit: BooleanLike;
};

export const PaiCard = (props) => {
  const { data } = useBackend<Data>();
  const { pai } = data;

  return (
    <Window width={400} height={400} title="Ustawienia pAI">
      <Window.Content scrollable>
        {!pai ? <PaiDownload /> : <PaiOptions />}
      </Window.Content>
    </Window>
  );
};

/** Gives a list of candidates as cards */
const PaiDownload = (props) => {
  const { act, data } = useBackend<Data>();
  const { candidates = [] } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <NoticeBox info>
          <Stack fill>
            <Stack.Item grow fontSize="16px">
              Kandydaci na pAI
            </Stack.Item>
            <Stack.Item>
              <Button
                color="good"
                icon="bell"
                onClick={() => act('request')}
                tooltip="Poproś zaświaty o więcej kandydatów."
              >
                Poproś
              </Button>
            </Stack.Item>
          </Stack>
        </NoticeBox>
      </Stack.Item>
      {candidates.length === 0 && (
        <Stack.Item>
          <NoticeBox>
            Brak dostępnych osobowości. Spróbuj ponownie później.
          </NoticeBox>
        </Stack.Item>
      )}
      {candidates.map((candidate, index) => {
        return (
          <Stack.Item key={candidate.ref}>
            <CandidateDisplay candidate={candidate} index={index + 1} />
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

/**
 * Renders a custom section that displays a candidate.
 */
const CandidateDisplay = (props: { candidate: Candidate; index: number }) => {
  const { act } = useBackend<Data>();
  const {
    candidate: { comments, description, name, ref, role },
    index,
  } = props;

  return (
    <Section
      buttons={
        <Button icon="save" onClick={() => act('download', { candidate: ref })}>
          Pobierz
        </Button>
      }
      overflow="hidden"
      title={`Kandydat ${index}`}
    >
      <Stack vertical>
        <Stack.Item>
          <Box color="label" mb={1}>
            Imię:
          </Box>
          {name ? (
            <Box color="green">{decodeHtmlEntities(name)}</Box>
          ) : (
            'Nie podano – imię zostanie wylosowane.'
          )}
        </Stack.Item>
        {!!description && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                Opis IC:
              </Box>
              {decodeHtmlEntities(description)}
            </Stack.Item>
          </>
        )}
        {!!role && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                Preferowana rola:
              </Box>
              {decodeHtmlEntities(role)}
            </Stack.Item>
          </>
        )}
        {!!comments && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                Uwagi OOC:
              </Box>
              {decodeHtmlEntities(comments)}
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

/** Once a pAI has been loaded, you can alter its settings here */
const PaiOptions = (props) => {
  const { act, data } = useBackend<Data>();
  const pai = data.pai as Pai;
  const {
    can_holo,
    dna,
    has_radio,
    is_master,
    laws = [],
    master,
    name,
    prime_directive,
    transmit,
    receive,
  } = pai;
  const suppliedLaws = laws[0] ? decodeHtmlEntities(laws[0]) : 'Brak';

  return (
    <Section fill scrollable title={`Ustawienia: ${name.toUpperCase()}`}>
      <LabeledList>
        <LabeledList.Item label="Właściciel">
          {master || (
            <Button icon="dna" onClick={() => act('set_dna')}>
              Zapisz DNA
            </Button>
          )}
        </LabeledList.Item>
        {!!master && (
          <LabeledList.Item color="red" label="DNA">
            {dna}
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Dyrektywa główna">
          {prime_directive ? decodeHtmlEntities(prime_directive) : 'Brak'}
          {!!prime_directive && !!is_master && (
            <Button.Confirm
              ml={1}
              color="bad"
              icon="eraser"
              onClick={() => act('clear_zero')}
            >
              Usuń
            </Button.Confirm>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Dyrektywy dodatkowe">
          <BlockQuote>{suppliedLaws}</BlockQuote>
        </LabeledList.Item>
        {!!is_master && (
          <LabeledList.Item label="Holomatryca">
            <Button
              icon={can_holo ? 'toggle-on' : 'toggle-off'}
              onClick={() => act('toggle_holo')}
              selected={can_holo}
            >
              {can_holo ? 'Włączona' : 'Wyłączona'}
            </Button>
          </LabeledList.Item>
        )}
        {has_radio ? (
          <>
            <LabeledList.Item label="Nadawanie">
              <Button
                icon={transmit ? 'toggle-on' : 'toggle-off'}
                onClick={() => act('toggle_radio', { option: 'transmit' })}
                selected={transmit}
              >
                {transmit ? 'Włączone' : 'Wyłączone'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Odbiór">
              <Button
                icon={receive ? 'toggle-on' : 'toggle-off'}
                onClick={() => act('toggle_radio', { option: 'receive' })}
                selected={receive}
              >
                {receive ? 'Włączony' : 'Wyłączony'}
              </Button>
            </LabeledList.Item>
          </>
        ) : (
          <LabeledList.Item label="Łącze radiowe">
            <Box color="bad" italic>
              Nie wczytano oprogramowania radia.
            </Box>
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Konfiguracja">
          <Button icon="edit" onClick={() => act('set_laws')}>
            Ustaw dyrektywy
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Osobowość">
          <Button color="bad" icon="trash" onClick={() => act('wipe_pai')}>
            Usuń
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
