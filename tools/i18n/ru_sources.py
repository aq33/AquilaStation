"""Gotowe rosyjskie tłumaczenia z innych serwerów dla wersji rosyjskiej (strings/i18n/ru_original.json).

Rosyjskie serwery tłumaczą kod w miejscu. Plik po pliku porównujemy fork z jego angielskim
upstreamem (linie o tym samym szkielecie kodu, literał na tej samej pozycji = para EN -> RU),
do tego słowniki TOML BandaStation (nazwy, emotki, reagenty), SS14 Corvax (Fluent + prototypy)
i nazwy przedmiotów po ścieżce typu. Nasz angielski tekst (en_all.json) wskazuje parę.

    python tools/i18n/ru_sources.py collect [--clones %TEMP%/ru]
    python tools/i18n/ru_sources.py apply

collect potrzebuje klonów (sparse, tylko kod) w katalogu --clones; nazwy katalogów jak w FORKS
i UPSTREAMS. Klony robić tak (Git Bash, bez MSYS_NO_PATHCONV ścieżki psują się):
    MSYS_NO_PATHCONV=1 git clone --depth 1 --filter=blob:none --sparse https://github.com/<repo> <katalog>
    cd <katalog> && MSYS_NO_PATHCONV=1 git sparse-checkout set --no-cone '/code/' '/modular_*/'
Upstream NSV13 (up_nsv13) to `git archive nsv13up/master code nsv13`.

apply zapisuje kandydatów (ru_candidates.json w katalogu klonów): polski literał -> tekst
z rosyjskiego serwera. Nie trafiają wprost do słownika, bo bywają złą parą (inny tekst o tym
samym angielskim brzmieniu, stacja zamiast statku, zmiany Aquili, ich wstawki declent_ru()):
tłumacz (tools/i18n/ru_translate.py) zatwierdza kandydata albo pisze własne tłumaczenie.
"safe": tekst bez wstawek po obu stronach, gotowy do zatwierdzenia bez przeróbek.
Licencje: kod serwerów jest na AGPL-3.0 jak nasz, SS14 Corvax na MIT.
"""

import argparse
import difflib
import json
import os
import re
import sys
import tempfile
import tomllib
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402

CYR = re.compile(r"[А-Яа-яЁё]")
EXT = (".dm", ".tsx", ".jsx", ".ts", ".js")
EMBED = re.compile(r"\[[^\[\]]*\]|\$\{")
TAG = re.compile(r"<[^<>]+>")
OUTER_SPAN = re.compile(r"^(<span\b[^>]*>)(.*)</span>(\s*(?:\\n)?\s*)$", re.S)

# katalog forka -> katalogi angielskich upstreamów (w kolejności)
FORKS = {
    "BandaStation": ["up_tgstation", "up_nsv13"],
    "Paradise": ["up_Paradise", "up_nsv13"],
    "REBOLUTION228-a11_white": ["up_tgstation", "up_nsv13"],
    "BlueMoon-Labs_BlueMoon-Station": ["up_S.P.L.U.R.T-Station-13", "up_nsv13"],
    "Falls-dev_TGMC-SS13": ["up_TerraGov-Marine-Corps"],
    "SierraBay_SierraBay12": ["up_Baystation12"],
    "infinitystation_Baystation12": ["up_Baystation12"],
    "TauCetiStation_TauCetiClassic": ["up_Baystation12", "up_nsv13"],
}
# domyślny katalog klonów i kandydatów (ten sam w tools/i18n/ru_translate.py)
DEFAULT_CLONES = os.path.join(os.environ.get("TEMP") or tempfile.gettempdir(), "ru")
CACHE = "ru_pairs_cache.json"
CANDIDATES = "ru_candidates.json"


def read_lines(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            return f.read().split("\n")
    except OSError:
        return None


def code_files(root):
    for d, _, fs in os.walk(root):
        if "node_modules" in d or ".git" in d:
            continue
        for f in fs:
            if f.endswith(EXT):
                yield os.path.relpath(os.path.join(d, f), root).replace("\\", "/")


def align(up_root, fork_root, votes):
    """Pary EN -> RU z linii o tym samym szkielecie w tym samym pliku."""
    up_files = set(code_files(up_root))
    for rel in code_files(fork_root):
        if rel not in up_files:
            continue
        fork = read_lines(os.path.join(fork_root, rel))
        if not fork or not any(CYR.search(x) for x in fork):
            continue
        up = ep.logical_lines(rel, read_lines(os.path.join(up_root, rel)))
        fork = ep.logical_lines(rel, fork)
        matcher = difflib.SequenceMatcher(None, [ep.skeleton(rel, x) for x in up],
                                          [ep.skeleton(rel, x) for x in fork], autojunk=False)
        for tag, i1, i2, j1, j2 in matcher.get_opcodes():
            if tag != "equal":
                continue
            for k in range(i2 - i1):
                a, b = up[i1 + k], fork[j1 + k]
                if a == b or not CYR.search(b):
                    continue
                la, lb = ep.literals(rel, a), ep.literals(rel, b)
                if len(la) != len(lb):
                    continue
                for en, ru in zip(la, lb):
                    if en != ru and CYR.search(ru) and not CYR.search(en) and ep.wordy(en):
                        votes[en][ru] += 1


def banda_tomls(base, votes):
    pub = os.path.join(base, "BandaStation", "modular_bandastation", "translations", "public")
    if not os.path.isdir(pub):
        return
    names = os.path.join(pub, "ru_names")
    for f in os.listdir(names):
        with open(os.path.join(names, f), "rb") as h:
            try:
                data = tomllib.load(h)
            except tomllib.TOMLDecodeError:
                continue
        for en, forms in data.items():
            if isinstance(forms, dict) and forms.get("nominative"):
                votes[en][forms["nominative"]] += 5

    def walk(d):
        for k, v in d.items():
            if isinstance(v, dict):
                walk(v)
            elif isinstance(v, str) and CYR.search(v):
                votes[k][v] += 5

    for name in ("ru_emotes.toml", "ru_reagents.toml", "ru_verbs.toml"):
        path = os.path.join(pub, name)
        if os.path.exists(path):
            with open(path, "rb") as h:
                walk(tomllib.load(h))


def fluent(path):
    out, key = {}, None
    with open(path, encoding="utf-8-sig", errors="replace") as f:
        for raw in f:
            line = raw.rstrip("\n")
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            m = re.match(r"^([A-Za-z][\w-]*)\s*=\s*(.*)$", line)
            if m:
                key = m.group(1)
                out[key] = m.group(2).strip()
                continue
            m = re.match(r"^\s+\.([\w-]+)\s*=\s*(.*)$", line)
            if m and key:
                out[f"{key}.{m.group(1)}"] = m.group(2).strip()
                continue
            if key and line.startswith((" ", "\t")) and out:
                last = list(out)[-1]
                out[last] = (out[last] + " " + line.strip()).strip()
    return out


def corvax(base, votes):
    """SS14 Corvax: te same klucze Fluent w en-US i ru-RU, nazwy i opisy prototypów."""
    res = os.path.join(base, "corvax", "Resources")
    if not os.path.isdir(res):
        return

    def tree(root):
        data = {}
        for d, _, fs in os.walk(root):
            for f in fs:
                if f.endswith(".ftl"):
                    data.update(fluent(os.path.join(d, f)))
        return data

    en, ru = tree(os.path.join(res, "Locale", "en-US")), tree(os.path.join(res, "Locale", "ru-RU"))
    for k, v in en.items():
        r = ru.get(k)
        if r and CYR.search(r) and v and not CYR.search(v) and "{" not in v:
            votes[v][r] += 1
    for d, _, fs in os.walk(os.path.join(res, "Prototypes")):
        for f in fs:
            if not f.endswith(".yml"):
                continue
            cur = {}
            for line in open(os.path.join(d, f), encoding="utf-8", errors="replace"):
                if re.match(r"^- type:", line):
                    cur = {}
                    continue
                m = re.match(r"^  (id|name|description):\s*(.*)$", line)
                if not m:
                    continue
                cur[m.group(1)] = m.group(2).strip().strip("\"'")
                pid = cur.get("id")
                if not pid:
                    continue
                for field, key in (("name", f"ent-{pid}"), ("description", f"ent-{pid}.desc")):
                    r = ru.get(key)
                    if cur.get(field) and r and CYR.search(r) and "{" not in r:
                        votes[cur[field]][r] += 1


TYPE_LINE = re.compile(r"^(/[\w/]+)\s*$")
VAR_LINE = re.compile(r"^\t(?:var/)?(name|desc)\s*=\s*\"(.*)\"\s*(?://.*)?$")


def type_vars(root, want):
    """(znormalizowana ścieżka typu, zmienna) -> literał dla definicji typów pełną ścieżką."""
    out = {}
    for d, _, fs in os.walk(root):
        if ".git" in d or "node_modules" in d:
            continue
        for f in fs:
            if not f.endswith(".dm"):
                continue
            current = None
            for line in read_lines(os.path.join(d, f)) or []:
                line = line.rstrip("\r")
                m = TYPE_LINE.match(line)
                if m and "/proc/" not in m.group(1) and "/verb/" not in m.group(1):
                    current = re.sub(r"/+", "/", m.group(1).lower().replace("/weapon/", "/"))
                    continue
                if line and not line[0].isspace():
                    current = None
                    continue
                if current:
                    m = VAR_LINE.match(line)
                    if m and want(m.group(2)):
                        out[(current, m.group(1))] = m.group(2)
    return out


def collect(args):
    base = args.clones
    en_votes = defaultdict(Counter)
    for fork, ups in FORKS.items():
        fork_root = os.path.join(base, fork)
        if not os.path.isdir(fork_root):
            print("brak klonu:", fork)
            continue
        before = len(en_votes)
        for up in ups:
            if os.path.isdir(os.path.join(base, up)):
                align(os.path.join(base, up), fork_root, en_votes)
        print(fork, "nowych tekstów EN:", len(en_votes) - before, flush=True)
    banda_tomls(base, en_votes)
    corvax(base, en_votes)
    en_all = json.load(open("strings/i18n/en_all.json", encoding="utf-8"))
    ours = {}
    for root in ("code", "nsv13", "aquila"):
        ours.update(type_vars(root, lambda s: s in en_all))
    pl_votes = defaultdict(Counter)
    for fork in FORKS:
        theirs = type_vars(os.path.join(base, fork), lambda s: bool(CYR.search(s)))
        for key, pl in ours.items():
            ru = theirs.get(key)
            if ru:
                pl_votes[pl][(ru, key[1])] += 1
    cache = {
        "en": {en: c.most_common(1)[0][0] for en, c in en_votes.items()},
        "pl": {pl: list(c.most_common(1)[0][0]) for pl, c in pl_votes.items()},
    }
    with open(os.path.join(base, CACHE), "w", encoding="utf-8") as f:
        json.dump(cache, f, ensure_ascii=False)
    print("par EN -> RU:", len(cache["en"]), "par PL -> RU po typie:", len(cache["pl"]))


def norm(text):
    text = TAG.sub("", EMBED.sub("[]", text))
    text = re.sub(r"\\[nt]", " ", text)
    return re.sub(r"\s+", " ", text).strip().lower()


def match_case(source, ru):
    """Wielka albo mała pierwsza litera jak w naszym tekście."""
    if not source or not ru:
        return ru
    first = source.lstrip("<")[:1]
    if first.isupper():
        return ru[:1].upper() + ru[1:]
    if first.islower():
        return ru[:1].lower() + ru[1:]
    return ru


def rewrap(pl, ru):
    """Zewnętrzny <span class=...> i końcowe \\n jak w polskim literale (rosyjskie serwery owijają gdzie indziej)."""
    inner = TAG.sub("", ru).strip() if TAG.search(ru) and not TAG.search(pl) else ru
    m = OUTER_SPAN.match(pl)
    if m and not OUTER_SPAN.match(inner):
        return m.group(1) + inner + "</span>" + m.group(3)
    return inner


def plain_inner(text):
    m = OUTER_SPAN.match(text)
    return m.group(2) if m else text


def apply(args):
    base = args.clones
    cache = json.load(open(os.path.join(base, CACHE), encoding="utf-8"))
    en_all = json.load(open("strings/i18n/en_all.json", encoding="utf-8"))
    index = {}
    for en, ru in cache["en"].items():
        index.setdefault(norm(en), ru)
    out = {}
    for pl, en in en_all.items():
        if not isinstance(en, str):
            continue
        ru = index.get(norm(en))
        if ru:
            safe = not EMBED.search(pl) and not EMBED.search(en) and not EMBED.search(ru)
            # tag w środku (<b>, <i>) po naszej stronie, którego oni nie mają: do przeróbki
            if safe and TAG.search(plain_inner(pl)) and not TAG.search(ru):
                safe = False
            if safe:
                ru = rewrap(pl, match_case(TAG.sub("", en).strip(), ru.strip()))
            out[pl] = {"ru": ru, "safe": safe}
            continue
        by_type = cache["pl"].get(pl)
        if by_type:
            ru, var = by_type
            safe = var == "name" and not EMBED.search(pl) and not EMBED.search(ru)
            out[pl] = {"ru": match_case(pl, ru.strip()) if safe else ru, "safe": safe}
    with open(os.path.join(base, CANDIDATES), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=0)
    safe = sum(1 for v in out.values() if v["safe"])
    print(f"kandydaci: {len(out)}, w tym gotowych do zatwierdzenia: {safe}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["collect", "apply"])
    ap.add_argument("--clones", default=DEFAULT_CLONES)
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    {"collect": collect, "apply": apply}[args.command](args)


if __name__ == "__main__":
    main()
