"""Szuka angielskich oryginałów dla tekstów, które mają dziś tłumaczenie zwrotne albo podejrzaną parę.

match_upstream.py paruje ostrożnie (ta sama linia, ta sama definicja, te same wstawki), więc część
tekstów z portów dostała tłumaczenie agentów (en_translated.json), czyli polski przełożony z powrotem
na angielski: "pack of plump-helmet spores" zamiast oryginalnego "pack of plump-helmet mycelium".
Tu szukamy oryginału luźniej. Rodzaje kandydatów (pole "kind"):

  var    - przypisanie zmiennej typu (name, desc, ...): ta sama ścieżka typu i zmienna w drzewie serwera
           (także pliki strings/*.json: ta sama ścieżka kluczy),
  proc   - komunikat w procedurze: literał z tej samej definicji w pliku źródłowym portu z tymi samymi
           wstawkami (bez treści napisów w wstawkach i zaimków p_*),
  tsx    - tekst okna: literał albo zdanie JSX z pliku o tej samej ścieżce w tgui/packages,
  pr     - nasz własny tekst sprzed tłumaczenia z gałęzi PR-a (squash go zgubił),
  global - literał z całej historii innego serwera z tymi samymi wstawkami i podobną treścią.

Kandydat nie zawsze jest oryginałem tego tekstu: bywa sąsiednim komunikatem albo tekstem, który
Aquila celowo zmieniła (hardsuity zamiast MODsuitów z aq33/AquilaStation#583, dopisane informacje).
Dlatego kandydatów ocenia człowiek albo agent (tools/i18n/match_originals_brief.md), a apply
sprawdza każdą przyjętą parę tymi samymi funkcjami, których używa build_chat_dict.py.

Przebieg (z katalogu repo; klony innych serwerów: git clone --bare --filter=blob:limit=400k):
    python tools/i18n/match_originals.py find --tree tg=<katalog> ...         -> en_pairs_original.jsonl
    python tools/i18n/match_originals.py snapshots --repo tg=<klon> --out <k>  (wersje kodu do find --tree)
    python tools/i18n/match_originals.py literals --repo tg=<klon> --out <k>
    python tools/i18n/match_originals.py global --literals <k>                -> en_pairs_original_global.jsonl
    python tools/i18n/match_originals.py prheads --repo <klon naszego repo z refs/pull/*>
    python tools/i18n/match_originals.py jsonfiles --repo tg=<klon> ...
    python tools/i18n/match_originals.py split <runda> --candidates strings/i18n/en_pairs_original*.jsonl \\
        --previous <starsze rundy>                                            -> paczki do oceny
    python tools/i18n/match_originals.py apply <wszystkie rundy od najstarszej> -> en_original.json
    python tools/build_chat_dict.py

apply zapisuje też en_original_base.json: wartość, którą słownik miał przed nadpisaniem. Bez niej para
usunięta z en_original.json zostałaby w en_all.json na zawsze (en_all.json jest bazą build_chat_dict.py).
"""

import argparse
import collections
import difflib
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading

sys.path.insert(0, os.path.dirname(__file__))
import build_chat_dict as bcd  # noqa: E402
import extract_pairs as ep  # noqa: E402
import jsx_ast  # noqa: E402
import jsx_runs  # noqa: E402
import list_missing as lm  # noqa: E402
import match_upstream as mu  # noqa: E402
import merge_translations as mt  # noqa: E402

I18N = "strings/i18n/"
AGENT = "tłumaczenie agenta"
# przypisanie zmiennej na pierwszym poziomie wcięcia pod definicją typu: "\tname = \"...\""
VAR_ASSIGN = re.compile(r'^\t(?:var/(?:[A-Za-z_]+/)*)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:\(\s*)?"')
JS_EMBED = re.compile(r"\$\{((?:[^{}]|\{[^{}]*\})*)\}")
WORD = re.compile(r"[a-z0-9]+")
BAD_CHAR = "\ufffd"  # bajty spoza UTF-8 w źródle innego serwera (Latin-1) po dekodowaniu z "replace"


def load(name):
    """Słownik strings/i18n/<name> bez klucza _komentarz (pusty, gdy pliku nie ma)."""
    return bcd.load_json(I18N + name)


def write_json(path, data, indent=0):
    """Zapis JSON w UTF-8 z LF i nową linią na końcu (wymóg check_grep.sh)."""
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=indent)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku


def write_candidates(path, best):
    """Lista kandydatów jako JSONL, od najwyższego podobieństwa."""
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        for item in sorted(best.values(), key=lambda x: -x["score"]):
            f.write(json.dumps(item, ensure_ascii=False) + "\n")


def offer(best, item):
    """Zapamiętuje kandydata, jeśli dla tego tekstu nie ma lepszego (wyższe podobieństwo)."""
    prev = best.get(item["pl"])
    if not prev or prev["score"] < item["score"]:
        best[item["pl"]] = item


def is_js(text):
    """Literał JS z wstawkami ${...} (tekst okna)."""
    return "${" in text


def embed_shape(text, js=None):
    """Wstawki literału bez treści napisów i zaimków: zbiór, który musi się zgadzać po obu stronach."""
    if js is None:
        js = is_js(text)
    if js:
        return frozenset(re.sub(r"\s+", "", jsx_runs.expr_skeleton(e)) for e in JS_EMBED.findall(text))
    out = set()
    for _kind, val in mu.parse_embeds(text):
        v = mt.STRING.sub('""', val)
        if mu.EMBED_IGNORED.search(v):
            continue
        out.add(bcd.norm_expr(v))
    return frozenset(out)


def same_embeds(pl, en, js=None):
    """Czy polski i angielski literał mają te same wstawki (bez treści napisów)."""
    js = is_js(pl) if js is None else js
    return embed_shape(pl, js) == embed_shape(en, js)


def words(text):
    """Słowa tekstu małymi literami, bez wstawek, znaczników i makr DM."""
    text = bcd.TAG.sub(" ", ep.strip_embeds(jsx_runs.plain(text)))
    text = re.sub(r"\\[a-zA-Z]+", " ", text)
    return WORD.findall(text.lower())


def similarity(a, b):
    """Podobieństwo dwóch angielskich tekstów (0..1): słowa w kolejności i zbiór słów."""
    wa, wb = words(a), words(b)
    if not wa or not wb:
        return 0.0
    seq = difflib.SequenceMatcher(None, wa, wb, autojunk=False).ratio()
    sa, sb = set(wa), set(wb)
    return round(max(seq, len(sa & sb) / len(sa | sb)), 3)


def polish_detector(known):
    """Polski tekst: polskie znaki albo słowo znane tylko z polskiej strony słownika.
    Bez stoplisty ep.PL_WORDS z lm.polish_detector: "to", "do" i "we" to też angielskie słowa,
    a angielskie zdanie z dwoma z nich wypadało jako "kandydat po polsku"."""
    pl_words, en_words = collections.Counter(), set()
    for pl, en in known.items():
        pl_words.update(set(lm.WORD.findall(pl.lower())))
        en_words.update(lm.WORD.findall(str(en).lower()))
    vocab = {w for w, count in pl_words.items() if count >= 2 and w not in en_words}

    def detect(text):
        """Czy tekst jest po polsku."""
        plain = ep.strip_embeds(jsx_runs.plain(text))
        return bool(ep.PL_DIACRITICS.search(plain) or any(w in vocab for w in lm.WORD.findall(plain.lower())))
    return detect


def suspicious_history(merged, skip, detect):
    """Pary z historii, które wyglądają na źle sparowane: {pl: powód}."""
    out = {}
    for pl, en in merged.items():
        if pl in skip or pl == en or not ep.wordy(pl):
            continue
        if detect(en):
            out[pl] = "polski po angielskiej stronie"
        elif not same_embeds(pl, en):
            out[pl] = "inne wstawki"
        elif len(pl) > 25 and not (0.4 < len(en) / len(pl) < 2.2):
            out[pl] = "inna długość"
    return out


def code_files(pathspecs):
    """Pliki kodu z gita według pathspeców, bez testów i plików spoza tekstów gracza."""
    out = subprocess.run(["git", "ls-files", "-z", *pathspecs], capture_output=True, text=True,
                         encoding="utf-8", check=True).stdout.split("\0")[:-1]
    return [p for p in out if not ep.SKIP_PATH.search(p) and not lm.NOT_PLAYER_TEXT.search(p)]


def code_places():
    """{literał: zbiór plików} dla tekstów gracza w kodzie (DM, okna, strings/), bez testów."""
    places = collections.defaultdict(set)
    for path in code_files(["*.dm", *ep.UI_PATHSPECS, "strings/*.txt", "strings/*.json"]):
        for line in mu.read_lines(path):
            for lit in ep.literals(path, line):
                places[lit].add(path)
    for item in jsx_ast.dump() or []:
        places[item["literal"]].add(item["file"].replace("\\", "/"))
    return places


def in_window(pl, places):
    """Literał z kodu okien: build_chat_dict.py parsuje go jak JS (makra DM nie działają)."""
    return is_js(pl) or any(p.startswith("tgui/") for p in places.get(pl, ()))


def real_originals():
    """Klucze en_original.json z prawdziwym oryginałem albo poprawką, bez wpisów przywracających wartość
    sprzed nadpisania (te zostają celami: można im jeszcze znaleźć oryginał)."""
    original, base = load("en_original.json"), load("en_original_base.json")
    return {pl for pl, en in original.items()
            if not (pl in base and (base[pl] == en or (base[pl] is None and en == pl)))}


def open_targets(merged, detect=None):
    """Teksty bez oryginału: tłumaczenia agentów i podejrzane pary z historii, których nie ma
    jeszcze w en_original.json ani w en_manual.json. {pl: powód}"""
    translated, manual, original = load("en_translated.json"), load("en_manual.json"), real_originals()
    targets = {pl: AGENT for pl in translated if translated[pl] != pl and pl not in manual and pl not in original}
    detect = detect or polish_detector(merged)
    targets.update(suspicious_history(merged, set(translated) | set(manual) | set(original), detect))
    print(f"celów: {len(targets)} ({collections.Counter(targets.values())})", file=sys.stderr)
    return targets


# ---------------------------------------------------------------- find

class Source:
    """Plik źródłowy serwera: literały według definicji i przypisania zmiennych."""

    def __init__(self, path):
        """Parsuje plik źródłowy: literały według definicji i przypisania zmiennych."""
        lines = mu.read_lines(path)
        self.by_owner = collections.defaultdict(list)
        self.vars = {}
        if path.endswith(".dm"):
            for line, owner in zip(lines, mu.owners(lines)):
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
            for line in lines:
                self.by_owner[None].extend(ep.literals(path, line))
            if path.endswith(jsx_runs.JSX_EXT):
                # zdania JSX złożone z kilku węzłów (tak jak klucze słownika okien)
                self.by_owner[None].extend(lit for lit, _ in jsx_runs.runs("\n".join(lines)))


def file_literals(path, lines):
    """Literały pliku: (linia, literały) i dla okien zdania JSX jako osobna pozycja na końcu."""
    out = [(line, ep.literals(path, line)) for line in lines]
    if path.endswith(jsx_runs.JSX_EXT):
        out.append(("", [lit for lit, _ in jsx_runs.runs("\n".join(lines))]))
    return out


def find(args):
    """Kandydaci z tego samego miejsca kodu w drzewach innych serwerów (var, proc, tsx)."""
    merged = load("en_all.json")
    targets = open_targets(merged)
    specs = ep.UI_PATHSPECS if args.tgui_only else ["*.dm", *ep.UI_PATHSPECS]
    todo = {}
    for path in code_files(specs):
        lines = mu.read_lines(path)
        lits = file_literals(path, lines)
        if any(lit in targets for _line, ls in lits for lit in ls):
            todo[path] = (lines, lits)
    print(f"plików z celami: {len(todo)}", file=sys.stderr)

    trees = []
    for spec in args.tree:
        label, root = spec.split("=", 1)
        if args.tgui_only:
            tgui = {}
            for dirpath, _dirs, names in os.walk(root):
                for name in names:
                    full = os.path.join(dirpath, name)
                    rel = os.path.relpath(full, root).replace("\\", "/")
                    idx = rel.find("tgui/packages/")
                    if idx >= 0 and name.endswith(mu.EXTS_TGUI):
                        tgui[rel[idx:]] = full
            trees.append((label, {}, tgui))
        else:
            trees.append((label, *mu.index_tree(label, root)))
    var_index = collections.defaultdict(list)  # typ -> [(etykieta, plik)]
    for label, by_key, _tgui in trees:
        for key, paths in by_key.items():
            if ":" not in key:
                var_index[key].extend((label, p) for p in paths)

    cache = {}

    def source(p):
        """Plik źródłowy z pamięci podręcznej (parsowany raz)."""
        if p not in cache:
            cache[p] = Source(p)
        return cache[p]

    best = {}
    for n, (path, (lines, lits_by_line)) in enumerate(sorted(todo.items())):
        dm = path.endswith(".dm")
        if dm:
            keys = mu.definitions(lines)
            scores = collections.Counter()
            for label, by_key, _tgui in trees:
                for key in keys:
                    for src in by_key.get(key, ()):
                        scores[(label, src)] += 1
            top = scores.most_common(mu.TOP_FILES)
            sources = [s for s, c in top if c * 2 >= top[0][1]] if top else []
            owners = mu.owners(lines)
        else:
            sources = [(label, tgui[path]) for label, _by_key, tgui in trees if path in tgui]
            owners = [None] * len(lits_by_line)
        port_labels = {label for label, _ in sources}
        for (line, lits), owner in zip(lits_by_line, owners):
            hits = [lit for lit in lits if lit in targets]
            if not hits:
                continue
            m = VAR_ASSIGN.match(line) if dm else None
            for pl in hits:
                current = merged.get(pl)
                if not current:
                    continue
                cands = []
                if m and owner and ":" not in owner and lits[0] == pl:
                    for label, p in var_index.get(owner, ()):
                        en = source(p).vars.get((owner, m.group(1)))
                        if en is not None:
                            cands.append(("var", label, p, en))
                else:
                    for label, p in sources:
                        cands.extend(("proc" if dm else "tsx", label, p, en) for en in source(p).by_owner.get(owner, ()))
                scored = []
                for kind, label, p, en in cands:
                    if en == pl or not ep.wordy(en) or ep.PL_DIACRITICS.search(en) or BAD_CHAR in en:
                        continue
                    if not same_embeds(pl, en, js=not dm):
                        continue
                    # przy remisie wygrywa drzewo, z którego pochodzi port (najwięcej wspólnych definicji)
                    scored.append((similarity(current, en), label in port_labels, kind, label, p, en))
                if not scored:
                    continue
                sim, _port, kind, label, p, en = max(scored, key=lambda s: s[:2])
                if en != current:
                    offer(best, {"pl": pl, "current": current, "original": en, "score": sim, "kind": kind,
                                 "tree": label, "source": os.path.basename(p), "why": targets[pl]})
        if n % 200 == 0:
            print(f"  {n}/{len(todo)} kandydatów: {len(best)}", file=sys.stderr)
    write_candidates(args.out, best)
    print(f"kandydatów: {len(best)}; według rodzaju: {collections.Counter(x['kind'] for x in best.values())}; "
          f"według drzewa: {collections.Counter(x['tree'] for x in best.values())}")


# ---------------------------------------------------------------- split

SPAN_OPEN = re.compile(r"<span\b", re.I)
SPAN_CLOSE = re.compile(r"</span\s*>", re.I)
OUTER = re.compile(r"^(<span class=['\"][^'\"]+['\"]>)(.*)</span>((?:\\n|\s)*)$", re.S)
TAIL = re.compile(r"(?:\\n|\s)*$")
# tekst okna złapany razem z kodem ("? 'Opublikuj...'", "name: 'Plazma',"): pary nie da się podmienić
CODEY_JS = re.compile(r"^\s*(\?|:|\w+:\s*['\"`])|['\"`],?\s*$")
# minimalne podobieństwo do obecnego tekstu; niżej to prawie zawsze sąsiedni komunikat
MIN_SCORE = {"var": 0.3, "proc": 0.3, "tsx": 0.5, "global": 0.55, "pr": 0.0}
PACKS = 9
# pewność źródła: gałąź PR (ten sam plik przed tłumaczeniem) > to samo miejsce w kodzie > podobna treść
KIND_RANK = {"pr": 2, "var": 1, "proc": 1, "tsx": 1, "global": 0}


def spans_balanced(text):
    """Czy liczba otwarć <span> równa się liczbie zamknięć."""
    return len(SPAN_OPEN.findall(text)) == len(SPAN_CLOSE.findall(text))


def outer_span(text):
    """(otwarcie, środek, ogon) dla tekstu w jednym zewnętrznym <span class=...>, inaczej None."""
    m = OUTER.match(text)
    if not m:
        return None
    depth = 0
    for closing in re.findall(r"<(/?)span\b", m.group(2), re.I):
        depth += -1 if closing else 1
        if depth < 0:
            return None  # pierwszy <span> i ostatni </span> to nie para
    return (m.group(1), m.group(2), m.group(3)) if depth == 0 else None


def rewrap(pl, en):
    """Zewnętrzny <span class=...> i końcowe \\n jak w polskim literale: to faktyczny HTML z kodu
    (panel dopasowuje cały HTML wiadomości, obecny angielski bywa złą parą z innym spanem)."""
    sp, se = outer_span(pl), outer_span(en)
    inner = se[1] if se else en
    if sp:
        return sp[0] + inner + "</span>" + sp[2]
    if se:
        return inner + TAIL.search(pl).group(0)
    return en


def letters_only(text):
    """Same litery i cyfry małymi literami (porównanie bez interpunkcji i odstępów)."""
    return re.sub(r"[^a-z0-9]", "", text.lower())


def case_only(cur, orig):
    """Kandydat różni się od obecnego tekstu tylko wielkością liter, ma tę samą pierwszą literę
    i nie jest pisany wersalikami (wielkie litery identyfikatorów zależą od kontekstu: "OFF")."""
    return (orig != cur and orig.lower() == cur.lower() and orig[:1] == cur[:1]
            and not (orig.isupper() and not cur.isupper()))


def judged_before(folders):
    """(pl, kandydat) z werdyktem w poprzednich rundach: ten sam kandydat nie wraca do oceny.
    Pozycja bez werdyktu (brak paczka_NN.out.json albo id) zostaje do oceny."""
    seen = set()
    for folder in folders:
        for in_path in glob_packs(folder):
            out = in_path.replace(".jsonl", ".out.json")
            if not os.path.exists(out):
                continue
            verdicts = json.load(open(out, encoding="utf-8"))
            for line in open(in_path, encoding="utf-8"):
                if line.strip():
                    item = json.loads(line)
                    if item["id"] in verdicts:
                        seen.add((item["pl"], item["original"]))
        auto_path = os.path.join(folder, "auto.json")
        if os.path.exists(auto_path):
            seen.update(json.load(open(auto_path, encoding="utf-8")).items())
    return seen


def rank(item):
    """Klucz sortowania kandydatów: pewność źródła, potem podobieństwo."""
    return (KIND_RANK.get(item["kind"], 0), item["score"])


def split(args):
    """Dzieli kandydatów na przyjęte od razu, odrzucone i paczki do oceny."""
    if not args.auto_only and glob.glob(os.path.join(args.dir, "paczka_*.out.json")):
        sys.exit(f"{args.dir} ma już ocenione paczki: nowe paczki przypięłyby stare werdykty do innych tekstów")
    by_pl = collections.defaultdict(list)
    for path in args.candidates:
        for line in open(path, encoding="utf-8"):
            if line.strip():
                x = json.loads(line)
                by_pl[x["pl"]].append(x)
    seen = judged_before(args.previous)
    merged = load("en_all.json")
    detect = polish_detector(merged)
    has_original = set() if args.auto_only else real_originals()
    places = code_places()
    os.makedirs(args.dir, exist_ok=True)
    auto, judge, dropped, have = {}, [], collections.Counter(), set()

    def verdict(x):
        """Co zrobić z kandydatem: ("auto"|"judge", oryginał) albo (None, powód odrzucenia)."""
        pl, cur, orig = x["pl"], x["current"], x["original"]
        history = x["why"] != AGENT
        if (pl, orig) in seen or (pl, rewrap(pl, orig)) in seen:
            return None, "oceniony wcześniej"
        if detect(orig) or BAD_CHAR in orig:
            return None, "kandydat po polsku albo z błędnym znakiem"
        if x["kind"] == "global" and letters_only(cur) == letters_only(orig):
            # ten sam tekst w innym miejscu: różni się tylko wielkością liter, które zależą od kontekstu
            return None, "po treści tylko wielkość liter"
        if in_window(pl, places) and (CODEY_JS.search(pl) or CODEY_JS.search(orig)):
            return None, "tekst okna z kodem"
        orig = rewrap(pl, orig)
        if orig == cur:
            return None, "po przeniesieniu spanu to obecny tekst"
        if "\n" in orig and "\\n" in cur:
            return None, "prawdziwe nowe linie"
        if not history and case_only(cur, orig):
            return "auto", orig
        if not history and x["score"] < MIN_SCORE[x["kind"]]:
            return None, "niskie podobieństwo"
        return "judge", orig

    for pl, cands in by_pl.items():
        if pl in has_original:
            dropped["ma już oryginał"] += 1
            continue
        reason = None
        for x in sorted(cands, key=rank, reverse=True):
            kind, value = verdict(x)
            if kind is None:
                reason = reason or value
                continue
            have.add(pl)
            if kind == "auto":
                auto[pl] = value
            else:
                judge.append({"pl": pl, "current": x["current"], "original": value})
            break
        else:
            dropped[reason] += 1
    with open(os.path.join(args.dir, "auto.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(auto, f, ensure_ascii=False, indent=0)
    if args.auto_only:
        print(f"od razu: {len(auto)}, odpadło: {dict(dropped)}")
        return
    skip = set(load("en_translated.json")) | set(load("en_manual.json")) | has_original
    for pl in suspicious_history(merged, skip, detect):
        if pl not in have and (pl, None) not in seen:
            judge.append({"pl": pl, "current": merged[pl], "original": None})
    for i in range(args.packs):
        with open(os.path.join(args.dir, f"paczka_{i:02d}.jsonl"), "w", encoding="utf-8", newline="\n") as f:
            for j, item in enumerate(judge[i::args.packs]):
                f.write(json.dumps(dict(item, id=f"{i:02d}-{j:04d}"), ensure_ascii=False) + "\n")
    print(f"od razu: {len(auto)}, do oceny: {len(judge)} "
          f"(z historii bez kandydata: {sum(1 for j in judge if j['original'] is None)}), odpadło: {dict(dropped)}")


# ---------------------------------------------------------------- apply

# starsze oryginały mają linki "?src=..." (także HREF=?src= bez cudzysłowu); BYOND 516 wymaga byond://
OLD_LINK = re.compile(r"""((?:href|action)\s*=\s*)(\\?['"]?)\?""", re.I)
# makra DM w tekście okna: parse_js_literal czyta "\r" z "\red" jako znak CR
DM_MACRO = re.compile(r"\\(?:red|blue|green|black|bold|italic|the|The|an?|An?|improper|proper|icon|ref|roman|Roman"
                      r"|th|s|he|she|him|her|his|hers|himself|herself)\b")
# Aquila to statek, a hardsuity zastąpiły MODsuity (aq33/AquilaStation#583): oryginał z innym słowem niż nasz tekst odpada
STATION_EN = re.compile(r"\bstation\b", re.I)
STATION_PL = re.compile(r"stacj", re.I)
MOD_EN = re.compile(r"\bMOD(suit)?s?\b")
NAME_MAPS = ["aquila/code/modules/client/accessory_names_pl.dm",
             "aquila/code/modules/client/loadout/loadout_names_pl.dm"]
NAME_MAP_PAIR = re.compile(r'^\s*"((?:\\.|[^"\\])+)"\s*=\s*"((?:\\.|[^"\\])+)"', re.M)
# krótki tekst (do 3 słów) używany w kilku plikach: oryginał z jednego miejsca nie pasuje do pozostałych
SHARED_SHORT_WORDS = 3


def end_mark(text):
    """Dwukropek albo wielokropek na końcu tekstu (bez znaczników i \\n): etykieta "Kołki:" i "Szukaj..."
    tracą sens bez nich, a polski tekst decyduje o wyglądzie."""
    text = re.sub(r"(?:<[^>]*>|\\n|\s)+$", "", text)
    if text.endswith(":"):
        return ":"
    return "..." if text.endswith(("...", "…")) else ""


def setting_conflict(pl, current, en):
    """Oryginał opisuje świat inaczej niż nasz tekst (stacja zamiast statku, MODsuit zamiast hardsuitu)."""
    if STATION_EN.search(en) and not STATION_EN.search(current) and not STATION_PL.search(pl):
        return True
    return bool(MOD_EN.search(en) and "MOD" not in pl)


def align_dm_embeds(pl, en):
    """Wstawki angielskiego tekstu w postaci z polskiego literału, żeby build_chat_dict je połączył.

    Zostają wstawki identyczne po normalizacji i angielskie warunki z tym samym warunkiem co polska
    alternatywa: build_en robi z nich gałąź ([x ? "s" : ""] daje "arm"/"arms"). Polski napis w takiej
    wstawce (merge_translations.fix_embeds) składał się z nowym szablonem w "armarms". Inne wstawki
    o tym samym kształcie (pick(), lista) dostają polską postać, a ich napisy wracają jako pary."""
    pl_exprs = [v for k, v in bcd.parse_dm_literal(pl) if k == "e"]
    pl_norm = {bcd.norm_expr(e) for e in pl_exprs}
    pl_conditions = {bcd.ternary_condition(e) for e in pl_exprs if bcd.literal_ternary(e)} - {None}
    unused, replaced, pairs = list(pl_exprs), [], []
    for kind, val in bcd.parse_dm_literal(en):
        if kind != "e" or bcd.norm_expr(val) in pl_norm:
            continue
        condition = bcd.ternary_condition(val)
        if condition in pl_conditions and bcd.literal_ternary(val):
            continue
        shape = mt.code_shape(val)
        match = next((e for e in unused if mt.code_shape(e) == shape and mt.STRING.search(e)), None)
        if not match:
            continue
        unused.remove(match)
        replaced.append((val, match))
        pl_strings, en_strings = mt.STRING.findall(match), mt.STRING.findall(val)
        if len(pl_strings) == len(en_strings):
            pairs += [(p, e) for p, e in zip(pl_strings, en_strings) if p != e and ep.wordy(p)]
    for val, match in replaced:
        en = en.replace(f"[{val}]", f"[{match}]", 1)
    return en, pairs


def builds(pl, en, js):
    """Czy build_chat_dict.py zrobi z pary szablon (te same funkcje, te same braki)."""
    parse = bcd.parse_js_literal if js else bcd.parse_dm_literal
    built = bcd.build_pl(parse(pl), js=js)
    if not built:
        return True  # klucz z makrem przedimka: build_chat_dict i tak go pomija
    _parts, missing = bcd.build_en(parse(en), built[1], js=js)
    return not missing


class Merger:
    """Stan scalania rund: wynik, źródło każdego oryginału i pary z wnętrza wstawek."""

    def __init__(self, previous, keep_previous):
        """Wczytuje słowniki i miejsca literałów w kodzie; keep_previous zaczyna od obecnego wyniku."""
        self.translated, self.manual = load("en_translated.json"), load("en_manual.json")
        self.base = load("en_original_base.json")
        self.all = load("en_all.json")
        self.previous = previous
        self.places = code_places()
        self.detect = polish_detector(self.all)
        # słownik, którego gra użyje dla napisu ze wstawki: bez naszych wcześniejszych nadpisań
        self.known = {pl: en for pl, en in self.all.items() if pl not in previous}
        self.known.update({pl: v for pl, v in self.base.items() if v is not None})
        self.known.update(self.translated)
        self.known.update(self.manual)
        self.result = dict(previous) if keep_previous else {}
        self.taken, self.nested, self.identity = {}, {}, set()
        self.stats = collections.Counter()

    def reject(self, reason):
        """Liczy odrzucenie z powodem i zwraca False."""
        self.stats[f"odrzucone: {reason}"] += 1
        return False

    def accept(self, pl, en, source, current):
        """source: "original" (kandydat), "auto" albo "fix" (tłumaczenie oceniającego)."""
        js = in_window(pl, self.places)
        if BAD_CHAR in en:
            return self.reject("błędny znak")
        if source != "fix":
            if setting_conflict(pl, current or "", en):
                return self.reject("stacja/MODsuit")
            if ep.PL_DIACRITICS.search(ep.strip_embeds(en)):
                return self.reject("kandydat po polsku")
            files = self.places.get(pl, ())
            if len(files) >= 2 and len(lm.WORD.findall(ep.strip_embeds(pl).lower())) <= SHARED_SHORT_WORDS:
                return self.reject("krótki tekst w kilku plikach")
            if end_mark(pl) and end_mark(pl) != end_mark(en):
                return self.reject("inny znak na końcu (etykieta, wielokropek)")
        if en == pl and source == "fix":
            self.identity.add(pl)
        else:
            en = rewrap(pl, en)
        en = OLD_LINK.sub(r"\1\2byond://?", en)
        if js and DM_MACRO.search(en):
            return self.reject("makro DM w tekście okna")
        pairs = []
        if js:
            if same_embeds(pl, en, js=True) and len(JS_EMBED.findall(en)) == len(JS_EMBED.findall(pl)):
                en = jsx_runs.with_pl_exprs(en, pl)
        else:
            en, pairs = align_dm_embeds(pl, en)
        if not same_embeds(pl, en, js=js):
            return self.reject("inne wstawki")
        if spans_balanced(pl) and not spans_balanced(en):
            return self.reject("niezamknięty span")
        if not builds(pl, en, js):
            return self.reject("build_chat_dict nie zrobi szablonu")
        nested = {}
        for p, e in pairs:
            known = self.known.get(p)
            if known is not None and known != e:
                # znany napis wstawki złożyłby się z nowym szablonem w inne zdanie niż oryginał
                return self.reject("konflikt napisu we wstawce")
            if known is None and self.detect(p) and e.strip():
                nested[p] = e
        self.result[pl] = en
        self.nested[pl] = nested
        if source == "original":
            self.taken[pl] = None
        else:
            self.taken.pop(pl, None)
        self.stats[{"original": "oryginał", "auto": "od razu", "fix": "poprawka"}[source]] += 1
        return True

    def revoke(self, pl):
        """Cofa oryginał przyjęty we wcześniejszej rundzie razem z napisami jego wstawek."""
        self.result.pop(pl, None)
        self.nested.pop(pl, None)
        self.identity.discard(pl)
        self.taken.pop(pl, None)
        self.stats["cofnięte"] += 1

    def apply_round(self, folder):
        """Stosuje auto.json i ocenione paczki jednej rundy."""
        auto_path = os.path.join(folder, "auto.json")
        if os.path.exists(auto_path):
            for pl, en in json.load(open(auto_path, encoding="utf-8")).items():
                self.accept(pl, en, "auto", self.translated.get(pl) or self.known.get(pl))
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
                pl, v = item["pl"], verdicts.get(item["id"])
                if v == "original" and item["original"]:
                    if self.accept(pl, item["original"], "original", item["current"]):
                        self.taken[pl] = item["original"]
                elif isinstance(v, dict) and isinstance(v.get("fix"), str):
                    self.accept(pl, v["fix"], "fix", item["current"])
                elif v == "current" and item["original"] and self.taken.get(pl) == item["original"]:
                    # późniejsza runda (np. druga opinia) cofa oryginał przyjęty z tego samego kandydata
                    self.revoke(pl)
                else:
                    self.stats["bez zmian" if v == "current" else "brak decyzji"] += 1

    def apply_name_maps(self):
        """Mapy nazw do wyświetlania (fryzury, wyposażenie): klucz to prawdziwa angielska nazwa z danych
        gry. Para trafia do słownika tylko wtedy, gdy polska nazwa jest w mapach jedna i nie występuje
        w kodzie poza mapami ("Brak" to też "None" w setkach komunikatów, a w mapie bielizny "Nude")."""
        pairs = []
        for path in NAME_MAPS:
            if os.path.exists(path):
                pairs += NAME_MAP_PAIR.findall(open(path, encoding="utf-8").read())
        english = collections.defaultdict(set)
        for en, pl in pairs:
            english[pl].add(en)
        for pl, ens in english.items():
            if len(ens) != 1 or self.places.get(pl, set()) - set(NAME_MAPS):
                self.stats["mapa nazw: pominięta (kilka nazw albo słowo spoza mapy)"] += 1
                continue
            en = next(iter(ens))
            # wpis tylko wtedy, gdy coś zmienia albo nadpisuje inny wynik rundy dla tej nazwy
            if en != pl and (pl in self.result or self.known.get(pl) != en):
                self.result[pl] = en
                self.nested.pop(pl, None)
                self.taken.pop(pl, None)
                self.stats["z mapy nazw"] += 1

    def finish(self, base_ref):
        """Wynik i wartości bazowe: napisy wstawek, filtr pustych wpisów, przywrócenie usuniętych par."""
        for pl, nested in list(self.nested.items()):
            if pl not in self.result:
                continue
            for p, e in nested.items():
                if p not in self.result and p not in self.manual:
                    self.result[p] = e
        result = {pl: en for pl, en in self.result.items()
                  if pl in self.identity or (pl != en and en.strip())}
        # wartość sprzed nadpisania: z en_original_base.json, a dla starszych wpisów z en_all.json w base_ref
        ref = None
        base = dict(self.base)
        for pl in set(result) | set(self.previous):
            if pl in base:
                continue
            if pl in self.previous:
                if ref is None:
                    ref = git_json(base_ref)
                base[pl] = ref.get(pl)
            else:
                base[pl] = self.all.get(pl)
        # para usunięta z en_original.json: bez wpisu en_all.json zostawiłby nasze nadpisanie na zawsze
        restored = 0
        for pl in set(self.previous) - set(result):
            if pl in self.manual or pl in self.translated:
                continue  # build_chat_dict nakłada je na bazę i tak
            value = base.get(pl)
            result[pl] = value if value is not None else pl
            restored += 1
        self.stats["przywrócone"] = restored
        return result, {pl: base.get(pl) for pl in sorted(result)}


def git_json(spec):
    """Plik JSON z gita ("aq33/master:strings/i18n/en_all.json") albo z dysku."""
    if os.path.exists(spec):
        data = json.load(open(spec, encoding="utf-8"))
    else:
        data = json.loads(subprocess.run(["git", "show", spec], capture_output=True, check=True).stdout.decode("utf-8"))
    data.pop("_komentarz", None)
    return data


def apply(args):
    """Scala ocenione rundy w en_original.json i en_original_base.json."""
    previous = load("en_original.json")
    merger = Merger(previous, args.keep_previous)
    for folder in args.dirs:  # rundy po kolei: późniejsza ocena tego samego tekstu wygrywa
        merger.apply_round(folder)
    merger.apply_name_maps()
    result, base = merger.finish(args.base_ref)
    result["_komentarz"] = ("Oryginały portów zamiast tłumaczeń zwrotnych i poprawki złych par z historii. "
                            "Generuje tools/i18n/match_originals.py apply; build_chat_dict.py nakłada go "
                            "na en_translated.json. Ręczne poprawki: en_manual.json.")
    write_json(I18N + "en_original.json", dict(sorted(result.items())))
    base["_komentarz"] = ("Wartość słownika sprzed nadpisania przez en_original.json (null: klucza nie było). "
                          "match_originals.py apply przywraca ją, gdy para znika z en_original.json.")
    write_json(I18N + "en_original_base.json", base)
    print(f"{dict(merger.stats)}; razem w en_original.json: {len(result) - 1}")


def glob_packs(folder):
    """Paczki paczka_NN.jsonl katalogu rundy, po kolei."""
    return sorted(glob.glob(os.path.join(folder, "paczka_[0-9]*.jsonl")))


# ---------------------------------------------------------------- historia innych serwerów
#
# Klony bez dużych plików (git clone --bare --filter=blob:limit=400k): kod jest cały, ikon i dźwięków
# nie ma. Git uruchamiamy z --no-lazy-fetch, żeby brakujący duży plik nie był dociągany z sieci.

CODE_DIRS = ("code", "modular_", "monkestation", "yogstation", "goon", "nsv13", "tgui", "_std", "strings")
HIST_EXT = ep.CODE_EXT
MAX_LINE = 20000
MAX_BLOB = 400 * 1024
# zbudowane bundle TGUI (tg i Bee commitowały je latami) są duże i nie ma ich w klonie bez dużych plików
HIST_EXCLUDE = [":(exclude)tgui/public/**", ":(exclude)**/*.bundle.*", ":(exclude)**/node_modules/**",
                ":(exclude).yarn/**", ":(exclude)**/*.min.js", ":(exclude)**/public/*.js"]


def git_lines(repo, *args, check=True):
    """Linie wyjścia gita. Błąd gita przerywa (check=True), żeby niepełny wynik nie udawał pełnego."""
    # stderr do pliku: ostrzeżenia o brakujących plikach potrafią zapchać potok i zakleszczyć odczyt stdout
    with tempfile.TemporaryFile() as err:
        proc = subprocess.Popen(["git", "--no-lazy-fetch", "-C", repo, *args], stdout=subprocess.PIPE, stderr=err)
        for raw in proc.stdout:
            yield raw.decode("utf-8", "replace").rstrip("\n").rstrip("\r")
        if proc.wait() != 0:
            err.seek(0)
            message = f"git w {repo} ({args[0]}): {err.read().decode('utf-8', 'replace').strip()[-300:]}"
            if check:
                raise RuntimeError(message)
            print(f"BŁĄD {message}", file=sys.stderr)


def read_blobs(repo, shas):
    """{sha: bajty} przez jedno git cat-file --batch; brakujące (za duże dla klonu) pomija."""
    shas = list(dict.fromkeys(shas))
    proc = subprocess.Popen(["git", "--no-lazy-fetch", "-C", repo, "cat-file", "--batch"],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    # wejście w osobnym wątku: przy zapisie wszystkiego naraz git czeka, aż odbierzemy wyjście (zakleszczenie)
    def feed():
        """Wysyła listę skrótów do git cat-file --batch."""
        proc.stdin.write("".join(f"{sha}\n" for sha in shas).encode())
        proc.stdin.close()
    threading.Thread(target=feed, daemon=True).start()
    out = {}
    for sha in shas:
        header = proc.stdout.readline().decode().split()
        if len(header) < 3 or header[1] == "missing":
            continue
        out[sha] = proc.stdout.read(int(header[2]))
        proc.stdout.read(1)
    proc.wait()
    return out


def missing_paths(repo, pathspecs):
    """Pliki, których któraś wersja jest za duża dla klonu (np. stare tgui/assets/tgui.js): log -p by na nich padł."""
    shas = collections.defaultdict(set)
    for line in git_lines(repo, "log", "--raw", "--no-abbrev", "--no-merges", "--no-renames", "--format=", "HEAD",
                          "--", *pathspecs):
        if not line.startswith(":"):
            continue
        meta, _, p = line.partition("\t")
        for sha in meta.split()[2:4]:
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
    """Czy literał z historii nadaje się na angielskiego kandydata."""
    return (ep.wordy(lit) and not ep.PL_DIACRITICS.search(lit) and BAD_CHAR not in lit and len(lit) <= 3000
            and re.search(r"[A-Za-z]{3}", ep.strip_embeds(lit)))


def literals(args):
    """Wszystkie angielskie literały, jakie kiedykolwiek dodano w historii repozytorium."""
    os.makedirs(args.out, exist_ok=True)
    for spec in args.repo:
        label, repo = spec.split("=", 1)
        seen, path, added = {}, None, []

        def flush():
            """Zbiera literały z dodanych linii bieżącego hunka."""
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
        done, mark = 0, 0
        for line in git_lines(repo, "log", "-p", "--no-merges", "--no-renames", "-U0", "--format=%x01",
                              "HEAD", "--", *pathspecs):
            done += len(line)
            if done - mark > 200 * 1024 * 1024:
                mark = done
                print(f"  {label}: {done >> 20} MB diffów, literałów: {len(seen)}", file=sys.stderr, flush=True)
            if line.startswith("diff --git "):
                flush()
                path = line.split(" b/", 1)[-1]
            elif line.startswith("@@") or line == "\x01":
                flush()
            elif line.startswith("+") and not line.startswith("+++ b/") and len(line) <= MAX_LINE:
                # gigantyczne linie (dane, zminifikowany kod) parser znak po znaku mieli bardzo długo,
                # a tak długich literałów i tak nie bierzemy
                added.append(line[1:])
        flush()
        out = os.path.join(args.out, f"{label}.jsonl")
        with open(out, "w", encoding="utf-8", newline="\n") as f:
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
                # północ, nie bieżąca godzina; główna linia historii, nie commit z gałęzi scalonej później
                revs = list(git_lines(repo, "rev-list", "-1", "--first-parent",
                                      f"--before={year}-{month}-01T00:00:00", "HEAD"))
                if not revs or revs[0] in done:
                    continue
                rev = revs[0]
                done.add(rev)
                dest = os.path.join(args.out, f"{label}@{year}-{month}")
                if os.path.isdir(dest):
                    continue
                blobs = []
                for line in git_lines(repo, "ls-tree", "-r", "-l", rev):
                    meta, _, p = line.partition("\t")
                    parts = meta.split()
                    if len(parts) < 4 or parts[1] != "blob" or not p.endswith(HIST_EXT) or not p.startswith(CODE_DIRS):
                        continue
                    # rozmiar "BAD" = pliku nie ma w klonie (za duży)
                    if parts[3].isdigit() and int(parts[3]) <= MAX_BLOB:
                        blobs.append((parts[2], p))
                # do katalogu tymczasowego: przerwany zapis nie zostawia wersji, którą następne
                # uruchomienie wzięłoby za pełną
                tmp = dest + ".tmp"
                shutil.rmtree(tmp, ignore_errors=True)
                os.makedirs(tmp)
                data = read_blobs(repo, [sha for sha, _ in blobs])
                for sha, p in blobs:
                    if sha in data:
                        full = os.path.join(tmp, p)
                        os.makedirs(os.path.dirname(full), exist_ok=True)
                        with open(full, "wb") as f:
                            f.write(data[sha])
                os.replace(tmp, dest)
                print(f"{label}@{year}-{month}: {len(data)} z {len(blobs)} plików", file=sys.stderr)


def prheads(args):
    """Pary z commitów na gałęziach PR-ów naszego repo, których nie ma w masterze (squash je zgubił).
    Port bywał najpierw skopiowany po angielsku i tłumaczony osobnym commitem: to dokładny oryginał
    w tym samym miejscu kodu. Klon: git clone --bare ... && git fetch origin '+refs/pull/*/head:refs/pull/*'"""
    merged = load("en_all.json")
    targets = open_targets(merged)
    sink = collections.defaultdict(collections.Counter)
    source = collections.defaultdict(set)
    commit, count = [], 0
    # jeden log -p zamiast git show na commit; słowniki strings/i18n są duże (brak w klonie), a i tak
    # odrzuca je SKIP_PATH
    for line in git_lines(args.repo, "log", "-p", "-U0", "--no-renames", "--no-merges", "--format=%x01",
                          "--all", "--not", "HEAD", "--", *ep.PATHSPECS, ":(exclude)strings/i18n/**"):
        if line == "\x01":
            ep.pairs_from_diff("\n".join(commit), source, sink)
            commit, count = [], count + 1
        else:
            commit.append(line)
    ep.pairs_from_diff("\n".join(commit), source, sink)
    best = {}
    for pl, ens in sink.items():
        if pl not in targets or pl not in merged:
            continue
        en = ens.most_common(1)[0][0]
        if en != merged[pl]:
            best[pl] = {"pl": pl, "current": merged[pl], "original": en, "score": similarity(merged[pl], en),
                        "kind": "pr", "tree": "aquila-pr", "source": sorted(source[pl])[0], "why": targets[pl]}
    write_candidates(args.out, best)
    print(f"commitów: {count}, par z gałęzi PR: {len(sink)}, kandydatów dla celów: {len(best)}")


def walk_json(ours, theirs, out):
    """Pary (nasz napis, ich napis) z tej samej ścieżki kluczy; listy tylko przy tej samej długości."""
    if isinstance(ours, str) and isinstance(theirs, str):
        out.append((ours, theirs))
    elif isinstance(ours, dict) and isinstance(theirs, dict):
        for key, val in ours.items():
            if key in theirs:
                walk_json(val, theirs[key], out)
    elif isinstance(ours, list) and isinstance(theirs, list) and len(ours) == len(theirs):
        for a, b in zip(ours, theirs):
            walk_json(a, b, out)


def jsonfiles(args):
    """Pliki strings/*.json: ten sam plik w każdej wersji historii innego serwera, pary po ścieżce kluczy."""
    merged = load("en_all.json")
    targets = open_targets(merged)
    ours, raw_of = {}, {}
    for path in code_files(["strings/*.json"]):
        try:
            data = json.load(open(path, encoding="utf-8"))
        except (OSError, ValueError):
            continue
        # literał w słowniku to zapis z pliku (z ucieczkami JSON-a); wartość po wczytaniu -> ten zapis
        raws = {}
        for line in open(path, encoding="utf-8"):
            for lit in ep.literals(path, line):
                if lit in targets:
                    try:
                        raws[json.loads(f'"{lit}"')] = lit
                    except ValueError:
                        pass
        if raws:
            ours[path], raw_of[path] = data, raws
    best = {}
    for spec in args.repo:
        label, repo = spec.split("=", 1)
        versions = collections.defaultdict(set)  # ścieżka -> blob każdej wersji (jeden log na repo)
        for line in git_lines(repo, "log", "--raw", "--no-abbrev", "--no-renames", "--format=", "HEAD", "--", *ours):
            if line.startswith(":"):
                meta, _, p = line.partition("\t")
                sha = meta.split()[3]
                if set(sha) != {"0"}:
                    versions[p].add(sha)
        blobs = read_blobs(repo, [sha for shas in versions.values() for sha in shas])
        for path, shas in versions.items():
            for sha in shas:
                try:
                    theirs = json.loads(blobs[sha].decode("utf-8"))
                except (KeyError, ValueError):
                    continue
                pairs = []
                walk_json(ours[path], theirs, pairs)
                for pl_val, en_val in pairs:
                    pl = raw_of[path].get(pl_val)
                    if not pl or pl not in merged or en_val == pl_val or ep.PL_DIACRITICS.search(en_val):
                        continue
                    en = json.dumps(en_val, ensure_ascii=False)[1:-1]
                    if same_embeds(pl, en, js=False):
                        offer(best, {"pl": pl, "current": merged[pl], "original": en,
                                     "score": similarity(merged[pl], en), "kind": "var", "tree": label,
                                     "source": f"{sha[:10]}:{path}", "why": targets[pl]})
        print(f"  {label}: kandydatów razem {len(best)}", file=sys.stderr)
    write_candidates(args.out, best)
    print(f"kandydatów z plików JSON: {len(best)}")


STOP = set("the and you your for with that this are not but can its into from have has was will".split())


def global_match(args):
    """Dopasowanie po treści: literał z historii innych serwerów z tymi samymi wstawkami co polski tekst
    i podobny do obecnego angielskiego. Teksty do dwóch słów pomijamy: bez miejsca w kodzie każdy
    krótki literał pasuje do wielu kontekstów."""
    merged = load("en_all.json")
    targets = open_targets(merged)
    places = code_places()
    info, index = {}, collections.defaultdict(list)
    for pl in targets:
        cur = merged.get(pl)
        ws = {w for w in words(cur or "") if len(w) > 2 and w not in STOP}
        if not cur or len(ws) <= 2:
            continue
        info[pl] = (cur, embed_shape(pl), ws, letters_only(cur), in_window(pl, places))
        for w in ws:
            index[w].append(pl)
    common = {w for w, pls in index.items() if len(pls) > args.max_df}
    best = {}
    for path in sorted(glob.glob(os.path.join(args.literals, "*.jsonl"))):
        label = os.path.basename(path)[:-len(".jsonl")]
        n = 0
        for line in open(path, encoding="utf-8"):
            lit, src = json.loads(line)
            n += 1
            if BAD_CHAR in lit:
                continue
            lw = {w for w in words(lit) if len(w) > 2 and w not in STOP}
            cands = set()
            for w in lw - common:
                cands.update(index.get(w, ()))
            key = letters_only(lit)
            for pl in cands:
                cur, shape, tw, letters, js = info[pl]
                if len(tw & lw) * 2 < len(tw) or lit == cur or (js and DM_MACRO.search(lit)):
                    continue
                if embed_shape(lit, js) != shape:
                    continue
                sim = 1.0 if key == letters else similarity(cur, lit)
                if sim >= args.min_score:
                    offer(best, {"pl": pl, "current": cur, "original": lit, "score": sim, "kind": "global",
                                 "tree": label, "source": src, "why": targets[pl]})
        print(f"  {label}: {n} literałów, kandydatów razem: {len(best)}", file=sys.stderr)
    write_candidates(args.out, best)
    print(f"kandydatów po treści: {len(best)}; według drzewa: {collections.Counter(x['tree'] for x in best.values())}")


def main():
    """Wiersz poleceń: podkomendy find, literals, snapshots, prheads, jsonfiles, global, split, apply."""
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("find")
    p.set_defaults(func=find)
    p.add_argument("--tree", action="append", default=[], help="etykieta=katalog z kodem serwera")
    p.add_argument("--out", default=I18N + "en_pairs_original.jsonl")
    p.add_argument("--tgui-only", action="store_true", help="tylko teksty okien (bez indeksu DM, szybko)")
    for name, func in (("literals", literals), ("snapshots", snapshots), ("jsonfiles", jsonfiles)):
        p = sub.add_parser(name)
        p.set_defaults(func=func)
        p.add_argument("--repo", action="append", default=[], help="etykieta=klon bare z historią")
        if name == "jsonfiles":
            p.add_argument("--out", default=I18N + "en_pairs_original_json.jsonl")
        else:
            p.add_argument("--out", required=True, help="katalog wyniku")
        if name == "snapshots":
            p.add_argument("--since", type=int, default=2021)
            p.add_argument("--until", type=int, default=2026)
    p = sub.add_parser("prheads")
    p.set_defaults(func=prheads)
    p.add_argument("--repo", required=True, help="klon bare naszego repo z refs/pull/*")
    p.add_argument("--out", default=I18N + "en_pairs_original_pr.jsonl")
    p = sub.add_parser("global")
    p.set_defaults(func=global_match)
    p.add_argument("--literals", required=True, help="katalog z wynikiem literals")
    p.add_argument("--out", default=I18N + "en_pairs_original_global.jsonl")
    p.add_argument("--min-score", type=float, default=0.5)
    p.add_argument("--max-df", type=int, default=400, help="słowa częstsze w celach nie wybierają kandydatów")
    p = sub.add_parser("split")
    p.set_defaults(func=split)
    p.add_argument("dir")
    p.add_argument("--candidates", nargs="+", default=[I18N + "en_pairs_original.jsonl"])
    p.add_argument("--previous", nargs="*", default=[], help="katalogi wcześniejszych rund oceny")
    p.add_argument("--packs", type=int, default=PACKS)
    p.add_argument("--auto-only", action="store_true",
                   help="przelicz tylko auto.json rundy (paczki i werdykty zostają bez zmian)")
    p = sub.add_parser("apply")
    p.set_defaults(func=apply)
    p.add_argument("dirs", nargs="+", help="katalogi rund oceny, od najstarszej")
    p.add_argument("--keep-previous", action="store_true",
                   help="zachowaj pary z obecnego en_original.json (gdy nie podajesz katalogów starszych rund)")
    p.add_argument("--base-ref", default="aq33/master:strings/i18n/en_all.json",
                   help="słownik sprzed pierwszego en_original.json, dla wpisów bez en_original_base.json")
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
