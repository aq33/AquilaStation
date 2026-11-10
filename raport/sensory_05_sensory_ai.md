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

## Przełączniki

- Debug > **Toggle AI sensor suites** (`GLOB.ai_sensor_suites_enabled`) — same sensory.
- Debug > **Toggle AI sensor tactics** (`GLOB.ai_sensor_tactics_enabled`) — korzystanie z nich.
- Piaskownica: `ai_sandbox_no_suites=1`, `ai_sandbox_no_sensor_tactics=1`,
  a `ai_sandbox_legacy=1` wyłącza wszystko razem z sygnaturami i morale.

## Czego tu nie ma

- Gracz nie dostaje zestawów sensorów. Jego DRADIS działa jak dotąd, więc AI i gracz
  grają na razie według innych reguł. To świadoma decyzja, nie przeoczenie.
- Nie ma unikania torped: wypadło z #569, bo w piaskownicy nie zmieniało odsetka trafień
  (torpeda skręca szybciej, niż okręt zdąży uciec).
