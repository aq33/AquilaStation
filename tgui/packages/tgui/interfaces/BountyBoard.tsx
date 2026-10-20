import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Flex,
  Icon,
  NumberInput,
  Section,
  TextArea,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { UserDetails } from './Newscaster';

type Request = {
  name: string;
  owner: string;
  description: string;
  value: number;
  acc_number: number;
};

type Applicant = {
  name: string;
  request_id: number;
  requestee_id: number;
};

type User = {
  name: string;
  job: string;
  authenticated: BooleanLike;
  silicon: BooleanLike;
};

type Data = {
  requests: Request[];
  applicants: Applicant[];
  bountyValue: number;
  bountyText: string;
  user: User;
};

export const BountyBoard = (props) => {
  return (
    <Window width={550} height={600}>
      <Window.Content scrollable>
        <BountyBoardContent />
      </Window.Content>
    </Window>
  );
};

export const BountyBoardContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { requests = [], applicants = [], user } = data;
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(50, 50, 170, 0.5)';

  return (
    <>
      <Section title="Dane użytkownika">
        <UserDetails />
      </Section>
      {!user.silicon && <NewBountyMenu />}
      {requests.map((request) => (
        <Collapsible
          key={request.name}
          title={`${request.owner}: zlecenie za ${formatMoney(request.value)} cr`}
        >
          <Section
            title={request.owner}
            buttons={
              <>
                <Icon name="coins" color="gold" />
                <Box inline ml={1} mr={1}>
                  {formatMoney(request.value)} cr
                </Box>
                <Button
                  icon="pen-fancy"
                  disabled={
                    user.silicon ||
                    !user.authenticated ||
                    request.owner === user.name
                  }
                  onClick={() =>
                    act('apply', {
                      request: request.acc_number,
                    })
                  }
                >
                  Zgłoś się
                </Button>
                <Button
                  icon="trash-alt"
                  color="red"
                  onClick={() =>
                    act('deleteRequest', {
                      request: request.acc_number,
                    })
                  }
                >
                  Usuń
                </Button>
              </>
            }
          >
            <BlockQuote style={{ whiteSpace: 'pre-wrap', overflow: 'auto' }}>
              <i>&quot;{request.description}&quot;</i>
            </BlockQuote>
            {applicants.some(
              (applicant) => applicant.request_id === request.acc_number,
            ) && (
              <Section title="Zgłoszeni chętni">
                {applicants.map(
                  (applicant) =>
                    applicant.request_id === request.acc_number && (
                      <Flex key={applicant.requestee_id} mt={1}>
                        <Flex.Item
                          grow={1}
                          p={0.5}
                          backgroundColor={backColor}
                          textAlign="center"
                          style={{
                            border: `2px solid ${color}`,
                          }}
                        >
                          {applicant.name}
                        </Flex.Item>
                        <Flex.Item align="end">
                          <Button
                            p={1}
                            icon="cash-register"
                            tooltip="Wypłać nagrodę tej osobie."
                            disabled={request.owner !== user.name}
                            onClick={() =>
                              act('payApplicant', {
                                applicant: applicant.requestee_id,
                                request: request.acc_number,
                              })
                            }
                          />
                        </Flex.Item>
                      </Flex>
                    ),
                )}
              </Section>
            )}
          </Section>
        </Collapsible>
      ))}
    </>
  );
};

const NewBountyMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { bountyValue, bountyText, user } = data;

  return (
    <Section
      title="Nowe zlecenie"
      buttons={
        <>
          <NumberInput
            animated
            unit="cr"
            minValue={1}
            maxValue={1000}
            value={bountyValue}
            width="80px"
            step={1}
            onChange={(value) =>
              act('bountyVal', {
                bountyval: value,
              })
            }
          />
          <Button
            icon="print"
            disabled={!user.authenticated}
            onClick={() => act('createBounty')}
          >
            Wystaw zlecenie
          </Button>
        </>
      }
    >
      <TextArea
        fluid
        height="60px"
        value={bountyText}
        placeholder="Opisz, czego potrzebujesz..."
        onBlur={(value) =>
          act('bountyText', {
            bountytext: value,
          })
        }
      />
    </Section>
  );
};
