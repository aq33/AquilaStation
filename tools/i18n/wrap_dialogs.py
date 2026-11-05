"""Natywne okienka BYOND po angielsku: owija wywołania alert() i input() w kodzie DM.

BYOND rysuje alert() i input() sam, więc klient ich nie przetłumaczy. Skrypt zmienia
miejsca wywołań (aquila/code/modules/i18n/native_dialogs.dm):
    alert(...)            -> i18n_alert(usr, ...)   (tekst, tytuł i przyciski; kod dostaje polski przycisk)
    input(kto, "tekst", "tytuł", ...) -> input(kto, i18n_dialog_text(kto, "tekst"), i18n_dialog_text(kto, "tytuł"), ...)
    input(...) as X in L  -> i18n_input_choice(kto, input(...) as X in i18n_input_shown(kto, L))
W input() owijamy komunikat, tytuł i listę wyboru. Lista dla gracza z EN ma pozycje po angielsku,
a i18n_input_choice zwraca kodowi polską pozycję (kod porównuje wynik). Wartość domyślna zostaje.

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


def input_target(parts):
    """Odbiorca input() i numery argumentów z tekstem (komunikat, tytuł)."""
    first = parts[0].strip() if parts else ""
    # input(Usr = usr, Message, Title, Default): pierwszy argument można pominąć. Bez odbiorcy
    # owijamy (0, 1), z odbiorcą (1, 2); nigdy wartości domyślnej, bo kod porównuje wynik.
    if first.startswith('"') or first.startswith('{"') or first.startswith(WRAP) or MESSAGE_NAME.search(first):
        return "usr", (0, 1)
    return first, (1, 2)


LIST_TAIL = re.compile(r"\s+as\s+[\w|]+\s+in\s+")
LIST_WRAP = "i18n_input_shown("


def list_end(line, start):
    """Koniec wyrażenia listy za "in " (do końca linii, komentarza albo niezamkniętego nawiasu)."""
    depth, i = 0, start
    while i < len(line):
        c = line[i]
        if c == '"' or line.startswith('{"', i):
            end = string_end(line, i)
            if end is None:
                return None
            i = end
            continue
        if line.startswith("//", i):
            break
        if c in "([":
            depth += 1
        elif c in ")]":
            if depth == 0:
                break
            depth -= 1
        elif c == "," and depth == 0:
            return None  # input(...) in L jako argument z dalszymi argumentami: zostawiamy
        i += 1
    end = i
    while end > start and line[end - 1] in " \t\r":
        end -= 1
    return end if end > start else None


def wrap_input_list(line, m):
    """input(...) as X in L -> i18n_input_choice(kto, input(...) as X in i18n_input_shown(kto, L))"""
    args, close = split_args(line, m.end())
    if args is None:
        return None
    tail = LIST_TAIL.match(line, close + 1)
    if not tail or line.startswith(LIST_WRAP, tail.end()):
        return None
    end = list_end(line, tail.end())
    if end is None:
        return None
    target, _ = input_target([line[a:b] for a, b in args])
    expr = line[tail.end():end]
    return (line[:m.start()] + f"i18n_input_choice({target}, " + line[m.start():tail.end()]
            + f"{LIST_WRAP}{target}, {expr}))" + line[end:])


def wrap_input(line, m):
    args, close = split_args(line, m.end())
    if args is None:
        return None
    parts = [line[a:b] for a, b in args]
    first = parts[0].strip() if parts else ""
    if not first:
        return None
    target, text_indexes = input_target(parts)
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
                # lista wyboru na tej samej linii (po owinięciu tekstów, żeby odbiorca był ten sam)
                listed = wrap_input_list(new if new is not None else line, CALL.search(new if new is not None else line, m.start()))
                if listed is not None:
                    new = listed
            if new is None:
                continue
            found.append((k + 1, m.group(1)))
            line = new
            if m.group(1) == "alert":
                offset = m.start() + len("i18n_alert(usr, ")
            else:
                # za owinięciem listy, żeby nie złapać tego samego input() jeszcze raz
                again = CALL.search(line, m.start())
                offset = again.end() if again else len(line)
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
    ap.add_argument("--strict", action="store_true", help="z --check: błąd (kod wyjścia 1), nie ostrzeżenie")
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
                level = "error" if args.strict else "warning"
                print(f"::{level} file={path},line={line_no}::Natywne {kind}() bez tłumaczenia (tools/i18n/wrap_dialogs.py)")
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except (AttributeError, OSError):
        pass  # wyjście do potoku na Windowsie
    print(f"{'do owinięcia' if args.check else 'owinięte'}: alert {total['alert']}, input {total['input']}")
    if args.check and args.strict and (total["alert"] or total["input"]):
        sys.exit(1)


if __name__ == "__main__":
    main()
