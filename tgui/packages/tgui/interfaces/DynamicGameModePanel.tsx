// AQUILA - panel trybu dynamicznego dla adminów (dawniej okno HTML w code/game/gamemodes/dynamic/dynamic.dm).
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Rule = {
  type: string;
  name: string;
};

type Data = {
  round_started: BooleanLike;
  threat_level: number;
  roundstart_budget: number;
  midround_budget_total: number;
  mid_round_budget: number;
  threat_curve_centre: number;
  threat_curve_width: number;
  lowpop_reduction_threshold: number;
  lowpop_reduction_coeff: number;
  split_curve_centre: number;
  split_curve_width: number;
  peaceful_percentage: number;
  forced_extended: BooleanLike;
  no_stacking: BooleanLike;
  stacking_limit: number;
  forced_latejoin_rule: string | null;
  executed_rules: Rule[];
  heavy_midround_chance: number;
  latejoin_time_left: number;
  midrounds_exhausted: BooleanLike;
  midround_time_left: number | null;
  threat_log: string[];
};

// Czas w dziesiątych częściach sekundy
const formatTime = (deciseconds: number) => {
  const seconds = Math.round(deciseconds / 10);
  if (seconds >= 60) {
    return `${Math.floor(seconds / 60)} min ${seconds % 60} s`;
  }
  return `${seconds} s`;
};

const round = (value: number) => Math.round(value * 100) / 100;

export const DynamicGameModePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { executed_rules = [], threat_log = [] } = data;

  return (
    <Window width={520} height={640}>
      <Window.Content scrollable>
        <Section
          title="Tryb dynamiczny"
          buttons={
            <Button icon="search" onClick={() => act('vv')}>
              VV
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Poziom zagrożenia">
              <Box bold>{round(data.threat_level)}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Budżety (start/w trakcie)">
              <Box bold>
                {round(data.roundstart_budget)} /{' '}
                {round(data.midround_budget_total)}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              label="Budżet do wydania"
              buttons={
                <Button icon="sliders-h" onClick={() => act('adjustthreat')}>
                  Zmień
                </Button>
              }
            >
              <Box bold>{round(data.mid_round_budget)}</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Parametry">
          <LabeledList>
            <LabeledList.Item label="Krzywa zagrożenia">
              środek = {data.threat_curve_centre}; szerokość ={' '}
              {data.threat_curve_width}
            </LabeledList.Item>
            <LabeledList.Item label="Redukcja przy niskiej populacji">
              próg = {data.lowpop_reduction_threshold}; współczynnik ={' '}
              {data.lowpop_reduction_coeff}
            </LabeledList.Item>
            <LabeledList.Item label="Krzywa podziału">
              środek = {data.split_curve_centre}; szerokość ={' '}
              {data.split_curve_width}
            </LabeledList.Item>
          </LabeledList>
          <Box italic mt={1}>
            Średnio {round(data.peaceful_percentage)}% rund jest
            spokojniejszych.
          </Box>
        </Section>
        <Section title="Ustawienia">
          <LabeledList>
            <LabeledList.Item label="Wymuszony extended">
              <Button.Checkbox
                checked={!!data.forced_extended}
                onClick={() => act('forced_extended')}
              >
                {data.forced_extended ? 'Wł.' : 'Wył.'}
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label="Bez kumulacji (jeden kończący rundę)">
              <Button.Checkbox
                checked={!!data.no_stacking}
                onClick={() => act('no_stacking')}
              >
                {data.no_stacking ? 'Wł.' : 'Wył.'}
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item
              label="Limit kumulacji"
              buttons={
                <Button icon="sliders-h" onClick={() => act('stacking_limit')}>
                  Zmień
                </Button>
              }
            >
              {data.stacking_limit}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Wykonane zestawy zasad">
          {executed_rules.length === 0 ? (
            <Box color="label">Brak.</Box>
          ) : (
            executed_rules.map((rule, i) => (
              <Box key={i}>
                {rule.type} — <b>{rule.name}</b>
              </Box>
            ))
          )}
        </Section>
        <Section
          title={`Wstrzyknięcia (szansa na ciężki midround: ${data.heavy_midround_chance}%)`}
        >
          <LabeledList>
            <LabeledList.Item
              label="Latejoin"
              buttons={
                <Button icon="bolt" onClick={() => act('injectlate')}>
                  Teraz!
                </Button>
              }
            >
              {formatTime(data.latejoin_time_left)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Midround"
              buttons={
                !data.midrounds_exhausted && (
                  <Button icon="bolt" onClick={() => act('injectmid')}>
                    Teraz!
                  </Button>
                )
              }
            >
              {data.midrounds_exhausted || data.midround_time_left === null
                ? 'Wszystkie midroundy zostały wyczerpane.'
                : formatTime(data.midround_time_left)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Wymuszona reguła latejoin"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="user-plus"
                      onClick={() => act('force_latejoin_rule')}
                    >
                      Ustaw
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="bad"
                      disabled={!data.forced_latejoin_rule}
                      onClick={() => act('clear_forced_latejoin')}
                    >
                      Wyczyść
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              {data.forced_latejoin_rule || 'brak'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Reguła midround"
              buttons={
                <Button
                  icon="play"
                  color="caution"
                  onClick={() => act('force_midround_rule')}
                >
                  Wykonaj teraz
                </Button>
              }
            />
          </LabeledList>
        </Section>
        <Section>
          <Collapsible title="Dziennik zagrożenia">
            {!data.round_started ? (
              <NoticeBox>Runda jeszcze się nie zaczęła.</NoticeBox>
            ) : (
              <>
                <Box bold>
                  Zagrożenie na starcie: {round(data.threat_level)}
                </Box>
                {threat_log.map((entry, i) => (
                  <Box key={i}>{entry}</Box>
                ))}
                <Box bold mt={1}>
                  Pozostałe zagrożenie / poziom zagrożenia:{' '}
                  {round(data.mid_round_budget)} / {round(data.threat_level)}
                </Box>
              </>
            )}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};
