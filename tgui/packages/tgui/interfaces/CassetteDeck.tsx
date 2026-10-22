// AQUILA - deck kasetowy (port z Monkestation, CassetteDeck.jsx)
import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Song = {
  name: string;
  url: string;
  length: number;
  artist?: string;
  album?: string;
};

type Cassette = {
  name: string;
  desc: string;
  status: number;
  author?: string;
  side: string;
  design: string;
  songs: Song[];
};

type Design = {
  name: string;
  icon_state: string;
};

type Data = {
  busy: boolean;
  cassette: Cassette | null;
  icon: string;
  max_songs: number;
  designs: Design[];
};

export const STATUS_TEXT = [
  'nieoficjalna',
  'w recenzji',
  'zatwierdzona',
  'odrzucona',
  'usunięta',
];

export const formatLength = (seconds: number) => {
  if (!seconds) {
    return '?';
  }
  const secs = Math.round(seconds) % 60;
  return `${Math.floor(seconds / 60)}:${secs < 10 ? '0' : ''}${secs}`;
};

export const CassetteDeck = () => {
  const { act, data } = useBackend<Data>();
  const { busy, cassette, icon, max_songs, designs } = data;
  const [url, setUrl] = useState('');

  if (!cassette) {
    return (
      <Window width={480} height={240}>
        <Window.Content>
          <NoticeBox info>Włóż kasetę, żeby nagrać na nią utwory.</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  const full = cassette.songs.length >= max_songs;
  const currentDesign = designs.find((d) => d.icon_state === cassette.design);

  return (
    <Window width={520} height={560}>
      <Window.Content scrollable>
        <Section
          title={cassette.name}
          buttons={
            <>
              <Button icon="rotate" onClick={() => act('flip')}>
                Odwróć
              </Button>
              <Button icon="eject" disabled={busy} onClick={() => act('eject')}>
                Wyjmij
              </Button>
            </>
          }
        >
          <Stack align="center">
            <Stack.Item>
              <DmIcon
                icon={icon}
                icon_state={cassette.design}
                width="64px"
                height="64px"
              />
            </Stack.Item>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Opis">
                  {cassette.desc || (
                    <Box color="label">brak (dopisz długopisem)</Box>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Status">
                  {STATUS_TEXT[cassette.status]}
                </LabeledList.Item>
                {!!cassette.author && (
                  <LabeledList.Item label="Autor">
                    {cassette.author}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Naklejka">
                  <Dropdown
                    width="100%"
                    selected={currentDesign?.name || ''}
                    options={designs.map((d) => d.name)}
                    onSelected={(value) => act('set_design', { design: value })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title={`Strona ${cassette.side} (${cassette.songs.length}/${max_songs})`}
        >
          {cassette.songs.length === 0 ? (
            <Box color="label">Ta strona jest pusta.</Box>
          ) : (
            <Table>
              {cassette.songs.map((song, index) => (
                <Table.Row key={index} className="candystripe">
                  <Table.Cell collapsing color="label">
                    {index + 1}.
                  </Table.Cell>
                  <Table.Cell>
                    {song.name}
                    {!!song.artist && <Box color="label">{song.artist}</Box>}
                  </Table.Cell>
                  <Table.Cell collapsing textAlign="right">
                    {formatLength(song.length)}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="trash"
                      color="bad"
                      tooltip="Usuń utwór"
                      disabled={busy}
                      onClick={() => act('remove', { index: index + 1 })}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section title="Nagraj utwór">
          {busy ? (
            <NoticeBox>Pobieranie danych utworu...</NoticeBox>
          ) : full ? (
            <NoticeBox>Ta strona jest pełna. Odwróć kasetę.</NoticeBox>
          ) : (
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Link z YouTube, SoundCloud albo Bandcamp"
                  value={url}
                  onChange={setUrl}
                  onEnter={() => {
                    act('add', { url });
                    setUrl('');
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="plus"
                  disabled={!url}
                  onClick={() => {
                    act('add', { url });
                    setUrl('');
                  }}
                >
                  Nagraj
                </Button>
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
