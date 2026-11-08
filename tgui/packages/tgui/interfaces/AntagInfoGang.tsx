import {
  Box,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

// AQUILA: okno roli w wojnie gangów (motyw „gang”: noir, mur z cegieł, złoto).
type Member = {
  name: string;
  rank: string;
  job: string;
  you: BooleanLike;
};

type Rival = {
  name: string;
  color: string;
  territory: number;
  dominating: BooleanLike;
};

type Info = {
  antag_name: string;
  objectives: Objective[];
  gang_name: string;
  gang_color: string;
  leader: BooleanLike;
  members: number;
  cap: number;
  leaders: number;
  territory: number;
  influence: number;
  dom_attempts: number;
  dominating: BooleanLike;
  dom_remaining: number;
  dom_estimate: number;
  rivals: Rival[];
  member_list: Member[];
};

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60);
  const rest = Math.floor(seconds % 60);
  return `${minutes}:${rest < 10 ? `0${rest}` : rest}`;
};

export const AntagInfoGang = () => {
  const { data } = useBackend<Info>();
  const {
    objectives = [],
    gang_name,
    gang_color,
    leader,
    members,
    cap,
    leaders,
    territory,
    influence,
    dom_attempts,
    dominating,
    dom_remaining,
    dom_estimate,
    rivals = [],
    member_list = [],
  } = data;

  return (
    <Window width={480} height={leader ? 680 : 620} theme="gang">
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textAlign="center">
              <Box
                inline
                px={1.5}
                py={0.5}
                fontSize="26px"
                bold
                textColor={gang_color}
                style={{
                  fontFamily: 'Georgia, serif',
                  letterSpacing: '0.12em',
                  border: `2px solid ${gang_color}`,
                  textShadow: '2px 2px 0 #000',
                  transform: 'rotate(-2deg)',
                }}
              >
                Gang {gang_name}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {leader ? (
                <Stack vertical>
                  <Stack.Item>
                    - Werbuj załogę długopisem werbunkowym albo implantem z
                    gangtoola. Gang ma limit członków, który rośnie razem z
                    liczbą żywej załogi.
                  </Stack.Item>
                  <Stack.Item>
                    - Zajmuj teren farbą gangu. Teren i szpan (stroje gangu)
                    dają wpływy, za które kupujesz sprzęt w gangtoolu.
                  </Stack.Item>
                  <Stack.Item>
                    - Kup Dominatora, postaw go na swoim terenie i włącz.
                    Brońcie go do końca odliczania, a gang przejmie stację. Im
                    więcej terenu macie, tym krócej trwa przejęcie.
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    - Słuchaj szefów gangu i zajmuj teren farbą gangu.
                  </Stack.Item>
                  <Stack.Item>
                    - Kumpli rozpoznasz po ikonie w kolorze gangu.
                  </Stack.Item>
                  <Stack.Item>
                    - Gdy szefowie włączą Dominatora, brońcie go za wszelką
                    cenę.
                  </Stack.Item>
                </Stack>
              )}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Członkowie">
                  <ProgressBar value={members} maxValue={Math.max(cap, 1)}>
                    {members} / {cap}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Szefowie">{leaders}</LabeledList.Item>
                <LabeledList.Item label="Teren">
                  <ProgressBar value={territory} maxValue={100}>
                    {territory}% stacji
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Wpływy">{influence}</LabeledList.Item>
                <LabeledList.Item label="Dominator">
                  {dominating
                    ? `Przejęcie trwa, zostało ${formatTime(dom_remaining)}`
                    : dom_attempts > 0
                      ? `Pozostałe próby: ${dom_attempts}, przejęcie potrwa ok. ${formatTime(dom_estimate)}`
                      : 'Brak prób'}
                </LabeledList.Item>
                {rivals.map((rival) => (
                  <LabeledList.Item
                    key={rival.name}
                    label={`Rywal: ${rival.name}`}
                    color={rival.dominating ? 'bad' : undefined}
                  >
                    {rival.dominating
                      ? 'Przejmuje stację! Zniszczcie ich Dominatora!'
                      : `Teren: ${rival.territory}%`}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Section title="Rodzina">
                <Table>
                  {member_list.map((member) => (
                    <Table.Row key={member.name}>
                      <Table.Cell
                        bold={!!member.you}
                        textColor={
                          member.rank === 'Gangster' ? undefined : 'label'
                        }
                      >
                        {member.name}
                        {member.you ? ' (ty)' : ''}
                      </Table.Cell>
                      <Table.Cell collapsing textColor="label">
                        {member.rank}
                      </Table.Cell>
                      <Table.Cell collapsing textColor="grey">
                        {member.job}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <ObjectivePrintout
                objectives={objectives}
                titleMessage="Cele gangu"
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
