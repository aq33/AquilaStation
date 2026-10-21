// NSV13 - status misji i cele (SSovermap_mode)
import { Box, Icon, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { notorietyName } from './constants';
import type { CommsConsoleData } from './types';

const STATUS_MAP = {
  0: {
    color: 'average',
    icon: 'square-o',
    statusText: 'W TOKU',
  },
  1: {
    color: 'good',
    icon: 'check-square-o',
    statusText: 'WYKONANE',
  },
  2: {
    color: 'bad',
    icon: 'window-close-o',
    statusText: 'NIEUDANE',
  },
  3: {
    color: 'good',
    icon: 'check-square-o',
    statusText: 'WYKONANE',
  },
};

export function PageObjectives(props) {
  const { data } = useBackend<CommsConsoleData>();
  const {
    announced_objectives,
    mission_briefing,
    notoriety,
    objectives = {},
  } = data;

  return (
    <Section fill scrollable title="Status misji">
      {!announced_objectives ? (
        <Box>Oczekuj na przydział zadań misji.</Box>
      ) : (
        <>
          <Box mb={1}>{mission_briefing}</Box>
          <Section title="Rozgłos">{notorietyName(notoriety)}</Section>
          <Section title="Cele">
            <Table>
              {Object.keys(objectives).map((key) => {
                const objective = objectives[key];
                const status = STATUS_MAP[objective.status] || STATUS_MAP[0];
                return (
                  <Table.Row key={key}>
                    <Table.Cell collapsing>
                      <Icon name={status.icon} mx={0.5} />
                    </Table.Cell>
                    <Table.Cell collapsing color={status.color} px={0.5} nowrap>
                      {status.statusText}
                    </Table.Cell>
                    <Table.Cell px={0.5}>{objective.brief}</Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Section>
        </>
      )}
    </Section>
  );
}
