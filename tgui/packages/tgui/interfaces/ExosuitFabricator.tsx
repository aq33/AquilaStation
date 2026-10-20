import {
  Box,
  Button,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import type { Design, Material, MaterialMap } from './Fabrication/Types';
import { affordableAmount } from './Fabricator';

type QueueJob = {
  /** Unique per row, used as the React key. */
  jobId: string;
  /** The design being printed, available in `designs`. */
  designId: string;
  /** If true, this design is being fabricated and `timeLeft` is counting down. */
  processing: BooleanLike;
  /** The time left in this design's fabrication, in deciseconds. */
  timeLeft: number;
};

type ExosuitFabricatorData = {
  /** AQUILA: our exosuit fabricator syncs research from a nearby R&D console */
  can_sync?: BooleanLike;
  materials: Material[];
  designs: Record<string, Design>;
  queue: QueueJob[];
  processing: BooleanLike;
};

export const ExosuitFabricator = (props) => {
  const { act, data } = useBackend<ExosuitFabricatorData>();
  const { materials = [], designs = {} } = data;

  const availableMaterials: MaterialMap = {};

  for (const material of materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title="Fabrykator egzoszkieletów" width={1100} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <DesignBrowser
                  designs={Object.values(designs)}
                  availableMaterials={availableMaterials}
                  buildRecipeElement={(design, availableMaterials) => (
                    <Recipe available={availableMaterials} design={design} />
                  )}
                  categoryButtons={(category) => (
                    <Button
                      color="transparent"
                      onClick={() => {
                        act('build', {
                          designs: category.children.map((design) => design.id),
                        });
                      }}
                    >
                      Dodaj wszystko do kolejki
                    </Button>
                  )}
                />
              </Stack.Item>
              {!!data.can_sync && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="sync"
                    tooltip="Skopiuj badania z pobliskiej konsoli B+R"
                    onClick={() => act('resync_rd')}
                  >
                    Synchronizuj z B+R
                  </Button>
                </Stack.Item>
              )}
              <Stack.Item>
                <Section>
                  <MaterialAccessBar
                    availableMaterials={materials}
                    designs={Object.values(designs)}
                    onEjectRequested={(material, amount) => {
                      act('remove_mat', { ref: material.ref, amount });
                    }}
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item width="420px">
            <Queue availableMaterials={availableMaterials} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type RecipeProps = {
  design: Design;
  available: MaterialMap;
};

const Recipe = (props: RecipeProps) => {
  const { act } = useBackend<ExosuitFabricatorData>();
  const { design, available } = props;

  const canPrint = affordableAmount(design, available) > 0;

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
        position="bottom"
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            available={available}
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('build', { designs: [design.id], now: true })
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

      <Tooltip content="Dodaj do kolejki" position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
          onClick={() => act('queue_item', { design_id: design.id, amount: 1 })}
        >
          <Icon name="plus-circle" />
        </div>
      </Tooltip>

      <Tooltip content="Zbuduj teraz" position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
          onClick={() => act('build', { designs: [design.id], now: true })}
        >
          <Icon name="play" />
        </div>
      </Tooltip>
      <CustomQueue design={design} available={available} />
    </div>
  );
};

/** AQUILA: queue any number of copies at once. */
const CustomQueue = (props: RecipeProps) => {
  const { act } = useBackend<ExosuitFabricatorData>();
  const { design, available } = props;
  const max = affordableAmount(design, available);

  return (
    <div
      className={classes([
        'FabricatorRecipe__Button',
        max < 1 && 'FabricatorRecipe__Button--disabled',
      ])}
    >
      <Button.Input
        color="transparent"
        buttonText={`×${max}`}
        onCommit={(value) =>
          act('queue_item', { design_id: design.id, amount: value })
        }
      />
    </div>
  );
};

type QueueProps = {
  availableMaterials: MaterialMap;
};

const Queue = (props: QueueProps) => {
  const { act, data } = useBackend<ExosuitFabricatorData>();
  const { availableMaterials } = props;
  const { designs = {}, processing } = data;

  const queue = data.queue || [];

  const materialCosts: MaterialMap = {};

  for (const entry of queue) {
    const design = designs[entry.designId];

    if (!design) {
      continue;
    }

    for (const [materialName, materialCost] of Object.entries(design.cost)) {
      materialCosts[materialName] =
        (materialCosts[materialName] || 0) + materialCost;
    }
  }

  return (
    <Section fill className="Fabricator__QueuePanel">
      <Stack fill vertical>
        <Stack.Item>
          <Section
            fill
            title="Kolejka"
            buttons={
              <>
                <Button.Confirm
                  disabled={!queue.length}
                  color="bad"
                  icon="minus-circle"
                  confirmContent="Na pewno?"
                  onClick={() => act('clear_queue')}
                >
                  Wyczyść kolejkę
                </Button.Confirm>
                {(!!processing && (
                  <Button
                    disabled={!queue.length}
                    icon="stop"
                    onClick={() => act('stop_queue')}
                  >
                    Zatrzymaj
                  </Button>
                )) || (
                  <Button
                    disabled={!queue.length}
                    icon="play"
                    onClick={() => act('build_queue')}
                  >
                    Buduj kolejkę
                  </Button>
                )}
              </>
            }
          >
            <MaterialCostSequence
              available={availableMaterials}
              costMap={materialCosts}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow style={{ overflowY: 'auto', overflowX: 'hidden' }}>
          <Section fill>
            <QueueList availableMaterials={availableMaterials} />
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const QueueList = (props: QueueProps) => {
  const { act, data } = useBackend<ExosuitFabricatorData>();
  const { availableMaterials } = props;

  const queue = data.queue || [];
  const designs = data.designs || {};

  if (!queue.length) {
    return null;
  }

  const accumulatedCosts: MaterialMap = {};

  return (
    <>
      {queue
        .map((job, index) => ({ job, index, design: designs[job.designId] }))
        .map((entry) => {
          // Side effects in map, but the costs have to accumulate down the queue.
          let canPrint = true;

          for (const [material, amount] of entry.design
            ? Object.entries(entry.design.cost)
            : []) {
            accumulatedCosts[material] =
              (accumulatedCosts[material] || 0) + amount;

            if (
              accumulatedCosts[material] > (availableMaterials[material] || 0)
            ) {
              canPrint = false;
            }
          }

          return { canPrint, ...entry };
        })
        .map((entry) => (
          <div key={entry.job.jobId} className="FabricatorRecipe">
            {!!entry.job.processing && (
              <div
                className="FabricatorRecipe__Progress"
                style={{
                  width:
                    (entry.job.timeLeft /
                      (entry.design ? entry.design.constructionTime : 0)) *
                      100 +
                    '%',
                }}
              />
            )}
            <Tooltip
              position="bottom"
              content={
                <MaterialCostSequence
                  design={entry.design}
                  amount={1}
                  available={availableMaterials}
                />
              }
            >
              <div
                className={classes([
                  'FabricatorRecipe__Title',
                  !entry.canPrint && 'FabricatorRecipe__Title--disabled',
                ])}
              >
                <div className="FabricatorRecipe__Icon">
                  <Box
                    width="32px"
                    height="32px"
                    className={classes(['design32x32', entry.design?.icon])}
                  />
                </div>
                <div className="FabricatorRecipe__Label">
                  {entry.design?.name}
                </div>
              </div>
            </Tooltip>

            {!entry.job.processing && (
              <div
                className={classes([
                  'FabricatorRecipe__Button',
                  'FabricatorRecipe__Button--icon',
                ])}
                onClick={() => {
                  act('del_queue_part', {
                    index: entry.index + (queue[0]!.processing ? 0 : 1),
                  });
                }}
              >
                <Tooltip content="Usuń z kolejki">
                  <Icon name="minus-circle" />
                </Tooltip>
              </div>
            )}
          </div>
        ))}
    </>
  );
};
