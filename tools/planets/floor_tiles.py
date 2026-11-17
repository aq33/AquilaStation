"""Podłogi planet Shiptesta (smoothing bitmaskowy, sprite'y 70x70 rysowane z przesunięciem -19) na pojedyncze kafle 32x32
dla naszego /turf/open/floor/plating/asteroid: środek stanu "<prefix>-255" jako "<env>", 13 wariantów "<env>0".."<env>12"
z nakładkami "<prefix>alt_N" po kolei (jak przy planecie wulkanicznej) i "<env>_dug" ze stanu "<prefix>_dug", jeśli jest.
Tracimy postrzępione brzegi między biomami (nasz stary smoothing ich nie rysuje).

Użycie: python tools/planets/floor_tiles.py <shiptest_floor.dmi> <wyjście.dmi> --prefix sand --env whitesand [--append]
--append dopisuje stany do istniejącego pliku wyjściowego (stany o tej samej nazwie są zastępowane).
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dmilib  # noqa: E402

BODY = '\tdirs = 1\n\tframes = 1'
VARIANTS = 13


def crop(image):
	return image.crop((19, 19, 51, 51))


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('src')
	parser.add_argument('dst')
	parser.add_argument('--prefix', required=True, help='przedrostek stanów w źródle (np. sand, rock, icemoon_ground)')
	parser.add_argument('--env', required=True, help='environment_type turfu (nazwy stanów w wyniku)')
	parser.add_argument('--append', action='store_true')
	args = parser.parse_args()
	width, height, src_states = dmilib.load(args.src)
	if (width, height) != (70, 70):
		raise SystemExit('oczekiwano ikon 70x70, jest %dx%d' % (width, height))
	states = {name: images[0] for name, _, images in src_states}
	base = crop(states['%s-255' % args.prefix])
	alts = sorted((name for name in states if name.startswith(args.prefix + 'alt_')), key=lambda n: int(n.rsplit('_', 1)[1]))
	out = [(args.env, BODY, [base])]
	for n in range(VARIANTS):
		variant = base.copy()
		if alts:
			variant.alpha_composite(crop(states[alts[n % len(alts)]]))
		out.append(('%s%d' % (args.env, n), BODY, [variant]))
	if '%s_dug' % args.prefix in states:
		out.append(('%s_dug' % args.env, BODY, [crop(states['%s_dug' % args.prefix])]))
	if args.append and os.path.exists(args.dst):
		_, _, existing = dmilib.load(args.dst)
		names = {state[0] for state in out}
		out = [state for state in existing if state[0] not in names] + out
	dmilib.save(args.dst, 32, 32, out)
	print('zapisano', args.dst, len(out), 'stanów')


if __name__ == '__main__':
	main()
