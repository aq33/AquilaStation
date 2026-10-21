// Port wyglądu z tg (SyndicateContractor.tsx) pod naszą nazwą okna.
// AQUILA: zostaje zakładka Hub z reputacją (contract_rep, buy_hub) - tg ją usunął, u nas działa.
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import { NtosWindow } from '../layouts';
import { FakeTerminal } from './common/FakeTerminal';

enum CONTRACT {
  Inactive = 1,
  Active = 2,
  Complete = 5,
}

type Data = {
  contracts_completed: number;
  contracts: ContractData[];
  contract_rep: number;
  contractor_hub_items: HubItem[];
  dropoff_direction: string;
  earned_tc: number;
  error: string;
  extraction_enroute: BooleanLike;
  first_load: BooleanLike;
  info_screen: BooleanLike;
  logged_in: BooleanLike;
  ongoing_contract: BooleanLike;
  redeemable_tc: number;
};

type ContractData = {
  contract: string;
  dropoff: string;
  extraction_enroute: BooleanLike;
  id: number;
  message: string;
  payout_bonus: number;
  payout: number;
  status: number;
  target_rank: string;
  target: string;
};

type HubItem = {
  name: string;
  desc: string;
  cost: number;
  limited: number;
  item_icon: string;
};

const terminalMessages = [
  'Zapis danych biometrycznych...',
  'Analiza wbudowanych danych Syndykatu...',
  'STATUS POTWIERDZONY',
  'Łączenie z bazą danych Syndykatu...',
  'Oczekiwanie na odpowiedź...',
  'Oczekiwanie na odpowiedź...',
  'Oczekiwanie na odpowiedź...',
  'Oczekiwanie na odpowiedź...',
  'Oczekiwanie na odpowiedź...',
  'Oczekiwanie na odpowiedź...',
  'Odebrano odpowiedź, ack 4851234...',
  `POTWIERDŹ KONTO ${Math.round(Math.random() * 20000)}`,
  'Zakładanie prywatnych kont...',
  'UTWORZONO KONTO KONTRAKTORA',
  'Szukanie dostępnych kontraktów...',
  'Szukanie dostępnych kontraktów...',
  'Szukanie dostępnych kontraktów...',
  'Szukanie dostępnych kontraktów...',
  'ZNALEZIONO KONTRAKTY',
  'WITAJ, AGENCIE',
] as const;

const infoEntries = [
  'SyndTract v2.0',
  '',
  'Namierzyliśmy potencjalnie cenne cele, które obecnie',
  'przebywają w twoim obszarze działania. Uważamy, że mają',
  'informacje, które mogą mieć dla naszej organizacji',
  'natychmiastowe znaczenie.',
  '',
  'Poniżej znajdziesz wszystkie dostępne dla ciebie kontrakty.',
  'Masz doprowadzić wskazany cel do wyznaczonego punktu',
  'zrzutu i skontaktować się z nami przez ten uplink.',
  'Wyślemy wtedy specjalną kapsułę ewakuacyjną na ciało.',
  '',
  'Cele chcemy żywe - za martwe czasem zapłacimy niewiele,',
  'ale bez pokazanej premii. Zapłatę odbierzesz przez ten',
  'uplink w postaci surowych telekryształów, które możesz',
  'włożyć do zwykłego uplinka Syndykatu i kupić, co trzeba.',
  'Kryształy przyznajemy w chwili wysłania nam celu,',
  'a odebrać je możesz w każdej chwili przez ten system.',
  '',
  'Gdy cele przestaną nam być potrzebne, odeślemy je na',
  'stację za okup, z którego dostaniesz niewielki procent.',
  'Uważaj, żeby po powrocie cię nie rozpoznały. Dajemy ci',
  'standardowe wyposażenie kontraktora, które pomoże ukryć',
  'twoją tożsamość.',
] as const;

export const SyndContractor = (props) => {
  return (
    <NtosWindow theme="syndicate" width={500} height={600}>
      <NtosWindow.Content scrollable>
        <SyndContractorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const SyndContractorContent = (props) => {
  const { data, act } = useBackend<Data>();
  const { error, logged_in, first_load, info_screen } = data;

  const errorPane = !!error && (
    <Modal backgroundColor="red">
      <Flex align="center">
        <Flex.Item mr={2}>
          <Icon size={4} name="exclamation-triangle" />
        </Flex.Item>
        <Flex.Item mr={2} grow={1} textAlign="center">
          <Box width="260px" textAlign="left" minHeight="80px">
            {error}
          </Box>
          <Button onClick={() => act('PRG_clear_error')}>Zamknij</Button>
        </Flex.Item>
      </Flex>
    </Modal>
  );

  if (!logged_in) {
    return (
      <Section minHeight="525px">
        <Box width="100%" textAlign="center">
          <Button color="transparent" onClick={() => act('PRG_login')}>
            ZAREJESTRUJ UŻYTKOWNIKA
          </Button>
        </Box>
        {!!error && <NoticeBox>{error}</NoticeBox>}
      </Section>
    );
  }

  if (logged_in && first_load) {
    return (
      <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="525px">
        <FakeTerminal
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('PRG_set_first_load_finished')}
        />
      </Box>
    );
  }

  if (info_screen) {
    return (
      <>
        <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="500px">
          <FakeTerminal allMessages={infoEntries} linesPerSecond={10} />
        </Box>
        <Button
          fluid
          color="transparent"
          textAlign="center"
          onClick={() => act('PRG_toggle_info')}
        >
          DALEJ
        </Button>
      </>
    );
  }

  return (
    <>
      {errorPane}
      <SyndPane />
    </>
  );
};

const StatusPane = (props) => {
  const { act, data } = useBackend<Data>();
  const { redeemable_tc, earned_tc, contracts_completed, contract_rep } = data;

  return (
    <Section
      title="Status kontraktora"
      buttons={
        <>
          <Box inline bold mr={1}>
            Reputacja: {contract_rep}
          </Box>
          <Button
            color="transparent"
            mb={0}
            ml={1}
            onClick={() => act('PRG_toggle_info')}
          >
            Pokaż informacje ponownie
          </Button>
        </>
      }
    >
      <Stack>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label="TC do odebrania"
              buttons={
                <Button
                  disabled={redeemable_tc <= 0}
                  onClick={() => act('PRG_redeem_TC')}
                >
                  Odbierz
                </Button>
              }
            >
              {String(redeemable_tc)}
            </LabeledList.Item>
            <LabeledList.Item label="Zarobione TC">
              {String(earned_tc)}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Wykonane kontrakty">
              {String(contracts_completed)}
            </LabeledList.Item>
            <LabeledList.Item label="Obecny status">AKTYWNY</LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SyndPane = (props) => {
  const [tab, setTab] = useLocalState('tab', 1);
  return (
    <>
      <StatusPane />
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          Kontrakty
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          Hub
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && <ContractsTab />}
      {tab === 2 && <HubTab />}
    </>
  );
};

const ContractsTab = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    contracts = [],
    ongoing_contract,
    extraction_enroute,
    dropoff_direction,
  } = data;

  return (
    <>
      <Section
        title="Dostępne kontrakty"
        buttons={
          <Button
            disabled={!ongoing_contract || !!extraction_enroute}
            onClick={() => act('PRG_call_extraction')}
          >
            Wezwij ewakuację
          </Button>
        }
      >
        {contracts.map((contract) => {
          if (ongoing_contract && contract.status !== CONTRACT.Active) {
            return null;
          }
          const active = contract.status > CONTRACT.Inactive;
          if (contract.status >= CONTRACT.Complete) {
            return null;
          }
          return (
            <Section
              key={contract.target}
              title={
                contract.target
                  ? `${contract.target} (${contract.target_rank})`
                  : 'Nieprawidłowy cel'
              }
              buttons={
                <>
                  <Box inline bold mr={1}>
                    {`${contract.payout} (+${contract.payout_bonus}) TC`}
                  </Box>
                  <Button
                    disabled={!!contract.extraction_enroute}
                    color={active ? 'bad' : undefined}
                    onClick={() =>
                      act(`PRG_contract${active ? '_abort' : '-accept'}`, {
                        contract_id: contract.id,
                      })
                    }
                  >
                    {active ? 'Przerwij' : 'Przyjmij'}
                  </Button>
                </>
              }
            >
              <Stack>
                <Stack.Item grow>{contract.message}</Stack.Item>
                <Stack.Item>
                  <Box bold mb={1}>
                    Punkt zrzutu:
                  </Box>
                  <Box>{contract.dropoff}</Box>
                </Stack.Item>
              </Stack>
            </Section>
          );
        })}
      </Section>
      <Section
        title="Lokalizator punktu zrzutu"
        textAlign="center"
        opacity={ongoing_contract ? 100 : 0}
      >
        <Box bold>{dropoff_direction}</Box>
      </Section>
    </>
  );
};

const HubTab = (props) => {
  const { act, data } = useBackend<Data>();
  const { contractor_hub_items = [], contract_rep } = data;
  return (
    <Section>
      {contractor_hub_items.map((item) => {
        const repInfo = item.cost ? `${item.cost} rep.` : 'ZA DARMO';
        const limited = item.limited !== -1;
        return (
          <Section
            key={item.name}
            title={`${item.name} - ${repInfo}`}
            buttons={
              <>
                {limited && (
                  <Box inline bold mr={1}>
                    Pozostało: {item.limited}
                  </Box>
                )}
                <Button
                  disabled={
                    contract_rep < item.cost || (limited && item.limited <= 0)
                  }
                  onClick={() =>
                    act('buy_hub', {
                      item: item.name,
                      cost: item.cost,
                    })
                  }
                >
                  Kup
                </Button>
              </>
            }
          >
            <Stack>
              <Stack.Item>
                <Icon fontSize="60px" name={item.item_icon} />
              </Stack.Item>
              <Stack.Item grow>{item.desc}</Stack.Item>
            </Stack>
          </Section>
        );
      })}
    </Section>
  );
};
