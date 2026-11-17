// AQUILA: markingi przypisane do kończyn (do 3 na część ciała, każdy z własnym kolorem).
// Serwer: aquila/code/modules/mob/living/carbon/human/body_markings/body_markings_prefs.dm
import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { CharacterPreview } from '../common/CharacterPreview';
import { PreferencesMenuData } from './data';

/** [id markingu, kolor #RRGGBB] */
type MarkingEntry = [string, string];

type MarkingInfo = {
  id: string;
  name: string;
  zones: string[];
};

type BodyMarkingsData = PreferencesMenuData & {
  // Pusta lista przychodzi z DM jako tablica, a nie obiekt
  aq_markings?: Record<string, MarkingEntry[]> | [];
  aq_markings_allowed?: BooleanLike;
  aq_markings_catalog?: MarkingInfo[];
  aq_markings_limit?: number;
};

const ZONES: [string, string][] = [
  ['head', 'Głowa'],
  ['chest', 'Tors'],
  ['l_arm', 'Lewa ręka'],
  ['r_arm', 'Prawa ręka'],
  ['l_hand', 'Lewa dłoń'],
  ['r_hand', 'Prawa dłoń'],
  ['l_leg', 'Lewa noga'],
  ['r_leg', 'Prawa noga'],
];

export const BodyMarkingsPage = () => {
  const { act, data } = useBackend<BodyMarkingsData>();
  const [zone, setZone] = useState('head');
  const [searchText, setSearchText] = useState('');
  // Numer wpisu (od 1), który podmieniamy na marking z listy, albo 0
  const [replacing, setReplacing] = useState(0);

  const markings: Record<string, MarkingEntry[]> = Array.isArray(
    data.aq_markings,
  )
    ? {}
    : data.aq_markings || {};
  const limit = data.aq_markings_limit || 3;
  const catalog = data.aq_markings_catalog || [];
  const names: Record<string, string> = {};
  for (const marking of catalog) {
    names[marking.id] = marking.name;
  }
  const current = markings[zone] || [];
  const zoneName = ZONES.find(([id]) => id === zone)?.[1] || zone;
  const search = createSearch(searchText, (marking: MarkingInfo) => {
    return marking.name;
  });
  const available = catalog
    .filter(
      (marking) =>
        marking.zones.indexOf(zone) !== -1 && (!searchText || search(marking)),
    )
    .sort((a, b) => a.name.localeCompare(b.name, 'pl'));
  const full = current.length >= limit;

  const selectZone = (newZone: string) => {
    setZone(newZone);
    setReplacing(0);
  };

  return (
    <Stack height="590px">
      <Stack.Item>
        <Stack vertical fill>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="undo"
                  tooltip="Obróć w lewo"
                  onClick={() => act('rotate', { direction: true })}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="redo"
                  tooltip="Obróć w prawo"
                  onClick={() => act('rotate', { direction: false })}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <CharacterPreview height="545px" id={data.character_preview_view} />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item width="190px">
        <Section title="Część ciała" fill>
          {ZONES.map(([id, label]) => (
            <Button
              key={id}
              fluid
              selected={zone === id}
              onClick={() => selectZone(id)}
            >
              <Stack>
                <Stack.Item grow>{label}</Stack.Item>
                <Stack.Item color="label">
                  {(markings[id] || []).length}/{limit}
                </Stack.Item>
              </Stack>
            </Button>
          ))}
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Stack vertical fill>
          {!data.aq_markings_allowed && (
            <Stack.Item>
              <NoticeBox>
                Ta rasa nie ma markingów na kończynach. Wybrane markingi zostają
                zapisane i pojawią się po zmianie rasy.
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Section title={zoneName}>
              {current.length === 0 && (
                <Box color="label">Brak markingów na tej części ciała.</Box>
              )}
              {current.map(([id, color], i) => (
                <Stack key={i} align="center" mb={0.5}>
                  <Stack.Item>
                    <ColorBox color={color} />
                  </Stack.Item>
                  <Stack.Item grow>{names[id] || id}</Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="palette"
                      onClick={() =>
                        act('aq_marking_color', { zone: zone, index: i + 1 })
                      }
                    >
                      Kolor
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="exchange-alt"
                      selected={replacing === i + 1}
                      tooltip="Wybierz z listy inny marking, kolor zostaje"
                      onClick={() =>
                        setReplacing(replacing === i + 1 ? 0 : i + 1)
                      }
                    >
                      Zamień
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="bad"
                      tooltip="Usuń"
                      onClick={() => {
                        setReplacing(0);
                        act('aq_marking_remove', { zone: zone, index: i + 1 });
                      }}
                    />
                  </Stack.Item>
                </Stack>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title={replacing ? 'Zamień na' : 'Dodaj marking'}
              fill
              scrollable
              buttons={
                <Input
                  width="220px"
                  placeholder="Szukaj markingu"
                  value={searchText}
                  onChange={(value) => setSearchText(value)}
                />
              }
            >
              {available.length === 0 && (
                <Box color="label">Żaden marking nie pasuje.</Box>
              )}
              {available.map((marking) => (
                <Button
                  key={marking.id}
                  disabled={!replacing && full}
                  tooltip={
                    !replacing && full
                      ? 'Ta część ciała ma już komplet markingów'
                      : undefined
                  }
                  onClick={() => {
                    if (replacing) {
                      act('aq_marking_change', {
                        zone: zone,
                        index: replacing,
                        id: marking.id,
                      });
                      setReplacing(0);
                    } else {
                      act('aq_marking_add', { zone: zone, id: marking.id });
                    }
                  }}
                >
                  {marking.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
