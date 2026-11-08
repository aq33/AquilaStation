"""Szuka angielskich oryginałów dla tekstów, które mają dziś tłumaczenie zwrotne albo podejrzaną parę.

match_upstream.py paruje ostrożnie (ta sama linia, ta sama definicja, te same wstawki), więc część
tekstów z portów dostała tłumaczenie agentów (en_translated.json), czyli polski przełożony z powrotem
na angielski: "pack of plump-helmet spores" zamiast oryginalnego "pack of plump-helmet mycelium".
Tu szukamy oryginału luźniej, ale w tym samym miejscu kodu:

  var   - przypisanie zmiennej typu (name, desc, ...): ta sama ścieżka typu i zmienna w drzewie serwera,
  proc  - komunikat w procedurze: literał z tej samej definicji w pliku źródłowym portu z tymi samymi
          wstawkami (bez treści napisów w wstawkach i zaimków p_*),
  tsx   - tekst okna: literał z pliku o tej samej ścieżce w tgui/packages.

Z kilku kandydatów wygrywa najbliższy obecnemu angielskiemu tekstowi. Podejrzane pary z historii
(angielska strona po polsku, inne wstawki, rażąco inna długość) też trafiają na listę celów.

Kandydat nie zawsze jest oryginałem tego tekstu: bywa sąsiednim komunikatem albo tekstem, który
Aquila celowo zmieniła (hardsuity zamiast MODsuitów, dopisane informacje). Dlatego:
  find   - lista kandydatów (strings/i18n/en_pairs_original.jsonl, poza repo),
  split  - podział: różnice tylko w wielkości liter i interpunkcji przechodzą od razu, kandydaci
           z niskim podobieństwem odpadają, reszta (i podejrzane pary z historii bez kandydata) idzie
           do oceny w paczkach paczka_NN.jsonl (ocena: człowiek albo agenci według match_originals_brief.md),
  apply  - scala ocenione paczki (paczka_NN.out.json) do strings/i18n/en_original.json, który
           build_chat_dict.py nakłada na en_translated.json.

Użycie (z katalogu repo):
    python tools/i18n/match_originals.py find --tree tg=<katalog> --tree bee=<katalog> ...
    python tools/i18n/match_originals.py split <katalog paczek>
    python tools/i18n/match_originals.py apply <katalog paczek>
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
import build_chat_dict as bcd  # noqa: E402
import extract_pairs as ep  # noqa: E402
import list_missing as lm  # noqa: E402
import match_upstream as mu  # noqa: E402

I18N = "strings/i18n/"
# przypisanie zmiennej na pierwszym poziomie wcięcia pod definicją typu: "\tname = \"...\""
VAR_ASSIGN = re.compile(r'^\t(?:var/(?:[A-Za-z_]+/)*)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:\(\s*)?"')
STRING = re.compile(r'"((?:\\.|[^"\\])*)"')
JS_EMBED = re.compile(r"\$\{([^{}]*)\}")
TAG = re.compile(r"<[^>]*>")
WORD = re.compile(r"[a-z0-9]+")


def load(name):
    path = I18N + name
    if not os.path.exists(path):
        return {}
    data = json.load(open(path, encoding="utf-8"))
    data.pop("_komentarz", None)
    return data


def embed_shape(path, text):
    """Wstawki literału bez treści napisów i zaimków: zbiór, który musi się zgadzać po obu stronach."""
    if path.endswith(".dm"):
        out = set()
        for kind, val in mu.parse_embeds(text):
            v = STRING.sub('""', val)
            if mu.EMBED_IGNORED.search(v):
                continue
            out.add(bcd.norm_expr(v))
        return frozenset(out)
    return frozenset(re.sub(r"\s+", "", e) for e in JS_EMBED.findall(text))


def kind_of(text):
    """Rodzaj literału dla embed_shape, gdy nie znamy pliku: wstawki JS ${...} albo DM [...]."""
    return ".tsx" if "${" in text else ".dm"


def words(text):
    text = TAG.sub(" ", ep.strip_embeds(text))
    text = re.sub(r"\\[a-zA-Z]+", " ", text)
    return WORD.findall(text.lower())


def similarity(a, b):
    """Podobieństwo dwóch angielskich tekstów (0..1): słowa w kolejności i zbiór słów."""
    wa, wb = words(a), words(b)
    if not wa or not wb:
        return 0.0
    seq = difflib.SequenceMatcher(None, wa, wb).ratio()
    sa, sb = set(wa), set(wb)
    jac = len(sa & sb) / len(sa | sb)
    return round(max(seq, jac), 3)


def suspicious_history(merged, skip, is_polish):
    """Pary z historii, które wyglądają na źle sparowane: {pl: powód}."""
    out = {}
    for pl, en in merged.items():
        if pl in skip or pl == en or not ep.wordy(pl):
            continue
        if is_polish(en) and not en.isascii() or ep.PL_DIACRITICS.search(en):
            out[pl] = "polski po angielskiej stronie"
        elif embed_shape(kind_of(pl), pl) != embed_shape(kind_of(pl), en):
            out[pl] = "inne wstawki"
        elif len(pl) > 25 and not (0.4 < len(en) / len(pl) < 2.2):
            out[pl] = "inna długość"
    return out


class Source:
    """Plik źródłowy serwera: linie, definicje i przypisania zmiennych."""

    def __init__(self, path):
        self.path = path
        self.lines = mu.read_lines(path)
        self.by_owner = collections.defaultdict(list)
        self.vars = {}
        if path.endswith(".dm"):
            owners = mu.owners(self.lines)
            for line, owner in zip(self.lines, owners):
                if owner is None:
                    continue
                lits = ep.literals(path, line)
                if not lits:
                    continue
                self.by_owner[owner].extend(lits)
                m = VAR_ASSIGN.match(line)
                if m and ":" not in owner:
                    self.vars[(owner, m.group(1))] = lits[0]
        else:
            for line in self.lines:
                self.by_owner[None].extend(ep.literals(path, line))


def open_targets(merged):
    """Teksty bez oryginału: tłumaczenia agentów i podejrzane pary z historii, których nie ma
    jeszcze w en_original.json ani w en_manual.json. {pl: powód}"""
    translated, manual, original = load("en_translated.json"), load("en_manual.json"), load("en_original.json")
    targets = {pl: "tłumaczenie agenta" for pl in translated if translated[pl] != pl}
    targets.update(suspicious_history(merged, set(translated) | set(manual) | set(original),
                                      lm.polish_detector(merged)))
    for pl in list(targets):
        if pl in manual or pl in original:
            del targets[pl]
    print(f"celów: {len(targets)} ({collections.Counter(targets.values())})", file=sys.stderr)
    return targets


def find(args):
    merged = load("en_all.json")
    translated = load("en_translated.json")
    targets = open_targets(merged)

    files = subprocess.run(["git", "ls-files", "-z", "*.dm", "tgui/packages/*.tsx", "tgui/packages/*.jsx",
                            "tgui/packages/*.ts", "tgui/packages/*.js"],
                           capture_output=True, text=True, encoding="utf-8", check=True).stdout.split("\0")[:-1]
    todo = {}
    for path in files:
        if ep.SKIP_PATH.search(path):
            continue
        lines = mu.read_lines(path)
        if any(lit in targets for line in lines for lit in ep.literals(path, line)):
            todo[path] = lines
    print(f"plików z celami: {len(todo)}", file=sys.stderr)

    trees = []
    for spec in args.tree:
        label, root = spec.split("=", 1)
        by_key, tgui = mu.index_tree(label, root)
        trees.append((label, by_key, tgui))
    var_index = collections.defaultdict(list)  # (typ, zmienna) -> [(etykieta, plik)]
    for label, by_key, _tgui in trees:
        for key, paths in by_key.items():
            if ":" not in key:
                for p in paths:
                    var_index[key].append((label, p))

    cache = {}

    def source(p):
        if p not in cache:
            cache[p] = Source(p)
        return cache[p]

    best = {}
    for n, (path, lines) in enumerate(sorted(todo.items())):
        dm = path.endswith(".dm")
        if dm:
            scores = collections.Counter()
            for label, by_key, _tgui in trees:
                for key in mu.definitions(lines):
                    for src in by_key.get(key, ()):
                        scores[(label, src)] += 1
            top = scores.most_common(mu.TOP_FILES)
            sources = [s for s, c in top if c * 2 >= top[0][1]] if top else []
            owners = mu.owners(lines)
        else:
            sources = [(label, tgui[path]) for label, _by_key, tgui in trees if path in tgui]
            owners = [None] * len(lines)
        port_labels = {label for label, _ in sources}
        for line, owner in zip(lines, owners):
            lits = ep.literals(path, line)
            hits = [lit for lit in lits if lit in targets]
            if not hits:
                continue
            m = VAR_ASSIGN.match(line) if dm else None
            for pl in hits:
                current = merged.get(pl) or translated.get(pl)
                if not current:
                    continue
                shape = embed_shape(path, pl)
                cands = []
                if m and owner and ":" not in owner and lits and lits[0] == pl:
                    for label, p in var_index.get(owner, ()):
                        en = source(p).vars.get((owner, m.group(1)))
                        if en is not None:
                            cands.append(("var", label, p, en))
                else:
                    for label, p in sources:
                        for en in source(p).by_owner.get(owner, ()):
                            cands.append(("proc" if dm else "tsx", label, p, en))
                scored = []
                for kind, label, p, en in cands:
                    if en == pl or not ep.wordy(en) or ep.PL_DIACRITICS.search(en):
                        continue
                    if embed_shape(path, en) != shape:
                        continue
                    sim = similarity(current, en)
                    # źródło portu (plik z największą liczbą wspólnych definicji) ma pierwszeństwo przy remisie
                    scored.append((sim, label in port_labels, kind, label, p, en))
                if not scored:
                    continue
                scored.sort(key=lambda x: (x[0], x[1]), reverse=True)
                sim, _port, kind, label, p, en = scored[0]
                if en == current:
                    continue
                prev = best.get(pl)
                if prev and prev["score"] >= sim:
                    continue
                best[pl] = {"pl": pl, "current": current, "original": en, "score": sim, "kind": kind,
                            "tree": label, "source": os.path.basename(p), "file": path,
                            "why": targets[pl], "alts": len({s[5] for s in scored})}
        if n % 200 == 0:
            print(f"  {n}/{len(todo)} kandydatów: {len(best)}", file=sys.stderr)

    with open(args.out, "w", encoding="utf-8") as f:
        for item in sorted(best.values(), key=lambda x: -x["score"]):
            f.write(json.dumps(item, ensure_ascii=False) + "\n")
    print(f"kandydatów: {len(best)}; według rodzaju: {collections.Counter(x['kind'] for x in best.values())}; "
          f"według drzewa: {collections.Counter(x['tree'] for x in best.values())}")


# ---------------------------------------------------------------- split

WRAP = re.compile(r"^(<span class=['\"][^'\"]+['\"]>)(.*)(</span>)$", re.S)
# tekst okna złapany razem z kodem ("? 'Opublikuj...'", "name: 'Plazma',"): pary nie da się podmienić
CODEY_TSX = re.compile(r"^\s*(\?|:|\w+:\s*['\"`])|['\"`],?\s*$")
# minimalne podobieństwo do obecnego tekstu; niżej to prawie zawsze sąsiedni komunikat
MIN_SCORE = {"var": 0.3, "proc": 0.3, "tsx": 0.5, "global": 0.55, "pr": 0.0}
PACKS = 9


def rewrap(current, original):
    """Oryginał w tym samym <span class=...> co obecny tekst (panel dopasowuje cały HTML wiadomości)."""
    mc, mo = WRAP.match(current), WRAP.match(original)
    if mc and not mo:
        return mc.group(1) + original + mc.group(3)
    if mo and not mc:
        return mo.group(2)
    if mc and mo:
        return mc.group(1) + mo.group(2) + mc.group(3)
    return original


def letters_only(text):
    return re.sub(r"[^a-z0-9]", "", text.lower())


def judged_before(folders):
    """(pl, kandydat) ocenione w poprzednich rundach: ten sam kandydat nie wraca do oceny."""
    seen = set()
    for folder in folders:
        for in_path in glob_packs(folder):
            for line in open(in_path, encoding="utf-8"):
                if line.strip():
                    item = json.loads(line)
                    seen.add((item["pl"], item["original"]))
        auto_path = os.path.join(folder, "auto.json")
        if os.path.exists(auto_path):
            seen.update(json.load(open(auto_path, encoding="utf-8")).items())
    return seen


def split(args):
    # z kilku list kandydatów (różne drzewa, wersje, dopasowanie po treści) wygrywa najwyższe podobieństwo
    best = {}
    for path in args.candidates:
        for line in open(path, encoding="utf-8"):
            if line.strip():
                x = json.loads(line)
                if x["pl"] not in best or x["score"] > best[x["pl"]]["score"]:
                    best[x["pl"]] = x
    items = list(best.values())
    seen = judged_before(args.previous)
    merged = load("en_all.json")
    is_polish = lm.polish_detector(merged)
    os.makedirs(args.dir, exist_ok=True)
    auto, judge, dropped = {}, [], collections.Counter()
    for x in items:
        pl, cur, orig = x["pl"], x["current"], x["original"]
        if (pl, orig) in seen or (pl, rewrap(cur, orig)) in seen:
            dropped["oceniony wcześniej"] += 1
            continue
        if is_polish(orig):
            dropped["kandydat po polsku"] += 1
            continue
        history = x["why"] != "tłumaczenie agenta"
        if x["kind"] == "tsx" and (CODEY_TSX.search(pl) or CODEY_TSX.search(orig)):
            dropped["tekst okna z kodem"] += 1
            continue
        orig = rewrap(cur, orig)
        if "\n" in orig and "\\n" in cur:
            dropped["prawdziwe nowe linie"] += 1
            continue
        if not history and letters_only(cur) == letters_only(orig):
            # sama wielkość liter i interpunkcja: pierwsza litera jak u nas (decyduje polski tekst)
            if cur[:1].isalpha() and orig[:1].isalpha():
                orig = (orig[0].upper() if cur[0].isupper() else orig[0].lower()) + orig[1:]
            if orig != cur:
                auto[pl] = orig
            continue
        if not history and x["score"] < MIN_SCORE[x["kind"]]:
            dropped["niskie podobieństwo"] += 1
            continue
        judge.append({"pl": pl, "current": cur, "original": orig})
    have = {x["pl"] for x in items}
    skip = set(load("en_translated.json")) | set(load("en_manual.json")) | set(load("en_original.json"))
    for pl in suspicious_history(merged, skip, lm.polish_detector(merged)):
        if pl not in have and (pl, None) not in seen:
            judge.append({"pl": pl, "current": merged[pl], "original": None})
    with open(os.path.join(args.dir, "auto.json"), "w", encoding="utf-8") as f:
        json.dump(auto, f, ensure_ascii=False, indent=0)
    for i in range(args.packs):
        with open(os.path.join(args.dir, f"paczka_{i:02d}.jsonl"), "w", encoding="utf-8") as f:
            for j, item in enumerate(judge[i::args.packs]):
                f.write(json.dumps(dict(item, id=f"{i:02d}-{j:04d}"), ensure_ascii=False) + "\n")
    print(f"od razu: {len(auto)}, do oceny: {len(judge)} "
          f"(z historii bez kandydata: {sum(1 for j in judge if j['original'] is None)}), odpadło: {dict(dropped)}")


# ---------------------------------------------------------------- apply

OLD_LINK = re.compile(r"""((?:href|action)\s*=\s*)(\\?['"])\?""")


# Aquila to statek, a MODsuity zastąpiły hardsuity (AQ#583): oryginał z innym słowem niż polski tekst odpada
SHIP_PL = re.compile(r"\b(statk|statek|okręt)", re.I)
STATION_EN = re.compile(r"\bstation\b", re.I)
MOD_EN = re.compile(r"\bMOD(suit)?s?\b")


def setting_conflict(pl, current, en):
    """Oryginał opisuje świat inaczej niż nasz tekst (stacja zamiast statku, MODsuit zamiast hardsuitu)."""
    if SHIP_PL.search(pl) and STATION_EN.search(en) and not STATION_EN.search(current):
        return True
    return bool(MOD_EN.search(en) and "MOD" not in pl)


def apply(args):
    out_path = I18N + "en_original.json"
    # słownik bez naszych wcześniejszych wyników: napisy ze wstawek z poprzedniego apply nie mogą zniknąć
    previous = load("en_original.json")
    known = {pl: en for pl, en in load("en_all.json").items() if pl not in previous}
    result, nested, stats = {}, {}, collections.Counter()
    # rundy po kolei: późniejsza ocena tego samego tekstu wygrywa
    for folder in args.dirs:
        auto_path = os.path.join(folder, "auto.json")
        if os.path.exists(auto_path):
            for pl, en in json.load(open(auto_path, encoding="utf-8")).items():
                result[pl] = en
                stats["od razu"] += 1
        apply_packs(folder, result, nested, stats)
    # napisy z wnętrza wstawek tylko, gdy słownik ich jeszcze nie zna (krótkie słowa mają już dobre pary)
    for pl, en in nested.items():
        if pl not in known:
            result.setdefault(pl, en)
    result = {pl: en for pl, en in result.items() if pl != en and en.strip()}
    result["_komentarz"] = ("Oryginały portów zamiast tłumaczeń zwrotnych i poprawki złych par z historii. "
                            "Generuje tools/i18n/match_originals.py apply; build_chat_dict.py nakłada go "
                            "na en_translated.json. Ręczne poprawki: en_manual.json.")
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(dict(sorted(result.items())), f, ensure_ascii=False, indent=0)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    print(f"{dict(stats)}; razem w {out_path}: {len(result) - 1}")


def apply_packs(folder, result, nested, stats):
    import merge_translations as mt
    for in_path in sorted(glob_packs(folder)):
        out = in_path.replace(".jsonl", ".out.json")
        if not os.path.exists(out):
            print(f"brak oceny: {out}", file=sys.stderr)
            continue
        verdicts = json.load(open(out, encoding="utf-8"))
        for line in open(in_path, encoding="utf-8"):
            if not line.strip():
                continue
            item = json.loads(line)
            v = verdicts.get(item["id"])
            if v == "original" and item["original"]:
                en = item["original"]
                if setting_conflict(item["pl"], item["current"], en):
                    stats["odrzucone: stacja/MODsuit"] += 1
                    continue
            elif isinstance(v, dict) and isinstance(v.get("fix"), str):
                en = v["fix"]
            else:
                stats["bez zmian" if v == "current" else "brak decyzji"] += 1
                continue
            pl = item["pl"]
            if embed_shape(kind_of(pl), en) != embed_shape(kind_of(pl), pl):
                stats["odrzucone: inne wstawki"] += 1
                continue
            # starsze oryginały mają linki "?src=..."; BYOND 516 i check_grep.sh wymagają byond://
            en = OLD_LINK.sub(r"\1\2byond://?", en)
            result[pl] = mt.fix_embeds(pl, en, nested)
            stats["oryginał" if v == "original" else "poprawka"] += 1


def glob_packs(folder):
    return [os.path.join(folder, n) for n in os.listdir(folder) if re.fullmatch(r"paczka_\d+\.jsonl", n)]


# ---------------------------------------------------------------- historia innych serwerów
#
# Klony bez dużych plików (git clone --bare --filter=blob:limit=400k): kod jest cały, ikon i dźwięków
# nie ma. Git uruchamiamy z --no-lazy-fetch, żeby brakujący duży plik nie był dociągany z sieci.

CODE_DIRS = ("code", "modular_", "monkestation", "yogstation", "goon", "nsv13", "tgui", "_std", "strings",
             "modular_skyrat", "modular_nova", "modular_ss220", "modular_bluemoon")
HIST_EXT = (".dm", ".tsx", ".jsx", ".ts", ".js")


# zbudowane bundle TGUI (tg i Bee commitowały je latami) są duże i nie ma ich w klonie bez dużych plików
HIST_EXCLUDE = [":(exclude)tgui/public/**", ":(exclude)**/*.bundle.*", ":(exclude)**/node_modules/**",
                ":(exclude).yarn/**", ":(exclude)**/*.min.js", ":(exclude)**/public/*.js"]


def git_lines(repo, *args):
    proc = subprocess.Popen(["git", "--no-lazy-fetch", "-C", repo, *args], stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    for raw in proc.stdout:
        yield raw.decode("utf-8", "replace").rstrip("\n").rstrip("\r")
    err = proc.stderr.read().decode("utf-8", "replace")
    if proc.wait() != 0:
        print(f"BŁĄD gita w {repo} ({args[0]}): {err.strip()[-300:]}", file=sys.stderr)


def missing_paths(repo, pathspecs):
    """Pliki, których któraś wersja jest za duża dla klonu (np. stare tgui/assets/tgui.js): log -p by na nich padł."""
    shas = collections.defaultdict(set)
    for line in git_lines(repo, "log", "--raw", "--no-abbrev", "--no-merges", "--no-renames", "--format=", "HEAD", "--", *pathspecs):
        if not line.startswith(":"):
            continue
        meta, _, p = line.partition("\t")
        parts = meta.split()
        for sha in parts[2:4]:
            if set(sha) != {"0"}:
                shas[sha].add(p)
    proc = subprocess.run(["git", "--no-lazy-fetch", "-C", repo, "cat-file", "--batch-check"],
                          input="".join(f"{s}\n" for s in shas).encode(), capture_output=True)
    out = set()
    for line in proc.stdout.decode("utf-8", "replace").splitlines():
        if line.endswith(" missing"):
            out.update(shas.get(line.split()[0], ()))
    return out


def english_literal(lit):
    return (ep.wordy(lit) and not ep.PL_DIACRITICS.search(lit) and len(lit) <= 3000
            and re.search(r"[A-Za-z]{3}", ep.strip_embeds(lit)))


def literals(args):
    """Wszystkie angielskie literały, jakie kiedykolwiek dodano w historii repozytorium."""
    os.makedirs(args.out, exist_ok=True)
    for spec in args.repo:
        label, repo = spec.split("=", 1)
        seen, path, added = {}, None, []

        def flush():
            if path and added and path.endswith(HIST_EXT) and not ep.SKIP_PATH.search(path):
                for line in ep.logical_lines(path, added):
                    for lit in ep.literals(path, line):
                        lit = lit.strip() if not path.endswith(".dm") else lit
                        if lit not in seen and english_literal(lit):
                            seen[lit] = path
            added.clear()

        pathspecs = [f"*{e}" for e in HIST_EXT] + HIST_EXCLUDE
        broken = missing_paths(repo, pathspecs)
        if broken:
            print(f"{label}: pomijam {len(broken)} plików bez pełnej historii: {sorted(broken)[:5]}", file=sys.stderr)
        pathspecs += [f":(exclude,literal){p}" for p in sorted(broken)]
        for line in git_lines(repo, "log", "-p", "--no-merges", "--no-renames", "-U0", "--format=%x01",
                              "HEAD", "--", *pathspecs):
            if line.startswith("diff --git "):
                flush()
                path = line.split(" b/", 1)[-1]
            elif line.startswith("@@") or line == "\x01":
                flush()
            elif line.startswith("+") and not line.startswith("+++"):
                added.append(line[1:])
        flush()
        out = os.path.join(args.out, f"{label}.jsonl")
        with open(out, "w", encoding="utf-8") as f:
            for lit, p in seen.items():
                f.write(json.dumps([lit, p], ensure_ascii=False) + "\n")
        print(f"{label}: {len(seen)} literałów -> {out}")


def snapshots(args):
    """Kod repozytorium z kolejnych półroczy (pliki kodu do 400 KB), do find --tree."""
    for spec in args.repo:
        label, repo = spec.split("=", 1)
        done = set()
        for year in range(args.since, args.until + 1):
            for month in ("01", "07"):
                rev = next(git_lines(repo, "rev-list", "-1", f"--before={year}-{month}-01", "HEAD"), "")
                if not rev or rev in done:
                    continue
                done.add(rev)
                dest = os.path.join(args.out, f"{label}@{year}-{month}")
                if os.path.isdir(dest):
                    continue
                blobs = []
                for line in git_lines(repo, "ls-tree", "-r", "-l", rev):
                    meta, _, p = line.partition("\t")
                    parts = meta.split()
                    if len(parts) < 4 or parts[1] != "blob" or not p.endswith(HIST_EXT):
                        continue
                    if not p.startswith(CODE_DIRS) or parts[3] == "-" or int(parts[3]) > 400 * 1024:
                        continue
                    blobs.append((parts[2], p))
                write_blobs(repo, blobs, dest)
                print(f"{label}@{year}-{month}: {len(blobs)} plików", file=sys.stderr)


def write_blobs(repo, blobs, dest):
    proc = subprocess.Popen(["git", "--no-lazy-fetch", "-C", repo, "cat-file", "--batch"],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    proc.stdin.write("".join(f"{sha}\n" for sha, _ in blobs).encode())
    proc.stdin.close()
    for sha, p in blobs:
        header = proc.stdout.readline().decode().split()
        if len(header) < 3 or header[1] == "missing":
            continue
        data = proc.stdout.read(int(header[2]))
        proc.stdout.read(1)
        full = os.path.join(dest, p)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "wb") as f:
            f.write(data)
    proc.wait()


def prheads(args):
    """Pary z commitów na gałęziach PR-ów naszego repo, których nie ma w masterze (squash je zgubił).
    Port bywał najpierw skopiowany po angielsku i tłumaczony osobnym commitem: to dokładny oryginał
    w tym samym miejscu kodu. Klon: git clone --bare ... && git fetch origin '+refs/pull/*/head:refs/pull/*'"""
    merged = load("en_all.json")
    targets = open_targets(merged)
    commits = list(git_lines(args.repo, "rev-list", "--no-merges", "--all", "--not", "HEAD"))
    print(f"commitów spoza mastera: {len(commits)}", file=sys.stderr)
    sink = collections.defaultdict(collections.Counter)
    source = collections.defaultdict(set)
    for n, sha in enumerate(commits):
        proc = subprocess.run(["git", "--no-lazy-fetch", "-C", args.repo, "show", "-U0", "--no-renames",
                               "--format=", sha, "--", *ep.PATHSPECS], capture_output=True)
        ep.pairs_from_diff(proc.stdout.decode("utf-8", "replace"), source, sink)
        if n % 500 == 0:
            print(f"  {n}/{len(commits)} par: {len(sink)}", file=sys.stderr)
    best = {}
    for pl, ens in sink.items():
        if pl not in targets or pl not in merged:
            continue
        en = ens.most_common(1)[0][0]
        if en == merged[pl]:
            continue
        best[pl] = {"pl": pl, "current": merged[pl], "original": en, "score": similarity(merged[pl], en),
                    "kind": "pr", "tree": "aquila-pr", "source": sorted(source[pl])[0], "file": "",
                    "why": targets[pl], "alts": len(ens)}
    with open(args.out, "w", encoding="utf-8") as f:
        for item in sorted(best.values(), key=lambda x: -x["score"]):
            f.write(json.dumps(item, ensure_ascii=False) + "\n")
    print(f"par z gałęzi PR: {len(sink)}, kandydatów dla celów: {len(best)}")


STOP = set("the and you your for with that this are not but can its into from have has was will".split())


def global_match(args):
    """Dopasowanie po treści: literał z historii innych serwerów z tymi samymi wstawkami co polski tekst
    i podobny do obecnego angielskiego. Krótkie teksty (do dwóch słów) tylko przy identycznych literach."""
    merged = load("en_all.json")
    targets = open_targets(merged)
    info, index = {}, collections.defaultdict(list)
    for pl in targets:
        cur = merged.get(pl)
        if not cur:
            continue
        ws = [w for w in words(cur) if len(w) > 2 and w not in STOP]
        info[pl] = (cur, embed_shape(kind_of(pl), pl), set(ws), letters_only(cur))
        for w in set(ws):
            index[w].append(pl)
    common = {w for w, pls in index.items() if len(pls) > args.max_df}
    short = {info[pl][3]: pl for pl in info if len(info[pl][2]) <= 2}
    best = {}
    for path in sorted(glob_files(args.literals)):
        label = os.path.basename(path)[:-len(".jsonl")]
        n = 0
        for line in open(path, encoding="utf-8"):
            lit, src = json.loads(line)
            n += 1
            lw = set(w for w in words(lit) if len(w) > 2 and w not in STOP)
            cands = set()
            for w in lw:
                if w not in common:
                    cands.update(index.get(w, ()))
            key = letters_only(lit)
            if key in short:
                cands.add(short[key])
            for pl in cands:
                cur, shape, tw, letters = info[pl]
                if len(tw) <= 2:
                    if key != letters:
                        continue
                elif len(tw & lw) * 2 < len(tw):
                    continue
                if embed_shape(kind_of(pl), lit) != shape or lit == cur:
                    continue
                sim = 1.0 if key == letters else similarity(cur, lit)
                if sim < args.min_score:
                    continue
                prev = best.get(pl)
                if prev and prev["score"] >= sim:
                    continue
                best[pl] = {"pl": pl, "current": cur, "original": lit, "score": sim, "kind": "global",
                            "tree": label, "source": src, "file": "", "why": targets[pl], "alts": 0}
        print(f"  {label}: {n} literałów, kandydatów razem: {len(best)}", file=sys.stderr)
    with open(args.out, "w", encoding="utf-8") as f:
        for item in sorted(best.values(), key=lambda x: -x["score"]):
            f.write(json.dumps(item, ensure_ascii=False) + "\n")
    print(f"kandydatów po treści: {len(best)}; według drzewa: {collections.Counter(x['tree'] for x in best.values())}")


def glob_files(folder):
    return [os.path.join(folder, n) for n in os.listdir(folder) if n.endswith(".jsonl")]


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("find")
    p.add_argument("--tree", action="append", default=[], help="etykieta=katalog z kodem serwera")
    p.add_argument("--out", default=I18N + "en_pairs_original.jsonl")
    p = sub.add_parser("literals")
    p.add_argument("--repo", action="append", default=[], help="etykieta=klon bare z historią")
    p.add_argument("--out", required=True, help="katalog na <etykieta>.jsonl")
    p = sub.add_parser("snapshots")
    p.add_argument("--repo", action="append", default=[], help="etykieta=klon bare z historią")
    p.add_argument("--out", required=True)
    p.add_argument("--since", type=int, default=2021)
    p.add_argument("--until", type=int, default=2026)
    p = sub.add_parser("prheads")
    p.add_argument("--repo", required=True, help="klon bare naszego repo z refs/pull/*")
    p.add_argument("--out", default=I18N + "en_pairs_original_pr.jsonl")
    p = sub.add_parser("global")
    p.add_argument("--literals", required=True, help="katalog z wynikiem literals")
    p.add_argument("--out", default=I18N + "en_pairs_original_global.jsonl")
    p.add_argument("--min-score", type=float, default=0.5)
    p.add_argument("--max-df", type=int, default=400, help="słowa częstsze w celach nie wybierają kandydatów")
    p = sub.add_parser("split")
    p.add_argument("dir")
    p.add_argument("--candidates", nargs="+", default=[I18N + "en_pairs_original.jsonl"])
    p.add_argument("--previous", nargs="*", default=[], help="katalogi wcześniejszych rund oceny")
    p.add_argument("--packs", type=int, default=PACKS)
    p = sub.add_parser("apply")
    p.add_argument("dirs", nargs="+", help="katalogi rund oceny, od najstarszej")
    args = ap.parse_args()
    {"find": find, "literals": literals, "snapshots": snapshots, "prheads": prheads, "global": global_match,
     "split": split, "apply": apply}[args.cmd](args)


if __name__ == "__main__":
    main()
