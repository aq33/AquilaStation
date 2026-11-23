"""Przycina urwane instalacje atmosferyczne w przekonwertowanych mapach (ruiny Shiptesta po usunięciu silników statków,
zbiorników paliwa, podgrzewaczy i podobnych urządzeń, których nie mamy), aż tools/ci/check_map_connections.py nie
zgłasza „brak połączenia”:
- rura z jednym urwanym końcem traci ten wylot (rozgałęzienie -> rura prosta albo kolano, kolano z jednym wylotem znika);
- urządzenia (pompy, zawory, wyloty, zbiorniki) i rozgałęźniki warstw z urwanym wylotem znikają;
powtarza, bo usunięcie odsłania kolejne urwane końce. Terminali (kolory kabli) nie rusza: te poprawia się ręcznie.

Użycie: python tools/planets/fix_connections.py <mapy.dmm>
"""
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'mapmerge2'))
sys.path.insert(0, os.path.join(HERE, '..', 'ci'))
import check_map_connections as checker  # noqa: E402
import dmm  # noqa: E402

N, S, E, W = 1, 2, 4, 8
NAME_DIR = {'N': N, 'S': S, 'E': E, 'W': W}
ATMOS = '/obj/machinery/atmospherics/'


def atom_layer(atom):
	part = checker.make_part(atom)
	return part.layer if part else None


def set_dir(atom, new_dir):
	path, values = atom.split('{', 1) if '{' in atom else (atom, '')
	body = values[:-1] if values.endswith('}') else values
	fields = [f.strip() for f in body.split(';') if f.strip() and not f.strip().startswith('dir')]
	if new_dir != 2:
		fields.insert(0, 'dir = %d' % new_dir)
	return path + ('{' + '; '.join(fields) + '}' if fields else '')


def reshape(atom, keep):
	"""Rura z wylotami keep (zbiór kierunków): nowy atom albo None (usunąć)."""
	path = atom.split('{', 1)[0]
	segs = path.split('/')
	kind = next((s for s in ('manifold4w', 'manifold', 'simple') if s in segs), None)
	if kind is None or len(keep) < 2:
		return None
	if len(keep) == 4:
		return atom
	if len(keep) == 3:
		missing = ({N, S, E, W} - keep).pop()
		new_path = path.replace('/' + kind + '/', '/manifold/')
		return set_dir(new_path + (atom[len(path):] if '{' in atom else ''), missing)
	a, b = sorted(keep)
	new_path = path.replace('/' + kind + '/', '/simple/')
	rest = atom[len(path):] if '{' in atom else ''
	if a | b in (N | S, E | W):
		return set_dir(new_path + rest, a)
	return set_dir(new_path + rest, a | b)


def fix_map(fname, spawner_size):
	removed = changed = 0
	for _ in range(200):
		problems = [p for p in checker.check_map(fname, spawner_size) if p.endswith('brak połączenia')]
		if not problems:
			break
		dangling = collections.defaultdict(set)
		for line in problems:
			_, coords, short, where, _ = line.split('|')
			x, y, z = (int(v) for v in coords.split(','))
			m = re.match(r'L([0-9*])([NSEW])', where)
			dangling[(x, y, z, ATMOS + short if not short.startswith('/') else short, m.group(1))].add(NAME_DIR[m.group(2)])
		mapdata = dmm.DMM.from_file(fname)
		tiles = {c: list(mapdata.dictionary[k]) for c, k in mapdata.grid.items()}
		for (x, y, z, path, layer), dirs in dangling.items():
			tile = tiles[(x, y, z)]
			for i, atom in enumerate(tile):
				if atom.split('{', 1)[0] != path:
					continue
				part = checker.make_part(atom)
				part_layer = '*' if part.layer == 'all' else str(part.layer)
				if part_layer != layer or not dirs & set(part.dirs):
					continue
				new = reshape(atom, set(part.dirs) - dirs) if path.startswith(ATMOS + 'pipe/') and 'layer_manifold' not in path else None
				if new is None:
					del tile[i]
					removed += 1
				else:
					tile[i] = new
					changed += 1
				break
		out = dmm.DMM(mapdata.key_length, mapdata.size)
		for coord, tile in tiles.items():
			out.set_tile(coord, tuple(tile))
		try:
			out.to_file(fname)
		except Exception:
			out.key_length = 3
			out.to_file(fname)
	return removed, changed


def main():
	spawner_size = checker.load_spawner_sizes()
	for fname in sys.argv[1:]:
		removed, changed = fix_map(fname, spawner_size)
		if removed or changed:
			print('%s: usunięto %d, przerobiono %d' % (fname, removed, changed))


if __name__ == '__main__':
	main()
