# Sensory: plan wdrożenia MVP

Na podstawie `sensory_01_analiza.md`, sekcja 11. Kod jeszcze nie powstał. Ten plan czeka na zgodę.

## Hipoteza

Gracze, którzy latają ciszej, są później wykrywani przez AI i dzięki temu wybierają, kiedy zaczyna się walka. Przy 1–2 osobach na mostku runda wygląda tak jak dziś.

## Zasada techniczna: jeden punkt decyzji

Odległość i widoczność sprawdza dziś kilka miejsc w kodzie, ale wszystkie przechodzą przez `is_sensor_visible(observer)`:

| Miejsce | Kod |
|---|---|
| AI wybiera cel | `ai-skynet.dm:1721` |
| AI porzuca pościg | `ai-skynet.dm:1507` |
| nałożenie namiaru | `overmap.dm:661` |
| utrzymanie namiaru | `physics.dm:441` |
| blip w DRADIS | `radar.dm:380` |
| automatyczna obrona | `autonomy.dm:46` |

Dlatego **całe MVP opiera się na jednym nadpisaniu `is_sensor_visible` z `..()`**. Gdy cel jest dalej niż jego zasięg wykrycia (liczony z sygnatury) dla danego obserwatora, procka zwraca `SENSOR_VISIBILITY_GHOST`. W pozostałych przypadkach zwraca wynik oryginału.

Wyjątki pozostają takie jak dziś i są sprawdzane przed odcięciem:
- cel niedawno wysłał impuls radaru;
- cel oznacza obserwatora;
- obserwator jest w zasięgu `sensor_profile` celu (kara po EMP);
- sojusznicy.

Nie trzeba edytować core ani dopisywać `LEGACY_OVERRIDES`.

**Wspólne cele floty** (`shared_targets`): okręt AI zgłasza cel, dopóki sam go widzi, i przestaje przy utracie kontaktu (`ai-skynet.dm:1507–1511`). Gdy cel wychodzi z zasięgu każdego okrętu we flocie, lista się opróżnia. Działa to jak nasze łącze danych, więc nie zmieniam tego. W teście sprawdzę, że okręt, który zamilkł, wypada z listy.

## Zakres

### 1. Sygnatura okrętu
Nowy plik: `aquila/code/modules/overmap/sensor_signature.dm`.

- Nowe zmienne na `/obj/structure/overmap`:
  - `sensor_signature`, przeliczana na bieżąco;
  - `thrust_heat`, zanikająca średnia ciągu;
  - `last_weapon_fire`, czas ostatniego strzału.
- Nadpisanie `/obj/structure/overmap/slowprocess()` (co 0,7 s, `physics.dm:122`) przelicza sygnaturę **przed** `..()`, bo `..()` woła `ai_process()`.
- Składniki sygnatury (parametry do testów, każdy jako `#define` w pliku):
  - **baza według `mass`** (`__DEFINES/overmap.dm:73–80`): TINY 0,4 · SMALL 0,5 · MEDIUM_SMALL/MEDIUM 0,6 · MEDIUM_LARGE 0,7 · LARGE 0,8 · TITAN 1,0 · IMMOBILE 1,3;
  - **ciąg**: `thrust_heat = thrust_heat * 0,85 + (last_thrust_forward || last_thrust_right || brakes ? 1 : 0) * 0,15`, a potem +0,5 × `thrust_heat`;
  - **tłumiki** (`inertial_dampeners`): +0,1;
  - **strzał**: +0,4 przez 10 s od `last_weapon_fire`;
  - **uszkodzenia**: +0,3 × (1 − `obj_integrity`/`max_integrity`), a przy `hullburn` > 0 dodatkowe +0,1;
  - **maskowanie**: × `alpha`/255.
- `last_weapon_fire` ustawia nadpisanie `/datum/overmap_ship_weapon/proc/fire_proc_chain()` z `..()`, gdy `.` > 0. Bez powtarzania `SHOULD_NOT_SLEEP`.

### 2. Zasięg wykrycia i odcięcie widoczności
Ten sam plik.

- Nowa procka `/obj/structure/overmap/proc/get_detection_range(obj/structure/overmap/observer)`:
  - dla AI (`observer.ai_controlled`): `observer.max_tracking_range * sensor_signature`;
  - dla gracza: `(observer.dradis?.sensor_range || SENSOR_RANGE_DEFAULT) * 1,5 * sensor_signature`;
  - wynik ograniczony do zakresu od `SENSOR_MIN_DETECTION` (15, ale nie mniej niż `max_weapon_range` celu) do `SENSOR_MAX_DETECTION` (100).
- Impuls radaru ustawia `sensor_range` konsoli na `world.maxx`, więc zasięg rośnie sam i dzisiejsze działanie impulsu zostaje bez zmian.
- Nadpisanie `is_sensor_visible` z `..()` według zasady opisanej wyżej.
- Wydajność: koszt to jedno `overmap_dist` i mnożenie na wywołanie, bo sygnatura jest liczona wcześniej.

### 3. Niepewne kontakty w DRADIS
Nowy plik: `aquila/code/modules/overmap/dradis_uncertainty.dm`.

- Nadpisanie `/obj/machinery/computer/ship/dradis/ui_data()` z `..()`. Po wywołaniu przechodzi przez `data["ships"]`:
  - Blip jest nierozpoznany, jeśli nie jest w zasięgu identyfikacji. Dziś oznacza to `name == "NIEZNANY"`. To porównanie tekstu, więc lepiej sprawdzić to samo co oryginał (`overmap_dist <= max(sensor_range, sensor_profile)`) po `id`.
  - Nierozpoznany blip dostaje przesunięte `x`/`y` i pole `uncertainty` (promień w polach): `2 + 6 × dist/zasięg wykrycia`.
- Przesunięcie jest trwałe: lista na okręcie-obserwatorze, `sensor_offsets[cel] = list(dx, dy)`. W każdym `slowprocess` przesuwa się o ±1 w losowym kierunku, w granicach promienia. Trzyma je okręt, a nie konsola, więc druga konsola nie daje dodatkowych próbek. Wpis czyści się przy `COMSIG_PARENT_QDELETING` celu albo przy zmianie systemu.

### 4. Kontakt „ostrzał z namiaru”
Ten sam plik co punkt 3.

- Nadpisanie `/obj/structure/overmap/bullet_act()` z `..()`. Jeśli `P.overmap_firer` istnieje i `is_sensor_visible(src)` < FAINT, wpisuje `hit_ghosts[firer] = list(x, y, world.time)` z pozycją strzelca w chwili trafienia.
- `ui_data` dokleja do `ships` wpisy z `hit_ghosts` młodsze niż 10 s: kolor pomarańczowy, nazwa „Źródło ostrzału”, duża niepewność.
- Kontaktu nie można namierzyć, bo nie ma `id`.
- Komunikat na mostku z limitem spamu (wzorem `last_missile_warning`): „Ostrzał z niewykrytego źródła, namiar NNN”.

### 5. Ostrzeżenie o namiarze w PvP
Ten sam plik co punkt 3.

- Nadpisanie `/obj/structure/overmap/proc/finish_lockon()` z `..()`. Gdy cel nie jest sterowany przez AI, ma `linked_areas` (czyli załogę) i namiar został nałożony bez łącza danych:
  - `target.relay('nsv13/sound/effects/fighters/being_locked.ogg', ...)`;
  - komunikat dla `target.gunner` i `target.pilot`: „Namiar ogniowy z kierunku NNN!”.
- Wzorem tego, co gracz dostaje od AI (`ai-skynet.dm:1625`).

### 6. Interfejs DRADIS
Plik: `tgui/packages/tgui/interfaces/Dradis.tsx`. To zmiana w core TGUI, więc z markerem `// AQ EDIT` i wpisem w tabeli „Core hooks”.

- Jeśli blip ma `uncertainty`: półprzezroczysty okrąg o tym promieniu (w skali `zoom_factor`) ze znakiem „?” zamiast kropki.
- Podpowiedź: „Niepewny kontakt, pozycja przybliżona. Podejdź bliżej albo użyj radaru.”
- Bez nowych przycisków.
- Wymaga przebudowy bundle.

### 7. Rejestracja i dokumentacja
- `aquila/aquila.dm`: dopisać nowe pliki w kolejności sensor_signature → dradis_uncertainty, a w bloku `#ifdef UNIT_TESTS` dopisać testy.
- `aquila/LEGACY_OVERRIDES.md`: jedynie hook w `Dradis.tsx`.
- `aquila/SLOWNIK_TLUMACZEN.md`: „sygnatura”, „niepewny kontakt”, „namiar ogniowy”.

## Testy

Plik: `aquila/code/modules/unit_tests/sensor_signature.dm`, z własnymi kopiami makr `TEST_ASSERT*`.

1. Sygnatura okrętu z ciągiem jest większa niż na dryfie. Sygnatura po strzale (`last_weapon_fire = world.time`) jest większa niż bez strzału.
2. Regresja AI: okręt gracza na dryfie poza `max_tracking_range * sygnatura` nie jest wybierany przez `seek_new_target`. Po impulsie radaru jest wybierany.
3. Wyjątki: przy `target_painted` i przy `sensor_profile` > dystans widoczność nie spada do GHOST.
4. Przesunięcie niepewności nie wychodzi poza promień przez 50 kroków i nie zmienia się między dwoma wywołaniami `ui_data` w tym samym kroku.

**Komora testowa:** `aquila/code/modules/test_chamber/kits/pr_<nr>_sensory.dm`. Zawiera przedmioty pomocnicze, a w `setup()` przywołuje nieuzbrojony okręt AI Syndykatu w bieżącym systemie. Opis: lecieć na dryfie i sprawdzić, z jakiej odległości AI cię łapie, wysłać impuls i porównać, otworzyć DRADIS i obejrzeć okręgi. Numer PR uzupełnię po jego otwarciu.

**W grze:** okręt AI w systemie. Sprawdzić dryf i pełny ciąg, impuls, trafienie z niewidocznego kierunku i (z drugim graczem) ostrzeżenie o namiarze. Kliknięcia idą tylko przez TGUI, więc tryby sterowania (combat mode i intencje) nie mają tu znaczenia.

## Poza MVP (osobne PR-y)

- migawka radaru i dłuższy minimalny odstęp impulsów;
- ostatnia znana pozycja i wektory ruchu;
- identyfikacja odsłaniana z czasem;
- macierz sensorów (wymaga map);
- zagłuszacz (ECM);
- działający AWACS;
- impuls trybu aktywnego przeniesiony z `ui_data` do procesu okrętu;
- transponder.

## Ryzyka i otwarte pytania

- **Twardy przełącznik w PvP i PvE.** Proponuję zmienną konfiguracyjną (`GLOBAL_VAR_INIT(sensor_signature_enabled, TRUE)`) z przełącznikiem admina, żeby dało się wyłączyć system w trakcie rundy, jeśli wyjdzie źle.
- **Zamaskowane okręty AI** (`cloak_factor` 80–100) staną się jeszcze trudniejsze do wykrycia, bo mnożnik alpha działa do tego pomnożony z obecnymi progami. Może wymagać obniżenia minimalnej sygnatury albo pominięcia mnożnika dla AI.
- **Gracze w myśliwcach** mają zasięg 30, więc wykrywają dalej tylko o 45 × sygnatura celu. Do sprawdzenia, czy zwiad myśliwcami ma sens bez AWACS.
- **Wiki:** nowa sekcja „Sygnatura i wykrywanie” na stronie DRADIS lub Overmap (do ustalenia po scaleniu).

## Szacunek

Około 250–350 linii DM, około 40 linii TSX i 4 testy. Jeden PR. Tytuł: `Overmap: sygnatura okrętu i niepewne kontakty w DRADIS`.
