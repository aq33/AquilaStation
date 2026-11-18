// AQUILA - misje okrętu od handlarzy i reputacja u stacji
// (aquila/code/modules/overmap/trader_missions.dm, trader_reputation.dm)
import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';

type Mission = {
  id: string;
  name: string;
  desc: string;
  department: string;
  reward: number;
  state: string;
  time_left: number | null;
  items: string[];
  reputation: number;
  progress: string | null;
  where: string | null;
};

type Missions = {
  available: boolean;
  offers: Mission[];
  active: Mission[];
  max_active: number;
  active_count: number;
};

type Reputation = {
  points: number;
  level: string;
  discount: number;
  next: number | null;
  special: boolean;
};

type Data = {
  aq_missions?: Missions;
  aq_reputation?: Reputation;
};

const stateColor = (state: string) => {
  if (state === 'wykonane') {
    return 'good';
  }
  if (state === 'nieudane') {
    return 'bad';
  }
  return 'average';
};

const Reward = (props: { mission: Mission }) => {
  const { mission } = props;
  return (
    <>
      {mission.reward} kr dla działu {mission.department}
      {mission.items.map((item) => (
        <Box inline key={item} ml={1}>
          + {item}
        </Box>
      ))}
      {mission.reputation > 0 && (
        <Box inline ml={1}>
          + {mission.reputation} pkt reputacji
        </Box>
      )}
    </>
  );
};

const ReputationInfo = (props: { reputation: Reputation }) => {
  const { reputation } = props;
  return (
    <Box mb={1}>
      Reputacja u stacji: <b>{reputation.level}</b> ({reputation.points} pkt
      {reputation.next !== null && <> z {reputation.next} do następnego</>}
      ). Zniżka na towar: {reputation.discount}%.
      {reputation.special && (
        <Box color="good">Stacja pokazuje wam oferty specjalne.</Box>
      )}
    </Box>
  );
};

export const TraderMissions = (props) => {
  const { act, data } = useBackend<Data>();
  const missions = data.aq_missions;
  const reputation = data.aq_reputation;
  if (!missions) {
    return null;
  }
  const {
    available,
    offers = [],
    active = [],
    max_active,
    active_count,
  } = missions;
  const full = active_count >= max_active;
  return (
    <Section title={`Misje dla okrętu (${active_count}/${max_active})`}>
      {reputation && <ReputationInfo reputation={reputation} />}
      {!available && (
        <Box color="average">Ta stacja nie zleca misji okrętom Nanotrasen.</Box>
      )}
      {available && full && (
        <Box color="average" mb={1}>
          Okręt ma już komplet misji. Wykonajcie którąś, zanim przyjmiecie
          kolejną.
        </Box>
      )}
      {available &&
        offers.map((mission) => (
          <Section
            key={mission.id}
            title={mission.name}
            buttons={
              <Button
                icon="file-signature"
                disabled={full}
                tooltip="Przyjmuje zaopatrzenie albo dowództwo."
                onClick={() => act('aq_accept_contract', { id: mission.id })}
              >
                Przyjmij
              </Button>
            }
          >
            <Box>{mission.desc}</Box>
            <Box color="label" mt={0.5}>
              Nagroda: <Reward mission={mission} />
            </Box>
          </Section>
        ))}
      {active.length > 0 && (
        <Section title="Przyjęte od tej stacji">
          <LabeledList>
            {active.map((mission) => (
              <LabeledList.Item
                key={mission.id}
                label={mission.name}
                color={stateColor(mission.state)}
              >
                {mission.state}
                {mission.progress && (
                  <Box inline ml={1}>
                    ({mission.progress})
                  </Box>
                )}
                {mission.time_left !== null && (
                  <Box inline ml={1} color="label">
                    (zostało {mission.time_left} min)
                  </Box>
                )}
                {mission.state === 'w toku' && (
                  <Button.Confirm
                    ml={1}
                    icon="times"
                    color="bad"
                    confirmContent="Na pewno?"
                    tooltip="Anulowanie obniża reputację u stacji."
                    onClick={() => act('aq_cancel_contract', { id: mission.id })}
                  >
                    Anuluj
                  </Button.Confirm>
                )}
                {mission.state === 'w toku' && mission.where && (
                  <Box color="label">Cel: {mission.where}</Box>
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}
    </Section>
  );
};
