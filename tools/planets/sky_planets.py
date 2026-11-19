"""Tekstury planet na niebie (paralaksa za okrętem stojącym w układzie z planetą).

Planeta na niebie to płaska mapa powierzchni (odwzorowanie walcowe 512 × 256, szwu brak, bo szum liczymy na kuli)
pod tarczą. Filtr displace z mapą przemieszczeń kuli zgina ją w globus, maska alpha obcina do tarczy, a cień i poświata
atmosfery leżą na wierzchu. Pliki są małe: jedna tekstura na typ planety.

Wynik:
  aquila/icons/effects/planet_sky_surface.dmi  (512 × 256) powierzchnie i chmury
  aquila/icons/effects/planet_sky_disk.dmi     (192 × 192) mapa przemieszczeń, maska, cień, poświata
  aquila/icons/effects/planet_sky_streaks.dmi  (480 × 480) smugi pędu przy wejściu w atmosferę
  aquila/icons/effects/planet_descent.dmi      (32 × 32) wypełnienie nieba, cień promu, żar przy kadłubie

Uruchomienie z katalogu repo: python tools/planets/sky_planets.py [--podglad katalog] (potrzebuje numpy, którego nie ma
w tools/requirements.txt: python -m pip install numpy==2.2.6)
--podglad zapisuje też PNG każdej planety złożonej tak jak w grze (do oceny bez uruchamiania gry).
Wszystko jest generowane z ziarna, więc kolejne uruchomienie daje te same pliki.
"""
import argparse
import math
import os
import sys

try:
	import numpy as np
except ImportError:  # celowo poza tools/requirements.txt: generator uruchamia się ręcznie, CI go nie potrzebuje
	sys.exit('Generator potrzebuje numpy: python -m pip install numpy==2.2.6')

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dmilib  # noqa: E402
from dmilib import Image  # noqa: E402

TEX_W, TEX_H = 512, 256
# Promień kuli w pikselach tekstury: obwód równika to cała szerokość tekstury
RADIUS = TEX_W / (2 * math.pi)
DISK = 192
# Największe przesunięcie w mapie displace (przy biegunach długości geograficzne zbiegają się aż do pół tekstury)
DISPLACE_SIZE = 128
# Kierunek światła: ekran x w prawo, y w górę, z do patrzącego (słońce z lewej u góry)
LIGHT = np.array([-0.62, 0.42, 0.66])
LIGHT = LIGHT / np.linalg.norm(LIGHT)

STATE = '\tdirs = 1\n\tframes = 1'


# ---------------------------------------------------------------------------
# Szum na kuli

def sphere_points():
	"""Punkty kuli dla każdego teksla mapy walcowej (H, W, 3) i szerokość geograficzna (H, W)."""
	lon = (np.arange(TEX_W) + 0.5) / TEX_W * 2 * math.pi
	lat = math.pi / 2 - (np.arange(TEX_H) + 0.5) / TEX_H * math.pi
	lon, lat = np.meshgrid(lon, lat)
	pts = np.stack([np.cos(lat) * np.cos(lon), np.cos(lat) * np.sin(lon), np.sin(lat)], axis=-1)
	return pts, lat


class Noise3:
	"""Szum wartości 3D na siatce z gładką interpolacją (wystarcza do pikselowej planety)."""

	def __init__(self, seed, size=64):
		rng = np.random.default_rng(seed)
		self.size = size
		self.grid = rng.random((size, size, size))
		self.offset = rng.random(3) * size

	def sample(self, pts):
		p = pts + self.offset
		i = np.floor(p).astype(int)
		f = p - i
		f = f * f * (3 - 2 * f)
		s = self.size
		out = 0
		for dx in (0, 1):
			for dy in (0, 1):
				for dz in (0, 1):
					w = (f[..., 0] if dx else 1 - f[..., 0]) * (f[..., 1] if dy else 1 - f[..., 1]) * (f[..., 2] if dz else 1 - f[..., 2])
					out = out + w * self.grid[(i[..., 0] + dx) % s, (i[..., 1] + dy) % s, (i[..., 2] + dz) % s]
		return out


def fbm(pts, seed, scale=2.0, octaves=5, gain=0.5):
	noise = Noise3(seed)
	total = np.zeros(pts.shape[:-1])
	amp, freq, norm = 1.0, scale, 0.0
	for _ in range(octaves):
		total += amp * noise.sample(pts * freq)
		norm += amp
		amp *= gain
		freq *= 2
	return total / norm


def normalize(values):
	lo, hi = np.percentile(values, 1), np.percentile(values, 99)
	return np.clip((values - lo) / (hi - lo), 0, 1)


def craters(pts, seed, count, min_r, max_r):
	"""Pole kraterów: -1 w dnie, +1 na wale, 0 poza kraterami."""
	rng = np.random.default_rng(seed)
	out = np.zeros(pts.shape[:-1])
	for _ in range(count):
		v = rng.normal(size=3)
		v /= np.linalg.norm(v)
		r = rng.uniform(min_r, max_r)
		ang = np.arccos(np.clip(pts @ v, -1, 1))
		inside = ang < r
		out[inside] = np.minimum(out[inside], -1)
		rim = (ang >= r) & (ang < r * 1.25)
		out[rim] = np.where(out[rim] == 0, 1, out[rim])
	return out


def hexcolor(value):
	value = value.lstrip('#')
	return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def palette_map(values, stops):
	"""Pasma kolorów: stops = [(próg, kolor), ...] rosnąco; wartość >= progu bierze ten kolor."""
	out = np.zeros(values.shape + (4,), np.uint8)
	out[..., 3] = 255
	for threshold, color in stops:
		out[values >= threshold, :3] = hexcolor(color)
	return out


# ---------------------------------------------------------------------------
# Powierzchnie typów planet

def surface_textures():
	pts, lat = sphere_points()
	polar = np.abs(lat) / (math.pi / 2)
	tex = {}

	# Ziemska z dżunglą: dużo lądu, zielenie
	h = normalize(fbm(pts, 11, scale=1.5, octaves=6))
	tex['jungle'] = palette_map(h, [(0, '#1d3f73'), (0.32, '#2a5a94'), (0.44, '#3a7bb5'), (0.47, '#d9c27a'),
		(0.5, '#3f8f3a'), (0.62, '#2f6f2e'), (0.78, '#235524'), (0.9, '#4b6e3a')])
	# Oceaniczna z wyspami i plażami (wybrzeże)
	h = normalize(fbm(pts, 21, scale=1.8, octaves=6))
	tex['beach'] = palette_map(h, [(0, '#1a4a8a'), (0.45, '#2563a8'), (0.62, '#3d86c6'), (0.7, '#6fb4dd'),
		(0.74, '#ead9a0'), (0.78, '#5fa04a'), (0.88, '#3f7f37')])
	# Wodna: głęboki ocean, prawie bez lądu
	h = normalize(fbm(pts, 31, scale=1.4, octaves=6))
	tex['water'] = palette_map(h, [(0, '#11305e'), (0.35, '#173f78'), (0.6, '#1f5092'), (0.8, '#2e68ad'),
		(0.9, '#4a86c4'), (0.955, '#d8cf9a'), (0.97, '#5d9a56')])
	# Lodowa: biel i błękit, pęknięcia
	h = normalize(fbm(pts, 41, scale=1.8, octaves=6))
	crack = np.abs(fbm(pts, 42, scale=3.0, octaves=4) - 0.5)
	h = np.where(crack < 0.018, 0.05, h)
	tex['ice'] = palette_map(h, [(0, '#5d86b0'), (0.15, '#9cc1dd'), (0.4, '#c6deef'), (0.65, '#e6f2fb'), (0.85, '#ffffff')])
	# Lawowa: ciemny bazalt i świecące rzeki
	h = normalize(fbm(pts, 51, scale=1.7, octaves=6))
	lava = np.abs(fbm(pts, 52, scale=2.2, octaves=5) - 0.5)
	tex['lava'] = palette_map(h, [(0, '#2a1816'), (0.35, '#3a2220'), (0.6, '#4d2c25'), (0.82, '#5f382c')])
	tex['lava'][lava < 0.035, :3] = hexcolor('#ff8a1e')
	tex['lava'][lava < 0.015, :3] = hexcolor('#ffd34a')
	# Pole bitwy: szare popioły, lej po lejem
	h = normalize(fbm(pts, 61, scale=1.6, octaves=6))
	c = craters(pts, 62, 70, 0.02, 0.08)
	h = np.clip(h + c * 0.12, 0, 1)
	tex['battlefield'] = palette_map(h, [(0, '#3a362f'), (0.3, '#4e493d'), (0.55, '#625b4a'), (0.75, '#7a705a'), (0.9, '#8f8468')])
	# Skalista: rdza
	h = normalize(fbm(pts, 71, scale=1.8, octaves=6))
	c = craters(pts, 72, 40, 0.03, 0.12)
	h = np.clip(h + c * 0.1, 0, 1)
	tex['rock'] = palette_map(h, [(0, '#5a2a24'), (0.3, '#7a3a2e'), (0.55, '#9a4c38'), (0.75, '#b8644a'), (0.9, '#d4836a')])
	# Białe piaski: blade wydmy w pasach
	dune = normalize(np.sin(pts[..., 2] * 40 + fbm(pts, 81, scale=2.0, octaves=4) * 14))
	h = normalize(fbm(pts, 82, scale=1.6, octaves=5)) * 0.6 + dune * 0.4
	tex['sand'] = palette_map(h, [(0, '#a49cb4'), (0.3, '#bdb6cc'), (0.55, '#d4cfe0'), (0.78, '#e8e5ef'), (0.92, '#f7f5fa')])
	# Pustynna: pomarańczowe wydmy i ciemne skały
	dune = normalize(np.sin((pts[..., 0] + pts[..., 2]) * 30 + fbm(pts, 91, scale=2.0, octaves=4) * 12))
	h = normalize(fbm(pts, 92, scale=1.5, octaves=6)) * 0.7 + dune * 0.3
	tex['desert'] = palette_map(h, [(0, '#7a4a2a'), (0.25, '#b0703a'), (0.45, '#d08f4a'), (0.68, '#e8ae62'), (0.86, '#f3c282')])
	# Mglista: fiolety pod gęstymi oparami
	h = normalize(fbm(pts, 101, scale=1.6, octaves=6))
	tex['shrouded'] = palette_map(h, [(0, '#2a1840'), (0.35, '#3d2358'), (0.6, '#54306f'), (0.8, '#6c4088')])
	# Śmietnisko: szaro-fioletowe hałdy z rdzawymi plamami
	h = normalize(fbm(pts, 111, scale=2.2, octaves=6))
	rust = fbm(pts, 112, scale=3.0, octaves=3)
	tex['waste'] = palette_map(h, [(0, '#3d3848'), (0.3, '#544d62'), (0.55, '#6b6380'), (0.8, '#8a82a0')])
	tex['waste'][(rust > 0.62) & (h > 0.3), :3] = hexcolor('#8a5a3a')
	tex['waste'][(rust > 0.68) & (h > 0.5), :3] = hexcolor('#a8744a')
	# Księżyc: szarości i kratery
	h = normalize(fbm(pts, 121, scale=1.4, octaves=5))
	c = craters(pts, 122, 90, 0.025, 0.14)
	h = np.clip(h * 0.7 + 0.15 + c * 0.14, 0, 1)
	tex['moon'] = palette_map(h, [(0, '#55555e'), (0.3, '#6e6e78'), (0.5, '#8a8a94'), (0.7, '#a8a8b2'), (0.88, '#c4c4cc')])
	# Gazowe olbrzymy: pasy wzdłuż równoleżników z zawirowaniami
	swirl = fbm(pts, 131, scale=2.5, octaves=5)
	bands = normalize(np.sin(pts[..., 2] * 9 + swirl * 5) + 0.4 * np.sin(pts[..., 2] * 23 + swirl * 3))
	tex['gas_giant'] = palette_map(bands, [(0, '#8a4a2a'), (0.2, '#b06a3a'), (0.4, '#d08f52'), (0.6, '#e8b478'),
		(0.78, '#f3d4a0'), (0.92, '#fbe8c8')])
	spot = np.arccos(np.clip(pts @ np.array([1.0, 0.0, -0.35]) / np.linalg.norm([1.0, 0.0, -0.35]), -1, 1))
	tex['gas_giant'][spot < 0.16, :3] = hexcolor('#c0502e')
	tex['gas_giant'][spot < 0.09, :3] = hexcolor('#d8683a')
	swirl = fbm(pts, 141, scale=2.5, octaves=5)
	bands = normalize(np.sin(pts[..., 2] * 11 + swirl * 6) + 0.4 * np.sin(pts[..., 2] * 27 + swirl * 3))
	tex['gas_plasma'] = palette_map(bands, [(0, '#3a1a5a'), (0.2, '#5a2a80'), (0.4, '#7a3aa0'), (0.6, '#9a58c0'),
		(0.78, '#c088dc'), (0.92, '#e8c0f4')])
	# Czapy polarne na planetach z wodą i lądem
	for name, start in (('jungle', 0.82), ('beach', 0.86), ('water', 0.88)):
		cap = polar + (fbm(pts, 151, scale=3.0, octaves=3) - 0.5) * 0.12 > start
		tex[name][cap, :3] = hexcolor('#eef6fb')
	return {name: Image.fromarray(data) for name, data in tex.items()}


def cloud_textures():
	pts, _ = sphere_points()
	out = {}
	for name, seed, coverage in (('clouds', 201, 0.63), ('clouds_thick', 211, 0.48), ('clouds_wisps', 221, 0.72)):
		# Chmury rozciągnięte wzdłuż równoleżników jak na prawdziwych planetach
		stretched = pts * np.array([1.0, 1.0, 2.2])
		c = normalize(fbm(stretched, seed, scale=2.2, octaves=6))
		img = np.zeros((TEX_H, TEX_W, 4), np.uint8)
		img[c >= coverage] = (255, 255, 255, 235)
		img[c >= coverage + 0.12] = (255, 255, 255, 255)
		# Cień od spodu chmury: ciemniejszy brzeg
		edge = (c >= coverage) & (c < coverage + 0.035)
		img[edge] = (200, 206, 220, 220)
		out[name] = Image.fromarray(img)
	return out


# ---------------------------------------------------------------------------
# Tarcza: mapa przemieszczeń, maska, cień, poświata

def disk_coords():
	idx = np.arange(DISK) + 0.5 - DISK / 2
	u = idx[None, :] / RADIUS + 0 * idx[:, None]
	v = -idx[:, None] / RADIUS + 0 * idx[None, :]  # oś y w górę
	return u, v


def disk_states():
	u, v = disk_coords()
	r2 = u * u + v * v
	inside = r2 <= 1
	vv = np.clip(v, -1, 1)
	cos_lat = np.sqrt(np.maximum(1e-9, 1 - vv * vv))
	lat = np.arcsin(vv)
	lon = np.arcsin(np.clip(u / cos_lat, -1, 1))
	off_x = np.where(inside, lon * RADIUS - u * RADIUS, 0)
	off_y = np.where(inside, lat * RADIUS - v * RADIUS, 0)
	displace = np.zeros((DISK, DISK, 4), np.uint8)
	displace[..., 0] = np.clip(np.round(128 + off_x / DISPLACE_SIZE * 127), 0, 255)
	# Zielony kanał w BYOND przesuwa w dół obrazka (sprawdzone na siatce), więc znak odwrócony
	displace[..., 1] = np.clip(np.round(128 - off_y / DISPLACE_SIZE * 127), 0, 255)
	displace[..., 3] = 255

	mask = np.zeros((DISK, DISK, 4), np.uint8)
	mask[inside] = (255, 255, 255, 255)

	# Cień: pasma jasności jak w pikselowych planetach, noc nie całkiem czarna
	nz = np.sqrt(np.maximum(0, 1 - r2))
	light = u * LIGHT[0] + v * LIGHT[1] + nz * LIGHT[2]
	shade = np.zeros((DISK, DISK, 4), np.uint8)
	alpha = np.select([light > 0.62, light > 0.38, light > 0.16, light > -0.04, light > -0.22],
		[0, 55, 110, 160, 200], 232)
	shade[..., 3] = np.where(inside, alpha, 0)
	# Rozświetlony brzeg od strony słońca
	rim = inside & (r2 > 0.86) & (light > 0.25)
	shade[rim] = (255, 255, 255, 60)

	# Poświata atmosfery (biała, barwiona w grze przez color), mocniejsza od strony słońca
	r = np.sqrt(r2)
	side = np.clip((u * LIGHT[0] + v * LIGHT[1]) / np.maximum(r, 1e-6) * 0.5 + 0.5, 0, 1)
	atmo = np.zeros((DISK, DISK, 4), np.uint8)
	ring_px = (r - 1) * RADIUS
	glow = np.select([ring_px < 0, ring_px < 2, ring_px < 4, ring_px < 7], [0, 150, 90, 40], 0)
	inner = inside & (r > 0.93)
	glow = np.where(inner, 70, glow)
	atmo[..., :3] = 255
	atmo[..., 3] = np.clip(glow * (0.35 + 0.65 * side), 0, 255).astype(np.uint8)

	base = np.zeros((DISK, DISK, 4), np.uint8)
	return {
		'base': Image.fromarray(base),
		'displace': Image.fromarray(displace),
		'mask': Image.fromarray(mask),
		'shade': Image.fromarray(shade),
		'atmosphere': Image.fromarray(atmo),
	}


# ---------------------------------------------------------------------------
# Zejście promu przez atmosferę

def streak_states():
	"""Jasne pionowe smugi pędu, powtarzalne w pionie (dwie kopie jadą w górę jedna za drugą)."""
	rng = np.random.default_rng(301)
	size = 480
	img = np.zeros((size, size, 4), np.uint8)
	for _ in range(70):
		x = int(rng.integers(0, size))
		length = int(rng.integers(30, 160))
		top = int(rng.integers(0, size))
		alpha = int(rng.integers(40, 140))
		width = 1 if rng.random() < 0.75 else 2
		for i in range(length):
			y = (top + i) % size
			# Smuga jaśnieje ku środkowi i gaśnie na końcach
			fade = math.sin(math.pi * i / length)
			img[y, x:x + width] = (255, 255, 255, int(alpha * fade))
	return {'streaks': Image.fromarray(img)}


def descent_states():
	"""32 × 32: wypełnienie nieba (białe, barwione w grze), cień kadłuba, żar przy kadłubie w 4 kierunkach."""
	fill = Image.new('RGBA', (32, 32), (255, 255, 255, 255))
	shadow = Image.new('RGBA', (32, 32), (0, 0, 0, 255))
	rng = np.random.default_rng(311)
	# Żar od krawędzi, przy której stoi kadłub: kierunek stanu = strona kadłuba (kolejność DMI: S, N, E, W)
	base = np.zeros((32, 32, 4), np.uint8)
	depth = np.arange(32)[:, None] + 0 * np.arange(32)[None, :]  # odległość od górnej krawędzi
	wobble = rng.random((32, 32)) * 4
	strength = np.clip(1 - (depth + wobble) / 22, 0, 1)
	base[..., 0] = 255
	base[..., 1] = np.clip(90 + strength * 120, 0, 255).astype(np.uint8)
	base[..., 2] = np.clip(20 + strength * 60, 0, 255).astype(np.uint8)
	base[..., 3] = (strength ** 1.6 * 235).astype(np.uint8)
	north = Image.fromarray(base)
	glow = {
		'S': north.rotate(180),
		'N': north,
		'E': north.rotate(-90),
		'W': north.rotate(90),
	}
	return [
		('fill', STATE, [fill]),
		('shadow', STATE, [shadow]),
		('reentry', STATE.replace('dirs = 1', 'dirs = 4'), [glow['S'], glow['N'], glow['E'], glow['W']]),
	]


# ---------------------------------------------------------------------------
# Podgląd złożonej planety (to samo, co robi BYOND: displace, maska, cień, poświata)

PREVIEW = {
	'jungle': ('clouds', '#ffffff', '#7fb8ff'), 'beach': ('clouds', '#ffffff', '#8cc8ff'),
	'water': ('clouds_thick', '#ffffff', '#6fa8ff'), 'ice': ('clouds_wisps', '#ffffff', '#cfe8ff'),
	'lava': ('clouds_wisps', '#5a4a48', '#ff7a3a'), 'battlefield': ('clouds_wisps', '#6a645a', '#c8b890'),
	'rock': (None, None, '#e0907a'), 'sand': ('clouds_wisps', '#f4f0fa', '#e8e0ff'),
	'desert': ('clouds_wisps', '#f0dcc0', '#f3c282'), 'shrouded': ('clouds_thick', '#9a70c0', '#b070e0'),
	'waste': ('clouds_wisps', '#a89a70', '#b0a0d0'), 'moon': (None, None, None),
	'gas_giant': (None, None, '#f0b070'), 'gas_plasma': (None, None, '#c070f0'),
}


def compose(surface, clouds, cloud_color, atmo_color, disk, shift=0):
	src = np.roll(np.asarray(surface).astype(float), -shift, axis=1)
	if clouds is not None:
		cl = np.roll(np.asarray(clouds).astype(float), -int(shift * 1.6), axis=1)
		a = cl[..., 3:4] / 255
		tint = np.array(hexcolor(cloud_color), float) / 255
		src[..., :3] = src[..., :3] * (1 - a) + cl[..., :3] * tint * a
	u, v = disk_coords()
	vv = np.clip(v, -1, 1)
	lat = np.arcsin(vv)
	lon = np.arcsin(np.clip(u / np.sqrt(np.maximum(1e-9, 1 - vv * vv)), -1, 1))
	tx = np.clip((TEX_W / 2 + lon * RADIUS).astype(int), 0, TEX_W - 1)
	ty = np.clip((TEX_H / 2 - lat * RADIUS).astype(int), 0, TEX_H - 1)
	out = src[ty, tx]
	mask = np.asarray(disk['mask'])[..., 3:4] / 255
	out[..., 3:4] = mask * 255
	shade = np.asarray(disk['shade']).astype(float)
	sa = shade[..., 3:4] / 255
	out[..., :3] = out[..., :3] * (1 - sa) + shade[..., :3] * sa
	img = Image.fromarray(out.astype(np.uint8))
	if atmo_color:
		atmo = np.asarray(disk['atmosphere']).astype(float)
		atmo[..., :3] = atmo[..., :3] * np.array(hexcolor(atmo_color), float) / 255
		img = Image.alpha_composite(img, Image.fromarray(atmo.astype(np.uint8)))
	bg = Image.new('RGBA', img.size, (6, 6, 14, 255))
	return Image.alpha_composite(bg, img)


def main():
	parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
	parser.add_argument('--podglad', help='katalog na PNG złożonych planet')
	parser.add_argument('--repo', default='.', help='katalog repozytorium')
	args = parser.parse_args()

	surfaces = surface_textures()
	clouds = cloud_textures()
	disk = disk_states()
	out_dir = os.path.join(args.repo, 'aquila', 'icons', 'effects')
	states = [(name, STATE, [img]) for name, img in sorted(surfaces.items())]
	states += [(name, STATE, [img]) for name, img in sorted(clouds.items())]
	dmilib.save(os.path.join(out_dir, 'planet_sky_surface.dmi'), TEX_W, TEX_H, states)
	dmilib.save(os.path.join(out_dir, 'planet_sky_disk.dmi'), DISK, DISK, [(name, STATE, [img]) for name, img in disk.items()])
	dmilib.save(os.path.join(out_dir, 'planet_sky_streaks.dmi'), 480, 480, [(name, STATE, [img]) for name, img in streak_states().items()])
	dmilib.save(os.path.join(out_dir, 'planet_descent.dmi'), 32, 32, descent_states())
	print('zapisano', len(states), 'tekstur i', len(disk), 'stanów tarczy, smugi i efekty zejścia')

	if args.podglad:
		os.makedirs(args.podglad, exist_ok=True)
		tiles = []
		for name, (cloud, cloud_color, atmo_color) in PREVIEW.items():
			img = compose(surfaces[name], clouds.get(cloud) if cloud else None, cloud_color, atmo_color, disk)
			img = img.resize((DISK * 2, DISK * 2), Image.NEAREST)
			img.save(os.path.join(args.podglad, name + '.png'))
			tiles.append(img)
		cols = 5
		rows = math.ceil(len(tiles) / cols)
		sheet = Image.new('RGBA', (cols * DISK * 2, rows * DISK * 2), (6, 6, 14, 255))
		for i, tile in enumerate(tiles):
			sheet.paste(tile, ((i % cols) * DISK * 2, (i // cols) * DISK * 2))
		sheet.save(os.path.join(args.podglad, '_wszystkie.png'))


if __name__ == '__main__':
	main()
