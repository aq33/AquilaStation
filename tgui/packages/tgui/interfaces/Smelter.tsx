// Port okna ProcessingConsole z tgstation pod naszą nazwą "Smelter"
import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Material = {
  name: string;
  id: string;
  amount: number;
  smelting: BooleanLike;
  icon?: string | null;
  icon_state?: string | null;
};

type Data = {
  on: BooleanLike;
  allowredeem: BooleanLike;
  stored_points?: number;
  materials: Material[];
  alloys: Material[];
  // AQUILA: automatyczne wyłączanie i limit arkuszy
  auto_shutdown: BooleanLike;
  smelt_amount_limit: number;
};

export const Smelter = (props) => {
  const { act, data } = useBackend<Data>();
  const { on } = data;

  return (
    <Window title="Konsola huty" width={580} height={520}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SettingsSection />
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack fill>
              <Stack.Item grow={1.2} basis={0}>
                <Section fill scrollable textAlign="center" title="Materiały">
                  <MaterialSelection />
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section fill scrollable title="Stopy" textAlign="center">
                  <AlloySelection />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrows-spin"
              iconSpin={!!on}
              color={on ? 'bad' : 'good'}
              textAlign="center"
              fontSize={1.25}
              py={1}
              fluid
              bold
              onClick={() => act('Toggle_on')}
            >
              {on ? 'Wyłącz' : 'Włącz'}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** AQUILA: ustawienia huty i odbiór punktów */
const SettingsSection = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    allowredeem,
    stored_points = 0,
    auto_shutdown,
    smelt_amount_limit,
  } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Samowyłączanie">
          <Button.Checkbox
            checked={auto_shutdown}
            onClick={() => act('toggle_auto_shutdown')}
          >
            {auto_shutdown ? 'Włączone' : 'Wyłączone'}
          </Button.Checkbox>
        </LabeledList.Item>
        <LabeledList.Item label="Zatrzymaj po">
          <NumberInput
            value={smelt_amount_limit}
            unit="ark."
            width="65px"
            minValue={1}
            maxValue={100}
            step={10}
            stepPixelSize={1}
            onChange={(value) =>
              act('set_smelt_amount', {
                amount: value,
              })
            }
          />
        </LabeledList.Item>
        {!!allowredeem && (
          <LabeledList.Item
            label="Zebrane punkty"
            buttons={
              <Button
                disabled={stored_points === 0}
                onClick={() => act('Redeem')}
              >
                Odbierz
              </Button>
            }
          >
            {stored_points}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const MaterialSelection = (props) => {
  const { act, data } = useBackend<Data>();
  const { materials = [] } = data;

  return materials.length > 0 ? (
    <Table>
      {materials.map((material) => (
        <DisplayRow
          key={material.id}
          material={material}
          amount={Math.floor(material.amount)}
          onSelect={() => act('Material', { id: material.id })}
        />
      ))}
    </Table>
  ) : (
    <NoticeBox danger>Brak materiałów w hucie!</NoticeBox>
  );
};

const AlloySelection = (props) => {
  const { act, data } = useBackend<Data>();
  const { alloys = [] } = data;

  return alloys.length > 0 ? (
    <Table>
      {alloys.map((alloy) => (
        <DisplayRow
          key={alloy.id}
          material={alloy}
          amount={Math.floor(alloy.amount)}
          onSelect={() => act('Alloy', { id: alloy.id })}
        />
      ))}
    </Table>
  ) : (
    <NoticeBox danger>Brak przepisów na stopy!</NoticeBox>
  );
};

type DisplayRowProps = {
  material: Material;
  amount?: number;
  onSelect: () => void;
};

const DisplayRow = (props: DisplayRowProps) => {
  const { material, amount, onSelect } = props;
  const { name, icon, icon_state, smelting } = material;

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsing pl={1}>
        {icon ? (
          <DmIcon
            m={1}
            width="24px"
            height="24px"
            verticalAlign="middle"
            icon={icon}
            icon_state={icon_state || ''}
            fallback={<Icon name="spinner" spin />}
          />
        ) : (
          <Icon name="circle-question" verticalAlign="middle" />
        )}
      </Table.Cell>
      <Table.Cell textAlign="left">
        {toTitleCase(name).replace('Alloy', '')}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        {amount !== undefined && (
          <Box color="label">{`${formatSiUnit(amount, 0)} ark.`}</Box>
        )}
      </Table.Cell>
      <Table.Cell collapsing pr={1} textAlign="right">
        <Button.Checkbox
          color="transparent"
          checked={smelting}
          tooltip={smelting ? 'Wytapiane' : 'Wybierz do wytapiania'}
          onClick={() => onSelect()}
        />
      </Table.Cell>
    </Table.Row>
  );
};
