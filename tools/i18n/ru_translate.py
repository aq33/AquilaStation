"""Tłumaczenie brakujących tekstów wersji rosyjskiej partiami (agenci) i scalanie z kontrolą.

    python tools/i18n/ru_translate.py batches DIR [--size 400]
    python tools/i18n/ru_translate.py merge DIR

batches: teksty z en_all.json (klucz = polski literał), których nie ma w ru_translated.json
ani ru_manual.json, w plikach DIR/batch_NNN.json:
[{"id": 1, "pl": "...", "en": "...", "ru": "..."}]. ru to kandydat z innego rosyjskiego serwera
(ru_candidates.json z tools/i18n/ru_sources.py): bywa dobry, bywa złą parą albo ma ich wstawki.

Tłumacz zapisuje DIR/out_NNN.json: {"1": "tekst po rosyjsku", "2": "=", ...} według zasad
z aquila/SLOWNIK_TLUMACZEN_RU.md; "=" zatwierdza kandydata bez zmian.

merge: sprawdza każde tłumaczenie (te same wstawki co polski tekst, te same znaczniki HTML i \\n,
cyrylica, bez polskich liter poza wstawkami), dopisuje dobre do strings/i18n/ru_translated.json,
a odrzucone zapisuje w DIR/rejected.json z powodem (do poprawki następną partią).
"""

import argparse
import collections
import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
import build_chat_dict as bcd  # noqa: E402
import extract_pairs as ep  # noqa: E402

TRANSLATED = "strings/i18n/ru_translated.json"
SOURCES = [TRANSLATED, "strings/i18n/ru_manual.json"]
CYR = re.compile(r"[А-Яа-яЁё]")
PL_LETTERS = re.compile(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]")
LATIN_WORD = re.compile(r"[A-Za-z]{2,}")
# \[tekst\] w DM to zwykły tekst w nawiasie (do tłumaczenia), nie wstawka
DM_EMBED = re.compile(r"(?<!\\)\[(?:[^\[\]\"]|\"[^\"]*\")*(?<!\\)\]")
JS_EMBED = re.compile(r"\$\{(?:[^{}]|\{[^{}]*\})*\}")


def load(path):
    if not os.path.exists(path):
        return {}
    data = json.load(open(path, encoding="utf-8"))
    data.pop("_komentarz", None)
    return data


def is_js(text):
    return "${" in text


def embed_keys(text):
    """Wstawki literału: wyrażenie znormalizowane albo, dla warunku z dwoma napisami, sam warunek."""
    parse = bcd.parse_js_literal if is_js(text) else bcd.parse_dm_literal
    keys = []
    for kind, val in parse(text):
        if kind != "e":
            continue
        condition = bcd.ternary_condition(val)
        if condition and bcd.literal_ternary(val, is_js(text)):
            keys.append("?" + condition)
        else:
            keys.append(bcd.norm_expr(val))
    return collections.Counter(keys)


def visible(text):
    """Tekst bez wstawek i znaczników (to, co przetłumaczono)."""
    text = JS_EMBED.sub(" ", text) if is_js(text) else text
    prev = None
    while prev != text:
        prev, text = text, DM_EMBED.sub(" ", text)
    return bcd.TAG.sub(" ", text)


def tags(text):
    return [m.groups() for m in bcd.TAG_NAME.finditer("".join(re.findall(r"<[^>]*>", text)))]


def same_edges(pl, ru):
    """Odstępy na brzegach jak w polskim (panel dopasowuje cały tekst)."""
    lead = pl[:len(pl) - len(pl.lstrip())]
    tail = pl[len(pl.rstrip()):]
    return lead + ru.strip() + tail


def check(pl, ru):
    """Powód odrzucenia albo None."""
    if not isinstance(ru, str) or not ru.strip():
        return "puste"
    if embed_keys(pl) != embed_keys(ru):
        return "inne wstawki"
    if tags(pl) != tags(ru):
        return "inne znaczniki HTML"
    if pl.count("\\n") != ru.count("\\n") or pl.count("\n") != ru.count("\n"):
        return "inne końce linii"
    shown = visible(ru)
    if PL_LETTERS.search(shown):
        return "polskie litery"
    if not CYR.search(shown):
        # bez cyrylicy tylko teksty bez słów do tłumaczenia (skróty, kody, nazwy własne)
        if visible(pl).strip() != shown.strip() and LATIN_WORD.search(visible(pl)) and ep.is_polish(pl):
            return "brak cyrylicy"
    return None


def batches(args):
    en_all = load("strings/i18n/en_all.json")
    done = {}
    for path in SOURCES:
        done.update(load(path))
    candidates = load(os.path.join(os.environ.get("TEMP", "/tmp"), "ru", "ru_candidates.json"))
    todo = [(pl, en) for pl, en in sorted(en_all.items())
            if isinstance(en, str) and pl not in done and re.search(r"[^\W\d_]{2}", visible(pl))]
    os.makedirs(args.dir, exist_ok=True)
    for old in glob.glob(os.path.join(args.dir, "batch_*.json")):
        os.remove(old)
    index = {}
    number = 0
    for start in range(0, len(todo), args.size):
        number += 1
        items = []
        for i, (pl, en) in enumerate(todo[start:start + args.size], start=1):
            item = {"id": i, "pl": pl, "en": en}
            if pl in candidates:
                item["ru"] = candidates[pl]["ru"]
            items.append(item)
            index[f"{number:03d}:{i}"] = pl
        with open(os.path.join(args.dir, f"batch_{number:03d}.json"), "w", encoding="utf-8") as f:
            json.dump(items, f, ensure_ascii=False, indent=0)
    with open(os.path.join(args.dir, "index.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False)
    words = sum(len(visible(pl).split()) for pl, _ in todo)
    print(f"{len(todo)} tekstów ({words} słów) w {number} partiach po {args.size}")


def merge(args):
    index = load(os.path.join(args.dir, "index.json"))
    candidates = load(os.path.join(os.environ.get("TEMP", "/tmp"), "ru", "ru_candidates.json"))
    translated = load(TRANSLATED)
    rejected, stats = {}, collections.Counter()
    for path in sorted(glob.glob(os.path.join(args.dir, "out_*.json"))):
        number = re.search(r"out_(\d+)", path).group(1)
        try:
            data = json.load(open(path, encoding="utf-8"))
        except json.JSONDecodeError as error:
            stats["zły JSON: " + os.path.basename(path)] += 1
            print("zły JSON:", path, error)
            continue
        for item_id, ru in data.items():
            pl = index.get(f"{number}:{item_id}")
            if pl is None:
                stats["nieznany id"] += 1
                continue
            if isinstance(ru, str) and ru.strip() == "=":
                ru = candidates.get(pl, {}).get("ru")
                stats["kandydat zatwierdzony"] += 1
            reason = check(pl, ru)
            if reason:
                rejected[pl] = {"ru": ru, "powód": reason}
                stats["odrzucone: " + reason] += 1
                continue
            translated[pl] = same_edges(pl, ru)
            stats["przyjęte"] += 1
    with open(TRANSLATED, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(translated.items())), f, ensure_ascii=False, indent=0)
        f.write("\n")
    with open(os.path.join(args.dir, "rejected.json"), "w", encoding="utf-8") as f:
        json.dump(rejected, f, ensure_ascii=False, indent=1)
    for k, v in stats.most_common():
        print(f"  {k}: {v}")
    print(f"{TRANSLATED}: {len(translated)} tłumaczeń")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["batches", "merge"])
    ap.add_argument("dir")
    ap.add_argument("--size", type=int, default=400)
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    {"batches": batches, "merge": merge}[args.command](args)


if __name__ == "__main__":
    main()
