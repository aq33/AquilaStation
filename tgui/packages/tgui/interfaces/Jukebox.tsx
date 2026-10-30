import { sortBy } from 'es-toolkit';
import {
  Box,
  Button,
  Dropdown,
  Knob,
  LabeledControls,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA EDIT - nasz jukebox (aquila/code/game/machinery/jukebox*.dm) ma
// własne okno HTML z playlistami YouTube; to okno zostaje jako port z tg
// i obecnie nie otwiera go żaden kod DM.

type Song = {
  name: string;
  length: number;
  beat: number;
};

type Data = {
  active: BooleanLike;
  looping: BooleanLike;
  volume: number;
  track_selected: string | null;
  songs: Song[];
};

export const Jukebox = () => {
  const { act, data } = useBackend<Data>();
  const { active, looping, track_selected, volume, songs = [] } = data;

  const songs_sorted: Song[] = sortBy(songs, [(song: Song) => song.name]);
  const song_selected: Song | undefined = songs.find(
    (song) => song.name === track_selected,
  );

  return (
    <Window title="Szafa grająca" width={370} height={313}>
      <Window.Content>
        <Section
          title="Odtwarzacz"
          buttons={
            <>
              <Button
                icon={active ? 'pause' : 'play'}
                selected={active}
                onClick={() => act('toggle')}
              >
                {active ? 'Zatrzymaj' : 'Graj'}
              </Button>
              <Button.Checkbox
                icon={'arrow-rotate-left'}
                disabled={active}
                checked={looping}
                onClick={() => act('loop', { looping: !looping })}
              >
                Powtarzaj
              </Button.Checkbox>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Wybrany utwór">
              <Dropdown
                width="240px"
                options={songs_sorted.map((song) => song.name)}
                disabled={!!active}
                selected={song_selected?.name || 'Wybierz utwór'}
                onSelected={(value) =>
                  act('select_track', {
                    track: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Długość utworu">
              {song_selected?.length || 'Nie wybrano utworu'}
            </LabeledList.Item>
            <LabeledList.Item label="Rytm">
              {song_selected
                ? `${song_selected.beat} ${song_selected.beat === 1 ? 'uderzenie' : 'uderzeń'}`
                : 'Nie wybrano utworu'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Ustawienia urządzenia">
          <LabeledControls justify="center">
            <LabeledControls.Item label="Głośność">
              <Box position="relative">
                <Knob
                  size={3.2}
                  color={volume >= 25 ? 'red' : 'green'}
                  value={volume}
                  unit="%"
                  minValue={0}
                  maxValue={50}
                  step={1}
                  stepPixelSize={1}
                  onChange={(e, value) =>
                    act('set_volume', {
                      volume: value,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-22px"
                  color="transparent"
                  icon="fast-backward"
                  tooltip="Minimalna"
                  onClick={() =>
                    act('set_volume', {
                      volume: 'min',
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-22px"
                  color="transparent"
                  icon="fast-forward"
                  tooltip="Maksymalna"
                  onClick={() =>
                    act('set_volume', {
                      volume: 'max',
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="34px"
                  right="-22px"
                  color="transparent"
                  icon="undo"
                  tooltip="Domyślna"
                  onClick={() =>
                    act('set_volume', {
                      volume: 'reset',
                    })
                  }
                />
              </Box>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
