"""Domyka urwane instalacje w przekonwertowanych mapach ruin (wraki z Shiptesta mają porozrywane rury), aż
tools/ci/check_map_connections.py nie zgłasza „brak połączenia”:
- rura bez żadnego podłączonego końca albo z jednym urwanym końcem znika (przycina urwaną odnogę do rozgałęzienia),
- rozgałęzienie (manifold) z urwaną stroną zamienia się w prostą/zagiętą rurę, czwórnik w trójnik,
- urządzenie (wentylacja, pompa, złącze) i rozdzielacz warstw z urwaną stroną znikają,
- pod terminalem z kilkoma kolorami kabla zostaje kolor pierwszego kabla.
Użycie (z katalogu repo, po convert_maps.py i tools/smartwires/convert.py): python tools/planets/prune_pipes.py <mapy.dmm>
Wypisuje każdą zmianę; sprawdź je, zanim zatwierdzisz mapy.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
sys.path.insert(0, os.path.join(ROOT, 'tools', 'ci'))
sys.path.insert(0, os.path.join(ROOT, 'tools', 'mapmerge2'))
import check_map_connections as checker  # noqa: E402
import dmm  # noqa: E402

ATMOS = '/obj/machinery/atmospherics/'
N, S, E, W = 1, 2, 4, 8
DIR_BY_NAME = {'N': N, 'S': S, 'E': E, 'W': W}
SIMPLE_DIR = {frozenset((N, S)): 1, frozenset((E, W)): 4, frozenset((N, E)): 5, frozenset((S, E)): 6, frozenset((N, W)): 9, frozenset((S, W)): 10}


def atom_dir(atom):
	match = re.search(r'\bdir = (\d+)', atom)
	return int(match.group(1)) if match else 2


def with_dir(path, extra, new_dir):
	"""Atom ze ścieżką i zmiennymi bez starego dir, z nowym dir (2 = domyślny, pomijany)."""
	extra = re.sub(r'\bdir = \d+;? ?', '', extra).strip().strip(';').strip()
	parts = [p for p in [('dir = %d' % new_dir) if new_dir != 2 else '', extra] if p]
	return path + ('{' + '; '.join(parts) + '}' if parts else '')


def sides_of(atom):
	path = atom.split('{')[0]
	rel = path[len(ATMOS):]
	d = atom_dir(atom)
	segs = rel.split('/')
	if 'manifold4w' in segs:
		return {N, S, E, W}
	if 'manifold' in segs:
		return {N, S, E, W} - {d}
	if d in (N, S):
		return {N, S}
	if d in (E, W):
		return {E, W}
	return {x for x in (N, S, E, W) if d & x}


def fix_atom(atom, dangling):
	"""Zwraca nowy atom albo None (usuń). dangling: zbiór urwanych stron."""
	path = atom.split('{')[0]
	extra = atom[len(path) + 1:-1] if '{' in atom else ''
	rel = path[len(ATMOS):]
	if not rel.startswith('pipe/') or rel.startswith('pipe/layer_manifold'):
		return None
	remaining = sides_of(atom) - dangling
	if len(remaining) <= 1:
		return None
	if len(remaining) == 2:
		new_path = path.replace('/manifold4w/', '/simple/').replace('/manifold/', '/simple/')
		return with_dir(new_path, extra, SIMPLE_DIR[frozenset(remaining)])
	if len(remaining) == 3:
		missing = ({N, S, E, W} - remaining).pop()
		return with_dir(path.replace('/manifold4w/', '/manifold/'), extra, missing)
	return atom


def run(maps):
	spawner_size = checker.load_spawner_sizes()
	for _ in range(100):
		problems = []
		for fname in maps:
			problems += checker.check_map(fname, spawner_size)
		todo = {}
		terminals = set()
		for line in problems:
			mapname, coords, short, where, what = line.split('|')
			x, y, z = (int(v) for v in coords.split(','))
			if 'brak połączenia' in what:
				todo.setdefault((mapname, (x, y, z), short), set()).add(DIR_BY_NAME[where[-1]])
			elif 'kilka kolorów kabla' in what:
				terminals.add((mapname, (x, y, z)))
		if not todo and not terminals:
			return
		by_map = {}
		for (mapname, coord, short), sides in todo.items():
			by_map.setdefault(mapname, []).append((coord, short, sides))
		for mapname, coord in terminals:
			by_map.setdefault(mapname, []).append((coord, None, None))
		for mapname, items in by_map.items():
			fname = os.path.join(ROOT, mapname)
			mapdata = dmm.DMM.from_file(fname)
			for coord, short, sides in items:
				tile = list(mapdata.get_tile(coord))
				if short is None:
					cables = [a for a in tile if a.startswith('/obj/structure/cable')]
					keep = cables[0].split('{')[0]
					new_tile = [a for a in tile if not a.startswith('/obj/structure/cable') or a.split('{')[0] == keep]
					print('%s %s: kable pod terminalem -> %s' % (mapname, coord, keep))
				else:
					full = ATMOS + short
					new_tile = []
					done = False
					for a in tile:
						if not done and a.split('{')[0] == full:
							done = True
							fixed = fix_atom(a, sides)
							print('%s %s: %s -> %s' % (mapname, coord, a, fixed))
							if fixed:
								new_tile.append(fixed)
						else:
							new_tile.append(a)
				mapdata.set_tile(coord, tuple(new_tile))
			mapdata.to_file(fname)
	raise SystemExit('Nie udało się domknąć instalacji w 100 przebiegach')


if __name__ == '__main__':
	run([os.path.abspath(p) for p in sys.argv[1:]])
