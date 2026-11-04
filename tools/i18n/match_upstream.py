"""Szuka angielskich oryginałów tekstów portowanych z innych serwerów.

Porty (aquila/ i część core) tłumaczyliśmy od razu przy porcie, więc w naszej
historii nie ma angielskiej wersji. Oryginał jest w repozytorium serwera, z którego
port przyszedł. Dla każdego pliku z polskimi tekstami bez tłumaczenia szukamy pliku
źródłowego po wspólnych ścieżkach typów i procek, a potem parujemy linie tak samo
jak extract_pairs.py (szkielet linii bez literałów).

Użycie (z katalogu repo, po extract_pairs.py):
    python tools/i18n/match_upstream.py --tree tg=../tgstation --tree bee=<katalog> ...

Wynik: strings/i18n/en_pairs_upstream.json {polski literał: angielski literał}
"""

import argparse
import collections
import difflib
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402

# Definicja typu albo procki na początku linii: /obj/item/foo, /obj/item/foo/proc/bar(, /datum/x/Initialize(
DEF = re.compile(r"^(/[A-Za-z0-9_/]+?)(?:/(?:proc|verb)/([A-Za-z0-9_]+)|/([A-Za-z0-9_]+)\()?\s*(?:\(|$|//|\{)")
EXTS_DM = (".dm",)
EXTS_TGUI = (".tsx", ".jsx", ".ts", ".js")
# ile najlepszych plików źródłowych bierzemy na jeden nasz plik
TOP_FILES = 3


def definitions(lines):
    keys = set()
    for line in lines:
        m = DEF.match(line)
        if not m:
            continue
        path = m.group(1)
        proc = m.group(2) or m.group(3)
        keys.add(f"{path}:{proc}" if proc else path)
    return keys


def read_lines(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            return f.read().splitlines()
    except OSError:
        return []


def index_tree(label, root):
    """Klucz definicji -> lista plików; dla tgui względna ścieżka -> plik."""
    by_key = collections.defaultdict(list)
    tgui = {}
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in (".git", "node_modules", ".yarn", "_maps", "icons", "sound")]
        for name in filenames:
            full = os.path.join(dirpath, name)
            if name.endswith(EXTS_DM):
                for key in definitions(read_lines(full)):
                    by_key[key].append(full)
            elif name.endswith(EXTS_TGUI) and "tgui" in dirpath:
                rel = os.path.relpath(full, root).replace("\\", "/")
                idx = rel.find("tgui/packages/")
                if idx >= 0:
                    tgui[rel[idx:]] = full
    print(f"  {label}: {len(by_key)} definicji, {len(tgui)} plików tgui", file=sys.stderr)
    return by_key, tgui


def owners(lines):
    """Dla każdej linii: definicja (typ albo procka), w której leży."""
    out, cur = [], None
    for line in lines:
        m = DEF.match(line)
        if m:
            proc = m.group(2) or m.group(3)
            cur = f"{m.group(1)}:{proc}" if proc else m.group(1)
        out.append(cur)
    return out


EMBED_IGNORED = re.compile(r"(^|\.)p_[a-z]+\(")


def embeds(text):
    """Znormalizowane wstawki literału bez zaimków (p_their() itp. PL zwykle nie ma)."""
    found = set()
    for kind, val in parse_embeds(text):
        key = re.sub(r"\s+", "", val)
        key = re.sub(r"\.name$", "", key)
        key = re.sub(r"^src\.", "", key)
        if not EMBED_IGNORED.search(key):
            found.add(key)
    return found


def parse_embeds(text):
    i, n, depth, start = 0, len(text), 0, 0
    while i < n:
        c = text[i]
        if c == "\\":
            i += 2
            continue
        if c == "[":
            if depth == 0:
                start = i + 1
            depth += 1
        elif c == "]" and depth:
            depth -= 1
            if depth == 0:
                yield ("e", text[start:i])
        i += 1


def align(path, en_lines, pl_lines, sink):
    sk_en = [ep.skeleton(path, x) for x in en_lines]
    sk_pl = [ep.skeleton(path, x) for x in pl_lines]
    dm = path.endswith(EXTS_DM)
    own_en = owners(en_lines) if dm else None
    own_pl = owners(pl_lines) if dm else None
    sm = difflib.SequenceMatcher(None, sk_en, sk_pl)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal" or (tag == "replace" and i2 - i1 == j2 - j1):
            for k in range(i2 - i1):
                en_line, pl_line = en_lines[i1 + k], pl_lines[j1 + k]
                # ta sama definicja po obu stronach, inaczej to sąsiedni podobny blok
                if dm and own_en[i1 + k] != own_pl[j1 + k]:
                    continue
                le, lp = ep.literals(path, en_line), ep.literals(path, pl_line)
                if len(le) != len(lp):
                    continue
                for en, pl in zip(le, lp):
                    if embeds(en) != embeds(pl):
                        continue
                    # jedno słowo ASCII ("temp", "legs") to zwykle klucz w kodzie, nie tekst
                    if re.fullmatch(r"[A-Za-z]+", pl.strip()) and not ep.NAME_ASSIGN.search(pl_line):
                        continue
                    if ep.accept(en, pl, en_line, pl_line):
                        sink[pl][en] += 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", action="append", default=[], help="etykieta=katalog z kodem serwera")
    ap.add_argument("--pairs", default="strings/i18n/en_pairs.json")
    ap.add_argument("--out", default="strings/i18n/en_pairs_upstream.json")
    args = ap.parse_args()

    known = set(json.load(open(args.pairs, encoding="utf-8")))
    files = subprocess.run(["git", "ls-files", "-z", "*.dm", "tgui/packages/*.tsx", "tgui/packages/*.jsx",
                            "tgui/packages/*.ts", "tgui/packages/*.js"],
                           capture_output=True, text=True, encoding="utf-8").stdout.split("\0")[:-1]

    # nasze pliki z polskimi tekstami bez tłumaczenia
    todo = {}
    for path in files:
        if ep.SKIP_PATH.search(path):
            continue
        lines = read_lines(path)
        missing = 0
        for line in lines:
            for lit in ep.literals(path, line):
                if lit not in known and ep.wordy(lit) and ep.is_polish(lit):
                    missing += 1
        if missing:
            todo[path] = (lines, missing)
    print(f"plików z brakami: {len(todo)}, tekstów: {sum(m for _, m in todo.values())}", file=sys.stderr)

    trees = []
    for spec in args.tree:
        label, root = spec.split("=", 1)
        trees.append((label,) + index_tree(label, root))

    sink = collections.defaultdict(collections.Counter)
    used = collections.Counter()
    for n, (path, (lines, _missing)) in enumerate(sorted(todo.items())):
        if path.endswith(EXTS_DM):
            keys = definitions(lines)
            scores = collections.Counter()
            for label, by_key, _tgui in trees:
                for key in keys:
                    for source in by_key.get(key, ()):
                        scores[(label, source)] += 1
            # tylko pliki, które dzielą co najmniej połowę naszych definicji z najlepszym
            best = scores.most_common(TOP_FILES)
            if not best:
                continue
            top = best[0][1]
            sources = [s for s, c in best if c * 2 >= top]
        else:
            sources = [(label, tgui[path]) for label, _by_key, tgui in trees if path in tgui]
        for label, source in sources:
            align(path, read_lines(source), lines, sink)
            used[label] += 1
        if n % 200 == 0:
            print(f"  {n}/{len(todo)} par: {len(sink)}", file=sys.stderr)

    result = {}
    for pl, ens in sink.items():
        if pl in known:
            continue
        result[pl] = ens.most_common(1)[0][0]
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(result.items())), f, ensure_ascii=False, indent=1)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    sys.stdout.reconfigure(encoding="utf-8")
    print(f"nowych par: {len(result)}; dopasowane pliki według źródła: {dict(used)}")


if __name__ == "__main__":
    main()
