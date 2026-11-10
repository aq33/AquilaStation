"""Zbiorcze liczby z nagran bitew piaskownicy AI.

Liczy to, co widac na nagraniu, zeby nie ocenia c zachowania AI na oko:
ile okretow ginie, ile czasu okrety stoja, jak czesto pulsuja radarem,
czym trzymaja kontakt i w jakich taktykach siedza.

    python tools/ai_sandbox/compare_battles.py data/seria_*.json
    python tools/ai_sandbox/compare_battles.py --grupuj data/seria_*.json

Z --grupuj przebiegi tego samego scenariusza (nazwa bez koncowki _a/_b/_c)
sa usredniane, a w nawiasie podany jest zakres.
"""

import argparse
import collections
import glob
import json
import math
import os
import re
import sys

STOI = 0.3  # ponizej tylu pol na sekunde uznajemy, ze okret stoi


def wczytaj(sciezka):
    with open(sciezka, "r", encoding="utf-8") as f:
        return json.load(f)


def dystans(a, b):
    return math.hypot(a["x"] - b["x"], a["y"] - b["y"])


def pelne_klatki(nagranie):
    """Uzupelnia lekkie klatki danymi z ostatniej pelnej (zapis co 0,5 s)."""
    ostatnie = {}
    for klatka in nagranie["frames"]:
        pelna = klatka.get("full", True)
        statki = []
        for s in klatka["ships"]:
            if pelna or s.get("name") is not None:
                ostatnie[s["id"]] = s
                statki.append(s)
            else:
                baza = ostatnie.get(s["id"])
                statki.append(dict(baza, **s) if baza else s)
        yield klatka["t"], statki


def metryki(sciezka):
    nagranie = wczytaj(sciezka)
    klatki = list(pelne_klatki(nagranie))
    if len(klatki) < 2:
        return None
    dt = klatki[1][0] - klatki[0][0]
    ruch = stoi = stoi_lot = lot = 0
    samotne = pary = 0
    taktyki = collections.Counter()
    sensory = collections.Counter()
    for i in range(len(klatki) - 1):
        poprzednie = {s["id"]: s for s in klatki[i][1]}
        biezace = [s for s in klatki[i + 1][1] if not s.get("main")]
        for s in biezace:
            stary = poprzednie.get(s["id"])
            if not stary:
                continue
            v = dystans(stary, s) / dt
            ruch += 1
            taktyki[stary.get("tactic")] += 1
            for c in stary.get("cts") or []:
                sensory[c["s"]] += 1
            if v < STOI:
                stoi += 1
            if "otniskow" in (s.get("name") or ""):
                lot += 1
                if v < STOI:
                    stoi_lot += 1
            wrogowie = [o for o in biezace if o.get("faction") and s.get("faction") and o["faction"] != s["faction"]]
            swoi = [o for o in biezace if o is not s and o.get("faction") == s.get("faction")]
            if wrogowie:
                pary += 1
                blisko = sum(1 for o in wrogowie if dystans(s, o) <= 25)
                najblizszy_swoj = min([dystans(s, o) for o in swoi], default=999)
                if blisko >= 2 and najblizszy_swoj > 40:
                    samotne += 1
    zabicia = [e["t"] for e in nagranie["events"]
               if "zniszczony" in e["text"] and "Wrak" not in e["text"]]
    procent = lambda ile, z: 100.0 * ile / z if z else 0.0
    return {
        "zabicia": len(zabicia),
        "ostatnie": max(zabicia) if zabicia else 0,
        "impulsy": len(nagranie.get("pulses") or []),
        "stoi%": procent(stoi, ruch),
        "lotniskowce stoja%": procent(stoi_lot, lot),
        "samotne szarze%": procent(samotne, pary),
        "walka%": procent(taktyki.get("walka", 0), ruch),
        "czeka na flote%": procent(taktyki.get("czeka na flote", 0) + taktyki.get("czeka na flotę", 0), ruch),
        "zasadzka%": procent(taktyki.get("zasadzka", 0), ruch),
        "szukanie%": procent(taktyki.get("szukanie", 0) + taktyki.get("przeczesywanie", 0), ruch),
        "termiczny%": procent(sensory.get("termiczny", 0), sum(sensory.values())),
    }


def scenariusz(sciezka):
    nazwa = os.path.splitext(os.path.basename(sciezka))[0]
    nazwa = re.sub(r"^seria_", "", nazwa)
    return re.sub(r"_[a-z]$", "", nazwa)


KOLUMNY = ["zabicia", "impulsy", "stoi%", "lotniskowce stoja%", "samotne szarze%",
           "walka%", "czeka na flote%", "zasadzka%", "szukanie%"]


def main(argv=None):
    p = argparse.ArgumentParser(description="Zbiorcze liczby z nagran piaskownicy AI")
    p.add_argument("wejscie", nargs="+")
    p.add_argument("--grupuj", action="store_true", help="usrednij przebiegi tego samego scenariusza")
    a = p.parse_args(argv)

    pliki = []
    for wzor in a.wejscie:
        pliki.extend(sorted(glob.glob(wzor)) or [wzor])

    wyniki = []
    for f in pliki:
        m = metryki(f)
        if m:
            wyniki.append((scenariusz(f) if a.grupuj else os.path.basename(f), m))

    if not wyniki:
        print("brak nagran")
        return 1

    if a.grupuj:
        grupy = collections.OrderedDict()
        for nazwa, m in wyniki:
            grupy.setdefault(nazwa, []).append(m)
        print("%-16s %4s %s" % ("scenariusz", "n", " ".join("%18s" % k for k in KOLUMNY)))
        for nazwa, lista in grupy.items():
            komorki = []
            for k in KOLUMNY:
                wartosci = [m[k] for m in lista]
                srednia = sum(wartosci) / len(wartosci)
                komorki.append("%8.1f (%3.0f-%3.0f)" % (srednia, min(wartosci), max(wartosci)))
            print("%-16s %4d %s" % (nazwa, len(lista), " ".join(komorki)))
    else:
        print("%-28s %s" % ("nagranie", " ".join("%18s" % k for k in KOLUMNY)))
        for nazwa, m in wyniki:
            print("%-28s %s" % (nazwa, " ".join("%18.1f" % m[k] for k in KOLUMNY)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
