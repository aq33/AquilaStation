"""Wyciąga pary tekstów PL -> EN z historii gita i z różnicy względem upstreamu.

Gra jest po polsku, a angielskie oryginały zostały w historii: każda linia, w której
commit zamienił angielski literał na polski, daje parę słownika. Drugie źródło to
różnica bieżącego drzewa z upstreamem NSV13 (historia jest squashowana, więc
spolszczenia sprzed squasha widać tylko tak).

Użycie (z katalogu repo):
    python tools/i18n/extract_pairs.py [--upstream nsv13up/master] [--rev aq33/master]

Wynik:
    strings/i18n/en_pairs.json  - słownik {polski literał: angielski literał}
    na stdout (i do --report, jeśli podany) - pokrycie: ile polskich tekstów w drzewie ma odpowiednik
"""

import argparse
import collections
import difflib
import json
import os
import re
import subprocess
import sys

CODE_EXT = (".dm", ".tsx", ".jsx", ".ts", ".js")
TEXT_EXT = (".txt", ".json")
PATHSPECS = ["*.dm", "*.tsx", "*.jsx", "*.ts", "*.js", "strings/*.txt", "strings/*.json"]
UI_PATHSPECS = ["tgui/packages/*.tsx", "tgui/packages/*.jsx", "tgui/packages/*.ts", "tgui/packages/*.js"]
# tools/ tylko w katalogu głównym: code/game/objects/items/tools/ to zwykły kod gry
SKIP_PATH = re.compile(r"^(tools|_maps|SQL|html/changelogs)/|(^|/)(node_modules|\.yarn)/|\.bundle\.|^strings/i18n/")

PL_DIACRITICS = re.compile(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]")
PL_WORDS = re.compile(
    r"\b(się|jest|nie|nic|jak|już|tylko|który|która|które|jego|jej|ich|oraz|albo|"
    r"czy|przez|dla|ale|tego|tym|ten|ta|to|że|na|do|od|po|za|ze|we|aby|żeby|"
    r"możesz|musisz|zostało|został|została|jesteś|twój|twoja|twoje|swój)\b",
    re.I,
)
EN_WORDS = re.compile(
    r"\b(the|you|your|is|are|was|of|and|with|this|that|it|its|to|from|into|on|"
    r"can|cannot|can't|has|have|be|been|not|no|an|a|for|at|by|in|out|off)\b",
    re.I,
)
IDENTIFIER = re.compile(r"^[A-Za-z0-9_./:\-#%]*$")
NAME_ASSIGN = re.compile(r"\b(name|desc|real_name|singular_name|gender_name|title|plural_name|"
                         r"description|announcement|message|text|tip|tooltip|label)\s*[:=]")


def git(*args):
    out = subprocess.run(["git", *args], capture_output=True, check=True)
    return out.stdout.decode("utf-8", errors="replace")


# ---------------------------------------------------------------- literały

def dm_strings(line):
    """Literały "..." z linii DM. Osadzenia [expr] zostają w tekście (z zagnieżdżonymi stringami)."""
    out = []
    i, n = 0, len(line)
    while i < n:
        c = line[i]
        if c == "/" and line.startswith("//", i):
            break
        if c == "'":  # ścieżka do pliku w DM
            j = line.find("'", i + 1)
            i = n if j < 0 else j + 1
            continue
        if c != '"':
            i += 1
            continue
        j, depth, buf = i + 1, 0, []
        while j < n:
            ch = line[j]
            if ch == "\\" and j + 1 < n:
                buf.append(line[j:j + 2])
                j += 2
                continue
            if ch == "[":
                depth += 1
            elif ch == "]" and depth:
                depth -= 1
            elif ch == '"' and depth == 0:
                break
            buf.append(ch)
            j += 1
        out.append("".join(buf))
        i = j + 1
    return out


QUOTED_JS = re.compile(r"""(["'`])((?:\\.|(?!\1).)*)\1""")
JSX_TEXT = re.compile(r">([^<>{}]*[^\s<>{}][^<>{}]*)<")
CODEY = re.compile(r"[=;(){}<>]|^\s*(import|export|const|let|return|if|case)\b")


def js_strings(line):
    s = line.strip()
    if s.startswith("//") or s.startswith("*") or s.startswith("/*"):
        return []
    out = [m.group(2) for m in QUOTED_JS.finditer(line)]
    out += [m.group(1).strip() for m in JSX_TEXT.finditer(line)]
    # cała linia to tekst JSX; linia z samym literałem ('...',) to napis JS, już wyżej
    if s and s[0] not in "'\"`" and not CODEY.search(s) and re.search(LETTERS + r"{2,}\s", s + " ") and " " in s:
        out.append(s)  # cała linia to tekst JSX
    return out


def logical_lines(path, lines):
    """Linie DM po sklejeniu kontynuacji: tekst kończący się "\\" ciągnie się w następnej
    linii (bez jej wcięcia), tak jak go widzi kompilator i gracz. Inne pliki bez zmian."""
    if not path.endswith(".dm"):
        return list(lines)
    out, pending = [], None
    for line in lines:
        line = line.rstrip("\r")
        if pending is not None:
            line = pending + line.lstrip()
            pending = None
        if line.endswith("\\") and not line.endswith("\\\\"):
            pending = line[:-1]
            continue
        out.append(line)
    if pending is not None:
        out.append(pending)
    return join_text_blocks(out)


def block_string_start(line, in_comment):
    """Początek napisu {" w kodzie linii (nie w komentarzu /* */ ani //, nie w "..." ani w
    surowym @'...'/@"..."): (indeks albo -1, czy linia kończy się w komentarzu blokowym)."""
    i, n = 0, len(line)
    while i < n:
        if in_comment:
            end = line.find("*/", i)
            if end < 0:
                return -1, True
            in_comment, i = False, end + 2
            continue
        if line.startswith("/*", i):
            in_comment, i = True, i + 2
            continue
        if line.startswith("//", i):
            return -1, False
        if line.startswith('{"', i):
            return i, False
        c = line[i]
        if c == "@" and i + 1 < n and line[i + 1] in "'\"":
            end = line.find(line[i + 1], i + 2)
            i = n if end < 0 else end + 1
            continue
        if c in "'\"":
            j = i + 1
            while j < n and line[j] != c:
                j += 2 if line[j] == "\\" else 1
            i = j + 1
            continue
        i += 1
    return -1, in_comment


def join_text_blocks(lines):
    """Napis {"..."} na kilka linii (opisy, HTML okien) jako jeden literał "...\\n...": gracz widzi
    cały tekst naraz, a czytany linia po linii dawał tylko kawałek pierwszej linii."""
    out, i, in_comment = [], 0, False
    # najbliższa linia z "} od danej (liczona raz: przy niezamkniętym {" szukanie od każdej linii
    # było kwadratowe, co przy dużych hunkach historii innych serwerów trwało godzinami)
    next_close, nxt = [len(lines)] * (len(lines) + 1), len(lines)
    for k in range(len(lines) - 1, -1, -1):
        if '"}' in lines[k]:
            nxt = k
        next_close[k] = nxt
    while i < len(lines):
        line = lines[i]
        start, in_comment = block_string_start(line, in_comment)
        if start < 0 or line.find('"}', start + 2) >= 0:
            out.append(line)
            i += 1
            continue
        j = next_close[i + 1]
        if j >= len(lines):  # niezamknięty: zostawiamy linie bez zmian
            out.append(line)
            i += 1
            continue
        parts = [line[start + 2:]] + lines[i + 1:j]
        end = lines[j].find('"}')
        parts.append(lines[j][:end])
        content = "\n".join(parts)
        # cudzysłów wewnątrz {"..."} jest dozwolony bez ucieczki; w "..." musi ją mieć
        content = re.sub(r'(?<!\\)"', r'\\"', content).replace("\n", "\\n")
        out.append(line[:start] + '"' + content + '"' + lines[j][end + 2:])
        i = j + 1
    return out


def literals(path, line):
    if path.endswith(".dm"):
        return dm_strings(line)
    if path.endswith(".txt"):
        s = line.strip()
        return [s] if s else []
    if path.endswith(".json"):
        return [m.group(2) for m in QUOTED_JS.finditer(line) if m.group(1) == '"']
    return js_strings(line)


def skeleton(path, line):
    s = line
    for lit in literals(path, line):
        s = s.replace(lit, "", 1)
    return re.sub(r"\s+", "", s)


# ---------------------------------------------------------------- klasyfikacja

def is_polish(text):
    return bool(PL_DIACRITICS.search(text) or len(PL_WORDS.findall(strip_embeds(text))) >= 2)


def is_english(text):
    return len(EN_WORDS.findall(strip_embeds(text))) >= 1 and not PL_DIACRITICS.search(text)


def strip_embeds(text):
    prev = None
    while prev != text:
        prev = text
        text = re.sub(r"\[[^\[\]]*\]", " ", text)
    return text


# litery z polskimi (ó to U+00F3 i nie leży w zakresie Ą-ż, więc zakres się nie nadaje)
LETTERS = r"[^\W\d_]"


def wordy(text):
    plain = strip_embeds(text).strip()
    if not re.search(LETTERS + r"{2,}", plain):
        return False
    # pojedyncze słowo, też z dwukropkiem lub kropką ("toolbox", "Lód", "Zawiera:"), to tekst;
    # "brute_damage" czy "icons/x" już nie
    if re.fullmatch(LETTERS + r"+[:.!?]?", plain):
        return True
    return not IDENTIFIER.match(plain)


def accept(en, pl, en_line, pl_line):
    if en == pl or not wordy(pl) or not wordy(en):
        return False
    if is_polish(pl) and not is_polish(en):
        return True
    # teksty bez cech języka (Mug -> Kubek, robusted -> robustuje). Szum EN -> EN
    # z diffu upstreamu jest nieszkodliwy: "tłumaczenie" i tak jest po angielsku.
    return en.isascii() and not is_english(pl)


# ---------------------------------------------------------------- diffy

HUNK = re.compile(r"^@@ ")


def parse_diff(text):
    """Zwraca listę (ścieżka, usunięte linie, dodane linie) dla każdego hunka."""
    path, rem, add, out = None, [], [], []

    def flush():
        if path and (rem or add):
            out.append((path, rem[:], add[:]))
        rem.clear()
        add.clear()

    for line in text.splitlines():
        if line.startswith("diff --git"):
            flush()
            path = None
        elif line.startswith("+++ "):
            p = line[4:]
            path = p[2:] if p.startswith("b/") else None
        elif line.startswith("--- "):
            continue
        elif HUNK.match(line):
            flush()
        elif path and line.startswith("-"):
            rem.append(line[1:])
        elif path and line.startswith("+"):
            add.append(line[1:])
    flush()
    return out


def pair_hunk(path, rem, add):
    if SKIP_PATH.search(path) or not path.endswith(CODE_EXT + TEXT_EXT):
        return
    sk_r = [skeleton(path, x) for x in rem]
    sk_a = [skeleton(path, x) for x in add]
    sm = difflib.SequenceMatcher(None, sk_r, sk_a, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal" or (tag == "replace" and i2 - i1 == j2 - j1):
            for k in range(i2 - i1):
                yield rem[i1 + k], add[j1 + k]


def pairs_from_diff(text, source, sink):
    for path, rem, add in parse_diff(text):
        for en_line, pl_line in pair_hunk(path, rem, add):
            le, lp = literals(path, en_line), literals(path, pl_line)
            if len(le) != len(lp):
                continue
            for en, pl in zip(le, lp):
                if accept(en, pl, en_line, pl_line):
                    sink[pl][en] += 1
                    source[pl].add(path)


# ---------------------------------------------------------------- pokrycie

def tree_literals(rev):
    files = git("ls-tree", "-r", "--name-only", rev).splitlines()
    found = collections.Counter()
    present = set()
    for path in files:
        if SKIP_PATH.search(path) or not path.endswith(CODE_EXT + TEXT_EXT):
            continue
        if path.endswith(TEXT_EXT) and not path.startswith("strings/"):
            continue
        try:
            content = git("show", f"{rev}:{path}")
        except subprocess.CalledProcessError:
            continue
        for line in logical_lines(path, content.splitlines()):
            for lit in literals(path, line):
                present.add(lit)
                if wordy(lit) and (is_polish(lit) or (NAME_ASSIGN.search(line) and not is_english(lit))):
                    found[lit] += 1
                    found_paths.setdefault(lit, path)
    return found, present


found_paths = {}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rev", default="aq33/master")
    ap.add_argument("--upstream", default="nsv13up/master")
    ap.add_argument("--extra", default="bee/master",
                    help="dodatkowe źródło oryginałów (tylko tgui/, uzupełnia brakujące wpisy)")
    ap.add_argument("--out", default="strings/i18n")
    ap.add_argument("--report", help="plik .md z raportem pokrycia (np. raport/jezyk_01_slownik_pokrycie.md)")
    ap.add_argument("--ui", action="store_true",
                    help="tylko kod okien tgui: pary do en_pairs_ui.json (okna mają własne tłumaczenia, np. Wróć -> Back)")
    args = ap.parse_args()
    pathspecs = UI_PATHSPECS if args.ui else PATHSPECS
    out_name = "en_pairs_ui.json" if args.ui else "en_pairs.json"

    sink = collections.defaultdict(collections.Counter)
    source = collections.defaultdict(set)

    commits = git("rev-list", "--no-merges", args.rev).split()
    print(f"commity: {len(commits)}", file=sys.stderr)
    for n, sha in enumerate(commits):
        try:
            diff = git("show", "-U0", "--no-renames", "--format=", sha, "--", *pathspecs)
        except subprocess.CalledProcessError:
            continue
        pairs_from_diff(diff, source, sink)
        if n % 50 == 0:
            print(f"  {n}/{len(commits)} par: {len(sink)}", file=sys.stderr)
    from_history = len(sink)

    print("diff z upstreamem...", file=sys.stderr)
    diff = git("diff", "-U0", "--no-renames", args.upstream, args.rev, "--", *pathspecs)
    pairs_from_diff(diff, source, sink)

    from_upstream = len(sink)
    if args.extra:
        print(f"diff tgui z {args.extra}...", file=sys.stderr)
        extra = collections.defaultdict(collections.Counter)
        diff = git("diff", "-U0", "--no-renames", args.extra, args.rev, "--", "tgui/packages")
        pairs_from_diff(diff, source, extra)
        for pl, ens in extra.items():
            if pl not in sink:
                sink[pl] = ens

    # current: teksty liczone do pokrycia (wyglądają na polskie),
    # present: wszystkie literały w drzewie (słownik bierze każdy, np. "robustuje")
    current, present = tree_literals(args.rev)
    dictionary, conflicts = {}, 0
    for pl, ens in sink.items():
        if pl not in present:
            continue  # tekst już nie istnieje w kodzie
        best, _ = ens.most_common(1)[0]
        conflicts += len(ens) > 1
        dictionary[pl] = best

    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, out_name), "w", encoding="utf-8") as f:
        json.dump(dict(sorted(dictionary.items())), f, ensure_ascii=False, indent=1)
        f.write("\n")  # check_grep.sh wymaga nowej linii na końcu pliku

    # pokrycie w podziale na katalogi
    total = len(current)
    covered = sum(1 for pl in current if pl in dictionary)
    occ_total = sum(current.values())
    occ_cov = sum(c for pl, c in current.items() if pl in dictionary)
    per_dir = collections.defaultdict(lambda: [0, 0])
    for pl in current:
        top = found_paths[pl].split("/")[0]
        per_dir[top][0] += 1
        per_dir[top][1] += pl in dictionary
    interp_total = sum(1 for pl in current if "[" in pl)
    interp_cov = sum(1 for pl in current if "[" in pl and pl in dictionary)

    lines = [
        "# Słownik PL→EN: pokrycie (etap 0)",
        "",
        f"- par znalezionych w historii ({len(commits)} commitów): {from_history}",
        f"- par łącznie z diffem względem `{args.upstream}`: {from_upstream}",
        f"- par łącznie z tgui z `{args.extra}`: {len(sink)}",
        f"- par wciąż obecnych w kodzie (słownik): {len(dictionary)}, z czego niejednoznacznych: {conflicts}",
        "",
        f"**Unikalne polskie teksty w drzewie: {total}, z tłumaczeniem: {covered} ({100 * covered / max(total, 1):.1f}%)**",
        "",
        f"- wystąpienia: {occ_total}, pokryte: {occ_cov} ({100 * occ_cov / max(occ_total, 1):.1f}%)",
        f"- teksty z interpolacją `[...]`: {interp_total}, pokryte: {interp_cov} ({100 * interp_cov / max(interp_total, 1):.1f}%)",
        "",
        "| katalog | teksty | pokryte | % |",
        "|---|---|---|---|",
    ]
    for d, (t, c) in sorted(per_dir.items(), key=lambda x: -x[1][0]):
        lines.append(f"| {d} | {t} | {c} | {100 * c / max(t, 1):.0f}% |")
    if args.report:
        with open(args.report, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
    sys.stdout.reconfigure(encoding="utf-8")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
