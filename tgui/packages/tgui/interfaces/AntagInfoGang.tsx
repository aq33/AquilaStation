import { LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

// AQUILA: okno roli w wojnie gangów, w stylu okien rewolucji i kultu krwi.
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
  } = data;

  return (
    <Window width={460} height={leader ? 560 : 500}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor={gang_color} fontSize="24px" textAlign="center">
              Gang {gang_name}
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
                    Brońcie go do końca odliczania, a gang przejmie stację.
                    Im więcej terenu macie, tym krócej trwa przejęcie.
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
