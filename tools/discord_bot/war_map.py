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

R = 19  # promień hexa w pikselach
HEX_W = math.sqrt(3) * R
ROW_H = 1.5 * R
PAD = 24
TITLE_H = 40
LEGEND_H = 70

BACKGROUND = (14, 17, 26)
GRID = (34, 40, 56)
TEXT = (215, 220, 230)
DIM_TEXT = (140, 148, 165)
FACTION_COLOURS = {
    "nanotrasen": (60, 130, 230),
    "solgov": (90, 200, 200),
    "whiterapids": (150, 170, 230),
    "syndicate": (215, 55, 55),
    "pirate": (235, 160, 40),
    "hostile": (170, 80, 210),
    "unaligned": (120, 125, 135),
    "uncharted": (80, 84, 92),
}
TERRAIN_COLOURS = {
    "meteor": (70, 60, 50),
    "junk": (60, 58, 52),
    "nebula": (60, 45, 85),
    "estorm": (45, 65, 95),
    "storm": (45, 75, 95),
    "rad": (70, 85, 35),
    "flare": (95, 65, 30),
    "anom": (75, 45, 75),
    "grav": (35, 35, 45),
    "bh": (5, 5, 8),
    "carp": (40, 75, 80),
    "comet": (60, 80, 95),
    "mines": (95, 40, 40),
    "signal": (40, 85, 60),
}


def font(size):
    for name in ("arial.ttf", "DejaVuSans.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"):
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
            if s.get("name") == "Staging":
                continue  # liczy się do granic sektora, ale nie ma hexa na rysunku
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


def centre(col, row):
    return HEX_W * (col + (0.5 if row & 1 else 0)) + HEX_W / 2, ROW_H * row + R


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
    terrain = (hexmap.get("terrain") or {}).get("tiles") or {}
    if not isinstance(terrain, dict):
        terrain = {}
    hidden = {s["name"] for s in starmap if s.get("hidden")}
    holders = {s["name"]: state["occupied"].get(s["name"], s.get("alignment")) for s in starmap}
    hqs = {hq["system"]: hq for hq in state["hqs"]}

    offsets = {}
    x = PAD
    height = 0
    for sector, _ in SECTORS:
        if sector not in sectors:
            continue
        cols, rows = sectors[sector]
        offsets[sector] = x
        x += HEX_W * (cols + 0.5) + PAD
        height = max(height, ROW_H * (rows - 1) + 2 * R)
    width = int(x)
    image = Image.new("RGB", (width, int(TITLE_H + height + LEGEND_H + PAD)), BACKGROUND)
    draw = ImageDraw.Draw(image)
    small = font(11)
    label = font(15)
    title = font(20)

    draw.text((PAD, 10), "Mapa wojny", font=title, fill=TEXT)
    draw.text((width - PAD, 14), war_status.footer(state), font=font(12), fill=DIM_TEXT, anchor="ra")

    def pos(sector, col, row):
        cx, cy = centre(col, row)
        return offsets[sector] + cx, TITLE_H + 18 + cy

    for sector, name in SECTORS:
        if sector not in sectors:
            continue
        cols, rows = sectors[sector]
        draw.text((offsets[sector], TITLE_H - 4), name, font=label, fill=DIM_TEXT)
        for row in range(rows):
            for col in range(cols):
                colour = TERRAIN_COLOURS.get(terrain.get(f"{sector}:{col}:{row}"))
                draw.polygon(hexagon(*pos(sector, col, row), R - 0.5), fill=colour, outline=GRID)

    for name, (sector, col, row) in placed.items():
        if name in hidden:
            continue  # nieodkryte układy (także kwatery) zostają nieodkryte
        cx, cy = pos(sector, col, row)
        colour = FACTION_COLOURS.get(holders.get(name), FACTION_COLOURS["unaligned"])
        draw.polygon(hexagon(cx, cy, R - 2), fill=colour)
        if name in hqs:
            hq = hqs[name]
            ring = FACTION_COLOURS[hq["faction"]] if hq["held"] else (255, 255, 255)
            draw.polygon(hexagon(cx, cy, R + 2), outline=ring, width=3)
        draw.text((cx, cy + R), name, font=small, fill=TEXT, anchor="mt")

    ship = hexmap.get("ship_hex")
    if isinstance(ship, str) and ship.count(":") == 2:
        sector, col, row = (int(v) for v in ship.split(":"))
        if sector in offsets:
            cx, cy = pos(sector, col, row)
            draw.polygon([(cx, cy - 7), (cx + 6, cy + 5), (cx - 6, cy + 5)], fill=(255, 255, 255), outline=(0, 0, 0))

    legend_y = TITLE_H + height + 34
    lx = PAD
    for faction in war_status.MAIN_FACTIONS + ["hostile", "unaligned"]:
        draw.polygon(hexagon(lx + 7, legend_y + 7, 7), fill=FACTION_COLOURS[faction])
        text = war_status.faction_name(faction)
        draw.text((lx + 20, legend_y), text, font=font(13), fill=TEXT)
        lx += 34 + draw.textlength(text, font=font(13))
    legend_y += 24
    draw.polygon(hexagon(PAD + 7, legend_y + 7, 8), outline=(255, 255, 255), width=2)
    draw.text((PAD + 20, legend_y), "kwatera główna (biała ramka: zajęta przez wroga)", font=font(13), fill=TEXT)
    sx = PAD + 420
    draw.polygon([(sx + 7, legend_y), (sx + 13, legend_y + 12), (sx + 1, legend_y + 12)], fill=(255, 255, 255))
    draw.text((sx + 20, legend_y), "okręt załogi", font=font(13), fill=TEXT)

    out = io.BytesIO()
    image.save(out, "PNG")
    return out.getvalue()


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
