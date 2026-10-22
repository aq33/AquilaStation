import {
  Box,
  Button,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  total_assigned_cpu: number;
  total_cpu: number;
  total_ram: number;
  total_assigned_ram: number;
  authenticated: BooleanLike;
  username: string;
  has_access: BooleanLike;
  human_only: BooleanLike;
  ais: AiData[];
};

type AiData = {
  name: string;
  ref: string;
  assigned_cpu: number;
  assigned_ram: number;
};

const percent = (value: number, total: number) =>
  total ? toFixed((value / total) * 100) : '0';

export const AiResources = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    total_assigned_cpu,
    total_cpu,
    total_ram,
    total_assigned_ram,
    authenticated,
    username,
    has_access,
    human_only,
    ais = [],
  } = data;

  const remaining_cpu = total_cpu - total_assigned_cpu;
  const remaining_ram = total_ram - total_assigned_ram;

  return (
    <Window
      width={450}
      height={authenticated ? 450 : 250}
      title="Przydział zasobów SI"
    >
      <Window.Content>
        {(!!authenticated && (
          <Stack vertical fill>
            <Stack.Item>
              <Section
                title="Wolne CPU w chmurze"
                buttons={
                  <>
                    <Button
                      icon="male"
                      color={human_only ? 'bad' : 'good'}
                      onClick={() => act('toggle_human_status')}
                      tooltip={
                        human_only
                          ? 'Pozwoli syntetykom korzystać z konsoli.'
                          : 'Zabroni syntetykom korzystać z konsoli.'
                      }
                    >
                      {human_only ? 'Wpuść syntetyki' : 'Zablokuj syntetyki'}
                    </Button>
                    <Button
                      icon="sign-out-alt"
                      color="bad"
                      onClick={() => act('log_out')}
                    >
                      Wyloguj
                    </Button>
                  </>
                }
              >
                <ProgressBar
                  value={remaining_cpu}
                  ranges={{
                    good: [total_cpu * 0.8, Infinity],
                    average: [total_cpu * 0.4, total_cpu * 0.8],
                    bad: [-Infinity, total_cpu * 0.4],
                  }}
                  maxValue={total_cpu}
                >
                  {toFixed(remaining_cpu)}/{toFixed(total_cpu)} THz (
                  {percent(remaining_cpu, total_cpu)}%)
                </ProgressBar>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Wolny RAM w chmurze">
                <ProgressBar
                  ranges={{
                    good: [total_ram * 0.8, Infinity],
                    average: [total_ram * 0.4, total_ram * 0.8],
                    bad: [-Infinity, total_ram * 0.4],
                  }}
                  value={remaining_ram}
                  maxValue={total_ram}
                >
                  {toFixed(remaining_ram)}/{toFixed(total_ram)} TB (
                  {percent(remaining_ram, total_ram)}%)
                </ProgressBar>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable title="Aktywne SI">
                {ais.length === 0 && (
                  <Box color="label">Brak aktywnych SI.</Box>
                )}
                {ais.map((ai) => (
                  <Section
                    key={ai.ref}
                    title={ai.name}
                    buttons={
                      <Button
                        icon="trash"
                        onClick={() =>
                          act('clear_ai_resources', { targetAI: ai.ref })
                        }
                      >
                        Zwolnij zasoby
                      </Button>
                    }
                  >
                    <Box mb={0.5}>Przydział CPU:</Box>
                    <Slider
                      minValue={0}
                      maxValue={total_cpu}
                      step={0.1}
                      stepPixelSize={1}
                      format={(value) => toFixed(value, 1)}
                      value={ai.assigned_cpu}
                      unit="THz"
                      onChange={(_, value) =>
                        act('set_cpu', {
                          targetAI: ai.ref,
                          amount_cpu: value,
                        })
                      }
                    />
                    <Box mt={1} mb={0.5}>
                      Przydział RAM:
                    </Box>
                    <Slider
                      minValue={0}
                      maxValue={total_ram}
                      step={1}
                      stepPixelSize={1}
                      value={ai.assigned_ram}
                      unit="TB"
                      onChange={(_, value) =>
                        act('set_ram', {
                          targetAI: ai.ref,
                          amount_ram: value,
                        })
                      }
                    />
                  </Section>
                ))}
              </Section>
            </Stack.Item>
          </Stack>
        )) || (
          <Section title="Witaj" fill>
            <Box textAlign="center" fontSize="18px" bold my={1}>
              <Icon
                name="user-circle"
                verticalAlign="middle"
                size={4.5}
                mr="1rem"
              />
              {username || 'Nieznany'}
            </Box>
            <NoticeBox
              textAlign="center"
              mt="1.5rem"
              color={has_access ? 'good' : 'bad'}
            >
              {has_access ? 'Dostęp przyznany' : 'Brak dostępu'}
            </NoticeBox>
            <Button
              icon="sign-in-alt"
              color={has_access ? 'good' : 'bad'}
              fluid
              textAlign="center"
              onClick={() => act('log_in')}
            >
              Zaloguj
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
