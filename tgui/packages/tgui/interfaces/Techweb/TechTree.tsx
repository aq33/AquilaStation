// AQUILA: sieć badań jako drzewko nauki. Węzły w kolumnach według głębokości wymagań,
// linie od wymagań do węzłów, przesuwanie przeciąganiem i zoom kółkiem (jak tablica detektywa).
import { useEffect, useMemo, useRef, useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useRemappedBackend } from './helpers';
import { TechNode } from './nodes/TechNode';
import type { NodeCache, TechwebNode } from './types';

const NODE_WIDTH = 190;
const NODE_HEIGHT = 46;
const COLUMN_GAP = 90;
const ROW_GAP = 16;
const MIN_ZOOM = 0.25;
const MAX_ZOOM = 1.6;

type Placed = { id: string; x: number; y: number; depth: number };

type View = { x: number; y: number; zoom: number };

/** Kolumna = najdłuższa ścieżka wymagań, kolejność w kolumnie wg średniej pozycji wymagań */
function layoutTree(
  nodes: TechwebNode[],
  node_cache: Record<string, NodeCache>,
): Record<string, Placed> {
  const visible = new Set(nodes.map((n) => n.id));
  const depth: Record<string, number> = {};
  const visiting = new Set<string>();
  const getDepth = (id: string): number => {
    if (depth[id] !== undefined) return depth[id];
    if (visiting.has(id)) return 0; // cykl w danych nie zawiesi okna
    visiting.add(id);
    let d = 0;
    for (const pre of node_cache[id]?.prereq_ids ?? []) {
      if (visible.has(pre)) d = Math.max(d, getDepth(pre) + 1);
    }
    visiting.delete(id);
    depth[id] = d;
    return d;
  };
  const columns: string[][] = [];
  for (const n of nodes) {
    if (!node_cache[n.id]) continue;
    const d = getDepth(n.id);
    (columns[d] ??= []).push(n.id);
  }
  const placed: Record<string, Placed> = {};
  columns.forEach((column, d) => {
    const order = column.map((id) => {
      const parents = (node_cache[id].prereq_ids ?? []).filter(
        (p) => placed[p],
      );
      const key = parents.length
        ? parents.reduce((sum, p) => sum + placed[p].y, 0) / parents.length
        : -1;
      return { id, key, name: node_cache[id].name };
    });
    order.sort((a, b) => a.key - b.key || a.name.localeCompare(b.name));
    order.forEach((entry, row) => {
      placed[entry.id] = {
        id: entry.id,
        depth: d,
        x: d * (NODE_WIDTH + COLUMN_GAP),
        y: row * (NODE_HEIGHT + ROW_GAP),
      };
    });
  });
  return placed;
}

const stateOf = (node?: TechwebNode) =>
  node?.tier === 0 ? 'researched' : node?.tier === 1 ? 'available' : 'future';

export function TechwebTree(props: { selectedNode?: string }) {
  const { data } = useRemappedBackend();
  const { nodes, node_cache, design_cache } = data;
  const [selected, setSelected] = useState<string | null>(
    props.selectedNode ?? null,
  );
  const [searchText, setSearchText] = useState('');
  const [view, setView] = useState<View>({ x: 20, y: 20, zoom: 0.8 });
  const viewport = useRef<HTMLDivElement>(null);
  const drag = useRef<{ x: number; y: number; moved: boolean } | null>(null);

  // Układ zależy tylko od listy widocznych węzłów, nie od punktów
  const layoutKey = nodes.map((n) => n.id).join(',');
  const placed = useMemo(
    () => layoutTree(nodes, node_cache),
    [layoutKey, node_cache],
  );
  const byId = useMemo(() => {
    const result: Record<string, TechwebNode> = {};
    for (const n of nodes) result[n.id] = n;
    return result;
  }, [nodes]);

  const query = searchText.trim().toLowerCase();
  const matches = useMemo(() => {
    if (query.length < 2) return null;
    const found = new Set<string>();
    for (const n of nodes) {
      const c = node_cache[n.id];
      if (
        c &&
        (c.name.toLowerCase().includes(query) ||
          c.description.toLowerCase().includes(query) ||
          c.design_ids.some((e) =>
            design_cache[e]?.name.toLowerCase().includes(query),
          ))
      ) {
        found.add(n.id);
      }
    }
    return found;
  }, [query, nodes]);

  const focusNode = (id: string) => {
    const p = placed[id];
    const box = viewport.current?.getBoundingClientRect();
    if (!p || !box) return;
    setView((v) => ({
      zoom: v.zoom,
      x: box.width / 2 - (p.x + NODE_WIDTH / 2) * v.zoom,
      y: box.height / 2 - (p.y + NODE_HEIGHT / 2) * v.zoom,
    }));
  };

  // Węzeł wybrany z analizatora albo dysku: wyśrodkuj go po otwarciu drzewa
  useEffect(() => {
    if (props.selectedNode) focusNode(props.selectedNode);
  }, []);

  // Przeciąganie tła przesuwa widok; nasłuch na oknie, żeby nie gubić myszy poza drzewem
  useEffect(() => {
    const move = (e: MouseEvent) => {
      const d = drag.current;
      if (!d) return;
      const dx = e.clientX - d.x;
      const dy = e.clientY - d.y;
      if (Math.abs(dx) + Math.abs(dy) > 2) d.moved = true;
      d.x = e.clientX;
      d.y = e.clientY;
      setView((v) => ({ ...v, x: v.x + dx, y: v.y + dy }));
    };
    const up = () => {
      drag.current = null;
    };
    window.addEventListener('mousemove', move);
    window.addEventListener('mouseup', up);
    return () => {
      window.removeEventListener('mousemove', move);
      window.removeEventListener('mouseup', up);
    };
  }, []);

  const onWheel = (e: React.WheelEvent) => {
    const box = viewport.current?.getBoundingClientRect();
    if (!box) return;
    const mx = e.clientX - box.left;
    const my = e.clientY - box.top;
    setView((v) => {
      const zoom = Math.min(
        MAX_ZOOM,
        Math.max(MIN_ZOOM, v.zoom * (e.deltaY < 0 ? 1.1 : 1 / 1.1)),
      );
      const k = zoom / v.zoom;
      return { zoom, x: mx - (mx - v.x) * k, y: my - (my - v.y) * k };
    });
  };

  const zoomBy = (factor: number) => {
    const box = viewport.current?.getBoundingClientRect();
    const mx = (box?.width ?? 0) / 2;
    const my = (box?.height ?? 0) / 2;
    setView((v) => {
      const zoom = Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, v.zoom * factor));
      const k = zoom / v.zoom;
      return { zoom, x: mx - (mx - v.x) * k, y: my - (my - v.y) * k };
    });
  };

  let width = 0;
  let height = 0;
  for (const p of Object.values(placed)) {
    width = Math.max(width, p.x + NODE_WIDTH);
    height = Math.max(height, p.y + NODE_HEIGHT);
  }

  const related = new Set<string>();
  if (selected && node_cache[selected]) {
    for (const id of node_cache[selected].prereq_ids) related.add(id);
    for (const id of node_cache[selected].unlock_ids) related.add(id);
  }

  const lines: React.ReactNode[] = [];
  for (const p of Object.values(placed)) {
    for (const pre of node_cache[p.id].prereq_ids) {
      const from = placed[pre];
      if (!from) continue;
      const x1 = from.x + NODE_WIDTH;
      const y1 = from.y + NODE_HEIGHT / 2;
      const x2 = p.x;
      const y2 = p.y + NODE_HEIGHT / 2;
      const mid = (x1 + x2) / 2;
      const highlighted = selected === p.id || selected === pre;
      lines.push(
        <path
          key={`${pre}>${p.id}`}
          d={`M ${x1} ${y1} C ${mid} ${y1}, ${mid} ${y2}, ${x2} ${y2}`}
          className={`Techweb__TreeLine Techweb__TreeLine--${stateOf(byId[pre])}${highlighted ? ' Techweb__TreeLine--highlight' : ''}`}
        />,
      );
    }
  }

  const selectedNode = selected ? byId[selected] : null;

  return (
    <Stack fill>
      <Stack.Item grow>
        <Stack vertical fill>
          <Stack.Item>
            <Stack align="center" className="Techweb__HeaderSectionTabs">
              <Stack.Item className="Techweb__HeaderTabTitle">
                Drzewo badań
              </Stack.Item>
              <Stack.Item grow>
                <Box inline className="Techweb__TreeLegend--researched">
                  ■ Zbadane
                </Box>
                <Box inline ml={1} className="Techweb__TreeLegend--available">
                  ■ Dostępne
                </Box>
                <Box inline ml={1} className="Techweb__TreeLegend--future">
                  ■ Przyszłe
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="minus"
                  tooltip="Oddal"
                  onClick={() => zoomBy(1 / 1.25)}
                />
                <Button
                  icon="plus"
                  tooltip="Przybliż"
                  onClick={() => zoomBy(1.25)}
                />
                <Button
                  icon="expand"
                  tooltip="Pokaż całe drzewo"
                  onClick={() => {
                    const box = viewport.current?.getBoundingClientRect();
                    if (!box || !width) return;
                    const zoom = Math.max(
                      MIN_ZOOM,
                      Math.min(
                        MAX_ZOOM,
                        Math.min(
                          (box.width - 40) / width,
                          (box.height - 40) / height,
                        ),
                      ),
                    );
                    setView({ zoom, x: 20, y: 20 });
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Input
                  value={searchText}
                  onChange={setSearchText}
                  onEnter={() => {
                    const first = matches && [...matches][0];
                    if (first) {
                      setSelected(first);
                      focusNode(first);
                    }
                  }}
                  placeholder="Szukaj węzła lub projektu..."
                  width="16em"
                  expensive
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <div
              ref={viewport}
              className="Techweb__TreeViewport"
              onWheel={onWheel}
              onMouseDown={(e) => {
                if (e.button !== 0) return;
                drag.current = { x: e.clientX, y: e.clientY, moved: false };
              }}
            >
              <div
                className="Techweb__TreeCanvas"
                style={{
                  transform: `translate(${view.x}px, ${view.y}px) scale(${view.zoom})`,
                }}
              >
                <svg
                  className="Techweb__TreeLines"
                  width={width}
                  height={height}
                >
                  {lines}
                </svg>
                {Object.values(placed).map((p) => {
                  const node = byId[p.id];
                  const state = stateOf(node);
                  const dim = !!matches && !matches.has(p.id);
                  return (
                    <div
                      key={p.id}
                      className={[
                        'Techweb__TreeNode',
                        `Techweb__TreeNode--${state}`,
                        selected === p.id && 'Techweb__TreeNode--selected',
                        related.has(p.id) && 'Techweb__TreeNode--related',
                        dim && 'Techweb__TreeNode--dim',
                        node?.can_unlock &&
                          state === 'available' &&
                          'Techweb__TreeNode--ready',
                      ]
                        .filter(Boolean)
                        .join(' ')}
                      style={{
                        left: `${p.x}px`,
                        top: `${p.y}px`,
                        width: `${NODE_WIDTH}px`,
                        height: `${NODE_HEIGHT}px`,
                      }}
                      onMouseUp={(e) => {
                        if (e.button !== 0 || drag.current?.moved) return;
                        setSelected(p.id === selected ? null : p.id);
                      }}
                    >
                      <div className="Techweb__TreeNodeName">
                        {node_cache[p.id].name}
                      </div>
                      <div className="Techweb__TreeNodeTier">
                        Poziom {node_cache[p.id].node_tier}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {!!selectedNode && (
        <Stack.Item width="24em">
          <Section
            fill
            scrollable
            title="Wybrany węzeł"
            buttons={<Button icon="times" onClick={() => setSelected(null)} />}
          >
            <TechNode node={selectedNode} nodetails />
            <NodeLinks
              title="Wymaga"
              ids={node_cache[selectedNode.id].prereq_ids}
              byId={byId}
              node_cache={node_cache}
              onPick={(id) => {
                setSelected(id);
                focusNode(id);
              }}
            />
            <NodeLinks
              title="Odblokowuje"
              ids={node_cache[selectedNode.id].unlock_ids}
              byId={byId}
              node_cache={node_cache}
              onPick={(id) => {
                setSelected(id);
                focusNode(id);
              }}
            />
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
}

type NodeLinksProps = {
  title: string;
  ids: string[];
  byId: Record<string, TechwebNode>;
  node_cache: Record<string, NodeCache>;
  onPick: (id: string) => void;
};

function NodeLinks(props: NodeLinksProps) {
  const { title, ids, byId, node_cache, onPick } = props;
  const shown = ids.filter((id) => byId[id] && node_cache[id]);
  if (!shown.length) return null;
  return (
    <Box mt={1}>
      <Box bold mb={0.5}>
        {title}
      </Box>
      {shown.map((id) => (
        <Button
          key={id}
          fluid
          className={`Techweb__TreeLink--${stateOf(byId[id])}`}
          onClick={() => onPick(id)}
        >
          {node_cache[id].name}
        </Button>
      ))}
    </Box>
  );
}
