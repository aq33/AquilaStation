import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import { AnimatedNumber, Button, Flex } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { MaterialIcon } from './MaterialIcon';
import {
  type Design,
  formatSheets,
  type Material,
  SHEET_MATERIAL_AMOUNT,
} from './Types';

// by popular demand of discord people (who are always right and never wrong)
// this is completely made up
const MATERIAL_RARITY: Record<string, number> = {
  glass: 0,
  iron: 1,
  copper: 2, // AQUILA
  plastic: 3,
  titanium: 4,
  plasma: 5,
  silver: 6,
  gold: 7,
  uranium: 8,
  diamond: 9,
  'bluespace crystal': 10,
  bananium: 11,
};

export type MaterialAccessBarProps = {
  /** All materials currently available to the user. */
  availableMaterials: Material[];

  /**
   * AQUILA: designs the machine can print. Materials none of them use are
   * hidden while the machine holds none of them.
   */
  designs?: Design[];

  /** Invoked when the user requests that a material be ejected. */
  onEjectRequested?: (material: Material, quantity: number) => void;
};

/**
 * The formatting function applied to the quantity labels in the bar.
 */
const LABEL_FORMAT = (value: number) => formatSheets(value);

/** Every material name that any of these designs is built from. */
const materialsUsedBy = (designs: Design[]) => {
  const used = new Set<string>();
  for (const design of designs) {
    for (const material of Object.keys(design.cost)) {
      used.add(material);
    }
  }
  return used;
};

/**
 * A bottom-docked bar for viewing and ejecting materials from local storage or
 * the ore silo. Has pop-out docks for each material type for ejecting up to
 * fifty sheets.
 */
export const MaterialAccessBar = (props: MaterialAccessBarProps) => {
  const { availableMaterials, designs, onEjectRequested } = props;
  const spendable = materialsUsedBy(designs || []);

  return (
    <Flex wrap>
      {sortBy(
        availableMaterials.filter(
          (material) => material.amount > 0 || spendable.has(material.name),
        ),
        [(material: Material) => MATERIAL_RARITY[material.name] ?? 99],
      ).map((material) => (
        <Flex.Item grow basis={4.5} key={material.name}>
          <MaterialCounter
            material={material}
            onEjectRequested={(quantity) =>
              onEjectRequested?.(material, quantity)
            }
          />
        </Flex.Item>
      ))}
    </Flex>
  );
};

type MaterialCounterProps = {
  material: Material;
  onEjectRequested: (quantity: number) => void;
};

const MaterialCounter = (props: MaterialCounterProps) => {
  const { material, onEjectRequested } = props;

  const [hovering, setHovering] = useState(false);

  const sheets = material.amount / SHEET_MATERIAL_AMOUNT;
  // Coerce to a real boolean, otherwise it would add a literal white 0
  const canEject = !!material.removable && sheets >= 1;

  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={classes([
        'MaterialDock',
        hovering && canEject && 'MaterialDock--active',
        !canEject && 'MaterialDock--disabled',
      ])}
    >
      <Flex direction="column-reverse">
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => canEject && onEjectRequested(1)}
          className="MaterialDock__Label"
        >
          <Flex.Item>
            <MaterialIcon
              materialName={material.name}
              amount={material.amount}
            />
          </Flex.Item>
          <Flex.Item>
            <AnimatedNumber value={material.amount} format={LABEL_FORMAT} />
          </Flex.Item>
        </Flex>
        {hovering && canEject && (
          <div className="MaterialDock__Dock">
            <Flex vertical direction="column-reverse">
              {[5, 10, 25, 50].map((amount) => (
                <EjectButton
                  key={amount}
                  sheets={sheets}
                  amount={amount}
                  onEject={onEjectRequested}
                />
              ))}
            </Flex>
          </div>
        )}
      </Flex>
    </div>
  );
};

type EjectButtonProps = {
  amount: number;
  sheets: number;
  onEject: (quantity: number) => void;
};

const EjectButton = (props: EjectButtonProps) => {
  const { amount, sheets, onEject } = props;

  return (
    <Button
      fluid
      color="transparent"
      className={classes([
        'Fabricator__PrintAmount',
        amount > sheets && 'Fabricator__PrintAmount--disabled',
      ])}
      onClick={() => onEject(amount)}
    >
      &times;{amount}
    </Button>
  );
};
