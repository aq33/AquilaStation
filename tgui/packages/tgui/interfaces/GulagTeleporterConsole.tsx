import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  teleporter: BooleanLike;
  teleporter_lock: BooleanLike;
  teleporter_state_open: BooleanLike;
  teleporter_location: string;
  beacon: BooleanLike;
  beacon_location: string;
  id: BooleanLike;
  id_name: string;
  can_teleport: BooleanLike;
  goal: number;
  prisoner: { name?: string; crimstat?: string };
  /** AQUILA: dożywotni wyrok */
  permanent: BooleanLike;
};

export const GulagTeleporterConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    teleporter,
    teleporter_lock,
    teleporter_state_open,
    teleporter_location,
    beacon,
    beacon_location,
    id,
    id_name,
    can_teleport,
    goal = 0,
    prisoner = {},
    permanent,
  } = data;

  return (
    <Window width={350} height={295}>
      <Window.Content>
        <Section
          title="Konsola teleportera"
          buttons={
            <>
              <Button
                disabled={teleporter_lock}
                selected={teleporter_state_open}
                onClick={() => act('toggle_open')}
              >
                {teleporter_state_open ? 'Otwarty' : 'Zamknięty'}
              </Button>
              <Button
                icon={teleporter_lock ? 'lock' : 'unlock'}
                selected={teleporter_lock}
                disabled={teleporter_state_open}
                onClick={() => act('teleporter_lock')}
              >
                {teleporter_lock ? 'Zablokowany' : 'Odblokowany'}
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Teleporter"
              color={teleporter ? 'good' : 'bad'}
              buttons={
                !teleporter && (
                  <Button onClick={() => act('scan_teleporter')}>
                    Połącz ponownie
                  </Button>
                )
              }
            >
              {teleporter ? teleporter_location : 'Brak połączenia'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Nadajnik docelowy"
              color={beacon ? 'good' : 'bad'}
              buttons={
                !beacon && (
                  <Button onClick={() => act('scan_beacon')}>
                    Połącz ponownie
                  </Button>
                )
              }
            >
              {beacon ? beacon_location : 'Brak połączenia'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Dane więźnia">
          <LabeledList>
            <LabeledList.Item label="Identyfikator">
              <Button fluid onClick={() => act('handle_id')}>
                {id ? id_name : 'Brak karty'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Limit punktów">
              <NumberInput
                value={goal}
                step={1}
                width="48px"
                minValue={1}
                maxValue={1000}
                onChange={(value) => act('set_goal', { value })}
              />
              <Button.Checkbox
                checked={permanent}
                onClick={() => act('set_permanent')}
              >
                Dożywocie
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label="W komorze">
              {prisoner.name || 'Pusto'}
            </LabeledList.Item>
            <LabeledList.Item label="Status karny">
              {prisoner.crimstat || 'Brak statusu'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Button
          fluid
          disabled={!can_teleport}
          textAlign="center"
          color="bad"
          onClick={() => act('teleport')}
        >
          Wyślij więźnia
        </Button>
      </Window.Content>
    </Window>
  );
};
