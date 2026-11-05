"""Zdania z okien tgui przecięte wstawkami JSX i ich angielskie oryginały.

W JSX zdanie bywa rozbite wyrażeniem:
    Przeciągnij kartę ID, aby {locked ? 'odblokować' : 'zablokować'} ten
    interfejs.
React robi z tego kilka sąsiednich węzłów tekstowych, a extract_pairs.py widzi tylko
kawałki linii. Tu składamy dzieci elementu (tekst + wyrażenia, bez zagnieżdżonych
znaczników) w jeden literał JS w postaci `...${wyrażenie}...`. build_chat_dict.py robi
z niego szablon, a tgui/i18nDom.ts tłumaczy razem sąsiednie węzły tekstowe elementu.

Oryginał szukamy w starszych wersjach pliku w naszej historii i w tym samym pliku
w repozytoriach innych serwerów. Wstawki parujemy po szkielecie (wyrażenie bez
napisów), więc kolejność wstawek musi być ta sama.

Użycie (z katalogu repo):
    python tools/i18n/jsx_runs.py --tree tg=../tgstation --tree bee=<katalog> ...
Wynik: strings/i18n/en_jsx.json {polski literał: angielski literał}
"""

import argparse
import collections
import difflib
import html
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import extract_pairs as ep  # noqa: E402

OUT = "strings/i18n/en_jsx.json"
JSX_EXT = (".tsx", ".jsx")
IDENT = re.compile(r"[\w$.)\]]")
CODE_IN_TEXT = re.compile(r"=>|;\s*(?://|/\*|const|let|type|function|export|interface|return)\b|\b(?:const|let) \w+\s*[:=]|\bexport (?:function|const|default)\b|\bfunction \w+\(")
JS_STRING = re.compile(r"""(["'`])((?:\\.|(?!\1).)*)\1""", re.S)


def skip_string(src, i):
    """Indeks za napisem JS zaczynającym się w src[i]."""
    quote = src[i]
    i += 1
    while i < len(src):
        c = src[i]
        if c == "\\":
            i += 2
            continue
        if c == quote:
            return i + 1
        if quote == "`" and src.startswith("${", i):
            i = skip_braces(src, i + 1)
            continue
        i += 1
    return i


def skip_braces(src, i):
    """src[i] == '{': indeks za pasującym '}'."""
    depth = 0
    while i < len(src):
        c = src[i]
        if c in "'\"`":
            i = skip_string(src, i)
            continue
        if src.startswith("//", i):
            j = src.find("\n", i)
            i = len(src) if j < 0 else j
            continue
        if src.startswith("/*", i):
            j = src.find("*/", i)
            i = len(src) if j < 0 else j + 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return i


def tag_end(src, i):
    """src[i] == '<' na początku znacznika JSX: (indeks za '>', czy samozamykający) albo None."""
    j = i + 1
    while j < len(src):
        c = src[j]
        if c in "'\"":
            j = skip_string(src, j)
            continue
        if c == "{":
            j = skip_braces(src, j)
            continue
        if c == "<":
            return None
        if c == ">":
            return j + 1, src[j - 1] == "/"
        j += 1
    return None


def is_tag_start(src, i):
    """'<' otwiera znacznik JSX, a nie porównanie ani typ generyczny (useBackend<Data>)."""
    nxt = src[i + 1:i + 2]
    if not (nxt.isalpha() or nxt in ("/", ">")):
        return False
    if nxt == "/":
        return True  # znacznik zamykający
    k = i - 1
    while k >= 0 and src[k] in " \t\r\n":
        k -= 1
    if k < 0:
        return True
    if IDENT.match(src[k]):
        # "return <Box>" i "=> <Box>" są JSX; "foo<Bar>" to typ
        return src[max(0, k - 5):k + 1] == "return" or src[k] == ">"
    return True


def clean_text(text):
    """Biały znak tekstu JSX jak w Babel/TypeScript: linie bez wcięć, sklejone spacją."""
    lines = text.split("\n")
    out = []
    for n, line in enumerate(lines):
        line = line.replace("\t", " ")
        if n > 0:
            line = line.lstrip(" \r")
        if n < len(lines) - 1:
            line = line.rstrip(" \r")
        if line:
            out.append(line)
    return html.unescape(" ".join(out))


def string_value(expr):
    """Wartość wyrażenia, które jest samym napisem ({' '}, {'tekst'}), inaczej None."""
    m = JS_STRING.fullmatch(expr.strip())
    if m and (m.group(1) != "`" or "${" not in m.group(2)):
        return m.group(2)
    return None


def in_text_tag(src, j):
    """W tekście JSX każdy '<' z literą, '/' albo '>' za nim to znacznik."""
    return src[j] == "<" and (src[j + 1:j + 2].isalpha() or src[j + 1:j + 2] in ("/", ">"))


def children(src, i):
    """Dzieci elementu od src[i] do najbliższego znacznika: ([("raw", tekst) | ("e", wyrażenie)], koniec)."""
    parts = []
    j = i
    while j < len(src):
        if in_text_tag(src, j):
            break
        if src[j] == "{":
            end = skip_braces(src, j)
            expr = src[j + 1:end - 1]
            parts.append(("e", expr))
            j = end
            continue
        k = j
        while k < len(src) and src[k] != "{" and not in_text_tag(src, k):
            k += 1
        parts.append(("raw", src[j:k]))
        j = k
    return parts, j


def escape_literal(text):
    return text.replace("\\", "\\\\").replace("`", "\\`").replace("${", "\\${")


def runs(src):
    """Zdania z wstawkami: lista (literał `...${e}...`, szkielet wstawek)."""
    found = []
    i = 0
    while i < len(src):
        c = src[i]
        if c in "'\"`":
            i = skip_string(src, i)
            continue
        if src.startswith("//", i):
            j = src.find("\n", i)
            i = len(src) if j < 0 else j
            continue
        if src.startswith("/*", i):
            j = src.find("*/", i)
            i = len(src) if j < 0 else j + 2
            continue
        if c == "<" and is_tag_start(src, i):
            end = tag_end(src, i)
            if not end:
                i += 1
                continue
            i, self_closing = end
            if not self_closing:
                # tekst dzieci pomijamy (apostrof w "Don't" to nie napis JS),
                # a w wyrażeniach szukamy zagnieżdżonych elementów
                parts, i = children(src, i)
                found.extend(split_run(parts))
                for kind, val in parts:
                    if kind == "e":
                        found.extend(runs(val))
            continue
        i += 1
    return found


def split_run(parts):
    """Ciąg dzieci -> zdania. Wyrażenie z JSX w środku (<b>, warunek z elementem) rozdziela zdanie."""
    out, cur = [], []

    def flush():
        literal, exprs, text = "", [], ""
        for kind, val in cur:
            if kind == "t":
                literal += escape_literal(val)
                text += val
            else:
                literal += "${" + val.strip() + "}"
                exprs.append(val)
        cur.clear()
        # kod TS złapany jako tekst (typ generyczny wzięty za znacznik): średniki,
        # strzałki i słowa kluczowe w tekście albo instrukcje w wyrażeniu
        if CODE_IN_TEXT.search(text) or any(";" in JS_STRING.sub("", e) for e in exprs):
            return
        if exprs and re.search(ep.LETTERS + r"{2,}", text):
            out.append((literal.strip(), tuple(expr_skeleton(e) for e in exprs)))

    for kind, val in parts:
        if kind == "raw":
            text = clean_text(val)
            if text:
                cur.append(("t", text))
            continue
        expr = val.strip()
        if not expr or expr.startswith("/*") or expr.startswith("//"):
            continue  # komentarz JSX
        value = string_value(expr)
        if value is not None:
            cur.append(("t", value))
        elif re.search(r"<\s*[A-Za-z/>]", expr):
            flush()
        else:
            cur.append(("e", expr))
    flush()
    return out


def expr_skeleton(expr):
    return re.sub(r"\s+", "", JS_STRING.sub("''", expr))


def plain(literal):
    """Sam tekst literału, bez wstawek (do klasyfikacji języka)."""
    return re.sub(r"\$\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}", " ", literal)


def is_polish_run(literal):
    return ep.is_polish(plain(literal))


def is_english_run(literal):
    text = plain(literal)
    return ep.is_english(text) and not ep.is_polish(text)


def with_pl_exprs(en_literal, pl_literal):
    """Angielski literał z wyrażeniami z polskiego (ten sam szkielet, ta sama kolejność),
    żeby build_chat_dict.py połączył wstawki po tekście wyrażenia."""
    pattern = re.compile(r"\$\{((?:[^{}]|\{[^{}]*\})*)\}")
    pl_exprs = [m.group(1) for m in pattern.finditer(pl_literal)]
    it = iter(pl_exprs)
    return pattern.sub(lambda m: "${" + next(it) + "}", en_literal)


def pair_runs(ours, theirs, sink):
    """Paruje zdania dwóch wersji pliku po szkieletach wstawek (difflib)."""
    sig_a = [s for _, s in ours]
    sig_b = [s for _, s in theirs]
    count_a, count_b = collections.Counter(sig_a), collections.Counter(sig_b)
    sm = difflib.SequenceMatcher(None, sig_a, sig_b, autojunk=False)
    for block in sm.get_matching_blocks():
        for k in range(block.size):
            pl, sig = ours[block.a + k]
            en, _ = theirs[block.b + k]
            # pojedyncze dopasowanie częstego szkieletu ({data.name}) bywa przypadkowe
            if block.size == 1 and (count_a[sig] > 1 or count_b[sig] > 1):
                continue
            if pl != en and is_polish_run(pl) and is_english_run(en):
                sink[pl][with_pl_exprs(en, pl)] += 1


def git_versions(path):
    """Treści pliku w kolejnych commitach naszej historii (od najstarszej)."""
    log = subprocess.run(["git", "log", "--format=%H", "--follow", "--name-only", "--", path],
                         capture_output=True, text=True, encoding="utf-8").stdout
    entries, commit = [], None
    for line in log.splitlines():
        if re.fullmatch(r"[0-9a-f]{40}", line):
            commit = line
        elif line.strip() and commit:
            entries.append((commit, line.strip()))
            commit = None
    out = []
    for commit, name in reversed(entries):
        shown = subprocess.run(["git", "show", f"{commit}:{name}"], capture_output=True)
        if shown.returncode == 0:
            out.append(shown.stdout.decode("utf-8", errors="replace"))
    return out


def tree_versions(trees, path):
    rel = path[path.find("tgui/packages/"):]
    stem = os.path.splitext(rel)[0]
    out = []
    for root in trees:
        for ext in JSX_EXT:
            full = os.path.join(root, stem + ext)
            if os.path.exists(full):
                with open(full, encoding="utf-8", errors="replace") as f:
                    out.append(f.read())
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", action="append", default=[], help="etykieta=katalog z kodem serwera")
    ap.add_argument("--out", default=OUT)
    args = ap.parse_args()
    trees = [t.split("=", 1)[1] for t in args.tree]

    files = subprocess.run(["git", "ls-files", "-z", "tgui/packages/*.tsx", "tgui/packages/*.jsx"],
                           capture_output=True, text=True, encoding="utf-8", check=True).stdout.split("\0")[:-1]
    sink = collections.defaultdict(collections.Counter)
    total = 0
    for path in files:
        with open(path, encoding="utf-8", errors="replace") as f:
            ours = runs(f.read())
        polish = [r for r in ours if is_polish_run(r[0])]
        if not polish:
            continue
        total += len(polish)
        for version in git_versions(path) + tree_versions(trees, path):
            pair_runs(ours, runs(version), sink)
    pairs = {pl: c.most_common(1)[0][0] for pl, c in sink.items()}
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(pairs.items())), f, ensure_ascii=False, indent=0)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku
    print(f"zdania z wstawkami po polsku: {total}, z oryginałem: {len(pairs)} -> {args.out}")


if __name__ == "__main__":
    main()
