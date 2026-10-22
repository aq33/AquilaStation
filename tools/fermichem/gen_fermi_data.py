"""Generates aquila/code/modules/reagents/chemistry/fermi/fermi_data.dm

Reactions: fermichem parameters copied from the matching tg reaction (tgstation@b3949ec362).
Reagents: pH, inverse_chem and inverse_chem_val copied from the matching tg reagent.

Usage (tg checkout needs code/ - a sparse clone of code/modules/reagents and code/modules/food_and_drinks is enough):
    python tools/fermichem/gen_fermi_data.py <tg checkout> . aquila/code/modules/reagents/chemistry/fermi/fermi_data.dm

Matching order: same typepath and results, then same reagents and results, then same results only
(for the last one our own temperature requirement is kept). Our recipes with their own on_reaction()
effects become REACTION_INSTANT, because the effect expects the products to exist right away.
"""
import os, sys, json, collections, re
sys.path.insert(0, os.path.dirname(__file__))
from dmparse import parse_files, walk, parse_reagent_list, resolve, resolve_with_owner

TG, OURS, OUT = sys.argv[1], sys.argv[2], sys.argv[3]

tg_types, tg_procs = parse_files(list(walk(os.path.join(TG, 'code'))))
our_files = []
for sub in ('code', 'nsv13', 'aquila'):
    our_files += [f for f in walk(os.path.join(OURS, sub)) if not f.replace('\\', '/').endswith('fermi/fermi_data.dm')]
our_types, our_procs = parse_files(our_files)

FERMI = ['required_temp', 'is_cold_recipe', 'optimal_temp', 'overheat_temp', 'optimal_ph_min', 'optimal_ph_max',
         'determin_ph_range', 'temp_exponent_factor', 'ph_exponent_factor', 'thermic_constant', 'H_ion_release',
         'rate_up_lim', 'purity_min', 'reaction_flags', 'reaction_tags']
TEMP_VARS = {'required_temp', 'is_cold_recipe', 'optimal_temp', 'overheat_temp', 'temp_exponent_factor'}
ROOT_R = '/datum/chemical_reaction'
ROOT_G = '/datum/reagent'

# reactions that live in our new fermi files are already tg-exact
SKIP_FILES = ('aquila/code/modules/reagents/chemistry/fermi/',)


def reactions(types):
    out = {}
    for p in types:
        if not p.startswith(ROOT_R + '/'):
            continue
        req = parse_reagent_list(resolve(types, p, 'required_reagents'))
        res = parse_reagent_list(resolve(types, p, 'results'))
        if not req:
            continue
        out[p] = (req, res)
    return out


def overrides(procs, path, proc):
    q = path
    while q and q.count('/') > 2:
        if proc in procs.get(q, set()):
            return True
        q = q.rsplit('/', 1)[0]
    return False


def num(v, default=None):
    if v is None:
        return default
    v = v.strip()
    if v in ('TRUE',):
        return 1
    if v in ('FALSE', 'null', '0'):
        return 0
    try:
        return float(v)
    except ValueError:
        return default


tg_r = reactions(tg_types)
our_r = reactions(our_types)
by_full = collections.defaultdict(list)
by_res = collections.defaultdict(list)
for p, (req, res) in tg_r.items():
    by_full[(frozenset(req), frozenset(res))].append(p)
    if res:
        by_res[frozenset(res)].append(p)

lines = []
lines.append('// WYGENEROWANE skryptem gen_fermi_data.py - nie edytuj ręcznie, opis w fermi_readme.md')
lines.append('// Parametry fermichemu przepisów i pH reagentów skopiowane z tgstation@b3949ec362.')
lines.append('')
lines.append('////////////////////////////// Przepisy //////////////////////////////')
stats = collections.Counter()
report = []
for p in sorted(our_r):
    f = our_types[p]['file'].replace('\\', '/')
    rel = os.path.relpath(f, OURS).replace('\\', '/')
    if rel.startswith(SKIP_FILES):
        continue
    req, res = our_r[p]
    match = kind = None
    if p in tg_r and set(tg_r[p][1]) == set(res):
        match, kind = p, 'path'
    elif by_full.get((frozenset(req), frozenset(res))):
        match, kind = by_full[(frozenset(req), frozenset(res))][0], 'full'
    elif res and by_res.get(frozenset(res)):
        match, kind = by_res[frozenset(res)][0], 'results'
    effect = overrides(our_procs, p, 'on_reaction')
    our_cold = num(resolve(our_types, p, 'is_cold_recipe'), 0)
    our_req_temp_raw = resolve(our_types, p, 'required_temp')
    our_req_temp = num(our_req_temp_raw, None)

    vals = collections.OrderedDict()
    if match:
        tg_cold = num(resolve(tg_types, match, 'is_cold_recipe'), 0)
        for v in FERMI:
            val, owner = resolve_with_owner(tg_types, match, v)
            if val is None or owner == ROOT_R:
                continue
            if v in TEMP_VARS and (kind == 'results' or bool(tg_cold) != bool(our_cold)):
                continue  # different recipe: keep our temperature requirement
            vals[v] = val
        stats['tg_' + kind] += 1
    else:
        stats['unmatched'] += 1
        if rel.endswith('drinks_recipes.dm'):
            # our drinks have no common base type - give them tg's /datum/chemical_reaction/drink values
            for v in FERMI:
                val, owner = resolve_with_owner(tg_types, '/datum/chemical_reaction/drink', v)
                if val is not None and owner == '/datum/chemical_reaction/drink':
                    vals[v] = val
            stats['unmatched_drink'] += 1

    # temperature sanity for recipes without tg temperatures
    req_temp = num(vals.get('required_temp'), our_req_temp if our_req_temp is not None else 100)
    if 'optimal_temp' not in vals:
        if our_cold:
            vals['optimal_temp'] = str(int(max(req_temp - 100, 0)))
            vals['overheat_temp'] = 'NO_OVERHEAT'
        elif req_temp >= 500:
            vals['optimal_temp'] = str(int(req_temp + 50))
            vals['overheat_temp'] = 'NO_OVERHEAT' if req_temp + 50 >= 900 else str(int(max(900, req_temp + 250)))
    if our_req_temp_raw is None and 'required_temp' not in vals:
        # our old default was 0 (no requirement); tg default 100 is fine for these
        pass

    flags = vals.get('reaction_flags')
    if flags:
        # tg has a stray reagent flag (REAGENT_SPLITRETAINVOL) in one recipe - keep only reaction flags
        parts = [f.strip() for f in flags.split('|') if f.strip().startswith('REACTION_') or f.strip() in ('NONE', '0')]
        flags = ' | '.join(parts) if parts else None
        if flags:
            vals['reaction_flags'] = flags
        else:
            vals.pop('reaction_flags', None)
    if effect and not res:
        pass  # reactions without results are always instant in handle_reactions()
    elif effect:
        # our on_reaction() effects expect the products to exist right away
        if not flags or flags in ('NONE', '0'):
            vals['reaction_flags'] = 'REACTION_INSTANT'
        elif 'REACTION_INSTANT' not in flags:
            vals['reaction_flags'] = flags + ' | REACTION_INSTANT'
        stats['instant_effect'] += 1
    if not vals:
        continue
    lines.append('')
    lines.append(p + (f' // tg: {match}' if match else ''))
    for k, v in vals.items():
        lines.append(f'\t{k} = {v}')
    report.append((p, match, kind, effect))

lines.append('')
lines.append('////////////////////////////// Reagenty //////////////////////////////')

def norm(s):
    return ''.join(c for c in s.lower() if c.isalnum())

tg_by_name = {}
for p in tg_types:
    if p.startswith(ROOT_G + '/'):
        v, _ = resolve_with_owner(tg_types, p, 'name')
        if v and v.startswith('"'):
            tg_by_name.setdefault(norm(v.strip('"')), p)

our_reagents = sorted(p for p in our_types if p.startswith(ROOT_G + '/'))
our_reagent_set = set(our_reagents)
rstats = collections.Counter()
for p in our_reagents:
    rel = os.path.relpath(our_types[p]['file'], OURS).replace('\\', '/')
    if rel.startswith(SKIP_FILES):
        continue
    m = p if p in tg_types else None
    if not m:
        v, _ = resolve_with_owner(our_types, p, 'name')
        if v and v.startswith('"'):
            m = tg_by_name.get(norm(v.strip('"')))
    if not m:
        rstats['none'] += 1
        continue
    vals = collections.OrderedDict()
    # only values set on this exact tg type (inherited ones come through our own type tree)
    tvars = tg_types.get(m, {}).get('vars', {})
    if 'ph' in tvars:
        vals['ph'] = tvars['ph']
    if 'inverse_chem_val' in tvars:
        vals['inverse_chem_val'] = tvars['inverse_chem_val']
    if 'inverse_chem' in tvars:
        inv = tvars['inverse_chem']
        if inv == 'null' or inv in our_reagent_set:
            vals['inverse_chem'] = inv
        else:
            rstats['inverse_missing'] += 1
    if p != m:
        # matched by name: also take inherited pH so the value doesn't come from an unrelated parent
        val, owner = resolve_with_owner(tg_types, m, 'ph')
        if val is not None and owner != ROOT_G and 'ph' not in vals:
            vals['ph'] = val
    if not vals:
        continue
    rstats['written'] += 1
    lines.append('')
    lines.append(p + ('' if p == m else f' // tg: {m}'))
    for k, v in vals.items():
        lines.append(f'\t{k} = {v}')

open(OUT, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
print(dict(stats))
print(dict(rstats))
