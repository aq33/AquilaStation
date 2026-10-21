// Konsola komunikacyjna: struktura z tg, układ dwukolumnowy i funkcje z NSV13/Aquili
// (cele misji, alarmy statku, ERT, wybudzanie załogi).
import {
  Box,
  Button,
  Flex,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PageBuyingShuttle } from './BuyingShuttle';
import { PageChangingStatus } from './ChangingStatus';
import { PageMain } from './Main';
import { PageMessages } from './Messages';
import { NoConnectionModal } from './NoConnectionModal';
import { PageObjectives } from './Objectives';
import { type CommsConsoleData, ShuttleState } from './types';

export function CommunicationsConsole(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const {
    authenticated,
    authorizeName,
    canBuyShuttles,
    canLogOut,
    emagged,
    hasConnection,
    page,
  } = data;

  let currentPage;
  switch (page) {
    case ShuttleState.BUYING_SHUTTLE:
      currentPage = <PageBuyingShuttle />;
      break;
    case ShuttleState.CHANGING_STATUS:
      currentPage = <PageChangingStatus />;
      break;
    case ShuttleState.MESSAGES:
      currentPage = <PageMessages />;
      break;
    case ShuttleState.OBJECTIVES:
      currentPage = <PageObjectives />;
      break;
    default:
      currentPage = <Box>Strona niezaimplementowana: {page}</Box>;
      break;
  }

  const buyShuttlesTab = (
    <Tabs.Tab
      icon="shopping-cart"
      selected={page === ShuttleState.BUYING_SHUTTLE}
      onClick={() => act('setState', { state: ShuttleState.BUYING_SHUTTLE })}
    >
      Kup prom
    </Tabs.Tab>
  );

  return (
    <Window width={800} height={550} theme={emagged ? 'syndicate' : undefined}>
      <Window.Content>
        {authenticated ? (
          <Stack fill>
            <Stack.Item width="40%">
              <Section fill scrollable>
                {!!canLogOut && (
                  <Section title="Uwierzytelnianie">
                    <Button
                      icon="sign-out-alt"
                      color="bad"
                      onClick={() => act('toggleAuthentication')}
                    >
                      {`Wyloguj${authorizeName ? ` (${authorizeName})` : ''}`}
                    </Button>
                  </Section>
                )}
                <PageMain />
              </Section>
            </Stack.Item>
            <Stack.Item width="60%">
              <Stack vertical fill>
                <Stack.Item>
                  <Section title="Menu" fitted>
                    <Tabs>
                      <Tabs.Tab
                        icon="desktop"
                        selected={page === ShuttleState.CHANGING_STATUS}
                        onClick={() =>
                          act('setState', {
                            state: ShuttleState.CHANGING_STATUS,
                          })
                        }
                      >
                        Wyświetlacze
                      </Tabs.Tab>

                      <Tabs.Tab
                        icon="envelope-o"
                        selected={page === ShuttleState.MESSAGES}
                        onClick={() =>
                          act('setState', { state: ShuttleState.MESSAGES })
                        }
                      >
                        Wiadomości
                      </Tabs.Tab>

                      {canBuyShuttles !== 0 &&
                        (canBuyShuttles !== 1 ? (
                          // canBuyShuttles to powód odmowy, jeśli DM go podał
                          <Tooltip content={canBuyShuttles}>
                            {buyShuttlesTab}
                          </Tooltip>
                        ) : (
                          buyShuttlesTab
                        ))}

                      <Tabs.Tab
                        icon="dot-circle-o"
                        selected={page === ShuttleState.OBJECTIVES}
                        onClick={() =>
                          act('setState', { state: ShuttleState.OBJECTIVES })
                        }
                      >
                        Cele
                      </Tabs.Tab>
                    </Tabs>
                  </Section>
                </Stack.Item>
                <Stack.Item grow position="relative">
                  {currentPage}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        ) : (
          <Flex height="100%" width="100%" justify="center" align="center">
            <Section title="Uwierzytelnianie">
              <Button
                icon="sign-in-alt"
                color="good"
                fluid
                onClick={() => act('toggleAuthentication')}
              >
                Zaloguj
              </Button>
            </Section>
          </Flex>
        )}

        {!hasConnection && <NoConnectionModal />}
      </Window.Content>
    </Window>
  );
}
