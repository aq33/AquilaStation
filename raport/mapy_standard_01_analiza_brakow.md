# Atlantis i Von Neumann a standard Atlasa i Trawnika: analiza braków

Data: 2026-11-07. Stan: `aq33/master` @ 132977ec39. Raport bez zmian w plikach gry.

## 1. Metoda

- Wszystkie typy z obu pokładów Atlasa (`atlas.dmm`, `atlas2.dmm`), Trawnika (`Serendipity1/2.dmm`), Atlantis (`Atlantis.dmm`, `Atlantis2.dmm`) i Von Neumanna (`vnmk3.dmm`) policzone przez `tools/mapmerge2/dmm.py`. Dla porównania także Padalec i Shrike.
- Przecięcie z typami zdefiniowanymi w `aquila/code` i `nsv13/code`, potem macierz mechanik po typach-markerach (sekcja 3).
- Obszary (`/area`) z prostokątami obrysu, wolne kafelki w maintenance, sloty losowych pokoi (`spawner/room`), porty dokowania.
- Rendery przeglądowe `dmm-tools minimap` z siatką współrzędnych, zbliżenia cargo i medbay Atlantis.
- Kod zależny od mapy: `job_changes.dm`, `map_changes.dm`, `_basemap.dm`, `map_check()`, testy z oczekiwaniami per mapa.

Układ pokładów: Atlantis z1 = `Atlantis.dmm` (obszary „deck2”: inżynieria, nauka, ochrona, uzbrojenie, kaplica), z2 = `Atlantis2.dmm` (obszary „deck1”: mostek, SI, telekomunikacja, bar/kuchnia/hydroponika, medbay, cargo, hangar). Von Neumann ma jeden pokład 200x200.

## 2. Błędy, które już teraz psują rundę (niezależnie od „standardu”)

| # | Mapa | Problem | Skutek | Poprawka |
|---|------|---------|--------|----------|
| B1 | Atlantis | brak `/obj/effect/landmark/observer_start` | obserwator z lobby dostaje „Teleportowanie nie powiodło się. Napisz na Ahelp.” i `stack_trace` (`new_player.dm:158`), ghost ląduje w nullspace | 1 landmark, np. w holu mostka |
| B2 | Atlantis | 0 `patrol_node` | abordaż KNPC przerywa się wyjątkiem „This ship does not support KNPCs” (`boarding.dm:101`); misje abordażu na Atlantis nie działają | ok. 12 punktów w korytarzach obu pokładów, jak Atlas (11) i Trawnik (12) |
| B3 | Atlantis | `Atlantis/job_changes.dm` nie jest dołączony w `code/modules/jobs/map_changes/map_changes.dm` | usunięcia wirusologa, kuratora i prawnika oraz 5 slotów pilota nie działają: wirusolog i kurator mają sloty, choć statek nie ma wirusologii ani biblioteki | dopisać include w istniejącym bloku `AQ EDIT` (map_name „NSV Atlantis”) i zdecydować o profesjach (sekcja 5) |
| B4 | Atlantis | `Atlantis.dmm`/`Atlantis2.dmm` nie ma w `_maps/_basemap.dm` (blok `ALL_MAPS`) | CI nie kompiluje mapy, błędy typów i ścieżek w Atlantis przechodzą po cichu | dopisać dwa include (hook z markerem, wpis w `LEGACY_OVERRIDES.md`) |
| B5 | Von Neumann | brak portów `syndicate_*` / `syndicatecutter_*` | prom piratów (`aquila/code/modules/shuttle/pirate.dm`) i dokowanie Syndykatu nie mają celu na VN | porty dokowania przy burtach jak na Atlantis2 |
| B6 | Von Neumann | 0 sortowników `disposalpipe/sorting`, 0 metkownic | poczta rurowa nie działa: paczki z metką nie trafią do działów | sortowniki na istniejącej pętli zsypów (to instalacja, zgoda potrzebna) |
| B7 | Atlantis | 2 wyświetlacze statusu na cały statek (Atlas 45, VN 52), brak `status_display/evac` i `/ai` | brak odliczania ewakuacji i ekranów SI na ścianach | wyświetlacze w korytarzach i działach |

## 3. Macierz mechanik

Liczby to sztuki na całej mapie (wszystkie pokłady). „Brak” = 0.

| Mechanika (port) | Atlas | Trawnik | Padalec | Atlantis | VN | Co dodać |
|---|---|---|---|---|---|---|
| Bitrunning (aq33/AquilaStation#452 i aq33/AquilaStation#453): serwer kwantowy, 3 netpody, konsola, byteforge, konsola zamówień, 3 starty, obszar `bitrunning/den` | jest | jest | jest | **brak** | **brak** | pracownia w slocie losowego pokoju przy cargo (sekcja 4) |
| Exodrony (aq33/AquilaStation#478): wyrzutnia, 2 skanery, 2 konsole, dron | jest | jest | jest | **brak** | **brak** | konsole w biurze górników, skanery w hangarze/próżni |
| Serwery SI (zdecentralizowane): rdzeń danych + główny, szafa serwerowa, chłodnica, 4 konsole, ekran rdzenia, `rack_creator` | jest | jest | jest | **brak** | **brak** | serwerownia telekomunikacji + rdzeń SI |
| Kable ethernet SI (aq33/AquilaStation#499) | 25 | 25 | 70 | **brak** | **brak** | trasa rdzeń - serwerownia - konsole |
| Xenoarcheologia (aq33/AquilaStation#468): 3 maszyny, konsola, artefakt + samouczkowy, labeler, szczypce | jest | jest | jest | **brak** | **brak** | Atlantis: `science/explab`; VN: `science/lab` |
| Gizmo (tgstation/tgstation#95857) | 1 | 1 | 1 | **brak** | **brak** | spawner w RnD |
| Kuźnia amunicji (aq33/AquilaStation#483): kowadło, piec łukowy, stół montażowy, galwanizer, młot, odlewy, analizator | jest | jest | jest | **brak** | **brak** | Atlantis: `nsv/weapons`; VN: `nsv/weapons/port` |
| Shipbreaking (aq33/AquilaStation#489): stół + szafka | jest | jest | jest | **brak** | **brak** | w klatce magnesu (wymaga magnesu) |
| Magnes asteroid (aq33/AquilaStation#442): 2 konsole magnesu, DRADIS górniczy, landmark klatki 40x40, kamera górnicza | jest | jest | jest | **brak** | **brak** (tylko kamera) | klatka 40x40 w kosmosie przy doku górniczym |
| Rynek szlamów (aq33/AquilaStation#487): konsola, pad, kompresor, pady zamówień | jest | jest | jest | **brak** | **brak** | xenobiologia (obie mapy ją mają) |
| Zlecenia cywilne + giełda (aq33/AquilaStation#434) | jest | jest | jest | **brak** | **brak** | lobby cargo |
| Restauracja (aq33/AquilaStation#435): 2 portale, 2 terminale | jest | jest | jest | **brak** | **brak** | bar/stołówka |
| Kuchnia Newfood: patelnia (griddle), piekarnik, wózek | jest | jest | jest (bez wózka) | **brak** | **brak** | kuchnia (wymiana starego sprzętu, nie dokładanie) |
| Botanika BeeStation/BeeStation-Hornet#14133: konsola maszyn, katalog refrakcji, worki podłoża | jest | jest | jest | jest | **brak** konsoli, katalogu, worków | VN: hydroponika 99-104 x 87-99 |
| Genetyka: DNA Infuser | jest | jest | jest | jest | **brak** | VN: genetyka w medbayu |
| Wirusologia: PANDEMIC, lodówka wirusologii, start wirusologa, ekstrapolator, karma dla wirusów | jest | jest | jest | **brak** | PANDEMIC jest, reszty brak | decyzja (sekcja 5) |
| Circuity (aq33/AquilaStation#510): drukarka komponentów, powielacz modułów, BCI | jest | jest | jest | **brak** | **brak** | RnD |
| NTSL (aq33/AquilaStation#495): konsola ruchu telecomms + klucz monitora | jest | jest | jest | **brak** | **brak** | serwerownia telekomunikacji |
| Gułag: teleporter, konsola, odzysk rzeczy, kamera obozu, instrukcja, `has_gulag` + dok `laborcamp_home` | jest | jest | jest | **brak** | **brak** | dok promu przy brygu + `has_gulag` w JSON (sekcja 5) |
| Bryg Aquili: interfejs GenPop, konsola więźniów, implanty wygnania, rower w więzieniu | jest | jest | częściowo | **brak** | konsola jest, reszty brak | bryg |
| Fax | 4 | 5 | 6 | **brak** | 5 | Atlantis: mostek, XO, ochrona, cargo, medbay, nauka |
| Zegary cyfrowe | 7 | 5 | 0 | **brak** | **brak** | korytarze, mostek, stołówka |
| Monitory funkcji życiowych (`aq_vitals_*` przy stazie) | 4 | 5 | 2 | **brak** (7 stazy) | **brak** (2 stazy) | przy każdym łóżku stazy + test `aquila_mapped_vitals_monitors` |
| Dzwonki działów | 5 | 6 | 4 | **brak** | **brak** | lady HoP, medbay, cargo, uzbrojenie, inżynieria, kuchnia |
| Wyświetlacze statusu evac/SI | 31/13 | 19/13 | 5/1 | **brak** | jest | B7 |
| Punkty patrolowe KNPC | 11 | 12 | 6 | **brak** | 10 | B2 |
| `observer_start` | 1 | 2 | 1 | **brak** | 1 | B1 |
| Kaplica: ołtarz bogów, Biblia | jest | jest | jest | **brak** (kaplica jest) | brak (kapelan usunięty) | Atlantis: ołtarz + Biblia w kaplicy |
| Polskie smaczki: Wojtek, sztandar | jest | jest | Wojtek | **brak** | **brak** | Wojtek w uzbrojeniu, sztandar na mostku |
| Automaty Aquili: naklejki, dyskietki profesji, ubrania, szafa szafy grającej, telewizor rozrywkowy | jest | jest | jest | **brak** wszystkich | brak naklejek i TV | korytarze, stołówka |
| Zasilanie Aquili: 4 baterie, rower | jest | jest | baterie | **brak** | **brak** | inżynieria; rower w więzieniu |
| Dyspenser dronów | 1 | 1 | 1 | **brak** | **brak** | robotyka/maint nauki |
| RCD kanalizacji, metkownice, bufor mózgu (`tgui_book/manual/dsm`) itp. drobne | jest | jest | jest | **brak** | **brak** | magazyny działów |
| Generator tarczy statku | 1 | 1 (spawner) | brak | **brak** | jest | decyzja (balans) |
| Konsola PvP (`conquest_beacon`) | 1 | 1 | 1 | **brak** | 1 | CIC Atlantis |
| Losowy silnik (spawner jak `atlasengine`) | jest | w aq33/AquilaStation#578 | w aq33/AquilaStation#578 | **brak** | **brak** | po scaleniu aq33/AquilaStation#578 (sekcja 5) |
| Kanalizacja (aq33/AquilaStation#443) | jest | jest | jest | jest (287 rur) | jest (118) | nic |
| Telecomms, kriogenika, chemia, xenobio, robotyka | jest | jest | jest | jest | jest | nic |

Opisy w `.json`: Atlantis nie ma `map_description`, `manufacturer`, `mapper`, `commission_date`, `strengths`, `weaknesses`, `equipment`, `starmap_path` ani `has_gulag`. W głosowaniu (`MapVote.tsx`) pokazuje „Brak danych”. VN ma wszystko poza `has_gulag`. Atlas, Trawnik i Padalec mają polskie nazwy (NSV Aquilas, DLV Trawnik, NSV Padalec), Atlantis i VN nie.

## 4. Gdzie jest miejsce

**Atlantis.** Maintenance jest długie, ale w większości to korytarze. Na pracownie nadają się sloty losowych pokoi (36 sztuk). Są już obudowane ścianami i stoją przy korytarzach, więc stały pokój w miejscu slotu wygląda jak od mappera i nie rusza obwodu:
- z2 `tenxfive` (104,95) i `fivexthree` (115,96) tuż przy doku górniczym (112-126 x 94-108): **pracownia bitrunnerów** (górnicy obsługują bitrunning), exodrony w biurze górników;
- z2 `tenxten` (81,135) obok telekomunikacji (`area/comms` 69-80 x 129-142): **serwerownia SI**, rack_creator i konsola NTSL;
- z2 `fivexfour` (132,120 i 137,110) w `maintenance/department/medical` przy medbayu: **wirusologia**, jeśli zostaje;
- z1 `tenxten` (160,144) między uzbrojeniem a brygiem: rezerwa (np. gułag albo kuźnia, jeśli w sali uzbrojenia zabraknie miejsca).
Pod dokiem górniczym (y<88) i za rufą jest pusty kosmos na klatkę magnesu 40x40.

**Von Neumann.** Statek jest ciasny, 11 slotów losowych pokoi:
- `tenxfive` (98,70) przy lobby cargo (102-116 x 72-84) i hangarze górniczym (116-123 x 71-79): **bitrunning** albo exodrony;
- `fivexfour` (93,88) i (93,95) w `maintenance/fore` przy lobby nauki i hydroponice: xenoarcheologia lub circuity, jeśli `science/lab` jest za mały;
- serwerownia SI: `tcommsat/server` (47-54 x 68-76) jak na Atlasie;
- klatka magnesu: kosmos na północ (y>125) albo na południe (y<57) od kadłuba.

W slotach nie ma instalacji poza obwodem, ale do nowej pracowni trzeba doprowadzić wentylację, scrubber, kabel do APC i światło. To instalacje, więc rysuję je na podglądzie i czekam na zgodę.

## 5. Decyzje dla użytkownika

1. **Zakres.** Proponuję wszystko z sekcji 3 poza generatorem tarczy dla Atlantis (zmienia balans ciężkiego krążownika) i poza biblioteką (patrz punkt 3). Do potwierdzenia.
2. **Losowy silnik.** Atlantis ma Stormdrive w hali 72-98 x 117-144, VN reaktor AGCR + TEG (unikalny, opisany w JSON jako cecha statku). Proponuję: Atlantis tak, po scaleniu aq33/AquilaStation#578 (3 warianty jak na Trawniku i Padalcu), VN zostaje przy AGCR. W tym PR silników nie ruszam.
3. **Wirusologia i biblioteka.** Atlas ma oba, Trawnik ma wirusologię bez biblioteki. Na Atlantis są miejsca na wirusologię (sloty przy medbayu), na VN nie ma (wirusolog i kapelan usunięci w `job_changes`). Propozycja: Atlantis dostaje wirusologię, VN nie; biblioteka i kurator nigdzie (jak na Trawniku).
4. **Gułag.** Wymaga doku promu obozu pracy na burcie przy brygu (konstrukcja zewnętrzna, śluza) i `has_gulag: 1`. Propozycja: tak na obu, dok przy brygu.
5. **Nazwy statków.** Zostawić „NSV Atlantis” i „SGV Von Neumann” czy spolszczyć jak Trawnik i Padalec? Zmiana `map_name` wymaga też zmiany define w `map_changes.dm` i oczekiwań w testach.
6. **Opisy w JSON.** Uzupełnić Atlantis wzorem Atlasa (opis, producent, mocne i słabe strony, wyposażenie). Teksty po angielsku jak na innych mapach czy po polsku?

## 6. Kolizje z otwartymi PR-ami

- aq33/AquilaStation#550 (Żandarmeria/Orlen/InPost/NFZ): zmienia definicje kluczy TGM w `Atlantis.dmm` (+198/-198), `Atlantis2.dmm` i `vnmk3.dmm`. Konflikty możliwe tylko w słowniku kluczy. Lepiej zacząć edycje po jego scaleniu albo rebase'ować na niego.
- aq33/AquilaStation#566 (konsola sensorów): kilka kafelków w `Atlantis2.dmm` i `vnmk3.dmm`.
- aq33/AquilaStation#578 (losowe silniki): nie rusza Atlantis ani VN; potrzebny dopiero do punktu 5.2.
- aq33/AquilaStation#579 (trwała struktura statku): zapisuje różnice względem mapy. Po zmianie map stary zapis struktury Atlantis/VN może nie pasować; trzeba sprawdzić, czy zapis jest kluczowany wersją mapy.

## 7. Plan wdrożenia (po zgodzie)

Jeden PR, osobne commity na partie:
1. Błędy B1-B5 i B7: landmarki, `map_changes.dm`, `_basemap.dm`, porty dokowania VN, wyświetlacze statusu; JSON-y.
2. Drobne obiekty bez instalacji w istniejących pomieszczeniach: dzwonki, zegary, faxy, monitory stazy, automaty, ołtarz, Wojtek, kuchnia Newfood, restauracja, rynek szlamów, zlecenia i giełda, NTSL, circuity, gizmo, xenoarch, kuźnia, baterie, rower, GenPop, drobne przedmioty.
3. Nowe pracownie w slotach (bitrunning, serwerownia SI z ethernetem, exodrony, wirusologia na Atlantis) z rozpisanymi instalacjami do akceptacji.
4. Magnes, klatka, shipbreaking; dok gułagu.
5. (Osobno, po aq33/AquilaStation#578) losowy silnik Atlantis.

Każda partia: render przed i po, statyczna kontrola rur i kabli, `dm.exe -DCBT nsv13.dme`, kontrola map jak w CI (`--ci dm -DCIBUILDING -DCITESTING -DALL_MAPS`), dla rzeczy z zasilaniem symulacja rundy bez klienta (tymczasowy `data/next_map.json`).

Test regresji: `aquila/code/modules/unit_tests/aquila_map_standard.dm` czyta z dysku `.json` i `.dmm` każdej mapy z rotacji (wzór: `aquila_pirate_shuttle_destinations`) i sprawdza listę wymaganych typów (observer_start, patrol_node, quantum_server, exodrone_launcher, data_core, xenoarch, kuźnia, mineral_magnet, restauracja, faxy, zegary…) oraz włączenie `job_changes.dm` i obecność map w `_basemap.dm`. Do tego rozszerzenie `aquila_mapped_vitals_monitors` i `aquila_pirate_shuttle_destinations` o Atlantis i VN.

Komora testowa: zestaw `pr_<nr>_mapy_standard` z opisem, co obejrzeć na Atlantis i VN (zmiana mapy przez admina), bo pracowni nie da się sprawdzić w komorze.

Wiki: strony Atlantis i Von Neumann (lista pracowni i różnic).
