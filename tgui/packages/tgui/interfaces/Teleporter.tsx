import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  calibrated: BooleanLike;
  calibrating: BooleanLike;
  power_station: BooleanLike;
  regime_set: string;
  teleporter_hub: BooleanLike;
  target: string;
};

export const Teleporter = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    calibrated,
    calibrating,
    power_station,
    regime_set,
    teleporter_hub,
    target,
  } = data;
  return (
    <Window width={360} height={130}>
      <Window.Content>
        <Section>
          {(!power_station && (
            <Box color="bad" textAlign="center">
              Brak podłączonej stacji zasilającej.
            </Box>
          )) ||
            (!teleporter_hub && (
              <Box color="bad" textAlign="center">
                Brak podłączonego węzła teleportera.
              </Box>
            )) || (
              <LabeledList>
                <LabeledList.Item label="Tryb">
                  <Button tooltip="Zmień tryb" onClick={() => act('regimeset')}>
                    {regime_set}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Cel">
                  <Button icon="edit" onClick={() => act('settarget')}>
                    {target}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item
                  label="Kalibracja"
                  buttons={
                    <Button icon="tools" onClick={() => act('calibrate')}>
                      Kalibruj
                    </Button>
                  }
                >
                  {(calibrating && <Box color="average">W toku</Box>) ||
                    (calibrated && <Box color="good">Optymalna</Box>) || (
                      <Box color="bad">Nieoptymalna</Box>
                    )}
                </LabeledList.Item>
              </LabeledList>
            )}
        </Section>
      </Window.Content>
    </Window>
  );
};
