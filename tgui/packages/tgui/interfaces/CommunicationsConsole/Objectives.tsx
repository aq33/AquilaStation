// NSV13 - status misji i cele (SSovermap_mode)
import { Box, Button, Icon, Section, Table } from 'tgui-core/components';

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
  const { act, data } = useBackend<CommsConsoleData>();
  const {
    announced_objectives,
    mission_briefing,
    notoriety,
    objectives = {},
    mission_choices = [],
    mission_choice_seconds = 0,
    can_choose_mission,
  } = data;

  return (
    <Section fill scrollable title="Status misji">
      {mission_choices.length > 0 ? (
        <>
          <Box mb={1}>
            Dowództwo floty przydzieliło trzy misje. Kapitan wybiera jedną z
            nich. Za {mission_choice_seconds} s zostanie przyjęta pierwsza.
          </Box>
          {!can_choose_mission && (
            <Box mb={1} color="average">
              Misję może wybrać tylko kapitan (dostęp kapitana).
            </Box>
          )}
          {mission_choices.map((choice, index) => (
            <Section
              key={choice.id}
              title={index === 0 ? `${choice.name} (domyślna)` : choice.name}
              buttons={
                <Button
                  icon="check"
                  disabled={!can_choose_mission}
                  onClick={() => act('chooseMission', { id: choice.id })}
                >
                  Wybierz
                </Button>
              }
            >
              {choice.brief}
            </Section>
          ))}
        </>
      ) : !announced_objectives ? (
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
