"""Buduje samowystarczalny odtwarzacz HTML z nagrania bitwy piaskownicy AI.

Nagranie powstaje w buildzie `dm.exe -DCBT -DAQ_AI_SANDBOX` (aquila/code/modules/overmap/ai_sandbox.dm),
ktory zapisuje data/ai_sandbox.json. Ten skrypt wkleja nagranie do szablonu battle_player.html,
wiec wynik dziala z pliku, bez serwera.

    python tools/ai_sandbox/render_battle.py data/sensory_new.json raport/bitwy/sensory_new.html \\
        --tytul "Sensory AI - po zmianie"

Bez --tytul tytul bierze sie z nazwy pliku. Mozna podac wiele nagran naraz:

    python tools/ai_sandbox/render_battle.py data/*.json --katalog raport/bitwy
"""

import argparse
import json
import os
import sys

SZABLON = os.path.join(os.path.dirname(os.path.abspath(__file__)), "battle_player.html")


def wczytaj_nagranie(sciezka):
    with open(sciezka, "r", encoding="utf-8") as f:
        dane = json.load(f)
    if "frames" not in dane:
        raise ValueError("%s nie wyglada na nagranie piaskownicy (brak 'frames')" % sciezka)
    return dane


def zbuduj(nagranie, tytul):
    with open(SZABLON, "r", encoding="utf-8") as f:
        szablon = f.read()
    # </script> w danych rozbilby blok <script type="application/json">
    dane = json.dumps(nagranie, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    return szablon.replace("__TITLE__", tytul).replace("__DATA__", dane)


# Serie bitew: prefiks pliku -> czytelny opis. Ta sama lista jest na stronie z bitwami (index.html na VDS),
# zeby tytul odtwarzacza i opis serii mowily to samo.
SERIE = [
    ("U_zapasy_", "Skończone zapasy na lotniskowcach: włączone"),
    ("U_bez_zapasow_", "Skończone zapasy na lotniskowcach: wyłączone (pełny magazyn co 5 s)"),
    ("T_wszystko_", "Objazd przeszkód: wszystko włączone"),
    ("T_bez_objazdu_", "Objazd przeszkód: bez objazdu (sam ciąg boczny)"),
    ("S_wszystko_", "Przepustnica i skradanie: wszystko włączone"),
    ("S_bez_dyscypliny_", "Przepustnica i skradanie: bez przepustnicy i oszczędnego boostu"),
    ("R_poprawki_", "Poprawki ruchu: z poprawkami"),
    ("R_bez_", "Poprawki ruchu: bez poprawek"),
    ("fin_zwykla_", "Pełne AI (przed poprawkami ruchu)"),
    ("fin_odniesienie_", "Odniesienie: AI bez nowych zachowań"),
    ("fin_szpica_", "Szpica floty (przed poprawkami ruchu)"),
    ("fin_zasadzka_", "Zasadzka (przed poprawkami ruchu)"),
]


def domyslny_tytul(sciezka):
    nazwa = os.path.splitext(os.path.basename(sciezka))[0]
    for prefiks, opis in SERIE:
        if nazwa.startswith(prefiks):
            litera = nazwa[len(prefiks):]
            return "%s, bitwa %s" % (opis, litera.upper()) if litera else opis
    return nazwa.replace("_", " ").strip().capitalize()


def main(argv=None):
    p = argparse.ArgumentParser(description="Odtwarzacz HTML z nagrania bitwy piaskownicy AI")
    p.add_argument("wejscie", nargs="+", help="pliki JSON z nagraniami")
    p.add_argument("-o", "--wyjscie", help="plik HTML (tylko przy jednym nagraniu)")
    p.add_argument("--katalog", help="katalog wynikowy przy wielu nagraniach")
    p.add_argument("--tytul", help="tytul strony (tylko przy jednym nagraniu)")
    a = p.parse_args(argv)

    if len(a.wejscie) > 1 and not a.katalog:
        p.error("przy wielu nagraniach podaj --katalog")
    if len(a.wejscie) == 1 and not a.wyjscie and not a.katalog:
        p.error("podaj plik wyjsciowy albo --katalog")

    for zrodlo in a.wejscie:
        nagranie = wczytaj_nagranie(zrodlo)
        tytul = a.tytul if (a.tytul and len(a.wejscie) == 1) else domyslny_tytul(zrodlo)
        if a.katalog:
            os.makedirs(a.katalog, exist_ok=True)
            cel = os.path.join(a.katalog, os.path.splitext(os.path.basename(zrodlo))[0] + ".html")
        else:
            cel = a.wyjscie
        html = zbuduj(nagranie, tytul)
        with open(cel, "w", encoding="utf-8", newline="\n") as f:
            f.write(html)
        print("%s -> %s (%d klatek, %d impulsow, %.1f KB)" % (
            zrodlo, cel, len(nagranie.get("frames", [])), len(nagranie.get("pulses", [])),
            os.path.getsize(cel) / 1024.0))
    return 0


if __name__ == "__main__":
    sys.exit(main())
