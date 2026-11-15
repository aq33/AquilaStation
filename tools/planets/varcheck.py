"""Sprawdza edycje zmiennych na mapach: czy zmienna jest zadeklarowana na typie albo jego przodku w naszym kodzie
(pliki dołączone do nsv13.dme). dm przy kompilacji map zatrzymuje się na pierwszej nieznanej zmiennej, ten skrypt
wypisuje wszystkie naraz.

Użycie (z katalogu repo): python tools/planets/varcheck.py [--usun] <mapy.dmm ...>
--usun: usuwa z map edycje nieznanych zmiennych (zapis w formacie TGM, jak convert_maps.py).
"""
import argparse
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'mapmerge2'))
import dmm  # noqa: E402
import convert_maps  # noqa: E402

BUILTIN = set('''name desc icon icon_state dir pixel_x pixel_y pixel_w pixel_z layer plane color alpha density opacity
luminosity invisibility mouse_opacity tag text suffix gender appearance_flags blend_mode transform verbs contents
overlays underlays vars step_x step_y step_size bound_x bound_y bound_width bound_height glide_size animate_movement
screen_loc maptext maptext_width maptext_height maptext_x maptext_y render_source render_target vis_flags filters
anchored'''.split())


def source_files(root):
	backslash = chr(92)
	files = []
	todo = [os.path.join(root, 'nsv13.dme')]
	seen = set()
	while todo:
		current = todo.pop(0)
		base = os.path.dirname(current)
		for line in open(current, encoding='utf-8', errors='replace'):
			match = re.match(r'\s*#include\s+"(.+?)"', line)
			if not match:
				continue
			path = os.path.normpath(os.path.join(base, match.group(1).replace(backslash, '/')))
			if (path.endswith('.dm') or path.endswith('.dme')) and path not in seen and os.path.exists(path):
				seen.add(path)
				files.append(path)
				todo.append(path)
	return files


def declared_vars(root):
	decl = collections.defaultdict(set)
	for current in source_files(root):
		owner = None
		in_var_block = False
		for line in open(current, encoding='utf-8', errors='replace'):
			match = re.match(r'^(/[A-Za-z0-9_/]+)', line)
			if match:
				path = match.group(1)
				var_match = re.match(r'(.*?)/var/(?:[A-Za-z_]+/)*([A-Za-z0-9_]+)', path)
				if var_match:
					decl[var_match.group(1) or '/datum'].add(var_match.group(2))
					owner = None
					continue
				owner = re.split(r'/(proc|verb)(/|$)', path)[0]
				if '/proc' in path or '/verb' in path or '(' in line:
					owner = None
				in_var_block = False
				continue
			if re.match(r'^\S', line):
				owner = None
				continue
			if not owner:
				continue
			var_match = re.match(r'^\tvar/(?:[A-Za-z_]+/)*([A-Za-z0-9_]+)', line)
			if var_match:
				decl[owner].add(var_match.group(1))
				continue
			if re.match(r'^\tvar\s*$', line):
				in_var_block = True
				continue
			block_match = re.match(r'^\t\t(?:[A-Za-z_]+/)*([A-Za-z0-9_]+)\s*(=|$)', line)
			if in_var_block and block_match:
				decl[owner].add(block_match.group(1))
			elif re.match(r'^\t\S', line):
				in_var_block = False
	return decl


def ancestors(path):
	parts = path.split('/')
	out = ['/'.join(parts[:i]) for i in range(len(parts), 1, -1)]
	if parts[1] in ('obj', 'mob', 'effect'):
		out += ['/atom/movable', '/atom']
	elif parts[1] in ('turf', 'area'):
		out += ['/atom']
	out.append('/datum')
	return out


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('--usun', action='store_true')
	parser.add_argument('--root', default='.')
	parser.add_argument('maps', nargs='+')
	args = parser.parse_args()
	decl = declared_vars(args.root)
	types = convert_maps.defined_types(args.root)

	def known(path, var, value):
		if var not in BUILTIN and not any(var in decl.get(a, ()) for a in ancestors(path)):
			return False
		# ścieżki typów w wartości (np. odczynniki w list_reagents) też muszą istnieć
		for type_path in re.findall(r'(?<![\w"])(/(?:datum|obj|mob|turf|area|atom)/[\w/]+)', value.split('"')[0] if value.startswith('"') else value):
			if type_path.rstrip('/') not in types and not type_path.startswith(convert_maps.MACRO_PREFIXES):
				return False
		return True
	total = 0
	for map_path in args.maps:
		m = dmm.DMM.from_file(map_path)
		changed = False
		for key, tile in list(m.dictionary.items()):
			new_tile = []
			for atom in tile:
				path, variables = convert_maps.parse_atom(atom)
				bad = [k for k in variables if not known(path, k, variables[k])]
				for k in bad:
					print('%s: %s.%s = %s' % (os.path.basename(map_path), path, k, variables[k]))
				total += len(bad)
				if bad and args.usun:
					kept = collections.OrderedDict((k, v) for k, v in variables.items() if k not in bad)
					atom = convert_maps.atom(path, kept)
					changed = True
				new_tile.append(atom)
			m.dictionary[key] = tuple(new_tile)
		if changed:
			m.to_file(map_path)
	print('nieznanych edycji:', total)
	sys.exit(1 if total and not args.usun else 0)


if __name__ == '__main__':
	main()
