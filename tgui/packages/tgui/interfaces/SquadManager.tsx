// NSV13
// AQUILA: konsola drużyn XO po reworku: cztery kolumny drużyn, przydział załogi,
// stan i sprzęt członków, rozkazy, mapa taktyczna ze znacznikami, kamera pancerza.

import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Dropdown,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type MapData,
  MarkerPicker,
  type MarkerType,
  POSITION_ICONS,
  type SquadInfo,
  type SquadMember,
  SquadTacticalMap,
  STATUS_COLORS,
} from './common/SquadTacticalMap';

type Crew = { ref: string; name: string; job: string };

type Loan = {
  name: string;
  squad: string | null;
  kit: string;
  missing: string[];
  minutes: number;
  lost: BooleanLike;
  ref: string;
  reported: BooleanLike;
};

type Position = { id: string; name: string };

export type SquadConsoleData = {
  squads: SquadInfo[];
  unassigned: Crew[];
  loans: Loan[];
  positions: Position[];
  marker_types: MarkerType[];
  map: MapData;
  has_camera: BooleanLike;
  camera_target: { ref: string; name: string; active: BooleanLike } | null;
  map_ref: string | null;
  order_cooldown: number;
};

export const SquadManager = () => {
  return (
    <Window theme="ntos" width={1360} height={860}>
      <Window.Content>
        <SquadConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const SquadConsoleContent = () => {
  const { data } = useBackend<SquadConsoleData>();
  const [tab, setTab] = useState(1);
  const missingCount = data.loans.filter((loan) => loan.missing.length).length;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab icon="users" selected={tab === 1} onClick={() => setTab(1)}>
            Drużyny
          </Tabs.Tab>
          <Tabs.Tab icon="map" selected={tab === 2} onClick={() => setTab(2)}>
            Mapa taktyczna
          </Tabs.Tab>
          <Tabs.Tab
            icon="box-open"
            selected={tab === 3}
            onClick={() => setTab(3)}
          >
            Sprzęt ({missingCount})
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {tab === 1 && <SquadsTab />}
        {tab === 2 && <MapTab />}
        {tab === 3 && <LoansTab />}
      </Stack.Item>
    </Stack>
  );
};

const SquadsTab = () => {
  const { act, data } = useBackend<SquadConsoleData>();
  return (
    <Stack vertical fill>
      <Stack.Item>
        <UnassignedCrew />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="plus"
          tooltip="Nowa drużyna z własną nazwą i kolorem"
          onClick={() => act('aq_create_squad')}
        >
          Nowa drużyna
        </Button>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {/* przy więcej niż czterech drużynach kolumny się przewijają w poziomie */}
        <div
          style={{
            display: 'flex',
            height: '100%',
            overflowX: 'auto',
            gap: '6px',
          }}
        >
          {data.squads.map((squad) => (
            <div
              key={squad.id}
              style={{ flex: '1 0 310px', minWidth: '310px', height: '100%' }}
            >
              <SquadColumn squad={squad} />
            </div>
          ))}
        </div>
      </Stack.Item>
      {!!data.has_camera && !!data.camera_target && (
        <Stack.Item height="300px">
          <BodycamView />
        </Stack.Item>
      )}
    </Stack>
  );
};

const UnassignedCrew = () => {
  const { act, data } = useBackend<SquadConsoleData>();
  if (!data.unassigned.length) {
    return (
      <Section title="Bez drużyny">
        <Box color="label">Cała załoga ma przydział.</Box>
      </Section>
    );
  }
  return (
    <Section title={`Bez drużyny (${data.unassigned.length})`}>
      <Box style={{ maxHeight: '110px', overflowY: 'auto' }}>
        <Stack wrap="wrap">
          {data.unassigned.map((crew) => (
            <Stack.Item key={crew.ref} mb={0.5}>
              <Box
                inline
                px={1}
                style={{ border: '1px solid #2a4a2a', borderRadius: '2px' }}
              >
                {crew.name}{' '}
                <Box inline color="label">
                  ({crew.job})
                </Box>{' '}
                {data.squads.map((squad) => (
                  <Button
                    key={squad.id}
                    compact
                    style={{ background: squad.colour }}
                    tooltip={`Przydziel do drużyny ${squad.name}`}
                    onClick={() =>
                      act('assign', { ref: crew.ref, squad_id: squad.id })
                    }
                  >
                    {squad.name.charAt(0)}
                  </Button>
                ))}
              </Box>
            </Stack.Item>
          ))}
        </Stack>
      </Box>
    </Section>
  );
};

const SquadColumn = (props: { squad: SquadInfo }) => {
  const { act, data } = useBackend<SquadConsoleData>();
  const { squad } = props;
  return (
    <Section
      fill
      scrollable
      title={
        <Box inline color={squad.colour}>
          <Icon name="shield-alt" /> {squad.name} ({squad.members.length})
        </Box>
      }
      buttons={
        <>
          <Button
            icon="pen"
            tooltip="Zmień nazwę drużyny"
            onClick={() => act('aq_rename_squad', { squad_id: squad.id })}
          />
          <Button
            icon="palette"
            tooltip="Zmień kolor drużyny"
            onClick={() => act('aq_recolour_squad', { squad_id: squad.id })}
          />
          <Button.Confirm
            icon="trash"
            color="bad"
            tooltip="Rozwiąż drużynę: członkowie zostają bez drużyny"
            confirmContent="Rozwiązać?"
            onClick={() => act('aq_delete_squad', { squad_id: squad.id })}
          />
          <Button
            icon="bullhorn"
            tooltip="Rozkaz na ekran drużyny, z twoim portretem i głosem"
            disabled={data.order_cooldown > 0}
            onClick={() => act('order', { squad_id: squad.id })}
          >
            {data.order_cooldown > 0 ? `${data.order_cooldown} s` : 'Rozkaz'}
          </Button>
        </>
      }
    >
      <Box mb={1}>
        <Button
          fluid
          icon="bullseye"
          tooltip="Zadanie drużyny: zmienia dostęp i cel główny"
          onClick={() => act('retask', { squad_id: squad.id })}
        >
          {squad.role_name}
        </Button>
        <Button
          fluid
          icon="dot-circle"
          color={squad.secondary_objective ? 'good' : 'transparent'}
          tooltip="Cel dodatkowy"
          onClick={() => act('aq_secondary_objective', { squad_id: squad.id })}
        >
          {squad.secondary_objective || 'Brak celu dodatkowego'}
        </Button>
      </Box>
      <Stack wrap="wrap" mb={1}>
        <Stack.Item>
          <Button
            icon="id-card"
            color={squad.access_enabled ? 'good' : 'average'}
            tooltip="Rozszerzony dostęp drużyny (zależy od zadania)"
            onClick={() => act('aq_toggle_access', { squad_id: squad.id })}
          >
            {squad.access_enabled ? 'Dostęp' : 'Bez dostępu'}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={squad.weapons_clearance ? 'fist-raised' : 'peace'}
            color={squad.weapons_clearance ? 'bad' : 'good'}
            tooltip="Czy automaty drużyny wydają broń"
            onClick={() => act('aq_toggle_beararms', { squad_id: squad.id })}
          >
            {squad.weapons_clearance ? 'Broń' : 'Bez broni'}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="shield-alt"
            color={squad.heavy_armor ? 'average' : 'good'}
            tooltip="Jaki pancerz automat wydaje drużynie: ciężki chroni lepiej, ale spowalnia"
            onClick={() => act('aq_toggle_heavy_armor', { squad_id: squad.id })}
          >
            {squad.heavy_armor ? 'Pancerz ciężki' : 'Pancerz lekki'}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={squad.hidden ? 'eye-slash' : 'eye'}
            color={squad.hidden ? 'bad' : 'good'}
            tooltip="Czy nowa załoga trafia tu automatycznie"
            onClick={() => act('aq_toggle_hidden', { squad_id: squad.id })}
          >
            {squad.hidden ? 'Bez przydziału' : 'Przydział'}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="print"
            tooltip="Smycz, którą ktoś spoza drużyny klika w ręce, żeby dołączyć"
            onClick={() => act('aq_print_pass', { squad_id: squad.id })}
          >
            Smycz
          </Button>
        </Stack.Item>
      </Stack>
      {!squad.members.length && <Box color="label">Brak członków.</Box>}
      {squad.members.map((member) => (
        <MemberCard key={member.ref} squad={squad} member={member} />
      ))}
    </Section>
  );
};

const MemberCard = (props: { squad: SquadInfo; member: SquadMember }) => {
  const { act, data } = useBackend<SquadConsoleData>();
  const { squad, member } = props;
  const others = data.squads.filter((other) => other.id !== squad.id);
  return (
    <Box
      mb={0.5}
      p={0.5}
      style={{
        borderLeft: `3px solid ${squad.colour}`,
        background: 'rgba(0, 0, 0, 0.25)',
      }}
    >
      <Stack align="center">
        <Stack.Item>
          <Icon
            name={POSITION_ICONS[member.position] || 'user'}
            color={member.leader ? 'yellow' : 'white'}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold>{member.name}</Box>
          <Box color="label" fontSize="11px">
            {member.position_name}
            {member.job ? `, ${member.job}` : ''}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box color={STATUS_COLORS[member.status]} textAlign="right">
            {member.status_name}
          </Box>
          <Box color="label" fontSize="11px" textAlign="right">
            {member.area || '?'}
          </Box>
        </Stack.Item>
      </Stack>
      <Box fontSize="11px" mt={0.5}>
        {member.kit ? (
          <Box color={member.missing.length ? 'average' : 'good'}>
            <Icon name="box" /> {member.kit}
            {member.missing.length
              ? `, nie oddał: ${member.missing.length}`
              : ''}
          </Box>
        ) : (
          <Box color="label">
            <Icon name="box-open" /> Bez zestawu
          </Box>
        )}
        {!member.pager && (
          <Box color="bad">
            <Icon name="exclamation-triangle" /> Nie ma pagera
          </Box>
        )}
      </Box>
      <Stack wrap="wrap" mt={0.5}>
        <Stack.Item>
          <Dropdown
            width="105px"
            selected={
              data.positions.find((pos) => pos.id === member.base_position)
                ?.name
            }
            options={data.positions.map((pos) => ({
              value: pos.id,
              displayText: pos.name,
            }))}
            onSelected={(value) =>
              act('set_position', { ref: member.ref, position: value })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="star"
            color={member.leader ? 'average' : 'transparent'}
            tooltip={member.leader ? 'Zdegraduj dowódcę' : 'Mianuj dowódcą'}
            onClick={() =>
              act(member.leader ? 'aq_demote_leader' : 'aq_set_leader', {
                ref: member.ref,
              })
            }
          />
        </Stack.Item>
        {!!data.has_camera && (
          <Stack.Item>
            <Button
              icon="video"
              disabled={!member.cam}
              tooltip={
                member.cam
                  ? 'Kamera pancerza'
                  : 'Nie nosi pancerza drużyny, więc kamera nie nadaje'
              }
              onClick={() => act('view_cam', { ref: member.ref })}
            />
          </Stack.Item>
        )}
        {others.map((other) => (
          <Stack.Item key={other.id}>
            <Button
              compact
              style={{ background: other.colour }}
              tooltip={`Przenieś do drużyny ${other.name}`}
              onClick={() =>
                act('assign', { ref: member.ref, squad_id: other.id })
              }
            >
              {other.name.charAt(0)}
            </Button>
          </Stack.Item>
        ))}
        <Stack.Item>
          <Button
            compact
            icon="user-minus"
            color="transparent"
            tooltip="Usuń z drużyny"
            onClick={() => act('unassign', { ref: member.ref })}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const BodycamView = () => {
  const { act, data } = useBackend<SquadConsoleData>();
  const target = data.camera_target;
  if (!target || !data.map_ref) {
    return null;
  }
  return (
    <Section
      fill
      title={`Kamera pancerza: ${target.name}`}
      buttons={
        <Button icon="times" onClick={() => act('close_cam')}>
          Zamknij
        </Button>
      }
    >
      {!target.active && (
        <NoticeBox>Pancerz zdjęty albo poza zasięgiem. Brak obrazu.</NoticeBox>
      )}
      <ByondUi
        height="100%"
        width="100%"
        params={{ id: data.map_ref, type: 'map' }}
      />
    </Section>
  );
};

const MapTab = () => {
  const { act, data } = useBackend<SquadConsoleData>();
  const [placing, setPlacing] = useState<string | null>(null);
  const [targetSquad, setTargetSquad] = useState<string | null>(
    data.squads[0]?.id || null,
  );
  const squad = data.squads.find((s) => s.id === targetSquad);
  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section fill>
          <SquadTacticalMap
            map={data.map}
            squads={data.squads}
            placing={placing && targetSquad ? placing : null}
            onSelectZ={(z) => act('select_z', { z })}
            onPlace={(x, y, z) =>
              act('place_marker', {
                squad_id: targetSquad,
                marker: placing,
                x,
                y,
                z,
              })
            }
            onClearMarker={(markerSquad, marker) =>
              act('clear_marker', {
                squad_id: markerSquad.id,
                marker: marker.type,
              })
            }
          />
        </Section>
      </Stack.Item>
      <Stack.Item width="300px">
        <Section fill scrollable title="Znaczniki rozkazów">
          <Box mb={1}>Drużyna:</Box>
          <Stack wrap="wrap" mb={1}>
            {data.squads.map((s) => (
              <Stack.Item key={s.id}>
                <Button
                  selected={s.id === targetSquad}
                  style={{ borderBottom: `3px solid ${s.colour}` }}
                  onClick={() => setTargetSquad(s.id)}
                >
                  {s.name}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
          <MarkerPicker
            markerTypes={data.marker_types}
            placing={placing}
            setPlacing={setPlacing}
          />
          <Box mt={2} bold>
            Aktywne znaczniki
          </Box>
          {data.squads.map((s) =>
            s.markers.map((marker) => (
              <Box key={`${s.id}-${marker.type}`} mt={0.5}>
                <Box inline color={s.colour}>
                  {s.name}
                </Box>
                : {marker.label}, {marker.area || '?'} ({marker.time_left} s){' '}
                <Button
                  compact
                  icon="times"
                  color="transparent"
                  tooltip="Usuń znacznik"
                  onClick={() =>
                    act('clear_marker', {
                      squad_id: s.id,
                      marker: marker.type,
                    })
                  }
                />
              </Box>
            )),
          )}
          {!!squad && (
            <Box mt={2} color="label" fontSize="11px">
              Znacznik zobaczą w świecie i na mapie pagera członkowie drużyny{' '}
              {squad.name}.
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const LoansTab = () => {
  const { act, data } = useBackend<SquadConsoleData>();
  if (!data.loans.length) {
    return (
      <Section fill>
        <Box color="label">Nikt nie ma teraz pobranego zestawu.</Box>
      </Section>
    );
  }
  return (
    <Section fill scrollable title="Wydany sprzęt">
      <Table>
        <Table.Row header>
          <Table.Cell>Osoba</Table.Cell>
          <Table.Cell>Drużyna</Table.Cell>
          <Table.Cell>Zestaw</Table.Cell>
          <Table.Cell>Minut temu</Table.Cell>
          <Table.Cell>Nie oddano</Table.Cell>
          <Table.Cell />
        </Table.Row>
        {data.loans.map((loan, i) => (
          <Table.Row key={i}>
            <Table.Cell>
              {loan.name}
              {!!loan.lost && (
                <Box inline color="bad">
                  {' '}
                  (zaginiony)
                </Box>
              )}
            </Table.Cell>
            <Table.Cell>{loan.squad || '-'}</Table.Cell>
            <Table.Cell>{loan.kit}</Table.Cell>
            <Table.Cell>{loan.minutes}</Table.Cell>
            <Table.Cell color={loan.missing.length ? 'average' : 'good'}>
              {loan.missing.length ? loan.missing.join(', ') : 'wszystko'}
            </Table.Cell>
            <Table.Cell collapsing>
              {!!loan.missing.length &&
                (loan.reported ? (
                  <Box color="bad">Zgłoszono</Box>
                ) : (
                  <Button.Confirm
                    icon="gavel"
                    color="bad"
                    tooltip="Dopisuje do akt ochrony wykroczenie: Przywłaszczenie sprzętu drużyny"
                    confirmContent="Na pewno?"
                    onClick={() => act('aq_report_gear', { loan: loan.ref })}
                  >
                    Zgłoś do ochrony
                  </Button.Confirm>
                ))}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
