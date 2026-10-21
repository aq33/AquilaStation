import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { GenericUplink, type Item } from './Uplink/GenericUplink';

type AbductorConsoleData = {
  categories: { name: string; items: ConsoleItem[] | null }[];

  compactMode: BooleanLike;
  experiment: BooleanLike;
  points?: number;
  credits?: number;
  pad: BooleanLike;
  gizmo: BooleanLike;
  vest: BooleanLike;
  vest_mode?: number;
  vest_lock?: BooleanLike;
};

type ConsoleItem = {
  name: string;
  cost: number;
  desc: string;
  icon: string;
  icon_state: string;
};

export const AbductorConsole = (props) => {
  const [tab, setTab] = useSharedState('tab', 1);

  return (
    <Window theme="abductor" width={600} height={532}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}
          >
            Abductsoft 3000
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}
          >
            Ustawienia misji
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <Abductsoft />}
        {tab === 2 && (
          <>
            <EmergencyTeleporter />
            <VestSettings />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const Abductsoft = (props) => {
  const { act, data } = useBackend<AbductorConsoleData>();
  const { experiment, points, credits, categories = [], compactMode } = data;

  if (!experiment) {
    return <NoticeBox danger>Nie wykryto maszyny do eksperymentów</NoticeBox>;
  }

  const categoriesList: string[] = [];
  const items: Item[] = [];
  for (let i = 0; i < categories.length; i++) {
    const category = categories[i];
    categoriesList.push(category.name);
    const categoryItems = category.items || [];
    for (let itemIndex = 0; itemIndex < categoryItems.length; itemIndex++) {
      const item = categoryItems[itemIndex];
      items.push({
        id: item.name,
        name: item.name,
        category: category.name,
        cost: `${item.cost} kr.`,
        desc: item.desc,
        disabled: (credits || 0) < item.cost,
        icon: item.icon,
        icon_state: item.icon_state,
        population_tooltip: '',
        insufficient_population: false,
      });
    }
  }

  return (
    <>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Zebrane próbki">{points}</LabeledList.Item>
        </LabeledList>
      </Section>
      <Box height="400px">
        <GenericUplink
          currency={`${credits || 0} kredytów`}
          categories={categoriesList}
          items={items}
          compactMode={compactMode}
          onCompactToggle={() => act('compact_toggle')}
          handleBuy={(item) => act('buy', { name: item.name })}
        />
      </Box>
    </>
  );
};

const EmergencyTeleporter = (props) => {
  const { act, data } = useBackend<AbductorConsoleData>();
  const { pad, gizmo } = data;

  if (!pad) {
    return <NoticeBox danger>Nie wykryto telepadu</NoticeBox>;
  }

  return (
    <Section
      title="Teleport awaryjny"
      buttons={
        <Button
          icon="exclamation-circle"
          color="bad"
          onClick={() => act('teleporter_send')}
        >
          Aktywuj
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Ściągnięcie oznaczonego">
          <Button
            icon={gizmo ? 'user-plus' : 'user-slash'}
            disabled={!gizmo}
            onClick={() => act('teleporter_retrieve')}
          >
            {gizmo ? 'Ściągnij' : 'Brak oznaczenia'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const VestSettings = (props) => {
  const { act, data } = useBackend<AbductorConsoleData>();
  const { vest, vest_mode, vest_lock } = data;

  if (!vest) {
    return <NoticeBox danger>Nie wykryto kamizelki agenta</NoticeBox>;
  }

  return (
    <Section
      title="Ustawienia kamizelki agenta"
      buttons={
        <Button
          icon={vest_lock ? 'lock' : 'unlock'}
          onClick={() => act('toggle_vest')}
        >
          {vest_lock ? 'Zablokowana' : 'Odblokowana'}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Tryb">
          <Button
            icon={vest_mode === 1 ? 'eye-slash' : 'fist-raised'}
            onClick={() => act('flip_vest')}
          >
            {vest_mode === 1 ? 'Skradanie' : 'Walka'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Przebranie">
          <Button icon="user-secret" onClick={() => act('select_disguise')}>
            Wybierz
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
