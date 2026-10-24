import { Box, NoticeBox, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  servers: ServerData[];
  cores: CoreData[];
  temp_limit: number;
  has_network: BooleanLike;
};

type ServerData = {
  area: string;
  working: BooleanLike;
  total_cpu: number;
  ram: number;
  card_capacity: string;
  temp: number;
};

type CoreData = {
  area: string;
  working: BooleanLike;
  temp: number;
  battery: number | null;
  ais: string | null;
};

const KELVIN_OFFSET = 273.15;

const Temperature = (props: { temp: number; limit: number }) => {
  const { temp, limit } = props;
  const celsius = Math.round((temp - KELVIN_OFFSET) * 10) / 10;
  return (
    <Box color={temp > limit ? 'bad' : temp > limit * 0.9 ? 'average' : 'good'}>
      {temp} K ({celsius} °C)
    </Box>
  );
};

const Status = (props: { working: BooleanLike }) => (
  <Box bold color={props.working ? 'good' : 'bad'}>
    {props.working ? 'DZIAŁA' : 'OFFLINE'}
  </Box>
);

export const AiServerConsole = (props) => {
  const { data } = useBackend<Data>();
  const { servers = [], cores = [], temp_limit, has_network } = data;

  return (
    <Window width={650} height={500} title="Przegląd serwerów SI">
      <Window.Content scrollable>
        {!has_network && (
          <NoticeBox danger>
            Brak połączenia z siecią SI. Konsola musi stać na kablu sieciowym.
          </NoticeBox>
        )}
        <NoticeBox info>
          Limit temperatury: {temp_limit} K (
          {Math.round((temp_limit - KELVIN_OFFSET) * 10) / 10} °C)
        </NoticeBox>
        <Section title="Szafy serwerowe">
          {servers.length === 0 ? (
            <Box color="label">Brak podłączonych szaf serwerowych.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Lokalizacja</Table.Cell>
                <Table.Cell>Stan</Table.Cell>
                <Table.Cell>Temperatura</Table.Cell>
                <Table.Cell>Karty</Table.Cell>
                <Table.Cell>CPU</Table.Cell>
                <Table.Cell>RAM</Table.Cell>
              </Table.Row>
              {servers.map((server, index) => (
                <Table.Row key={index} className="candystripe">
                  <Table.Cell>{server.area}</Table.Cell>
                  <Table.Cell>
                    <Status working={server.working} />
                  </Table.Cell>
                  <Table.Cell>
                    <Temperature temp={server.temp} limit={temp_limit} />
                  </Table.Cell>
                  <Table.Cell>{server.card_capacity}</Table.Cell>
                  <Table.Cell>{server.total_cpu} THz</Table.Cell>
                  <Table.Cell>{server.ram} TB</Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section title="Rdzenie danych">
          {cores.length === 0 ? (
            <Box color="label">Brak rdzeni danych.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Lokalizacja</Table.Cell>
                <Table.Cell>Stan</Table.Cell>
                <Table.Cell>Temperatura</Table.Cell>
                <Table.Cell>Bateria</Table.Cell>
                <Table.Cell>SI</Table.Cell>
              </Table.Row>
              {cores.map((core, index) => (
                <Table.Row key={index} className="candystripe">
                  <Table.Cell>{core.area}</Table.Cell>
                  <Table.Cell>
                    <Status working={core.working} />
                  </Table.Cell>
                  <Table.Cell>
                    <Temperature temp={core.temp} limit={temp_limit} />
                  </Table.Cell>
                  <Table.Cell>
                    {core.battery === null ? (
                      <Box color="label">brak</Box>
                    ) : (
                      <Box
                        color={
                          core.battery > 50
                            ? 'good'
                            : core.battery > 20
                              ? 'average'
                              : 'bad'
                        }
                      >
                        {core.battery}%
                      </Box>
                    )}
                  </Table.Cell>
                  <Table.Cell>
                    {core.ais || <Box color="label">brak</Box>}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
