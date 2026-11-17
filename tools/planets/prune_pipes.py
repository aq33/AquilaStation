"""Naprawia w przekonwertowanych mapach ruin wiszące kawałki instalacji, które zgłasza
tools/ci/check_map_connections.py, i powtarza sprawdzenie, aż map nie zostaną żadne problemy.

Zasada: sieć ma przetrwać, odcina się tylko to, co wisi.
- rozgałęzienie z jedną stroną bez połączenia zmienia kształt: czwórnik -> trójnik bez tej strony, trójnik -> prosta
  rura albo kolanko między pozostałymi stronami;
- prosta rura albo kolanko bez połączenia z jednej strony, urządzenie jednostronne (wentylacja, złącze) bez rury
  i layer manifold bez połączenia znikają (ewentualnie odsłaniając następną końcówkę, którą naprawia kolejny przebieg);
- rury nachodzące na siebie: druga znika; terminal bez kabla (albo z kablami w kilku kolorach) znika.
Ruiny Shiptesta mają instalacje urwane już w oryginale albo zepsute przy konwersji (inne urządzenia i warstwy).

Użycie (z katalogu repo): python tools/planets/prune_pipes.py <mapy...>
"""
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'ci'))
sys.path.insert(0, os.path.join(HERE, '..', 'mapmerge2'))
import check_map_connections as checker  # noqa: E402
import dmm as dmmlib  # noqa: E402

MAX_PASSES = 300
N, S, E, W = 1, 2, 4, 8
NAME_DIR = {'N': N, 'S': S, 'E': E, 'W': W}
CARDINALS = (N, S, E, W)
REV = {N: S, S: N, E: W, W: E}


def atom_dir(atom):
	match = re.search(r'\bdir = (\d+)', atom)
	return int(match.group(1)) if match else S


def with_dir(atom, new_path, new_dir):
	"""Atom z nową ścieżką i kierunkiem, z zachowaniem pozostałych edycji."""
	path, _, rest = atom.partition('{')
	edits = [e.strip() for e in rest.rstrip('}').split(';') if e.strip()] if rest else []
	edits = [e for e in edits if not e.startswith('dir =')]
	if new_dir != S:
		edits.insert(0, 'dir = %d' % new_dir)
	return new_path + ('{' + '; '.join(edits) + '}' if edits else '')


def reshape(atom, missing_dir):
	"""Nowy atom bez strony missing_dir albo None (usuń)."""
	path = atom.split('{')[0]
	if '/pipe/manifold4w/' in path:
		# trójnik łączy wszystkie strony poza swoim dir
		return with_dir(atom, path.replace('/manifold4w/', '/manifold/'), missing_dir)
	if '/pipe/manifold/' in path:
		sides = [d for d in CARDINALS if d != atom_dir(atom) and d != missing_dir]
		if len(sides) != 2:
			return None
		new_dir = sides[0] if REV[sides[0]] == sides[1] else sides[0] | sides[1]
		if new_dir in (N, S):
			new_dir = N if new_dir == N else S
		return with_dir(atom, path.replace('/manifold/', '/simple/'), new_dir)
	return None


def prune(path, spawner_size):
	changes = collections.Counter()
	for _ in range(MAX_PASSES):
		problems = checker.check_map(path, spawner_size)
		if not problems:
			break
		m = dmmlib.DMM.from_file(path)
		grid = {coord: list(m.dictionary[key]) for coord, key in m.grid.items()}
		touched = set()
		for line in problems:
			_, coords, short, where, what = line.split('|')
			x, y, z = (int(v) for v in coords.split(','))
			if (x, y, z) in touched:
				continue
			tile = grid.get((x, y, z))
			if tile is None:
				continue
			if what.startswith('terminal') or what.startswith('kilka kolorów'):
				grid[(x, y, z)] = [a for a in tile if not a.startswith('/obj/machinery/power/terminal')]
				changes['terminal'] += 1
				touched.add((x, y, z))
				continue
			full = short if short.startswith('/') else checker.ATMOS + short
			for i, atom in enumerate(tile):
				if atom.split('{')[0] != full:
					continue
				missing_dir = NAME_DIR.get(where[-1]) if what.startswith('brak') else None
				new_atom = reshape(atom, missing_dir) if missing_dir else None
				if new_atom:
					tile[i] = new_atom
					changes['przerobione'] += 1
				else:
					del tile[i]
					changes['usunięte'] += 1
				touched.add((x, y, z))
				break
		if not touched:
			break
		new = dmmlib.DMM(m.key_length, m.size)
		for coord, tile in grid.items():
			new.set_tile(coord, tuple(tile))
		try:
			new.to_file(path)
		except Exception:
			new.key_length = 3
			new.to_file(path)
	return changes, checker.check_map(path, spawner_size)


def main():
	spawner_size = checker.load_spawner_sizes()
	status = 0
	for path in sys.argv[1:]:
		changes, left = prune(path, spawner_size)
		print(os.path.basename(path), dict(changes), 'zostało:', len(left))
		for line in left:
			print('   ', line)
		if left:
			status = 1
	return status


if __name__ == '__main__':
	sys.exit(main())
