# Przegląd max: aq33/AquilaStation#582 (Atlantis i Von Neumann do standardu)

Stan gałęzi `mapy-atlantis-vn` na b76f4dec03. W przeglądzie pracowało 11 kątów wyszukiwania, 2 weryfikatorów i jeden przebieg szukający luk. Skrypty i dane robocze leżą w scratchpadzie sesji (`review/`).

Werdykty: P = potwierdzone (weryfikator albo kilka niezależnych kątów), M = możliwe (mechanizm jest, wynik zależy od gry albo od ustawień), O = obalone. „Master” oznacza, że problem istniał już przed PR.

## Poprawność — mapy

| # | Gdzie | Problem | Ryzyko | Werdykt |
|---|---|---|---|---|
| 1 | atl2 (114,97), (116,95); Atlantis2.dmm:12596 | Pracownia bitrunnerów była jedyną drogą do sterowni słonecznej (SMES, konsola solarów). Drzwi (114,97) mają teraz dostęp 48;78, więc inżynier i CE wejdą tylko przez EVA. Odwrotnie: przez śluzę „Auxiliary Shuttle Dock”, która nie wymaga dostępu, każdy z dostępem do maint dostaje się do pracowni. | wysokie | P |
| 2 | atl2 (118,118); Atlantis2.dmm:3385 | MULE „Bolek” i jego beacon „Cargo Bay” stoją w obrysie promu cargo (`supply_home`, x115–126, y112–118). Przy pierwszym przylocie promu MULE ginie, a beacon znika, więc nie ma już domu ani celu dostaw. | wysokie | P |
| 3 | vn (95,87), (95,92), (95,94), (95,99); vnmk3.dmm:7610 | Nowe pracownie (ksenoarcheologia, układy) zachowały drzwi maint ze slotu (dostęp 12), z czego dwoje prowadzi prosto z korytarzy. Asystent omija drzwi naukowe (47). | wysokie | P |
| 4 | atl2 (82,143), (85,143), (87,143); Atlantis2.dmm:11675 | Rdzenie danych SI (w tym główny, w który trafia SI) stoją w `/area/comms` za drzwiami z dostępem 61, który ma każdy inżynier, bez wieżyczek. Na pozostałych mapach główny rdzeń jest w komorze chronionej wieżyczkami. | wysokie (balans/antag) | M |
| 5 | atl1 (132,169); Atlantis.dmm:19213 | Prom obozu pracy po obrocie ma drugie drzwi tytanowe (dostęp 2) na (136,169), a pod nimi otwartą próżnię (136,168). Strażnik, który przez nie przejdzie, rozszczelni prom. Na Atlasie pod drugimi drzwiami jest śluza, na VN ściana (sprawdzone: na VN problemu nie ma). | średnie | P |
| 6 | vn (119,112); vnmk3.dmm:9522 | Teleporter gułagu ma na wszystkich 8 sąsiednich polach coś gęstego (konsola, rower, kopiarka, stoły, szafki, stojak). Nie da się go normalnie otworzyć ani wprowadzić do niego więźnia. | średnie | P |
| 7 | vn (122,73); vnmk3.dmm:10650 | Jedyna konsola magnesu na VN stoi pod Sabre'em górniczym (obrys 2x2). Dopóki prom stoi w hangarze, kliknięcie trafia w Sabre'a. | średnie | P |
| 8 | vn (118,77); vnmk3.dmm:1948 | Recykler złomu stoi na kafelku ściany r_wall. Nie da się na niego wrzucić ani przepchnąć złomu, a arkusze wypadają w ścianę. | średnie | P |
| 9 | atl2 (115,101) Atlantis2.dmm:19868; vn (100,72) vnmk3.dmm:26384 | Wyrzutnie exodronów nie mają pelletu paliwowego (Atlas, Trawnik i Padalec go mają). Dron nie wystartuje, dopóki cargo nie kupi paczki za 600 cr. | średnie | P |
| 10 | atl2 (145..149,105..107) Atlantis2.dmm:5995 i nowe pokoje w slotach: atl2 bitrunning, atl2 sala SI (81..88,135..144), vn ksenoarch, vn układy, vn bitrunning | Brak wentylacji (vent, scrubber) i alarmu powietrza. Po pożarze albo rozszczelnieniu nic nie uzupełnia powietrza. Sala SI na Atlantis dostaje zimny N2 z serwerowni przy każdym przejściu przez śluzę. Wirusologia: braki z mastera (sale chorych), ale PR robi z niej pracownię. | średnie | P (wirusologia), M (reszta) |
| 11 | atl2 (157,118), (158,119), (155,119) Atlantis2.dmm:16644; vn (69,111) | Monitory funkcji życiowych nachodzą na siebie: dwa rysują się w tym samym miejscu ściany (157,119), jeden na alarmie pożarowym, jeden na wyświetlaczu statusu. Monitor (160,120) wisi 3 pola od łóżka. | średnie | P |
| 12 | atl1 (122,165) Atlantis.dmm:18803; vn (120,112) | Rowery więzienne nie stoją na kablu, więc nie podłączają się do sieci i nie dają prądu. | niskie | P |
| 13 | vn (108..112,96); vnmk3.dmm:14234 | Konsola zasobów SI, konsola serwerów, szafa i chłodnica stoją w komorze rdzenia SI (dostęp 16). Inżynier z dostępem tcomms, do którego jest skierowana konsola, tam nie wejdzie. Plan zakładał tcommsat/server. | niskie | P |
| 14 | Nakładki urządzeń ściennych: atl2 (147,109) znak na alarmie powietrza, (100,139), (118,107), (133,149); atl1 (110,147) (wyświetlacz na guziku rolet EVA), (117,107) (na APC kaplicy), (123,142), (124,99), (126,155); vn (123,103), (157,99) zegar na oknie, (95,98) lampa na drzwiach | Sprite'y przykrywają się nawzajem i przejmują kliknięcia. | niskie | P |
| 15 | atl1 (131,166) Atlantis.dmm:11210 | Automat zwrotu rzeczy gułagu wisi nad szafką GenPop. Zwracane rzeczy lądują na jej kafelku i przy zamknięciu szafki trafiają do środka. | niskie | P |
| 16 | vn (98..107,70..74) i atl2 (115..119,96..98) | Pracownie bitrunnerów mają obszary `cargo/lobby` i `miningdock` zamiast `bitrunning/den` (plan). Na VN lobby rozpada się na dwa kawałki zasilane z APC w innym pokoju. | niskie | P |
| 17 | vn | Brak `slime_extract_requestor` (zlecenia ekstraktów), choć plan wymieniał „pady zamówień” (Atlantis dostał dwa). | niskie | P |
| 18 | vn (104,110) | Duplikaty pudełek implantów trackimp i chemimp w zbrojowni. | niskie | P |
| 19 | atl2 (126,95) + (134,141) | Dwie konsole magnesu z osobnym stanem mogą ściągnąć dwa obiekty do jednej klatki. Ten sam układ jest na Atlasie; to błąd w kodzie konsoli, nie w mapie. | niskie | P (kod z mastera) |

Obalone: drzwi bitrunnerów na VN (102,69)/(101,75) nie rozcinają sieci maint (zabierają tylko skrót przez dawny slot). Na VN drugie drzwi promu gułagu trafiają w ścianę, nie w próżnię. Cykl śluz ksenobiologii na Atlantis (148,115)/(150,113) i reaktora to błędy z mastera, PR ich nie ruszał.

Poza PR, ale znalezione przy okazji (master): landmarki startowe Starszego Oficera na Atlantis (147,148) i VN (144,90), (151,88), (145,90) mają `name = "Executive Officer"`, a SSjob szuka „Starszy Oficer”, więc XO startuje w losowym miejscu.

## Test i CI

| # | Gdzie | Problem | Werdykt |
|---|---|---|---|
| 20 | aquila_map_standard.dm:50 | `map_has_type` przeszukuje cały tekst TGM łącznie z nieużywanymi kluczami słownika. Trawnik od aq33/AquilaStation#572 nie ma na siatce żadnej drukarki komponentów (została tylko w martwym kluczu „be”), a test przechodzi. To samo dotyczy `laborcamp_home` (nie sprawdza `roundstart_template`). | P |
| 21 | aquila_map_standard.dm:71 | `MAP_REMOVE_JOB(x)` sam tworzy typ `/datum/job/x`, więc literówka przechodzi (`brig_phys` na Atlasie, Trawniku i VN; `hydro`, `rd` i inne na Shrike). Gałąź `continue` nigdy się nie wykona. `job_slots.dm` nadpisuje `map_check()` bez `..()`, więc część usunięć jest niewidoczna. Zmiany slotów w `New()` nie są sprawdzane. | P |
| 22 | aquila_map_standard.dm:8 | Lista map wpisana ręcznie pomija Shrike (głosowalny w `config/maps.txt`). JSON jest parsowany ręcznie, choć istnieje `load_map_config()`. Ta sama lista jest też w `aquila_mutation_toxins.dm:125` i `aquila_wounds.dm:142`. | P |
| 23 | aquila_wounds.dm:142 | Oczekiwane liczby monitorów dla Atlantis i VN nigdy nie wykonują się w CI, bo CI ładuje mapę domyślną (Atlas), a nie runtimestation (komentarz w teście jest błędny). | P |
| 24 | aquila_map_standard.dm:52, 57, 97; aquila_mutation_toxins.dm:132 | `findtext` (bez rozróżniania wielkości liter) jest ok. 55× wolniejszy od `findtextEx`. Około 0,8 s na przebieg CI. | P (pomiar) |
| 25 | aquila_map_standard.dm:68 | `SSmapping.config.map_name` jest zmieniane globalnie i nie zostanie przywrócone, jeśli `New()` profesji rzuci wyjątek. | M |
| 26 | CI (build.js) | CI nie kompiluje gulag.dmm, asteroid i ruin magnesu ani domen bitrunningu (build.js nadpisuje `_maps/templates.dm`). Problem z mastera, ale PR podpina te mapy do dwóch kolejnych statków. | P |

## Zasady repo i porządki

| # | Gdzie | Problem | Werdykt |
|---|---|---|---|
| 27 | `_maps/_basemap.dm:24`, `map_changes.dm`, `Atlantis/job_changes.dm` | Nowe hooki core nie są wpisane do tabeli „Core hooks” w `aquila/LEGACY_OVERRIDES.md` (zasada w CLAUDE.md, a plan B4 to obiecywał). | P |
| 28 | Faksy, porty, beacony | Nowe nazwy widoczne dla gracza są po angielsku („Engineerings Fax Machine” z literówką, „atlantis gulag shuttle dock”). Skopiowane z Atlasa. `location` beaconów musi zostać, `fax_name` i nazwy portów można przetłumaczyć. | P |
| 29 | vn (115,115), (122,115) | „Techniczne brygu”: słownik ma Brig → Areszt („Bryg” odrzucone). W changelogu „faxy” i „beacony” zamiast „faksy” i „radiolatarnie/nadajniki”. | P |
| 30 | Scalenie aad57a0a29 | `merge3.py` przekluczył ok. 359 niezmienionych kafelków, co zwiększa diff i ryzyko konfliktów. | P |
| 31 | Commit bd56414dfa | Nie buduje się z `-DALL_MAPS` (błędy Atlantis naprawione dopiero w następnym commicie). Przy squashu bez znaczenia. | P |
| 32 | raport/mapy_standard_01 | Gołe numery PR i skróty (`AQ#…`, `Bee#…`, `tg#…`) zamiast `owner/repo#N`. | P |
| 33 | Zestaw komory pr_582 | W komorze powtarza tylko to, co sprawdzają już pr_500 i pr_457. | P |

## Stan po poprawkach (2026-11-08)

Poprawione w aq33/AquilaStation#582:
- 1: drzwi pracowni bitrunnerów (114,97) mają dostęp 10;48;78, więc inżynier przechodzi do sterowni słonecznej. Drzwi „Solar Control” (116,95) wymagają już tylko dostępu 10, więc przez EVA da się wejść najwyżej do sterowni.
- 2: MULE „Bolek” i beacon „Cargo Bay” stoją na (118,119), poza obrysem promu cargo. Rozładunek jest na (117,119).
- 3: cztery drzwi ze slotów do pracowni nauki na VN mają dostęp 47. Lampa ksenoarcheologii nie wisi już na drzwiach.
- 5: pod drugimi drzwiami promu obozu pracy (136,167–168) jest krótka ściana kadłuba, jak na Padalcu.
- 6: teleporter i konsola gułagu na VN stoją pod południową ścianą korytarza aresztu (111,108)/(112,108). Pokój ochrony wrócił do stanu z mastera.
- 7, 8: konsola magnesu na VN stoi na (123,74) przy wschodniej ścianie hangaru, recykler złomu na (119,76).
- 9: pellety paliwowe leżą przy wyrzutniach na obu mapach (test tego pilnuje).
- 11, 14: monitory i urządzenia ścienne przestawione albo usunięte (jeden zegar i jeden wyświetlacz na Atlantis). Alarm pożarowy przy łóżku (156,118) przeniesiony na (153,116). Skrypt kolizji nie znajduje już nakładek.
- 15: automat zwrotu rzeczy na Atlantis wisi na ścianie korytarza aresztu (135,165), tuż za kołowrotem z pokoju przyjęć.
- 17: pad zamówień ekstraktów na VN stoi w lobby nauki przy oknie ksenobiologii (79,92) (test tego pilnuje).
- 18: zostało tylko nowe pudełko implantów wygnania.
- 20: test liczy tylko klucze postawione na siatce. Port gułagu musi mieć `roundstart_template` promu. Drukarka układów wróciła na Trawnik (124,121) (zgubiona w aq33/AquilaStation#572). Sprawdzone: bez niej test oblewa.
- 21: test odrzuca `MAP_REMOVE_JOB` z typem, który nie jest profesją stacji. `brig_phys` zamienione na `brig_physician` na Atlasie, Trawniku i VN.
- 24: `findtextEx` w obu testach. Test map trwa ok. 0,5 s.
- 27: wpisy w „Core hooks”, blok `AQ EDIT START/END` w `_basemap.dm`.
- 28, 29: faksy, porty Syndykatu i doki gułagu mają polskie nazwy (z angielskimi w `en_translated.json`). „Tunele techniczne aresztu” zamiast „Techniczne brygu”.
- 32: pełne `owner/repo#N` w raporcie 01.

Do decyzji (instalacje albo balans, CLAUDE.md wymaga zgody): 4 (rdzenie SI na Atlantis), 10 (wentylacja nowych pokoi), 12 (kabel do rowerów; rower na VN chwilowo usunięty), 13 (konsole SI na VN), 16 (obszar `bitrunning/den` wymaga APC i alarmu powietrza).

Bez zmian: 19 (kod konsoli magnesu, ten sam układ jest na Atlasie), 22, 23, 25 (lista map w testach), 26 (CI nie kompiluje map gułagu, asteroid ani domen), 30, 31 (historia gałęzi), 33.
