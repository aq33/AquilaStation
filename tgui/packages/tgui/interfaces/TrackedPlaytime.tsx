import { sortBy } from 'es-toolkit';
import {
  Box,
  Button,
  Flex,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED = 1;
const JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS = 2;

type Playtimes = Record<string, number>;

type Data = {
  failReason?: number;
  jobPlaytimes: Playtimes;
  specialPlaytimes: Playtimes;
  exemptStatus: BooleanLike;
  isAdmin: BooleanLike;
  livingTime: number;
  ghostTime: number;
  adminTime: number;
};

const sortByPlaytime = (array: [string, number][]) =>
  sortBy(array, [([_, playtime]) => -playtime]);

const PlaytimeSection = (props: { playtimes: Playtimes }) => {
  const { playtimes } = props;

  const sortedPlaytimes = sortByPlaytime(
    Object.entries(playtimes || {}).map(
      ([name, time]) => [name, Number(time) || 0] as [string, number],
    ),
  ).filter((entry) => entry[1]);

  if (!sortedPlaytimes.length) {
    return <Box>Brak zapisanego czasu gry w tej kategorii.</Box>;
  }

  const mostPlayed = sortedPlaytimes[0][1];
  return (
    <Table>
      {sortedPlaytimes.map(([jobName, playtime]) => {
        const ratio = playtime / mostPlayed;
        return (
          <Table.Row key={jobName}>
            <Table.Cell
              collapsing
              p={0.5}
              style={{
                verticalAlign: 'middle',
              }}
            >
              <Box align="right">{jobName}</Box>
            </Table.Cell>
            <Table.Cell>
              <ProgressBar maxValue={mostPlayed} value={playtime}>
                <Flex>
                  <Flex.Item width={`${ratio * 100}%`} />
                  <Flex.Item>
                    {(playtime / 60).toLocaleString(undefined, {
                      minimumFractionDigits: 1,
                      maximumFractionDigits: 1,
                    })}
                    h
                  </Flex.Item>
                </Flex>
              </ProgressBar>
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
};

export const TrackedPlaytime = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    failReason,
    jobPlaytimes,
    specialPlaytimes,
    exemptStatus,
    isAdmin,
    livingTime,
    ghostTime,
    adminTime,
  } = data;
  return (
    <Window title="Czas gry" width={550} height={650}>
      <Window.Content scrollable>
        {(failReason &&
          ((failReason === JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED && (
            <Box>Śledzenie czasu gry jest wyłączone na tym serwerze.</Box>
          )) ||
            (failReason === JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS && (
              <Box>Nie masz żadnych zapisów.</Box>
            )))) || (
          <Box>
            <Section title="Łącznie">
              <PlaytimeSection
                playtimes={{
                  Duch: ghostTime,
                  'Żywa postać': livingTime,
                  Admin: adminTime,
                }}
              />
            </Section>
            <Section
              title="Profesje"
              buttons={
                !!isAdmin && (
                  <Button.Checkbox
                    checked={!!exemptStatus}
                    onClick={() => act('toggle_exempt')}
                  >
                    Zwolnienie z wymogów czasu gry
                  </Button.Checkbox>
                )
              }
            >
              <PlaytimeSection playtimes={jobPlaytimes} />
            </Section>
            <Section title="Specjalne">
              <PlaytimeSection playtimes={specialPlaytimes} />
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
