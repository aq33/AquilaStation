// AQUILA - panel sterowania antymaterią (code/modules/power/antimatter/control.dm).
// tg nie ma już silnika antymaterii, więc to własne okno w miejsce dawnego HTML.
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: BooleanLike;
  stability: number;
  shielding: number;
  cores: number;
  efficiency: number;
  core_stability: number;
  stored_power: string;
  has_jar: BooleanLike;
  fuel: number | null;
  fuel_max: number | null;
  fuel_injection: number;
};

export const AntimatterControl = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    stability,
    shielding,
    cores,
    efficiency,
    core_stability,
    stored_power,
    has_jar,
    fuel,
    fuel_max,
    fuel_injection,
  } = data;
  return (
    <Window width={400} height={420} title="Panel sterowania antymaterią">
      <Window.Content scrollable>
        <Section
          title="Reaktor"
          buttons={
            <>
              <Button icon="sync" onClick={() => act('refreshicons')}>
                Wymuś aktualizację osłon
              </Button>
              <Button
                icon="power-off"
                selected={!!active}
                onClick={() => act('togglestatus')}
              >
                {active ? 'Wtrysk' : 'Czuwanie'}
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stabilność">
              <ProgressBar
                value={stability / 100}
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.4, 0.75],
                  bad: [-Infinity, 0.4],
                }}
              >
                {stability}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Części reaktora">
              {shielding}
            </LabeledList.Item>
            <LabeledList.Item label="Rdzenie">{cores}</LabeledList.Item>
            <LabeledList.Item label="Obecna wydajność">
              {efficiency}
            </LabeledList.Item>
            <LabeledList.Item
              label="Średnia stabilność"
              buttons={
                <Button
                  icon="sync"
                  tooltip="Odśwież"
                  onClick={() => act('refreshstability')}
                />
              }
            >
              {core_stability}
            </LabeledList.Item>
            <LabeledList.Item label="Ostatnio wytworzono">
              {stored_power}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Paliwo"
          buttons={
            !!has_jar && (
              <Button icon="eject" onClick={() => act('ejectjar')}>
                Wysuń
              </Button>
            )
          }
        >
          {!has_jar ? (
            <NoticeBox>Nie wykryto pojemnika na paliwo.</NoticeBox>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Zawartość">
                <ProgressBar value={fuel || 0} maxValue={fuel_max || 1}>
                  {fuel}/{fuel_max} j.
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Wtrysk">
                <Button icon="minus" onClick={() => act('strengthdown')} />{' '}
                {fuel_injection} j.{' '}
                <Button icon="plus" onClick={() => act('strengthup')} />
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
