"""Wypisuje polskie teksty z kodu, które nie mają jeszcze angielskiego odpowiednika.

Źródła tłumaczeń: en_all.json (scalony słownik w repo) oraz, jeśli są, en_pairs.json,
en_pairs_upstream.json, en_original.json, en_translated.json i en_manual.json.

Użycie (z katalogu repo):
    python tools/i18n/list_missing.py --out braki.jsonl         # cały kod, lista z kontekstem
    python tools/i18n/list_missing.py --changed origin/master   # tylko linie dodane względem gałęzi (CI)

Tryb --changed wypisuje adnotacje GitHub Actions; z --strict (CI i lokalne CI) to błędy i kod wyjścia 1. Angielski
odpowiednik nowego tekstu dopisz do strings/i18n/en_translated.json i uruchom
tools/i18n/build_chat_dict.py.
"""

import argparse
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402
import jsx_ast  # noqa: E402
import jsx_runs  # noqa: E402

SOURCES = [
    "strings/i18n/en_all.json",
    "strings/i18n/en_jsx.json",
    "strings/i18n/en_pairs.json",
    "strings/i18n/en_pairs_upstream.json",
    "strings/i18n/en_manual.json",
    "strings/i18n/en_original.json",
    "strings/i18n/en_translated.json",
]


PATHSPECS = ["*.dm", "tgui/packages/*.tsx", "tgui/packages/*.jsx", "tgui/packages/*.ts",
             "tgui/packages/*.js", "strings/*.txt", "strings/*.json"]
HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")
# pliki, które nie są tekstem dla gracza (testy, polskie listy imion, sam słownik)
NOT_PLAYER_TEXT = re.compile(
    r"(^|/)unit_tests/|^strings/names/|^strings/i18n/|tgui-panel/stat/translations\.js$|\.test\.[jt]sx?$"
)


def load_known(sources):
    known = {}
    for path in sources:
        if os.path.exists(path):
            data = json.load(open(path, encoding="utf-8"))
            data.pop("_komentarz", None)
            for pl, en in data.items():
                known.setdefault(pl, en)
    return known


WORD = re.compile(r"[a-ząćęłńóśźż]{2,}")  # od dwóch liter: "ma", "na" (jak build_chat_dict.py)
STRING_IN_EMBED = re.compile(r'"((?:\\.|[^"\\])*)"')
PATH_LIKE = re.compile(r"\.(dm|dmi|ogg|wav|png|json|txt|dmm|tsx|ts|js)$")


def polish_detector(known):
    """Polski tekst: polskie znaki albo słowa ze stoplisty (is_polish), albo słowo,
    które w słowniku występuje tylko po polskiej stronie ("bardziej kobieco", "prawe")."""
    pl_words, en_words = {}, set()
    for pl, en in known.items():
        for word in set(WORD.findall(pl.lower())):
            pl_words[word] = pl_words.get(word, 0) + 1
        en_words.update(WORD.findall(en.lower()))
    vocab = {w for w, count in pl_words.items() if count >= 2 and w not in en_words}

    def detect(text):
        if not ep.wordy(text) or PATH_LIKE.search(text.strip()) or text.startswith("data:"):
            return False
        return ep.is_polish(text) or any(w in vocab for w in WORD.findall(ep.strip_embeds(text).lower()))
    return detect


def polish_run_detector(known, detect=None):
    """Polski tekst okna. Sam jsx_runs.is_polish_run patrzy tylko na ogonki i stoplistę, więc
    "Mapa taktyczna" czy "Brak celu dodatkowego" przechodziły jako nie-polskie: tu też słownik.
    detect: gotowy polish_detector(known), żeby nie liczyć słownika drugi raz."""
    detect = detect or polish_detector(known)
    return lambda literal: jsx_runs.is_polish_run(literal) or detect(jsx_runs.plain(literal))


# napis w kodzie okna, a nie apostrof w tekście JSX ("Kliknij 'Start', żeby"): przed nim operator, nawias,
# przecinek albo początek linii, za nim to samo, metoda ('Tekst'.toUpperCase()), `as const` albo koniec linii
CODE_BEFORE = re.compile(r"(?:^|[=:(\[{,?|&+!]|\breturn|\bcase|=>)\s*$")
CODE_AFTER = re.compile(r"^\s*(?:$|[,;:)\]}?|&+]|/?>|\w+=|\.\w|(?:as|satisfies)\b)")


def window_code_matches(line):
    """(napis, kolumna cudzysłowu) dla napisów w cudzysłowach z linii kodu okna (label: 'Stado',
    x || 'brak'), które tłumaczy w oknie tgui/i18nDom.ts. Tekst JSX bierzemy z drzewa składni,
    więc cała linia jako tekst odpada. Kolumna w jednostkach UTF-16 jak w zrzucie zdań okien
    (i18n-jsx.cjs dumpItems): emoji przed napisem to dwie jednostki, nie jeden znak Pythona."""
    if line.strip().startswith(("//", "*", "/*")):
        return []
    return [(m.group(2), utf16_len(line[:m.start()])) for m in ep.QUOTED_JS.finditer(line)
            if CODE_BEFORE.search(line[:m.start()]) and CODE_AFTER.match(line[m.end():])]


def utf16_len(text):
    return len(text.encode("utf-16-le")) // 2


def window_code_strings(line):
    return [lit for lit, _ in window_code_matches(line)]


# plik -> [((linia, kolumna) początku, (linia, kolumna) końca)] zdań okien z drzewa składni
_sentences = None


def in_window_sentence(path, number, column):
    """Napis w miejscu (linia, kolumna) leży w zdaniu okna (<Box>Wybierz {'żółty przycisk'} teraz.</Box>):
    loader tłumaczy całe zdanie z drzewa składni, więc sam napis nie potrzebuje osobnego wpisu. Liczy się
    położenie, nie treść: label: 'żółty przycisk' obok takiego zdania w tej samej linii to osobny tekst."""
    global _sentences
    if _sentences is None:
        _sentences = sentence_spans(jsx_ast.dump() or [])
    return any(start <= (number, column) < end for start, end in _sentences.get(path, ()))


def sentence_spans(items):
    """plik -> zakresy zdań ((linia, kolumna), (linia, kolumna)) ze zrzutu loadera (kolumny UTF-16)."""
    spans = {}
    for item in items:
        end_line = item.get("endLine", item["line"])
        spans.setdefault(item["file"], []).append(
            ((item["line"], item.get("column", 0)), (end_line, item.get("endColumn", 10 ** 9))))
    return spans


def scan_literals(path, number, line, windows_from_ast):
    """Literały linii do sprawdzenia. W oknach z drzewem składni tylko napisy w kodzie spoza zdań okien."""
    if windows_from_ast and path.endswith(jsx_runs.JSX_EXT):
        return [lit for lit, column in window_code_matches(line) if not in_window_sentence(path, number, column)]
    return line_literals(path, line)


def line_literals(path, line):
    """Literały linii i napisy wewnątrz ich wstawek ([on ? "włączony" : "wyłączony"])."""
    if path.endswith(".dm") and line.strip().startswith(("*", "/*")):
        return []  # komentarz blokowy (/** ... */): cudzysłowy w opisie to nie tekst gracza
    found = ep.literals(path, line)
    if path.endswith(".dm"):
        for lit in list(found):
            for embed in re.findall(r"\[([^\[\]]*)\]", lit):
                found += STRING_IN_EMBED.findall(embed)
    return found


def missing_literals(known):
    files = subprocess.run(["git", "ls-files", "-z", *PATHSPECS],
                           capture_output=True, text=True, encoding="utf-8", check=True).stdout.split("\0")[:-1]
    is_polish = polish_detector(known)
    is_polish_run = polish_run_detector(known, is_polish)
    windows_from_ast = jsx_ast.dump() is not None
    found = {}
    for path in files:
        if ep.SKIP_PATH.search(path) or NOT_PLAYER_TEXT.search(path):
            continue
        try:
            with open(path, encoding="utf-8", errors="replace") as f:
                content = f.read()
        except OSError:
            continue
        lines = ep.logical_lines(path, content.splitlines())
        for lit, number in jsx_missing(path, content, known, is_polish_run):
            found.setdefault(lit, {"pl": lit, "file": path, "line": number, "code": lit[:200]})
        for number, line in enumerate(lines, 1):
            for lit in scan_literals(path, number, line, windows_from_ast):
                if lit in known or lit in found:
                    continue
                if is_polish(lit):
                    found[lit] = {"pl": lit, "file": path, "line": number, "code": line.strip()[:200]}
    return found


def jsx_missing_ranges(path, content, known, is_polish_run):
    """Jak jsx_missing, ale z zakresem linii tekstu: (literał, pierwsza linia, ostatnia linia)."""
    ast = jsx_ast.dump()
    if ast is not None and path.endswith(jsx_runs.JSX_EXT):
        return [(item["literal"], item["line"], item.get("endLine", item["line"])) for item in ast
                if item["file"] == path and item["literal"] not in known
                and is_polish_run(item["literal"])]
    return [(lit, number, number) for lit, number in jsx_missing(path, content, known, is_polish_run)]


def jsx_missing(path, content, known, is_polish_run):
    """Polskie teksty okien bez angielskiego: (literał, numer linii). Z drzewa składni (te same,
    które owija loader tgui/i18n-jsx.cjs); bez Node ze skanu tools/i18n/jsx_runs.py."""
    if not path.endswith(jsx_runs.JSX_EXT):
        return []
    ast = jsx_ast.dump()
    if ast is not None:
        return [(item["literal"], item["line"]) for item in ast
                if item["file"] == path and item["literal"] not in known
                and is_polish_run(item["literal"])]
    out = []
    for lit, _ in jsx_runs.runs(content):
        if lit not in known and is_polish_run(lit):
            head = lit.split("${", 1)[0].strip() or lit
            out.append((lit, content.count("\n", 0, max(content.find(head), 0)) + 1))
    return out


def normalized(text):
    return re.sub(r"\s+", " ", text).strip()


def in_base(base, path, literal, cache):
    """Czy ten sam tekst był już w tym pliku w base (linia tylko przeniesiona albo przeformatowana).
    Wykrywanie polskiego zależy od słownika, więc bez tego ruszenie starej linii mogło nagle zablokować CI.
    Porównuje całe literały (ze skanu linii i zdań okien), nie podciągi: nowe "Bez" to nie stare "Bez broni"."""
    if path not in cache:
        shown = subprocess.run(["git", "show", f"{base}:{path}"], capture_output=True, text=True,
                               encoding="utf-8", errors="replace")
        literals = set()
        if shown.returncode == 0:
            for line in ep.logical_lines(path, shown.stdout.splitlines()):
                literals.update(line_literals(path, line))
            if path.endswith(jsx_runs.JSX_EXT):
                literals.update(lit for lit, _ in jsx_runs.runs(shown.stdout))
        cache[path] = {normalized(lit) for lit in literals}
    return normalized(literal) in cache[path]


def changed_missing(known, base):
    """Polskie literały w liniach dodanych względem base, bez angielskiego. Pomija teksty, które
    w tym pliku już były (ich braki pokazuje pełny skan bez --changed)."""
    diff = subprocess.run(["git", "diff", "-U0", "--no-renames", base, "--", *PATHSPECS],
                          capture_output=True, text=True, encoding="utf-8", check=True).stdout
    is_polish = polish_detector(known)
    is_polish_run = polish_run_detector(known, is_polish)
    path, number, found = None, 0, []
    added = {}  # okno -> numery dodanych linii
    # teksty okien z drzewa składni (zdania przez kilka linii); bez Node ze skanu linii jak DM
    windows_from_ast = jsx_ast.dump() is not None
    for line in diff.splitlines():
        if line.startswith("+++ "):
            path = line[6:] if line.startswith("+++ b/") else None
        elif m := HUNK.match(line):
            number = int(m.group(1))
        elif line.startswith("+") and path:
            if not ep.SKIP_PATH.search(path) and not NOT_PLAYER_TEXT.search(path):
                if windows_from_ast and path.endswith(jsx_runs.JSX_EXT):
                    added.setdefault(path, set()).add(number)
                # w oknach z drzewem składni: napisy w kodzie poza tekstem JSX (label: 'Stado')
                for lit in scan_literals(path, number, line[1:], windows_from_ast):
                    if lit not in known and is_polish(lit):
                        found.append((path, number, lit))
            number += 1
    # tylko teksty, które nachodzą na dodane linie: stare zdania okna nie wracają w każdym PR-ze
    for path, lines in sorted(added.items()):
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8", errors="replace") as f:
            for lit, first, last in jsx_missing_ranges(path, f.read(), known, is_polish_run):
                if any(first <= n <= last for n in lines):
                    found.append((path, first, lit))
    # atrybut JSX (tooltip="...") bywa i w drzewie składni, i w skanie linii: raz na plik i tekst
    unique, cache = {}, {}
    for path, number, lit in found:
        if (path, lit) not in unique and not in_base(base, path, lit, cache):
            unique[(path, lit)] = (path, number, lit)
    return list(unique.values())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out")
    ap.add_argument("--changed", metavar="BASE", help="sprawdź tylko linie dodane względem BASE")
    ap.add_argument("--strict", action="store_true", help="z --changed: błąd (kod wyjścia 1), nie ostrzeżenie")
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")

    known = load_known(SOURCES)
    if args.changed:
        found = changed_missing(known, args.changed)
        for path, number, lit in found:
            # ostrzeżenie GitHub Actions: % i nowe linie muszą być zakodowane
            text = lit.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")[:150]
            level = "error" if args.strict else "warning"
            print(f"::{level} file={path},line={number}::Tekst bez angielskiego odpowiednika: {text}")
        print(f"nowych polskich tekstów bez angielskiego: {len(found)}"
              + (" (dopisz je do strings/i18n/en_translated.json i uruchom tools/i18n/build_chat_dict.py;"
                 " tekst, który nie trafia do gracza, jako parę tekst -> ten sam tekst)"
                 if found else ""))
        if found and args.strict:
            sys.exit(1)
        return

    missing = missing_literals(known)
    print(f"polskich tekstów bez angielskiego: {len(missing)}")
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            for item in sorted(missing.values(), key=lambda x: (x["file"], x["line"])):
                f.write(json.dumps(item, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
