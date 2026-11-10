// AQUILA: sieć badań jako drzewko nauki rosnące od środka. Węzeł bazowy stoi w środku, a główne gałęzie
// (dzieci węzła bazowego i osobne korzenie) rosną od niego w prawo i w lewo, ułożone jedna nad drugą
// w górę i w dół od środka. Każda gałąź to zwarte drzewko: im dalej od środka, tym głębiej w wymaganiach.
// Gałąź ma swój kolor i ikonę pierwszej technologii. Przesuwanie przeciąganiem i zoom kółkiem jak na
// tablicy detektywa.
import { useEffect, useMemo, useRef, useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useRemappedBackend } from './helpers';
import { TechNode } from './nodes/TechNode';
import type { NodeCache, TechwebNode } from './types';

const NODE_WIDTH = 190;
const NODE_HEIGHT = 46;
/** Odstęp między kolejnymi poziomami gałęzi */
const LEVEL_GAP = 70;
/** Odstęp między sąsiednimi węzłami na tym samym poziomie */
const ROW_GAP = 14;
/** Odstęp między gałęziami po tej samej stronie i od środka */
const BRANCH_GAP = 60;
const MIN_ZOOM = 0.15;
const MAX_ZOOM = 1.6;
/** Węzeł, od którego rośnie drzewo */
const CENTER_ID = 'base';

type Side = 'right' | 'left';

type Placed = {
  /** Lewy górny róg ramki */
  x: number;
  y: number;
  id: string;
  /** Indeks gałęzi, -1 dla środka */
  branch: number;
};

type Branch = { root: string; hue: number };

type Layout = {
  placed: Record<string, Placed>;
  branches: Branch[];
  width: number;
  height: number;
};

type View = { x: number; y: number; zoom: number };

function layoutTree(
  nodes: TechwebNode[],
  node_cache: Record<string, NodeCache>,
): Layout {
  const ids = nodes.map((n) => n.id).filter((id) => node_cache[id]);
  const visible = new Set(ids);
  const prereqs = (id: string) =>
    (node_cache[id]?.prereq_ids ?? []).filter((p) => visible.has(p));

  // Głębokość = najdłuższa ścieżka wymagań
  const depth: Record<string, number> = {};
  const visiting = new Set<string>();
  const getDepth = (id: string): number => {
    if (depth[id] !== undefined) return depth[id];
    if (visiting.has(id)) return 0; // cykl w danych nie zawiesi okna
    visiting.add(id);
    let d = 0;
    for (const pre of prereqs(id)) d = Math.max(d, getDepth(pre) + 1);
    visiting.delete(id);
    depth[id] = d;
    return d;
  };
  ids.forEach(getDepth);

  // Gałęzie: dzieci środka i osobne korzenie; reszta dziedziczy gałąź po wymaganiu
  const hasCenter = visible.has(CENTER_ID);
  const roots: string[] = [];
  for (const id of ids) {
    if (id === CENTER_ID) continue;
    const pre = prereqs(id);
    if (!pre.length || (pre.length === 1 && pre[0] === CENTER_ID)) {
      roots.push(id);
    }
  }
  const branchOf: Record<string, number> = {};
  roots.forEach((id, i) => (branchOf[id] = i));
  for (const id of [...ids].sort((a, b) => depth[a] - depth[b])) {
    if (id === CENTER_ID || branchOf[id] !== undefined) continue;
    const parent = prereqs(id).find(
      (p) => p !== CENTER_ID && branchOf[p] !== undefined,
    );
    branchOf[id] = parent !== undefined ? branchOf[parent] : 0;
  }

  // Poziom w gałęzi liczony od jej korzenia
  const level: Record<string, number> = {};
  for (const id of ids) {
    if (id === CENTER_ID) continue;
    level[id] = Math.max(0, depth[id] - depth[roots[branchOf[id]]]);
  }

  // Każda gałąź jako małe drzewko: poziomy i kolejność na poziomie wg średniej pozycji wymagań
  type Local = { levels: string[][]; rows: number; size: number };
  const locals: Local[] = roots.map(() => ({ levels: [], rows: 0, size: 0 }));
  const rowOf: Record<string, number> = {};
  for (const id of [...ids].sort((a, b) => level[a] - level[b])) {
    if (id === CENTER_ID) continue;
    const local = locals[branchOf[id]];
    (local.levels[level[id]] ??= []).push(id);
    local.size++;
  }
  locals.forEach((local) => {
    local.levels.forEach((onLevel) => {
      if (!onLevel) return;
      const keyed = onLevel.map((id) => {
        const parents = prereqs(id).filter((p) => rowOf[p] !== undefined);
        const key = parents.length
          ? parents.reduce((sum, p) => sum + rowOf[p], 0) / parents.length
          : -1;
        return { id, key, name: node_cache[id].name };
      });
      keyed.sort((a, b) => a.key - b.key || a.name.localeCompare(b.name));
      keyed.forEach((entry, row) => (rowOf[entry.id] = row));
      local.rows = Math.max(local.rows, keyed.length);
    });
  });

  // Rozdział gałęzi na dwie strony: największe najpierw, zawsze na stronę z mniejszą liczbą węzłów
  const sides: Side[] = ['right', 'left'];
  const sideLoad: Record<Side, number> = { right: 0, left: 0 };
  const sideBranches: Record<Side, number[]> = { right: [], left: [] };
  const order = roots
    .map((_, i) => i)
    .sort((a, b) => locals[b].size - locals[a].size);
  for (const b of order) {
    const side = sides.reduce((best, s) =>
      sideLoad[s] < sideLoad[best] ? s : best,
    );
    sideBranches[side].push(b);
    sideLoad[side] += locals[b].size;
  }

  // Wysokość gałęzi: tyle węzłów, ile ma jej najszerszy poziom
  const across = (b: number) => locals[b].rows * (NODE_HEIGHT + ROW_GAP);
  const sideSpan = (side: Side) =>
    sideBranches[side].reduce(
      (sum, b) => sum + across(b) + BRANCH_GAP,
      -BRANCH_GAP,
    );

  // Środki ramek względem środka drzewa (0,0)
  const centers: Record<string, { x: number; y: number }> = {};
  if (hasCenter) centers[CENTER_ID] = { x: 0, y: 0 };
  for (const side of sides) {
    // Największe gałęzie w środku strony, mniejsze na zmianę po obu bokach
    const arranged: number[] = [];
    sideBranches[side].forEach((b, i) =>
      i % 2 ? arranged.push(b) : arranged.unshift(b),
    );
    let offset = -sideSpan(side) / 2;
    for (const b of arranged) {
      const local = locals[b];
      local.levels.forEach((onLevel, lv) => {
        if (!onLevel) return;
        // Węzły poziomu wyśrodkowane w poprzek gałęzi
        const shift = (local.rows - onLevel.length) / 2;
        onLevel.forEach((id) => {
          const row = rowOf[id] + shift;
          const dist = NODE_WIDTH + BRANCH_GAP + lv * (NODE_WIDTH + LEVEL_GAP);
          centers[id] = {
            x: side === 'right' ? dist : -dist,
            y: offset + row * (NODE_HEIGHT + ROW_GAP) + NODE_HEIGHT / 2,
          };
        });
      });
      offset += across(b) + BRANCH_GAP;
    }
  }

  // Przesunięcie do dodatnich współrzędnych lewego górnego rogu (SVG z liniami zaczyna się w 0,0)
  const all = Object.values(centers);
  if (!all.length) {
    return { placed: {}, branches: [], width: 0, height: 0 };
  }
  const minX = Math.min(...all.map((c) => c.x));
  const minY = Math.min(...all.map((c) => c.y));
  const maxX = Math.max(...all.map((c) => c.x));
  const maxY = Math.max(...all.map((c) => c.y));
  const placed: Record<string, Placed> = {};
  for (const [id, c] of Object.entries(centers)) {
    placed[id] = {
      id,
      branch: id === CENTER_ID ? -1 : branchOf[id],
      x: c.x - minX,
      y: c.y - minY,
    };
  }
  // Kolejne gałęzie co „złoty kąt” na kole barw, żeby sąsiednie miały wyraźnie różne kolory
  const branches = roots.map((root, i) => ({
    root,
    hue: Math.round((i * 137.5) % 360),
  }));
  return {
    placed,
    branches,
    width: maxX - minX + NODE_WIDTH,
    height: maxY - minY + NODE_HEIGHT,
  };
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
  const layout = useMemo(
    () => layoutTree(nodes, node_cache),
    [layoutKey, node_cache],
  );
  const { placed, branches, width, height } = layout;
  // Ikona gałęzi: pierwszy projekt korzenia gałęzi (albo pierwszego węzła gałęzi, który ma projekty)
  const branchIcons = useMemo(
    () =>
      branches.map((branch) => {
        const own = node_cache[branch.root]?.design_ids ?? [];
        const design = own.find((d) => design_cache[d]);
        if (design) return design_cache[design].class;
        for (const p of Object.values(placed)) {
          if (branches[p.branch] !== branch) continue;
          const found = node_cache[p.id]?.design_ids.find(
            (d) => design_cache[d],
          );
          if (found) return design_cache[found].class;
        }
        return null;
      }),
    [layout],
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

  // Po otwarciu drzewa środek (albo węzeł wybrany z analizatora lub dysku) stoi na środku okna
  useEffect(() => {
    focusNode(
      props.selectedNode ??
        (placed[CENTER_ID] ? CENTER_ID : Object.keys(placed)[0]),
    );
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
      // Linie od środka do środka ramek: w układzie promienistym węzły leżą we wszystkich kierunkach
      const x1 = from.x + NODE_WIDTH / 2;
      const y1 = from.y + NODE_HEIGHT / 2;
      const x2 = p.x + NODE_WIDTH / 2;
      const y2 = p.y + NODE_HEIGHT / 2;
      const highlighted = selected === p.id || selected === pre;
      lines.push(
        <path
          key={`${pre}>${p.id}`}
          d={`M ${x1} ${y1} L ${x2} ${y2}`}
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
                    setView({
                      zoom,
                      x: (box.width - width * zoom) / 2,
                      y: (box.height - height * zoom) / 2,
                    });
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
                  const branch = branches[p.branch];
                  const icon = branch ? branchIcons[p.branch] : null;
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
                        // Pasek w kolorze gałęzi po lewej stronie ramki
                        boxShadow: branch
                          ? `inset 6px 0 0 hsl(${branch.hue}, 70%, 55%)`
                          : undefined,
                      }}
                      onMouseUp={(e) => {
                        if (e.button !== 0 || drag.current?.moved) return;
                        setSelected(p.id === selected ? null : p.id);
                      }}
                    >
                      {!!icon && (
                        <div className="Techweb__TreeNodeIcon">
                          <div className={icon} />
                        </div>
                      )}
                      <div className="Techweb__TreeNodeText">
                        <div className="Techweb__TreeNodeName">
                          {node_cache[p.id].name}
                        </div>
                        <div className="Techweb__TreeNodeTier">
                          Poziom {node_cache[p.id].node_tier}
                        </div>
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
