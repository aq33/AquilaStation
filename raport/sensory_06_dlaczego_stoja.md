# Dlaczego okręty AI stoją

Analiza na istniejących nagraniach piaskownicy (seria `B_zwykla`, 6 bitew, kod z eskortą krążącą wokół
lotniskowca, przed stożkami sensorów). Bez nowych bitew. „Stoi” = poniżej 0,3 pola/s, mierzone co 0,5 s.

## Co odpada

- **Obracanie się w miejscu.** Stojące okręty obracają się rzadziej niż jadące (39% wobec 47% klatek)
  i mają dziób bliżej celu (mediana 30° wobec 42°). To nie obrót je zatrzymuje.
- **Trzymanie miejsca na skrzydle** (`ai_flanking.dm`: po dolocie `brakes = TRUE`). Kod hamuje, ale w pasie
  14–22 pól od celu, gdzie leży miejsce na skrzydle, okręty stoją 21%, tyle samo co w innych pasach.
- **Część pomiaru to stacja.** „Stocznie CzanekCorp” stoi 99,8% czasu i była liczona jak okręt.
  Bez niej stanie spada z 28,0% do 26,9%. Filtr pomija tylko obiekty bez floty i bez celu AI: pierwsza wersja
  (wszystko, co się nie rusza) wycinała też prawdziwe okręty AI, patrz niżej.

## Okręty AI zamarznięte na całą bitwę

Jakiś okręt AI ani razu się nie ruszył (p95 prędkości < 0,05 pola/s) w 4 z 6 bitew odniesienia, w 2 z 6 bitew
pełnego AI i w 2 z 6 serii B. Ich ostatni cel: „Break off and escape by FTL” (4 okręty, m.in. lotniskowce Syndykatu),
„Maintain safe distance from enemies” (2, lotniskowiec Enterprise), „Join a lance…” (2), „Patrol system” (2),
„Search and destroy” (1). To skrajny przypadek tego samego problemu; ucieczka przez FTL może tu mieć własną przyczynę
(czekanie na rozruch napędu), do sprawdzenia po poprawkach.

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

## Rozkład stania (bez stacji, 26,9%)

| sytuacja | stoi w swoich klatkach | udział w całym staniu |
|---|---|---|
| inny duży okręt w promieniu 8 pól | 38,6% | 41% |
| z celem, wolna droga | 21,7% | 34% |
| bez celu, wolna droga | 23,5% | 22% |
| dokowanie do uzbrojenia | 18,4% | 2% |

Tło ok. 22% przy wolnej drodze pasuje do przyczyny 1. Nadwyżka w tłoku to przyczyna 2.

## Propozycje

1. **Ciąg AI w każdym tiku** — nadpisanie `/obj/structure/overmap/process()` w `aquila/` z `..()`:
   przed tikiem `user_thrust_dir = move_mode` dla okrętów AI. Bez zmian w core, z przełącznikiem.
   To zmiana balansu także w walce z graczem: AI rozpędza się 5× szybciej (prędkość maksymalna bez zmian).
2. **Omijanie tylko tego, co przed dziobem** — jedna linia `// AQ EDIT` w pętli bazowego `move_toward()`:
   pomijać okręty za okrętem (poza połową przednią względem kierunku lotu). Wpis w tabeli hooków.
3. **Pomiar bez stacji** — `tools/ai_sandbox/compare_battles.py` pomija obiekty, które się nie ruszają
   i przez całe nagranie nie mają floty ani celu AI.

Wszystkie trzy są zrobione: `aquila/code/modules/overmap/ai_steering.dm` (przełączniki Debug > Toggle AI continuous
thrust i Toggle AI forward avoidance, w piaskownicy `ai_sandbox_no_continuous_thrust=1`
i `ai_sandbox_no_forward_avoidance=1`). Cichy bieg i zasadzka zerują teraz `move_mode`, bo przy ciągłym ciągu
zostawiony `move_mode` grzałby silnik. Bitew porównawczych jeszcze nie było.

Bez propozycji: trzymanie miejsca na skrzydle (dane nie pokazują efektu), dokowanie (mały udział, sensowne).

## Wyniki (6 bitew z poprawkami, 6 bez; stożki sensorów w obu włączone)

| | bez poprawek ruchu | z poprawkami |
|---|---|---|
| stoi% | 29,4 (23–38) | **14,3 (9–21)** |
| lotniskowce stoją% | 44,4 (35–57) | 30,4 (16–45) |
| mediana prędkości okrętów AI | 0,85 pola/s | 1,82 pola/s |
| pierwsze trafienie (mediana) | 22 s | 12 s |
| zniszczone okręty | 18,5 (14–22) | 15,7 (10–21) |
| samotne szarże% | 1,3 | 1,7 |
| termika oślepiona za rufą | 3,7% klatek | 94,4% klatek |
| kontakty trzymane termiką | 85,4% | 93,7% |
| bitwy z okrętem AI zamarzniętym na całą bitwę | 3 z 6 | 4 z 6 |

Stanie spadło o połowę, zakresy się nie nakładają. Pozostałe skutki:

- **Tempo wzrosło bardziej, niż szacowałem** (~20%): mediana prędkości ×2,1, pierwsze trafienie 22 s → 12 s.
  Pominąłem boost: `move_toward()` odpala go co 15 s (limit prędkości +5 na 6 s), a wcześniej AI nie miało
  czym się w tym oknie rozpędzić. Teraz leci z limitem boostu (po skosie do ~6 pól/s, bo limit jest na każdą oś
  osobno). Przeskoki przez krawędź mapy: 177 klatek na 6 bitew.
- **AI ciągnie bez przerwy.** Nie ma przepustnicy: `move_mode = NORTH` to pełny ciąg także przy prędkości maksymalnej,
  gdzie ciąg już nic nie daje. Silnik jest więc gorący prawie zawsze, ślepy klin za rufą działa w 94% klatek,
  a termika trzyma 94% kontaktów. Optyka i teleskop prawie przestają mieć znaczenie.
- **Lotniskowce zamarznięte na całą bitwę zostały** (wszystkie z celem „Maintain safe distance”, oba typy
  przechodzą przez `is_ai_carrier()`). To osobna przyczyna; nagrania nie zapisują hamulców, `move_mode`
  ani przyłożonego ciągu, więc nie da się jej z nich wyczytać.

