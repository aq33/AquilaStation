// AQUILA: sieć badań podzielona na kategorie tematyczne (techweb_categories.dm). Widok jednej kategorii:
// kolumny według kolejności wymagań, duże karty z ikoną wiodącej technologii, linie tylko wewnątrz
// kategorii, a wymagania z innych kategorii jako klikalne etykiety. Widok „Wszystkie”: wszystkie kategorie
// naraz w siatce, w mniejszych kartach. Kategorie są niezależnymi drzewkami (wymagania przebudowuje DM).
import { useEffect, useMemo, useState } from 'react';
import { Box, Button, Icon, Input, Section, Stack } from 'tgui-core/components';

import { abbreviatePoint, useRemappedBackend } from './helpers';
import { TechNode } from './nodes/TechNode';
import type { DesignCache, NodeCache, TechwebNode } from './types';

type Category = { key: string; name: string; icon: string; hue: number };

const CATEGORIES: Category[] = [
  {
    key: 'medical',
    name: 'Medycyna i biologia',
    icon: 'heart-pulse',
    hue: 140,
  },
  { key: 'robotics', name: 'Robotyka i cyborgi', icon: 'robot', hue: 280 },
  {
    key: 'exosuits',
    name: 'Egzoszkielety i hardsuity',
    icon: 'user-astronaut',
    hue: 30,
  },
  { key: 'weapons', name: 'Uzbrojenie', icon: 'crosshairs', hue: 0 },
  { key: 'ship', name: 'Statek i myśliwce', icon: 'rocket', hue: 200 },
  { key: 'bluespace', name: 'Bluespace i anomalie', icon: 'atom', hue: 250 },
  {
    key: 'computing',
    name: 'Informatyka i nanity',
    icon: 'microchip',
    hue: 180,
  },
  {
    key: 'engineering',
    name: 'Inżynieria i górnictwo',
    icon: 'wrench',
    hue: 55,
  },
];
const ALL = 'all';

const categoryOf = (cache?: NodeCache) =>
  CATEGORIES.find((c) => c.key === cache?.category) ??
  CATEGORIES[CATEGORIES.length - 1];

const stateOf = (node?: TechwebNode) =>
  node?.tier === 0 ? 'researched' : node?.tier === 1 ? 'available' : 'future';

type CardSize = { w: number; h: number; colGap: number; rowGap: number };
const FULL: CardSize = { w: 230, h: 64, colGap: 64, rowGap: 12 };
const COMPACT: CardSize = { w: 175, h: 44, colGap: 34, rowGap: 8 };

type BlockLayout = {
  pos: Record<string, { x: number; y: number }>;
  width: number;
  height: number;
};

/** Kolumny = kolejne kroki wymagań w kategorii; kolejność w kolumnie wg średniej pozycji wymagań */
function layoutBlock(
  ids: string[],
  node_cache: Record<string, NodeCache>,
  size: CardSize,
): BlockLayout {
  const inBlock = new Set(ids);
  // Kolumna = najdłuższa ścieżka wymagań wewnątrz kategorii, więc linie zawsze idą w prawo
  const depth: Record<string, number> = {};
  const visiting = new Set<string>();
  const getDepth = (id: string): number => {
    if (depth[id] !== undefined) return depth[id];
    if (visiting.has(id)) return 0; // cykl w danych nie zawiesi okna
    visiting.add(id);
    let d = 0;
    for (const pre of node_cache[id].prereq_ids) {
      if (inBlock.has(pre)) d = Math.max(d, getDepth(pre) + 1);
    }
    visiting.delete(id);
    depth[id] = d;
    return d;
  };
  ids.forEach(getDepth);
  const columns = Math.max(0, ...ids.map((id) => depth[id] + 1));
  const rowOf: Record<string, number> = {};
  const pos: Record<string, { x: number; y: number }> = {};
  let rows = 0;
  for (let col = 0; col < columns; col++) {
    const column = ids.filter((id) => depth[id] === col);
    const keyed = column.map((id) => {
      const parents = node_cache[id].prereq_ids.filter(
        (p) => inBlock.has(p) && rowOf[p] !== undefined,
      );
      const key = parents.length
        ? parents.reduce((sum, p) => sum + rowOf[p], 0) / parents.length
        : -1;
      return { id, key, name: node_cache[id].name };
    });
    keyed.sort((a, b) => a.key - b.key || a.name.localeCompare(b.name));
    keyed.forEach((entry, row) => {
      rowOf[entry.id] = row;
      pos[entry.id] = {
        x: col * (size.w + size.colGap),
        y: row * (size.h + size.rowGap),
      };
    });
    rows = Math.max(rows, keyed.length);
  }
  return {
    pos,
    width: Math.max(0, columns * (size.w + size.colGap) - size.colGap),
    height: Math.max(0, rows * (size.h + size.rowGap) - size.rowGap),
  };
}

/** Ikona wiodącej technologii węzła: jego pierwszy projekt z obrazkiem */
const leadIcon = (
  cache: NodeCache,
  design_cache: Record<string, DesignCache>,
) => {
  const design = cache.design_ids.find((d) => design_cache[d]);
  return design ? design_cache[design].class : null;
};

export function TechwebTree(props: { selectedNode?: string }) {
  const { data } = useRemappedBackend();
  const { nodes, node_cache, design_cache } = data;
  const [selected, setSelected] = useState<string | null>(
    props.selectedNode ?? null,
  );
  const [view, setView] = useState<string>(
    props.selectedNode && node_cache[props.selectedNode]
      ? categoryOf(node_cache[props.selectedNode]).key
      : ALL,
  );
  const [searchText, setSearchText] = useState('');
  const [onlyAvailable, setOnlyAvailable] = useState(false);

  // node_cache i design_cache to dane statyczne zbuforowane raz w useRemappedBackend, więc nie ma ich w zależnościach
  const byId = useMemo(() => {
    const result: Record<string, TechwebNode> = {};
    for (const n of nodes) {
      if (node_cache[n.id]) result[n.id] = n;
    }
    return result;
  }, [nodes]);

  // Węzły każdej kategorii (bez węzłów ukrytych w sieci)
  const layoutKey = Object.keys(byId).join(',');
  const idsByCategory = useMemo(() => {
    const result: Record<string, string[]> = {};
    for (const c of CATEGORIES) result[c.key] = [];
    for (const id of Object.keys(byId)) {
      result[categoryOf(node_cache[id]).key].push(id);
    }
    return result;
  }, [layoutKey]);

  const query = searchText.trim().toLowerCase();
  const matches = useMemo(() => {
    if (query.length < 2) return null;
    const found = new Set<string>();
    for (const id of Object.keys(byId)) {
      const c = node_cache[id];
      if (
        c.name.toLowerCase().includes(query) ||
        c.description.toLowerCase().includes(query) ||
        c.design_ids.some((e) =>
          design_cache[e]?.name.toLowerCase().includes(query),
        )
      ) {
        found.add(id);
      }
    }
    return found;
  }, [query, layoutKey]);

  // Cała ścieżka wymagań wybranego węzła, także przez inne kategorie
  const path = useMemo(() => {
    const result = new Set<string>();
    const stack = selected ? [selected] : [];
    while (stack.length) {
      const id = stack.pop()!;
      for (const pre of node_cache[id]?.prereq_ids ?? []) {
        if (byId[pre] && !result.has(pre)) {
          result.add(pre);
          stack.push(pre);
        }
      }
    }
    return result;
  }, [selected, layoutKey]);

  const pick = (id: string, openCategory = false) => {
    setSelected(id);
    if (openCategory) setView(categoryOf(node_cache[id]).key);
  };

  // Wybrany węzeł zawsze widoczny w przewijanym obszarze
  useEffect(() => {
    if (selected) {
      document
        .getElementById(`techweb-node-${selected}`)
        ?.scrollIntoView({ block: 'nearest', inline: 'nearest' });
    }
  }, [selected, view]);

  const dimmed = (id: string) =>
    (!!matches && !matches.has(id)) ||
    (onlyAvailable && stateOf(byId[id]) !== 'available');

  const renderBlock = (category: Category, compact: boolean) => (
    <CategoryBlock
      key={category.key}
      category={category}
      ids={idsByCategory[category.key]}
      size={compact ? COMPACT : FULL}
      compact={compact}
      byId={byId}
      node_cache={node_cache}
      design_cache={design_cache}
      selected={selected}
      path={path}
      dimmed={dimmed}
      onPick={pick}
      onOpen={() => setView(category.key)}
    />
  );

  const current = CATEGORIES.find((c) => c.key === view);
  const selectedNode = selected ? byId[selected] : null;

  return (
    <Stack fill>
      <Stack.Item width="20em" shrink={0}>
        <Section fill scrollable title="Kategorie">
          <CategoryButton
            name="Wszystkie"
            icon="table-cells"
            done={Object.values(byId).filter((n) => n.tier === 0).length}
            total={Object.keys(byId).length}
            hue={-1}
            active={view === ALL}
            onClick={() => setView(ALL)}
          />
          {CATEGORIES.map((category) => {
            const ids = idsByCategory[category.key];
            return (
              <CategoryButton
                key={category.key}
                name={category.name}
                icon={category.icon}
                done={ids.filter((id) => byId[id].tier === 0).length}
                total={ids.length}
                hue={category.hue}
                active={view === category.key}
                onClick={() => setView(category.key)}
              />
            );
          })}
          <Box mt={1}>
            <Button.Checkbox
              fluid
              checked={onlyAvailable}
              tooltip="Przygasza wszystko, czego nie da się teraz zbadać"
              onClick={() => setOnlyAvailable(!onlyAvailable)}
            >
              Tylko dostępne
            </Button.Checkbox>
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
        <Stack vertical fill>
          <Stack.Item>
            <Stack align="center" className="Techweb__HeaderSectionTabs">
              <Stack.Item grow className="Techweb__HeaderTabTitle">
                {current ? (
                  <>
                    <Icon name={current.icon} mr={1} />
                    {current.name}
                  </>
                ) : (
                  'Wszystkie kategorie'
                )}
              </Stack.Item>
              <Stack.Item>
                <Input
                  value={searchText}
                  onChange={setSearchText}
                  onEnter={() => {
                    const first = matches && Array.from(matches)[0];
                    if (first) pick(first, true);
                  }}
                  placeholder="Szukaj we wszystkich kategoriach..."
                  width="20em"
                  expensive
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis={0} position="relative">
            <div className="Techweb__CatArea">
              {current ? (
                renderBlock(current, false)
              ) : (
                <div className="Techweb__CatGrid">
                  {CATEGORIES.map((category) => renderBlock(category, true))}
                </div>
              )}
            </div>
          </Stack.Item>
          <Stack.Item className="Techweb__CatLegend">
            <span className="Techweb__CatLegend--researched">■</span> zbadane ·{' '}
            <span className="Techweb__CatLegend--available">■</span> dostępne ·{' '}
            <span className="Techweb__CatLegend--future">■</span> przyszłe ·
            żółta etykieta: wymaganie z innej kategorii (kliknij, żeby przejść)
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {!!selectedNode && (
        <Stack.Item width="24em" shrink={0}>
          <Section
            fill
            scrollable
            title={categoryOf(node_cache[selectedNode.id]).name}
            buttons={<Button icon="times" onClick={() => setSelected(null)} />}
          >
            <TechNode node={selectedNode} nodetails />
            <NodeLinks
              title="Wymaga"
              ids={node_cache[selectedNode.id].prereq_ids}
              byId={byId}
              node_cache={node_cache}
              onPick={(id) => pick(id, true)}
            />
            <NodeLinks
              title="Odblokowuje"
              ids={node_cache[selectedNode.id].unlock_ids}
              byId={byId}
              node_cache={node_cache}
              onPick={(id) => pick(id, true)}
            />
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
}

type CategoryButtonProps = {
  name: string;
  icon: string;
  done: number;
  total: number;
  hue: number;
  active: boolean;
  onClick: () => void;
};

function CategoryButton(props: CategoryButtonProps) {
  const { name, icon, done, total, hue, active, onClick } = props;
  return (
    <div
      className={`Techweb__CatButton${active ? ' Techweb__CatButton--active' : ''}`}
      style={
        hue >= 0 ? { borderLeftColor: `hsl(${hue}, 65%, 55%)` } : undefined
      }
      onClick={onClick}
    >
      <Stack>
        <Stack.Item grow>
          <Icon name={icon} mr={1} />
          {name}
        </Stack.Item>
        <Stack.Item color="label">
          {done}/{total}
        </Stack.Item>
      </Stack>
      <div className="Techweb__CatBar">
        <div style={{ width: `${total ? (done / total) * 100 : 0}%` }} />
      </div>
    </div>
  );
}

type CategoryBlockProps = {
  category: Category;
  ids: string[];
  size: CardSize;
  compact: boolean;
  byId: Record<string, TechwebNode>;
  node_cache: Record<string, NodeCache>;
  design_cache: Record<string, DesignCache>;
  selected: string | null;
  path: Set<string>;
  dimmed: (id: string) => boolean;
  onPick: (id: string, openCategory?: boolean) => void;
  onOpen: () => void;
};

function CategoryBlock(props: CategoryBlockProps) {
  const {
    category,
    ids,
    size,
    compact,
    byId,
    node_cache,
    design_cache,
    selected,
    path,
    dimmed,
    onPick,
    onOpen,
  } = props;
  const layout = useMemo(() => layoutBlock(ids, node_cache, size), [ids, size]);
  const inBlock = new Set(ids);
  const color = `hsl(${category.hue}, 65%, 55%)`;

  const lines: React.ReactNode[] = [];
  for (const id of ids) {
    for (const pre of node_cache[id].prereq_ids) {
      if (!inBlock.has(pre)) continue;
      const from = layout.pos[pre];
      const to = layout.pos[id];
      if (!from || !to) continue;
      const x1 = from.x + size.w;
      const y1 = from.y + size.h / 2;
      const x2 = to.x;
      const y2 = to.y + size.h / 2;
      const mid = (x1 + x2) / 2;
      const lit =
        (selected === id || path.has(id)) &&
        (pre === selected || path.has(pre));
      lines.push(
        <path
          key={`${pre}>${id}`}
          d={`M ${x1} ${y1} C ${mid} ${y1}, ${mid} ${y2}, ${x2} ${y2}`}
          className={`Techweb__CatLine${lit ? ' Techweb__CatLine--lit' : ''}`}
        />,
      );
    }
  }

  return (
    <div className="Techweb__CatBlock">
      <div
        className="Techweb__CatBlockTitle"
        style={{ color }}
        onClick={compact ? onOpen : undefined}
      >
        <Icon name={category.icon} mr={1} />
        {category.name} ({ids.filter((id) => byId[id].tier === 0).length}/
        {ids.length})
      </div>
      <div
        className="Techweb__CatCanvas"
        style={{ width: `${layout.width}px`, height: `${layout.height}px` }}
      >
        <svg
          className="Techweb__CatLines"
          width={layout.width}
          height={layout.height}
        >
          {lines}
        </svg>
        {ids.map((id) => {
          const cache = node_cache[id];
          const node = byId[id];
          const state = stateOf(node);
          const icon = leadIcon(cache, design_cache);
          const p = layout.pos[id];
          const outside = cache.prereq_ids.filter(
            // Podstawy wymaga każda kategoria, więc nie dostają etykiety
            (pre) => byId[pre] && !inBlock.has(pre) && pre !== 'base',
          );
          const costs = Object.entries(node.costs ?? {})
            .map(([type, cost]) => `${cost} ${abbreviatePoint(type)}`)
            .join(', ');
          return (
            <div
              key={id}
              id={`techweb-node-${id}`}
              className={[
                'Techweb__Card',
                `Techweb__Card--${state}`,
                compact && 'Techweb__Card--compact',
                selected === id && 'Techweb__Card--selected',
                path.has(id) && 'Techweb__Card--path',
                dimmed(id) && 'Techweb__Card--dim',
                node.can_unlock &&
                  state === 'available' &&
                  'Techweb__Card--ready',
              ]
                .filter(Boolean)
                .join(' ')}
              style={{
                left: `${p.x}px`,
                top: `${p.y}px`,
                width: `${size.w}px`,
                height: `${size.h}px`,
                borderLeftColor: color,
              }}
              onClick={() => onPick(id)}
            >
              <div className="Techweb__CardIcon">
                {icon ? (
                  <div className={icon} />
                ) : (
                  <Icon name={category.icon} />
                )}
              </div>
              <div className="Techweb__CardText">
                <div className="Techweb__CardName">{cache.name}</div>
                {!compact && (
                  <div className="Techweb__CardMeta">
                    Poziom {cache.node_tier} ·{' '}
                    {state === 'researched' ? 'zbadane' : costs || 'za darmo'}
                  </div>
                )}
                {!compact &&
                  outside.slice(0, 1).map((pre) => (
                    <div
                      key={pre}
                      className="Techweb__CardChip"
                      title={outside
                        .map(
                          (o) =>
                            `${node_cache[o].name} (${categoryOf(node_cache[o]).name})`,
                        )
                        .join(', ')}
                      onClick={(e) => {
                        e.stopPropagation();
                        onPick(pre, true);
                      }}
                    >
                      wymaga: {node_cache[pre].name} (
                      {categoryOf(node_cache[pre]).name})
                      {outside.length > 1 ? ` +${outside.length - 1}` : ''}
                    </div>
                  ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
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
          icon={byId[id].tier === 0 ? 'check' : undefined}
          className={`Techweb__TreeLink--${stateOf(byId[id])}`}
          onClick={() => onPick(id)}
        >
          {node_cache[id].name} ({categoryOf(node_cache[id]).name})
        </Button>
      ))}
    </Box>
  );
}
