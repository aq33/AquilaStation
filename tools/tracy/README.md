# Profiler byond-tracy

Oś czasu każdego ticka z rozbiciem na procki, od pierwszej zmiennej statycznej (przed `Master` i mapą)
do zatrzymania świata. Dokładniejszy niż `world.Profile()` i CSV perf, bo pokazuje pojedyncze wywołania
i to, co działo się w konkretnym ticku.

## Elementy

| Co | Skąd | Gdzie |
| --- | --- | --- |
| hook DM | `aquila/code/modules/tracy/tracy.dm` (ostatni include builda) | w repo, włączany zmienną środowiskową |
| `prof.dll` | fork ParadiseSS13/byond-tracy (offsety do 516.1687 z ParadiseSS13/byond-tracy#27) + nasze offsety 1688 | `python tools/tracy/build_prof.py --zig <zig.exe>`, kładzie obok `nsv13.dmb` (`prof.dll`, `.lib`, `.pdb` w `.gitignore`) |
| offsety nowego BYOND | `tools/tracy/find_offsets.py` | gdy `dependencies.sh` podniesie wersję BYOND |
| rtracy 0.1.7 | github.com/Dimach/rtracy (wydanie `rtracy.exe`) | `~/tools/tracy` |
| Tracy 0.14.0 | github.com/wolfpld/tracy (wydanie `windows-0.14.0.zip`, protokół zgodny z rtracy) | `~/tools/tracy` |
| zig 0.17.1 | ziglang.org/download | tylko do zbudowania `prof.dll` |

`build_prof.py` buduje zigiem pod `x86-windows-gnu`. mingw nie ma C11 `<threads.h>`, więc kompilacja dostaje
nakładkę `threads_win32.h` (SRWLOCK, CONDITION_VARIABLE, CreateThread), a `prof.c` zostaje bez zmian.

## Użycie

```bash
python tools/tracy/profile.py --sekundy 120            # start świata z AQUILA_TRACY=1, 120 s, tabela procek
python tools/tracy/profile.py --plik data/profiler/X.utracy --top 50 --csv wynik.csv
```

Ręcznie: `AQUILA_TRACY=1` (i opcjonalnie `AQUILA_TRACY_DLL=ścieżka`) przy starcie Dream Daemona. W logu świata
pojawia się `byond-tracy: profil zapisywany do data/profiler/...`. Zapis rośnie szybko (~1 GB na 90 s rozruchu),
więc usuwaj stare pliki z `data/profiler`. Oś czasu: `tracy-profiler.exe` otwiera plik `.tracy`, który zostawia `profile.py`.

Nie łącz z debuggerem auxtools (oba podpinają się pod wykonywanie procek) i nie włączaj na serwerze produkcyjnym.

## Nowa wersja BYOND

`prof.dll` odmawia startu na buildzie spoza tabeli (`byond version unsupported` w logu świata). Wtedy:

```bash
python tools/tracy/find_offsets.py <stary byondcore.dll> "<offsety starego z offsets/windows.h>" <nowy byondcore.dll>
```

Skrypt przenosi adresy danych (głosowanie po instrukcjach z relokacją) i funkcji (sygnatura początku albo
miejsca wywołań). Wynik dopisz do `EXTRA_OFFSETS` w `build_prof.py`. Przed użyciem sprawdź skrypt na parze
ze znanymi offsetami (czwarty argument: oczekiwane offsety, wypisuje ZGODNE/NIEZGODNE). Offsety 1688 policzono
z 1687 i niezależnie z 1673; oba dały ten sam wynik, a test na parze 1673 → 1687 trafił we wszystkie znane offsety.
Linux (`libprof.so`) nie jest objęty: tabela linuksowa kończy się na 1687.
