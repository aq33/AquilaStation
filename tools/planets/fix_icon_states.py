"""Usuwa z map edycje icon_state, których nie ma w pliku ikon typu (np. stany Shiptesta: pine_4, icemoonrock1,
conc_tiles), żeby obiekt nie był niewidzialny. Plik ikon typu bierze z kodu (icon = '...' na typie albo przodku);
edycja icon w samej mapie też się liczy. Stany z animacją kierunkową i bez nazwy pomija.

Użycie: python tools/planets/fix_icon_states.py <mapy.dmm>   (z katalogu repo)
"""
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'mapmerge2'))
import dmilib  # noqa: E402
import dmm  # noqa: E402

BACKSLASH = chr(92)


def code_files(root):
	files = []
	todo = [os.path.join(root, 'nsv13.dme')]
	seen = set()
	while todo:
		current = todo.pop(0)
		if not os.path.exists(current):
			continue
		base = os.path.dirname(current)
		for line in open(current, encoding='utf-8', errors='replace'):
			m = re.match(r'\s*#include\s+"(.+?)"', line)
			if m:
				path = os.path.normpath(os.path.join(base, m.group(1).replace(BACKSLASH, '/')))
				if path.endswith(('.dm', '.dme')) and path not in seen and os.path.exists(path):
					seen.add(path)
					files.append(path)
					todo.append(path)
	return files


def type_icons(root):
	icons = {}
	for f in code_files(root):
		current = None
		for line in open(f, encoding='utf-8', errors='replace'):
			m = re.match(r'^(/[A-Za-z0-9_/]+)\s*$', line.rstrip())
			if m:
				current = m.group(1)
				continue
			if re.match(r'^\S', line):
				current = None
				continue
			if current:
				m = re.match(r"^\ticon\s*=\s*'([^']+)'", line)
				if m:
					icons[current] = m.group(1)
	return icons


def main():
	root = '.'
	icons = type_icons(root)
	states_cache = {}

	def states(icon):
		if icon not in states_cache:
			try:
				states_cache[icon] = {name for name, _, _ in dmilib.load(os.path.join(root, icon))[2]}
			except Exception:  # noqa: BLE001 - brak pliku albo nie-dmi: nie ruszamy
				states_cache[icon] = None
		return states_cache[icon]

	def icon_of(path):
		parts = path.split('/')
		for i in range(len(parts), 1, -1):
			icon = icons.get('/'.join(parts[:i]))
			if icon:
				return icon
		return None

	total = collections.Counter()
	for mp in sys.argv[1:]:
		m = dmm.DMM.from_file(mp)
		fixed = {}
		for key, tile in m.dictionary.items():
			new = []
			for atom in tile:
				path, values = dmm.parse_map_atom(atom)
				state = values.get('icon_state')
				if state and state.startswith('"'):
					icon = values.get('icon', "'" + (icon_of(path) or '') + "'").strip("'")
					known = states(icon) if icon else None
					if known is not None and state.strip('"') not in known:
						values = {k: v for k, v in values.items() if k != 'icon_state'}
						atom = path + ('{' + '; '.join('%s = %s' % kv for kv in values.items()) + '}' if values else '')
						total[(path, state)] += 1
				new.append(atom)
			if tuple(new) != tuple(tile):
				fixed[key] = tuple(new)
		if not fixed:
			continue
		# Klucze mogą się zlać w jeden (dwa kafle różniące się tylko złym stanem): mapa budowana od nowa
		out = dmm.DMM(m.key_length, m.size)
		for coord, key in m.grid.items():
			out.set_tile(coord, fixed.get(key, m.dictionary[key]))
		try:
			out.to_file(mp)
		except Exception:  # noqa: BLE001 - za mało kluczy przy dłuższej mapie
			out.key_length += 1
			out.to_file(mp)
	for (path, state), n in sorted(total.items()):
		print('usunięto icon_state %s z %s (%d)' % (state, path, n))


if __name__ == '__main__':
	main()
