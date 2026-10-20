"""Minimal DM parser for /datum/chemical_reaction and /datum/reagent type blocks.

Collects, per typepath, the var assignments made directly in that block and the
names of procs overridden for that type. Handles both `/datum/x/y` blocks and
nested indentation is NOT supported (tg/our code use flat paths for these).
"""
import os, re, sys

TYPE_RE = re.compile(r'^(/datum/(?:chemical_reaction|reagent)(?:/[A-Za-z0-9_]+)*)\s*(?://.*)?$')
PROC_RE = re.compile(r'^(/datum/(?:chemical_reaction|reagent)(?:/[A-Za-z0-9_]+)*)/(?:proc/)?([A-Za-z0-9_]+)\(')
VAR_RE = re.compile(r'^\t([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+?)\s*$')


def strip_comment(line):
    out = []
    in_str = False
    i = 0
    while i < len(line):
        c = line[i]
        if c == '"' and (i == 0 or line[i - 1] != '\\'):
            in_str = not in_str
        if not in_str and line.startswith('//', i):
            break
        out.append(c)
        i += 1
    return ''.join(out).rstrip()


def parse_files(paths):
    types = {}
    procs = {}
    for path in paths:
        try:
            text = open(path, encoding='utf-8', errors='replace').read()
        except OSError:
            continue
        lines = text.replace('\r', '').split('\n')
        cur = None
        i = 0
        while i < len(lines):
            raw = lines[i]
            line = strip_comment(raw)
            m = TYPE_RE.match(line)
            if m:
                cur = m.group(1)
                types.setdefault(cur, {'file': path, 'vars': {}})
                i += 1
                continue
            m = PROC_RE.match(line)
            if m:
                procs.setdefault(m.group(1), set()).add(m.group(2))
                cur = None
                i += 1
                continue
            if line and not line[0].isspace():
                cur = None
                i += 1
                continue
            if cur:
                m = VAR_RE.match(line)
                if m:
                    name, val = m.group(1), m.group(2)
                    # join continuation lines for list( ... ) spanning lines
                    depth = val.count('(') - val.count(')')
                    while depth > 0 and i + 1 < len(lines):
                        i += 1
                        nxt = strip_comment(lines[i]).strip()
                        val += ' ' + nxt
                        depth = val.count('(') - val.count(')')
                    while val.endswith('\\') and i + 1 < len(lines):
                        i += 1
                        val = val[:-1] + ' ' + strip_comment(lines[i]).strip()
                    types[cur]['vars'][name] = val
            i += 1
    return types, procs


def walk(root, exts=('.dm',)):
    for dp, dn, fn in os.walk(root):
        if '.git' in dp:
            continue
        for f in fn:
            if f.endswith(exts):
                yield os.path.join(dp, f)


LIST_ITEM_RE = re.compile(r'(/datum/reagent(?:/[A-Za-z0-9_]+)*)\s*=\s*([0-9.]+)')


def parse_reagent_list(val):
    if not val:
        return {}
    return {m.group(1): float(m.group(2)) for m in LIST_ITEM_RE.finditer(val)}


def resolve(types, path, var, default=None):
    """Value of var for path, following DM inheritance through parent paths."""
    p = path
    while p:
        t = types.get(p)
        if t and var in t['vars']:
            return t['vars'][var]
        if p.count('/') <= 2:
            break
        p = p.rsplit('/', 1)[0]
    return default


def resolve_with_owner(types, path, var):
    p = path
    while p:
        t = types.get(p)
        if t and var in t['vars']:
            return t['vars'][var], p
        if p.count('/') <= 2:
            break
        p = p.rsplit('/', 1)[0]
    return None, None
