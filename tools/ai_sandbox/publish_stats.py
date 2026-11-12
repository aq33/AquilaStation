"""Wysyła statystyki piaskownicy AI na serwer ze stroną bitew i pilnuje, żeby były aktualne.

    python tools/ai_sandbox/publish_stats.py            # raz: odtwarzacze nowych profili + statystyki.html
    python tools/ai_sandbox/publish_stats.py --pilnuj   # co 30 s sprawdza data/*_profil.json i wysyła po każdym nowym

Profil (data/<bitwa>_profil.json) powstaje na końcu bitwy puszczonej z ai_sandbox_profile=1. Po każdym nowym albo
zmienionym profilu skrypt robi odtwarzacz tej bitwy (render_battle.py), przebudowuje statystyki (build_stats.py)
i kopiuje oba przez scp. Serwer i katalog: --host (alias z ~/.ssh/config) i --katalog.
"""

import argparse
import glob
import os
import subprocess
import sys
import tempfile
import time

TU = os.path.dirname(os.path.abspath(__file__))


def stabilny(p, sekundy=10):
    """Plik nie zmieniał się od kilku sekund (DreamDaemon skończył zapis)"""
    try:
        return time.time() - os.path.getmtime(p) > sekundy
    except OSError:
        return False


def wyslij(host, pliki, cel):
    subprocess.run(["scp", "-q"] + pliki + ["%s:%s" % (host, cel)], check=True)


def opublikuj(a, nowe):
    tmp = tempfile.mkdtemp(prefix="aq_staty_")
    odtwarzacze = []
    for prof in nowe:
        nagranie = prof.replace("_profil.json", ".json")
        if not os.path.exists(nagranie):
            continue
        wyj = os.path.join(tmp, os.path.basename(nagranie)[:-5] + ".html")
        subprocess.run([sys.executable, os.path.join(TU, "render_battle.py"), nagranie, "-o", wyj], check=True, stdout=subprocess.DEVNULL)
        odtwarzacze.append(wyj)
    staty = os.path.join(tmp, "statystyki.html")
    subprocess.run([sys.executable, os.path.join(TU, "build_stats.py"), "--dane", a.dane, "--wyjscie", staty], check=True, stdout=subprocess.DEVNULL)
    if a.na_sucho:
        print("na sucho: %d odtwarzaczy i statystyki w %s" % (len(odtwarzacze), tmp))
        return
    if odtwarzacze:
        wyslij(a.host, odtwarzacze, a.katalog.rstrip("/") + "/pliki/bitwy/")
    wyslij(a.host, [staty], a.katalog.rstrip("/") + "/statystyki.html")
    subprocess.run(["ssh", a.host, "chown -R caddy:caddy %s/statystyki.html %s/pliki/bitwy" % (a.katalog, a.katalog)], check=False)
    print("%s wysłano: statystyki.html i %d odtwarzaczy%s" % (
        time.strftime("%H:%M:%S"), len(odtwarzacze), (" (" + ", ".join(os.path.basename(x) for x in odtwarzacze) + ")") if odtwarzacze else ""))


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--dane", default="data")
    p.add_argument("--host", default="aquila")
    p.add_argument("--katalog", default="/srv/bitwy")
    p.add_argument("--pilnuj", action="store_true", help="działaj w kółko i wysyłaj po każdym nowym profilu")
    p.add_argument("--co", type=int, default=30, help="co ile sekund sprawdzać (z --pilnuj)")
    p.add_argument("--na-sucho", action="store_true", help="tylko zbuduj pliki, nic nie wysyłaj")
    a = p.parse_args(argv)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    stan = {}
    pierwszy = True
    while True:
        teraz = {}
        for prof in glob.glob(os.path.join(a.dane, "*_profil.json")):
            if stabilny(prof):
                teraz[prof] = os.path.getmtime(prof)
        nowe = [k for k, v in teraz.items() if stan.get(k) != v]
        if nowe and (not pierwszy or not a.pilnuj):
            opublikuj(a, nowe)
        elif pierwszy and a.pilnuj:
            opublikuj(a, [])  # na start same statystyki; stare odtwarzacze już są na serwerze
            print("pilnuję %s (%d profili), co %d s; Ctrl+C kończy" % (a.dane, len(teraz), a.co))
        stan = teraz
        pierwszy = False
        if not a.pilnuj:
            return 0
        time.sleep(a.co)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(0)
