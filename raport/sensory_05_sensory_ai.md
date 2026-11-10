# Sensory AI: zestawy sensorów i korzystanie z nich

Notatka do `aquila/code/modules/overmap/ai_sensor_suites.dm` i `ai_sensor_use.dm`.
Dotyczy wyłącznie okrętów AI. Gracz dalej ma jeden DRADIS z `sensor_range` i impuls radaru.

## Po co

Po #566 okręt ma sygnaturę: im więcej pali silnikami, strzela i płonie, tym dalej go widać.
Problem w tym, że AI z tego nie korzystało. Miało jedną liczbę zasięgu, pulsowało radarem zawsze,
gdy nie miało celu, a gdy cel zniknął z sensorów, leciało prosto przed siebie (`ai-skynet.dm`,
`/datum/ai_goal/seek/action`). Wyglądało to tak, jakby wróg albo wiedział wszystko, albo nic.

## Zestawy sensorów

Jedna sygnatura zostaje rozbita na składniki, które liczy `sensor_signature.dm`:

| Składnik | Co go podnosi | Proc |
|---|---|---|
| rozmiar | masa okrętu | `get_signature_size()` |
| ciepło | ciąg, tłumiki, pożar kadłuba, uszkodzenia, świeży strzał | `get_signature_heat()` |
| emisja | impuls radaru | `radar_emission.dm` |

Każdy sensor czyta inny składnik, więc zasięg zależy od tego, co cel robi:

| Sensor | Zasięg | Czyta | Zdradza nas |
|---|---|---|---|
| optyczny | `max(30 × rozmiar, 15)` | rozmiar | nie |
| termiczny (IR) | `70 × ciepło` | ciepło | nie |
| lidar | `max_tracking_range` tylko w trakcie własnego impulsu | wszystko | tak, jako emisja |
| nasłuch (ESM) | słyszy cudze impulsy, sam namiar bez pozycji | emisja | nie |

Wykrycie to najlepszy z zasięgów (`get_best_suite()`), a to, który sensor trzyma kontakt,
zostaje zapisane w `sensor_contact_suites` — stąd bierze je nagranie i decyzje z `ai_sensor_use.dm`.

Liczby dobrane tak, żeby zostać przy dzisiejszej skali: okręt średniej masy na pełnym ciągu
widać z około 40–45 pól (przedtem około 60 z jednej sygnatury), a ten sam okręt dryfujący
z zimnymi silnikami — z około 18, czyli tylko optycznie.

## Co AI z tym robi

- **Ostatnia znana pozycja.** Dopóki widzi cel, zapisuje jego pozycję i prędkość.
  Gdy kontakt znika, leci do punktu wyliczonego z tego kursu (`get_ai_contact_guess()`),
  tam pulsuje raz i przez 45 s przeczesuje okolicę, zanim odpuści.
- **Dyscyplina radarowa.** Nie pulsuje, gdy cel i tak jest na sensorze pasywnym,
  gdy ucieka albo podchodzi cicho. We flocie pulsuje jeden okręt na 12 s,
  a ostrożny dowódca czeka 24 s, czyli zwykle zostawia to komuś innemu.
- **Cisza w ucieczce.** Uciekający okręt, którego ścigający już nie wykrywa, gasi silniki
  i tłumiki i leci rozpędem. Ciepło spada, więc IR go gubi na dobre.
- **Namiar z nasłuchu.** Usłyszany impuls jest tropem nie tylko dla okrętu bez celu,
  ale i dla tego, który właśnie zgubił kontakt; flota dostaje ten sam namiar z rozrzutem,
  żeby okręty nie leciały jedna linią.
- **Ciche podejście.** Okręt, który widzi cel, nie jest przez niego widziany i jest jeszcze
  poza zasięgiem broni, podchodzi z wyłączonymi tłumikami i bez impulsów.

## Co wie flota

Upstream dzieli cele przez `shared_targets` (`ai-skynet.dm:75`): jedna lista raportujących na cel.
Okręt, któremu ktoś raportuje, trzyma `last_target` i leci do jego **prawdziwych współrzędnych**,
nawet jeśli sam nie ma żadnego kontaktu — a `seek_new_target()` potrafi wziąć cel z floty
(`ai-skynet.dm:1738`) okrętowi, który nigdy go nie widział. Przy sensorach to znaczyło, że zgaszenie
silników chowa cię przed jednym okrętem, a reszta floty dalej leci prosto na ciebie.

`ai_fleet_picture.dm` zamienia to na obraz sytuacji:

- **Meldunek niesie pozycję, kurs i czas** (`report_ai_contact()`), nie referencję do okrętu.
- Okręt bez własnego kontaktu leci do punktu z meldunku, wyliczonego z kursu
  (`get_ai_blind_point()` w `move_toward`), a nie do celu.
- Meldunek starzeje się po 30 s. Gdy wygasa, cel wypada też z `shared_targets`,
  więc cała flota gubi go dokładnie tak, jak gubi go pojedynczy okręt.
- **Szpica**: jeden okręt na flotę ma prawo do radaru przez 60 s (`is_ai_picket()`),
  nigdy lotniskowiec ani uciekający. Reszta leci zimna i korzysta z jego obrazu.
- **Triangulacja**: dwa okręty, które usłyszały ten sam impuls, przecinają swoje namiary
  (`triangulate_ai_emission()`); przy namiarach bliższych niż 12° wynik jest odrzucany,
  bo przecięcie jest bezużyteczne.
- **Zasadzka**: flota z `FLEET_TRAIT_DEFENSE` bez żadnego celu dryfuje z zimnymi silnikami
  i bez radaru, dopóki coś nie wejdzie w 90% jej zasięgu wykrycia.

Każde z tych czterech ma własny przełącznik, żeby dało się je pokazywać pojedynczo.

## Jak okręty się ustawiają

Z nagrań wyszły dwie rzeczy, które psuły wrażenie walki:

- Okręty trzymające dystans **stały w miejscu**: 22–41% klatek z prędkością poniżej 0,3 pola/s,
  lotniskowce 27–68%, a w 43% tych klatek okręt nawet się nie obracał. Przyczyną był kod z #569,
  który w pasie wokół celu wołał `circle_around()` i zaraz `enable_dampeners()` — tłumiki
  wyhamowywały okręt do zera. Stojące okręty siedziały w 20–50 polach od wroga, czyli dokładnie
  w tym pasie.
- Pojedyncze okręty **wchodziły same w kilku wrogów** (0,7% klatek przy kryterium: dwóch wrogów
  bliżej niż 25 pól, najbliższy swój dalej niż 40).

`ai_formation.dm` zmienia oba:

- `get_ai_standoff_point()` daje punkt na okręgu dystansu, odsunięty o 45–110° od obecnego namiaru;
  okręt leci do niego, a po dotarciu albo po 6–13 s wybiera następny. Stronę okrążania wybiera tę,
  po której są jego sojusznicy, więc flota się schodzi. Tłumiki już nie zatrzymują okrętu w pasie.
- `ai_waits_for_support()` liczy wrogów w promieniu 45 pól i swoich w promieniu wsparcia.
  Przy przewadze wroga okręt trzyma się na `zasięg dział + podwójny pas` zamiast wchodzić w środek.
  Zapas zależy od charakteru: brawurowy rusza mimo przewagi trzech, ostrożny czeka już przy jednym.
  Myśliwców, okrętów bez floty i uciekających to nie dotyczy.

## Przełączniki

- Debug > **Toggle AI sensor suites** (`GLOB.ai_sensor_suites_enabled`) — same sensory.
- Debug > **Toggle AI sensor tactics** (`GLOB.ai_sensor_tactics_enabled`) — korzystanie z nich.
- `GLOB.ai_fleet_picture_enabled`, `ai_picket_enabled`, `ai_triangulation_enabled`,
  `ai_ambush_enabled` — cztery zachowania floty osobno.
- Debug > **Toggle AI formation** (`GLOB.ai_formation_enabled`) — krążenie na dystansie
  i czekanie na resztę floty.
- Piaskownica: `ai_sandbox_no_suites=1`, `ai_sandbox_no_sensor_tactics=1`,
  `ai_sandbox_no_picture/_no_picket/_no_triangulation/_no_ambush=1`,
  `ai_sandbox_only=picture|picket|triangulation|ambush|formation` zostawia włączone jedno z nich,
  `ai_sandbox_step=<decysekundy>` zmienia gęstość zapisu (domyślnie 5, czyli co pół sekundy),
  a `ai_sandbox_legacy=1` wyłącza wszystko razem z sygnaturami i morale.

## Stożki sensorów (jak na prawdziwym okręcie)

`aquila/code/modules/overmap/ai_sensor_suites.dm`, przełącznik Debug > **Toggle AI sensor cones**
(`GLOB.ai_sensor_cones_enabled`), w piaskownicy `ai_sandbox_no_cones=1`.

| sensor | pierwowzór | w grze |
|---|---|---|
| optyczny | panoramiczne kamery szerokokątne | dookoła, połowa dawnego zasięgu optycznego (najmniej 10 pól) |
| teleskop | wąski obiektyw na przegubie, trzeba go wycelować | stożek 2×10°, dawny zasięg optyczny (30 × rozmiar celu); celuje w trzymany cel, potem w miejsce, gdzie cel powinien być, a bez celu wzdłuż kursu. Tylko okręty większe od myśliwca |
| termiczny | panoramiczny IRST | dookoła poza klinem 2×30° za rufą, gdy własny napęd pracuje (`thrust_heat` ≥ 0,2); ciepło napędu celu zależy od kąta: od dysz ×2,25, z boku ×1,37, od dzioba ×0,49 (pożar, uszkodzenia i gorące działa świecą dookoła); zasięg rośnie z pierwiastkiem ciepła: 35 × √ciepło (pełny ciąg z boku ok. 43 pola, od dysz 54, od dzioba 28) |
| lidar (impuls) | obrotowy radar, emisja zdradza nadawcę | bez zmian |
| nasłuch | pasywny, sam namiar | bez zmian |

Dla okrętu, który ciągnie tylko na napędzie, daje to zasięg termiki 1,5× od strony dysz i 0,7× od dzioba.
Skutki, których się spodziewamy: uciekający okręt traci termikę na pościg za rufą, a podejście od strony
dysz wroga jest trudniejsze do wykrycia termiką. Liczby są startowe i czekają na serię bitew porównawczych.

Odtwarzacz ma warstwę „Stożki sensorów": turkusowy stożek teleskopu (obrót doliczany między pełnymi
klatkami) i pomarańczowy klin martwego pola termiki. Koło termiki zaznaczonego okrętu ma ten klin wycięty.

## Czego tu nie ma

- Gracz nie dostaje zestawów sensorów. Jego DRADIS działa jak dotąd, więc AI i gracz
  grają na razie według innych reguł. To świadoma decyzja, nie przeoczenie.
- Nie ma unikania torped: wypadło z #569, bo w piaskownicy nie zmieniało odsetka trafień
  (torpeda skręca szybciej, niż okręt zdąży uciec).
