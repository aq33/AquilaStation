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


def domyslny_tytul(sciezka):
    nazwa = os.path.splitext(os.path.basename(sciezka))[0]
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
