import { sortBy } from 'es-toolkit';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ILLEGAL_SHUTTLE_NOTICE } from './constants';
import type { CommsConsoleData, Shuttle } from './types';

function sortShuttles(shuttles: CommsConsoleData['shuttles']) {
  return sortBy(shuttles, [
    (shuttle) => !shuttle.illegal,
    (shuttle) => shuttle.creditCost,
  ]);
}

export function PageBuyingShuttle(props) {
  const { data } = useBackend<CommsConsoleData>();
  const { budget = 0, canBuyShuttles, shuttles = [] } = data;

  return (
    <Stack vertical fill>
      {canBuyShuttles !== 1 && (
        <Stack.Item>
          <NoticeBox danger>{canBuyShuttles}</NoticeBox>
        </Stack.Item>
      )}
      <Stack.Item>
        <Section>
          <Stack fill align="center" justify="space-between">
            <Stack.Item>Budżet:</Stack.Item>
            <Stack.Item>
              <Box as="span" bold color="good">
                {budget.toLocaleString()} kr
              </Box>{' '}
              <Icon name="coins" color="gold" />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {sortShuttles(shuttles).map((shuttle) => (
            <ShuttleCard key={shuttle.ref} shuttle={shuttle} />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

type ShuttleCardProps = {
  shuttle: Shuttle;
};

function ShuttleCard(props: ShuttleCardProps) {
  const { shuttle } = props;

  const { act, data } = useBackend<CommsConsoleData>();
  const { budget = 0, canBuyShuttles } = data;

  const tooBroke = budget < shuttle.creditCost;

  let buttonTooltip: string | undefined;
  if (tooBroke) {
    buttonTooltip = `Brakuje ci ${shuttle.creditCost - budget} kredytów.`;
  } else if (shuttle.illegal) {
    buttonTooltip = ILLEGAL_SHUTTLE_NOTICE;
  }

  return (
    <Section
      title={
        <span
          style={{
            display: 'inline-block',
            width: '70%',
          }}
        >
          {shuttle.name}
        </span>
      }
      buttons={
        <Button
          color={shuttle.illegal ? 'red' : 'default'}
          disabled={canBuyShuttles !== 1 || tooBroke}
          onClick={() =>
            act('purchaseShuttle', {
              shuttle: shuttle.ref,
            })
          }
          tooltip={buttonTooltip}
          tooltipPosition="left"
        >
          {`${shuttle.creditCost.toLocaleString()} kr`}
        </Button>
      }
    >
      <Box textAlign="justify">{shuttle.description}</Box>
      {!!shuttle.prerequisites && (
        <Box color="violet" fontSize="10px" bold>
          Wymagania: {shuttle.prerequisites}
        </Box>
      )}
    </Section>
  );
}
