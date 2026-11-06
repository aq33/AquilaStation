# Kable i sieci energetyczne: przegląd (5.11.2026)

Zgłoszenie: „co jakiś czas w kablach znika prąd i wraca po dłuższej chwili”.
Zakres: Smartwires (`code/modules/power/cable.dm`, `cable_coil.dm`, `powernet.dm`, `power.dm`),
kolejka sieci w `code/controllers/subsystem/machines.dm`, ładowanie map, maszyny NSV zasilane z kabla.
`code/modules/power/multiz.dm` (przekaźniki pokładowe) nie jest w buildzie i został pominięty.

## Już poprawione na tej gałęzi

### 0. Po przecięciu cała sieć statku mogła przejść do nowej, pustej sieci (wysokie)
`code/modules/power/powernet.dm`, `repropogate_cables()`.
Stary obiekt sieci zostawał przy kawałku z `cables[1]`, czyli z przypadkowym kablem. Gdy przecięcie
(mysz, gracz, wybuch) odcinało właśnie ten kabel, reszta statku dostawała nową sieć z `avail = 0`.
Skutki: jeden takt bez prądu, APC przestają się ładować (wznawiają po 10 taktach, około 20 s), działa
i tarcze z kabla tracą zasilanie, monitor mocy zaczyna od 0 i wraca do właściwej wartości po około 40 s.
Poprawka: stary obiekt zostaje przy największym kawałku. Test `smartwires_split_keeps_main_grid`
bez poprawki pada, z poprawką przechodzi.
Ograniczenie: największy kawałek (w kablach) nie musi być tym z generatorami. Jeśli przecięcie odetnie
małą maszynownię od reszty, maszynownia dostaje nową sieć z 0 na jeden takt. Nie da się tego ogólnie
rozpoznać bez większej zmiany, bo silnik burzowy, RBMK i rośliny piszą do `newavail` bezpośrednio.

## Znalezione w przeglądzie (1–3 poprawione na tej gałęzi, z testami)

### 1. Kolejka brudnych sieci pomija element (średnie, poprawione: test `smartwires_dirty_queue`)
`code/controllers/subsystem/machines.dm:67`.
Po zamianie bieżącego elementu z ostatnim indeks rośnie przy `dirty_stop_index <= length`. Gdy
`length == dirty_stop_index`, ostatni element jest jeszcze z tego przebiegu, a mimo to zostaje pominięty.
Przykład: kolejka [A, B, C] → przetworzone A i B, C czeka do następnego taktu (2 s).
Skutek: odcięty kawałek sieci przez dodatkowy takt dalej korzysta z prądu starej sieci, a ponowne
przeliczenie sieci przychodzi później. To nie powoduje zaników, tylko opóźnia rozcięcie.
Poprawka: kolejka jest przetwarzana z migawki (`process_dirty_powernets()` w
`aquila/code/modules/power/smartwires.dm`), bez indeksów. Usunięta w trakcie sieć jest pomijana, a sieć
dodana w trakcie przebiegu czeka do następnego taktu. Ten sam błąd jest w Bee.

### 2. Przecięcie kabla wielopokładowego może się zapętlić (średnie, poprawione: test `smartwires_multiz_deconstruct`)
`code/modules/power/cable.dm:274-277`, `deconstruct()`.
Kabel `multiz` rozbiera kable `up` i `down`. Gdy dwa kable `multiz` są nad sobą (mapowany
`/obj/structure/cable/multiz` pod kablem na open space albo dwa pokłady open space), A.up = B i
B.down = A. Wtedy A rozbiera B, B znowu A i tak dalej. `qdel` jest dopiero w `..()` na końcu, więc nic
nie przerywa pętli przed limitem rekurencji. Spodziewany skutek: runtime, kable zostają na miejscu,
a na kafelku zbierają się zwoje kabla. Tak samo jest w Bee.
Poprawka: rozbierać sąsiada tylko wtedy, gdy nie jest już w trakcie rozbiórki, np. zapamiętać i
wyzerować `up` i `down` przed wywołaniem (`var/c = up; up = null; c?.deconstruct()`) albo sprawdzić `QDELETED`.
Nie odtworzone w grze. Warto potwierdzić na mapie z `cable/multiz` (Serendipity, Shrike, Snake).
Po poprawce przecięcie usuwa tylko kable tuż nad i pod przeciętym, nie cały stos przez wszystkie pokłady.

### 3. Łączenie sieci gubi prąd wchłoniętej sieci na jeden takt (niskie, poprawione: test `smartwires_merge_keeps_power`)
`code/modules/power/power.dm:184-205`, `merge_powernets()`.
Mniejsza sieć (liczona w kablach) jest wchłaniana, ale jej `avail`, `newavail`, `load` i `delayedload`
nie przechodzą do większej. Jeśli mniejsza to ta z generatorami lub SMES-ami, jej odbiorcy przez jeden
takt widzą tylko prąd większej sieci. Poprawka: dodać te cztery wartości do `net1` przed przeniesieniem.

### 4. Kable przy ładowaniu mapy łączą się dwa razy (niskie, wydajność, bez zmian)
`code/modules/power/cable.dm:104-106` i `code/controllers/subsystem/atoms.dm:33`.
Komentarz zakłada, że podczas ładowania mapy `LateInitialize` widzi `INITIALIZATION_INNEW_MAPLOAD`.
Late loadery chodzą jednak już po `clear_tracked_initalize()`, więc każdy kabel z mapy sam łączy
i scala sieci, a potem `makepowernets()` / `setup_template_powernets()` robi to od nowa.
Działa poprawnie, tylko podwójnie kosztuje przy starcie i przy ładowaniu statków.

## Rzeczy, które wzmacniają krótkie zaniki (projekt, nie błąd)

- `nsv13/code/game/machinery/inertial_dampener.dm:47-60`: tłumik wyłącza się (`on = FALSE`) już po
  jednym takcie bez nadwyżki i nie włącza się sam. Każdy zanik wyłącza go na stałe.
- `nsv13/code/modules/overmap/shieldgen.dm:276-290`: generator tarcz po takcie bez prądu ustawia
  `active = FALSE` i traci integralność.
- APC (`code/modules/power/apc.dm:1373-1382`): po przerwaniu ładowanie wraca dopiero po 10 taktach nadwyżki.
- Maszyna zbudowana w trakcie rundy na końcu kabla ma tylko darmowy węzeł. Przedłużenie kabla dalej
  zabiera węzeł i odłącza maszynę (`cable.dm:216-232`, `disconnect_from_machines()`). Gracz musi dodać
  węzeł zwojem. Tak działa Smartwires w Bee, ale to wygląda dla gracza jak „zniknął prąd”.

Poprawka 0 usuwa najczęstsze źródło tych krótkich zaników, więc te zachowania przestają się kumulować.
