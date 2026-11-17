"""Odczyt i zapis plików .dmi (PNG z opisem stanów w tekście Description), wspólne dla narzędzi portu planet.

load(path) -> (width, height, [(nazwa, ciało_opisu, [obrazy RGBA])])
save(path, width, height, stany)
subset(src, dst, nazwy, rename=None): kopiuje wybrane stany (opcjonalnie pod nowymi nazwami) do nowego pliku.
"""
import math
import re

from PIL import Image  # noqa: F401 (używane też przez skrypty: dmilib.Image)
from PIL.PngImagePlugin import PngInfo


def load(path):
	src = Image.open(path)
	desc = src.info['Description']
	image = src.convert('RGBA')
	width = int(re.search(r'width = (\d+)', desc).group(1))
	height = int(re.search(r'height = (\d+)', desc).group(1))
	cols = max(1, image.width // width)
	states = []
	index = 0
	for block in re.split(r'\nstate = ', desc)[1:]:
		name = re.match(r'"([^"]*)"', block).group(1)
		dirs = int(re.search(r'dirs = (\d+)', block).group(1))
		frames = int(re.search(r'frames = (\d+)', block).group(1))
		body = block.split('\n', 1)[1] if '\n' in block else ''
		body = body.split('# END DMI')[0].rstrip('\n')
		images = []
		for _ in range(dirs * frames):
			x = (index % cols) * width
			y = (index // cols) * height
			images.append(image.crop((x, y, x + width, y + height)))
			index += 1
		states.append((name, body, images))
	return width, height, states


def save(path, width, height, states):
	total = sum(len(state[2]) for state in states)
	cols = max(1, math.ceil(math.sqrt(total)))
	rows = max(1, math.ceil(total / cols))
	out = Image.new('RGBA', (cols * width, rows * height), (0, 0, 0, 0))
	desc = ['# BEGIN DMI', 'version = 4.0', '\twidth = %d' % width, '\theight = %d' % height]
	index = 0
	for name, body, images in states:
		desc.append('state = "%s"' % name)
		if body:
			desc.append(body)
		for image in images:
			out.paste(image, ((index % cols) * width, (index // cols) * height))
			index += 1
	desc.append('# END DMI')
	info = PngInfo()
	info.add_text('Description', '\n'.join(desc) + '\n', zip=True)
	out.save(path, format='PNG', pnginfo=info)


def subset(src, dst, names, rename=None):
	width, height, states = load(src)
	by_name = {state[0]: state for state in states}
	missing = [name for name in names if name not in by_name]
	if missing:
		raise SystemExit('brak stanów w %s: %s' % (src, ', '.join(missing)))
	rename = rename or {}
	picked = [(rename.get(name, name), by_name[name][1], by_name[name][2]) for name in names]
	save(dst, width, height, picked)
	return picked
