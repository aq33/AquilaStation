# Dlaczego okręty AI stoją

Analiza na istniejących nagraniach piaskownicy (seria `B_zwykla`, 6 bitew, kod z eskortą krążącą wokół
lotniskowca, przed stożkami sensorów). Bez nowych bitew. „Stoi” = poniżej 0,3 pola/s, mierzone co 0,5 s.

## Co odpada

- **Obracanie się w miejscu.** Stojące okręty obracają się rzadziej niż jadące (39% wobec 47% klatek)
  i mają dziób bliżej celu (mediana 30° wobec 42°). To nie obrót je zatrzymuje.
- **Trzymanie miejsca na skrzydle** (`ai_flanking.dm`: po dolocie `brakes = TRUE`). Kod hamuje, ale w pasie
  14–22 pól od celu, gdzie leży miejsce na skrzydle, okręty stoją 21%, tyle samo co w innych pasach.
- **Część pomiaru to stacja.** „Stocznie CzanekCorp” stoi 99,8% czasu i była liczona jak okręt.
  Bez obiektów, które nigdy się nie ruszają, stanie spada z 28,0% do 25,0%.

## Przyczyna 1: AI ciągnie silnikiem tylko w co piątym tiku fizyki

`process()` (nsv13/code/modules/overmap/physics.dm) chodzi co 0,15 s (`SSphysics_processing`, `wait = 1.5`)
i na końcu zeruje `user_thrust_dir` (linia 430). AI ustawia go z `move_mode` tylko w `ai_process()`,
które idzie z `slowprocess()` co 0,7 s (ai-skynet.dm:1521). Gracz ustawia ciąg przez `relaymove()`
przy każdym ruchu klawiszem, więc go to nie dotyczy.

Przyspieszenie przy rozpędzaniu wzdłuż dziobu (okna 2 s, obrót < 15°), pola/s²:

| | ciąg ciągły (z parametrów) | ciąg co 5. tik | zmierzone |
|---|---|---|---|
| lotniskowiec Enterprise (`MASS_LARGE`), mediana | 0,25 | 0,05 | 0,057 |
| ten sam z boostem, p95 | 1,25 | 0,25 | 0,270 |

Fregaty pasują tak samo. Okręty AI rozpędzają się pięć razy wolniej, niż przewidują ich parametry.
Prędkość maksymalna jest ta sama, ale ciężki okręt potrzebuje ok. 35 s zamiast 7 s, żeby ją osiągnąć,
a każdy zakręt (tłumiki kasują prędkość boczną) zaczyna rozpędzanie od nowa. Zgadza się to ze wzorcem klas:
fregaty Caracal i Raptor stoją 6–8% czasu, lotniskowce 45–56%, krążowniki Corvid i Inquisitor 34–37%.

## Przyczyna 2: omijanie przeszkód hamuje okręty w tłoku

Bazowe `move_toward()` (ai-skynet.dm:1655) przegląda `getline(src, cel)` do 8 pól i uznaje za przeszkodę
każdy duży okręt w promieniu 5 pól od kafelka na linii. `getline()` zaczyna od kafelka samego okrętu,
więc przeszkodą jest każdy duży okręt w promieniu 5 pól **w dowolnym kierunku**, także za rufą i także swój.
Wtedy okręt dostaje tylko ciąg boczny i wyłączone tłumiki.

Ślad tej gałęzi w nagraniach (ruch względem dziobu, okręty, które się ruszają):

| najbliższy duży okręt | wzdłuż dziobu (<30°) | bokiem (60–120°) | mediana |
|---|---|---|---|
| 8 pól i dalej | 78,3% | 7,6% | 5° |
| 5–8 pól | 56,1% | 19,1% | 21° |
| poniżej 5 pól | 41,9% | 26,0% | 42° |

Eskorta zbierająca się przy stojącym okręcie nie dałaby ruchu bokiem względem jego własnego dziobu,
więc to nie jest odwrotna zależność. Lotniskowiec z innym dużym okrętem w promieniu 6 pól stoi 62% czasu,
w 13–20 polach 28%.

## Rozkład stania (bez stacji, 25,0%)

| sytuacja | stoi w swoich klatkach | udział w całym staniu |
|---|---|---|
| inny duży okręt w promieniu 8 pól | 37,3% | 43% |
| z celem, wolna droga | 20,0% | 34% |
| bez celu, wolna droga | 20,3% | 20% |
| dokowanie do uzbrojenia | 18,4% | 3% |

Tło ok. 20% przy wolnej drodze pasuje do przyczyny 1. Nadwyżka w tłoku to przyczyna 2.

## Propozycje

1. **Ciąg AI w każdym tiku** — nadpisanie `/obj/structure/overmap/process()` w `aquila/` z `..()`:
   przed tikiem `user_thrust_dir = move_mode` dla okrętów AI. Bez zmian w core, z przełącznikiem.
   To zmiana balansu także w walce z graczem: AI rozpędza się 5× szybciej (prędkość maksymalna bez zmian).
2. **Omijanie tylko tego, co przed dziobem** — jedna linia `// AQ EDIT` w pętli bazowego `move_toward()`:
   pomijać okręty za okrętem (poza połową przednią względem kierunku lotu). Wpis w tabeli hooków.
3. **Pomiar bez stacji** — `tools/ai_sandbox/compare_battles.py` pomija obiekty, które się nie ruszają.

Bez propozycji: trzymanie miejsca na skrzydle (dane nie pokazują efektu), dokowanie (mały udział, sensowne).
