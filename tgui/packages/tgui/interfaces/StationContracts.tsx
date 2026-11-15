// AQUILA - zlecenia działów ze stacji handlowych (aquila/code/modules/overmap/station_contracts.dm)
import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';

type Contract = {
  id: string;
  name: string;
  desc: string;
  department: string;
  reward: number;
  research: number;
  state: string;
  time_left: number | null;
  served?: number;
  amount?: number;
};

type Contracts = {
  offers: Contract[];
  active: Contract[];
  max_active: number;
  active_count: number;
};

type Data = {
  aq_contracts?: Contracts;
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

const Reward = (props: { contract: Contract }) => {
  const { contract } = props;
  return (
    <>
      {contract.reward} kr dla działu {contract.department}
      {contract.research > 0 && (
        <Box inline ml={1}>
          (+ {contract.research} pkt badań)
        </Box>
      )}
    </>
  );
};

export const StationContracts = (props) => {
  const { act, data } = useBackend<Data>();
  const contracts = data.aq_contracts;
  if (!contracts) {
    return null;
  }
  const { offers = [], active = [], max_active, active_count } = contracts;
  const full = active_count >= max_active;
  return (
    <Section title={`Zlecenia dla działów (${active_count}/${max_active})`}>
      {full && (
        <Box color="average" mb={1}>
          Okręt ma już komplet zleceń. Wykonajcie któreś, zanim przyjmiecie
          kolejne.
        </Box>
      )}
      {offers.map((contract) => (
        <Section
          key={contract.id}
          title={contract.name}
          buttons={
            <Button
              icon="file-signature"
              disabled={full}
              tooltip="Przyjmuje zaopatrzenie albo dowództwo."
              onClick={() => act('aq_accept_contract', { id: contract.id })}
            >
              Przyjmij
            </Button>
          }
        >
          <Box>{contract.desc}</Box>
          <Box color="label" mt={0.5}>
            Nagroda: <Reward contract={contract} />
          </Box>
        </Section>
      ))}
      {active.length > 0 && (
        <Section title="Przyjęte od tej stacji">
          <LabeledList>
            {active.map((contract) => (
              <LabeledList.Item
                key={contract.id}
                label={contract.name}
                color={stateColor(contract.state)}
              >
                {contract.state}
                {contract.time_left !== null && (
                  <Box inline ml={1} color="label">
                    (zostało {contract.time_left} min)
                  </Box>
                )}
                {contract.state === 'w toku' && (
                  <Button.Confirm
                    ml={1}
                    icon="times"
                    color="bad"
                    confirmContent="Na pewno?"
                    onClick={() =>
                      act('aq_cancel_contract', { id: contract.id })
                    }
                  >
                    Anuluj
                  </Button.Confirm>
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}
    </Section>
  );
};
