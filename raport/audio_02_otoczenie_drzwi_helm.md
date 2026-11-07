# Dźwięk, część 2: szum maszyn, droga przez drzwi, hełm, odległość, mamrotanie

Ciąg dalszy `audio_01_dzwiek_przestrzenny.md`, ten sam PR aq33/AquilaStation#577. **W grze niesprawdzone.**

## Co doszło

| Element | Jak działa | Pliki |
|---|---|---|
| Szum maszyn (jak AmbientSound w SS14) | Wentylacje, odciągi, szafki APC i automaty szumią. Co sekundę każdy gracz dostaje najwyżej 3 najgłośniejsze pobliskie źródła, po jednym na rodzaj szumu. Każde gra w pętli na własnym, raz zarezerwowanym kanale. Zmiana odległości i ściany po drodze zmienia tylko głośność (`SOUND_UPDATE`), plik nie leci od nowa. Źródła trzyma siatka 8×8 kafelków. Włącznik: preferencja dźwięków statku. | `aquila/code/controllers/subsystem/ambient_emitters.dm`, pętle `aquila/sound/ambience/emitters/` z `aquila/tools/make_ambient_loops.py` |
| Droga przez otwarte drzwi | Głośny dźwięk (≥40) za ścianą: raz na dźwięk BFS od źródła przez kafelki bez ścian, zamkniętych drzwi i szyb (najwyżej 400 kafelków, wynik trzymany 0,5 s dla serii z broni). Gdy droga istnieje, wygłuszenie spada do 0,1 + 0,04 × nadłożone kroki (poniżej progu podmiany pliku), a dźwięk dochodzi z najdalszego kafelka drogi, który słuchacz ma na prostej (zwykle drzwi). | `sound_heard_through()` w `sound_occlusion.dm` |
| Z daleka | Od 11 kratek stłumiona kopia, także bez ściany: powietrze zjada wysokie tony. | `apply_sound_occlusion()` |
| Szczelny hełm | Hełm z `STOPSPRESSUREDAMAGE` (skafander, MOD): wszystko ze stłumionej kopii, ×0,85 głośności, −400 mB ścieżki suchej. Oddech w masce już był (pętla `gasmask` z NSV13). | `has_sealed_helmet()` |
| Pogłos źródła | Za ścianą dźwięk z hali dostaje +800 mB pogłosu (`echo[3]` Room), z korytarza lub ogólnej stacji +400, z małego pokoju nic, razy wygłuszenie. | `apply_source_reverb()` |
| Więcej kopii | Próg w generatorze 5 → 2 użycia w kodzie: 612 kopii, 4,0 MB (było 389, 2,5 MB). Dwie pary nazw różnią się tylko wielkością liter (`Fireball`/`fireball`, `genhit`), druga z pary zostaje bez kopii. | `muffle_sounds.py` |
| Mamrotanie | Frazy mowy idą przez ściany (bez `hearers()`), więc za ścianą słychać stłumione mamrotanie (kopie z `voice_muffled_sounds.dm`). Tekst dalej dochodzi tylko jak dotąd. | `aquila/code/modules/mob/voice.dm` |

## Koszt (sonda na mapie Aquili)

Mierzone `rustg_time_microseconds` po pełnej inicjalizacji mapy (dwa przebiegi, mapa stacji losowana: 437 i 513 źródeł szumu, z czego ok. 35% wentylacje, 28% odciągi, 20% automaty, 18% szafki APC).

| Co | Koszt |
|---|---|
| Wybór szumu dla jednego gracza (raz na sekundę) | 69–76 µs. W 80% miejsc gracz słyszy coś, średnio 2,3 źródła. |
| Droga przez drzwi: nowa mapa BFS | ok. 390 µs na głośny dźwięk z wygłuszonym słuchaczem (pomiar 524 µs minus 133 µs samego `forceMove` sondy). Obejście znalezione w 7–10% losowych par za ścianą. |
| Droga przez drzwi: kolejny słuchacz tego samego dźwięku | ok. 15 µs (gotowa mapa) |
| `apply_sound_occlusion` z hełmem i odległością | 2,2–3,1 µs |

Szacunek przy pełnym serwerze:
- szum maszyn dla 40 graczy to ok. 3 ms/s, czyli ~0,3% `world.cpu`,
- strzelanina z 10 strzałami/s za ścianami to najwyżej 10 map BFS/s, ok. 4 ms/s, czyli ~0,4% (strzelec, który stoi, liczy jedną mapę na 0,5 s).

Razem z częścią 1 (~2%) daje to ~2,5–3% `world.cpu` w ciężkiej rundzie. Liczby dźwięków na sekundę są założeniem, nie pomiarem z rundy.

Klient: szum to najwyżej 3 dodatkowe pętle na kanałach z repeat i jeden `SOUND_UPDATE` na sekundę na kanał. CPU klienta nie mierzyłem osobno, przy 20 dźwiękach/s całość mieściła się w rozrzucie (część 1).

## Testy

- `aquila_sound_occlusion` rozszerzony: stłumienie z odległości, hełm, obejście przez otwarte drzwi (i więcej wygłuszenia przy zamkniętych), cichy dźwięk nie szuka obejścia, wybór szumu (najbliższy, jeden na rodzaj, za ścianą ciszej, usunięta maszyna milknie).
- PASS: `aquila_sound_occlusion`, `jukebox_pa_system`, `aquila_logi_rund_6552`, `test_chamber`. `create_and_destroy` jest w naszym kodzie wyłączony (tylko z `REFERENCE_TRACKING_FAST`), więc usuwanie maszyn z listy źródeł sprawdza tylko własny test.

## Ograniczenia

- Szum zmienia głośność skokami co sekundę (bez płynnego przejścia).
- Droga przez drzwi liczy tylko 4 kierunki i najwyżej 400 kafelków. Na dużych otwartych przestrzeniach obejścia dalej niż ok. 10 kroków mogą nie zostać znalezione i zostaje zwykłe wygłuszenie.
- Głośność z drogi okrężnej liczy się z prostej odległości, nie z długości drogi.
- Rodzaje szumu to 4 pętle z istniejących dźwięków maszyn. Więcej źródeł (rury, silniki, telekomunikacja) to dopisanie `ambient_hum` do typu i pętli do generatora.
- Web Audio (prawdziwy filtr, HRTF) nadal odłożone.
