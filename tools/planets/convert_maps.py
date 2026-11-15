"""Konwersja map Shiptesta (ruiny, greeble) na nasz kod: zamienia ścieżki typów, dekale, światła i szafki ścienne,
tłumaczy nazwy edytowane na mapie i zgłasza wszystkie ścieżki, których nie ma u nas ani w tablicach zamienników.

Użycie (z katalogu repo):
  python tools/planets/convert_maps.py --out aquila/_maps/RandomRuins/PlanetIce --mappings ice <shiptest>/_maps/RandomRuins/IceRuins/icemoon_x.dmm=planet_ice_x ...

--mappings: moduły z tools/planets/mappings/ (common jest zawsze), które dopisują zamienniki dla danej planety.
Bez błędów zapisuje mapy w formacie TGM i raport do --report (en_map_strings.json: polski -> angielski z nazw na
mapach, report.json, decisions.json). Kable zostają w starym formacie: potem tools/smartwires/convert.py.
Brakujące typy liczy z plików dołączonych do nsv13.dme (każda ścieżka zdefiniowana w kodzie i jej przodkowie).
"""
import argparse
import collections
import importlib
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'mapmerge2'))
import dmm as dmmlib  # noqa: E402
from mappings.common import *  # noqa: E402,F401,F403
from mappings import common  # noqa: E402

EN = {}  # polski -> angielski


def tr(s):
    """s to literał z cudzysłowami"""
    inner = s[1:-1]
    if inner in common.TR:
        EN[common.TR[inner]] = inner
        return '"' + common.TR[inner] + '"'
    raise KeyError('Brak tłumaczenia: ' + inner)


def defined_types(root):
    """Ścieżki typów zdefiniowane w plikach dołączonych do nsv13.dme (z przodkami)."""
    backslash = chr(92)
    files = []
    todo = [os.path.join(root, 'nsv13.dme')]
    seen = set()
    while todo:
        current = todo.pop(0)
        if not os.path.exists(current):
            continue
        base = os.path.dirname(current)
        for line in open(current, encoding='utf-8', errors='replace'):
            match = re.match(r'\s*#include\s+"(.+?)"', line)
            if not match:
                continue
            path = os.path.normpath(os.path.join(base, match.group(1).replace(backslash, '/')))
            if (path.endswith(".dm") or path.endswith(".dme")) and path not in seen and os.path.exists(path):
                seen.add(path)
                files.append(path)
                todo.append(path)
    types = set()
    for current in files:
        for line in open(current, encoding='utf-8', errors='replace'):
            match = re.match(r'^(/[A-Za-z0-9_/]+)', line)
            if match:
                path = re.split(r'/(proc|verb)(/|$)', match.group(1))[0].rstrip('/')
                if path:
                    types.add(path)
    for path in list(types):
        parts = path.split('/')
        for i in range(2, len(parts)):
            types.add('/'.join(parts[:i]))
    return types


# ---------------------------------------------------------------- pomocnicze
DIRS = {'north': 1, 'south': 2, 'east': 4, 'west': 8}
WALL_PIX = {'north': ('pixel_y', '28'), 'south': ('pixel_y', '-28'), 'east': ('pixel_x', '28'), 'west': ('pixel_x', '-28')}
OPP = {'north': 2, 'south': 1, 'east': 8, 'west': 4}
DROP_VARS = {'populate', 'req_ship_access', 'turret_flags', 'spawn_no_ammo', 'gps_active', 'subship_template',
             'weapon_drop_chance', 'burst_interval', 'aggro_say_chance', 'holds_post', 'on_aggro_say', 'verb_exclaim',
             'verb_yell', 'icon_state', 'empty', 'table_type', 'name_override', 'close_exception', 'set_dir_on_move',
             'auto_scatter', 'auto_rotate', 'default_ammo_type', 'spawn_arm_delay', 'search_alarms', 'drops_core'}  # icon_state zostawiamy tylko tam, gdzie typ docelowy jest ten sam


def atom(path, vars_):
    if not vars_:
        return path
    return path + '{' + '; '.join(f'{k} = {v}' for k, v in vars_.items()) + '}'

# ---------------------------------------------------------------- kafelki podłogowe: kolory Shiptesta
ST_COLORS = {
    'neutral': None, 'black': '#444547', 'blue': '#75A2BB', 'green': '#99BB76', 'lime': '#B7D993', 'yellow': '#BA9F6D',
    'beige': '#CEB689', 'red': '#B4696A', 'bar': '#791500', 'grey': '#a3a2a0', 'syndiered': '#730622',
    'warrablue': '#32426b', 'white': '#FFFFFF',
}
# nasz najbliższy kolor (podtyp), kolor Shiptesta nadpisujemy edycją
OUR_COLOR = {'neutral': 'neutral', 'black': 'black', 'blue': 'blue', 'green': 'green', 'lime': 'green', 'yellow': 'yellow',
             'beige': 'brown', 'red': 'red', 'bar': 'bar', 'grey': 'neutral', 'syndiered': 'red', 'warrablue': 'darkblue',
             'white': 'white'}
OUR_TRIM_COLORS = {'black', 'blue', 'brown', 'darkblue', 'green', 'neutral', 'purple', 'red', 'white', 'yellow'}

# kształty narożników Shiptesta (corner/<kolor>/<kształt>) -> nasz /tile/<kolor>/<kształt> + przeliczenie kierunku
# kierunki sprawdzone na arkuszu stanów ikon (Shiptest decals.dmi vs nasz decals.dmi)
CORNER_SHAPES = {
    '': ('', {1: 1, 2: 2, 4: 4, 8: 8}),                      # corner_white == tile_corner
    'diagonal': ('opposingcorners', {2: 2, 1: 2, 4: 8, 8: 8}),
    'three_quarters': ('anticorner/contrasted', {2: 2, 1: 8, 4: 1, 8: 4}),
    'full': ('fourcorners/contrasted', None),
    'mono': ('fourcorners', None),
    'half': ('half', {2: 8, 1: 4, 4: 2, 8: 1}),                # bordercolorhalf: pół kafla przy krawędzi dir
    'border': ('half', {2: 8, 1: 4, 4: 2, 8: 1}),              # cienki pas przy krawędzi -> pół kafla (najbliższe)
    'bordercorner': ('', {2: 2, 1: 1, 4: 4, 8: 8}),            # mały kwadrat w rogu -> róg kafla
}

def decal(path, vars_, mapname):
    """Zwraca listę atomów albo None (pominięcie)."""
    d = int(vars_.get('dir', '2'))
    m = re.match(r'/obj/effect/turf_decal/corner/(opaque|transparent)/(\w+)(?:/(\w+))?$', path)
    if m:
        op, col, shape = m.group(1), m.group(2), m.group(3) or ''
        target, dirmap = CORNER_SHAPES[shape]
        our = '/obj/effect/turf_decal/tile/' + OUR_COLOR[col] + ('/' + target if target else '')
        nv = {}
        if dirmap:
            nd = dirmap.get(d, d)
            if nd != 2:
                nv['dir'] = str(nd)
        if ST_COLORS[col]:
            nv['color'] = '"' + ST_COLORS[col] + '"'
        nv['alpha'] = '255' if op == 'opaque' else ('130' if col == 'bar' else '140')
        return [atom(our, nv)]
    m = re.match(r'/obj/effect/turf_decal/trimline/(opaque|transparent)/(\w+)/(.+)$', path)
    if m:
        op, col, shape = m.groups()
        oc = OUR_COLOR[col]
        if oc not in OUR_TRIM_COLORS:
            oc = 'neutral'
        our = '/obj/effect/turf_decal/trimline/' + oc + '/' + shape
        nv = {}
        if d != 2:
            nv['dir'] = str(d)
        if ST_COLORS[col]:
            nv['color'] = '"' + ST_COLORS[col] + '"'
        nv['alpha'] = '255' if op == 'opaque' else '140'
        return [atom(our, nv)]
    m = re.match(r'/obj/effect/turf_decal/spline/(fancy|plain)/opaque/(\w+)(/corner)?$', path)
    if m:
        kind, col, corner = m.groups()
        our = '/obj/effect/turf_decal/siding/white' + ('/corner' if corner else '')
        nv = {}
        if d != 2:
            nv['dir'] = str(d)
        nv['color'] = '"' + (ST_COLORS[col] or '#FFFFFF') + '"'
        return [atom(our, nv)]
    m = re.match(r'/obj/effect/turf_decal/siding/black(/corner|/end)?$', path)
    if m:
        our = '/obj/effect/turf_decal/siding/white' + (m.group(1) or '')
        nv = {}
        if d != 2:
            nv['dir'] = str(d)
        nv['color'] = '"#474747"'
        return [atom(our, nv)]
    simple = {
        '/obj/effect/turf_decal/industrial/warning': '/obj/effect/turf_decal/stripes/line',
        '/obj/effect/turf_decal/industrial/warning/corner': '/obj/effect/turf_decal/stripes/corner',
        '/obj/effect/turf_decal/industrial/warning/dust': '/obj/effect/turf_decal/stripes/asteroid/line',
        '/obj/effect/turf_decal/industrial/fire': '/obj/effect/turf_decal/stripes/red/line',
        '/obj/effect/turf_decal/industrial/fire/corner': '/obj/effect/turf_decal/stripes/red/corner',
        '/obj/effect/turf_decal/industrial/fire/cee': '/obj/effect/turf_decal/stripes/red/end',
        '/obj/effect/turf_decal/industrial/hatch': '/obj/effect/turf_decal/delivery',
        '/obj/effect/turf_decal/industrial/loading': '/obj/effect/turf_decal/loading_area',
        '/obj/effect/turf_decal/industrial/outline/yellow': '/obj/effect/turf_decal/box',
        '/obj/effect/turf_decal/industrial/stand_clear': '/obj/effect/turf_decal/caution/stand_clear',
        '/obj/effect/turf_decal/borderfloor': '/obj/effect/turf_decal/ship/borderfloor',
        '/obj/effect/turf_decal/borderfloor/corner': '/obj/effect/turf_decal/ship/borderfloor/corner',
        '/obj/effect/turf_decal/borderfloorblack': '/obj/effect/turf_decal/ship/borderfloor',
        '/obj/effect/turf_decal/borderfloorwhite': '/obj/effect/turf_decal/ship/borderfloor/gunmetal',
        '/obj/effect/turf_decal/techfloor': '/obj/effect/turf_decal/ship/techfloor',
        '/obj/effect/turf_decal/techfloor/corner': '/obj/effect/turf_decal/ship/techfloor/corner',
        '/obj/effect/turf_decal/techfloor/hole': '/obj/effect/turf_decal/ship/techfloor',
        '/obj/effect/turf_decal/techfloor/hole/right': '/obj/effect/turf_decal/ship/techfloor',
    }
    if path in simple:
        nv = {}
        if d != 2:
            nv['dir'] = str(d)
        return [atom(simple[path], nv)]
    colored = {
        '/obj/effect/turf_decal/industrial/warning/green': ('/obj/effect/turf_decal/stripes/white/line', '"#4ca64c"'),
        '/obj/effect/turf_decal/industrial/warning/green/corner': ('/obj/effect/turf_decal/stripes/white/corner', '"#4ca64c"'),
        '/obj/effect/turf_decal/industrial/traffic': ('/obj/effect/turf_decal/stripes/white/line', '"#fb9700"'),
    }
    if path in colored:
        nv = {}
        if d != 2:
            nv['dir'] = str(d)
        nv['color'] = colored[path][1]
        return [atom(colored[path][0], nv)]
    # czysta dekoracja bez odpowiednika: schodki, stalowe wzorki, numery, logo, droga, atmos
    if re.match(r'/obj/effect/turf_decal/(stairs|steeldecal/|number/|road/|minutemen/|warra/|atmos/)', path):
        return None
    raise KeyError(path)


MISSING = set()

def clean_vars(vars_, keep_icon_state):
    out = collections.OrderedDict()
    for k, v in vars_.items():
        if k in DROP_VARS and not (k == 'icon_state' and keep_icon_state):
            continue
        # parser map rozcina listy asocjacyjne (list(a = 1, b = 2)) na kawałki: takie zmienne (skład jedzenia, pancerz
        # kanistra) pomijamy w całości, zostaje wartość domyślna typu
        if not re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', k) or (v.count('(') != v.count(')')):
            continue
        if v == '/datum/species/spider':  # rachnidzi z Shiptesta, u nas brak tej rasy
            v = '/datum/species/human'
        if v == '/obj/item/gem/amber':  # klejnot w gablocie -> złoto
            v = '/obj/item/stack/sheet/mineral/gold'
        if k in ('pixel_x', 'pixel_y') and v == '0':
            continue
        if k in ('name', 'desc', 'default_raw_text') and v.startswith('"'):
            v = tr(v)
        out[k] = v
    return out

def convert_atom(a, mapname, stat):
    path, vars_ = dmmlib.parse_map_atom(a)
    vars_ = collections.OrderedDict(vars_)
    # kable zostają w starym formacie, przerabia je tools/smartwires/convert.py (kolory blue/cyan/white zna)
    if path.startswith('/obj/structure/cable'):
        stat['replaced'] += 1
        return [a]
    # obszary
    if path.startswith('/area'):
        if path in AREAS:
            return [AREAS[path]]
        if path in MISSING:
            raise KeyError(path)
        return [path]
    # łuski z ikoną "empty" to w Shiptescie zużyte łuski, u nas byłyby to żywe naboje
    if path in ('/obj/item/ammo_casing/c10mm', '/obj/item/ammo_casing/c9mm') and 'empty' in vars_.get('icon_state', ''):
        nv = clean_vars(vars_, False)
        return [atom('/obj/item/ammo_casing/spent', nv)]
    # edycje icon_state ze stanami, których nasze ikony nie mają (konsole wielopolowe, karty, pajęczyny, krew)
    if path in ICON_STATE_DROP:
        return [atom(path, clean_vars(vars_, False))]
    # turfy
    if path.startswith('/turf'):
        if path in TURFS:
            t = TURFS[path]
            nv = clean_vars(vars_, False)
            if isinstance(t, tuple):
                t, extra = t
                nv.update(extra)
            stat['ported' if t in PORTED else 'replaced'] += 1
            return [atom(t, nv)]
        if path in MISSING:
            raise KeyError(path)
        return [atom(path, clean_vars(vars_, True))]
    # dekale
    if path.startswith('/obj/effect/turf_decal') and path in MISSING and path not in R:
        res = decal(path, vars_, mapname)
        stat['dropped' if res is None else 'replaced'] += 1
        return res or []
    # światła ze ścian
    m = re.match(r'(/obj/machinery/light(?:/small)?)(/broken|/built|/dim)?/directional/(\w+)$', path)
    if m:
        base = m.group(1) + ({'/broken': '/broken', '/built': '/built'}.get(m.group(2) or '', ''))
        nv = clean_vars(vars_, False)
        d = DIRS[m.group(3)]
        if d != 2:
            nv['dir'] = str(d)
        else:
            nv.pop('dir', None)
        stat['replaced'] += 1
        return [atom(base, nv)]
    m = re.match(r'/obj/machinery/power/apc/auto_name/directional/(\w+)$', path)
    if m:
        stat['replaced'] += 1
        nv = clean_vars(vars_, False)
        nv.pop('dir', None)
        return [atom('/obj/machinery/power/apc/auto_name/' + m.group(1), nv)]
    m = re.match(r'/obj/structure/extinguisher_cabinet/directional/(\w+)$', path)
    if m:
        stat['replaced'] += 1
        return [atom('/obj/structure/extinguisher_cabinet/' + m.group(1), clean_vars(vars_, False))]
    m = re.match(r'(/obj/structure/noticeboard|/obj/machinery/computer/security/telescreen/entertainment/wall(?:/beige)?|/obj/item/radio/intercom/wideband)/directional/(\w+)$', path)
    if m:
        stat['replaced'] += 1
        side = m.group(2)
        base = {'/obj/structure/noticeboard': '/obj/structure/noticeboard',
                '/obj/item/radio/intercom/wideband': '/obj/item/radio/intercom/directional/' + side}.get(m.group(1), '/obj/machinery/computer/security/telescreen/entertainment')
        nv = clean_vars(vars_, False)
        if base.startswith('/obj/item/radio/intercom/directional'):
            return [atom(base, nv)]
        k, v = WALL_PIX[side]
        nv[k] = v
        if base == '/obj/structure/noticeboard' and OPP[side] != 2:
            nv['dir'] = str(OPP[side])
        return [atom(base, nv)]
    m = re.match(r'/obj/structure/chair/(?:bench/(\w+)|comfy/grey)/directional/(\w+)$', path)
    if m:
        stat['replaced'] += 1
        nv = clean_vars(vars_, False)
        d = DIRS[m.group(2)]
        if d != 2:
            nv['dir'] = str(d)
        base = '/obj/structure/chair/fancy/bench' if 'bench' in path else '/obj/structure/chair/fancy/comfy'
        return [atom(base, nv)]
    m = re.match(r'(/obj/structure/closet/.*?)(?:/directional/(\w+))?$', path)
    if m and path in MISSING:
        base = m.group(1)
        if base in WALL_CLOSETS:
            stat['replaced'] += 1
            nv = clean_vars(vars_, False)
            nv.pop('dir', None)
            return [atom(WALL_CLOSETS[base], nv)]
    # szafki bez wypełnienia
    if path in NO_POPULATE and vars_.get('populate') == '0':
        base, icon = NO_POPULATE[path]
        nv = clean_vars(vars_, False)
        if icon:
            nv['icon_state'] = icon
        stat['replaced'] += 1
        return [atom(base, nv)]
    if path in R:
        t = R[path]
        if t is None:
            stat['dropped'] += 1
            return []
        nv = clean_vars(vars_, False)
        if isinstance(t, tuple):
            t, extra = t
            nv.update(extra)
        tt = t if isinstance(t, str) else t
        # moby i wieżyczki Shiptesta mają własne zmienne (wander, l_hand, id, lethal), u nas ich nie ma
        if tt.startswith('/mob/'):
            nv = collections.OrderedDict((k, v) for k, v in nv.items() if k in ('name', 'desc', 'dir', 'pixel_x', 'pixel_y', 'faction'))
        if tt.startswith('/obj/machinery/porta_turret'):
            nv.pop('id', None); nv.pop('lethal', None)
        stat['ported' if t in PORTED else 'replaced'] += 1
        return [atom(t, nv)]
    if path in MISSING:
        raise KeyError(path)
    return [atom(path, clean_vars(vars_, True))]

def convert_tile(atoms, mapname, stat):
    out = []
    for a in atoms:
        out.extend(convert_atom(a, mapname, stat))
    # magazyny skafandrów, które w Shiptescie zabierały rzeczy z pola (inherit): rzeczy -> zmienne SSU
    ssu = [i for i, a in enumerate(atoms) if dmmlib.parse_map_atom(a)[0].startswith('/obj/machinery/suit_storage_unit/inherit')]
    if ssu:
        nv = collections.OrderedDict()
        keep = []
        for a in out:
            p = dmmlib.parse_map_atom(a)[0]
            if p.startswith(SUIT_PREFIX) and 'suit_type' not in nv and '{' not in a:
                nv['suit_type'] = p
            elif p.startswith(HELM_PREFIX) and 'helmet_type' not in nv and '{' not in a:
                nv['helmet_type'] = p
            elif p.startswith(MASK_PREFIX) and 'mask_type' not in nv and '{' not in a:
                nv['mask_type'] = p
            elif p.startswith('/obj/item') and 'storage_type' not in nv and '{' not in a:
                nv['storage_type'] = p
            else:
                keep.append(a)
        out = keep
        mv = [a for a in out if not a.startswith(('/turf', '/area'))]
        rest = [a for a in out if a.startswith(('/turf', '/area'))]
        out = mv + [atom('/obj/machinery/suit_storage_unit', nv)] + rest
        stat['replaced'] += 1
    # bez duplikatów tych samych struktur na polu (lint CI)
    seen = set(); res = []
    for a in out:
        p = dmmlib.parse_map_atom(a)[0]
        if p.startswith(('/obj/structure/table', '/obj/structure/chair', '/obj/structure/closet', '/obj/structure/lattice',
                         '/obj/structure/grille', '/obj/structure/barricade', '/obj/machinery/door/airlock', '/obj/structure/girder')):
            key = p.split('{')[0] if p.startswith('/obj/structure/lattice') else a
            if key in seen:
                continue
            seen.add(key)
        res.append(a)
    return res


# Typy generowane makrami (rury w kolorach i warstwach), których nie widać jako ścieżki w kodzie. Czy naprawdę
# istnieją, sprawdza potem kompilacja map i render dmm-tools.
MACRO_PREFIXES = ('/obj/machinery/atmospherics/pipe/',)


def collect_missing(maps, ours):
    missing = set()
    for m in maps:
        for tile in m.dictionary.values():
            for a in tile:
                p = a.split('{')[0]
                if p not in ours and not p.startswith(MACRO_PREFIXES):
                    missing.add(p)
    return missing


def main():
    global MISSING
    parser = argparse.ArgumentParser(description='Konwersja map Shiptesta na nasz kod')
    parser.add_argument('--out', required=True, help='folder na przekonwertowane mapy')
    parser.add_argument('--mappings', default='', help='moduły zamienników po przecinku (bez common)')
    parser.add_argument('--report', default=os.path.join(HERE, '.out'), help='folder na raporty')
    parser.add_argument('--root', default='.', help='katalog repo (nsv13.dme)')
    parser.add_argument('maps', nargs='+', help='źródło.dmm=nowa_nazwa')
    args = parser.parse_args()
    modules = []
    for name in filter(None, args.mappings.split(',')):
        modules.append(importlib.import_module('mappings.' + name.strip()))
    ours = defined_types(args.root)
    pairs = []
    for item in args.maps:
        src, _, dst = item.partition('=')
        pairs.append((src, dst or os.path.splitext(os.path.basename(src))[0]))
    loaded = [(dmmlib.DMM.from_file(src), src, dst) for src, dst in pairs]
    MISSING = collect_missing([m for m, _, _ in loaded], ours)
    # Moduły zamienników mogą same dobrać zamienniki dla brakujących ścieżek (resolve(missing, ours), np. mappings/auto.py)
    for module in modules:
        if hasattr(module, 'resolve'):
            module.resolve(MISSING, ours)
    errors = collections.defaultdict(set)
    results = []
    report = {}
    blockers = ('/obj/structure/window', '/obj/effect/spawner/structure/window', '/obj/machinery/door', '/obj/structure/grille',
        '/obj/structure/table', '/obj/machinery/vending', '/obj/structure/closet', '/obj/structure/rack')
    for m, src, dst in loaded:
        stat = collections.Counter()
        new = dmmlib.DMM(m.key_length, m.size)
        cache = {}

        def dense(x, y):
            try:
                t = m.get_tile((x, y, 1))
            except KeyError:
                return True
            return any(a.startswith('/turf/closed') or a.startswith(blockers) for a in t)
        # szafki ścienne, które jako zwykła szafka zablokowałyby przejście albo stanęły na krześle/stole
        drop_closet = set()
        for (x, y, z), key in m.grid.items():
            t = m.dictionary[key]
            if any(re.match(r'/obj/structure/closet/.*wall', a) for a in t):
                blocking = (dense(x, y + 1) and dense(x, y - 1)) or (dense(x + 1, y) and dense(x - 1, y))
                crowded = any(a.startswith(('/obj/structure/chair', '/obj/structure/table', '/obj/structure/bed')) for a in t)
                if blocking or crowded:
                    drop_closet.add((x, y, z))
        failed = False
        for coord, key in m.grid.items():
            if key not in cache:
                try:
                    cache[key] = tuple(convert_tile(list(m.dictionary[key]), dst, stat))
                except KeyError as error:
                    errors[str(error.args[0])].add(dst)
                    cache[key] = ()
                    failed = True
            tile = cache[key]
            if coord in drop_closet:
                tile = tuple(a for a in tile if a.split('{')[0] not in WALL_CLOSETS.values())
            new.set_tile(coord, tile)
        if not failed:
            results.append((new, dst))
        report[dst] = {'source': src, 'size': list(m.size[:2]), 'stats': dict(stat)}
    if errors:
        print('Brak zamienników albo tłumaczeń (%d):' % len(errors))
        for path in sorted(errors):
            print('  %s   [%s]' % (path, ', '.join(sorted(errors[path]))))
        sys.exit(1)
    os.makedirs(args.out, exist_ok=True)
    for new, dst in results:
        out = os.path.join(args.out, dst + '.dmm')
        try:
            new.to_file(out)
        except Exception:
            new.key_length = 3
            new.to_file(out)
        print('zapisano', out)
    os.makedirs(args.report, exist_ok=True)
    json.dump(EN, open(os.path.join(args.report, 'en_map_strings.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    json.dump(report, open(os.path.join(args.report, 'report.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    json.dump(dict(common.DECISIONS), open(os.path.join(args.report, 'decisions.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)


if __name__ == '__main__':
    main()
