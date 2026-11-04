"""Buduje słownik czatu PL -> EN dla panelu tgui z en_pairs.json.

Literał DM z osadzeniami ("[user] uderza [target]!") staje się szablonem: stałe
fragmenty do dopasowania w HTML wiadomości i numery osadzeń. Angielska strona
wskazuje, które przechwycone wartości wstawić i gdzie. Panel (tgui-panel/chat/i18n.ts)
dopasowuje szablony do przychodzących wiadomości.

Źródła (po kolei, późniejsze wygrywają): en_pairs_upstream.json i en_pairs.json
(generowane, poza repo) albo en_all.json, potem en_translated.json i en_manual.json.
Zapisuje scalony en_all.json, który jest w repo.

Użycie (z katalogu repo, po extract_pairs.py):
    python tools/i18n/build_chat_dict.py [--slice code/_onclick code/modules/mob ...]

Ręczne pary dla pomocniczych procedur Aquili (strefa_pl, "Widzisz, jak ...") są
w strings/i18n/en_manual.json.

Wynik: strings/i18n/en_chat.json (klient) i strings/i18n/en_dm.json (krótkie stałe dla serwera)
"""

import argparse
import collections
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402
import list_missing as lm  # noqa: E402

# Domyślnie cały kod DM. --slice zawęża szablony do wybranych ścieżek (stałe teksty
# i tak idą ze wszystkich plików, bo są potrzebne jako wartości wstawek).
DEFAULT_SLICE = ["code/", "nsv13/", "aquila/", "goon/"]


# Makra tekstowe BYOND. \the i \a dają tekst, reszta znika.
ARTICLE_MACROS = {"the", "The", "a", "A", "an", "An"}
SILENT_MACROS = {"improper", "proper", "icon", "ref", "roman", "Roman", "th", "s",
                 "red", "blue", "green", "black", "b", "i", "u", "font", "bold", "italic"}
PRONOUN_MACROS = {"he", "He", "she", "She", "his", "His", "him", "himself", "herself", "hers"}

# Zaimki z angielskich szablonów, których polski odpowiednik nie ma (p_their() itd.).
# Liczba zależy od tego, czy szablon ma podmiot "they" (wtedy forma mnoga).
PRONOUNS_PLURAL = {"they": "they", "their": "their", "them": "them", "theirs": "theirs",
                   "themselves": "themselves", "s": "", "es": "", "are": "are", "were": "were",
                   "do": "do", "have": "have", "theyre": "they're", "is": "are", "has": "have",
                   "theyve": "they've", "dont": "don't"}
PRONOUNS_SINGULAR = dict(PRONOUNS_PLURAL, s="s", es="es", are="is", were="was", do="does",
                         have="has", theyre="they're", has="has", theyve="they've", dont="doesn't")
PRONOUN_CALL = re.compile(r"(?:^|\.)p_([a-z]+)\((TRUE|1)?\)$")


def parse_dm_literal(lit):
    """Zwraca listę części: ("t", tekst) albo ("e", wyrażenie) albo ("m", makro)."""
    parts, buf, i, n = [], [], 0, len(lit)

    def flush():
        if buf:
            parts.append(("t", "".join(buf)))
            buf.clear()

    while i < n:
        c = lit[i]
        if c == "\\" and i + 1 < n:
            nxt = lit[i + 1]
            m = re.match(r"[A-Za-z]+", lit[i + 1:])
            if m and m.group(0) not in ("n", "t"):
                flush()
                parts.append(("m", m.group(0)))
                i += 1 + len(m.group(0))
                continue
            buf.append({"n": "\n", "t": "\t"}.get(nxt, nxt))
            i += 2
            continue
        if c == "[":
            depth, j, in_str = 1, i + 1, False
            while j < n and depth:
                ch = lit[j]
                if ch == "\\":
                    j += 2
                    continue
                if ch == '"':
                    in_str = not in_str
                elif not in_str and ch == "[":
                    depth += 1
                elif not in_str and ch == "]":
                    depth -= 1
                j += 1
            flush()
            parts.append(("e", lit[i + 1:j - 1].strip()))
            i = j
            continue
        buf.append(c)
        i += 1
    flush()
    return parts


# najdłuższy tekst w słowniku dla serwera: dymki i runechat są krótkie
DM_MAX_LENGTH = 100
JS_EXT = (".tsx", ".jsx", ".ts", ".js")
JS_ESCAPES = {"n": "\n", "t": "\t", "r": "\r"}


def parse_js_literal(lit):
    """Literał JS: części ("t", tekst) i ("e", wyrażenie z ${...}), jak parse_dm_literal."""
    parts, buf, i, n = [], [], 0, len(lit)

    def flush():
        if buf:
            parts.append(("t", "".join(buf)))
            buf.clear()

    while i < n:
        c = lit[i]
        if c == "\\" and i + 1 < n:
            buf.append(JS_ESCAPES.get(lit[i + 1], lit[i + 1]))
            i += 2
            continue
        if c == "$" and lit.startswith("${", i):
            depth, j = 1, i + 2
            while j < n and depth:
                if lit[j] == "{":
                    depth += 1
                elif lit[j] == "}":
                    depth -= 1
                j += 1
            flush()
            parts.append(("e", lit[i + 2:j - 1].strip()))
            i = j
            continue
        buf.append(c)
        i += 1
    flush()
    return parts


def norm_expr(expr):
    e = re.sub(r"\s+", "", expr)
    # strefa ciała: nasze strefa_pl(...) odpowiada oryginałom parse_zone(...) i limb.name
    e = re.sub(r"^strefa_pl\((\w+)\.body_zone(?:,\w+)?\)$", r"\1.name", e)
    e = re.sub(r"^(?:strefa_pl|parse_zone)\(([^(),]+)(?:,\w+)?\)$", r"zone:\1", e)
    e = re.sub(r"^src\.", "", e)
    e = re.sub(r"\.name$", "", e)
    return e


def ternary_condition(expr):
    """Warunek wstawki [x ? "A" : "B"] (znormalizowany) albo None."""
    m = TERNARY.match(expr.strip())
    if not m:
        return None
    return re.sub(r"\s+", "", expr.strip().split("?", 1)[0])


AUTO_ARTICLE = re.compile(r"(^|[\s>(„\"'])[Tt]he (?=\S)")


def build_pl(parts):
    """Polski szablon: [tekst0, tekst1, ...] i lista wyrażeń między nimi. None = nie do użycia."""
    texts, exprs, cur = [], [], []
    for kind, val in parts:
        if kind == "t":
            cur.append(val)
        elif kind == "m":
            if val in ARTICLE_MACROS or val in PRONOUN_MACROS:
                if val in ("the", "The"):
                    continue  # strip_auto_articles i tak usuwa "the"
                return None
            # makro bez tekstu: zjada spację za sobą
        else:
            texts.append(AUTO_ARTICLE.sub(r"\1", "".join(cur)))
            exprs.append(val)
            cur = []
    texts.append(AUTO_ARTICLE.sub(r"\1", "".join(cur)))
    return texts, exprs


TERNARY = re.compile(r'^[^"]+\?\s*"((?:\\.|[^"\\])*)"\s*:\s*"((?:\\.|[^"\\])*)"$')


def unescape_dm(text):
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": "\t"}.get(m.group(1), m.group(1)), text)


def alternatives(exprs):
    """Wstawki-warunki z dwoma napisami ([harmful ? "wbija się" : "przykleja się"]): numer -> [A, B].

    W szablonie zamiast dowolnego tekstu dopasowujemy jedną z alternatyw. Daje to kotwicę
    i pewniejsze dopasowanie, a wartość i tak tłumaczy słownik stałych (napisy ze wstawek)."""
    found = {}
    for index, expr in enumerate(exprs):
        options = literal_ternary(expr)
        if options:
            found[str(index)] = options
    return found


def literal_ternary(expr):
    """[A, B] dla wstawki [x ? "A" : "B"] bez zagnieżdżonych wstawek, inaczej None."""
    m = TERNARY.match(expr.strip())
    if m and "[" not in m.group(1) and "[" not in m.group(2):
        return [unescape_dm(m.group(1)), unescape_dm(m.group(2))]
    return None


def build_en(parts, pl_exprs):
    """Angielska strona: lista elementów: tekst albo [nr osadzenia PL, przedimek]."""
    pl_index, pl_conditions = {}, {}
    for k, e in enumerate(pl_exprs):
        pl_index.setdefault(norm_expr(e), k)
        condition = ternary_condition(e)
        if condition and literal_ternary(e):
            pl_conditions.setdefault(condition, k)
    plural = any(PRONOUN_CALL.search(norm_expr(v)) and PRONOUN_CALL.search(norm_expr(v)).group(1) in ("they", "theyre", "theyve")
                 for kind, v in parts if kind == "e")
    pronouns = PRONOUNS_PLURAL if plural else PRONOUNS_SINGULAR
    out, article, missing = [], None, []

    def add_text(t):
        if out and isinstance(out[-1], str):
            out[-1] += t
        else:
            out.append(t)

    for kind, val in parts:
        if kind == "t":
            if article:  # "\The [x]": panel sam wstawia przedimek ze spacją
                val = val.lstrip(" ")
            if val:
                add_text(val)
        elif kind == "m":
            if val in ARTICLE_MACROS:
                article = val
            elif val in PRONOUN_MACROS:
                missing.append("\\" + val)
            # pozostałe makra bez tekstu pomijamy
        else:
            key = norm_expr(val)
            condition = ternary_condition(val)
            if key in pl_index:
                out.append([pl_index[key], article] if article else [pl_index[key]])
            elif condition in pl_conditions and "[" not in val:
                # angielski warunek z tym samym warunkiem co polska alternatywa: gałąź według tego,
                # która polska alternatywa wystąpiła (["?", nr wstawki PL, [EN dla A, EN dla B]])
                m = TERNARY.match(val.strip())
                out.append(["?", pl_conditions[condition], [unescape_dm(m.group(1)), unescape_dm(m.group(2))]])
            else:
                m = PRONOUN_CALL.search(key)
                if m and m.group(1) in pronouns:
                    word = pronouns[m.group(1)]
                    if m.group(2) and word:
                        word = word[0].upper() + word[1:]
                    add_text(word)
                else:
                    missing.append(val)
            article = None
    if article:  # \the na końcu bez osadzenia: zostaje jako tekst
        add_text(article)
    # makra zjadają spację: "\improper  nazwa" -> pojedyncze spacje
    out = [re.sub(r"  +", " ", x) if isinstance(x, str) else x for x in out]
    return out, missing


WORD = re.compile(r"[a-ząćęłńóśźż]{2,}", re.I)  # dwie litery: "ma", "na" bywają jedynym słowem szablonu
TAG = re.compile(r"<[^>]*>")


def load_json(path):
    if not path or not os.path.exists(path):
        return {}
    data = json.load(open(path, encoding="utf-8"))
    data.pop("_komentarz", None)
    return data


def load_sources(args):
    """Scala źródła i zapisuje en_all.json.

    Świeże en_pairs.json (+ oryginały portów) zastępują bazę; bez nich (brak historii
    albo klonów innych serwerów) bazą jest en_all.json z repo. Na wierzch idą
    tłumaczenia agentów/ręczne (en_translated.json), a na sam koniec en_manual.json.
    """
    if os.path.exists(args.pairs):
        merged = dict(load_json(args.upstream))
        merged.update(load_json(args.pairs))
    else:
        merged = load_json(args.all)
    merged.update(load_json(args.translated))
    merged.update(load_json(args.manual))
    with open(args.all, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(merged.items())), f, ensure_ascii=False, indent=0)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    return merged


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pairs", default="strings/i18n/en_pairs.json")
    ap.add_argument("--upstream", default="strings/i18n/en_pairs_upstream.json")
    ap.add_argument("--translated", default="strings/i18n/en_translated.json")
    ap.add_argument("--all", default="strings/i18n/en_all.json",
                    help="scalony słownik (w repo); baza, gdy nie ma en_pairs.json")
    ap.add_argument("--out", default="strings/i18n/en_chat.json")
    ap.add_argument("--dm-out", default="strings/i18n/en_dm.json",
                    help="krótkie stałe dla DM (aquila/code/modules/i18n/translate.dm)")
    ap.add_argument("--slice", nargs="*", default=DEFAULT_SLICE)
    ap.add_argument("--manual", default="strings/i18n/en_manual.json")
    args = ap.parse_args()

    pairs = load_sources(args)
    # strings/ (porady rundy, listy tekstów) daje tylko stałe: wiadomość składa je w DM
    # tgui: teksty z okien (stałe i literały `${...}`) dla tłumaczenia okien (tgui/i18nDom.ts)
    files = subprocess.run(["git", "ls-files", "-z", "*.dm", "strings/*.txt", "strings/*.json",
                            "tgui/packages/*.tsx", "tgui/packages/*.jsx", "tgui/packages/*.ts",
                            "tgui/packages/*.js"],
                           capture_output=True, text=True, encoding="utf-8", check=True).stdout.split("\0")[:-1]

    wanted, names, js_literals = set(), set(), set()
    for path in files:
        if ep.SKIP_PATH.search(path) or lm.NOT_PLAYER_TEXT.search(path):
            continue
        is_js = path.endswith(JS_EXT)
        in_slice = path.endswith(".dm") and any(path.startswith(p) for p in args.slice)
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                # z napisami ze środka wstawek: "aś" z [gender == FEMALE ? "aś" : "eś"] też ma wpis
                for lit in lm.line_literals(path, line):
                    if lit not in pairs:
                        continue
                    if is_js:
                        js_literals.add(lit)
                        (wanted if "${" in lit else names).add(lit)
                    elif in_slice:
                        wanted.add(lit)
                    elif "[" not in lit:
                        names.add(lit)  # stałe spoza wycinka: nazwy, czasowniki ataku itp.

    manual = load_json(args.manual)

    exact, templates, stats = {}, [], collections.Counter()
    for pl in sorted(wanted | names | set(manual)):
        en = pairs[pl]
        parse = parse_js_literal if pl in js_literals else parse_dm_literal
        pl_parts = parse(pl)
        built = build_pl(pl_parts)
        if not built:
            stats["pomijane: przedimek/zaimek w PL"] += 1
            continue
        texts, exprs = built
        en_parts, missing = build_en(parse(en), exprs)
        if missing:
            stats["pomijane: wstawka EN bez odpowiednika PL"] += 1
            continue
        if not exprs:
            key = texts[0].strip()
            value = "".join(x for x in en_parts if isinstance(x, str)).strip()
            # pusta wartość jest poprawna: polskie końcówki rodzaju ("aś") po angielsku znikają
            if key and key != value:
                exact[key] = value
                stats["stałe"] += 1
            continue
        alts = alternatives(exprs) if pl not in js_literals else {}
        fixed = TAG.sub(" ", "".join(texts) + " " + " ".join(" ".join(a) for a in alts.values()))
        if pl not in manual and (len(WORD.findall(fixed)) == 0 or len(re.sub(r"\s", "", fixed)) < 4):
            stats["pomijane: za mało stałego tekstu"] += 1
            continue
        templates.append({"pl": texts, "en": en_parts, "alts": alts})
        stats["szablony"] += 1
        stats["z alternatywami"] += bool(alts)

    # słowo-kotwica: najrzadsze słowo stałego tekstu szablonu. Gdy stały tekst nie ma słów,
    # kotwicą jest po jednym słowie z każdej alternatywy (w wiadomości jest tylko jedna z nich).
    def plain_words(text):
        return {w.lower() for w in WORD.findall(TAG.sub(" ", text))}

    freq = collections.Counter()
    for t in templates:
        freq.update(plain_words("".join(t["pl"])))
        for options in t["alts"].values():
            for option in options:
                freq.update(plain_words(option))

    def rarest(words):
        return min(words, key=lambda w: (freq[w], -len(w), w))

    kept = []
    for t in templates:
        words = plain_words("".join(t["pl"]))
        if words:
            t["k"] = rarest(words)
        else:
            option_words = [plain_words(o) for options in t["alts"].values() for o in options]
            if not option_words or not all(option_words):
                stats["pomijane: alternatywa bez słowa-kotwicy"] += 1
                continue
            t["k"] = sorted({rarest(w) for w in option_words})
        kept.append(t)
    templates = kept

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    data = {
        "version": 2,
        "exact": exact,
        # [kotwica albo lista kotwic, teksty PL, części EN, {nr wstawki: [alternatywy PL]}?]
        "templates": [[t["k"], t["pl"], t["en"]] + ([t["alts"]] if t["alts"] else []) for t in templates],
    }
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    # Serwer (dymki, runechat, screentipy) potrzebuje tylko krótkich tekstów: stałe i szablony
    # bez HTML (runechat zdejmuje znaczniki, dymki ich nie mają)
    short = {k: v for k, v in sorted(exact.items()) if len(k) <= DM_MAX_LENGTH}
    short_templates = [
        entry for t, entry in zip(templates, data["templates"])
        if not TAG.search("".join(t["pl"])) and len("".join(t["pl"])) <= DM_MAX_LENGTH
    ]
    with open(args.dm_out, "w", encoding="utf-8") as f:
        json.dump({"exact": short, "templates": short_templates}, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    stats["szablony dla serwera"] = len(short_templates)
    sys.stdout.reconfigure(encoding="utf-8")
    print(f"wycinek: {len(wanted)} tekstów, stałe spoza wycinka: {len(names)}, ręczne: {len(manual)}")
    for k, v in stats.most_common():
        print(f"  {k}: {v}")
    print(f"zapisano {args.out}: {os.path.getsize(args.out) // 1024} KB")


if __name__ == "__main__":
    main()
