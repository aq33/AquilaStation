// AQUILA: okno pagera drużyny: członkowie i stan, zadanie, wiadomości, mapa taktyczna.
// Dowódca wydaje stąd rozkazy na ekran i stawia znaczniki na mapie.

import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
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
  SquadTacticalMap,
  STATUS_COLORS,
} from './common/SquadTacticalMap';

type LogEntry = { time: string; sender: string; text: string; kind: string };

type Data = {
  squad: SquadInfo | null;
  primary_objective: string | null;
  is_leader: BooleanLike;
  position: string | null;
  user_ref: string;
  log: LogEntry[];
  marker_types: MarkerType[];
  map: MapData;
  order_cooldown: number;
  tts: BooleanLike;
  tts_available: BooleanLike;
};

const LOG_ICONS: Record<string, string> = {
  order: 'bullhorn',
  marker: 'map-marker-alt',
  chat: 'comment',
};

export const SquadPager = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState(1);
  const squad = data.squad;
  return (
    <Window theme="ntos" width={760} height={720}>
      <Window.Content>
        {!squad ? (
          <NoticeBox>
            Pager nie jest przypisany do żadnej drużyny. Poproś XO o przydział.
          </NoticeBox>
        ) : (
          <Stack vertical fill>
            <Stack.Item>
              <Section
                title={
                  <Box inline color={squad.colour}>
                    Drużyna {squad.name}
                  </Box>
                }
                buttons={
                  <>
                    {!!data.tts_available && (
                      <Button
                        icon={data.tts ? 'volume-up' : 'volume-mute'}
                        selected={!!data.tts}
                        tooltip="Głos rozkazów (też w preferencjach gry)"
                        onClick={() => act('toggle_tts')}
                      />
                    )}
                    {!!data.is_leader && (
                      <Button
                        icon="bullhorn"
                        disabled={data.order_cooldown > 0}
                        onClick={() => act('order')}
                      >
                        {data.order_cooldown > 0
                          ? `Rozkaz za ${data.order_cooldown} s`
                          : 'Wydaj rozkaz'}
                      </Button>
                    )}
                  </>
                }
              >
                <Box>
                  Zadanie: <b>{data.primary_objective}</b>
                </Box>
                {!!squad.secondary_objective && (
                  <Box>
                    Cel dodatkowy: <b>{squad.secondary_objective}</b>
                  </Box>
                )}
                <Box>
                  Dowódca: <b>{squad.leader_name || 'brak'}</b>
                  {data.position ? `, twoja funkcja: ${data.position}` : ''}
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Tabs>
                <Tabs.Tab
                  icon="users"
                  selected={tab === 1}
                  onClick={() => setTab(1)}
                >
                  Drużyna
                </Tabs.Tab>
                <Tabs.Tab
                  icon="map"
                  selected={tab === 2}
                  onClick={() => setTab(2)}
                >
                  Mapa
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              {tab === 1 ? <TeamTab /> : <MapTab />}
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

const TeamTab = () => {
  const { data } = useBackend<Data>();
  const squad = data.squad as SquadInfo;
  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section fill scrollable title={`Członkowie (${squad.members.length})`}>
          {squad.members.map((member) => (
            <Stack key={member.ref} align="center" mb={0.5}>
              <Stack.Item>
                <Icon
                  name={POSITION_ICONS[member.position] || 'user'}
                  color={member.leader ? 'yellow' : 'white'}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Box bold={member.ref === data.user_ref}>{member.name}</Box>
                <Box color="label" fontSize="11px">
                  {member.position_name}, {member.area || '?'}
                </Box>
              </Stack.Item>
              <Stack.Item color={STATUS_COLORS[member.status]}>
                {member.status_name}
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        <Section fill scrollable title="Ostatnie wiadomości">
          {!data.log.length && <Box color="label">Brak wiadomości.</Box>}
          {[...data.log].reverse().map((entry, i) => (
            <Box key={i} mb={0.5}>
              <Box color="label" fontSize="11px">
                <Icon name={LOG_ICONS[entry.kind] || 'comment'} /> {entry.time}{' '}
                {entry.sender}
              </Box>
              <Box bold={entry.kind === 'order'}>{entry.text}</Box>
            </Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MapTab = () => {
  const { act, data } = useBackend<Data>();
  const [placing, setPlacing] = useState<string | null>(null);
  const squad = data.squad as SquadInfo;
  return (
    <Section fill>
      <Stack vertical fill>
        {!!data.is_leader && (
          <Stack.Item>
            <MarkerPicker
              markerTypes={data.marker_types}
              placing={placing}
              setPlacing={setPlacing}
            />
          </Stack.Item>
        )}
        <Stack.Item grow basis={0}>
          <SquadTacticalMap
            map={data.map}
            squads={[squad]}
            userRef={data.user_ref}
            placing={data.is_leader ? placing : null}
            onSelectZ={(z) => act('select_z', { z })}
            onPlace={(x, y, z) =>
              act('place_marker', { marker: placing, x, y, z })
            }
            onClearMarker={
              data.is_leader
                ? (_, marker) => act('clear_marker', { marker: marker.type })
                : undefined
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
