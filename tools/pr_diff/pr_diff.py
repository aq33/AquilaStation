"""Obrazki „przed / po” dla zmienionych map (.dmm) i ikon (.dmi) gałęzi, do recenzji i opisu PR.

Mapy: zmienione kafelki z porównania plików TGM (tools/mapmerge2), render obszaru wokół nich przez dmm-tools
(SpacemanDMM w wersji z dependencies.sh, pobierany do tools/bootstrap/.cache), obok siebie: przed, po,
po z czerwoną ramką na każdym zmienionym kafelku. Jeden obrazek na każdy zmieniony poziom Z (klaster zmian).
Ikony: stany dodane, usunięte i zmienione (piksele, liczba kierunków, klatki), każdy jako wiersz przed / po.

Użycie (z katalogu repo):
  python tools/pr_diff/pr_diff.py                      # względem aq33/master, wynik w raport/pr_diff/
  python tools/pr_diff/pr_diff.py --baza origin/master --out moj_folder --margines 4
  python tools/pr_diff/pr_diff.py --tylko _maps/map_files/Atlas/atlas.dmm
Na końcu wypisuje listę obrazków i podsumowanie w Markdownie do wklejenia w opis PR.
"""

import argparse
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(REPO, "tools"))
sys.path.insert(0, os.path.join(REPO, "tools", "local_ci"))
from mapmerge2 import dmm  # noqa: E402
import local_ci  # noqa: E402

TILE = 32


def git(*args, binary=False):
	result = subprocess.run(["git", *args], cwd=REPO, capture_output=True)
	if result.returncode:
		return None
	return result.stdout if binary else result.stdout.decode("utf-8", "replace")


TARGET = None  # None: pliki z dysku (gałąź z niezacommitowanymi zmianami), inaczej commit z --cel


def new_bytes(path):
	if TARGET:
		return git("show", f"{TARGET}:{path}", binary=True)
	return open(os.path.join(REPO, path), "rb").read()


def changed_files(base, only):
	out = git("diff", "--name-only", "--diff-filter=AMR", f"{base}...{TARGET or 'HEAD'}") or ""
	if not TARGET:
		out += git("diff", "--name-only", "--diff-filter=AMR", "HEAD") or ""
	files = sorted({f.strip() for f in out.splitlines() if f.strip()})
	if only:
		files = [f for f in files if f.replace("\\", "/") in {o.replace("\\", "/") for o in only}]
	return [f for f in files if f.endswith(".dmm")], [f for f in files if f.endswith(".dmi")]


# --- mapy ---

def dmm_tools():
	version = local_ci.dependency("SPACEMAN_DMM_VERSION")
	return local_ci.download(f"https://github.com/SpaceManiac/SpacemanDMM/releases/download/{version}/dmm-tools.exe", os.path.join(local_ci.CACHE, f"spacemandmm-{version}", "dmm-tools.exe"))


def changed_tiles(old, new):
	"""Współrzędne (x, y, z) kafelków, które różnią się zawartością."""
	coords = set(new.grid) | set(old.grid)
	changed = set()
	for c in coords:
		a = old.get_tile(c) if c in old.grid else None
		b = new.get_tile(c) if c in new.grid else None
		if a != b:
			changed.add(c)
	return changed


def clusters(points, gap):
	"""Grupuje zmienione kafelki jednego poziomu w prostokąty (sąsiedzi bliżej niż gap)."""
	boxes = []
	for x, y in sorted(points):
		for box in boxes:
			if box[0] - gap <= x <= box[2] + gap and box[1] - gap <= y <= box[3] + gap:
				box[0], box[1], box[2], box[3] = min(box[0], x), min(box[1], y), max(box[2], x), max(box[3], y)
				break
		else:
			boxes.append([x, y, x, y])
	merged = True
	while merged:
		merged = False
		for i in range(len(boxes)):
			for j in range(i + 1, len(boxes)):
				a, b = boxes[i], boxes[j]
				if a[0] - gap <= b[2] and b[0] - gap <= a[2] and a[1] - gap <= b[3] and b[1] - gap <= a[3]:
					boxes[i] = [min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3])]
					del boxes[j]
					merged = True
					break
			if merged:
				break
	return boxes


def render(tool, path, box, z, work):
	out = tempfile.mkdtemp(dir=work)
	subprocess.run([tool, "-e", os.path.join(REPO, "nsv13.dme"), "minimap", "-o", out, "--min", f"{box[0]},{box[1]},{z}", "--max", f"{box[2]},{box[3]},{z}", path], cwd=REPO, capture_output=True)
	pngs = [f for f in os.listdir(out) if f.endswith(".png")]
	if not pngs:
		return None
	return Image.open(os.path.join(out, pngs[0])).convert("RGBA")


def map_diff(path, base, out_dir, margin, tool, work):
	old_bytes = git("show", f"{base}:{path}", binary=True)
	new_path = os.path.join(work, "po_" + os.path.basename(path))
	open(new_path, "wb").write(new_bytes(path))
	new = dmm.DMM.from_file(new_path)
	if old_bytes is None:
		return [f"- `{path}`: nowa mapa (bez obrazka przed/po)"]
	old_path = os.path.join(work, "przed_" + os.path.basename(path))
	open(old_path, "wb").write(old_bytes)
	old = dmm.DMM.from_file(old_path)
	changed = changed_tiles(old, new)
	if not changed:
		return [f"- `{path}`: zmiana bez różnicy kafelków (formatowanie/klucze)"]
	lines = [f"- `{path}`: {len(changed)} zmienionych kafelków"]
	for z in sorted({c[2] for c in changed}):
		points = [(x, y) for x, y, zz in changed if zz == z]
		for n, box in enumerate(clusters(points, margin * 2), 1):
			view = [max(1, box[0] - margin), max(1, box[1] - margin), min(new.size.x, box[2] + margin), min(new.size.y, box[3] + margin)]
			before = render(tool, old_path, view, z, work)
			after = render(tool, new_path, view, z, work)
			if not before or not after:
				lines.append(f"  - Z{z} ({box[0]},{box[1]})–({box[2]},{box[3]}): dmm-tools nie wyrenderował obszaru")
				continue
			marked = after.copy()
			draw = ImageDraw.Draw(marked)
			for x, y in points:
				if view[0] <= x <= view[2] and view[1] <= y <= view[3]:
					px = (x - view[0]) * TILE
					py = (view[3] - y) * TILE  # y w DM rośnie w górę, w obrazku w dół
					draw.rectangle([px, py, px + TILE - 1, py + TILE - 1], outline=(255, 40, 40, 255), width=2)
			gap = 12
			sheet = Image.new("RGBA", (before.width * 3 + gap * 2, before.height + 24), (24, 24, 24, 255))
			label = ImageDraw.Draw(sheet)
			for i, (img, name) in enumerate(((before, "przed"), (after, "po"), (marked, "po + zmiany"))):
				sheet.paste(img, (i * (before.width + gap), 24))
				label.text((i * (before.width + gap) + 4, 6), name, fill=(230, 230, 230, 255))
			name = f"{os.path.splitext(os.path.basename(path))[0]}_z{z}_{n}.png"
			sheet.save(os.path.join(out_dir, name))
			lines.append(f"  - Z{z}, kafelki ({box[0]},{box[1]})–({box[2]},{box[3]}): `{name}`")
	return lines


# --- ikony ---

def load_dmi(data):
	image = Image.open(io.BytesIO(data))
	desc = image.info.get("Description", "")
	image = image.convert("RGBA")
	w = int(re.search(r"width = (\d+)", desc).group(1))
	h = int(re.search(r"height = (\d+)", desc).group(1))
	cols = max(1, image.width // w)
	states = {}
	index = 0
	for block in re.split(r"\nstate = ", desc)[1:]:
		name = re.match(r'"([^"]*)"', block).group(1)
		dirs = int(re.search(r"dirs = (\d+)", block).group(1))
		frames = int(re.search(r"frames = (\d+)", block).group(1))
		frames_list = []
		for _ in range(dirs * frames):
			x, y = (index % cols) * w, (index // cols) * h
			frames_list.append(image.crop((x, y, x + w, y + h)))
			index += 1
		states[name] = {"dirs": dirs, "frames": frames, "images": frames_list}
	return states, (w, h)


def same(a, b):
	return a["dirs"] == b["dirs"] and a["frames"] == b["frames"] and all(x.tobytes() == y.tobytes() for x, y in zip(a["images"], b["images"]))


def icon_diff(path, base, out_dir):
	old_bytes = git("show", f"{base}:{path}", binary=True)
	new_states, (w, h) = load_dmi(new_bytes(path))
	old_states = load_dmi(old_bytes)[0] if old_bytes else {}
	rows = []
	for name in sorted(set(old_states) | set(new_states)):
		a, b = old_states.get(name), new_states.get(name)
		if a and b and same(a, b):
			continue
		rows.append((name, a, b))
	if not rows:
		return [f"- `{path}`: bez zmian w stanach"]
	scale = 2 if w <= 32 else 1
	cell = (w * scale, h * scale)
	per_side = max(min(len((r[1] or r[2])["images"]), 8) for r in rows)
	label_w = 220
	width = label_w + (per_side * (cell[0] + 2)) * 2 + 30
	sheet = Image.new("RGBA", (width, 20 + len(rows) * (cell[1] + 8)), (40, 40, 40, 255))
	draw = ImageDraw.Draw(sheet)
	draw.text((4, 4), "stan", fill=(230, 230, 230, 255))
	draw.text((label_w, 4), "przed", fill=(230, 230, 230, 255))
	draw.text((label_w + per_side * (cell[0] + 2) + 30, 4), "po", fill=(230, 230, 230, 255))
	summary = []
	for i, (name, a, b) in enumerate(rows):
		y = 20 + i * (cell[1] + 8)
		kind = "nowy" if not a else "usunięty" if not b else "zmieniony"
		summary.append(f"`{name or '(bez nazwy)'}` ({kind})")
		draw.text((4, y + cell[1] // 2 - 6), f"{(name or '(bez nazwy)')[:28]} [{kind}]", fill=(230, 230, 230, 255))
		for side, state in enumerate((a, b)):
			if not state:
				continue
			x0 = label_w + side * (per_side * (cell[0] + 2) + 30)
			for k, frame in enumerate(state["images"][:per_side]):
				sheet.paste(frame.resize(cell, Image.NEAREST), (x0 + k * (cell[0] + 2), y), frame.resize(cell, Image.NEAREST))
	name = os.path.splitext(os.path.basename(path))[0] + "_ikony.png"
	sheet.save(os.path.join(out_dir, name))
	shown = ", ".join(summary[:12]) + (f" i {len(summary) - 12} więcej" if len(summary) > 12 else "")
	return [f"- `{path}`: {shown} → `{name}`"]


def main():
	for stream in (sys.stdout, sys.stderr):
		stream.reconfigure(encoding="utf-8", errors="replace")
	parser = argparse.ArgumentParser(description="Obrazki przed/po dla zmienionych map i ikon.")
	parser.add_argument("--baza", default="aq33/master")
	parser.add_argument("--out", default=os.path.join(REPO, "raport", "pr_diff"))
	parser.add_argument("--margines", type=int, default=3, help="kafelki kontekstu wokół zmian")
	parser.add_argument("--tylko", nargs="*", help="tylko te pliki")
	parser.add_argument("--cel", help="commit „po” zamiast bieżących plików, np. hash scalonego PR-a (baza: jego rodzic)")
	args = parser.parse_args()
	global TARGET
	TARGET = args.cel

	maps, icons = changed_files(args.baza, args.tylko)
	if not maps and not icons:
		print(f"Brak zmienionych .dmm i .dmi względem {args.baza}.")
		return 0
	os.makedirs(args.out, exist_ok=True)
	work = tempfile.mkdtemp(prefix="pr-diff-")
	lines = []
	try:
		if maps:
			tool = dmm_tools()
			lines.append("**Mapy**")
			for path in maps:
				print(f"mapa {path}...")
				lines += map_diff(path, args.baza, args.out, args.margines, tool, work)
		if icons:
			lines.append("**Ikony**")
			for path in icons:
				print(f"ikony {path}...")
				lines += icon_diff(path, args.baza, args.out)
	finally:
		shutil.rmtree(work, ignore_errors=True)
	print(f"\nObrazki w {args.out}\n")
	print("\n".join(lines))
	return 0


if __name__ == "__main__":
	sys.exit(main())
