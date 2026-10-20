import {
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import type { Design, FabricatorData, MaterialMap } from './Fabrication/Types';

/** The most copies the machine will accept in one order. */
const MAX_PRINT_AMOUNT = 50;

/**
 * AQUILA: how much of a cost entry the machine can cover. A cost keyed by a
 * material category rather than a material name -- the toolbox is costed
 * against any rigid material -- is payable from whichever single material
 * there is most of, so that is what it gets measured against.
 */
export const availableFor = (material: string, available: MaterialMap) =>
  material in available
    ? available[material]
    : Math.max(0, ...Object.values(available));

/** How many of a design the loaded materials and reagents can afford, up to the cap. */
export const affordableAmount = (
  design: Design,
  available: MaterialMap,
  availableReagents: MaterialMap = {},
) => {
  let affordable = Object.entries(design.cost).reduce(
    (most, [material, cost]) =>
      Math.min(most, availableFor(material, available) / cost),
    Infinity,
  );
  affordable = Object.entries(design.reagentCost || {}).reduce(
    (most, [reagent, volume]) =>
      Math.min(most, (availableReagents[reagent] || 0) / volume),
    affordable,
  );
  return Math.min(Math.floor(affordable), MAX_PRINT_AMOUNT);
};

/** AQUILA: reagent name -> units currently loaded. */
const loadedReagents = (data: FabricatorData) => {
  const loaded: MaterialMap = {};
  for (const reagent of data.reagents || []) {
    loaded[reagent.name] = reagent.volume;
  }
  return loaded;
};

export const Fabricator = (props) => {
  const { act, data } = useBackend<FabricatorData>();
  const { fabName, onHold, designs, busy } = data;

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials || []) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title={fabName} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <DesignBrowser
              busy={!!busy}
              designs={Object.values(designs || {})}
              availableMaterials={availableMaterials}
              buildRecipeElement={(design, availableMaterials) => (
                <Recipe design={design} available={availableMaterials} />
              )}
            />
          </Stack.Item>
          {!!data.reagents?.length && (
            <Stack.Item>
              <ReagentBar />
            </Stack.Item>
          )}
          <Stack.Item>
            <SyncButton />
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={data.materials ?? []}
                designs={Object.values(designs || {})}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
        {!!onHold && (
          <Dimmer style={{ fontSize: '2em', textAlign: 'center' }}>
            Dostęp do minerałów jest wstrzymany, skontaktuj się z
            kwatermistrzem.
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};

/** AQUILA: pulls newly researched designs from the techweb, which lathes don't do on their own. */
const SyncButton = () => {
  const { act, data } = useBackend<FabricatorData>();
  const pending = data.pendingResearch || 0;
  return (
    <Button
      fluid
      icon="sync"
      color={pending ? 'good' : 'default'}
      tooltip="Pobierz nowo opracowane projekty z serwerów naukowych"
      onClick={() => act('sync_rnd')}
    >
      {pending
        ? `Synchronizuj badania (nowe projekty: ${pending})`
        : 'Synchronizuj badania'}
    </Button>
  );
};

/** AQUILA: reagents are poured in by hand, so they get their own bar above the materials. */
const ReagentBar = () => {
  const { act, data } = useBackend<FabricatorData>();
  const loaded = data.reagents.reduce(
    (total, reagent) => total + reagent.volume,
    0,
  );

  return (
    <Section
      title={`Odczynniki (${loaded}u / ${data.reagentCapacity}u)`}
      buttons={
        <Button.Confirm
          color="bad"
          icon="trash"
          confirmContent="Na pewno?"
          onClick={() => act('disposeall')}
        >
          Wylej wszystko
        </Button.Confirm>
      }
    >
      <Flex wrap>
        {data.reagents.map((reagent) => (
          <Flex.Item key={reagent.id} mr={1}>
            <Button
              icon="times"
              color="transparent"
              tooltip="Wylej ten odczynnik"
              onClick={() => act('dispose', { reagent_id: reagent.id })}
            >
              {reagent.name} &mdash; {reagent.volume}u
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  available: MaterialMap;
  availableReagents: MaterialMap;
};

const PrintButton = (props: PrintButtonProps) => {
  const { act } = useBackend<FabricatorData>();
  const { design, quantity, available, availableReagents } = props;

  const canPrint =
    affordableAmount(design, available, availableReagents) >= quantity;

  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          available={available}
          availableReagents={availableReagents}
        />
      }
    >
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        onClick={() => act('build', { ref: design.id, amount: quantity })}
      >
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

type CustomPrintProps = {
  design: Design;
  available: MaterialMap;
  availableReagents: MaterialMap;
};

const CustomPrint = (props: CustomPrintProps) => {
  const { act } = useBackend<FabricatorData>();
  const { design, available, availableReagents } = props;
  const maxMult = affordableAmount(design, available, availableReagents);
  const canPrint = maxMult > 0;

  return (
    <div
      className={classes([
        'FabricatorRecipe__Button',
        !canPrint && 'FabricatorRecipe__Button--disabled',
      ])}
    >
      <Button.Input
        buttonText={`[Maks.: ${maxMult}]`}
        color="transparent"
        onCommit={(value) =>
          act('build', {
            ref: design.id,
            amount: value,
          })
        }
      />
    </div>
  );
};

type RecipeProps = {
  design: Design;
  available: MaterialMap;
};

const Recipe = (props: RecipeProps) => {
  const { act, data } = useBackend<FabricatorData>();
  const { design, available } = props;
  const availableReagents = loadedReagents(data);

  const canPrint = affordableAmount(design, available, availableReagents) > 0;

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
        >
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            available={available}
            availableReagents={availableReagents}
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('build', { ref: design.id, amount: 1 })
          }
        >
          <div className="FabricatorRecipe__Icon">
            <Box
              width="32px"
              height="32px"
              className={classes(['design32x32', design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>
      <PrintButton
        design={design}
        quantity={5}
        available={available}
        availableReagents={availableReagents}
      />
      <PrintButton
        design={design}
        quantity={10}
        available={available}
        availableReagents={availableReagents}
      />
      <CustomPrint
        design={design}
        available={available}
        availableReagents={availableReagents}
      />
    </div>
  );
};
