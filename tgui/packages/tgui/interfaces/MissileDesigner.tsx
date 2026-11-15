// AQUILA - stół projektowy pocisków (aquila/code/modules/munitions/missile_design.dm)
import {
  Box,
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Summary = {
  speed: number;
  range: number;
  integrity: number;
  turn: number;
  seeker: string;
};

type Design = {
  name: string;
  body: string;
  engine: string;
  seeker: string;
  summary: Summary;
};

// index to trwały numer projektu (missile_design.dm), nie pozycja na liście
type SavedDesign = Design & { index: number };

type Data = {
  draft: Design;
  designs: SavedDesign[];
  options: Record<string, string[]>;
  printing: boolean;
  can_use: boolean;
};

const SLOTS: [string, string][] = [
  ['body', 'Kadłub'],
  ['engine', 'Silnik'],
  ['seeker', 'Naprowadzanie'],
];

const SEEKER_INFO: Record<string, string> = {
  brak: 'Leci prosto. Tani i szybki, na krótki dystans.',
  podczerwień: 'Leci na ciepło celu. Gubi zimny cel i cel w masce.',
  radar: 'Sam świeci radarem. Wabik może go ściągnąć.',
  'z okrętu': 'Leci na cel główny operatora rozpoznania.',
};

const factorColor = (value: number, higherIsBetter = true) => {
  if (value === 1) {
    return undefined;
  }
  return value > 1 === higherIsBetter ? 'good' : 'average';
};

export const MissileDesigner = () => {
  const { act, data } = useBackend<Data>();
  const { draft, designs, options, printing, can_use } = data;
  const s = draft.summary;
  return (
    <Window width={560} height={560}>
      <Window.Content scrollable>
        {!can_use && (
          <Box color="bad" mb={1}>
            Brak dostępu do zbrojowni: możesz tylko przeglądać projekty.
          </Box>
        )}
        <Section
          title="Projekt"
          buttons={
            <>
              <Button
                icon="save"
                disabled={!can_use}
                onClick={() => act('save')}
              >
                Zapisz
              </Button>
              <Button
                icon="print"
                disabled={!can_use || printing}
                onClick={() => act('print')}
              >
                {printing ? 'Drukowanie...' : 'Drukuj chip'}
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Nazwa">
              <Input
                value={draft.name}
                disabled={!can_use}
                onBlur={(value) => act('rename', { name: value })}
              />
            </LabeledList.Item>
            {SLOTS.map(([slot, label]) => (
              <LabeledList.Item key={slot} label={label}>
                {(options[slot] || []).map((option) => (
                  <Button
                    key={option}
                    selected={draft[slot] === option}
                    disabled={!can_use}
                    onClick={() => act('set_slot', { slot, value: option })}
                  >
                    {option}
                  </Button>
                ))}
              </LabeledList.Item>
            ))}
          </LabeledList>
          <Box mt={1} color="label">
            {SEEKER_INFO[draft.seeker]}
          </Box>
        </Section>
        <Section title="Parametry względem zwykłego pocisku">
          <Stack>
            <Stack.Item grow>
              Prędkość:{' '}
              <Box inline bold color={factorColor(s.speed)}>
                ×{s.speed}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              Zasięg:{' '}
              <Box inline bold color={factorColor(s.range)}>
                ×{s.range}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              Odporność:{' '}
              <Box inline bold color={factorColor(s.integrity)}>
                ×{s.integrity}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              Skręt:{' '}
              <Box inline bold color={factorColor(s.turn)}>
                ×{s.turn}
              </Box>
            </Stack.Item>
          </Stack>
          <Box mt={1} color="label">
            Chip włóż do obudowy torpedy albo rakiety przed spawaniem. Głowicę
            bojową wkładasz jak zwykle.
          </Box>
        </Section>
        <Section title="Zapisane projekty">
          {!designs.length && <Box color="label">Brak zapisanych projektów.</Box>}
          <Table>
            {designs.map((design) => (
              <Table.Row key={design.index} className="candystripe">
                <Table.Cell bold>{design.name}</Table.Cell>
                <Table.Cell color="label">
                  {design.body}, {design.engine}, {design.seeker}
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    icon="folder-open"
                    disabled={!can_use}
                    onClick={() => act('load', { index: design.index })}
                  >
                    Wczytaj
                  </Button>
                  <Button
                    icon="trash"
                    color="bad"
                    disabled={!can_use}
                    onClick={() => act('delete', { index: design.index })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
