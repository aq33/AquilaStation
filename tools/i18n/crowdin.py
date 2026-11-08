"""Most między kodem gry a projektem Crowdin (https://crowdin.com/project/aquila).

Gracze poprawiają w Crowdinie polskie tłumaczenie. Źródłem w Crowdinie jest angielski
oryginał tekstu (z strings/i18n/en_all.json), a tłumaczeniem polskim obecny tekst z kodu.
Zatwierdzona poprawka wraca do gry jako PR, który podmienia literał w kodzie.

Klucz napisu to skrót SHA-1 obecnego polskiego literału, więc po wprowadzeniu poprawki
napis dostaje nowy klucz, a stary znika z Crowdina przy następnym wysłaniu źródeł.

Użycie (z katalogu repo):
    python tools/i18n/crowdin.py export [--out crowdin_out] [--existing <katalog pl>]
        Pisze crowdin_out/en/<obszar>.json (źródła) i crowdin_out/pl/<obszar>.json
        (obecny polski tekst). Z --existing pomija w plikach pl klucze, które w Crowdinie
        mają już zatwierdzone tłumaczenie, żeby nie nadpisać poprawek czekających na PR.
    python tools/i18n/crowdin.py apply <katalog pl> [--report raport.md]
        Wprowadza do kodu zatwierdzone tłumaczenia różne od obecnego tekstu.

Format plików: Chrome JSON ({"klucz": {"message": ..., "description": ...}}).
Teksty są w zapisie literału z kodu (z wstawkami [src], \\n, \\the).
"""

import argparse
import collections
import glob
import hashlib
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402
import list_missing as lm  # noqa: E402

SOURCES = ["strings/i18n/en_all.json", "strings/i18n/en_original.json", "strings/i18n/en_translated.json",
           "strings/i18n/en_manual.json"]
# przy wprowadzaniu poprawki zmieniamy też mapy, żeby var-edity i porównania w kodzie się zgadzały
APPLY_PATHSPECS = lm.PATHSPECS + ["*.dmm"]
SKIP_DIRS = {"code", "modules", "game", "packages", "objects", "interfaces"}
LOCATIONS_IN_DESCRIPTION = 3

DM_EMBED = re.compile(r"\[[^\[\]]*\]")
JS_EMBED = re.compile(r"\$\{[^{}]*\}")
DM_MACRO = re.compile(r"\\(?:the|The|a|A|an|An|improper|proper|icon|ref|roman|Roman|th|s|he|she|him|her|his|hers|himself|herself|n|t|<|>|\[|\]|\"|\\)")


def key_of(literal):
    return "s" + hashlib.sha1(literal.encode("utf-8")).hexdigest()[:12]


def area_of(path):
    """Nazwa pliku w Crowdinie: katalog główny i pierwszy znaczący podkatalog."""
    parts = path.split("/")[:-1]
    root = parts[0] if parts else "inne"
    rest = [p for p in parts[1:] if p not in SKIP_DIRS and not p.startswith("_")]
    if root == "tgui":
        return "tgui"
    if root == "strings" or not rest:
        return root
    return f"{root}-{rest[0]}"


def tracked(pathspecs):
    out = subprocess.run(["git", "ls-files", "-z", *pathspecs], capture_output=True, text=True, encoding="utf-8")
    return [p for p in out.stdout.split("\0")[:-1]]


def player_files(pathspecs):
    for path in tracked(pathspecs):
        if path.endswith(".dmm"):
            yield path
            continue
        if ep.SKIP_PATH.search(path) or lm.NOT_PLAYER_TEXT.search(path):
            continue
        yield path


def read_lines(path):
    try:
        with open(path, encoding="utf-8", errors="strict", newline="") as f:
            return f.read().split("\n")
    except (OSError, UnicodeDecodeError):
        return None


def scan(known):
    """{literał: [(plik, linia, kod), ...]} dla polskich tekstów gracza w drzewie."""
    is_polish = lm.polish_detector(known)
    found = collections.OrderedDict()
    for path in player_files(lm.PATHSPECS):
        lines = read_lines(path)
        if lines is None:
            continue
        for number, line in enumerate(lines, 1):
            for lit in lm.line_literals(path, line.rstrip("\r")):
                if lit in found:
                    found[lit].append((path, number, line.strip()))
                elif lit in known or is_polish(lit):
                    found[lit] = [(path, number, line.strip())]
    return found


# ---------------------------------------------------------------- export

def export(args):
    known = lm.load_known(SOURCES)
    found = scan(known)
    existing = load_translations(args.existing) if args.existing else {}

    sources, polish = collections.defaultdict(dict), collections.defaultdict(dict)
    for lit, places in found.items():
        key = key_of(lit)
        path, number, code = places[0]
        area = area_of(path)
        en = known.get(lit)
        where = "\n".join(f"{p}:{n}" for p, n, _ in places[:LOCATIONS_IN_DESCRIPTION])
        if len(places) > LOCATIONS_IN_DESCRIPTION:
            where += f"\n(i jeszcze {len(places) - LOCATIONS_IN_DESCRIPTION} miejsc)"
        description = f"{where}\nKod: {code[:200]}"
        if not en:
            description += "\nBrak angielskiego oryginału: źródłem jest obecny tekst polski."
        description += "\nNie zmieniaj wstawek w nawiasach [ ] ani ${ }, cudzysłowów i znaków \\n."
        sources[area][key] = {"message": en or lit, "description": description}
        if key not in existing:
            polish[area][key] = {"message": lit}

    for lang, data in (("en", sources), ("pl", polish)):
        folder = os.path.join(args.out, lang)
        os.makedirs(folder, exist_ok=True)
        for old in glob.glob(os.path.join(folder, "*.json")):
            os.remove(old)
        for area, entries in data.items():
            with open(os.path.join(folder, f"{area}.json"), "w", encoding="utf-8", newline="\n") as f:
                json.dump(entries, f, ensure_ascii=False, indent=1, sort_keys=True)
                f.write("\n")
    total_pl = sum(len(v) for v in polish.values())
    no_en = sum(1 for lit in found if lit not in known)
    print(f"napisów: {len(found)} w {len(sources)} plikach, bez angielskiego oryginału: {no_en}, "
          f"polskich tłumaczeń do wysłania: {total_pl}")


# ---------------------------------------------------------------- apply

def load_translations(folder):
    out = {}
    for path in glob.glob(os.path.join(folder, "**", "*.json"), recursive=True):
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        for key, value in data.items():
            message = value.get("message") if isinstance(value, dict) else value
            if isinstance(message, str):
                out[key] = message
    return out


def counts(pattern, text):
    return collections.Counter(pattern.findall(text))


def check(old, new, is_dm):
    """Powód odrzucenia poprawki albo None."""
    if not new.strip():
        return "pusty tekst"
    if "\n" in new or "\r" in new:
        return "znak nowej linii (użyj \\n)"
    embed = DM_EMBED if is_dm else JS_EMBED
    if counts(embed, old) != counts(embed, new):
        return "zmienione wstawki w nawiasach"
    if is_dm and counts(DM_MACRO, old) != counts(DM_MACRO, new):
        return "zmienione makra \\the, \\n itp."
    for quote in "\"'`":
        if new.count(quote) > old.count(quote):
            return f"nowy znak {quote} (użyj „ ”)"
    if new.count("\\") != old.count("\\"):
        return "zmieniona liczba ukośników \\"
    return None


def keep_edges(old, new):
    """Spacje na brzegach literału bywają potrzebne przy sklejaniu tekstów: zostawiamy je."""
    lead = old[: len(old) - len(old.lstrip())]
    trail = old[len(old.rstrip()):]
    return lead + new.strip() + trail


def replace_in_line(path, line, fixes):
    if path.endswith(".dmm"):
        path = path[:-1]  # mapy TGM mają literały jak w DM
    lits = set(lm.line_literals(path, line))
    hit = [lit for lit in lits if lit in fixes]
    if not hit:
        return line
    # dłuższe najpierw, żeby krótki literał nie trafił w środek dłuższego
    for lit in sorted(hit, key=len, reverse=True):
        new = fixes[lit]
        if path.endswith(".dm"):
            line = line.replace(f'"{lit}"', f'"{new}"')
        elif path.endswith(".txt"):
            if line.strip() == lit:
                line = line.replace(lit, new)
        else:
            replaced = False
            for q in "\"'`":
                if f"{q}{lit}{q}" in line:
                    line = line.replace(f"{q}{lit}{q}", f"{q}{new}{q}")
                    replaced = True
            if not replaced:  # tekst JSX między znacznikami
                line = line.replace(lit, new)
    return line


def apply(args):
    known = lm.load_known(SOURCES)
    found = scan(known)
    by_key = {key_of(lit): lit for lit in found}
    translations = load_translations(args.folder)

    fixes, rejected, stale = {}, [], 0
    for key, message in translations.items():
        old = by_key.get(key)
        if old is None:
            stale += 1  # tekst zniknął z kodu albo już poprawiony
            continue
        new = keep_edges(old, message)
        if new == old:
            continue
        files = {p for p, _, _ in found[old]}
        is_dm = any(p.endswith(".dm") for p in files)
        reason = check(old, new, is_dm)
        if reason:
            rejected.append((old, new, reason, found[old][0]))
            continue
        fixes[old] = new

    changed_files = collections.Counter()
    if fixes:
        for path in player_files(APPLY_PATHSPECS):
            lines = read_lines(path)
            if lines is None:
                continue
            out = []
            for line in lines:
                cr = line.endswith("\r")
                body = line[:-1] if cr else line
                new = replace_in_line(path, body, fixes)
                if new != body:
                    changed_files[path] += 1
                out.append(new + ("\r" if cr else ""))
            if changed_files[path]:
                with open(path, "w", encoding="utf-8", newline="") as f:
                    f.write("\n".join(out))

    report = [f"Zatwierdzone poprawki z Crowdina: **{len(fixes)}** tekstów w **{len(changed_files)}** plikach."]
    if fixes:
        report += ["", "| Było | Jest |", "|---|---|"]
        for old, new in sorted(fixes.items()):
            report.append(f"| {md(old)} | {md(new)} |")
    if rejected:
        report += ["", f"Odrzucone ({len(rejected)}), do poprawienia w Crowdinie:", "",
                   "| Tekst | Propozycja | Powód | Miejsce |", "|---|---|---|---|"]
        for old, new, reason, (path, number, _) in rejected:
            report.append(f"| {md(old)} | {md(new)} | {reason} | `{path}:{number}` |")
    if stale:
        report += ["", f"Pominięte, bo tekstu nie ma już w kodzie: {stale}."]
    text = "\n".join(report) + "\n"
    if args.report:
        with open(args.report, "w", encoding="utf-8") as f:
            f.write(text)
    sys.stdout.write(text)
    if args.github_output:
        with open(args.github_output, "a", encoding="utf-8") as f:
            f.write(f"changed={'true' if changed_files else 'false'}\n")


def md(text):
    return "`" + text.replace("|", "\\|").replace("`", "'")[:300] + "`"


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("export")
    e.add_argument("--out", default="crowdin_out")
    e.add_argument("--existing", help="katalog z pobranymi tłumaczeniami pl")
    a = sub.add_parser("apply")
    a.add_argument("folder")
    a.add_argument("--report")
    a.add_argument("--github-output", default=os.environ.get("GITHUB_OUTPUT"))
    args = ap.parse_args()
    (export if args.cmd == "export" else apply)(args)


if __name__ == "__main__":
    main()
