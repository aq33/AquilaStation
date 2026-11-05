# Dźwięk przestrzenny jak w SS14: wygłuszanie, pogłos, pozycjonowanie

Gałąź `audio-przestrzenne` od aq33/master (e9489368eb). PR jeszcze nie założony.

## Stan

- Kompilacja `dm.exe -DCBT nsv13.dme`: 0 błędów, 0 ostrzeżeń. Dreamchecker: 0 diagnostyk.
- Unit testy `aquila_sound_occlusion`, `jukebox_pa_system`, `aquila_logi_rund_6552`: PASS, bez runtime'ów w logu.
- Pomiary FMOD: nagranie wyjścia audio (WASAPI loopback) i analiza widma, nie odsłuch.
- **W grze niesprawdzone.** Jak to brzmi w prawdziwej rundzie (czy wygłuszenie nie jest za mocne, czy panorama nie jest za łagodna), trzeba ocenić w grze.

## Co zmieniłem

| Plik | Co |
|---|---|
| `code/game/sound.dm` | Hooki `AQ EDIT`: `playsound()` liczy wygłuszenie dla każdego żywego słuchacza i przekazuje źródło. `playsound_local()` stosuje wygłuszenie, pozycję i pogłos z kształtu, a po wysłaniu przywraca plik. |
| `aquila/code/game/sound_occlusion.dm` (nowy) | `get_sound_occlusion()` (Bresenham bez list), `apply_sound_occlusion()`, `apply_sound_position()`. `distant_sound_dampening()` korzysta teraz z tej samej pętli. |
| `aquila/code/game/area/sound_environments.dm` | `get_sound_environment()`: obszar z ogólnym pogłosem stacji przy pierwszym dźwięku dostaje preset z liczby kafelków, szerokości i podłogi. |
| `aquila/code/game/muffled_sounds.dm` (wygenerowany) + `aquila/sound/muffled/` | 390 stłumionych kopii (dolnoprzepustowy 900 Hz, mono, 22 kHz): 2,5 MB do `.rsc`. |
| `aquila/tools/muffle_sounds.py` (nowy) | Generator kopii i listy. Wybiera dźwięki z ≥5 miejsc w kodzie, wszystkie kroki, grupy `get_sfx()`, drzwi i wybuchy. |
| `aquila/code/game/distant_sound.dm` | Usunięta własna kopia pętli. Pogłos przez `get_sound_environment()`. |
| `aquila/code/modules/unit_tests/aquila_sound_occlusion.dm` (nowy) | Test: ściana, zamknięte i otwarte drzwi, przekątna, podmiana pliku i przywrócenie dla kolejnego słuchacza, panorama, klasyfikacja pogłosu. |
| `aquila/code/modules/unit_tests/aquila_logi_rund_6552.dm` | Sonda testu wybuchu przyjmuje nowe argumenty `playsound_local()`. |
| `aquila/LEGACY_OVERRIDES.md`, `aquila/sound/attributions_dzwieki.txt` | Wpis hooka i atrybucja wygenerowanych kopii. |

## Jak działa

**Wygłuszanie (A).** Na prostej źródło → słuchacz sumujemy `sound_dampening`: ściana 0,45, ściana wzmocniona 0,6, zamknięte drzwi 0,3, szyby 0,15–0,3. Inny pokład liczy się jako 0,5, a suma ma limit 1. Przy wygłuszeniu `w`:
- głośność × (1 − 0,5·w),
- ścieżka sucha `echo[1] = −2000·w` mB, a pogłos zostaje, więc dźwięk zza ściany brzmi „z oddali”,
- od `w ≥ 0,3` stłumiona kopia pliku, jeśli istnieje (`muffled_sounds`, a dla głosów `muffled_speech_sounds`).

Duchy słyszą bez wygłuszenia. Głosy dalej idą przez `hearers()`, więc za ścianą ich nie słychać, jak dotąd. Wygłuszenie działa na nie tylko przez szyby.

**Pogłos (B).** Liczony leniwie, raz na obszar, tylko dla obszarów z ogólnym `SOUND_AREA_STANDARD_STATION`:
- ≤30 kafelków: łazienka (dywan: pokój),
- ≥60% kafelków ma szerokość ≤3: korytarz (`HALLWAY`, dywan: wyłożony korytarz),
- ≥300 kafelków: duża hala,
- pozostałe: bez zmian (dywan, drewno, trawa ≥40%: miękkie presety).

Ręczne wartości z `sound_environments.dm` zostają bez zmian.

**Pozycja (C1 + C2).** Do 6 kratek od gracza, na tym samym pokładzie, gdy kamera to sam gracz (bez przesunięcia widoku): `sound.atom` = źródło (ruchomy atom na kafelku) albo jego kafelek. `transform` przelicza piksele na kratki i dodaje wysokość 0,7 × odległość w bok. Klient sam przesuwa dźwięk, gdy gracz albo źródło idzie. Dalej i przez kamerę zostaje stała pozycja z tą samą łagodniejszą panoramą (`y = max(0,7·|dx|, 0,5)`).

## Pomiary FMOD w BYOND 516 (nagranie wyjścia, ton 2 + 9 kHz albo szum)

| Parametr | Wynik |
|---|---|
| `echo[1]` Direct −2000 | −19 dB w całym paśmie, czyli zwykła głośność. Ścisza tylko ścieżkę suchą: przy −3000 dźwięk spada tylko o 18 dB, bo zostaje pogłos. |
| `echo` DirectHF / Occlusion / Obstruction / Exclusion −3000 | **brak zmian** (±0,1 dB w każdym paśmie). Filtra dolnoprzepustowego po stronie klienta nie ma (FMOD Ex w trybie programowym). |
| `environment` + Room 0 | pogłos słychać (ogon po końcu dźwięku), Room −1000 skraca go |
| `x = 1/2/4/8`, `y = 1` | różnica L−P −11 / −20 / −31 / −32 dB. Dotychczasowe `y = 1` daje prawie jedno ucho już przy 2 kratkach. |
| `x = 4`, `y = 4` | −11 dB: panorama zależy od kąta, wysokość ją łagodzi |
| `falloff = 1 / 2` przy odległości 4 | −14 / −8 dB: tłumienie FMOD zaczyna się dopiero za `falloff`, dlatego głośność dalej liczy serwer |
| `sound.atom` | jednostki to piksele względem środka widoku (na małej mapie środek mapy, w grze gracz). **Śledzi ruch** gracza i źródła w trakcie dźwięku (przejście z prawej na lewą). |
| `transform` | lista 9 liczb (`matrix()` nie działa). Skala 1/32 daje kratki. `xy = 0,5` daje −20 dB, `xy = 1` daje −11 dB. Wiersz przesunięcia `c` i bazowe `x/y/z` łączone z `atom` dają dziwne wyniki, więc ich nie używam. |
| atom poza widokiem (12 kratek) | **−44 dB, praktycznie cisza**, stąd limit 6 kratek |
| atom niewidzialny (`invisibility = 101`) | śledzony normalnie |

Uwaga do metody: Dream Seeker był wyciszony w mikserze Windows (ustawienie użytkownika, nie ruszałem go), więc testy szły z kopii klienta pod inną nazwą `.exe`. Discord zaśmiecał nagranie, dlatego liczyłem tylko wąskie pasma wokół tonów testowych.

## Koszt

**Serwer** (sonda na mapie Aquili, 5000 par kafelków do 12 kratek, `rustg_time_microseconds`):
- `get_sound_occlusion`: **16,5 µs** na słuchacza (stara pętla na `getline`: 21 µs, wyniki identyczne w 5000/5000 par),
- `apply_sound_occlusion` + `apply_sound_position`: 3,7 µs na słuchacza,
- pogłos z kształtu: 40 obszarów, 31 ms razem, jednorazowo i rozłożone na pierwsze dźwięki w każdym obszarze. Rozkład: 15 łazienka, 13 bez zmian, 6 pokój, 4 korytarz, 1 hala, 1 wyłożony korytarz.

W losowych parach 84% ma ścianę po drodze (≥0,3), a 14% nic. Na statku większość słuchaczy w zasięgu jest w innym pomieszczeniu.

Szacunek dla pełnej rundy: 150 `playsound`/s × 6 słuchaczy × 20 µs ≈ 18 ms/s, czyli ~0,9 ms na tick 50 ms (**~2% `world.cpu`**). Liczby dźwięków na sekundę nie zmierzyłem w prawdziwej rundzie, to założenie (kroki dominują).

**Klient** (CPU procesu Dream Seekera, 20 dźwięków/s przez 25 s, 3 przebiegi):

| Faza | Przebieg 1 | 2 | 3 |
|---|---|---|---|
| bez dźwięków | 1,8% | 2,4% | 2,1% |
| stała pozycja | 1,6% | 4,1% | 2,0% |
| `sound.atom` | 2,2% | 4,9% | 2,3% |

`atom` kosztuje +0,3 do +0,8 punktu procentowego rdzenia, czyli w granicach rozrzutu między przebiegami. Czas klatki z PresentMon w tym mini-świecie nic nie mówi: scena była statyczna, było tylko kilkanaście klatek. W prawdziwej grze FPS nie mierzyłem. Kopie stłumione dokładają 2,5 MB do pobrania.

## Ograniczenia i ryzyko

- Źródło, które w trakcie długiego dźwięku wyjdzie poza widok klienta, milknie. Przy limicie 6 kratek zdarzy się to rzadko (tylko długie dźwięki i szybki ruch).
- Linia prosta (jak raycast w SS14): dźwięk zza rogu przy otwartych drzwiach i tak liczy ścianę na prostej.
- Dźwięki spoza listy kopii za ścianą są tylko ciszej i z mniejszą ścieżką suchą, bez zmiany barwy. Listę poszerza ponowne uruchomienie `aquila/tools/muffle_sounds.py` (np. niższy `MIN_USES`).
- Pogłos jest dalej globalny dla słuchacza (ograniczenie BYOND): strzał z hangaru słyszany na korytarzu ma pogłos korytarza.

## Strojenie (stałe w `sound_occlusion.dm`)

`SOUND_OCCLUSION_VOLUME` (0,5), `SOUND_OCCLUSION_DIRECT` (−2000), `SOUND_OCCLUSION_MUFFLE_THRESHOLD` (0,3), `SOUND_PAN_SOFTNESS` (0,7), `SOUND_TRACK_RANGE` (6). Progi pogłosu w `sound_environments.dm`.

## Jak sprawdzić w grze

1. Stań za ścianą od kogoś, kto strzela albo chodzi: dźwięk ma być cichszy i głuchy. Potem otwórz drzwi między wami: ma być czysty.
2. Przejdź obok pracującej maszyny albo idącej osoby: dźwięk ma płynnie przejść z jednego ucha do drugiego w trakcie trwania.
3. Dźwięk 1–2 kratki z boku ma być wyraźnie z boku, ale słyszalny w obu uszach.
4. Strzał w małym pokoju, na korytarzu i w hangarze: różny pogłos.
5. Jako duch: bez wygłuszenia.

## Co dalej (poza tą gałęzią)

- D2, czyli Web Audio w WebView2 (prawdziwy filtr, pogłos splotowy, HRTF): odłożone. Wysokie ryzyko (autoodtwarzanie, opóźnienie, serwowanie plików).
- Ewentualne głosy za ścianą jako mamrotanie: wymaga decyzji, na razie zostaje cisza.
