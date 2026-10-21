import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  previous_attempts: Attempts[];
  attempts_left: number;
};

type Attempts = {
  attempt: string;
  bulls: number;
  cows: number;
};

const check_attempts = (attempts_to_check: number) => {
  return attempts_to_check === 1
    ? 'przy następnej nieudanej próbie.'
    : `po ${attempts_to_check} nieudanych próbach.`;
};

const BULLS_COWS_INFO = `Kod składa się z niepowtarzających się cyfr.
Każda błędna próba pokazuje liczbę dobrych cyfr na dobrych pozycjach
oraz liczbę dobrych cyfr na złych pozycjach.`;

export const AbandonedCrate = (props) => {
  const { data } = useBackend<Data>();
  const { previous_attempts, attempts_left } = data;

  return (
    <Window width={335} height={180 + previous_attempts.length * 19}>
      <Window.Content scrollable>
        <Section
          title="Zamek Deca-code"
          buttons={
            <Button
              tooltip={BULLS_COWS_INFO}
              icon="info"
              tooltipPosition="top"
            />
          }
        >
          <NoticeBox color="bad">
            Bomba przeciwwłamaniowa uruchomi się {check_attempts(attempts_left)}
          </NoticeBox>
          <Table>
            {!!previous_attempts.length && (
              <Table.Row fontSize="125%" bold>
                <Table.Cell
                  collapsing
                  color="white"
                  textAlign="center"
                  pr="5px"
                >
                  Próba
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Button
                    tooltip="Dobre cyfry na dobrych pozycjach"
                    icon="check"
                    color="green"
                  />
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Button
                    tooltip="Dobre cyfry na złych pozycjach"
                    icon="asterisk"
                    color="yellow"
                  />
                </Table.Cell>
              </Table.Row>
            )}
            {previous_attempts.map((previous_attempt, index) => (
              <Table.Row key={index} style={{ borderTop: '2px solid #222' }}>
                <Table.Cell collapsing textAlign="center" pr="5px">
                  <Box color="white" inline fontSize="125%">
                    {previous_attempt.attempt}
                  </Box>
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Box color="green" inline fontSize="125%">
                    {previous_attempt.bulls}
                  </Box>
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Box color="yellow" inline fontSize="125%">
                    {previous_attempt.cows}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
