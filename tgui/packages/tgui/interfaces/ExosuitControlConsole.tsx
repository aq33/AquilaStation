import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Mech = {
  name: string;
  integrity: number;
  charge: number | null;
  airtank: number | null;
  pilot: string[];
  location: string | null;
  /** AQUILA: the equipment currently selected by the pilot */
  active_equipment: string | null;
  emp_recharging: BooleanLike;
  tracker_ref: string;
  cargo_space?: number;
};

type ExosuitControlConsoleData = {
  mechs: Mech[];
};

export const ExosuitControlConsole = (props) => {
  const { act, data } = useBackend<ExosuitControlConsoleData>();
  const { mechs = [] } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        {mechs.length === 0 && (
          <NoticeBox>Nie wykryto żadnych egzoszkieletów</NoticeBox>
        )}
        {mechs.map((mech) => (
          <Section
            key={mech.tracker_ref}
            title={mech.name}
            buttons={
              <>
                <Button
                  icon="envelope"
                  disabled={mech.pilot.length < 1}
                  onClick={() =>
                    act('send_message', {
                      tracker_ref: mech.tracker_ref,
                    })
                  }
                >
                  Wiadomość
                </Button>
                <Button
                  icon="wifi"
                  color="bad"
                  disabled={mech.emp_recharging}
                  onClick={() =>
                    act('shock', {
                      tracker_ref: mech.tracker_ref,
                    })
                  }
                >
                  {mech.emp_recharging ? 'Ładowanie...' : 'Impuls EMP'}
                </Button>
              </>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Integralność">
                <Box
                  color={
                    (mech.integrity <= 30 && 'bad') ||
                    (mech.integrity <= 70 && 'average') ||
                    'good'
                  }
                >
                  {mech.integrity}%
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Ładunek">
                {mech.charge !== null ? (
                  <Box
                    color={
                      (mech.charge <= 30 && 'bad') ||
                      (mech.charge <= 70 && 'average') ||
                      'good'
                    }
                  >
                    {mech.charge}%
                  </Box>
                ) : (
                  <Box>Nie znaleziono</Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Zbiornik powietrza">
                {mech.airtank !== null ? (
                  <AnimatedNumber
                    value={mech.airtank}
                    format={(value) => `${toFixed(value, 2)} kPa`}
                  />
                ) : (
                  'Brak'
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Pilot">
                {mech.pilot.length > 0
                  ? mech.pilot.map((pilot) => (
                      <Box key={pilot} inline>
                        {pilot}
                        {mech.pilot.length > 1 ? '|' : ''}
                      </Box>
                    ))
                  : 'Brak'}
              </LabeledList.Item>
              <LabeledList.Item label="Położenie">
                {mech.location || 'Nieznane'}
              </LabeledList.Item>
              <LabeledList.Item label="Aktywne wyposażenie">
                {mech.active_equipment || 'Brak'}
              </LabeledList.Item>
              {mech.cargo_space !== undefined && (
                <LabeledList.Item label="Zajęta ładownia">
                  <Box
                    color={
                      (mech.cargo_space <= 30 && 'good') ||
                      (mech.cargo_space <= 70 && 'average') ||
                      'bad'
                    }
                  >
                    {mech.cargo_space}%
                  </Box>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
