"""Test pokrycia okien tgui: każdy polski tekst z kodu okien przez prawdziwy tłumacz.

Zbiera teksty tak, jak zobaczy je okno: literały i teksty JSX z jednej linii, zdania
z wstawkami i zdania łamane na kilka linii (tools/i18n/jsx_runs.py). Wstawki dostają
przykładową wartość (pierwszą gałąź warunku z napisami albo liczbę). Potem jest
(tgui/packages/tgui/i18n.coverage.test.ts) tłumaczy je słownikiem strings/i18n/en_chat.json
i zapisuje to, co zostało po polsku.

Użycie (z katalogu repo):
    python tools/i18n/ui_coverage.py [--lang ru]
Wynik: lista w data/i18n_ui_coverage.json (polskie resztki z plikiem i tekstem); dla innego
języka niż angielski data/i18n_ui_coverage_<język>.json.
"""

import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402
import jsx_runs  # noqa: E402
import list_missing as lm  # noqa: E402

INPUT = "data/i18n_ui_coverage_input.json"
OUTPUT = "data/i18n_ui_coverage.json"
# teksty owinięte przy budowie (tgui/i18n-jsx.cjs dump) i to, co z nich zostało po polsku
JSX_DUMP = "data/i18n_jsx_dump.json"
JSX_INPUT = "data/i18n_jsx_coverage_input.json"
JSX_OUTPUT = "data/i18n_jsx_coverage.json"
EXPR = re.compile(r"\$\{((?:[^{}]|\{[^{}]*\})*)\}")
TERNARY_JS = re.compile(r"""^[^"'?]+\?\s*(["'])((?:\\.|(?!\1).)*)\1\s*:\s*(["'])((?:\\.|(?!\3).)*)\3$""")


def sample(literal):
    """Tekst zdania z przykładowymi wartościami wstawek."""
    def value(match):
        expr = match.group(1).strip()
        ternary = TERNARY_JS.match(expr)
        if ternary:
            return ternary.group(2)
        string = jsx_runs.string_value(expr)
        return string if string is not None else "7"
    return unescape_js(EXPR.sub(value, literal))


def unescape_js(text):
    """Ucieczki napisu JS tak, jak zobaczy je okno (\n to nowa linia)."""
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": "\t"}.get(m.group(1), m.group(1)), text)


def collect():
    files = subprocess.run(["git", "ls-files", "-z", "tgui/packages/*.tsx", "tgui/packages/*.jsx",
                            "tgui/packages/*.ts", "tgui/packages/*.js"],
                           capture_output=True, text=True, encoding="utf-8", check=True).stdout.split("\0")[:-1]
    texts = {}
    for path in files:
        if lm.NOT_PLAYER_TEXT.search(path) or ep.SKIP_PATH.search(path) or "/tgui-dev-server/" in path:
            continue
        with open(path, encoding="utf-8", errors="replace") as f:
            content = f.read()
        if path.endswith(jsx_runs.JSX_EXT):
            for lit, _ in jsx_runs.runs(content):
                if jsx_runs.is_polish_run(lit):
                    texts.setdefault(sample(lit), (path, lit))
        for line in content.splitlines():
            for lit in ep.literals(path, line):
                if "${" in lit:
                    text = sample(lit)
                else:
                    text = unescape_js(lit).strip()
                if text and ep.is_polish(text) and ep.wordy(text):
                    texts.setdefault(text, (path, lit))
    return texts


def jsx_items():
    """Zdania z loadera z przykładowymi wartościami wstawek (pierwsza gałąź warunku z napisami)."""
    items = []
    for item in json.load(open(JSX_DUMP, encoding="utf-8")):
        if not ep.is_polish("".join(item["texts"])):
            continue
        slots = []
        for src in item["slots"]:
            ternary = TERNARY_JS.match(src.strip())
            string = jsx_runs.string_value(src)
            slots.append(ternary.group(2) if ternary else string if string is not None else "7")
        items.append({"file": item["file"], "kind": item["kind"], "texts": item["texts"], "slots": slots})
    return items


def main():
    global OUTPUT, JSX_OUTPUT
    lang = sys.argv[sys.argv.index("--lang") + 1] if "--lang" in sys.argv else "en"
    if lang != "en":
        OUTPUT = f"data/i18n_ui_coverage_{lang}.json"
        JSX_OUTPUT = f"data/i18n_jsx_coverage_{lang}.json"
    yarn = next(f for f in os.listdir("tgui/.yarn/releases") if f.endswith(".cjs"))
    node = os.path.abspath("tools/bootstrap/node.bat" if os.name == "nt" else "tools/bootstrap/node")
    os.makedirs("data", exist_ok=True)  # świeży klon nie ma data/, a zrzut tam pisze
    subprocess.run([node, f".yarn/releases/{yarn}", "node", "i18n-jsx.cjs", "dump", os.path.abspath(JSX_DUMP)],
                   cwd="tgui", shell=os.name == "nt", check=True)
    os.makedirs("data", exist_ok=True)
    with open(JSX_INPUT, "w", encoding="utf-8") as f:
        json.dump(jsx_items(), f, ensure_ascii=False)
    texts = collect()
    os.makedirs("data", exist_ok=True)
    with open(INPUT, "w", encoding="utf-8") as f:
        # key: literał w kodzie (klucz słownika, strings/i18n/en_translated.json), text: co widzi okno
        json.dump([{"text": t, "file": p, "key": k} for t, (p, k) in sorted(texts.items())], f, ensure_ascii=False)
    print(f"tekstów do sprawdzenia: {len(texts)} -> {INPUT}")
    env = dict(os.environ, CI="true", I18N_COVERAGE=os.path.abspath(INPUT), I18N_COVERAGE_OUT=os.path.abspath(OUTPUT),
               I18N_JSX=os.path.abspath(JSX_INPUT), I18N_JSX_OUT=os.path.abspath(JSX_OUTPUT), I18N_LANG=lang)
    subprocess.run([node, f".yarn/releases/{yarn}", "jest", "packages/tgui/i18n.coverage"], cwd="tgui", env=env,
                   shell=os.name == "nt", check=True)
    if os.path.exists(OUTPUT):
        left = json.load(open(OUTPUT, encoding="utf-8"))
        sys.stdout.reconfigure(encoding="utf-8")
        print(f"po polsku zostało: {len(left)} z {len(texts)}")
    if os.path.exists(JSX_OUTPUT):
        jsx_total = len(json.load(open(JSX_INPUT, encoding="utf-8")))
        jsx_left = json.load(open(JSX_OUTPUT, encoding="utf-8"))
        print(f"przy budowie (t/tt/ts) po polsku zostało: {len(jsx_left)} z {jsx_total}"
              " (te tłumaczy w oknie zapasowe tłumaczenie DOM)")


if __name__ == "__main__":
    main()
