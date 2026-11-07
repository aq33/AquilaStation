# Dźwięk, część 3: eksperyment z Web Audio w WebView2 (BYOND 516)

Pytanie: czy klient BYOND 516 może grać dźwięki gry przez Web Audio w ukrytym oknie przeglądarki, żeby mieć prawdziwy filtr dolnoprzepustowy, pogłos splotowy i panoramę HRTF (czego FMOD Ex w BYOND nie daje, część 1). Mini-projekt: `raport/audio_03_web_audio/` (`wa.dm`, `wa.html`, `wa2.dm`). Pomiar jak w części 1: nagranie wyjścia audio (WASAPI loopback), kopia klienta pod inną nazwą, osobny folder danych WebView2.

To jest eksperyment, nic z tego nie jest w kodzie gry.

## Jak to działało w teście

- Serwer: `browse_rsc()` plików dźwięku, `browse(wa.html, "window=wa")`, potem `winset(..., "is-visible=false")`.
- Odtwarzanie: `src << output(list2params(list(json)), "wa.browser:play")`, a JSON zawiera plik, głośność, filtr, pozycję i pogłos.
- Strona: `AudioContext`, bufory z `fetch()` + `decodeAudioData`. Tor na dźwięk: `BufferSource → Biquad (lowpass) → Gain → Panner (HRTF albo equalpower) → wyjście`, plus wysyłka do wspólnego `ConvolverNode` (pogłos z wygenerowaną odpowiedzią impulsową 1,6 s).
- Strona odsyła wyniki przez `byond://?src=...;walog=...` (zbiera komunikaty co 150 ms).

## Wyniki

| Co | Wynik |
|---|---|
| Autoodtwarzanie | `AudioContext` ma stan `running` od razu, **bez kliknięcia gracza**. WebView2 w BYOND nie blokuje dźwięku (w przeciwieństwie do mikrofonu). |
| Pliki | Okno to `http://127.0.0.1:<port>/...`, a `fetch("noise.ogg")` po `browse_rsc()` działa. Dekodowanie 1 s OGG trwa ok. 20 ms. |
| Ukryte okno | gra normalnie (`is-visible=false`) |
| Opóźnienie | W tym samym ticku serwera Web Audio gra **ok. 80 ms wcześniej** niż natywny `sound` (4 z 5 prób −75 do −80 ms, jedna +27 ms). Natywny FMOD ma większy bufor. |
| Filtr dolnoprzepustowy 800 Hz | 0,5–2 kHz −2,8 dB, 2–6 kHz −23 dB, >6 kHz −44 dB |
| Filtr 300 Hz | 0,5–2 kHz −18 dB, 2–6 kHz −41 dB, >6 kHz −61 dB |
| Panorama `equalpower`, x = 3 | drugie ucho −65 dB, czyli jedno ucho |
| Panorama HRTF, x = 3 | drugie ucho −6,7 dB, cień głowy obcina wysokie tony (−4 do −5 dB powyżej 500 Hz) |
| HRTF przód/tył | tył wobec przodu: −3 do −6 dB w 2–6 kHz i −13 dB w 12–16 kHz. Słuchawki rozróżnią przód od tyłu, czego stereo FMOD nie potrafi. |
| Pogłos splotowy | ogon po końcu dźwięku −25 dB (bez pogłosu −68 dB) |

## Koszt CPU klienta (klient + procesy WebView2, 20 dźwięków/s przez 20 s)

| Faza | Przebieg 1 | Przebieg 2 |
|---|---|---|
| bez dźwięków | 1,8% | 2,0% |
| natywny `sound` | 0,8% | – |
| Web Audio: filtr + HRTF | 6,9% | 5,1% |
| Web Audio: filtr + HRTF + **wspólny** pogłos | – | 9,2% |
| Web Audio: filtr + HRTF + **osobny** pogłos na każdy dźwięk | 118% | – |

Wnioski:
- Pełny tor kosztuje ok. **+7 punktów procentowych jednego rdzenia** przy 20 dźwiękach/s, z czego ok. 4 to pogłos.
- Pogłos musi być jeden na klienta (wspólna szyna), osobny na każdy dźwięk zjada ponad rdzeń.
- WebView2 dokłada 8 procesów (już są, bo panel czatu i TGUI też są oknami WebView2) i ~1,4% w spoczynku.
- Czasu klatek nie mierzyłem: dźwięk Web Audio idzie poza wątkiem rysowania mapy.

## Co by trzeba zrobić, żeby to weszło do gry

Wszystko poniżej to szacunki, niezmierzone:
1. **Tor dźwięku:** w `playsound_local()` dla klienta z włączoną opcją wysyłać `output()` zamiast `sound`. Wygłuszenie z części 1 i 2 zamienia się wtedy na płynną częstotliwość filtra zamiast gotowych kopii (4 MB kopii przestaje być potrzebne tym graczom). Serwer: jedno `json_encode` + `output` na słuchacza, rząd wielkości jak dzisiejsze `SEND_SOUND`.
2. **Pliki:** `browse_rsc()` przy pierwszym użyciu danego pliku przez klienta, z listą wysłanych na kliencie. Nie sprawdziłem, czy `browse_rsc()` pliku, który klient ma już w `.rsc`, przesyła go jeszcze raz przez sieć. To trzeba zmierzyć na prawdziwym serwerze, przy 3670 plikach (~220 MB) to kluczowe. Pierwsze odtworzenie pliku spóźni się o czas ładowania (ok. 20 ms lokalnie).
3. **Pozycja w ruchu:** Web Audio nie wie, gdzie jest gracz. Serwer musiałby wysyłać pozycję słuchacza przy każdym kroku (jedno `output` na krok) i pozycje ruchomych źródeł. To zastępuje `sound.atom`.
4. **Reszta toru dźwięku:**
   - zatrzymywanie kanałów (`stop_sound_channel`), pętle i `SOUND_UPDATE` (szum maszyn, pętle maszyn) przepisane na JS,
   - preferencje głośności,
   - zachowanie przy głuchocie i próżni (to akurat liczy serwer, więc zostaje).
5. **Zapas:** gdy okno nie wstanie (stary klient, błąd WebView2), gra po staremu natywnie. Muzyka, lobby, admin i ogłoszenia mogą zostać natywne.
6. **HRTF na głośnikach** brzmi dziwnie, więc preferencja: „słuchawki (HRTF)” albo „głośniki (łagodna panorama)”.

Ryzyko:
- **średnie:** punkt 2 (sieć przy plikach) i punkt 3 (dodatkowe `output` przy ruchu),
- **niskie:** autoodtwarzanie i filtr (sprawdzone).

## Rekomendacja

Technicznie działa lepiej, niż zakładałem w planie: bez blokady autoodtwarzania, z mniejszym opóźnieniem niż natywny dźwięk i z prawdziwym filtrem, HRTF i pogłosem przy koszcie ok. 7% rdzenia klienta. Następny krok, jeśli warto: **opcjonalny prototyp w grze** dla 3D dźwięków `playsound()`. Za preferencją, z natywnym zapasem, najpierw z pomiarem `browse_rsc()` na prawdziwym serwerze. Szacuję to jako średnio duże zadanie (osobna gałąź), większe niż części 1–2 razem.
