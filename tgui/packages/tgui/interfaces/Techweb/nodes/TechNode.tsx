import {
  Box,
  Button,
  Icon,
  ImageButton,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { abbreviatePoint, useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import type { TechwebNode } from '../types';

type Props = {
  node: TechwebNode;
} & Partial<{
  nocontrols: BooleanLike;
  nodetails: BooleanLike;
  // AQUILA: węzły do odblokowania analizatorem destrukcyjnym (z NSV13)
  destructive: BooleanLike;
}>;

export function TechNode(props: Props) {
  const { act, data } = useRemappedBackend();
  const {
    node_cache,
    design_cache,
    points = {},
    nodes,
    compact,
    researchable,
    tech_tier,
  } = data;
  const { node, nodetails, nocontrols, destructive } = props;
  const { id, can_unlock, tier = 0, costs } = node;
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  const cached = node_cache[id];
  if (!cached) return null;
  const { name, description, design_ids, prereq_ids, node_tier } = cached;

  // AQUILA: węzły z wyższego poziomu technologii kosztują dodatkowe punkty odkryć
  const overTier = node_tier > tech_tier + 1;

  const techcompl = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;

  const researchDisabled = !can_unlock || tier > 1;

  return (
    <Section
      className="Techweb__NodeContainer"
      title={name}
      buttons={
        <>
          <Box inline className="Techweb__TierDisplay">
            Poziom {node_tier}
          </Box>
          {!nocontrols && (
            <>
              {overTier && (
                <Tooltip
                  content={`Zbadanie tego węzła będzie kosztować dodatkowe punkty odkryć. Najpierw zbadaj więcej węzłów poziomu ${tech_tier + 1}.`}
                >
                  <Icon mx={1} name="exclamation-triangle" color="yellow" />
                </Tooltip>
              )}
              {tier > 0 &&
                !destructive &&
                !!researchable &&
                (overTier ? (
                  <Button.Confirm
                    icon="lightbulb"
                    disabled={researchDisabled}
                    confirmContent="Na pewno?"
                    onClick={() => act('researchNode', { node_id: id })}
                  >
                    Zbadaj
                  </Button.Confirm>
                ) : (
                  <Button
                    icon="lightbulb"
                    disabled={researchDisabled}
                    onClick={() => act('researchNode', { node_id: id })}
                  >
                    Zbadaj
                  </Button>
                ))}
              {!!destructive && (
                <Button
                  icon="trash"
                  color="bad"
                  onClick={() => act('destroyfortech', { node_id: id })}
                >
                  Zniszcz dla węzła
                </Button>
              )}
              {!nodetails && (
                <Button
                  icon="tasks"
                  onClick={() => {
                    setTechwebRoute({ route: 'details', selectedNode: id });
                  }}
                >
                  Szczegóły
                </Button>
              )}
            </>
          )}
        </>
      }
    >
      {tier !== 0 && !!compact && !destructive && (
        <Stack className="Techweb__NodeProgress">
          {Object.keys(costs || {}).map((type) => {
            const reqPts = Math.max(0, costs![type]);
            const nodeProg = Math.min(reqPts, points[type]) || 0;
            return (
              <Stack.Item key={type} grow basis={0}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={
                    reqPts === 0 ? 1 : Math.min(1, (points[type] || 0) / reqPts)
                  }
                >
                  {abbreviatePoint(type)} ({nodeProg}/{reqPts})
                </ProgressBar>
              </Stack.Item>
            );
          })}
          {prereq_ids.length > 0 && (
            <Stack.Item grow basis={0}>
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
                value={techcompl / prereq_ids.length}
              >
                Wymagane ({techcompl}/{prereq_ids.length})
              </ProgressBar>
            </Stack.Item>
          )}
        </Stack>
      )}
      <Box className="Techweb__NodeDescription" mb={2}>
        {description}
      </Box>
      {!!compact && (
        <Box className="Techweb__NodeUnlockedDesigns" mb={2}>
          {design_ids.map(
            (k, i) =>
              !!design_cache[k] && (
                <ImageButton
                  key={k}
                  className="Techweb__DesignIcon"
                  imageSize={32}
                  asset={['', design_cache[k].class]}
                  tooltip={design_cache[k].name}
                  tooltipPosition={i % 15 < 7 ? 'right' : 'left'}
                />
              ),
          )}
        </Box>
      )}
    </Section>
  );
}
