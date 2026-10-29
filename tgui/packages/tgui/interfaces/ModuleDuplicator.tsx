// AQUILA: okno duplikatora modułów, ComponentPrinter z tg na naszej przeglądarce projektów.
import { Box, Icon, Section, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import type { Design, Material, MaterialMap } from './Fabrication/Types';

type Data = {
  designs: Record<string, Design>;
  materials: Material[];
};

export const ModuleDuplicator = (props) => {
  const { act, data } = useBackend<Data>();
  const { materials = [], designs = {} } = data;

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title="Duplikator modułów" width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow style={{ minHeight: '0' }}>
            <DesignBrowser
              designs={Object.values(designs)}
              availableMaterials={availableMaterials}
              buildRecipeElement={(design, available) => (
                <Recipe design={design} available={available} />
              )}
            />
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

type RecipeProps = {
  available: MaterialMap;
  design: Design;
};

const Recipe = (props: RecipeProps) => {
  const { available, design } = props;
  const { act } = useBackend<Data>();

  const canPrint = !Object.entries(design.cost).some(([material, amount]) => {
    const have = available[material];

    return !have || amount > have;
  });

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
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => canPrint && act('print', { design_id: design.id })}
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
    </div>
  );
};
