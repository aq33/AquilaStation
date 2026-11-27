"""Siatki modułów okrętów z map wnętrz abordażu (moduł = pomieszczenie wnętrza).

Dla każdego szablonu /datum/map_template/boarding/* czyta jego .dmm, dzieli pokład na pomieszczenia (podłoga odcięta
ścianami, oknami i drzwiami), rozpoznaje rodzaj pomieszczenia po zawartości i zapisuje prostokąty w układzie okrętu:
x od rufy (0) do dziobu (L), y od lewej burty (0, północ mapy) do prawej (W) - mapy wnętrz mają dziób na wschodzie.
Wynik: aquila/code/modules/overmap/modules/ship_module_layouts.dm (generowany).

Uruchom po zmianie albo dodaniu mapy wnętrza:  python tools/overmap_modules/module_layouts.py
"""
import glob
import os
import re
import sys
from collections import deque

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if len(sys.argv) > 1:
    REPO = sys.argv[1]
sys.path.insert(0, os.path.join(REPO, "tools", "mapmerge2"))
import dmm  # noqa: E402

OUT = os.path.join(REPO, "aquila", "code", "modules", "overmap", "modules", "ship_module_layouts.dm")

# Rozpoznawanie pomieszczeń: pierwszy pasujący wzór wygrywa (kolejność ma znaczenie)
SIGNATURES = [
    ("bridge", r"/obj/machinery/computer/ship/helm"),
    ("reactor", r"stormdrive_reactor"),
    ("engine", r"/obj/structure/shuttle/engine/heater|/obj/structure/shuttle/engine/router"),
    ("interdictor", r"/obj/structure/particle_accelerator|/obj/machinery/particle_accelerator"),
    ("mac", r"/obj/machinery/ship_weapon/(mac|railgun|hybrid_rail|deck_turret)|/obj/machinery/deck_turret"),
    ("gauss", r"/obj/machinery/ship_weapon/gauss_gun"),
    ("torpedo", r"/obj/machinery/ship_weapon/torpedo_launcher"),
    ("vls", r"/obj/machinery/ship_weapon/vls"),
    ("aa", r"/obj/machinery/ship_weapon/anti_air"),
    ("flak", r"/obj/machinery/ship_weapon/pdc_mount"),
    ("hangar", r"/obj/structure/fighter_launcher"),
    ("medbay", r"/obj/structure/table/optable|/obj/machinery/sleeper|/obj/machinery/computer/operating"),
    ("cargo", r"trader_drop_point"),
    ("armory", r"/obj/item/gun/|armory_contraband|peacekeeper_barricade"),
    ("sensors", r"/obj/machinery/telecomms|/obj/item/stock_parts/subspace|/obj/machinery/computer/ship/dradis(?!/minor)"),
    ("quarters", r"/obj/structure/bed(?!/roller)|mob_spawn/human/syndicate/boarding\b"),
    ("ammo", r"/obj/item/ship_weapon/ammunition|/obj/item/powder_bag|nac_ammo|/obj/item/ammo_box/magazine/nsv"),
    ("power", r"/obj/machinery/power/port_gen|/obj/machinery/space_heater|/obj/machinery/power/smes|tank_dispenser"),
    ("cargo", r"/obj/structure/closet/crate|trader_drop_point"),
    ("ftl", r"/obj/structure/fluff/bleepypanel|/obj/structure/frame/machine"),
]
SIG = [(k, re.compile(p)) for k, p in SIGNATURES]
WALL = re.compile(r"^/turf/closed|window|/obj/structure/grille|/obj/structure/shuttle/engine/(router|huge|propulsion)")
EXTERNAL = re.compile(r"/obj/machinery/door/airlock/ship/external")
ROUTER = re.compile(r"/obj/structure/shuttle/engine/router")
DOOR = re.compile(r"/obj/machinery/door/(airlock|poddoor)")
SPACE = re.compile(r"^/turf/open/space")


def template_maps():
    """Ścieżki map szablonów abordażu z kodu (mappath jako string albo plik)."""
    found = {}
    for path in glob.glob(os.path.join(REPO, "nsv13", "code", "**", "*.dm"), recursive=True) + glob.glob(os.path.join(REPO, "aquila", "code", "**", "*.dm"), recursive=True):
        cur = None
        for line in open(path, encoding="utf-8", errors="ignore"):
            m = re.match(r"^(/datum/map_template/boarding/[\w/]+)\s*$", line.rstrip())
            if m:
                cur = m.group(1)
                continue
            if line.strip() and not line[0].isspace():
                cur = None
            if cur:
                m = re.match(r"\s+mappath\s*=\s*['\"]([^'\"]+)['\"]", line)
                if m:
                    found[cur] = m.group(1)
    return found


def analyse(path):
    m = dmm.DMM.from_file(path)
    tiles = {}
    for (x, y, z), k in m.grid.items():
        if z != 1:
            continue
        atoms = m.dictionary[k]
        area = atoms[-1]
        turf = atoms[-2]
        if area.startswith("/area/space") and SPACE.match(turf):
            continue
        tiles[(x, y)] = atoms
    if not tiles:
        return None

    def is_wall(atoms):
        return any(WALL.search(a.split("{")[0]) for a in atoms[:-1]) or SPACE.match(atoms[-2])

    def is_door(atoms):
        return any(DOOR.search(a) for a in atoms)

    def is_outside(atoms):
        # poszycie na zewnątrz kadłuba (pola bez powietrza i płyty kadłuba) nie jest pomieszczeniem
        return any(a.startswith("/obj/structure/hull_plate") or a.startswith("/obj/structure/lattice") for a in atoms)

    floor = {c for c, a in tiles.items() if not is_wall(a) and not is_door(a) and not is_outside(a)}
    # obrys kadłuba: wszystkie pola okrętu (ściany, podłoga, poszycie)
    hull = [c for c, a in tiles.items() if not SPACE.match(a[-2]) or any("hull_plate" in s for s in a)]
    xs = [c[0] for c in hull]
    ys = [c[1] for c in hull]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    seen = set()
    rooms = []
    for start in sorted(floor):
        if start in seen:
            continue
        comp = []
        dq = deque([start])
        seen.add(start)
        while dq:
            c = dq.popleft()
            comp.append(c)
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (c[0] + dx, c[1] + dy)
                if n in floor and n not in seen:
                    seen.add(n)
                    dq.append(n)
        if len(comp) < 4:
            continue
        text = "\n".join(a for c in comp for a in tiles[c][:-2])
        compset = set(comp)
        around = set()
        for c in comp:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (c[0] + dx, c[1] + dy)
                if n not in compset and n in tiles:
                    around.add(n)
        around_text = "\n".join(a for c in around for a in tiles[c][:-2])
        kind = "corridor"
        for k, rx in SIG:
            if rx.search(text):
                kind = k
                break
        # silnik: routery w ścianie rufowej przy pomieszczeniu
        if kind not in ("bridge", "reactor") and ROUTER.search(around_text):
            kind = "engine"
        # maskowanie (tylko wygenerowane wnętrza): ramy maszyn i dradis pomocniczy w jednym pomieszczeniu
        if kind in ("ftl", "corridor", "power") and "/obj/machinery/computer/ship/dradis/minor" in text and "/obj/structure/frame/machine" in text:
            kind = "cloak"
        # śluza: małe pomieszczenie przy zewnętrznych drzwiach, nie moduł
        if EXTERNAL.search(around_text) and len(comp) <= 16 and kind in ("corridor", "armory", "ftl", "power", "cargo"):
            kind = "airlock"
        cx0, cx1 = min(c[0] for c in comp), max(c[0] for c in comp)
        cy0, cy1 = min(c[1] for c in comp), max(c[1] for c in comp)
        # korytarz bez wyposażenia albo długi i wąski zostaje korytarzem
        if kind in ("cargo", "ftl", "power") and "trader_drop_point" not in text and ((cx1 - cx0 + 1) >= 4 * (cy1 - cy0 + 1) or (cy1 - cy0 + 1) >= 4 * (cx1 - cx0 + 1)) and len(comp) > 40:
            kind = "corridor"
        rooms.append((kind, cx0, cy0, cx1, cy1, len(comp)))
    # do układu okrętu: x od rufy, y od lewej burty (północ mapy = góra = y największe w BYOND)
    out = []
    for kind, cx0, cy0, cx1, cy1, n in rooms:
        if kind in ("corridor", "airlock"):
            continue
        lx0, lx1 = cx0 - x0, cx1 - x0
        ly0, ly1 = y1 - cy1, y1 - cy0
        out.append((kind, lx0, ly0, lx1, ly1, n))
    return (x1 - x0 + 1, y1 - y0 + 1, out, x0, y1)


def main():
    maps = template_maps()
    blocks = []
    for ttype, mappath in sorted(maps.items()):
        full = os.path.join(REPO, mappath.replace("/", os.sep))
        if not os.path.exists(full):
            print("brak mapy", ttype, mappath)
            continue
        res = analyse(full)
        if not res:
            continue
        L, W, mods, hull_x0, hull_y1 = res
        kinds = {}
        for m in mods:
            kinds[m[0]] = kinds.get(m[0], 0) + 1
        print(ttype.split("/")[-1], f"{L}x{W}", dict(sorted(kinds.items())))
        rows = ",\n".join(f'\t\tlist("{k}", {a}, {b}, {c}, {d}, {n})' for k, a, b, c, d, n in mods)
        blocks.append(f'\t{ttype} = list({L}, {W}, list(\n{rows}\n\t\t), {hull_x0}, {hull_y1})')
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("// GENEROWANE przez tools/overmap_modules/module_layouts.py - nie edytować ręcznie.\n")
        fh.write("// szablon wnętrza = list(długość L, szerokość W, list(list(rodzaj, x0, y0, x1, y1, liczba pól), ...), x rufy na mapie, y lewej burty na mapie)\n")
        fh.write("// x od rufy do dziobu, y od lewej burty do prawej (mapy wnętrz mają dziób na wschodzie)\n")
        fh.write("GLOBAL_LIST_INIT(ship_module_layouts, list(\n")
        fh.write(",\n".join(blocks))
        fh.write("\n))\n")
    print("zapisano", len(blocks), "układów")


if __name__ == "__main__":
    main()
