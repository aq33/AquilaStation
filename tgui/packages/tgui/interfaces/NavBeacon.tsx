import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export type Data = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
  controls: NavBeaconControl;
  static_controls: NavBeaconStaticControl;
};

export type NavBeaconControl = {
  location: string;
  patrol_enabled: BooleanLike;
  patrol_next: string;
  delivery_enabled: BooleanLike;
  delivery_direction: string;
  cover_locked: BooleanLike;
};

export type DisabledProps = {
  disabled: BooleanLike;
};

export type NavBeaconStaticControl = {
  direction_options: string[];
  has_codes: BooleanLike;
};

// AQUILA EDIT - kierunki przychodzą z DM po angielsku (dir2text), tu tylko je
// wyświetlamy po polsku
const DIRECTION_NAMES: Record<string, string> = {
  none: 'brak',
  north: 'północ',
  south: 'południe',
  east: 'wschód',
  west: 'zachód',
};

const directionName = (direction?: string | null) =>
  (direction && DIRECTION_NAMES[direction]) || direction || 'brak';

export const NavBeacon = (props) => {
  return (
    <Window title="Radiolatarnia nawigacyjna" width={400} height={350}>
      <Window.Content>
        <NavBeaconContent />
      </Window.Content>
    </Window>
  );
};

export const NavBeaconContent = (props) => {
  const { data } = useBackend<Data>();
  const disabled = data.locked && !data.siliconUser;
  return (
    <Stack vertical fill>
      <InterfaceLockNoticeBox />
      <NavBeaconControlSection disabled={disabled} />
      <NavBeaconMaintenanceSection disabled={disabled} />
    </Stack>
  );
};

export const NavBeaconControlSection = (props: DisabledProps) => {
  const { act, data } = useBackend<Data>();
  const { controls, static_controls } = data;
  return (
    <Section title="Sterowanie">
      <LabeledList>
        <LabeledList.Item label="Lokalizacja">
          <Button
            fluid
            icon="pencil-alt"
            disabled={props.disabled}
            onClick={() => act('set_location')}
          >
            {controls.location ?? 'Nie ustawiono'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Punkt patrolowy">
          <Button.Checkbox
            fluid
            checked={controls.patrol_enabled}
            disabled={props.disabled}
            onClick={() => act('toggle_patrol')}
          >
            {controls.patrol_enabled ? 'Włączony' : 'Wyłączony'}
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item label="Następny punkt patrolu">
          <Button
            fluid
            icon="pencil-alt"
            disabled={props.disabled}
            onClick={() => act('set_patrol_next')}
          >
            {controls.patrol_next ?? 'Brak następnego punktu'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Punkt dostaw">
          <Button.Checkbox
            fluid
            checked={controls.delivery_enabled}
            disabled={props.disabled}
            onClick={() => act('toggle_delivery')}
          >
            {controls.delivery_enabled ? 'Włączony' : 'Wyłączony'}
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item label="Kierunek dostawy">
          <Dropdown
            disabled={!!props.disabled}
            options={static_controls.direction_options.map((direction) => ({
              displayText: directionName(direction),
              value: direction,
            }))}
            selected={controls.delivery_direction || 'none'}
            displayText={directionName(controls.delivery_direction)}
            onSelected={(value) =>
              act('set_delivery_direction', {
                direction: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const NavBeaconMaintenanceSection = (props: DisabledProps) => {
  const { act, data } = useBackend<Data>();
  const { controls, static_controls } = data;
  return (
    <Section title="Konserwacja">
      <LabeledList>
        <LabeledList.Item label="Reset kodów">
          {!!static_controls.has_codes && (
            <Button
              fluid
              icon="power-off"
              disabled={props.disabled}
              onClick={() => act('reset_codes')}
            >
              Resetuj
            </Button>
          )}
          {!static_controls.has_codes && <Box>Brak zapasowych kodów</Box>}
        </LabeledList.Item>
        <LabeledList.Item label="Pokrywa włazu serwisowego">
          <Button.Checkbox
            fluid
            checked={controls.cover_locked}
            disabled={props.disabled}
            onClick={() => act('toggle_cover')}
          >
            {controls.cover_locked ? 'Zablokowana' : 'Odblokowana'}
          </Button.Checkbox>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
