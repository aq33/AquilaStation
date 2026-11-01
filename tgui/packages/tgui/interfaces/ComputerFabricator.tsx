import { multiline } from 'common/string';
import { Box, Button, Section, Table, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

type Data = {
  credits: any;
  devtype: any;
  hw_battery: any;
  hw_card: any;
  hw_cpu: any;
  hw_disk: any;
  hw_nanoprint: any;
  hw_netcard: any;
  hw_tesla: any;
  state: any;
  totalprice: any;
};

export const ComputerFabricator = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={500} height={400}>
      <Window.Content>
        <Section italic fontSize="20px">
          Twoje idealne urządzenie jest tylko trzy kroki stąd...
        </Section>
        {data.state !== 0 && (
          <Button
            fluid
            mb={1}
            icon="circle"
            content="Wyczyść zamówienie"
            onClick={() => act('clean_order')}
          />
        )}
        {data.state === 0 && <CfStep1 />}
        {data.state === 1 && <CfStep2 />}
        {data.state === 2 && <CfStep3 />}
        {data.state === 3 && <CfStep4 />}
      </Window.Content>
    </Window>
  );
};

// This had a pretty gross backend so this was unfortunately one of the
// best ways of doing it.
const CfStep1 = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section title="Krok 1" minHeight="306px">
      <Box mt={5} bold textAlign="center" fontSize="40px">
        Wybierz urządzenie
      </Box>
      <Box mt={3}>
        <Grid width="100%">
          <Grid.Column>
            <Button
              fluid
              icon="laptop"
              content="Laptop"
              textAlign="center"
              fontSize="30px"
              lineHeight="50px"
              onClick={() =>
                act('pick_device', {
                  pick: '1',
                })
              }
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              icon="tablet-alt"
              content="Tablet"
              textAlign="center"
              fontSize="30px"
              lineHeight="50px"
              onClick={() =>
                act('pick_device', {
                  pick: '2',
                })
              }
            />
          </Grid.Column>
        </Grid>
      </Box>
    </Section>
  );
};

const CfStep2 = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section
      title="Krok 2: dostosuj urządzenie"
      minHeight="282px"
      buttons={
        <Box bold color="good">
          {data.totalprice} kr.
        </Box>
      }
    >
      <Table>
        <Table.Row>
          <Table.Cell bold position="relative">
            <Tooltip
              content={multiline`
                Pozwala urządzeniu działać bez zewnętrznego źródła zasilania.
                Lepsze baterie dłużej wytrzymują.
              `}
              position="right"
            >
              Bateria:
            </Tooltip>
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_battery === 1}
              onClick={() =>
                act('hw_battery', {
                  battery: '1',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Ulepszona wersja"
              selected={data.hw_battery === 2}
              onClick={() =>
                act('hw_battery', {
                  battery: '2',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Wersja zaawansowana"
              selected={data.hw_battery === 3}
              onClick={() =>
                act('hw_battery', {
                  battery: '3',
                })
              }
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            <Tooltip
              content={multiline`
                Przechowuje pliki na urządzeniu. Lepsze dyski mieszczą więcej
                plików, ale zużywają więcej energii i skracają czas pracy baterii.
              `}
              position="right"
            >
              Dysk twardy:
            </Tooltip>
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_disk === 1}
              onClick={() =>
                act('hw_disk', {
                  disk: '1',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Ulepszona wersja"
              selected={data.hw_disk === 2}
              onClick={() =>
                act('hw_disk', {
                  disk: '2',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Wersja zaawansowana"
              selected={data.hw_disk === 3}
              onClick={() =>
                act('hw_disk', {
                  disk: '3',
                })
              }
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            <Tooltip
              content={multiline`
                Pozwala urządzeniu łączyć się bezprzewodowo z siecią NTNet na
                stacji. Podstawowe karty działają tylko na stacji, a zaawansowane
                wszędzie w pobliżu stacji, także na placówkach na asteroidach.
              `}
              position="right"
            >
              Karta sieciowa:
            </Tooltip>
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Brak"
              selected={data.hw_netcard === 0}
              onClick={() =>
                act('hw_netcard', {
                  netcard: '0',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_netcard === 1}
              onClick={() =>
                act('hw_netcard', {
                  netcard: '1',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Wersja zaawansowana"
              selected={data.hw_netcard === 2}
              onClick={() =>
                act('hw_netcard', {
                  netcard: '2',
                })
              }
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            <Tooltip
              content={multiline`
                Urządzenie do pracy z dokumentami, na przykład skanowania
                albo drukowania nowych. Ma certyfikat EcoFriendlyPlus i potrafi
                przetwarzać zużyty papier do ponownego druku.
              `}
              position="right"
            >
              Nanodrukarka:
            </Tooltip>
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Brak"
              selected={data.hw_nanoprint === 0}
              onClick={() =>
                act('hw_nanoprint', {
                  print: '0',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_nanoprint === 1}
              onClick={() =>
                act('hw_nanoprint', {
                  print: '1',
                })
              }
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold position="relative">
            Dodatkowy czytnik kart:
            <Tooltip
              content={multiline`
                Dodaje drugi czytnik RFID do odczytu i zmiany drugiej
                standardowej karty RFID.
                Pamiętaj, że główny czytnik jest potrzebny, żeby urządzenie
                odczytało twój identyfikator, ale jest on wliczony w cenę
                podstawową.
              `}
              position="right"
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Brak"
              selected={data.hw_card === 0}
              onClick={() =>
                act('hw_card', {
                  card: '0',
                })
              }
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Standard"
              selected={data.hw_card === 1}
              onClick={() =>
                act('hw_card', {
                  card: '1',
                })
              }
            />
          </Table.Cell>
        </Table.Row>
        {data.devtype !== 2 && (
          <>
            <Table.Row>
              <Table.Cell bold position="relative">
                <Tooltip
                  content={multiline`
                    Kluczowy podzespół urządzenia. Pozwala uruchamiać
                    programy z dysku twardego. Lepsze procesory zużywają
                    więcej energii, ale pozwalają uruchomić więcej programów
                    naraz w tle.
                  `}
                  position="right"
                >
                  Procesor:
                </Tooltip>
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Standard"
                  selected={data.hw_cpu === 1}
                  onClick={() =>
                    act('hw_cpu', {
                      cpu: '1',
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Wersja zaawansowana"
                  selected={data.hw_cpu === 2}
                  onClick={() =>
                    act('hw_cpu', {
                      cpu: '2',
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold position="relative">
                <Tooltip
                  content={multiline`
                    Zaawansowany bezprzewodowy przekaźnik energii, który łączy
                    urządzenie z pobliskim APC jako alternatywnym źródłem
                    zasilania. Ze względu na rozmiar ten podzespół jest
                    niedostępny w tabletach.
                  `}
                  position="right"
                >
                  Przekaźnik Tesli:
                </Tooltip>
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Brak"
                  selected={data.hw_tesla === 0}
                  onClick={() =>
                    act('hw_tesla', {
                      tesla: '0',
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Standard"
                  selected={data.hw_tesla === 1}
                  onClick={() =>
                    act('hw_tesla', {
                      tesla: '1',
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          </>
        )}
      </Table>
      <Button
        fluid
        mt={3}
        content="Potwierdź zamówienie"
        color="good"
        textAlign="center"
        fontSize="18px"
        lineHeight="26px"
        onClick={() => act('confirm_order')}
      />
    </Section>
  );
};

const CfStep3 = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section title="Krok 3: płatność" minHeight="282px">
      <Box italic textAlign="center" fontSize="20px">
        Urządzenie jest gotowe do wytworzenia...
      </Box>
      <Box bold mt={2} textAlign="center" fontSize="16px">
        <Box inline>Włóż wymaganą kwotę:</Box>{' '}
        <Box inline color="good">
          {data.totalprice} kr.
        </Box>
      </Box>
      <Box bold mt={1} textAlign="center" fontSize="18px">
        Obecnie:
      </Box>
      <Box
        bold
        mt={0.5}
        textAlign="center"
        fontSize="18px"
        color={data.credits >= data.totalprice ? 'good' : 'bad'}
      >
        {data.credits} kr.
      </Box>
      <Button
        fluid
        content="Kup"
        disabled={data.credits < data.totalprice}
        mt={8}
        color="good"
        textAlign="center"
        fontSize="20px"
        lineHeight="28px"
        onClick={() => act('purchase')}
      />
    </Section>
  );
};

const CfStep4 = (props) => {
  return (
    <Section minHeight="282px">
      <Box bold textAlign="center" fontSize="28px" mt={10}>
        Dziękujemy za zakup!
      </Box>
      <Box italic mt={1} textAlign="center">
        Jeśli masz problemy z nowym urządzeniem, skontaktuj się z lokalnym
        administratorem sieci.
      </Box>
    </Section>
  );
};
