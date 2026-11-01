import type { CatalogOperation, SurgeryTool } from './types';

/** „skalpel / nóż (66%)” - narzędzia operacji, najlepsze pierwsze */
export const formatTools = (tools: SurgeryTool[] = [], limit?: number) =>
  [...tools]
    .sort((a, b) => b.speed - a.speed)
    .slice(0, limit)
    .map((tool) =>
      tool.speed >= 100 ? tool.name : `${tool.name} (${tool.speed}%)`,
    )
    .join(' / ');

/** Najlepsze narzędzie operacji, jak „tool_rec” w tg */
export const recommendedTool = (operation: CatalogOperation) =>
  formatTools(operation.tools, 1);

/** Wymagania operacji pogrupowane jak w tg (OperatingComputer/helpers.ts) */
export const extractRequirementMap = (
  operation: CatalogOperation,
): Record<string, string[]> => {
  if (operation.requirements?.length !== 4) {
    return {};
  }
  const hard = [...operation.requirements[0]];
  const soft = [...operation.requirements[1]];
  const optional = operation.requirements[2];
  const blocked = operation.requirements[3];

  // jedno z jednego to po prostu wymaganie
  if (soft.length === 1) {
    hard.push(soft[0]);
    soft.length = 0;
  }

  return {
    'Wymagane:': hard,
    'Do tego jedno z:': soft,
    'Opcjonalnie:': optional,
    'Blokuje operację:': blocked,
  };
};
