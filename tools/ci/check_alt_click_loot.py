"""AQUILA - każdy typ, który nadpisuje AltClick(), musi być w aquila/code/modules/lootpanel/alt_click_actions.dm
(sam albo przez przodka), inaczej Alt+klik zrobi swoją akcję i do tego otworzy okno kafelka (RPG Loot).
Handler sygnału COMSIG_CLICK_ALT (komponenty, kontrolery AI) musi zwracać COMPONENT_INTERCEPT_ALT
(albo flagę o tej samej wartości), bo /atom/AltClick() otwiera okno, gdy sygnał nie przechwycił kliknięcia.

Użycie (z katalogu repo): python tools/ci/check_alt_click_loot.py
"""

import os
import re
import sys

LIST_FILE = "aquila/code/modules/lootpanel/alt_click_actions.dm"
# typy, które świadomie otwierają okno: /obj ma wybór wyglądu obsłużony w open_loot_panel()
ALLOWED = {"/obj", "/atom"}
DEF = re.compile(r"^(/[A-Za-z0-9_/]+)/AltClick\(")
SIGNAL = re.compile(r"RegisterSignal\(.*\bCOMSIG_CLICK_ALT\b.*PROC_REF\((\w+)\)")
# flagi o wartości COMPONENT_INTERCEPT_ALT, którymi handler przechwytuje Alt+klik
INTERCEPT = ("COMPONENT_INTERCEPT_ALT", "COMPONENT_CANCEL_ATTACK_CHAIN", "CLICK_ACTION_SUCCESS")


def handler_body(lines, proc_name):
    """Treść procedury proc_name (pierwsza definicja w pliku), None gdy jej tu nie ma."""
    head = re.compile(r"^/[A-Za-z0-9_/]*proc/" + proc_name + r"\(")
    for start, line in enumerate(lines):
        if head.match(line):
            body = []
            for next_line in lines[start + 1:]:
                if next_line.strip() and not next_line[0].isspace():
                    break
                body.append(next_line)
            return "".join(body)
    return None


def main():
    listed = set()
    with open(LIST_FILE, encoding="utf8") as list_file:
        for line in list_file:
            if line.startswith("/"):
                listed.add(line.strip())
    missing = []
    unhandled = []
    for root in ("code", "nsv13", "aquila"):
        for dirpath, _, files in os.walk(root):
            for name in files:
                if not name.endswith(".dm"):
                    continue
                path = os.path.join(dirpath, name)
                with open(path, encoding="utf8", errors="ignore") as dm_file:
                    lines = list(dm_file)
                for num, line in enumerate(lines, 1):
                    sig = SIGNAL.search(line)
                    if sig:
                        body = handler_body(lines, sig.group(1))
                        if body is not None and not any(flag in body for flag in INTERCEPT):
                            unhandled.append(f"{path}:{num}: {sig.group(1)}")
                    m = DEF.match(line)
                    if not m:
                        continue
                    typepath = m.group(1)
                    if typepath.endswith("/proc") or typepath in ALLOWED:
                        continue
                    parts = typepath.split("/")
                    if not any("/".join(parts[:i]) in listed for i in range(2, len(parts) + 1)):
                        missing.append(f"{path}:{num}: {typepath}")
    for entry in missing:
        print(f"::error::{entry} nadpisuje AltClick(), a nie ma go w {LIST_FILE}")
    for entry in unhandled:
        print(f"::error::{entry} obsługuje COMSIG_CLICK_ALT bez COMPONENT_INTERCEPT_ALT, więc Alt+klik otworzy też okno kafelka")
    return 1 if missing or unhandled else 0


if __name__ == "__main__":
    sys.exit(main())
