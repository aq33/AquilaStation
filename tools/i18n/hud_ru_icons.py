"""Rosyjskie wersje ikon HUD-u (napisy na guzikach) dla graczy z językiem RU.

Jak hud_en_icons.py, ale bez oryginału do skopiowania: polski napis (pas wierszy różny od
angielskiego upstreamu NSV13) jest wymazywany, a rosyjski rysowany pikselową cyrylicą 3x5
w kolorze polskich liter, na środku miejsca po polskim napisie.

Użycie (z katalogu repo, potrzebny nsv13up/master z upstreamem NSV13):
    python tools/i18n/hud_ru_icons.py
Po zmianie polskich ikon HUD-u trzeba uruchomić ponownie (razem z hud_en_icons.py).
"""

import os
import sys
from collections import Counter

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, os.path.dirname(__file__))
from dmi import Dmi  # noqa: E402
import hud_en_icons as en  # noqa: E402

OUT_DIR = "aquila/icons/hud/ru"

# Napis rosyjski dla stanu (stany o tej samej nazwie mają ten sam napis we wszystkich stylach)
LABELS = {
    "harm": "ВРЕД",
    "help": "ПОМОЩЬ",
    "disarm": "ОБЕЗОР",
    "grab": "ЗАХВАТ",
    "pull": "ТЯНУТЬ",
    "act_resist": "ОТПОР",
    "act_drop": "СБРОС",
    "act_throw_off": "БРОСОК",
    "act_throw_on": "БРОСОК",
    "act_rest0": "ЛЕЧЬ",
    "act_rest": "ЛЕЧЬ",
    "swap_1": "СМЕНА",
    "swap_2": "СМЕНА",
    "swap_1_m": "СМЕНА",
    "walking": "ШАГ",
    "running": "БЕГ",
    "health6": "КРИТ",
    "health7": "ТРУП",
    "combat": "АТАКА",
    "combat_off": "АТАКА",
}

# Guziki obejrzane po wygenerowaniu, na których rosyjski napis wychodzi nieczysto (napis na całą
# szerokość guzika albo nachodzący na rysunek): zostaje napis angielski z hud_en_icons.py
FORCE_ENGLISH = {
    ("midnight", "help"),
    ("midnight", "disarm"),
    ("midnight", "pull"),
    ("plasmafire", "harm"),
    ("retro", "harm"),
    ("retro", "disarm"),
    ("retro", "help"),
}

# Krótsze napisy dla wąskich wyświetlaczy LED (Midnight, Plasmafire); bez krótszego: napis angielski
SHORT_LABELS = {
    "grab": "ХВАТ",
    "help": "МИР",
}

# Cyrylica 3x5 (szersze litery: М, Ш, Щ, Ы, Ю, Ж)
FONT = {
    "А": [".#.", "#.#", "###", "#.#", "#.#"],
    "Б": ["###", "#..", "##.", "#.#", "##."],
    "В": ["##.", "#.#", "##.", "#.#", "##."],
    "Г": ["###", "#..", "#..", "#..", "#.."],
    "Д": [".##.", ".#.#", ".#.#", "####", "#..#"],
    "Е": ["###", "#..", "##.", "#..", "###"],
    "Ж": ["#.#.#", "#.#.#", ".###.", "#.#.#", "#.#.#"],
    "З": ["##.", "..#", ".#.", "..#", "##."],
    "И": ["#..#", "#..#", "#.##", "##.#", "#..#"],
    "К": ["#.#", "#.#", "##.", "#.#", "#.#"],
    "Л": [".##", "#.#", "#.#", "#.#", "#.#"],
    "М": ["#..#", "####", "#..#", "#..#", "#..#"],
    "Н": ["#.#", "#.#", "###", "#.#", "#.#"],
    "О": [".#.", "#.#", "#.#", "#.#", ".#."],
    "П": ["###", "#.#", "#.#", "#.#", "#.#"],
    "Р": ["##.", "#.#", "##.", "#..", "#.."],
    "С": [".##", "#..", "#..", "#..", ".##"],
    "Т": ["###", ".#.", ".#.", ".#.", ".#."],
    "У": ["#.#", "#.#", ".##", "..#", "##."],
    "Ф": [".#.", "###", "#.#", "###", ".#."],
    "Х": ["#.#", "#.#", ".#.", "#.#", "#.#"],
    "Ч": ["#.#", "#.#", ".##", "..#", "..#"],
    "Ш": ["#.#.#", "#.#.#", "#.#.#", "#.#.#", "#####"],
    "Щ": ["#.#.", "#.#.", "#.#.", "####", "...#"],
    "Ы": ["#...#", "#...#", "##..#", "#.#.#", "##..#"],
    "Ь": ["#..", "#..", "##.", "#.#", "##."],
    "Э": ["##.", "..#", ".##", "..#", "##."],
    "Ю": ["#..#.", "#.#.#", "###.#", "#.#.#", "#..#."],
    "Я": [".##", "#.#", ".##", "#.#", "#.#"],
}


def text_width(text):
    return sum(len(FONT[c][0]) for c in text) + len(text) - 1


# najmniejsza różnica koloru liter od tła wiersza (suma różnic RGB)
LETTER_CONTRAST = 60


def distance(c1, c2):
    return sum(abs(c1[i] - c2[i]) for i in range(3))


def row_background(px, box, y, letter=None):
    """Tło wiersza w ramce napisu: najczęstszy kolor wyraźnie inny niż litery
    (guziki mają poziome paski; w wierszu bywa więcej liter niż tła)."""
    x0, _, x1, _ = box
    counts = Counter(px[x, y] for x in range(x0, x1 + 1)
                     if px[x, y][3] and (letter is None or distance(px[x, y], letter) >= LETTER_CONTRAST))
    return counts.most_common(1)[0][0] if counts else None


def letter_color(px, box):
    """Kolor liter: najczęstszy kolor w ramce, który wyraźnie odstaje od tła swojego wiersza."""
    x0, y0, x1, y1 = box
    counts = Counter()
    for y in range(y0, y1 + 1):
        background = row_background(px, box, y)
        if background is None:
            continue
        for x in range(x0, x1 + 1):
            color = px[x, y]
            if color[3] and distance(color, background) >= LETTER_CONTRAST:
                counts[color] += 1
    return counts.most_common(1)[0][0] if counts else None


def text_region(frame, upstream, band):
    """Polski napis w pasie band: ramka pikseli różnych od upstreamu, ramka liter i kolor liter."""
    a, b = frame.load(), upstream.load()
    top, bottom = band
    diff = [(x, y) for y in range(top, bottom + 1) for x in range(frame.size[0])
            if a[x, y] != b[x, y] and (a[x, y][3] or b[x, y][3])]
    if not [p for p in diff if a[p][3]]:
        return None
    box = (min(p[0] for p in diff), min(p[1] for p in diff), max(p[0] for p in diff), max(p[1] for p in diff))
    color = letter_color(a, box)
    if color is None:
        return None
    letters = [p for p in diff if a[p] == color] or diff
    letter_box = (min(p[0] for p in letters), min(p[1] for p in letters), max(p[0] for p in letters), max(p[1] for p in letters))
    return box, letter_box, color


def erase(image, box, rows, letter):
    """Zamalowuje w wierszach rows (od-do) ramki piksele odstające od tła wiersza (litery, cienie,
    ogonki). Zwraca False, gdy któryś wiersz nie ma tła (napis nie do wymazania)."""
    px = image.load()
    x0, _, x1, _ = box
    for y in range(rows[0], rows[1] + 1):
        background = row_background(px, box, y, letter)
        if background is None:
            return False
        for x in range(x0, x1 + 1):
            if px[x, y][3] and distance(px[x, y], background) >= LETTER_CONTRAST // 2:
                px[x, y] = background
    return True


def draw(image, text, center_x, center_y, color):
    px = image.load()
    width = text_width(text)
    cx = max(0, min(center_x - width // 2, image.size[0] - width))
    cy = center_y - 2
    for char in text:
        glyph = FONT[char]
        for gy, row in enumerate(glyph):
            for gx, cell in enumerate(row):
                y = cy + gy
                if cell == "#" and 0 <= y < image.size[1]:
                    px[cx + gx, y] = color
        cx += len(glyph[0]) + 1


def redraw(image, box, color, text, letter_box=None):
    """Wymazuje polski napis i rysuje text na środku miejsca po polskich literach (None: nie da się)."""
    out = image.convert("RGBA").copy()
    lx0, ly0, lx1, ly1 = letter_box or box
    # ogonki i kreski polskich liter wystają wiersz nad i pod literę
    rows = (max(box[1], ly0 - 1), min(box[3], ly1 + 1))
    if not erase(out, box, rows, color):
        return None
    # resztki polskich liter (w kolorze liter) w całej ramce: napis nie do czystego przerobienia
    px = out.load()
    for y in range(box[1], box[3] + 1):
        for x in range(box[0], box[2] + 1):
            if px[x, y][3] and distance(px[x, y], color) < LETTER_CONTRAST // 2:
                return None
    draw(out, text, (lx0 + lx1 + 1) // 2, (ly0 + ly1 + 1) // 2, color)
    return out


def relabel(a, b, label):
    """Klatka a (polska) z rosyjskim napisem według różnicy od b (upstream) albo None."""
    band = en.diff_band(a, b) if a.size == b.size else None
    if not band or band[1] - band[0] + 1 > en.MAX_BAND:
        return None
    found = text_region(a, b, band)
    if not found:
        return None
    box, letter_box, color = found
    if is_led_panel(a, letter_box):
        image = led_redraw(a, letter_box, label)
        return (image, letter_box) if image else None
    image = redraw(a, box, color, label, letter_box)
    return (image, box) if image else None


def is_led_panel(image, letter_box):
    """Wyświetlacz z punktami zapalonymi i zgaszonymi: w ramce liter nie ma żadnego koloru
    z pikseli tuż obok niej (zwykły napis leży na tych samych paskach co otoczenie)."""
    px = image.load()
    x0, y0, x1, y1 = letter_box
    if x0 < 1 or x1 >= image.size[0] - 1:
        return False
    outside = {px[x0 - 1, y] for y in range(y0, y1 + 1)} | {px[x1 + 1, y] for y in range(y0, y1 + 1)}
    inside = {px[x, y] for y in range(y0, y1 + 1) for x in range(x0, x1 + 1)}
    return not inside & outside


def brightness(color):
    return sum(color[:3])


def led_redraw(image, panel, label):
    """Napis na wyświetlaczu LED: w każdym wierszu najjaśniejszy kolor to punkt zapalony,
    najciemniejszy zgaszony. Napis musi się zmieścić w panelu (inaczej krótszy albo None)."""
    out = image.convert("RGBA").copy()
    px = out.load()
    x0, y0, x1, y1 = panel
    width = x1 - x0 + 1
    if text_width(label) > width:
        label = next((short for name, short in SHORT_LABELS.items() if LABELS.get(name) == label and text_width(short) <= width), None)
        if not label:
            return None
    lit, unlit = {}, {}
    for y in range(y0, y1 + 1):
        colors = {px[x, y] for x in range(x0, x1 + 1)}
        lit[y] = max(colors, key=brightness)
        unlit[y] = min(colors, key=brightness)
        for x in range(x0, x1 + 1):
            px[x, y] = unlit[y]
    cx = x0 + (width - text_width(label)) // 2
    cy = y0 + (y1 - y0 + 1 - 5) // 2
    for char in label:
        glyph = FONT[char]
        for gy, row in enumerate(glyph):
            for gx, cell in enumerate(row):
                y = cy + gy
                if cell == "#" and y0 <= y <= y1:
                    px[cx + gx, y] = lit[y]
        cx += len(glyph[0]) + 1
    return out


def fallback(state, english, report, where):
    """Guzik, którego nie da się czysto przerobić: napis z angielskiej kopii (hud_en_icons.py)."""
    try:
        state.frames = list(english.get_state(state.name).frames)
    except KeyError:
        return
    report.append((where, state.name, "EN (zapasowo)", None))


def translate_state(state, original, english, report, where):
    label = LABELS.get(state.name)
    if not label or len(original.frames) != len(state.frames):
        return
    if (where, state.name) in FORCE_ENGLISH:
        fallback(state, english, report, where)
        return
    frames = []
    used = None
    for frame, up_frame in zip(state.frames, original.frames):
        result = relabel(frame.convert("RGBA"), up_frame.convert("RGBA"), label)
        if not result:
            frames.append(None)
            continue
        frames.append(result[0])
        used = result[1]
    if not used:
        return
    if None in frames:
        fallback(state, english, report, where)
        return
    state.frames = frames
    report.append((where, state.name, label, used))


def joined(left, right):
    from PIL import Image

    out = Image.new("RGBA", (left.size[0] + right.size[0], left.size[1]))
    out.paste(left.convert("RGBA"), (0, 0))
    out.paste(right.convert("RGBA"), (left.size[0], 0))
    return out


def translate_swap(cur, up, english, report, where):
    """Guzik zmiany ręki to dwa kafelki: swap_1 (albo swap_1_m) po lewej, swap_2 po prawej,
    a napis (ZAMIEŃ) biegnie przez oba. Napis przerysowujemy na sklejonym obrazku;
    gdy się nie da, cały guzik bierze angielską kopię."""
    names = {s.name for s in cur.states}
    if "swap_2" not in names:
        return
    right = cur.get_state("swap_2")
    right_up = up.get_state("swap_2")
    results = {}
    for left_name in ("swap_1", "swap_1_m"):
        if left_name not in names:
            continue
        left = cur.get_state(left_name)
        a = joined(left.frames[0], right.frames[0])
        b = joined(up.get_state(left_name).frames[0], right_up.frames[0])
        results[left_name] = relabel(a, b, LABELS["swap_2"])
    if not results or None in results.values():
        for name in ("swap_1", "swap_1_m", "swap_2"):
            if name in names:
                fallback(cur.get_state(name), english, report, where)
        return
    for left_name, (image, box) in results.items():
        left = cur.get_state(left_name)
        width = left.frames[0].size[0]
        left.frames = [image.crop((0, 0, width, image.size[1]))]
        report.append((where, left_name + "+swap_2", LABELS["swap_2"], box))
    image = results.get("swap_1", next(iter(results.values())))[0]
    right.frames = [image.crop((cur.get_state("swap_1" if "swap_1" in results else left_name).frames[0].size[0], 0, image.size[0], image.size[1]))]


def build_dmi(path, english_path, report, where):
    cur = Dmi.from_file(path)
    up = en.git_dmi(path)
    english = Dmi.from_file(english_path)
    translate_swap(cur, up, english, report, where)
    for state in cur.states:
        if state.name.startswith("swap_"):
            continue
        try:
            original = up.get_state(state.name)
        except KeyError:
            continue
        translate_state(state, original, english, report, where)
    return cur


def fixed_box(state, box, label, english, report, where):
    """Napis dodany u nas (bez oryginału w upstreamie) w stałej ramce."""
    frame = state.frames[0].convert("RGBA")
    color = letter_color(frame.load(), box)
    frames = [redraw(f, box, color, label) if color else None for f in state.frames]
    if None in frames:
        fallback(state, english, report, where)
        return
    state.frames = frames
    report.append((where, state.name, label, box))


def build_combat(cur, english, report, where):
    """WALKA (x4..27, wiersze 4..8): ramka jak w hud_en_icons.py."""
    for state in cur.states:
        if state.name in ("combat", "combat_off"):
            fixed_box(state, (3, 4, 28, 8), LABELS[state.name], english, report, where)


def build_porzadki(report):
    cur = Dmi.from_file("aquila/icons/hud/ui_porzadki.dmi")
    english = Dmi.from_file("aquila/icons/hud/en/ui_porzadki.dmi")
    for state in cur.states:
        if state.name.endswith("_sleep"):
            # ŚPIJ (x10..21, wiersze 4..10 razem z kreską nad S) -> СОН
            fixed_box(state, (9, 4, 22, 10), "СОН", english, report, "ui_porzadki")
    return cur


def build_console_tab(name, text, erase_box):
    """Zakładka panelu konsoli statku: jednolite tło, napis szary jak w polskiej."""
    from PIL import Image

    image = Image.open(f"aquila/icons/overmap/gui/{name}").convert("RGBA")
    px = image.load()
    x0, y0, x1, y1 = erase_box
    text_color = (104, 104, 104, 255)
    background = px[x0, y1 + 1]
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if px[x, y] == text_color:
                px[x, y] = background
    cx = 12
    for char in text:
        glyph = FONT[char]
        for gy, row in enumerate(glyph):
            for gx, cell in enumerate(row):
                if cell == "#":
                    px[cx + gx, 4 + gy] = text_color
        cx += len(glyph[0]) + 1
    image.save(f"{OUT_DIR}/{name}")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    report = []
    for name in en.STYLES:
        path = f"icons/mob/screen_{name}.dmi"
        english_path = f"{en.OUT_DIR}/screen_{name}.dmi"
        cur = build_dmi(path, english_path, report, name)
        build_combat(cur, Dmi.from_file(english_path), report, name)
        cur.to_file(f"{OUT_DIR}/screen_{name}.dmi")
    build_dmi("icons/mob/screen_gen.dmi", f"{en.OUT_DIR}/screen_gen.dmi", report, "gen").to_file(f"{OUT_DIR}/screen_gen.dmi")
    build_porzadki(report).to_file(f"{OUT_DIR}/ui_porzadki.dmi")
    build_console_tab("console_tab_closed.png", "КОНСОЛЬ", (12, 2, 39, 8))
    build_console_tab("console_tab_open.png", "ЗАКР", (12, 2, 28, 8))
    sys.stdout.reconfigure(encoding="utf-8")
    for row in report:
        print(*row)


if __name__ == "__main__":
    main()
