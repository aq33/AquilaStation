"""Angielskie wersje ikon HUD-u (napisy na guzikach) dla graczy z językiem EN.

Napisy na guzikach (OPÓR, RZUĆ, LEŻ, WALKA, ŚPIJ...) są narysowane w plikach .dmi.
Gracz z angielskim dostaje kopię pliku z angielskimi napisami
(aquila/code/modules/i18n/hud_icons.dm podmienia ikony jego HUD-u):

- guziki, które mają angielski oryginał w upstreamie NSV13: bierzemy z oryginału tylko
  pas wierszy z napisem, reszta grafiki zostaje nasza;
- guziki dodane u nas z polskim napisem (WALKA, ŚPIJ, wąskie CHD w Retro): wymazujemy
  napis (tło z wiersza o dwa wyżej, paski tła mają okres 2) i rysujemy angielski tą samą
  pikselową czcionką i kolorem.

Użycie (z katalogu repo, potrzebny remote nsv13up z upstreamem NSV13):
    python tools/i18n/hud_en_icons.py
Po zmianie polskich ikon HUD-u trzeba uruchomić ponownie.
"""

import io
import os
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from dmi import Dmi  # noqa: E402

UPSTREAM = "nsv13up/master"
OUT_DIR = "aquila/icons/hud/en"
STYLES = ["midnight", "retro", "plasmafire", "slimecore", "operative", "clockwork"]
# najwyższy pas z napisem; większa różnica od upstreamu to inna grafika, nie napis
MAX_BAND = 16

# Czcionki napisów (wiersze glifu, "#" = piksel napisu)
FONT5 = {  # WALKA, 5 wierszy; litery po 3 piksele, żeby COMBAT zmieścił się w guziku
    "C": [".##", "#..", "#..", "#..", ".##"],
    "O": [".#.", "#.#", "#.#", "#.#", ".#."],
    "M": ["#...#", "##.##", "#.#.#", "#...#", "#...#"],
    "B": ["##.", "#.#", "##.", "#.#", "##."],
    "A": [".#.", "#.#", "###", "#.#", "#.#"],
    "T": ["###", ".#.", ".#.", ".#.", ".#."],
    "W": ["#.#", "#.#", "###", "###", "#.#"],
    "L": ["#..", "#..", "#..", "#..", "###"],
    "K": ["#.#", "#.#", "##.", "#.#", "#.#"],
}
FONT6 = {  # ŚPIJ, 6 wierszy
    "S": ["###", "#..", "#..", "###", "..#", "###"],
    "L": ["#..", "#..", "#..", "#..", "#..", "###"],
    "E": ["###", "#..", "###", "#..", "#..", "###"],
    "P": ["###", "#.#", "###", "#..", "#..", "#.."],
}


def git_dmi(path):
    data = subprocess.run(["git", "show", f"{UPSTREAM}:{path}"], capture_output=True, check=True).stdout
    tmp = io.BytesIO(data)
    return Dmi.from_file(tmp)


def text_width(text, font):
    return sum(len(font[c][0]) for c in text) + len(text) - 1


def diff_band(a, b):
    """Pas wierszy, w których obraz różni się od oryginału (bez pikseli przezroczystych w obu)."""
    pa, pb = a.load(), b.load()
    counts = [0] * a.size[1]
    for y in range(a.size[1]):
        for x in range(a.size[0]):
            if pa[x, y] != pb[x, y] and (pa[x, y][3] or pb[x, y][3]):
                counts[y] += 1
    if not any(counts):
        return None
    # od wiersza z największą różnicą w górę i w dół, z przerwą najwyżej jednego wiersza
    top = bottom = counts.index(max(counts))
    while top > 0 and (counts[top - 1] or (top > 1 and counts[top - 2])):
        top -= 1
    while bottom < len(counts) - 1 and (counts[bottom + 1] or (bottom < len(counts) - 2 and counts[bottom + 2])):
        bottom += 1
    return top, bottom


def copy_band(cur, up, band):
    out = cur.copy()
    top, bottom = band
    out.paste(up.crop((0, top, up.size[0], bottom + 1)), (0, top))
    return out


def redraw(image, box, text, font, origin, probe):
    """Wymazuje napis w ramce box (x0, y0, x1, y1 włącznie) i rysuje text od origin.
    probe to piksel litery polskiego napisu: jego kolor to kolor napisu (paski tła
    zmieniają kolor co wiersz, więc najczęstszy kolor nim nie jest)."""
    out = image.convert("RGBA").copy()
    px = out.load()
    x0, y0, x1, y1 = box
    color = px[probe]
    mask = {(x, y) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1) if px[x, y] == color}
    for x, y in sorted(mask, key=lambda p: p[1]):
        for dy in (-2, -4, -6, 2, 4, 6):
            sy = y + dy
            if 0 <= sy < out.size[1] and (x, sy) not in mask and px[x, sy][3]:
                px[x, y] = px[x, sy]
                break
    cx, cy = origin
    for char in text:
        glyph = font[char]
        for gy, row in enumerate(glyph):
            for gx, cell in enumerate(row):
                if cell == "#":
                    px[cx + gx, cy + gy] = color
        cx += len(glyph[0]) + 1
    return out


def replace_state(state, fn):
    state.frames = [fn(frame) for frame in state.frames]


def build_style(name, report):
    path = f"icons/mob/screen_{name}.dmi"
    cur = Dmi.from_file(path)
    up = git_dmi(path)
    for state in cur.states:
        if state.name in ("combat", "combat_off"):
            # WALKA (x4..27, wiersze 4..8) -> COMBAT, środek guzika
            width = text_width("COMBAT", FONT5)
            replace_state(state, lambda im: redraw(im, (3, 4, 28, 8), "COMBAT", FONT5, (16 - width // 2, 4), (15, 4)))
            report.append((name, state.name, "COMBAT"))
            continue
        try:
            original = up.get_state(state.name)
        except KeyError:
            continue
        if len(original.frames) != len(state.frames):
            continue
        new_frames, band_used = [], None
        for frame, up_frame in zip(state.frames, original.frames):
            a, b = frame.convert("RGBA"), up_frame.convert("RGBA")
            band = diff_band(a, b) if a.size == b.size else None
            if band and band[1] - band[0] + 1 <= MAX_BAND:
                new_frames.append(copy_band(a, b, band))
                band_used = band
            else:
                new_frames.append(frame)
        if band_used:
            state.frames = new_frames
            report.append((name, state.name, f"wiersze {band_used[0]}-{band_used[1]} z upstreamu"))
    if name == "retro":
        # wąski guzik chodu: "CHD" (x18..28, wiersze 4..8) -> "WLK"
        walking = cur.get_state("walking")
        replace_state(walking, lambda im: redraw(im, (18, 4, 28, 8), "WLK", FONT5, (18, 4), (18, 4)))
        report.append((name, "walking", "WLK"))
    return cur


def build_gen(report):
    path = "icons/mob/screen_gen.dmi"
    cur = Dmi.from_file(path)
    up = git_dmi(path)
    for state in cur.states:
        if state.name not in ("health6", "health7"):  # KRYT. i TRUP
            continue
        original = up.get_state(state.name)
        a, b = state.frames[0].convert("RGBA"), original.frames[0].convert("RGBA")
        band = diff_band(a, b)
        state.frames = [copy_band(f.convert("RGBA"), b, band) for f in state.frames]
        report.append(("gen", state.name, f"wiersze {band[0]}-{band[1]} z upstreamu"))
    return cur


def build_porzadki(report):
    cur = Dmi.from_file("aquila/icons/hud/ui_porzadki.dmi")
    width = text_width("SLEEP", FONT6)
    for state in cur.states:
        if state.name.endswith("_sleep"):
            # ŚPIJ (x10..21, wiersze 4..10 razem z kreską nad S) -> SLEEP
            replace_state(state, lambda im: redraw(im, (9, 4, 22, 10), "SLEEP", FONT6, (16 - width // 2 - 1, 5), (14, 5)))
            report.append(("ui_porzadki", state.name, "SLEEP"))
    return cur


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    report = []
    for name in STYLES:
        build_style(name, report).to_file(f"{OUT_DIR}/screen_{name}.dmi")
    build_gen(report).to_file(f"{OUT_DIR}/screen_gen.dmi")
    build_porzadki(report).to_file(f"{OUT_DIR}/ui_porzadki.dmi")
    sys.stdout.reconfigure(encoding="utf-8")
    for row in report:
        print(*row)


if __name__ == "__main__":
    main()
