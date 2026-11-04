"""Natywne okienka BYOND po angielsku: owija wywołania alert() i input() w kodzie DM.

BYOND rysuje alert() i input() sam, więc klient ich nie przetłumaczy. Skrypt zmienia
miejsca wywołań (aquila/code/modules/i18n/native_dialogs.dm):
    alert(...)            -> i18n_alert(usr, ...)   (tekst, tytuł i przyciski; kod dostaje polski przycisk)
    input(kto, "tekst", "tytuł", ...) -> input(kto, i18n_dialog_text(kto, "tekst"), i18n_dialog_text(kto, "tytuł"), ...)
W input() owijamy tylko literały komunikatu i tytułu. Domyślna wartość i lista wyboru
(`in list(...)`) zostają, bo kod porównuje zwracaną wartość.

Makro na alert() odpada: preprocesor DM po nazwie makra szuka nawiasu i zjada koniec linii,
co psuje ścieżki typów kończące się na /alert i zmienne o tej nazwie.

Użycie (z katalogu repo): python tools/i18n/wrap_dialogs.py [--check]
    --check: tylko wypisuje niezawinięte wywołania (np. w nowym porcie), nic nie zmienia.
"""

import argparse
import re
import subprocess
import sys

CALL = re.compile(r"(?<![\w.:/])(alert|input)\(")
SKIP = ("aquila/code/modules/i18n/native_dialogs.dm",)
MARKER = "// AQ EDIT - i18n okienka"
WRAP = "i18n_dialog_text("
# zmienna z tekstem komunikatu na pierwszym miejscu (input(msg, "Tytuł") bez odbiorcy)
# (pełne nazwy: "stranger" czy "quartermaster" to odbiorcy, nie komunikaty)
MESSAGE_NAME = re.compile(r"(^|\.)(msg|message|text|prompt|question|query|desc|description|info|title|txt)$", re.I)


def string_end(text, i):
    """Koniec literału zaczynającego się w text[i] ('"' albo '{"'), indeks za nim; None, gdy nie zamknięty w linii."""
    if text.startswith('{"', i):
        end = text.find('"}', i + 2)
        return None if end < 0 else end + 2
    j = i + 1
    depth = 0
    while j < len(text):
        c = text[j]
        if c == "\\":
            j += 2
            continue
        if c == "[":
            depth += 1
        elif c == "]" and depth:
            depth -= 1
        elif c == '"' and not depth:
            return j + 1
        j += 1
    return None


def split_args(text, start):
    """Argumenty wywołania od text[start] (za nawiasem): lista (początek, koniec) i indeks nawiasu zamykającego."""
    args, depth, i, arg_start = [], 0, start, start
    while i < len(text):
        c = text[i]
        if c == '"' or text.startswith('{"', i):
            end = string_end(text, i)
            if end is None:
                return None, None
            i = end
            continue
        if c in "([":
            depth += 1
        elif c in ")]":
            if depth == 0:
                args.append((arg_start, i))
                return args, i
            depth -= 1
        elif c == "," and depth == 0:
            args.append((arg_start, i))
            arg_start = i + 1
        elif c == "/" and text.startswith("//", i):
            return None, None
        i += 1
    return None, None


def in_string_or_comment(line, pos):
    """Czy pos leży w napisie albo komentarzu (prosty skan od początku linii)."""
    i = 0
    while i < pos:
        if line.startswith("//", i):
            return True
        if line[i] == '"' or line.startswith('{"', i):
            end = string_end(line, i)
            if end is None or end > pos:
                return True
            i = end
            continue
        i += 1
    return False


def wrap_input(line, m):
    args, close = split_args(line, m.end())
    if args is None:
        return None
    parts = [line[a:b] for a, b in args]
    first = parts[0].strip() if parts else ""
    if not first:
        return None
    # input(Usr = usr, Message, Title, Default): pierwszy argument można pominąć. Bez odbiorcy
    # owijamy (0, 1), z odbiorcą (1, 2); nigdy wartości domyślnej, bo kod porównuje wynik.
    if first.startswith('"') or first.startswith('{"') or first.startswith(WRAP) or MESSAGE_NAME.search(first):
        target, text_indexes = "usr", (0, 1)
    else:
        target, text_indexes = first, (1, 2)
    changed = False
    for index in text_indexes:
        if index >= len(parts):
            continue
        value = parts[index].strip()
        # literał albo zmienna z tekstem; i18n_dialog_text przepuszcza wszystko, czego nie ma w słowniku
        if value and value != "null" and WRAP not in value:
            lead = parts[index][:len(parts[index]) - len(parts[index].lstrip())]
            parts[index] = f"{lead}{WRAP}{target}, {value})"
            changed = True
    if not changed:
        return None
    return line[:m.end()] + ",".join(parts) + line[close:]


def process(path, check):
    with open(path, encoding="utf-8", newline="") as f:
        lines = f.read().split("\n")
    found = []
    for k, line in enumerate(lines):
        offset = 0
        while True:
            m = CALL.search(line, offset)
            if not m:
                break
            offset = m.end()
            if in_string_or_comment(line, m.start()):
                continue
            new = None
            if m.group(1) == "alert":
                new = line[:m.start()] + "i18n_alert(usr, " + line[m.end():]
            else:
                new = wrap_input(line, m)
            if new is None:
                continue
            found.append((k + 1, m.group(1)))
            line = new
            offset = m.start() + len("i18n_alert(usr, ") if m.group(1) == "alert" else m.end()
        if found and found[-1][0] == k + 1 and MARKER not in line:
            eol = "\r" if line.endswith("\r") else ""
            line = line.rstrip("\r") + " " + MARKER + eol
        lines[k] = line
    if found and not check:
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write("\n".join(lines))
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    files = subprocess.run(["git", "ls-files", "-z", "*.dm"], capture_output=True, text=True,
                           encoding="utf-8", check=True).stdout.split("\0")[:-1]
    total = {"alert": 0, "input": 0}
    for path in files:
        if path in SKIP or path.startswith("tools/"):
            continue
        for line_no, kind in process(path, args.check):
            total[kind] += 1
            if args.check:
                print(f"::warning file={path},line={line_no}::Natywne {kind}() bez tłumaczenia (tools/i18n/wrap_dialogs.py)")
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except (AttributeError, OSError):
        pass  # wyjście do potoku na Windowsie
    print(f"{'do owinięcia' if args.check else 'owinięte'}: alert {total['alert']}, input {total['input']}")


if __name__ == "__main__":
    main()
