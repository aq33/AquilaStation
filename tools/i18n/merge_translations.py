"""Scala tłumaczenia (agentów albo ręczne) do strings/i18n/en_translated.json.

Wejście: pary plików paczka_NN.jsonl (lista z list_missing.py) i paczka_NN.out.json
({polski literał: angielski literał}). Tłumacz czasem przekłada też napisy wewnątrz
wstawek ([on ? "włączony" : "wyłączony"] -> [on ? "on" : "off"]). Panel dopasowuje
wstawki po treści wyrażenia, więc taką wstawkę przywracamy do polskiej postaci,
a jej napisy dokładamy jako osobne pary ("włączony" -> "on"): tłumacz w panelu
przełoży je, gdy trafią do wiadomości jako wartość.

Użycie (z katalogu repo):
    python tools/i18n/merge_translations.py <katalog z paczkami>
"""

import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
import build_chat_dict as bcd  # noqa: E402
import extract_pairs as ep  # noqa: E402

OUT = "strings/i18n/en_translated.json"
STRING = re.compile(r'"((?:\\.|[^"\\])*)"')


def code_shape(expr):
    """Wyrażenie bez treści napisów: [a ? "x" : "y"] i [a ? "p" : "q"] mają ten sam kształt."""
    return re.sub(r"\s+", "", STRING.sub('""', expr))


def fix_embeds(pl, en, nested):
    pl_exprs = [v for k, v in bcd.parse_dm_literal(pl) if k == "e"]
    en_parts = bcd.parse_dm_literal(en)
    if not any(k == "e" for k, _ in en_parts):
        return en
    pl_norm = {bcd.norm_expr(e) for e in pl_exprs}
    unused = [e for e in pl_exprs]
    replaced = {}
    for kind, val in en_parts:
        if kind != "e" or bcd.norm_expr(val) in pl_norm:
            continue
        shape = code_shape(val)
        match = next((e for e in unused if code_shape(e) == shape and STRING.search(e)), None)
        if not match:
            continue
        unused.remove(match)
        replaced[val] = match
        pl_strings, en_strings = STRING.findall(match), STRING.findall(val)
        if len(pl_strings) == len(en_strings):
            for p, e in zip(pl_strings, en_strings):
                if p != e and ep.wordy(p):
                    nested.setdefault(p, e)
    for val, match in replaced.items():
        en = en.replace(f"[{val}]", f"[{match}]", 1)
    return en


def main():
    folder = sys.argv[1]
    merged = {}
    if os.path.exists(OUT):
        merged = json.load(open(OUT, encoding="utf-8"))
    nested, stats = {}, {"pary": 0, "bez zmian": 0, "poprawione wstawki": 0}
    for out_path in sorted(glob.glob(os.path.join(folder, "*.out.json"))):
        in_path = out_path.replace(".out.json", ".jsonl")
        files = {}
        if os.path.exists(in_path):
            for line in open(in_path, encoding="utf-8"):
                if line.strip():
                    item = json.loads(line)
                    files[item["pl"]] = item["file"]
        for pl, en in json.load(open(out_path, encoding="utf-8")).items():
            if not isinstance(en, str) or en == pl:
                stats["bez zmian"] += 1
                continue
            if files.get(pl, "").endswith(".dm"):
                fixed = fix_embeds(pl, en, nested)
                stats["poprawione wstawki"] += fixed != en
                en = fixed
            merged[pl] = en
            stats["pary"] += 1
    for pl, en in nested.items():
        merged.setdefault(pl, en)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(merged.items())), f, ensure_ascii=False, indent=0)
    sys.stdout.reconfigure(encoding="utf-8")
    print(f"{stats}, napisy z wstawek: {len(nested)}, razem w {OUT}: {len(merged)}")


if __name__ == "__main__":
    main()
