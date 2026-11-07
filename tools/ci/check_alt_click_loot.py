"""AQUILA - każdy typ, który nadpisuje AltClick(), musi być w aquila/code/modules/lootpanel/alt_click_actions.dm
(sam albo przez przodka), inaczej Alt+klik zrobi swoją akcję i do tego otworzy okno kafelka (RPG Loot).

Użycie (z katalogu repo): python tools/ci/check_alt_click_loot.py
"""

import os
import re
import sys

LIST_FILE = "aquila/code/modules/lootpanel/alt_click_actions.dm"
# typy, które świadomie otwierają okno: /obj ma wybór wyglądu obsłużony w open_loot_panel()
ALLOWED = {"/obj", "/atom"}
DEF = re.compile(r"^(/[A-Za-z0-9_/]+)/AltClick\(")


def main():
    listed = set()
    with open(LIST_FILE, encoding="utf8") as list_file:
        for line in list_file:
            if line.startswith("/"):
                listed.add(line.strip())
    missing = []
    for root in ("code", "nsv13", "aquila"):
        for dirpath, _, files in os.walk(root):
            for name in files:
                if not name.endswith(".dm"):
                    continue
                path = os.path.join(dirpath, name)
                with open(path, encoding="utf8", errors="ignore") as dm_file:
                    lines = list(dm_file)
                for num, line in enumerate(lines, 1):
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
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
