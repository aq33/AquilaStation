"""Teksty okien tgui z drzewa składni (tgui/i18n-jsx.cjs), w postaci kluczy słownika.

Loader webpacka owija w okna dokładnie te teksty, więc słownik (build_chat_dict.py), lista
braków (list_missing.py) i test pokrycia (ui_coverage.py) biorą je stąd, a nie ze skanu
linii wyrażeniami regularnymi (ten gubił np. słowo w osobnej linii i tekst z nawiasem).

Klucz: stały tekst bez spacji z brzegów albo literał JS "tekst ${wyrażenie} tekst"
(ta sama postać co tools/i18n/jsx_runs.py i dynamiczne literały `...${x}...` w kodzie).
Bez Node (brak tools/bootstrap) zwraca None i narzędzia wracają do starego skanu.
"""

import json
import os
import subprocess
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_UNSET = object()
_cache = _UNSET


def escape_literal(text):
    return text.replace("\\", "\\\\").replace("`", "\\`").replace("${", "\\${")


def literal(item):
    """Klucz słownika dla tekstu z loadera."""
    texts, slots = item["texts"], item["slots"]
    if not slots:
        return texts[0].strip()
    out = escape_literal(texts[0])
    for slot, text in zip(slots, texts[1:]):
        out += "${" + slot.strip() + "}" + escape_literal(text)
    return out.strip()


def _run_loader(*args):
    """Wynik `node i18n-jsx.cjs <args> <plik wyjścia>` z kluczami słownika albo None (bez Node)."""
    tgui = os.path.join(ROOT, "tgui")
    releases = os.path.join(tgui, ".yarn", "releases")
    node = os.path.join(ROOT, "tools", "bootstrap", "node.bat" if os.name == "nt" else "node")
    if not os.path.isdir(releases) or not os.path.exists(node):
        return None
    yarn = next((f for f in os.listdir(releases) if f.endswith(".cjs")), None)
    if not yarn:
        return None
    fd, out = tempfile.mkstemp(suffix=".json")
    os.close(fd)
    try:
        done = subprocess.run([node, os.path.join(".yarn", "releases", yarn), "node", "i18n-jsx.cjs", *args, out],
                              cwd=tgui, capture_output=True, shell=os.name == "nt")
        if done.returncode != 0:
            return None
        with open(out, encoding="utf-8") as f:
            items = json.load(f)
    finally:
        os.remove(out)
    for item in items:
        item["literal"] = literal(item)
    return items


def dump():
    """Lista {file, line, endLine, column, endColumn, kind, texts, slots, literal} wszystkich okien
    albo None (bez Node). Kolumny w jednostkach UTF-16."""
    global _cache
    if _cache is not _UNSET:
        return _cache
    # porażka też zostaje zapamiętana: bez Node nie próbujemy przy każdym pliku
    _cache = _run_loader("dump")
    return _cache


def dump_file(source_path, rel):
    """Jak dump(), ale dla jednego pliku z dowolnego miejsca (testy); rel to ścieżka w polu file."""
    return _run_loader("dump-file", os.path.abspath(source_path), rel)
