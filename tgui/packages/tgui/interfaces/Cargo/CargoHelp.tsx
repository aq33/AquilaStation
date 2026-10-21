import { Box, NoticeBox, Section, Stack } from 'tgui-core/components';

const DISPOSAL_TEXT = `Oprócz MULEbotów i doręczania osobiście możesz korzystać
        z poczty rurowej. Pamiętaj, że przerwana rura może sprawić, że paczka
        przepadnie (zdarza się to rzadko), więc nie zawsze jest to najpewniejszy
        sposób dostawy. W ten sam sposób możesz zapakować i wysłać kartkę
        papieru, jeśli ktoś chce nadać list.`;

export function CargoHelp(props) {
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable>
          <Section title="MULEboty">
            <Box color="label">
              MULEboty to powolne, ale wierne roboty dostawcze, które dowiozą
              skrzynie przy minimalnym wysiłku. Są jednak wolne i ktoś może przy
              nich majstrować po drodze.
            </Box>
            <br />
            <Box bold color="green">
              Uruchomienie MULEbota jest proste:
            </Box>
            <b>1.</b> Przeciągnij skrzynię obok MULEbota.
            <br />
            <b>2.</b> Przeciągnij skrzynię na MULEbota. Powinien ją załadować.
            <br />
            <b>3.</b> Otwórz PDA.
            <br />
            <b>4.</b> Wybierz <i>Delivery Bot Control</i>.<br />
            <b>5.</b> Kliknij <i>Scan for Active Bots</i>.<br />
            <b>6.</b> Wybierz swojego MULE.
            <br />
            <b>7.</b> Kliknij <i>Destination: (set)</i>.<br />
            <b>8.</b> Wybierz cel i zatwierdź.
            <br />
            <b>9.</b> Kliknij <i>Proceed</i>.
          </Section>
          <Section title="Poczta rurowa">
            <Box color="label">{DISPOSAL_TEXT}</Box>
            <br />
            <Box bold color="green">
              Wysyłka pocztą rurową jest jeszcze prostsza:
            </Box>
            <b>1.</b> Zapakuj przedmiot lub skrzynię w papier pakowy.
            <br />
            <b>2.</b> Ustaw cel na metkownicy.
            <br />
            <b>3.</b> Oznacz paczkę.
            <br />
            <b>4.</b> Połóż ją na taśmociągu, system zajmie się resztą.
            <br />
          </Section>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <NoticeBox textAlign="center" info mb={0}>
          Czegoś tu brakuje? W razie wątpliwości pytaj kwatermistrza!
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
}
