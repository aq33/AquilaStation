import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ability = {
  ref: string;
  name: string;
  cost: number;
  required_total_points: number;
  category: string;
  short_desc: string;
  long_desc: string;
  stat_block: string;
  threshold_block: string;
};

type AbilityState = {
  purchased: BooleanLike;
  can_act: BooleanLike;
};

type Host = {
  ref: string;
  name: string;
  following: BooleanLike;
};

type Data = {
  resistance: number;
  stealth: number;
  stage_rate: number;
  transmission: number;
  cure_text: string;
  points: number;
  total_points: number;
  abilities: Ability[];
  ability_states: Record<string, AbilityState>;
  hosts: Host[];
};

const CATEGORY_NAMES: Record<string, string> = {
  Active: 'Aktywna',
  Symptom: 'Objaw',
  'Symptom (Weak)': 'Objaw (słaby)',
  'Symptom (+)': 'Objaw (+)',
  'Symptom (Strong)': 'Objaw (silny)',
  'Symptom (Strong+)': 'Objaw (silny+)',
};

export const SentientDiseaseMenu = (props) => {
  const { data } = useBackend<Data>();
  const { abilities = [] } = data;
  const [examined, setExamined] = useState<string | null>(null);
  const examinedAbility = abilities.find((ability) => ability.ref === examined);

  return (
    <Window width={1000} height={770}>
      <Window.Content scrollable>
        {examinedAbility ? (
          <AbilityDetails
            ability={examinedAbility}
            onBack={() => setExamined(null)}
          />
        ) : (
          <MainMenu onExamine={setExamined} />
        )}
      </Window.Content>
    </Window>
  );
};

const PurchaseButton = (props: { ability: Ability }) => {
  const { act, data } = useBackend<Data>();
  const { ability } = props;
  const state = data.ability_states?.[ability.ref];
  if (!state) {
    return null;
  }
  return state.purchased ? (
    <Button
      icon="undo"
      color="bad"
      disabled={!state.can_act}
      onClick={() => act('refund_ability', { ref: ability.ref })}
    >
      Zwróć
    </Button>
  ) : (
    <Button
      icon="dna"
      disabled={!state.can_act}
      onClick={() => act('buy_ability', { ref: ability.ref })}
    >
      Kup
    </Button>
  );
};

const AbilityDetails = (props: { ability: Ability; onBack: () => void }) => {
  const { ability, onBack } = props;
  return (
    <Section
      title={ability.name}
      buttons={
        <Stack>
          <Stack.Item>
            <PurchaseButton ability={ability} />
          </Stack.Item>
          <Stack.Item>
            <Button icon="arrow-left" onClick={onBack}>
              Wróć
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Koszt">{ability.cost}</LabeledList.Item>
        <LabeledList.Item label="Wymagane punkty łącznie">
          {ability.required_total_points}
        </LabeledList.Item>
        <LabeledList.Item label="Rodzaj">
          {CATEGORY_NAMES[ability.category] || ability.category}
        </LabeledList.Item>
      </LabeledList>
      <Box
        mt={1}
        dangerouslySetInnerHTML={{
          __html:
            ability.stat_block + ability.long_desc + ability.threshold_block,
        }}
      />
    </Section>
  );
};

const MainMenu = (props: { onExamine: (ref: string) => void }) => {
  const { act, data } = useBackend<Data>();
  const { abilities = [], hosts = [], ability_states = {} } = data;

  return (
    <>
      <Section title="Statystyki choroby">
        <LabeledList>
          <LabeledList.Item label="Odporność">
            {data.resistance}
          </LabeledList.Item>
          <LabeledList.Item label="Skrytość">{data.stealth}</LabeledList.Item>
          <LabeledList.Item label="Szybkość postępu">
            {data.stage_rate}
          </LabeledList.Item>
          <LabeledList.Item label="Zaraźliwość">
            {data.transmission}
          </LabeledList.Item>
          <LabeledList.Item label="Lekarstwo">
            {data.cure_text}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title={`Adaptacje — punkty: ${data.points} / ${data.total_points}`}
      >
        <Table>
          <Table.Row header>
            <Table.Cell collapsing>Koszt</Table.Cell>
            <Table.Cell collapsing />
            <Table.Cell collapsing>Próg</Table.Cell>
            <Table.Cell width="180px">Nazwa</Table.Cell>
            <Table.Cell collapsing>Rodzaj</Table.Cell>
            <Table.Cell>Opis</Table.Cell>
          </Table.Row>
          {abilities.map((ability) => (
            <Table.Row key={ability.ref} className="candystripe">
              <Table.Cell collapsing textAlign="center">
                {ability.cost}
              </Table.Cell>
              <Table.Cell collapsing>
                <PurchaseButton ability={ability} />
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                {ability.required_total_points}
              </Table.Cell>
              <Table.Cell>
                <Button
                  fluid
                  selected={!!ability_states[ability.ref]?.purchased}
                  onClick={() => props.onExamine(ability.ref)}
                >
                  {ability.name}
                </Button>
              </Table.Cell>
              <Table.Cell collapsing>
                {CATEGORY_NAMES[ability.category] || ability.category}
              </Table.Cell>
              <Table.Cell>
                <Box dangerouslySetInnerHTML={{ __html: ability.short_desc }} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <NoticeBox info mt={1}>
          Zarażaj wielu nosicieli naraz, by zdobywać punkty adaptacji.
        </NoticeBox>
      </Section>
      <Section title="Zarażeni nosiciele">
        {hosts.length === 0 ? (
          <Box color="label">Brak nosicieli.</Box>
        ) : (
          hosts.map((host) => (
            <Button
              key={host.ref}
              icon="eye"
              selected={!!host.following}
              onClick={() => act('follow_instance', { ref: host.ref })}
            >
              {host.name}
            </Button>
          ))
        )}
      </Section>
    </>
  );
};
