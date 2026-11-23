// AQUILA: port tgstation/tgstation#83836 (Flatpacker.tsx) z listą schematów z bazy sieci badań
import {
  Box,
  Button,
  Dimmer,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialIcon } from './Fabrication/MaterialIcon';
import { formatSheets, type Material } from './Fabrication/Types';

type Cost = {
  name: string;
  amount: number;
};

type ManualPart = {
  name: string;
  have: number;
  need: number;
};

type Design = {
  name: string;
  tier: number;
  illegal: BooleanLike;
  icon: string;
  icon_state: string;
  requiredMaterials: Cost[];
  manual: ManualPart[];
  disableReason: string;
};

type Schematic = {
  key: string;
  name: string;
  tier: number;
  illegal: BooleanLike;
};

type Data = {
  materials: Material[];
  busy: BooleanLike;
  maxTier: number;
  efficiency: number;
  emagged: BooleanLike;
  boardInserted: BooleanLike;
  selected: string | null;
  schematics: Schematic[];
  design: Design | null;
};

export const Flatpacker = (props) => {
  const { act, data } = useBackend<Data>();
  const { materials, design, busy, boardInserted } = data;

  return (
    <Window width={760} height={520} title="Flatpacker">
      <Window.Content>
        {!!busy && (
          <Dimmer fontSize="2em" textAlign="center">
            <Icon name="cog" spin />
            {' Pakowanie...'}
          </Dimmer>
        )}
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="260px">
                <SchematicList />
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  fill
                  title={design ? toTitleCase(design.name) : 'Brak źródła'}
                  buttons={
                    <Button
                      icon="eject"
                      disabled={!boardInserted}
                      onClick={() => act('ejectBoard')}
                    >
                      Wyjmij płytkę
                    </Button>
                  }
                >
                  {design ? (
                    <DesignPreview design={design} />
                  ) : (
                    <NoticeBox>
                      Włóż płytkę maszyny albo wybierz schemat z bazy.
                    </NoticeBox>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={materials}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SchematicList = (props) => {
  const { act, data } = useBackend<Data>();
  const { schematics, selected, boardInserted, emagged } = data;

  return (
    <Section
      fill
      scrollable
      title="Baza schematów"
      buttons={
        <Button
          icon="times"
          disabled={!selected}
          tooltip="Odznacz schemat"
          onClick={() => act('deselect')}
        />
      }
    >
      {boardInserted ? (
        <NoticeBox info>
          Włożona płytka ma pierwszeństwo przed schematem.
        </NoticeBox>
      ) : null}
      {schematics.length === 0 ? (
        <NoticeBox>
          Baza jest pusta. Zeskanuj maszyny skanerem i wgraj skany do czytnika
          schematów.
        </NoticeBox>
      ) : (
        schematics.map((schematic) => (
          <Button
            key={schematic.key}
            fluid
            ellipsis
            selected={schematic.key === selected}
            color={schematic.illegal && !emagged ? 'bad' : undefined}
            tooltip={
              schematic.illegal
                ? 'Maszyna z czarnej listy: flatpacker zrobi paczkę tylko po zhakowaniu.'
                : undefined
            }
            onClick={() => act('select', { key: schematic.key })}
          >
            {`${toTitleCase(schematic.name)} (tier ${schematic.tier})`}
          </Button>
        ))
      )}
    </Section>
  );
};

const DesignPreview = (props: { design: Design }) => {
  const { act, data } = useBackend<Data>();
  const { design } = props;
  const { maxTier, efficiency } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <DmIcon
              width="96px"
              height="96px"
              icon={design.icon}
              icon_state={design.icon_state}
            />
          </Stack.Item>
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item label="Tier części">
                <Box color={design.tier > maxTier ? 'bad' : undefined}>
                  {design.tier} (ten flatpacker: do {maxTier})
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Zużycie materiałów">
                {Math.round(efficiency * 100)}%
              </LabeledList.Item>
              {!!design.illegal && (
                <LabeledList.Item label="Uwaga">
                  <Box color="bad">Maszyna z czarnej listy</Box>
                </LabeledList.Item>
              )}
            </LabeledList>
            <Button
              mt={1}
              bold
              fluid
              icon="box"
              textAlign="center"
              disabled={design.disableReason !== ''}
              tooltip={design.disableReason || undefined}
              onClick={() => act('build')}
            >
              Zapakuj
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {design.manual.length > 0 && (
        <Stack.Item>
          <Section title="Części do włożenia ręcznie">
            <Table>
              {design.manual.map((part) => (
                <Table.Row key={part.name}>
                  <Table.Cell>{toTitleCase(part.name)}</Table.Cell>
                  <Table.Cell
                    collapsing
                    color={part.have < part.need ? 'bad' : 'good'}
                  >
                    {part.have}/{part.need}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Section fill scrollable title="Koszt">
          <Table>
            {design.requiredMaterials.map((material) => (
              <Table.Row key={material.name} className="candystripe">
                <Table.Cell collapsing verticalAlign="middle">
                  <MaterialIcon
                    materialName={material.name}
                    amount={material.amount}
                  />
                </Table.Cell>
                <Table.Cell verticalAlign="middle">
                  {toTitleCase(material.name)}
                </Table.Cell>
                <Table.Cell collapsing verticalAlign="middle">
                  x{formatSheets(material.amount)}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
