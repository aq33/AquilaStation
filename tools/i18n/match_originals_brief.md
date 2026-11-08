# Ocena angielskich odpowiedników tekstów gry (SS13, serwer Aquila)

Gra ma polskie teksty w kodzie i angielską wersję językową. Dla każdego polskiego tekstu chcemy
angielski tekst **jak najwierniejszy oryginałowi** z serwera, z którego kod pochodzi (tgstation,
BeeStation, Monkestation itd.). Część obecnych angielskich tekstów to tłumaczenie zwrotne
(ktoś przełożył polski z powrotem na angielski), a skrypt znalazł w kodzie źródłowym kandydata
na oryginał. Skrypt bywa omylny: kandydat może być innym tekstem z tej samej procedury,
a Aquila część tekstów celowo zmieniła.

## Wejście
Plik `paczka_NN.jsonl`, jedna pozycja na linię:
`{"id": "...", "pl": polski tekst w grze, "current": obecny angielski, "original": kandydat na oryginał albo null}`

Teksty są zapisem literałów z kodu: `[wyrażenie]` to wstawki, `\n`, `\the`, `\The`, `\improper`
to makra, `<span class='...'>` to HTML. To normalne.

## Decyzja dla każdej pozycji

Gdy `original` nie jest null:
- `"original"`: polski tekst jest tłumaczeniem kandydata. Ta sama treść i te same informacje,
  swobodne tłumaczenie jest w porządku (inny szyk, synonimy, wielkie litery, drobne słowa).
- `"current"`: kandydat to inny tekst albo polski mówi coś innego. Przykłady:
  - polski dodaje lub pomija istotną informację: kandydat `pack of plump-helmet mycelium`,
    polski „zarodniki: pulchny hełm (dowolne podłoże)”, czyli dodatkowa informacja o podłożu → current;
  - Aquila zmieniła nazwę lub mechanikę: u nas nie ma MODsuitów, są hardsuity. Polski
    „moduł hardsuitu”, a kandydat „MODsuit module” → current. Podobnie, gdy polski używa innej
    nazwy własnej niż kandydat;
  - kandydat to sąsiedni komunikat (inna sytuacja, inny adresat: „You hear…” zamiast „You don't need…”)
    → current;
  - kandydat jest wyraźnie nie na temat → current.
  W razie wątpliwości wybierz `"current"`. Zła podmiana szkodzi bardziej niż tłumaczenie zwrotne.

Kandydat bywa znaleziony po treści w całej historii innego serwera, a nie w tym samym miejscu kodu.
Wtedy jest tylko podobnym zdaniem i może opisywać coś innego, np. inny przedmiot o podobnym opisie.
„original” wybierz tylko wtedy, gdy polski tekst jest jego tłumaczeniem w całości.

Nie odrzucaj kandydata za drobiazgi, które skrypt poprawia sam: linki `href='?src=...'` bez `byond://`
dostają `byond://`, a brakujący albo inny zewnętrzny `<span class='...'>` przejmuje z polskiego tekstu.
Literówki i dziwne wielkie litery z oryginału zostają, bo tekst ma być wierny.

Gdy ani obecny angielski, ani kandydat nie pasują do polskiego tekstu, wybierz `"fix"` (opis niżej).

Gdy `original` jest null (para z historii wygląda podejrzanie):
- `"current"`: obecny angielski to poprawny odpowiednik polskiego. Może się różnić
  wstawkami, np. polski ma `[on ? "włączony" : "wyłączony"]`, a angielski `[on ? "on" : "off"]`;
  angielski może mieć zaimki `[p_they()]`, których polski nie ma; może być nieco krótszy lub dłuższy.
- `"fix"`: angielski jest zły. Obcięty fragment, inne zdanie, inna treść albo nadal po polsku.
  Wtedy podaj w `en` własne tłumaczenie polskiego tekstu w stylu angielskiego SS13
  (krótko, druga osoba „You…”, nazwy przedmiotów małą literą jak w tg). Zachowaj **dokładnie**
  wszystkie wstawki `[...]` i `${...}` z polskiego tekstu (bez zmian w środku, także polskich
  napisów w `[x ? "a" : "b"]`), tagi HTML, `\n`, cudzysłowy i makra.

## Wyjście
Zapisz plik `paczka_NN.out.json` (ten sam numer) w tym samym katalogu. Obiekt JSON:
`{"<id>": "original"}`, `{"<id>": "current"}` albo `{"<id>": {"fix": "<angielski>"}}`.
Wypisz wszystkie pozycje z paczki. Plik zapisz narzędziem Write (nie heredoc w Bash: psuje backslashe).
Na koniec odpowiedz jednym zdaniem: ile było original, current i fix.
