import {
  Box,
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
  breaker: BooleanLike;
  charge_count: number;
  charging_state: number;
  emagged: BooleanLike;
  on: BooleanLike;
  operational: BooleanLike;
  theme: string;
};

export const GravityGenerator = (props) => {
  const { data } = useBackend<Data>();
  // NSV13 - theme i emagged
  const { charging_state, operational, emagged, theme } = data;
  return (
    <Window width={400} height={230} theme={theme}>
      <Window.Content>
        {!operational && <NoticeBox>Brak dostępnych danych</NoticeBox>}
        {/* NSV13 - informacja o zemagowanym generatorze */}
        {!!operational && !!emagged && (
          <NoticeBox danger>
            {'BŁĄD - GR&!%$$ %$&/(!%$) ?)!&$§ BŁĄD, #!&%# 2G'}
          </NoticeBox>
        )}
        {/* NSV13 end */}
        {!!operational && charging_state !== 0 && (
          <NoticeBox danger>UWAGA - wykryto promieniowanie</NoticeBox>
        )}
        {!!operational && charging_state === 0 && (
          <NoticeBox success>Nie wykryto promieniowania</NoticeBox>
        )}
        {!!operational && <GravityGeneratorContent />}
      </Window.Content>
    </Window>
  );
};

const GravityGeneratorContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { breaker, charge_count, charging_state, on, operational } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Zasilanie">
          <Button
            icon={breaker ? 'power-off' : 'times'}
            selected={breaker}
            disabled={!operational}
            onClick={() => act('gentoggle')}
          >
            {breaker ? 'Wł.' : 'Wył.'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Ładunek grawitacji">
          <ProgressBar
            value={charge_count / 100}
            ranges={{
              good: [0.7, Infinity],
              average: [0.3, 0.7],
              bad: [-Infinity, 0.3],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Tryb ładowania">
          {charging_state === 0 &&
            ((on && <Box color="good">W pełni naładowany</Box>) || (
              <Box color="bad">Nie ładuje</Box>
            ))}
          {charging_state === 1 && <Box color="average">Ładuje</Box>}
          {charging_state === 2 && <Box color="average">Rozładowuje</Box>}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
