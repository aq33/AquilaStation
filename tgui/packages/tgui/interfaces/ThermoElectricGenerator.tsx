// Okno generatora termoelektrycznego z tg (code/modules/power/generator.dm).
import { Box, Divider, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  error_message: string | null;
  last_power_output: string | null;
  cold_data: CirculatorData[];
  hot_data: CirculatorData[];
};

type CirculatorData = {
  temperature_inlet: number | null;
  temperature_outlet: number | null;
  pressure_inlet: number | null;
  pressure_outlet: number | null;
};

export const ThermoElectricGenerator = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    error_message,
    last_power_output,
    cold_data = [],
    hot_data = [],
  } = data;
  if (error_message) {
    return (
      <Window width={320} height={100}>
        <Window.Content>
          <Section>BŁĄD: {error_message}</Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={360} height={200}>
      <Window.Content>
        <Section>
          <Box>
            <Box>Ostatnia moc: {last_power_output}</Box>
            <Divider />
            <Box m={1} textColor="cyan" bold>
              Obieg zimny
            </Box>
            {cold_data.map((data, index) => (
              <Box key={index}>
                <Box>
                  Temperatura wlotu: {data.temperature_inlet} K / wylotu:{' '}
                  {data.temperature_outlet} K
                </Box>
                <Box>
                  Ciśnienie wlotu: {data.pressure_inlet} kPa / wylotu:{' '}
                  {data.pressure_outlet} kPa
                </Box>
              </Box>
            ))}
          </Box>
          <Box>
            <Box m={1} textColor="red" bold>
              Obieg gorący
            </Box>
            {hot_data.map((data, index) => (
              <Box key={index}>
                <Box>
                  Temperatura wlotu: {data.temperature_inlet} K / wylotu:{' '}
                  {data.temperature_outlet} K
                </Box>
                <Box>
                  Ciśnienie wlotu: {data.pressure_inlet} kPa / wylotu:{' '}
                  {data.pressure_outlet} kPa
                </Box>
              </Box>
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
