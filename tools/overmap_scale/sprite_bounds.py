"""Obrysy sprite'ów overmapy dla skali wizualnej (aquila/code/modules/overmap/overmap_visual_scale.dm).

Dla każdego stanu ikony z nsv13/icons/overmap i aquila/icons/overmap liczy rozmiar klatki, prostokąt
niezerowej alfy (obrys kadłuba) i przesunięcie środka obrysu względem środka klatki (x w prawo, y w górę).
Wynik: aquila/code/modules/overmap/overmap_sprite_bounds.dm (generowany, nie edytować ręcznie).

Uruchom po dodaniu albo zmianie sprite'a okrętu:  python tools/overmap_scale/sprite_bounds.py
"""
import glob
import os
import re
import sys

from PIL import Image

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(REPO, "aquila", "code", "modules", "overmap", "overmap_sprite_bounds.dm")
FOLDERS = ["nsv13/icons/overmap", "aquila/icons/overmap"]
# Nakładki i stany pomocnicze: nie są kadłubem okrętu
SKIP = re.compile(r"(^|_)(thrust|rcs|railgun|canopy|launcher)|Port$|Starboard$|^$")
STATE_RE = re.compile(r'state = "([^"]*)"\s*\n\s*dirs = (\d+)(?:\s*\n\s*frames = (\d+))?')


def states(path):
    im = Image.open(path)
    desc = im.info.get("Description", "")
    mw = re.search(r"width = (\d+)", desc)
    mh = re.search(r"height = (\d+)", desc)
    if not mw or not mh:
        return
    w, h = int(mw.group(1)), int(mh.group(1))
    cols = max(1, im.width // w)
    rgba = im.convert("RGBA")
    idx = 0
    for m in STATE_RE.finditer(desc):
        name, dirs, frames = m.group(1), int(m.group(2)), int(m.group(3) or 1)
        # pierwsza klatka pierwszego kierunku (SOUTH), tak jak icon(icon, icon_state, SOUTH) w core
        x, y = (idx % cols) * w, (idx // cols) * h
        idx += dirs * frames
        if SKIP.search(name) or re.search(r"-\d+$", name):
            continue
        frame = rgba.crop((x, y, x + w, y + h))
        bbox = frame.getbbox()
        if not bbox:
            continue
        bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
        off_x = (bbox[0] + bbox[2]) / 2 - w / 2
        off_y = h / 2 - (bbox[1] + bbox[3]) / 2  # obraz ma y w dół, BYOND w górę
        yield name, (w, h, bw, bh, round(off_x, 1), round(off_y, 1))


def main():
    rows = []
    for folder in FOLDERS:
        for path in sorted(glob.glob(os.path.join(REPO, folder, "**", "*.dmi"), recursive=True)):
            rel = os.path.relpath(path, REPO).replace("\\", "/")
            for name, vals in states(path):
                rows.append((f"{rel}|{name}", vals))
    rows.sort()
    lines = [
        "// GENEROWANE przez tools/overmap_scale/sprite_bounds.py - nie edytować ręcznie.",
        "// \"ikona|stan\" = list(szerokość klatki, wysokość klatki, szerokość kadłuba, wysokość kadłuba, przesunięcie środka x, y)",
        "GLOBAL_LIST_INIT(overmap_sprite_bounds, list(",
    ]
    lines.append(",\n".join(f'\t"{key}" = list({", ".join(str(v) for v in vals)})' for key, vals in rows))
    lines.append("))")
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines) + "\n")
    print(f"zapisano {len(rows)} stanów do {os.path.relpath(OUT, REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
