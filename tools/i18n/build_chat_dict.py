"""Buduje słownik czatu PL -> EN dla panelu tgui z en_pairs.json.

Literał DM z osadzeniami ("[user] uderza [target]!") staje się szablonem: stałe
fragmenty do dopasowania w HTML wiadomości i numery osadzeń. Angielska strona
wskazuje, które przechwycone wartości wstawić i gdzie. Panel (tgui-panel/chat/i18n.ts)
dopasowuje szablony do przychodzących wiadomości.

Źródła (po kolei, późniejsze wygrywają): en_pairs_upstream.json i en_pairs.json
(generowane, poza repo) albo en_all.json, potem en_translated.json, en_original.json i en_manual.json.
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
import jsx_ast  # noqa: E402
import jsx_runs  # noqa: E402

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


# napis w wyrażeniu okna: ${on ? 'WŁ.' : 'WYŁ.'}
QUOTED_IN_EXPR = re.compile(r"""(['"])((?:\\.|(?!\1).)*)\1""")
# Słownik okien (tgui, menu Esc): mniejszy niż czatu, patrz koniec main()
WINDOWS_OUT = "strings/i18n/en_windows.json"
# Linia DM, której tekst idzie tylko do czatu (wiadomość, dymek, examine, log): nie do okna
CHAT_ONLY_LINE = re.compile(
    r"\bto_chat\(|visible_message\(|audible_message\(|balloon_alert\(|show_message\(|"
    r"\bsay\(|\bwhisper\(|\bemote\(|\blog_\w+\(|message_admins\(|investigate_log\(|"
    r"priority_announce\(|minor_announce\(|deadchat_broadcast\(|notify_ghosts\(|"
    r"examine_list \+=|^\s*\. \+= |send_to_playing_players\("
)

# najdłuższy tekst w słowniku dla serwera: dymki i runechat są krótkie
DM_MAX_LENGTH = 100
# opisy przedmiotów w dymku po najechaniu (tooltip) są dłuższe: stałe bez HTML do tej długości
DM_MAX_PLAIN_LENGTH = 2000
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


def build_pl(parts, js=False):
    """Polski szablon: [tekst0, tekst1, ...] i lista wyrażeń między nimi. None = nie do użycia.
    js: literał z okna, w którym "the" zostaje (usuwa je tylko DM przy wstawianiu obiektu)."""
    def strip(text):
        return text if js else AUTO_ARTICLE.sub(r"\1", text)

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
            texts.append(strip("".join(cur)))
            exprs.append(val)
            cur = []
    texts.append(strip("".join(cur)))
    return texts, exprs


# [x ? "A" : "B"] z DM albo ${x ? 'A' : 'B'} z okien; napisy w grupach 2 i 4
TERNARY = re.compile(r'''^[^"']+?\?\s*(["'])((?:\\.|(?!\1)[^\\])*)\1\s*:\s*(["'])((?:\\.|(?!\3)[^\\])*)\3$''')


def unescape_dm(text):
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": "\t"}.get(m.group(1), m.group(1)), text)


def alternatives(exprs, js=False):
    """Wstawki-warunki z dwoma napisami ([harmful ? "wbija się" : "przykleja się"]): numer -> [A, B].

    W szablonie zamiast dowolnego tekstu dopasowujemy jedną z alternatyw. Daje to kotwicę
    i pewniejsze dopasowanie, a wartość i tak tłumaczy słownik stałych (napisy ze wstawek)."""
    found = {}
    for index, expr in enumerate(exprs):
        options = literal_ternary(expr, js)
        if options:
            found[str(index)] = options
    return found


TAG_NAME = re.compile(r"<\s*(/?)\s*(\w+)")


def tag_segments(pl, en):
    """Pary tekstów między znacznikami, gdy PL i EN mają te same znaczniki w tej samej kolejności."""
    pl_tags = [m.groups() for m in TAG_NAME.finditer("".join(re.findall(r"<[^>]*>", pl)))]
    en_tags = [m.groups() for m in TAG_NAME.finditer("".join(re.findall(r"<[^>]*>", en)))]
    if not pl_tags or pl_tags != en_tags:
        return []
    pairs = []
    for segment_pl, segment_en in zip(re.split(r"<[^>]*>", pl), re.split(r"<[^>]*>", en)):
        segment_pl, segment_en = segment_pl.strip(), segment_en.strip()
        if segment_pl and segment_pl != segment_en and re.search(r"[^\W\d_]{2,}", segment_pl):
            pairs.append((segment_pl, segment_en))
    return pairs


def literal_ternary(expr, js=False):
    """[A, B] dla wstawki [x ? "A" : "B"] bez zagnieżdżonych wstawek, inaczej None.

    W DM nawias kwadratowy w napisie to wstawka, a w literale JS zwykły tekst ('[NIEZNANE]')."""
    m = TERNARY.match(expr.strip())
    nested = "${" in m.group(2) + m.group(4) if m else True
    if not js and m and ("[" in m.group(2) or "[" in m.group(4)):
        nested = True
    if m and not nested:
        return [unescape_dm(m.group(2)), unescape_dm(m.group(4))]
    return None


def build_en(parts, pl_exprs, js=False):
    """Angielska strona: lista elementów: tekst albo [nr osadzenia PL, przedimek]."""
    pl_index, pl_conditions = {}, {}
    for k, e in enumerate(pl_exprs):
        pl_index.setdefault(norm_expr(e), k)
        condition = ternary_condition(e)
        if condition and literal_ternary(e, js):
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
            elif condition in pl_conditions and literal_ternary(val, js):
                # angielski warunek z tym samym warunkiem co polska alternatywa: gałąź według tego,
                # która polska alternatywa wystąpiła (["?", nr wstawki PL, [EN dla A, EN dla B]])
                m = TERNARY.match(val.strip())
                out.append(["?", pl_conditions[condition], [unescape_dm(m.group(2)), unescape_dm(m.group(4))]])
            else:
                m = PRONOUN_CALL.search(key)
                if m and m.group(1) in pronouns:
                    word = pronouns[m.group(1)]
                    if m.group(2) and word:
                        word = word[0].upper() + word[1:]
                    add_text(word)
                elif literal_ternary(val, js):
                    # angielski warunek bez polskiego odpowiednika ([gender == PLURAL ? "They are" :
                    # "It is"]): gałąź domyślna, czyli druga
                    add_text(literal_ternary(val, js)[1])
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
    tłumaczenia agentów/ręczne (en_translated.json), oryginały portów, które je zastępują
    (en_original.json), a na sam koniec en_manual.json.
    """
    if os.path.exists(args.pairs):
        merged = dict(load_json(args.upstream))
        merged.update(load_json(args.pairs))
    else:
        merged = load_json(args.all)
    # zdania z okien przecięte wstawkami JSX (tools/i18n/jsx_runs.py)
    merged.update(load_json(jsx_runs.OUT))
    merged.update(load_json(args.translated))
    # oryginały portów znalezione dla tłumaczeń zwrotnych i złych par (tools/i18n/match_originals.py)
    merged.update(load_json(args.original))
    merged.update(load_json(args.manual))
    with open(args.all, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(merged.items())), f, ensure_ascii=False, indent=0)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    return merged


def load_ui_pairs():
    """Pary z samego kodu okien (extract_pairs.py --ui), zapisywane do en_ui.json w repo.

    Ten sam polski tekst bywa w oknie i w DM z innym oryginałem ("Wróć": "Return" w menu Esc,
    "Recall" gdzie indziej), więc okna mają własną tablicę z pierwszeństwem."""
    generated, saved = "strings/i18n/en_pairs_ui.json", "strings/i18n/en_ui.json"
    if not os.path.exists(generated):
        return load_json(saved)
    pairs = load_json(generated)
    with open(saved, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(pairs.items())), f, ensure_ascii=False, indent=0)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    return pairs


# polskie słowa bez polskich liter, które są też angielskimi słowami (nie odrzucamy ich par)
POLISH_ASCII_WORDS = {"szatnia", "mops", "ananas", "paragon", "ko"}
SINGLE_WORD = re.compile(r"^[A-Za-z_]+$")


def identifier_refactors(table, manual):
    """Klucze par EN -> EN z historii: klucz to jedno słowo ASCII, które występuje w angielskich
    tłumaczeniach, a nie występuje w polskich zdaniach słownika."""
    english_words, polish_words = set(), set()
    for key, value in table.items():
        english_words.update(w.lower() for w in re.findall(r"[A-Za-z]+", value))
        if " " in key and re.search(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]", key):
            polish_words.update(w.lower() for w in re.findall(r"[^\W\d_]+", key))
    return [
        key for key, value in table.items()
        if SINGLE_WORD.match(key) and key not in manual
        and key.lower() in english_words and key.lower() not in polish_words
        and key.lower() not in POLISH_ASCII_WORDS and key.lower() != value.lower()
    ]


# kolory i klasy tgui ({color: 'bad'}), które historia brała za tłumaczenie etykiet ("Martwe" -> "bad")
CSS_CLASSES = {"good", "bad", "average", "label", "danger", "caution", "notice", "transparent", "grey"}


def polish_words_of(table):
    """Słowa z polskich zdań słownika (klucze z polskimi literami i spacją)."""
    words = set()
    for key in table:
        if " " in key and re.search(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]", key):
            words.update(w.lower() for w in re.findall(r"[^\W\d_]+", key))
    return words


def polish_or_class_values(table, exact, manual, check_css):
    """Klucze, których "tłumaczenie" jest polskim tekstem: samo jest kluczem słownika z innym
    tłumaczeniem i składa się z polskich słów ("Odciski" -> "Wiek", "Spłacony" -> "Brak komentarzy.").
    check_css: w tablicy okien także nazwa klasy koloru przy nazwie z wielkiej litery ("Martwe" -> "bad")."""
    polish_words = polish_words_of(exact)
    # słowa angielskie z oryginałów upstreamu (czysto angielskie teksty); bez tego pliku: z całego słownika
    source = load_json("strings/i18n/en_pairs_upstream.json") or exact
    english_words = set()
    for value in source.values():
        english_words.update(w.lower() for w in re.findall(r"[A-Za-z]+", value))
    out = []
    for key, value in table.items():
        if key in manual or value == key:
            continue
        words = [w.lower() for w in re.findall(r"[^\W\d_]+", value)]
        # "Left", "ERROR" też bywają w polskich zdaniach: odpada tylko wartość bez angielskich słów
        polish_value = value in exact and exact[value] != value and words             and all(w in polish_words and w not in english_words for w in words)
        css_class = key[:1].isupper() and value in CSS_CLASSES
        if polish_value or css_class:
            out.append(key)
    return out


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
    ap.add_argument("--original", default="strings/i18n/en_original.json")
    args = ap.parse_args()

    pairs = load_sources(args)
    ui_pairs = load_ui_pairs()
    # strings/ (porady rundy, listy tekstów) daje tylko stałe: wiadomość składa je w DM
    # tgui: teksty z okien (stałe i literały `${...}`) dla tłumaczenia okien (tgui/i18nDom.ts)
    files = subprocess.run(["git", "ls-files", "-z", "*.dm", "strings/*.txt", "strings/*.json",
                            "tgui/packages/*.tsx", "tgui/packages/*.jsx", "tgui/packages/*.ts",
                            "tgui/packages/*.js"],
                           capture_output=True, text=True, encoding="utf-8", check=True).stdout.split("\0")[:-1]

    wanted, names, js_literals, english_literals = set(), set(), set(), set()
    # literały, które mogą trafić do okna: kod okien i DM poza liniami wysyłającymi tylko do czatu
    window_literals = set()
    for path in files:
        if ep.SKIP_PATH.search(path) or lm.NOT_PLAYER_TEXT.search(path):
            continue
        is_js = path.endswith(JS_EXT)
        in_slice = path.endswith(".dm") and any(path.startswith(p) for p in args.slice)
        with open(path, encoding="utf-8", errors="replace") as f:
            content = f.read()
        if path.endswith(jsx_runs.JSX_EXT):
            # całe zdania z wstawkami: okno tłumaczy razem sąsiednie węzły tekstowe
            for lit, _ in jsx_runs.runs(content):
                if lit in pairs:
                    js_literals.add(lit)
                    wanted.add(lit)
                    window_literals.add(lit)
        for line in ep.logical_lines(path, content.splitlines()):
            # z napisami ze środka wstawek: "aś" z [gender == FEMALE ? "aś" : "eś"] też ma wpis
            to_window = not path.endswith(".dm") or not CHAT_ONLY_LINE.search(line)
            for lit in lm.line_literals(path, line):
                if to_window:
                    window_literals.add(lit)
                if lit not in pairs:
                    # zdanie w kodzie po angielsku z wstawką ("[src] looks pretty robust!"):
                    # szablon na siebie, żeby przetłumaczyć wstawione polskie nazwy
                    if in_slice and "[" in lit and ep.is_english(lit) and not ep.is_polish(lit):
                        english_literals.add(lit)
                    continue
                if is_js:
                    js_literals.add(lit)
                    (wanted if "${" in lit else names).add(lit)
                elif in_slice:
                    wanted.add(lit)
                elif "[" not in lit:
                    names.add(lit)  # stałe spoza wycinka: nazwy, czasowniki ataku itp.

    # teksty okien z drzewa składni (te same, które loader owija w t()/tt())
    for item in jsx_ast.dump() or []:
        lit = item["literal"]
        window_literals.add(lit)
        if lit in pairs:
            js_literals.add(lit)
            (wanted if "${" in lit else names).add(lit)

    manual = load_json(args.manual)

    exact, templates, stats = {}, [], collections.Counter()
    window_keys = set()  # klucze exact dla słownika okien (bez stałych tylko z czatu)
    # stałe z kodu okien (TSX) mają w oknach pierwszeństwo przed ogólnym słownikiem:
    # "Wróć" w menu Esc to "Back", a nie "Recall" z jakiegoś DM
    ui = {}
    for literal in english_literals:
        pairs.setdefault(literal, literal)
    wanted |= english_literals
    for pl in sorted(wanted | names | set(manual)):
        en = pairs[pl]
        parse = parse_js_literal if pl in js_literals else parse_dm_literal
        pl_parts = parse(pl)
        built = build_pl(pl_parts, js=pl in js_literals)
        if not built:
            stats["pomijane: przedimek/zaimek w PL"] += 1
            continue
        texts, exprs = built
        en_parts, missing = build_en(parse(en), exprs, js=pl in js_literals)
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
                if pl in window_literals or pl in manual:
                    window_keys.add(key)
                # Tekst w znacznikach (<span class='notice'>…</span>, <a>metkę</a>) trafia do
                # gracza jako jeden z wielu węzłów, np. linia examine: pary dla tekstów między
                # znacznikami, gdy obie strony mają te same znaczniki
                for segment_pl, segment_en in tag_segments(key, value):
                    # pusty odpowiednik całego zwrotu to złe dopasowanie węzłów (opis czapki
                    # poczty: "A <i>…</i> head wear"), oględziny pokazałyby pusty tekst
                    if not segment_en and any(len(w) > 3 for w in WORD.findall(segment_pl)):
                        continue
                    if segment_pl not in exact:
                        exact[segment_pl] = segment_en
                        stats["stałe z wnętrza znaczników"] += 1
            if key and pl in js_literals:
                # okna: tłumaczenie z kodu okien, jeśli jest; ogólne exact zostaje dla czatu
                # en_manual.json poprawia także tablicę okien (złe pary z historii TSX)
                ui_en = None if pl in manual else ui_pairs.get(pl)
                if ui_en:
                    ui_value = "".join(text for kind, text in parse(ui_en) if kind == "t").strip()
                else:
                    ui_value = value
                if ui_value and ui_value != key:
                    ui[key] = ui_value
            continue
        alts = alternatives(exprs, js=pl in js_literals)
        fixed = TAG.sub(" ", "".join(texts) + " " + " ".join(" ".join(a) for a in alts.values()))
        if pl not in manual and (len(WORD.findall(fixed)) == 0 or len(re.sub(r"\s", "", fixed)) < 4):
            stats["pomijane: za mało stałego tekstu"] += 1
            continue
        templates.append({"pl": texts, "en": en_parts, "alts": alts,
                          "window": pl in window_literals or pl in manual})
        stats["szablony"] += 1
        stats["z alternatywami"] += bool(alts)

    # słowo-kotwica: najrzadsze słowo stałego tekstu szablonu. Gdy stały tekst nie ma słów,
    # kotwicą jest po jednym słowie z każdej alternatywy (w wiadomości jest tylko jedna z nich).
    def plain_words(text):
        return {w.lower() for w in WORD.findall(TAG.sub(" ", text))}

    def anchor_words(texts, alts):
        """Słowa stałego tekstu bez kawałków przyklejonych do wstawki, która dokleja litery:
        w "nanit${reverse ? 'ów' : 'y'}" okno pokazuje "nanitów", więc "nanit" jako kotwica
        nigdy by nie trafiło. Wstawka nr i leży między texts[i] a texts[i + 1]."""
        def glues(index, at_start):
            options = alts.get(str(index), [])
            return any(o and (o[:1] if at_start else o[-1:]).isalpha() for o in options)

        words = set()
        for i, segment in enumerate(texts):
            segment = TAG.sub(" ", segment)
            if i > 0 and segment[:1].isalpha() and glues(i - 1, False):
                segment = re.sub(r"^\w+", " ", segment)
            if i < len(texts) - 1 and segment[-1:].isalpha() and glues(i, True):
                segment = re.sub(r"\w+$", " ", segment)
            words |= plain_words(segment)
        return words

    freq = collections.Counter()
    for t in templates:
        freq.update(anchor_words(t["pl"], t["alts"]))
        for options in t["alts"].values():
            for option in options:
                freq.update(plain_words(option))

    def rarest(words):
        return min(words, key=lambda w: (freq[w], -len(w), w))

    kept = []
    for t in templates:
        words = anchor_words(t["pl"], t["alts"])
        if words:
            t["k"] = rarest(words)
        else:
            # pusta alternatywa (${looping ? ', powtarza się' : ''}) nie daje słowa, ale wtedy nie ma
            # też czego tłumaczyć: kotwicami są słowa pozostałych
            option_words = [plain_words(o) for options in t["alts"].values() for o in options if o.strip()]
            if not option_words or not all(option_words):
                stats["pomijane: alternatywa bez słowa-kotwicy"] += 1
                continue
            t["k"] = sorted({rarest(w) for w in option_words})
        kept.append(t)
    templates = kept

    # Pary z refaktoryzacji kodu wzięte za tłumaczenie ("Yes" -> "No", "insert" -> "eject",
    # "volume" -> "select"): angielski tekst w oknie zamieniałby się w inne słowo
    for table in (exact, ui):
        for key in identifier_refactors(table, manual):
            del table[key]
            stats["pomijane: angielskie słowo na inne angielskie"] += 1
    # Pary z historii, w których polski tekst zamieniono na inny polski albo na nazwę klasy koloru
    # ("Odciski" -> "Wiek", "Martwe" -> "bad"); okna dostają wtedy tłumaczenie z ogólnego słownika
    for table, check_css in ((exact, False), (ui, True)):
        for key in polish_or_class_values(table, exact, manual, check_css):
            del table[key]
            stats["pomijane: polski tekst albo klasa zamiast tłumaczenia"] += 1

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    data = {
        "version": 2,
        "exact": exact,
        "ui": ui,
        # [kotwica albo lista kotwic, teksty PL, części EN, {nr wstawki: [alternatywy PL]}?]
        "templates": [[t["k"], t["pl"], t["en"]] + ([t["alts"]] if t["alts"] else []) for t in templates],
    }
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    # Serwer (dymki, runechat, screentipy, tooltipy) potrzebuje głównie krótkich tekstów: stałe i szablony
    # bez HTML (runechat zdejmuje znaczniki, dymki ich nie mają)
    short = {k: v for k, v in sorted(exact.items())
             if len(k) <= DM_MAX_LENGTH or (len(k) <= DM_MAX_PLAIN_LENGTH and not TAG.search(k))}
    short_templates = [
        entry for t, entry in zip(templates, data["templates"])
        if not TAG.search("".join(t["pl"])) and len("".join(t["pl"])) <= DM_MAX_LENGTH
    ]
    with open(args.dm_out, "w", encoding="utf-8") as f:
        json.dump({"exact": short, "templates": short_templates}, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    stats["szablony dla serwera"] = len(short_templates)
    # Okna tgui i menu Esc: każde okno to osobna przeglądarka, która parsuje słownik od nowa, więc
    # dostaje mniejszy: bez HTML (tłumaczy węzły tekstowe, w nich nie ma znaczników) i bez tekstów
    # wysyłanych tylko do czatu; tablica ui tylko tam, gdzie różni się od exact
    # wartości wstawek tłumaczy exact: napisy z alternatyw i ze środka wyrażeń szablonów okien
    for t in templates:
        if t["window"]:
            for options in t["alts"].values():
                window_keys.update(o.strip() for o in options)
    for lit in js_literals:
        for _quote, inner in QUOTED_IN_EXPR.findall("".join(re.findall(r"\$\{((?:[^{}]|\{[^{}]*\})*)\}", lit))):
            window_keys.add(inner.strip())
    windows = {
        "version": 2,
        "exact": {k: exact[k] for k in sorted(window_keys) if k in exact and not TAG.search(k)},
        "ui": {k: v for k, v in sorted(ui.items()) if exact.get(k) != v},
        "templates": [
            entry for t, entry in zip(templates, data["templates"])
            if t["window"] and not TAG.search("".join(t["pl"]))
        ],
    }
    with open(WINDOWS_OUT, "w", encoding="utf-8") as f:
        json.dump(windows, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    stats["słownik okien: stałe"] = len(windows["exact"])
    stats["słownik okien: szablony"] = len(windows["templates"])
    sys.stdout.reconfigure(encoding="utf-8")
    print(f"wycinek: {len(wanted)} tekstów, stałe spoza wycinka: {len(names)}, ręczne: {len(manual)}")
    for k, v in stats.most_common():
        print(f"  {k}: {v}")
    print(f"zapisano {args.out}: {os.path.getsize(args.out) // 1024} KB, "
          f"{WINDOWS_OUT}: {os.path.getsize(WINDOWS_OUT) // 1024} KB")


if __name__ == "__main__":
    main()
