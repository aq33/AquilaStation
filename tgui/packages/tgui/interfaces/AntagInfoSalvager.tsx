import { Box, ProgressBar, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

// AQUILA: okno roli złomiarza (motyw „salvager”): jak grać, punkty i wyniki załogi.
type Member = {
  name: string;
  earned: number;
  alive: BooleanLike;
  you: BooleanLike;
};

type Info = {
  objectives: Objective[];
  points: number;
  earned: number;
  crew_points: number;
  goal: number;
  crew: Member[];
};

export const AntagInfoSalvager = () => {
  const { data } = useBackend<Info>();
  const {
    objectives = [],
    points,
    earned,
    crew_points,
    goal,
    crew = [],
  } = data;

  return (
    <Window width={560} height={640} theme="salvager">
      <Window.Content scrollable>
        <Box className="Salvager__hazard" />
        <Box
          mt={1}
          mb={1}
          fontSize="24px"
          bold
          color="#e0902c"
          style={{ letterSpacing: '0.12em', fontFamily: 'Consolas' }}
        >
          Jesteś złomiarzem!
        </Box>
        <Section title="Jak to działa">
          <Stack vertical>
            <Stack.Item>
              1. W konsoli kapsuł desantowych wybierz obszar okrętu i lećcie.
            </Stack.Item>
            <Stack.Item>
              2. Reklamatorem (poza trybem walki) rozbieraj ściany, podłogi,
              drzwi i maszyny na złom.
            </Stack.Item>
            <Stack.Item>
              3. Urządzeniem dwukonstrukcyjnym pakuj maszyny w paczki: są warte
              najwięcej.
            </Stack.Item>
            <Stack.Item>
              4. Wracaj teleporterem ręcznym. Telekryształ dokłada ładunek.
            </Stack.Item>
            <Stack.Item>
              5. Sprzedawaj łup w terminalu S.R.O.K.A. i kupuj w nim sprzęt.
            </Stack.Item>
            <Stack.Item color="label">
              Nie jesteście mordercami: walczcie, gdy musicie, ale zysk jest w
              złomie.
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Twoje punkty">
          <Stack>
            <Stack.Item grow>
              <Box className="Salvager__display">
                <Box fontSize="20px">{points} pkt</Box>
                <Box fontSize="10px">do wydania</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box className="Salvager__display">
                <Box fontSize="20px">{earned} pkt</Box>
                <Box fontSize="10px">zarobione razem</Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Załoga">
          <ProgressBar
            value={crew_points}
            maxValue={goal || 1}
            ranges={{
              good: [goal, Infinity],
              average: [-Infinity, goal],
            }}
          >
            {crew_points} / {goal} pkt
          </ProgressBar>
          <Table mt={1}>
            {crew.map((member) => (
              <Table.Row key={member.name}>
                <Table.Cell
                  bold={!!member.you}
                  color={member.alive ? undefined : 'bad'}
                >
                  {member.name}
                  {member.alive ? '' : ' (nie żyje)'}
                </Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  {member.earned} pkt
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        <ObjectivePrintout objectives={objectives} titleMessage="Cele załogi" />
      </Window.Content>
    </Window>
  );
};
