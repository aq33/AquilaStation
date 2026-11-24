// AQUILA - okno NIF (Nanitowa Platforma Implantów), przepisane z NifPanel.jsx z Monkestation (pierwotnie Skyrat/Nova)
// Bez przełącznika „zachowaj NIFSoft między rundami” i punktów nagród.
import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Nifsoft = {
  name: string;
  desc: string;
  active: BooleanLike;
  active_mode: BooleanLike;
  activation_cost: number;
  active_cost: number;
  reference: string;
  ui_icon: string;
};

type Data = {
  linked_mob_name: string;
  current_theme: string;
  power_level: number;
  power_usage: number;
  nutrition_drain: BooleanLike;
  nutrition_level: number;
  minimum_nutrition: number;
  blood_level: number;
  blood_drain: BooleanLike;
  minimum_blood_level: number;
  durability: number;
  examine_text: string;
  loaded_nifsofts: Nifsoft[];
  ui_themes: string[];
  max_nifsofts: number;
  max_durability: number;
  max_power: number;
  max_blood_level: number;
  product_notes: string;
};

const percent = (value: number, max: number) =>
  Math.round((value / max) * 1000) / 10;

export const NifPanel = (props) => {
  const { data } = useBackend<Data>();
  const { linked_mob_name, loaded_nifsofts = [], max_nifsofts } = data;
  const { current_theme } = data;
  const [settingsOpen, setSettingsOpen] = useState(false);

  return (
    <Window
      title="Nanitowa Platforma Implantów"
      width={500}
      height={450}
      theme={current_theme === 'default' ? undefined : current_theme}
    >
      <Window.Content scrollable>
        <Section
          title={`Witaj w swoim NIF-ie, ${linked_mob_name}`}
          buttons={
            <Button
              icon="cogs"
              tooltip="Ustawienia NIF"
              tooltipPosition="bottom-end"
              selected={settingsOpen}
              onClick={() => setSettingsOpen(!settingsOpen)}
            />
          }
        >
          {settingsOpen ? <NifSettings /> : <NifStats />}
        </Section>
        {settingsOpen ? (
          <Section title="O produkcie">
            <NifProductNotes />
          </Section>
        ) : (
          <Section
            title={`Programy NIFSoft (wolne miejsca: ${
              max_nifsofts - loaded_nifsofts.length
            })`}
          >
            {loaded_nifsofts.length ? (
              <Stack vertical>
                {loaded_nifsofts.map((nifsoft) => (
                  <Stack.Item key={nifsoft.reference}>
                    <NifsoftEntry nifsoft={nifsoft} />
                  </Stack.Item>
                ))}
              </Stack>
            ) : (
              <NoticeBox>Nie masz zainstalowanych NIFSoftów.</NoticeBox>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const NifsoftEntry = (props: { nifsoft: Nifsoft }) => {
  const { act, data } = useBackend<Data>();
  const { max_power } = data;
  const { nifsoft } = props;

  return (
    <Collapsible
      title={
        <>
          <Icon name={nifsoft.ui_icon} /> {nifsoft.name}
        </>
      }
      color={nifsoft.active ? 'good' : undefined}
      buttons={
        <Button
          icon={nifsoft.active ? 'stop' : 'play'}
          color={nifsoft.active ? 'red' : 'green'}
          tooltip={nifsoft.active ? 'Wyłącz' : 'Uruchom'}
          onClick={() =>
            act('activate_nifsoft', { activated_nifsoft: nifsoft.reference })
          }
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Koszt uruchomienia">
          {nifsoft.activation_cost === 0
            ? 'Brak'
            : `${percent(nifsoft.activation_cost, max_power)}% energii`}
        </LabeledList.Item>
        <LabeledList.Item label="Zużycie w działaniu">
          {nifsoft.active_cost === 0
            ? 'Brak'
            : `${percent(nifsoft.active_cost, max_power)}% energii na cykl`}
        </LabeledList.Item>
        {!!nifsoft.active_mode && (
          <LabeledList.Item label="Stan">
            <Box color={nifsoft.active ? 'good' : 'bad'}>
              {nifsoft.active ? 'Włączony' : 'Wyłączony'}
            </Box>
          </LabeledList.Item>
        )}
      </LabeledList>
      <BlockQuote mt={1}>{nifsoft.desc}</BlockQuote>
      <Button.Confirm
        mt={1}
        icon="trash"
        color="red"
        fluid
        tooltip="Odinstaluj ten NIFSoft"
        confirmContent="Na pewno?"
        confirmIcon="question"
        onClick={() =>
          act('uninstall_nifsoft', { nifsoft_to_remove: nifsoft.reference })
        }
      >
        Odinstaluj
      </Button.Confirm>
    </Collapsible>
  );
};

const NifSettings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    nutrition_drain,
    ui_themes = [],
    current_theme,
    nutrition_level,
    minimum_nutrition,
    blood_drain,
    minimum_blood_level,
    blood_level,
    examine_text,
  } = data;

  return (
    <LabeledList>
      <LabeledList.Item label="Motyw okna">
        <Dropdown
          width="100%"
          selected={current_theme}
          options={ui_themes}
          onSelected={(value) => act('change_theme', { target_theme: value })}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Opis przy oględzinach">
        <Input
          fluid
          value={examine_text}
          placeholder="Co widzą inni, gdy cię oglądają"
          onBlur={(value) => act('change_examine_text', { new_text: value })}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Zasilanie z jedzenia">
        <Button
          fluid
          selected={!!nutrition_drain}
          tooltip="NIF czerpie energię z tego, co jesz. Szybciej robisz się głodny."
          onClick={() => act('toggle_nutrition_drain')}
          disabled={!nutrition_drain && nutrition_level <= minimum_nutrition}
        >
          {nutrition_drain ? 'Włączone' : 'Wyłączone'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Zasilanie z krwi">
        <Button
          fluid
          selected={!!blood_drain}
          tooltip="NIF pobiera krew na energię. Wyłącza się sam, zanim krwi zrobi się niebezpiecznie mało."
          onClick={() => act('toggle_blood_drain')}
          disabled={!blood_drain && blood_level <= minimum_blood_level}
        >
          {blood_drain ? 'Włączone' : 'Wyłączone'}
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
};

const NifProductNotes = (props) => {
  const { data } = useBackend<Data>();
  const { product_notes } = data;
  return <BlockQuote>{product_notes}</BlockQuote>;
};

const NifStats = (props) => {
  const { data } = useBackend<Data>();
  const {
    max_power,
    power_level,
    durability,
    power_usage,
    nutrition_drain,
    nutrition_level,
    blood_drain,
    blood_level,
    minimum_blood_level,
    max_blood_level,
    max_durability,
  } = data;

  return (
    <LabeledList>
      <LabeledList.Item label="Stan NIF-u">
        <ProgressBar
          value={durability}
          minValue={0}
          maxValue={max_durability}
          ranges={{
            good: [max_durability * 0.66, Infinity],
            average: [max_durability * 0.33, max_durability * 0.66],
            bad: [-Infinity, max_durability * 0.33],
          }}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Energia">
        <ProgressBar
          value={power_level}
          minValue={0}
          maxValue={max_power}
          ranges={{
            good: [max_power * 0.66, Infinity],
            average: [max_power * 0.33, max_power * 0.66],
            bad: [-Infinity, max_power * 0.33],
          }}
        >
          {`${percent(power_level, max_power)}% (zużycie ${percent(
            power_usage,
            max_power,
          )}% na cykl)`}
        </ProgressBar>
      </LabeledList.Item>
      {!!nutrition_drain && (
        <LabeledList.Item label="Odżywienie">
          <ProgressBar
            value={nutrition_level}
            minValue={0}
            maxValue={550}
            ranges={{
              good: [250, Infinity],
              average: [150, 250],
              bad: [-Infinity, 150],
            }}
          />
        </LabeledList.Item>
      )}
      {!!blood_drain && (
        <LabeledList.Item label="Krew">
          <ProgressBar
            value={blood_level}
            minValue={0}
            maxValue={max_blood_level}
            ranges={{
              good: [minimum_blood_level, Infinity],
              average: [336, minimum_blood_level],
              bad: [-Infinity, 336],
            }}
          />
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};
