import { useEffect, useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  comments: string;
  description: string;
  name: string;
  ready: BooleanLike;
  // AQUILA: preferowana rola
  role: string;
};

type Inputs = {
  comments: string;
  description: string;
  name: string;
  role: string;
};

const PAI_DESCRIPTION = `Osobiste SI to zaawansowane modele zdolne do
subtelnej interakcji. Mają pomagać swoim właścicielom w pracy. Nie mają rąk,
więc nie mogą obsługiwać sprzętu ani przedmiotów. W formie hologramu nie da
się cię bezpośrednio zabić, ale można cię unieszkodliwić.`;

const PAI_RULES = `Oczekujemy od ciebie odgrywania postaci. Pamiętaj: jeśli
nic nie wpiszesz, możesz nie zostać wybrany. Naciśnij „Zgłoś”, aby
powiadomić karty pAI o swojej kandydaturze.`;

const toInputs = (data: Data): Inputs => ({
  comments: decodeHtmlEntities(data.comments || ''),
  description: decodeHtmlEntities(data.description || ''),
  name: decodeHtmlEntities(data.name || ''),
  role: decodeHtmlEntities(data.role || ''),
});

export const PaiSubmit = (props) => {
  const { data } = useBackend<Data>();
  const { comments, description, name, role } = data;
  const [input, setInput] = useState<Inputs>(toInputs(data));

  // Wczytanie zapisanej osobowości zmienia dane z DM - odśwież pola
  useEffect(() => {
    setInput(toInputs(data));
  }, [comments, description, name, role]);

  return (
    <Window width={400} height={520} title="Kandydatura na pAI">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <DetailsDisplay />
          </Stack.Item>
          <Stack.Item>
            <InputDisplay input={input} setInput={setInput} />
          </Stack.Item>
          <Stack.Item>
            <ButtonsDisplay input={input} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays basic info about playing pAI */
const DetailsDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { ready } = data;

  return (
    <Section fill scrollable title="Informacje">
      <Box color="label">
        {PAI_DESCRIPTION}
        <br />
        <br />
        {PAI_RULES}
      </Box>
      {!!ready && (
        <Box mt={1} color="good" bold>
          Twoja kandydatura jest zgłoszona.
        </Box>
      )}
    </Section>
  );
};

type InputDisplayProps = {
  input: Inputs;
  setInput: (input: Inputs) => void;
};

/** Input boxes for submission details */
const InputDisplay = (props: InputDisplayProps) => {
  const { input, setInput } = props;
  const { name, description, role, comments } = input;

  return (
    <Section fill title="Dane">
      <Stack fill vertical>
        <Stack.Item>
          <Box bold color="label">
            Imię
          </Box>
          <Input
            fluid
            maxLength={41}
            value={name}
            onChange={(value) => setInput({ ...input, name: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            Opis
          </Box>
          <Input
            fluid
            maxLength={1024}
            value={description}
            onChange={(value) => setInput({ ...input, description: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            Preferowana rola
          </Box>
          <Input
            fluid
            maxLength={1024}
            value={role}
            onChange={(value) => setInput({ ...input, role: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            Uwagi OOC
          </Box>
          <Input
            fluid
            maxLength={1024}
            value={comments}
            onChange={(value) => setInput({ ...input, comments: value })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Gives the user a submit button */
const ButtonsDisplay = (props: { input: Inputs }) => {
  const { act } = useBackend<Data>();
  const { input } = props;

  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Button
            onClick={() => act('save', input)}
            tooltip="Zapisuje dane kandydata lokalnie."
          >
            ZAPISZ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('load')}
            tooltip="Wczytuje zapisane dane kandydata, jeśli istnieją."
          >
            WCZYTAJ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button color="good" onClick={() => act('submit', input)}>
            ZGŁOŚ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('withdraw')}
            tooltip="Wycofuje twoją kandydaturę na pAI, jeśli jakaś jest."
          >
            WYCOFAJ
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
