"""Ściany Shiptesta (smoothing bitmaskowy, 47 stanów "<nazwa>-<maska>", 40x40) na nasz stary smoothing narożnikowy
(stany "1-i" ... "4-f" jak icons/turf/smoothrocks.dmi): każdy narożnik wycinany ze stanu bitmaski o tej samej
konfiguracji sąsiadów. Dokłada też stan pełnej ściany (maska 255) pod podaną nazwą, do podglądu w edytorze map.

Użycie: python tools/planets/wall_corners.py <shiptest_wall.dmi> <wyjście.dmi> [--prefix red_wall] [--full rock]

Bity sąsiadów jak w smoothingu tg: N=1, S=2, E=4, W=8, NE=16, SE=32, SW=64, NW=128.
Narożniki starego smoothingu: 1 = NW, 2 = NE, 3 = SW, 4 = SE; litery: i (brak sąsiadów po obu bokach),
n/s (sąsiad w pionie), w/e (sąsiad w poziomie), nw/ne/sw/se (oba boki bez przekątnej), f (oba boki i przekątna).
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dmilib  # noqa: E402

N, S, E, W, NE, SE, SW, NW = 1, 2, 4, 8, 16, 32, 64, 128

# narożnik -> (prostokąt w obrazie 40x40, {litera: maska})
CORNERS = {
	1: ((0, 0, 20, 20), {'i': 0, 'n': N, 'w': W, 'nw': N | W, 'f': N | W | NW}),
	2: ((20, 0, 40, 20), {'i': 0, 'n': N, 'e': E, 'ne': N | E, 'f': N | E | NE}),
	3: ((0, 20, 20, 40), {'i': 0, 's': S, 'w': W, 'sw': S | W, 'f': S | W | SW}),
	4: ((20, 20, 40, 40), {'i': 0, 's': S, 'e': E, 'se': S | E, 'f': S | E | SE}),
}


def best_state(states, mask):
	"""Stan bitmaski dla maski; brakujące przekątne Shiptest pomija (maska bez przekątnych bez sąsiednich boków)."""
	if mask in states:
		return states[mask]
	# przekątna liczy się tylko przy obu sąsiednich bokach: zdejmij nieistotne bity
	for diag, sides in ((NE, N | E), (SE, S | E), (SW, S | W), (NW, N | W)):
		if mask & diag and (mask & sides) != sides:
			mask &= ~diag
	return states[mask]


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('src')
	parser.add_argument('dst')
	parser.add_argument('--prefix', help='przedrostek stanów w pliku źródłowym (domyślnie nazwa pliku)')
	parser.add_argument('--full', default='full', help='nazwa stanu pełnej ściany w wyniku')
	args = parser.parse_args()
	width, height, src_states = dmilib.load(args.src)
	if (width, height) != (40, 40):
		raise SystemExit('oczekiwano ikon 40x40, jest %dx%d' % (width, height))
	prefix = args.prefix or os.path.splitext(os.path.basename(args.src))[0]
	states = {}
	for name, _, images in src_states:
		if name.startswith(prefix + '-'):
			states[int(name[len(prefix) + 1:])] = images[0]
	out = []
	for corner, (box, letters) in CORNERS.items():
		for letter, mask in letters.items():
			image = best_state(states, mask)
			piece = dmilib.Image.new('RGBA', (40, 40), (0, 0, 0, 0))
			piece.paste(image.crop(box), box[:2])
			out.append(('%d-%s' % (corner, letter), '\tdirs = 1\n\tframes = 1', [piece]))
	out.append((args.full, '\tdirs = 1\n\tframes = 1', [states[255]]))
	dmilib.save(args.dst, 40, 40, out)
	print('zapisano', args.dst, len(out), 'stanów')


if __name__ == '__main__':
	main()
