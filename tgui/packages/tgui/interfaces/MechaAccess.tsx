// AQUILA - okno dostępu i protokołów serwisowych mecha dla osoby z kartą ID
// (code/game/mecha/mecha_topic.dm, /datum/mecha_access_panel). Zastępuje dwa
// stare okna HTML: "exosuit_maint_console" i "exosuit_add_access".
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Access = {
  id: number;
  desc: string;
};

type Data = {
  editing_access: BooleanLike;
  add_req_access: BooleanLike;
  maint_access: BooleanLike;
  maint_active: BooleanLike;
  hatch_open: BooleanLike;
  has_cell: BooleanLike;
  has_scanmod: BooleanLike;
  has_capacitor: BooleanLike;
  internal_tank_valve: number;
  stored_access?: Access[];
  card_access?: Access[];
};

export const MechaAccess = (props) => {
  const { data } = useBackend<Data>();
  return (
    <Window width={420} height={460}>
      <Window.Content scrollable>
        {data.editing_access ? <AccessEditor /> : <Maintenance />}
      </Window.Content>
    </Window>
  );
};

const Maintenance = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    add_req_access,
    maint_access,
    maint_active,
    hatch_open,
    has_cell,
    has_scanmod,
    has_capacitor,
    internal_tank_valve,
  } = data;
  return (
    <>
      <Section title="Konsola serwisowa">
        {!add_req_access && !maint_access && (
          <NoticeBox>Operator wyłączył dostęp z zewnątrz.</NoticeBox>
        )}
        <Stack vertical>
          {!!add_req_access && (
            <Stack.Item>
              <Button fluid icon="id-card" onClick={() => act('req_access')}>
                Edytuj kody dostępu
              </Button>
            </Stack.Item>
          )}
          {!!maint_access && (
            <Stack.Item>
              <Button
                fluid
                icon="wrench"
                selected={!!maint_active}
                onClick={() => act('maint_access')}
              >
                {maint_active
                  ? 'Zakończ protokół serwisowy'
                  : 'Rozpocznij protokół serwisowy'}
              </Button>
            </Stack.Item>
          )}
        </Stack>
      </Section>
      {!!hatch_open && (
        <Section title="Podzespoły">
          <LabeledList>
            <LabeledList.Item label="Ogniwo zasilające">
              {has_cell ? (
                <Button icon="eject" onClick={() => act('drop_cell')}>
                  Wyjmij
                </Button>
              ) : (
                <Box color="label">Brak</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Moduł skanujący">
              {has_scanmod ? (
                <Button icon="eject" onClick={() => act('drop_scanmod')}>
                  Wyjmij
                </Button>
              ) : (
                <Box color="label">Brak</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Kondensator">
              {has_capacitor ? (
                <Button icon="eject" onClick={() => act('drop_cap')}>
                  Wyjmij
                </Button>
              ) : (
                <Box color="label">Brak</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      {!!maint_active && (
        <Section title="Kabina">
          <LabeledList>
            <LabeledList.Item label="Ciśnienie powietrza w kabinie">
              <NumberInput
                value={internal_tank_valve}
                minValue={0}
                maxValue={10000}
                step={10}
                unit="kPa"
                width="90px"
                onChange={(value) =>
                  act('set_internal_tank_valve', { pressure: value })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </>
  );
};

const AccessEditor = (props) => {
  const { act, data } = useBackend<Data>();
  const stored_access = data.stored_access || [];
  const card_access = data.card_access || [];
  return (
    <>
      <Section
        title="Kody dostępu w systemie"
        buttons={
          <Button icon="arrow-left" onClick={() => act('back')}>
            Wstecz
          </Button>
        }
      >
        {stored_access.length === 0 ? (
          <NoticeBox>
            Brak kodów – egzoszkielet jest dostępny dla każdego.
          </NoticeBox>
        ) : (
          <Table>
            {stored_access.map((access) => (
              <Table.Row key={access.id} className="candystripe">
                <Table.Cell>{access.desc}</Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    icon="trash"
                    color="bad"
                    onClick={() => act('del_req_access', { access: access.id })}
                  >
                    Usuń
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
      <Section title="Kody wykryte na karcie">
        {card_access.length === 0 ? (
          <NoticeBox>Brak nowych kodów na karcie.</NoticeBox>
        ) : (
          <Table>
            {card_access.map((access) => (
              <Table.Row key={access.id} className="candystripe">
                <Table.Cell>{access.desc}</Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    icon="plus"
                    onClick={() => act('add_req_access', { access: access.id })}
                  >
                    Dodaj
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
      <Section>
        <Button.Confirm
          fluid
          icon="lock"
          color="bad"
          confirmContent="Na pewno? Odblokować można tylko z kabiny."
          onClick={() => act('finish_req_access')}
        >
          Zablokuj panel wgrywania ID
        </Button.Confirm>
        <Box mt={1} color="bad">
          Uwaga! Panel wgrywania ID można odblokować tylko przez interfejs
          egzoszkieletu.
        </Box>
      </Section>
    </>
  );
};
