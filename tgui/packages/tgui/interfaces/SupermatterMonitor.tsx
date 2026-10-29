import { sortBy } from 'es-toolkit';
import { type ReactNode, useState } from 'react';
import {
  Button,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

type Gas = {
  id: string;
  name: string;
  amount: number;
};

type SupermatterListEntry = {
  uid: number;
  area_name: string;
  integrity: number;
};

type Data = {
  SM_ambientpressure: number;
  SM_ambienttemp: number;
  SM_bad_moles_amount: number;
  SM_integrity: number;
  SM_moles: number;
  SM_power: number;
  SM_radiation: number;
  active: BooleanLike;
  gases: Gas[];
  standalone_mode: BooleanLike;
  supermatters: SupermatterListEntry[];
};

const logScale = (value) => Math.log2(16 + Math.max(0, value)) - 4;

export const SupermatterMonitor = () => {
  return (
    <Window width={700} height={400} theme="ntos" title="Monitor supermaterii">
      <Window.Content>
        <SupermatterMonitorContent />
      </Window.Content>
    </Window>
  );
};

// Wiersz w stylu LabeledList, jak w oknie Supermatter z tg
type SupermatterEntryProps = {
  title: string;
  content: ReactNode;
};

const SupermatterEntry = (props: SupermatterEntryProps) => {
  const { title, content } = props;
  return (
    <Stack.Item>
      <Stack align="center">
        <Stack.Item color="grey" width="125px">
          {`${title}:`}
        </Stack.Item>
        <Stack.Item grow>{content}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const SupermatterMonitorContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    standalone_mode,
    SM_integrity,
    SM_power,
    SM_ambienttemp,
    SM_ambientpressure,
    SM_radiation,
    SM_moles,
    SM_bad_moles_amount,
  } = data;
  const [allGasActive, setAllGasActive] = useState(false);
  if (!active) {
    return <SupermatterList />;
  }
  let gases = data.gases || [];
  if (!allGasActive) {
    gases = gases.filter((gas) => gas.amount >= 0.01);
  }
  gases = sortBy(gases, [(gas) => -gas.amount]);

  return (
    <Stack height="100%">
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Parametry"
          buttons={
            !standalone_mode && (
              <Button icon="arrow-left" onClick={() => act('PRG_clear')}>
                Wróć
              </Button>
            )
          }
        >
          <Stack vertical>
            <SupermatterEntry
              title="Integralność"
              content={
                <ProgressBar
                  value={SM_integrity / 100}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.5, 0.9],
                    bad: [-Infinity, 0.5],
                  }}
                >
                  {`${toFixed(SM_integrity, 2)} %`}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Względna EER"
              content={
                <ProgressBar
                  value={SM_power}
                  minValue={0}
                  maxValue={5000}
                  ranges={{
                    good: [-Infinity, 5000],
                    average: [5000, 7000],
                    bad: [7000, Infinity],
                  }}
                >
                  {`${toFixed(SM_power)} MeV/cm3`}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Promieniowanie"
              content={
                <ProgressBar
                  value={SM_radiation}
                  minValue={0}
                  maxValue={7000}
                  ranges={{
                    // The threshold where enough radiation gets to the
                    // collectors to start generating power. Experimentally
                    // determined, because radiation waves are inscrutable.
                    grey: [-Infinity, 320],
                    good: [320, 5000],
                    average: [5000, 7000],
                    bad: [7000, Infinity],
                  }}
                >
                  {`${toFixed(SM_radiation)} Sv/h`}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Temperatura"
              content={
                <ProgressBar
                  value={logScale(SM_ambienttemp)}
                  minValue={0}
                  maxValue={logScale(10000)}
                  ranges={{
                    teal: [-Infinity, logScale(80)],
                    good: [logScale(80), logScale(373)],
                    average: [logScale(373), logScale(1000)],
                    bad: [logScale(1000), Infinity],
                  }}
                >
                  {`${toFixed(SM_ambienttemp, 2)} K`}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Łącznie moli"
              content={
                <ProgressBar
                  value={logScale(SM_moles)}
                  minValue={0}
                  maxValue={logScale(50000)}
                  ranges={{
                    good: [-Infinity, logScale(SM_bad_moles_amount * 0.75)],
                    average: [
                      logScale(SM_bad_moles_amount * 0.75),
                      logScale(SM_bad_moles_amount),
                    ],
                    bad: [logScale(SM_bad_moles_amount), Infinity],
                  }}
                >
                  {`${toFixed(SM_moles, 2)} mol`}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Ciśnienie"
              content={
                <ProgressBar
                  value={logScale(SM_ambientpressure)}
                  minValue={0}
                  maxValue={logScale(50000)}
                  ranges={{
                    good: [logScale(1), logScale(300)],
                    average: [-Infinity, logScale(1000)],
                    bad: [logScale(1000), +Infinity],
                  }}
                >
                  {`${toFixed(SM_ambientpressure)} kPa`}
                </ProgressBar>
              }
            />
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Gazy"
          buttons={
            <Button
              icon={allGasActive ? 'times' : 'book-open'}
              onClick={() => setAllGasActive(!allGasActive)}
            >
              {allGasActive ? 'Ukryj gazy' : 'Pokaż wszystkie gazy'}
            </Button>
          }
        >
          <Stack vertical>
            {gases.map((gas) => (
              <SupermatterEntry
                key={gas.name}
                title={getGasLabel(gas.id, gas.name)}
                content={
                  <ProgressBar
                    color={getGasColor(gas.id)}
                    value={gas.amount}
                    minValue={0}
                    maxValue={100}
                  >
                    {`${toFixed(gas.amount, 2)}%`}
                  </ProgressBar>
                }
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const SupermatterList = (props) => {
  const { act, data } = useBackend<Data>();
  const { supermatters = [] } = data;
  return (
    <Section
      fill
      scrollable
      title="Wykryte supermaterie"
      buttons={
        <Button icon="sync" onClick={() => act('PRG_refresh')}>
          Odśwież
        </Button>
      }
    >
      <Table>
        {supermatters.map((sm) => (
          <Table.Row key={sm.uid}>
            <Table.Cell>{`${sm.uid}. ${sm.area_name}`}</Table.Cell>
            <Table.Cell collapsing color="label">
              Integralność:
            </Table.Cell>
            <Table.Cell collapsing width="120px">
              <ProgressBar
                value={sm.integrity / 100}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }}
              />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() =>
                  act('PRG_set', {
                    target: sm.uid,
                  })
                }
              >
                Szczegóły
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
