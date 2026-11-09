// NSV13
// AQUILA: automat drużyny po reworku: jeden zestaw według funkcji, wydawany w skrzyni.

import { Box, Button, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  user_name: string;
  squad: string | null;
  squad_colour: string | null;
  position: string | null;
  weapons_clearance: BooleanLike;
  already_loaned: BooleanLike;
  missing: string[];
  fine: number;
  kit: { name: string; desc: string; contents: string[] } | null;
};

export const SquadVendor = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="ntos" width={460} height={560}>
      <Window.Content scrollable>
        <Section title={`Witaj, ${data.user_name}`}>
          {data.squad ? (
            <Box>
              Drużyna{' '}
              <Box inline bold color={data.squad_colour || undefined}>
                {data.squad}
              </Box>
              , funkcja: <b>{data.position}</b>
            </Box>
          ) : (
            <NoticeBox danger>
              Nie należysz do żadnej drużyny. Poproś XO o przydział.
            </NoticeBox>
          )}
        </Section>
        {!!data.already_loaned && (
          <Section
            title="Masz pobrany zestaw"
            buttons={
              <>
                <Button
                  color="average"
                  icon="undo"
                  tooltip="Oddaje sprzęt z rąk i z plecaka. Skrzynię możesz też po prostu włożyć do automatu."
                  onClick={() => act('return_gear')}
                >
                  Zwróć sprzęt
                </Button>
                <Button
                  color="bad"
                  icon="money-bill"
                  tooltip={`Grzywna za brakujące przedmioty: ${data.fine} kr`}
                  onClick={() => act('pay_fine')}
                >
                  Zapłać grzywnę
                </Button>
              </>
            }
          >
            {data.missing.length ? (
              <Box color="average">Do zwrotu: {data.missing.join(', ')}.</Box>
            ) : (
              <Box color="good">Wszystko oddane.</Box>
            )}
          </Section>
        )}
        {!!data.kit && (
          <Section
            title={data.kit.name}
            buttons={
              <Button
                icon="box"
                disabled={!!data.already_loaned}
                onClick={() => act('vend')}
              >
                Wydaj
              </Button>
            }
          >
            <Box mb={1}>{data.kit.desc}</Box>
            <Box color="label">W skrzyni:</Box>
            <Box>{data.kit.contents.join(', ')}.</Box>
            {!data.weapons_clearance && (
              <Box mt={1} color="average">
                Drużyna nie ma zezwolenia na broń, więc zestaw wychodzi bez
                broni i amunicji.
              </Box>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
