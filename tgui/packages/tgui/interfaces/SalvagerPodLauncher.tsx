import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: konsola kapsuł desantowych złomiarzy: obszar lądowania, kto leci i dwuetapowy start (motyw „salvager”).
type Data = {
  areas: string[];
  area: string | null;
  crew: string[];
  reload: number;
  launching: BooleanLike;
  armed: BooleanLike;
};

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${minutes}:${rest < 10 ? `0${rest}` : rest}`;
};

export const SalvagerPodLauncher = () => {
  const { act, data } = useBackend<Data>();
  const { areas = [], area, crew = [], reload, launching, armed } = data;
  const [search, setSearch] = useState('');
  const query = search.toLowerCase();
  const shown = areas.filter((name) => name.toLowerCase().includes(query));
  let status = 'GOTOWE';
  if (launching) {
    status = 'START W TOKU';
  } else if (reload > 0) {
    status = `PRZEŁADOWANIE ${formatTime(reload)}`;
  } else if (armed) {
    status = 'UZBROJONE';
  }

  return (
    <Window width={540} height={620} theme="salvager">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Box className="Salvager__hazard" />
            <Box
              mt={1}
              fontSize="20px"
              bold
              color="#e0902c"
              style={{ letterSpacing: '0.15em', fontFamily: 'Consolas' }}
            >
              KAPSUŁY DESANTOWE
            </Box>
            <Box color="label" fontSize="11px">
              Lot w jedną stronę. Wracacie teleporterem ręcznym.
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Obszar lądowania"
              buttons={
                <Input
                  placeholder="Szukaj..."
                  value={search}
                  onChange={(value) => setSearch(value)}
                />
              }
            >
              {shown.map((name) => (
                <Button
                  key={name}
                  fluid
                  icon={name === area ? 'crosshairs' : 'location-dot'}
                  selected={name === area}
                  disabled={!!launching}
                  onClick={() => act('set_area', { area: name })}
                >
                  {name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={`Na platformie (${crew.length})`}>
              {crew.length ? (
                <Box>{crew.join(', ')}</Box>
              ) : (
                <Box color="label">Nikogo przy konsoli.</Box>
              )}
              {crew.length === 1 && (
                <Box mt={0.5} color="average">
                  Lecisz sam!
                </Box>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Box className="Salvager__display" mb={1}>
              <Box>CEL: {area || '---'}</Box>
              <Box>STAN: {status}</Box>
            </Box>
            {!!armed && (
              <NoticeBox danger>NAPRAWDĘ na pewno? Nie ma powrotu!</NoticeBox>
            )}
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  fontSize="16px"
                  icon={armed ? 'xmark' : 'lock-open'}
                  disabled={!area || reload > 0 || !!launching}
                  onClick={() => act('arm')}
                >
                  {armed ? 'Anuluj' : 'Uzbrój start'}
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  fontSize="16px"
                  icon="rocket"
                  color="danger"
                  disabled={!armed || !!launching}
                  onClick={() => act('launch')}
                >
                  START
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
