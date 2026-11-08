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


def find(args):
    merged = load("en_all.json")
    translated, manual, original = load("en_translated.json"), load("en_manual.json"), load("en_original.json")
    is_polish = lm.polish_detector(merged)
    targets = {pl: "tłumaczenie agenta" for pl in translated if translated[pl] != pl}
    targets.update(suspicious_history(merged, set(translated) | set(manual) | set(original), is_polish))
    for pl in manual:
        targets.pop(pl, None)
    print(f"celów: {len(targets)} ({collections.Counter(targets.values())})", file=sys.stderr)

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
MIN_SCORE = {"var": 0.3, "proc": 0.3, "tsx": 0.5}
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


def split(args):
    items = [json.loads(line) for line in open(args.candidates, encoding="utf-8") if line.strip()]
    merged = load("en_all.json")
    os.makedirs(args.dir, exist_ok=True)
    auto, judge, dropped = {}, [], collections.Counter()
    for x in items:
        pl, cur, orig = x["pl"], x["current"], x["original"]
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
        if pl not in have:
            judge.append({"pl": pl, "current": merged[pl], "original": None})
    with open(os.path.join(args.dir, "auto.json"), "w", encoding="utf-8") as f:
        json.dump(auto, f, ensure_ascii=False, indent=0)
    for i in range(PACKS):
        with open(os.path.join(args.dir, f"paczka_{i:02d}.jsonl"), "w", encoding="utf-8") as f:
            for j, item in enumerate(judge[i::PACKS]):
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
    import merge_translations as mt
    out_path = I18N + "en_original.json"
    known = load("en_all.json")
    result, nested, stats = {}, {}, collections.Counter()
    auto_path = os.path.join(args.dir, "auto.json")
    if os.path.exists(auto_path):
        for pl, en in json.load(open(auto_path, encoding="utf-8")).items():
            result[pl] = en
            stats["od razu"] += 1
    for in_path in sorted(glob_packs(args.dir)):
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


def glob_packs(folder):
    return [os.path.join(folder, n) for n in os.listdir(folder) if re.fullmatch(r"paczka_\d+\.jsonl", n)]


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("find")
    p.add_argument("--tree", action="append", default=[], help="etykieta=katalog z kodem serwera")
    p.add_argument("--out", default=I18N + "en_pairs_original.jsonl")
    p = sub.add_parser("split")
    p.add_argument("dir")
    p.add_argument("--candidates", default=I18N + "en_pairs_original.jsonl")
    p = sub.add_parser("apply")
    p.add_argument("dir")
    args = ap.parse_args()
    {"find": find, "split": split, "apply": apply}[args.cmd](args)


if __name__ == "__main__":
    main()
