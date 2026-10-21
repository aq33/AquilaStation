import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: nasza karta agenta nie ma systemu "trim"/wildcardów z tg
// (dostępy kopiuje się w całości, przykładając inną kartę), więc okno
// służy do fałszowania tożsamości: imię, stanowisko, wygląd karty i konto.
type Data = {
  registered_name: string | null;
  assignment: string | null;
  default_name: string;
  forged: BooleanLike;
  account_id: number | null;
  account_holder: string | null;
  accesses: string[];
  styles: string[];
};

const KEEP_STYLE = 'Bez zmian';

export const ChameleonCard = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    registered_name,
    assignment,
    default_name,
    forged,
    account_id,
    account_holder,
    accesses = [],
    styles = [],
  } = data;

  const [name, setName] = useState(registered_name || default_name || '');
  const [job, setJob] = useState(assignment || 'Assistant');
  const [style, setStyle] = useState(KEEP_STYLE);

  // Po resecie/fałszowaniu pola pokazują to, co jest na karcie.
  useEffect(() => {
    setName(registered_name || default_name || '');
    setJob(assignment || 'Assistant');
  }, [registered_name, assignment]);

  return (
    <Window width={420} height={520}>
      <Window.Content scrollable>
        <Section
          title="Tożsamość"
          buttons={
            <Button icon="id-card" onClick={() => act('show')}>
              Pokaż kartę
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Imię">
              <Input
                fluid
                value={name}
                placeholder="Puste = losowe"
                onChange={(value) => setName(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Stanowisko">
              <Input fluid value={job} onChange={(value) => setJob(value)} />
            </LabeledList.Item>
            <LabeledList.Item label="Wygląd karty">
              <Dropdown
                width="100%"
                selected={style}
                options={[KEEP_STYLE, ...styles]}
                onSelected={(value) => setStyle(value)}
              />
            </LabeledList.Item>
          </LabeledList>
          <Box mt={1} color="label">
            Stanowisko nie daje żadnych dostępów poza tunelami technicznymi.
            Ikona na HUD-zie odpowiada wybranemu wyglądowi karty.
          </Box>
          <Stack mt={1}>
            <Stack.Item grow>
              <Button
                fluid
                icon="pen"
                color="good"
                textAlign="center"
                onClick={() =>
                  act('forge', {
                    name,
                    assignment: job,
                    style: style === KEEP_STYLE ? null : style,
                  })
                }
              >
                {forged ? 'Sfałszuj ponownie' : 'Sfałszuj'}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="undo"
                color="bad"
                textAlign="center"
                disabled={!forged}
                onClick={() => act('reset')}
              >
                Resetuj
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="Konto bankowe"
          buttons={
            <Button icon="university" onClick={() => act('change_account')}>
              Zmień konto
            </Button>
          }
        >
          {account_id ? (
            <LabeledList>
              <LabeledList.Item label="Numer konta">
                {account_id}
              </LabeledList.Item>
              <LabeledList.Item label="Właściciel">
                {account_holder}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="label">Brak przypisanego konta.</Box>
          )}
        </Section>
        <Section title="Dostępy">
          <Box color="label" mb={1}>
            Przyłóż kartę agenta do innej karty ID, aby skopiować jej dostępy.
          </Box>
          {accesses.length === 0 ? (
            <NoticeBox>Brak dostępów.</NoticeBox>
          ) : (
            accesses.map((access) => <Box key={access}>• {access}</Box>)
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
