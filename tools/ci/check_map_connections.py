#!/usr/bin/env python3
"""AQUILA - statyczna kontrola rur atmosferycznych i terminali zasilania na mapach.

Szuka końcówek rur i urządzeń, które nie mają z kim się połączyć (rura urwana w ścianie, zła warstwa,
zwykła rura wpięta w wymiennik ciepła, filtr obrócony w złą stronę), oraz dwóch rur na jednej warstwie
nachodzących na siebie na tym samym kafelku, a także terminale SMES-ów i APC bez kabla albo z kablami
w kilku kolorach (terminal bierze pierwszy kabel z kafelka). Reguły rur jak w code/modules/atmospherics:
- unary: łączy się w stronę `dir`; binary: `dir` i przeciwna; trinary: `dir`, przeciwna i turn(dir, -90);
- manifold: wszystkie strony poza `dir`; layer manifold łączy wszystkie warstwy wzdłuż swojej osi;
- rury wymiennika ciepła łączą się tylko ze sobą, złączka HE ma stronę HE w kierunku `dir`;
- warstwa z podtypu /layerN albo z `piping_layer`, domyślnie 3.
Urządzenia o nietypowym kształcie (reaktory, cyrkulatory, wielokafelkowe maszyny) są traktowane jak
„coś, do czego da się podłączyć” i same nie są sprawdzane. Kafelki szablonów (template_noop) i sloty
losowych pokoi (/obj/effect/spawner/room) są nieznane, więc rura kończąca się na nich nie jest błędem.

Stare błędy są w tools/ci/map_connections_baseline.txt. CI odrzuca tylko nowe; po poprawieniu starego
uruchom z --update-baseline, żeby wypadł z listy.

Użycie: python tools/ci/check_map_connections.py [--update-baseline] [mapy...]
"""
import glob
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from mapmerge2 import dmm  # noqa: E402

N, S, E, W = 1, 2, 4, 8
CARDINALS = (N, S, E, W)
STEP = {N: (0, 1), S: (0, -1), E: (1, 0), W: (-1, 0)}
REV = {N: S, S: N, E: W, W: E}
CW = {N: E, E: S, S: W, W: N}  # turn(dir, -90)
DIR_NAME = {N: 'N', S: 'S', E: 'E', W: 'W'}
ATMOS = '/obj/machinery/atmospherics/'
ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
BASELINE = os.path.join(ROOT, 'tools', 'ci', 'map_connections_baseline.txt')

UNARY = ('vent_pump', 'vent_scrubber', 'outlet_injector', 'portables_connector', 'passive_vent',
	'thermomachine', 'tank', 'cryo_cell', 'heat_exchanger')
BINARY = ('pump', 'volume_pump', 'passive_gate', 'valve', 'pressure_valve', 'dp_vent_pump', 'temperature_gate')
TRINARY = ('filter', 'mixer')


def parse_atom(atom):
	m = re.match(r'([^{]+)(?:\{(.*)\})?$', atom, re.S)
	path, body = m.group(1).strip(), m.group(2) or ''
	values = {}
	for part in body.split(';'):
		if '=' in part:
			k, v = part.split('=', 1)
			values[k.strip()] = v.strip().strip('"')
	return path, values


class Part:
	"""Jedno urządzenie atmosferyczne na kafelku."""
	__slots__ = ('path', 'layer', 'dirs', 'he_dirs', 'kind', 'wildcard')

	def __init__(self, path, layer, dirs, he_dirs=(), kind='pipe', wildcard=False):
		self.path, self.layer, self.dirs, self.he_dirs, self.kind, self.wildcard = path, layer, dirs, he_dirs, kind, wildcard

	def is_he(self, d):
		return self.kind == 'he' or (self.kind == 'junction' and d in self.he_dirs)


def make_part(atom):
	path, v = parse_atom(atom)
	if not path.startswith(ATMOS) or '/meter' in path or path.startswith(ATMOS + 'miner'):
		return None
	try:
		d = int(v.get('dir', 2))
	except ValueError:
		return None
	layer = 3
	m = re.search(r'/layer([1-5])(?:/|$)', path)
	if m:
		layer = int(m.group(1))
	if 'piping_layer' in v:
		try:
			layer = int(v['piping_layer'])
		except ValueError:
			pass
	rel = path[len(ATMOS):]
	segs = rel.split('/')
	if rel.startswith('pipe/layer_manifold'):
		return Part(path, 'all', (E, W) if d in (E, W) else (N, S))
	if rel.startswith('pipe/heat_exchanging/junction'):
		return Part(path, layer, (REV[d], d), (d,), 'junction')
	if rel.startswith('pipe/multiz'):
		return Part(path, layer, (d,))
	if rel.startswith('pipe/'):
		kind = 'he' if rel.startswith('pipe/heat_exchanging/') else 'pipe'
		if 'manifold4w' in segs:
			return Part(path, layer, CARDINALS, kind=kind)
		if 'manifold' in segs:
			return Part(path, layer, tuple(x for x in CARDINALS if x != d), kind=kind)
		if 'simple' in segs:
			if d in (N, S):
				return Part(path, layer, (N, S), kind=kind)
			if d in (E, W):
				return Part(path, layer, (E, W), kind=kind)
			return Part(path, layer, tuple(x for x in CARDINALS if d & x), kind=kind)
		return Part(path, layer, CARDINALS, wildcard=True)
	if d not in CARDINALS:
		return Part(path, layer, CARDINALS, wildcard=True)
	if len(segs) > 2 and segs[0] == 'components':
		if segs[1] == 'unary' and segs[2] in UNARY:
			return Part(path, layer, (d,))
		if segs[1] == 'binary' and segs[2] in BINARY:
			return Part(path, layer, (d, REV[d]))
		if segs[1] == 'trinary' and segs[2] in TRINARY:
			return Part(path, layer, (REV[d], CW[d], d))
	# reaktory, cyrkulatory, maszyny wielokafelkowe: nie modelujemy, ale da się do nich podłączyć
	return Part(path, layer, CARDINALS, wildcard=True)


def load_spawner_sizes():
	"""room_width/room_height każdego /obj/effect/spawner/room z kodu (z dziedziczeniem po rodzicu)."""
	sizes = {}
	current = None
	files = glob.glob(os.path.join(ROOT, 'code', '**', '*.dm'), recursive=True)
	files += glob.glob(os.path.join(ROOT, 'nsv13', '**', '*.dm'), recursive=True)
	files += glob.glob(os.path.join(ROOT, 'aquila', '**', '*.dm'), recursive=True)
	for fname in files:
		with open(fname, encoding='utf-8', errors='replace') as f:
			for line in f:
				m = re.match(r'(/obj/effect/spawner/room[\w/]*)\s*$', line.rstrip())
				if m:
					current = m.group(1)
					sizes.setdefault(current, {})
					continue
				if line[:1] not in ('\t', ' ') and line.strip():
					current = None
					continue
				if current:
					m = re.match(r'\s+(room_width|room_height)\s*=\s*(\d+)', line)
					if m:
						sizes[current][m.group(1)] = int(m.group(2))

	def lookup(path, key):
		while path:
			if key in sizes.get(path, {}):
				return sizes[path][key]
			path = path.rsplit('/', 1)[0]
		return 0
	return lambda path: (lookup(path, 'room_width'), lookup(path, 'room_height'))


def check_map(fname, spawner_size):
	try:
		mapdata = dmm.DMM.from_file(fname)
	except Exception as e:  # noqa: BLE001 - każdy błąd wczytania to błąd mapy, nie przerywamy reszty
		return [f'{os.path.relpath(fname, ROOT).replace(chr(92), "/")}|-|-|-|nie da się wczytać mapy: {e}']
	maxx, maxy = mapdata.size[0], mapdata.size[1]
	key_parts = {}
	key_unknown = {}
	key_spawners = {}
	key_power = {}
	for key, atoms in mapdata.dictionary.items():
		key_power[key] = power_problem(atoms)
		key_parts[key] = [p for p in (make_part(a) for a in atoms) if p]
		key_unknown[key] = any('template_noop' in a for a in atoms)
		key_spawners[key] = [parse_atom(a)[0] for a in atoms if a.startswith('/obj/effect/spawner/room')]
	parts = {}
	unknown = set()
	rel = os.path.relpath(fname, ROOT).replace('\\', '/')
	problems = []
	for (x, y, z), key in mapdata.grid.items():  # dmm.py zwraca już współrzędne BYOND (y rośnie na północ)
		if key_power[key]:
			problems.append(f'{rel}|{x},{y},{z}|power/terminal|-|{key_power[key]}')
		if key_parts[key]:
			parts[x, y, z] = key_parts[key]
		if key_unknown[key]:
			unknown.add((x, y, z))
		for spawner in key_spawners[key]:
			w, h = spawner_size(spawner)
			for sx in range(x, x + w):
				for sy in range(y, y + h):
					unknown.add((sx, sy, z))
	for (x, y, z), lst in parts.items():
		# dwie rury na jednej warstwie wychodzące z kafelka w tę samą stronę
		seen = {}
		for p in lst:
			if p.wildcard:
				continue
			for d in p.dirs:
				layers = (1, 2, 3, 4, 5) if p.layer == 'all' else (p.layer,)
				for layer in layers:
					# rura wymiennika ciepła i zwykła rura się nie łączą, więc mogą leżeć obok siebie
					slot = (layer, d, p.is_he(d))
					other = seen.get(slot)
					if other is not None and other is not p:
						problems.append(f'{rel}|{x},{y},{z}|{short(p.path)}|L{layer}{DIR_NAME[d]}|nakłada się na {short(other.path)}')
					seen[slot] = p
		for p in lst:
			if p.wildcard:
				continue
			for d in p.dirs:
				dx, dy = STEP[d]
				nx, ny = x + dx, y + dy
				if not (1 <= nx <= maxx and 1 <= ny <= maxy) or (nx, ny, z) in unknown:
					continue
				if not connects(p, d, parts.get((nx, ny, z), ())):
					layer = p.layer if p.layer != 'all' else '*'
					problems.append(f'{rel}|{x},{y},{z}|{short(p.path)}|L{layer}{DIR_NAME[d]}|brak połączenia')
	return problems


def power_problem(atoms):
	"""Terminal SMES-a/APC bierze pierwszy kabel z kafelka (code/modules/power/power.dm), więc musi mieć dokładnie jeden kolor."""
	if not any(a.startswith('/obj/machinery/power/terminal') for a in atoms):
		return None
	colours = {parse_atom(a)[0] for a in atoms if a.startswith('/obj/structure/cable')}
	if not colours:
		return 'terminal bez kabla pod spodem'
	if len(colours) > 1:
		return 'kilka kolorów kabla pod terminalem: ' + ', '.join(sorted(c.rsplit('/', 1)[-1] for c in colours))
	return None


def connects(part, d, neighbours):
	back = REV[d]
	for other in neighbours:
		if back not in other.dirs:
			continue
		if other.wildcard:
			return True
		if part.layer != 'all' and other.layer != 'all' and part.layer != other.layer:
			continue
		if part.is_he(d) != other.is_he(back):
			continue
		return True
	return False


def short(path):
	return path[len(ATMOS):] if path.startswith(ATMOS) else path


def main(argv):
	update = '--update-baseline' in argv
	maps = [a for a in argv if not a.startswith('--')]
	if not maps:
		maps = sorted(glob.glob(os.path.join(ROOT, '_maps', '**', '*.dmm'), recursive=True))
		maps += sorted(glob.glob(os.path.join(ROOT, 'aquila', '_maps', '**', '*.dmm'), recursive=True))
	spawner_size = load_spawner_sizes()
	found = []
	for fname in maps:
		found += check_map(fname, spawner_size)
	if update:
		with open(BASELINE, 'w', encoding='utf-8', newline='\n') as f:
			f.write('# AQUILA - znane błędy rur i terminali sprzed tools/ci/check_map_pipes.py. Nie dopisuj tu nowych, popraw mapę.\n')
			f.write('# Po poprawieniu starego błędu: python tools/ci/check_map_connections.py --update-baseline\n')
			for line in sorted(set(found)):
				f.write(line + '\n')
		print(f'Zapisano {len(set(found))} znanych błędów do {os.path.relpath(BASELINE, ROOT)}')
		return 0
	known = set()
	if os.path.exists(BASELINE):
		with open(BASELINE, encoding='utf-8') as f:
			known = {line.rstrip('\n') for line in f if line.strip() and not line.startswith('#')}
	new = sorted(set(found) - known)
	for line in new:
		mapname, coords, path, where, what = line.split('|')
		print(f'{mapname} ({coords}): {path} [{where}] {what}')
	if new:
		print(f'\nBŁĄD: {len(new)} nowych problemów z rurami lub zasilaniem na mapach (format: mapa (x,y,z): typ [warstwa+strona] opis).')
		print('Współrzędne jak w StrongDMM. Jeśli to zamierzone, popraw sprawdzacz zamiast dopisywać do listy znanych.')
		return 1
	fixed = len(known & set(found)) != len(known)
	if fixed:
		print('Część znanych błędów zniknęła: uruchom z --update-baseline, żeby skrócić listę.')
	print(f'Rury i terminale na mapach: brak nowych problemów ({len(maps)} map).')
	return 0


if __name__ == '__main__':
	sys.exit(main(sys.argv[1:]))
