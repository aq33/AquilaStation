"""Obrazek mapy wojny (PNG) z zapisu kampanii: trzy sektory hex, układy w kolorach frakcji, które je trzymają,
kwatery główne, teren i ostatnie położenie okrętu załogi. Floty nie są rysowane (mgła wojny).

Siatka liczy się tak samo jak w aquila/code/modules/overmap/hexmap/hex_grid.dm (build, place_system), więc
identyfikatory hexów z hexmap.json (teren, okręt) trafiają w te same pola.

Bez Discorda: python tools/discord_bot/war_map.py [folder z hexmap.json] [plik.png]
"""

import io
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

import war_status

HEX_UNITS_PER_HEX = 4.6
HEX_MARGIN = 2
SECTORS = [(1, "Sektor Sol"), (2, "Sektor neutralny"), (3, "Sektor Syndykatu")]

R = 20  # promień hexa w pikselach
HEX_W = math.sqrt(3) * R
ROW_H = 1.5 * R
K = 2  # rysowanie w podwójnej rozdzielczości i zmniejszenie: gładkie krawędzie i napisy
PAD = 24

BACKGROUND = (11, 13, 20)
PANEL = (17, 20, 30)
PANEL_EDGE = (40, 46, 62)
GRID = (30, 35, 48)
TEXT = (232, 236, 244)
DIM_TEXT = (150, 158, 175)
TUNNEL = (120, 220, 255)
FACTION_COLOURS = {
    "nanotrasen": (66, 135, 245),
    "solgov": (80, 205, 200),
    "whiterapids": (160, 180, 240),
    "syndicate": (225, 60, 60),
    "pirate": (240, 165, 40),
    "hostile": (180, 90, 225),
    "unaligned": (125, 130, 142),
    "uncharted": (85, 90, 100),
}
# Teren: nazwa jak w grze (hex_terrain.dm) i przygaszony kolor, żeby nie zagłuszał układów
TERRAIN = {
    "meteor": ("Pole asteroid", (74, 62, 48)),
    "junk": ("Złomowisko", (60, 60, 56)),
    "nebula": ("Mgławica", (62, 44, 92)),
    "estorm": ("Burza elektryczna", (38, 60, 98)),
    "storm": ("Burza jonowa", (34, 74, 92)),
    "rad": ("Promieniowanie", (64, 82, 30)),
    "flare": ("Aktywność gwiazdy", (100, 64, 26)),
    "anom": ("Pole anomalii", (84, 44, 84)),
    "grav": ("Anomalia grawitacyjna", (40, 40, 56)),
    "bh": ("Czarna dziura", (0, 0, 0)),
    "carp": ("Ławica karpi", (34, 80, 84)),
    "comet": ("Kometa", (60, 84, 104)),
    "mines": ("Pole minowe", (104, 36, 36)),
    "signal": ("Nieznany sygnał", (34, 90, 60)),
}


def font(size, bold=False):
    if bold:
        names = ("arialbd.ttf", "DejaVuSans-Bold.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf")
    else:
        names = ("arial.ttf", "DejaVuSans.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def build_grid(starmap):
    """Wymiary sektorów i hex każdego układu, jak hexmap/build() w grze."""
    by_sector = {}
    for system in starmap:
        by_sector.setdefault(system.get("sector") or 2, []).append(system)
    sectors = {}
    placed = {}
    for sector, _ in SECTORS:
        systems = by_sector.get(sector)
        if not systems:
            continue
        min_x = min(s["x"] for s in systems)
        max_x = max(s["x"] for s in systems)
        min_y = min(s["y"] for s in systems)
        max_y = max(s["y"] for s in systems)
        for s in systems:  # obszary generatorów Badlands (starsystem.dm)
            if s.get("startup_proc") == "STARTUP_PROC_TYPE_BRASIL":
                min_x, max_x, min_y, max_y = min(min_x, 20), max(max_x, 102), min(min_y, 30), max(max_y, 82)
            elif s.get("startup_proc") == "STARTUP_PROC_TYPE_BRASIL_LITE":
                min_x, max_x, max_y = min(min_x, 26), max(max_x, 72), max(max_y, 156)
        cols = math.ceil((max_x - min_x) / HEX_UNITS_PER_HEX) + HEX_MARGIN * 2 + 1
        rows = math.ceil((max_y - min_y) / (HEX_UNITS_PER_HEX * 0.866)) + HEX_MARGIN * 2 + 1
        sectors[sector] = (cols, rows)
        taken = set()
        # Kolejność i wybór pola jak w grze: sortTim po nazwie bez wielkości liter, round() DM (połówki w górę),
        # zajęty hex: BFS po sąsiadach w kolejności hex_axial_dirs (place_system w czasie build())
        for s in sorted(systems, key=lambda s: s["name"].lower()):
            col = math.floor((s["x"] - min_x) / HEX_UNITS_PER_HEX + HEX_MARGIN + 0.5)
            row = math.floor((max_y - s["y"]) / (HEX_UNITS_PER_HEX * 0.866) + HEX_MARGIN + 0.5)
            col = max(0, min(col, cols - 1))
            row = max(0, min(row, rows - 1))
            spot = first_free((col, row), taken, cols, rows)
            if not spot:
                continue
            taken.add(spot)
            placed[s["name"]] = (sector, *spot)
    return sectors, placed


AXIAL_DIRS = [(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)]


def first_free(start, taken, cols, rows):
    """Najbliższe wolne pole od start, w tej samej kolejności co BFS w place_system."""
    queue = [start]
    seen = {start}
    while queue:
        col, row = queue.pop(0)
        if (col, row) not in taken:
            return col, row
        q = col - (row - (row & 1)) // 2
        for dq, dr in AXIAL_DIRS:
            nr = row + dr
            nc = q + dq + (nr - (nr & 1)) // 2
            if 0 <= nc < cols and 0 <= nr < rows and (nc, nr) not in seen:
                seen.add((nc, nr))
                queue.append((nc, nr))
    return None


def hexagon(cx, cy, radius):
    return [(cx + radius * math.cos(math.radians(60 * i - 30)), cy + radius * math.sin(math.radians(60 * i - 30)))
            for i in range(6)]


def render(folder):
    """PNG mapy jako bajty albo None, gdy zapisu nie ma."""
    state = war_status.load(folder)
    if not state:
        return None
    hexmap = state["hexmap"]  # te same dane co w raporcie: jeden odczyt plików
    starmap = state["starmap"]
    sectors, placed = build_grid(starmap)
    tiles = (hexmap.get("terrain") or {}).get("tiles") or {}
    if not isinstance(tiles, dict):
        tiles = {}
    wormholes = (hexmap.get("terrain") or {}).get("wormholes") or []
    hidden = {s["name"] for s in starmap if s.get("hidden")}
    holders = {s["name"]: state["occupied"].get(s["name"], s.get("alignment")) for s in starmap}
    hqs = {hq["system"]: hq for hq in state["hqs"]}
    visible = {name: spot for name, spot in placed.items() if name not in hidden}
    ship = parse_hex(hexmap.get("ship_hex"))

    terrain = {}
    for hex_id, kind in tiles.items():
        spot = parse_hex(hex_id)
        if spot and kind in TERRAIN:
            terrain[spot] = kind
    tunnels = {}
    for number, pair in enumerate(wormholes, 1):
        for hex_id in pair if isinstance(pair, list) else []:
            spot = parse_hex(hex_id)
            if spot:
                tunnels[spot] = number

    # Każdy sektor przycięty do tego, co w nim jest (układy, teren, okręt), z ramką jednego pola
    panels = []
    for sector, title in SECTORS:
        if sector not in sectors:
            continue
        content = list(visible.values()) + list(terrain) + list(tunnels) + ([ship] if ship else [])
        spots = [(c, r) for s, c, r in content if s == sector]
        if not spots:
            continue
        cols, rows = sectors[sector]
        c0 = max(0, min(c for c, _ in spots) - 1)
        c1 = min(cols - 1, max(c for c, _ in spots) + 1)
        r0 = max(0, min(r for _, r in spots) - 1)
        r1 = min(rows - 1, max(r for _, r in spots) + 1)
        panels.append({"sector": sector, "title": title, "c0": c0, "c1": c1, "r0": r0, "r1": r1,
                       "w": (c1 - c0 + 1.5) * HEX_W * K, "h": ((r1 - r0) * ROW_H + 2 * R) * K})
    if not panels:
        return None

    pad = PAD * K
    top = 92 * K
    panel_title = 30 * K
    total_w = int(pad + sum(p["w"] + pad for p in panels))
    body_h = max(p["h"] for p in panels)
    present = sorted(set(terrain.values()), key=list(TERRAIN).index)
    legend_rows = 2 + (1 if present or tunnels else 0)
    total_h = int(top + panel_title + body_h + pad + legend_rows * 26 * K + pad)
    image = Image.new("RGB", (total_w, total_h), BACKGROUND)
    draw = ImageDraw.Draw(image)

    # Nagłówek: tytuł, data zapisu i liczba układów każdej frakcji
    draw.text((pad, 16 * K), "Mapa wojny", font=font(26 * K, bold=True), fill=TEXT)
    draw.text((total_w - pad, 24 * K), war_status.footer(state), font=font(13 * K), fill=DIM_TEXT, anchor="ra")
    head_font = font(15 * K, bold=True)
    x = pad
    for faction in war_status.MAIN_FACTIONS:
        count = state["systems"].get(faction, 0)
        draw.rounded_rectangle((x, 57 * K, x + 13 * K, 70 * K), radius=3 * K, fill=FACTION_COLOURS[faction])
        text = f"{war_status.faction_name(faction)}: {war_status.plural(count, 'układ', 'układy', 'układów')}"
        draw.text((x + 19 * K, 55 * K), text, font=head_font, fill=TEXT)
        x += 19 * K + draw.textlength(text, font=head_font) + 28 * K

    label_font = font(12 * K, bold=True)
    x = pad
    for panel in panels:
        sector = panel["sector"]
        px, py = x, top + panel_title

        def pos(col, row, panel=panel, px=px, py=py):
            cx = (col - panel["c0"] + (0.5 if row & 1 else 0)) * HEX_W + HEX_W / 2
            cy = (row - panel["r0"]) * ROW_H + R
            return px + cx * K, py + cy * K

        draw.rounded_rectangle((px - 8 * K, py - 8 * K, px + panel["w"] + 8 * K, py + panel["h"] + 8 * K),
                               radius=10 * K, fill=PANEL, outline=PANEL_EDGE, width=K)
        draw.text((px, top + 2 * K), panel["title"], font=font(16 * K, bold=True), fill=DIM_TEXT)
        for row in range(panel["r0"], panel["r1"] + 1):
            for col in range(panel["c0"], panel["c1"] + 1):
                cx, cy = pos(col, row)
                kind = terrain.get((sector, col, row))
                if kind:
                    draw.polygon(hexagon(cx, cy, (R - 1) * K), fill=TERRAIN[kind][1])
                else:
                    draw.polygon(hexagon(cx, cy, (R - 1) * K), outline=GRID, width=K)
        for (s, col, row), number in tunnels.items():
            if s == sector:
                cx, cy = pos(col, row)
                draw.ellipse((cx - 9 * K, cy - 9 * K, cx + 9 * K, cy + 9 * K), outline=TUNNEL, width=2 * K)
                draw.text((cx, cy), str(number), font=font(10 * K, bold=True), fill=TUNNEL, anchor="mm")

        names = [(name, spot) for name, spot in visible.items() if spot[0] == sector]
        boxes = []  # zajęte prostokąty układów i napisów, żeby napisy na siebie nie wchodziły
        for name, (_, col, row) in names:
            cx, cy = pos(col, row)
            boxes.append((cx - (R - 4) * K, cy - (R - 4) * K, cx + (R - 4) * K, cy + (R - 4) * K))
            colour = FACTION_COLOURS.get(holders.get(name), FACTION_COLOURS["unaligned"])
            draw.polygon(hexagon(cx, cy, (R - 2) * K), fill=colour, outline=(8, 10, 16), width=K)
            draw.ellipse((cx - 3 * K, cy - 3 * K, cx + 3 * K, cy + 3 * K), fill=(250, 250, 250))
            if name in hqs:
                hq = hqs[name]
                ring = FACTION_COLOURS[hq["faction"]] if hq["held"] else (255, 255, 255)
                draw.polygon(hexagon(cx, cy, (R + 3) * K), outline=ring, width=3 * K)
        if ship and ship[0] == sector:
            cx, cy = pos(ship[1], ship[2])
            draw.polygon([(cx, cy - 12 * K), (cx + 10 * K, cy + 8 * K), (cx - 10 * K, cy + 8 * K)],
                         fill=(255, 255, 255), outline=(0, 0, 0), width=2 * K)
        for name, (_, col, row) in sorted(names, key=lambda n: (n[1][2], n[1][1])):
            cx, cy = pos(col, row)
            text = name
            w = draw.textlength(text, font=label_font)
            h = 14 * K
            gap = (R + 1) * K
            options = [(cx + gap, cy - h / 2), (cx - gap - w, cy - h / 2), (cx - w / 2, cy + gap - 4 * K),
                       (cx - w / 2, cy - gap - h + 2 * K)]
            inside = (px - 6 * K, py - 6 * K, px + panel["w"] + 6 * K, py + panel["h"] + 6 * K)
            # Pierwsze miejsce w panelu bez kolizji; gdy takiego nie ma, pierwsze w panelu
            candidates = []
            for ax, ay in options:
                box = (ax - 2 * K, ay - 2 * K, ax + w + 2 * K, ay + h + 2 * K)
                if box[0] >= inside[0] and box[1] >= inside[1] and box[2] <= inside[2] and box[3] <= inside[3]:
                    candidates.append((any(overlap(box, other) for other in boxes), ax, ay, box))
            if candidates:
                _, ax, ay, box = min(candidates, key=lambda c: c[0])
            else:
                ax, ay = options[0]
                box = (ax, ay, ax + w, ay + h)
            boxes.append(box)
            draw.text((ax, ay), text, font=label_font, fill=TEXT, stroke_width=3 * K, stroke_fill=(5, 6, 10))
        x += panel["w"] + pad

    # Legenda
    y = top + panel_title + body_h + pad
    small = font(13 * K)
    x = pad
    for faction in war_status.MAIN_FACTIONS + ["hostile", "unaligned"]:
        draw.polygon(hexagon(x + 8 * K, y + 8 * K, 8 * K), fill=FACTION_COLOURS[faction])
        text = war_status.faction_name(faction)
        draw.text((x + 22 * K, y), text, font=small, fill=TEXT)
        x += 40 * K + draw.textlength(text, font=small)
    y += 26 * K
    x = pad
    draw.polygon(hexagon(x + 8 * K, y + 8 * K, 9 * K), outline=(255, 255, 255), width=2 * K)
    text = "kwatera główna (biała ramka: zajęta przez wroga)"
    draw.text((x + 22 * K, y), text, font=small, fill=TEXT)
    x += 50 * K + draw.textlength(text, font=small)
    draw.polygon([(x + 8 * K, y), (x + 16 * K, y + 15 * K), (x, y + 15 * K)], fill=(255, 255, 255))
    draw.text((x + 22 * K, y), "okręt załogi (koniec ostatniej rundy)", font=small, fill=TEXT)
    if present or tunnels:
        y += 26 * K
        x = pad
        for kind in present:
            draw.polygon(hexagon(x + 8 * K, y + 8 * K, 8 * K), fill=TERRAIN[kind][1], outline=GRID)
            draw.text((x + 22 * K, y), TERRAIN[kind][0], font=small, fill=DIM_TEXT)
            x += 40 * K + draw.textlength(TERRAIN[kind][0], font=small)
        if tunnels:
            draw.ellipse((x, y, x + 16 * K, y + 16 * K), outline=TUNNEL, width=2 * K)
            draw.text((x + 22 * K, y), "tunel (ten sam numer łączy oba końce)", font=small, fill=DIM_TEXT)

    image = image.resize((total_w // K, total_h // K), Image.LANCZOS)
    out = io.BytesIO()
    image.save(out, "PNG")
    return out.getvalue()


def parse_hex(hex_id):
    """'sektor:kolumna:wiersz' → (sektor, kolumna, wiersz) albo None."""
    try:
        sector, col, row = (int(v) for v in str(hex_id).split(":"))
    except ValueError:
        return None
    return sector, col, row


def overlap(a, b):
    return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parents[2] / "config" / "starmap"
    target = sys.argv[2] if len(sys.argv) > 2 else "mapa_wojny.png"
    sys.stdout.reconfigure(encoding="utf-8")
    png = render(folder)
    if not png:
        print("Brak zapisu kampanii albo wojna jeszcze nie ruszyła.")
        return 1
    Path(target).write_bytes(png)
    print(target)
    return 0


if __name__ == "__main__":
    sys.exit(main())
