// AQUILA - statystyki pacjenta w kapsule mecha medycznego
// (code/game/mecha/equipment/tools/medical_tools.dm, /sleeper). Zastępuje stare
// okno HTML "msleeper": stan zdrowia, odczynniki we krwi, wstrzykiwanie
// odczynników z działka strzykawkowego mecha.
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Reagent = {
  name: string;
  volume: number;
  ref?: string;
};

type Data = {
  patient_name: string;
  stat: number;
  health: number;
  body_temperature: number;
  brute: number;
  oxy: number;
  tox: number;
  burn: number;
  clone: BooleanLike;
  brain: BooleanLike;
  traumas: BooleanLike;
  reagents: Reagent[];
  has_syringe_gun: BooleanLike;
  available_reagents: Reagent[];
  inject_amount: number;
};

const STAT_NAMES = ['Przytomny', 'Nieprzytomny', 'Martwy'];

const T0C = 273.15;

const DamageRow = (props: { label: string; value: number }) => {
  const { label, value } = props;
  return (
    <LabeledList.Item label={label} color={value < 60 ? 'good' : 'bad'}>
      {Math.round(value * 10) / 10}%
    </LabeledList.Item>
  );
};

export const MechaSleeper = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    patient_name,
    stat,
    health,
    body_temperature,
    brute,
    oxy,
    tox,
    burn,
    clone,
    brain,
    traumas,
    has_syringe_gun,
    inject_amount,
  } = data;
  const reagents = data.reagents || [];
  const available = data.available_reagents || [];
  const dead = stat > 1;

  return (
    <Window width={400} height={560}>
      <Window.Content scrollable>
        <Section
          title={patient_name}
          buttons={
            <Button icon="eject" onClick={() => act('eject')}>
              Wyrzuć
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan" color={dead ? 'bad' : 'label'}>
              {STAT_NAMES[stat] ?? 'Nieznany'}
            </LabeledList.Item>
            <LabeledList.Item label="Zdrowie">
              {dead ? (
                <Box color="bad">*martwy*</Box>
              ) : (
                <ProgressBar
                  value={health / 100}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0, 0.5],
                    bad: [-Infinity, 0],
                  }}
                >
                  {health}%
                </ProgressBar>
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label="Temperatura ciała"
              color={body_temperature > 50 ? 'good' : 'bad'}
            >
              {Math.round((body_temperature - T0C) * 10) / 10}°C (
              {Math.round(body_temperature * 10) / 10} K)
            </LabeledList.Item>
            <DamageRow label="Obrażenia fizyczne" value={brute} />
            <DamageRow label="Niedotlenienie" value={oxy} />
            <DamageRow label="Toksyny" value={tox} />
            <DamageRow label="Oparzenia" value={burn} />
          </LabeledList>
          {!!clone && (
            <NoticeBox danger mt={1}>
              Pacjent ma uszkodzenia komórkowe.
            </NoticeBox>
          )}
          {!!brain && (
            <NoticeBox danger mt={1}>
              Wykryto poważne uszkodzenie mózgu.
            </NoticeBox>
          )}
          {!!traumas && (
            <NoticeBox danger mt={1}>
              Wykryto urazy mózgu.
            </NoticeBox>
          )}
        </Section>
        <Section title="Odczynniki we krwi">
          {reagents.length === 0 ? (
            <Box color="label">Brak.</Box>
          ) : (
            <LabeledList>
              {reagents.map((reagent) => (
                <LabeledList.Item key={reagent.name} label={reagent.name}>
                  {reagent.volume}u
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
        <Section title={`Wstrzyknij (do ${inject_amount}u)`}>
          {!has_syringe_gun ? (
            <NoticeBox>Brak działka strzykawkowego w mechu.</NoticeBox>
          ) : available.length === 0 ? (
            <Box color="label">Działko strzykawkowe jest puste.</Box>
          ) : (
            <Table>
              {available.map((reagent) => (
                <Table.Row key={reagent.ref} className="candystripe">
                  <Table.Cell>
                    {reagent.name}: {reagent.volume}u
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="syringe"
                      onClick={() => act('inject', { ref: reagent.ref })}
                    >
                      Wstrzyknij
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
