# Projekt: Aquila NSV13 (fork BeeStation/NSV13)
Repozytorium: `aq33/AquilaStation` (stare `aq33/NSV13` przekierowuje). Język: DM (BYOND). Kod ma polskie elementy, które są ważne.
## Środowisko
- BYOND 516.1688 (źródło prawdy: `dependencies.sh`). Kompilator 515 nie zbuduje mastera, a `.dmb` z 515 wywala się pod Dream Daemonem 516.
- Plik projektu: `nsv13.dme`.
- Pełny build na Windows: `BUILD.bat` (woła `tools/build`). Sama kompilacja DM: `dm.exe -DCBT nsv13.dme` (bez `-DCBT` dm.exe odmawia: „Building with Dream Maker is no longer supported”).
- TGUI: `tools\build\build.bat tgui` (sam ściąga Node). Bundle w `tgui/public/` są w `.gitignore`, więc w świeżym worktree bez tego kroku w grze nie ma czatu ani paneli.
- Okna TGUI na żywo: `bin\tgui-dev.cmd` przy połączonym Dream Seekerze buduje bundle w trybie dev i wstrzykuje je do cache BYOND, więc zmiana `.tsx` odświeża okna bez przebudowy (`--reload` robi to raz). Edytor: rozszerzenie VS Code `platymuus.dm-langclient` (SpacemanDMM: przejście do definicji, użycia, błędy dreamcheckera w edytorze) potrzebuje w ustawieniach `dreammaker.byondPath` z folderem BYOND 516.
- `tgui/public/tgui.html` jest wkompilowany w `.rsc`: jego zmiana wymaga przebudowy DM, nie tylko restartu serwera.
- Przed oddaniem zmian zawsze kompiluj. Nowe ostrzeżenia i błędy dreamcheckera napraw.
- Działający Dream Daemon blokuje `nsv13.rsc`, a dm.exe zgłasza wtedy mylący błąd „'<ikona>.dmi': cannot find file”. Nie zabijaj serwera: sprawdź kod kompilacją kopii `.dme` pod inną nazwą (potem usuń jej `.dme/.dmb/.rsc`) i poproś o zatrzymanie serwera.
- `.dmb` zbudowany z `-DUNIT_TESTS` po starcie puszcza testy i restartuje świat („runda kończy się od razu”). Po testach zawsze przebuduj zwykłym `dm.exe -DCBT nsv13.dme`.
- Debugger: auxtools 3 (https://github.com/auxtools/auxtools, rozszerzenie VS Code `sohpea.auxtools`, konfiguracje „auxtools” w `.vscode/launch.json`, bez zmian w kodzie gry). CLI nie jest w PATH: leży w rozszerzeniu (`%USERPROFILE%\.vscode\extensions\sohpea.auxtools-<wersja>\bin\win32\auxtools.exe`) albo w wydaniu na GitHubie. Z terminala: `auxtools launch nsv13.dmb --detach --json --server dd --port <wolny> -D CBT`, potem `--pid <pid>` z `status`, `eval`, `trace`, `pause`/`stack`/`vars`/`continue`, `reboot`, `stop --kill`. Flagi `-D` muszą być te same co przy kompilacji `.dmb` (np. dopisz `-D UNIT_TESTS`), bo hot-reload kompiluje z nimi źródła. Build sam bierze BYOND z `dependencies.sh`, ale debugger uruchamia zainstalowany: przy kilku wersjach podaj `--byond <folder BYOND 516>` (w VS Code ustawienie `auxtools.byondPath`). W Git Bash ścieżki procek (`/datum/...`) wymagają `MSYS_NO_PATHCONV=1`. Hot-reload jest domyślnie włączony: po przeładowaniu stare obiekty zostają, więc przed wnioskiem o błędzie zrób czysty restart. Przed debugowaniem przebuduj `.dmb`, bo przy nieaktualnym breakpointy trafiają w inne linie; `--no-hot-reload` tylko blokuje przeładowanie i tej rozbieżności nie usuwa. Pod debuggerem nie mierz wydajności.
## Język i teksty
- Nazwy typów, procedur i zmiennych zostają po angielsku.
- Wszystko, co widzi gracz, jest po polsku: nazwy i opisy przedmiotów, komunikaty w czacie, okna TGUI, podpowiedzi, ogłoszenia, nazwy reagentów i receptur, wpisy w `strings/`. Dotyczy to także kodu portowanego z innych serwerów: tłumacz przy porcie, nie zostawiaj angielskiego „na później”.
- Terminy bierz z `aquila/SLOWNIK_TLUMACZEN.md` i dopisuj tam nowe. Nazwy własne spolszczaj brzmieniowo (Bikarydyna, Kosmiczna Cola); Nanotrasen i nazwy frakcji bez zmian.
- Gra ma opcję angielską (`aquila/code/modules/i18n/`, `tools/i18n/`). Angielski odpowiednik nowego tekstu dopisz do `strings/i18n/en_translated.json` (klucz to dokładny polski literał) i uruchom `python tools/i18n/build_chat_dict.py`. Moduł nie zmienia kodu gry: same nadpisania procedur w `aquila/code/modules/i18n/` (blok include na końcu `aquila/aquila.dm`) i loader w `tgui/webpack.config.js`; nie dopisuj wywołań tłumacza w kodzie gry, tylko nadpisanie w module. Natywne `alert()`/`input()` zostają po polsku. CI pokazuje nowe teksty bez angielskiego jako ostrzeżenia. Teksty okien owija przy budowie loader `tgui/i18n-jsx.cjs` (wywołania `t`/`tt`/`ts` z `tgui/i18n.ts`, granice zdań z drzewa składni); zdanie przecięte wstawką JSX (`aby {x} ten`) ma klucz w postaci literału `aby ${x} ten`, a narzędzia biorą teksty okien z tego samego drzewa (`tools/i18n/jsx_ast.py`). Dane z DM w oknach tłumaczy zapasowo `tgui/i18nDom.ts`. Napisy na guzikach HUD-u są w .dmi: po zmianie ikon HUD-u uruchom `python tools/i18n/hud_en_icons.py` (angielskie kopie w `aquila/icons/hud/en/`). Pokrycie okien sprawdza `python tools/i18n/ui_coverage.py` (każdy polski tekst okien przez prawdziwy tłumacz, resztki w `data/i18n_ui_coverage.json`).
- Nie tłumacz tekstów porównywanych w kodzie (klucze list, `name` sprawdzane w `if`, identyfikatory w TSX, ckey nazw reagentów), chyba że zmieniasz też wszystkie porównania.
- Gracze poprawiają polski tekst w Crowdinie (https://crowdin.com/project/aquila, komenda „Popraw tłumaczenie” w OOC). Zatwierdzone poprawki przychodzą jako PR z gałęzi `crowdin-poprawki` (`tools/i18n/crowdin.py`, `.github/workflows/crowdin_*.yml`). Nie edytuj tej gałęzi ręcznie, bo workflow ją nadpisuje. Złą poprawkę odrzuć w Crowdinie.
- Tytuły PR-ów, opisy PR-ów i wpisy changelogu też są po polsku.
- Nie ruszaj istniejących polskich tekstów ani naszych zmian bez pytania.
## Combat mode i intencje (dwa tryby sterowania)
Domyślnie gra używa combat mode z Bee, a gracz może włączyć w preferencjach stare cztery intencje. Każda akcja musi działać w obu trybach (opis: nagłówek `aquila/code/_onclick/legacy_intents.dm`).
- Akcja na prawym przycisku idąca przez `ClickOn` albo przechwycenie kliku (spell, akcja z celowaniem) działa sama: intencja disarm jest tłumaczona na prawy klik.
- Kliknięcie omijające `ClickOn` (przycisk HUD, `COMSIG_CLICK`) sprawdza akcję dodatkową przez `mob.is_secondary_click(modifiers)`, nie przez `RIGHT_CLICK`.
- Tekst instrukcji o prawym przycisku pisz przez `[mob.secondary_click_text()]` („prawym przyciskiem” / „na intencji rozbrajania”).
- Zachowanie zależne od walki sprawdzaj przez `combat_mode`, nie przez `a_intent` (harm = combat mode włączony).
- Każdy żywy mob gracza (także simple animale i antagi-zwierzęta) ma w HUD wskaźnik trybu (`combat_mode_indicator`, domyślnie TRUE) i w starym trybie cztery intencje. FALSE tylko dla mobów, które nie dotykają świata (silikony, revenant itp.).
- Port z serwera, który ma tylko intencje albo tylko combat mode: dopisz brakujący wariant i sprawdź oba tryby w teście w grze.
## Kod Aquili (modularność)
- Nowy kod, ikony i dźwięki idą tylko do `aquila/` (`aquila/code/`, `aquila/icons/`, `aquila/sound/`, `aquila/_maps/`).
- Nowy plik `.dm` dopisz do `aquila/aquila.dm` (ścieżka względna od `aquila/`, backslashe), nie do `nsv13.dme`.
- `aquila/aquila.dm` jest dołączany na końcu `nsv13.dme`. Define potrzebny wcześniej w core musi być w core, z markerem.
- Zmiana zachowania upstreamowego typu: nadpisanie w `aquila/` z wywołaniem `..()`.
- Pełne nadpisanie procki bez `..()` tylko gdy inaczej się nie da, i wtedy obowiązkowo wpis do `aquila/LEGACY_OVERRIDES.md`.
- Edycja pliku core: najmniejszy możliwy hook, oznaczony `// AQ EDIT - powód` (jedna linia) albo `// AQ EDIT START` ... `// AQ EDIT END` (blok). Nowy hook dopisz do tabeli „Core hooks” w `LEGACY_OVERRIDES.md`.
- Same polskie tłumaczenia tekstów w core nie wymagają markera.
- Pełne ścieżki typów i procek (`/obj/item/foo/proc/bar()`). Dreamchecker zabrania definicji względnych (`SpacemanDMM.toml`).
- Zmienne globalne tylko przez `GLOBAL_VAR*` / `GLOBAL_LIST*`.
- Nie każdy plik z `code/` jest w buildzie (np. `code/modules/jobs/job_types/security_officer.dm`, `code/modules/power/multiz.dm`). Zanim coś w nim zmienisz, sprawdź, czy jest w `nsv13.dme`.
## Zasady ogólne
- Zanim napiszesz nową funkcję, makro, typ lub system, przeszukaj kod (grep) i sprawdź, czy coś podobnego już istnieje. Jeśli tak, użyj tego albo rozbuduj, zamiast duplikować.
- Rób najmniejszą zmianę, która załatwia zadanie. Nie dodawaj systemów, abstrakcji ani opcji, o które nie proszono.
- Naśladuj styl i wzorce sąsiedniego kodu (nazewnictwo, rejestracja sygnałów, użycie podsystemów).
- Nie refaktoryzuj ani nie formatuj kodu, którego zadanie nie dotyczy.
- Przed zmianą pliku przeczytaj go oraz miejsca, które z niego korzystają (grep po nazwie).
- Jeśli zadanie jest niejasne albo wymaga dużego systemu, napisz krótki plan i listę plików, po czym poczekaj na zgodę.
## Testy
- Nowa logika (nie same sprite'y) dostaje unit test w `aquila/code/modules/unit_tests/`, dołączony w bloku `#ifdef UNIT_TESTS` na końcu `aquila/aquila.dm`.
- Makra `TEST_ASSERT*` są `#undef` na końcu `code/modules/unit_tests/_unit_tests.dm`, więc test modularny ma własne kopie (wzór: `polish_content.dm`).
- Pojedynczy test lokalnie: `TEST_FOCUS(/datum/unit_test/...)`. Usuń go przed commitem (CI odrzuca go w `check_grep.sh`).
- Poprawka błędu dostaje test regresji, jeśli da się go odtworzyć bez klienta: test ma wywołać zgłoszony przypadek i sprawdzić wynik działania, nie tylko to, że coś istnieje (wzór: `aquila_gun_fire_without_params.dm`).
- Gdy `run_all_tests` padnie, pełne logi serwera i `unit_tests.json` są w artefakcie `run_all_tests-logs` przebiegu (krok dodany w aq33/AquilaStation#543; do jego scalenia logi są tylko w wyjściu joba).
- Odtworzenie błędu w działającym świecie bez klienta: `python tools/scenario/scenario.py <plik>` (wzór: `tools/scenario/examples/smoke.txt`). Plik to ciało procki DM wykonywane w świecie przez auxtools (`eval --spawn`, może używać `sleep`), zwraca `"OK"` albo opis porażki (eval nie obsługuje `new()` ani `locate()` bez jawnego typu); `--runda` startuje rundę, `--zostaw` nie zatrzymuje świata, `-D` podaje flagi, z którymi zbudowano `.dmb`. Na końcu dołącza audyt logów. Scenariusz nie zastępuje unit testu w repo, służy do szybkiego sprawdzenia hipotezy.
- Komora testowa: każdy PR z nową treścią lub mechaniką dostaje zestaw `aquila/code/modules/test_chamber/kits/pr_<nr>_<nazwa>.dm` (`/datum/test_chamber_kit/pr_<nr>`: `name`, `pr` jako pełne `aq33/AquilaStation#N`, `description` z tym, co sprawdzić, `items`, ewentualnie `setup()`), dołączony pod komentarzem „Komora testowa” w `aquila/aquila.dm`. Bugfixy nie dostają zestawu. Zestawu `test_subjects` nie usuwaj.
## CI (`.github/workflows/continuous_integration.yml`)
- Lintery: `tools/ci/check_grep.sh` (m.in. pisownia `CentCom`, mapy w TGM, brak `pixel_x = 0`, zdublowanych obiektów na kafelku), `check_filedirs.sh` (nie zaznaczaj folderów w drzewie DreamMakera), `check_changelogs.sh` (nie ruszaj `html/changelogs/example.yml`), dreamchecker. Wszystkie lintery map obejmują też `aquila/_maps/`.
- `tools/ci/check_map_connections.py`: urwane rury, zła warstwa lub strona urządzenia, nakładające się rury, terminal bez kabla albo z kilkoma kolorami. Stare błędy są w `tools/ci/map_connections_baseline.txt`, CI odrzuca tylko nowe. Po poprawieniu starego błędu uruchom skrypt z `--update-baseline`. Nowego błędu nie dopisuj do listy, tylko popraw mapę.
- Lokalne CI przed pushem: `tools\local_ci\local_ci.bat` (lintery, kompilacja DM, dreamchecker, TGUI; `--szybko` bez TGUI, `--pelne` dodaje wszystkie mapy i testy jednostkowe, `--tylko grep,dm`, `--lista`). Kompiluje kopię `.dme`, więc nie rusza `nsv13.dmb` ani `.rsc` zablokowanego przez działający serwer; do `tools/bootstrap/.cache` pobiera dreamchecker w wersji z `dependencies.sh` (`SPACEMAN_DMM_VERSION`) i `jq` w wersji ze stałej `JQ_VERSION` w `local_ci.py`. Mapy sprawdza jak CI (`dm-maps-include` i `-DCIBUILDING -DCITESTING -DALL_MAPS`), a potem usuwa `_maps/templates.dm`, którego `build.js` sam nie usuwa. Bez `-DCIBUILDING` szablony nie są dołączane i błędy map przechodzą po cichu. Nie sprawdzaj map przez `.dme` z `#include` wszystkich `.dmm`: dm przestaje ładować mapy po pierwszej z błędem. Testy działają jak w CI w osobnej kopii świata (`tools/bootstrap/.cache/ci_test`, własne `config/` i `data/`), bez bazy danych, więc testy jej wymagające mogą padać inaczej niż w CI; logi przebiegu analizuje `round_audit.py --ci`.
- TGUI: z folderu `tgui/` skrypty projektu `tgui:lint`, `tgui:prettier` i `tgui:tsc` przez wrapper Node z repo, np. `..\tools\bootstrap\node.bat .yarn/releases/yarn-4.9.1.cjs tgui:lint` (analogicznie pozostałe).
- Jeśli CI jest czerwone, najpierw sprawdź, czy master też jest czerwony, zanim zaczniesz szukać błędu w swoim PR.
## Git
- Każde zadanie na osobnej gałęzi od `aq33/master` (lokalny `master` bywa nieaktualny), najlepiej w osobnym worktree. Przed zadaniem sprawdź `git status`.
- Commit po udanej kompilacji. Nie rób commitów z kodem, który się nie buduje.
- Push i PR dopiero po zakończonym zadaniu na własnej gałęzi, nigdy na `master`.
- Kilka próśb w jednej wiadomości: domyślnie jeden PR z osobnymi commitami, chyba że ktoś poprosi o podział.
## Pull request
- Tytuł po polsku: `Obszar: krótki opis (port Repo #NNNN)`.
- Opis według `.github/PULL_REQUEST_TEMPLATE.md`. Przy porcie: link do oryginału i lista różnic względem niego z powodem.
- Każdy numer PR/issue jako pełne `owner/repo#N` (np. `tgstation/tgstation#88252`), także do naszego repo (`aq33/AquilaStation#N`). Gołe `#N` wskazuje bieżące repo, więc numer PR-a z innego serwera (np. „Skyrat #1115”) zamienia się w link do niezwiązanego PR-a u nas albo w upstreamie.
- Changelog między `:cl:` a `/:cl:`, wpisy po polsku, tylko prefiksy z szablonu. Przy porcie autor oryginału po pierwszym `:cl:`.
- Napisz, czy zmiana była testowana w grze i czy TGUI wymaga przebudowy.
## Porty z innych kodów (tgstation, Bee, Yogstation, Monkestation, Paradise i inne)
- Trzymaj się oryginalnego PR-a. Nie dodawaj funkcji ani refaktorów, których w nim nie ma.
- Przy większych PR-ach najpierw wypisz zależności (czego brakuje w naszym kodzie) i poczekaj na „dalej”.
- Jeśli PR zależy od czegoś, czego nie mamy, zapytaj: portować zależność, uprościć czy pominąć.
- Nie nadpisuj naszych modyfikacji. Wypisz miejsca kolizji.
- Sprawdź, czy PR miał poprawki po wcieleniu w oryginalnym repo, i je uwzględnij.
- Pomijaj mapy, testy screenshotowe i inne elementy, których nasz kod nie obsługuje, chyba że napisano inaczej.
- Licencje: zwróć uwagę, skąd pochodzą ikony i dźwięki.
- Dopisując coś do listy w core (`products` automatu, `backpack_contents` stroju itp.), najpierw sprawdź grepem, czy `aquila/` albo `nsv13/` nie przypisuje tej listy od nowa. Wygrywa ostatnia definicja w kolejności `#include`, więc dopisz tam. Przykład: strój oficera ochrony to `/datum/outfit/job/security` z `nsv13/`.
- Okno TGUI z tg, które pokazuje zmieniające się dane (licznik, postęp), potrzebuje `ui.set_autoupdate(TRUE)` w `ui_interact`. U nas `autoupdate` jest domyślnie FALSE.
## Synchronizacja z upstreamem (BeeStation/NSV13)
- Historia jest squashowana, `git merge-base` nic nie znajduje: porównuj drzewa, nie historię.
- Przejdź `aquila/LEGACY_OVERRIDES.md` i każdy `AQ EDIT` w zmienionych plikach.
## Mapy (.dmm)
- Zmiany tylko precyzyjne i drobne (na podstawie współrzędnych lub jednoznacznego opisu).
- Nie ruszaj instalacji (rury, kable, zasilanie, wentylacja) bez pytania. Jeśli trzeba, zaproponuj układ i poczekaj na zgodę.
- Zmiana ma wyglądać jak od mappera, nie tylko działać: przed edycją obejrzyj pomieszczenie i sąsiedztwo, dopasuj podłogi, dekale, oświetlenie i symetrię, ustawiaj meble i maszyny logicznie (pod ścianami, z przejściami). Po zmianie wyrenderuj fragment (webmapa lub render BYOND) i oceń go wzrokiem.
- Zapisuj w formacie TGM (hooki mapmerge: `tools/hooks/Install.bat`), inaczej CI odrzuci mapę.
- Po zmianie napisz, co dokładnie zmieniłeś, żeby dało się to obejrzeć w StrongDMM.
## Wiki (https://aqnsv13.miraheze.org)
- Każda nowa zawartość od nas (antag, rasa, maszyna, przedmiot, mechanika, reagent, event, mapa) dostaje wpis na wiki. Zmiana działania istniejącej rzeczy też.
- Najpierw szukaj istniejącej strony i ją uzupełniaj: nowa sekcja, wiersz tabeli, poprawiony opis. Nową stronę zakładaj dopiero, gdy temat nie pasuje do żadnej (np. każdy nowy antag ma własną stronę, tak jak Blood Cult czy Changeling). Nową stronę podlinkuj z powiązanych stron i z odpowiedniej kategorii lub nawigacji.
- Opisuj stan z kodu (liczby, czasy, koszty, receptury), nie z oryginału portu. Jeśli działa inaczej niż na innych serwerach NSV13, napisz to wprost.
- Treść po polsku, nazwy według `aquila/SLOWNIK_TLUMACZEN.md` i tak jak w grze. Tytuły stron i kotwice zostają po angielsku: `=={{anchor|Objectives}}Cele==`, żeby stare linki działały.
- Trzymaj styl istniejących stron:
  - antagi i profesje: `{{Infobox_jobs}}` (kolory, obrazek, przełożeni, trudność, obowiązki), pod nim cytat kursywą i wstęp fabularny;
  - sekcje `==`/`===` z ikoną `[[File:X.png]]` przy nagłówku zdolności lub przedmiotu;
  - dane w `{| class="wikitable"`, długie listy w ramkach `toccolours mw-collapsible`;
  - obrazki ze sprite'ów z gry (wycięte z `.dmi`), z podpisem w `[[File:X.png|Nazwa]]`; brakujące wgrywaj.
- Sterowanie opisuj dla obu trybów (combat mode i intencje), jeśli się różni.
- Edytuję z panelu przeglądarki w aplikacji, na koncie użytkownika (sam się loguje). Przed zapisem dużej zmiany albo nowej strony pokaż w czacie plan: które strony, jakie sekcje.
- Po scaleniu PR-a z nową zawartością albo zmianą działania aktualizuję wiki w tej samej sesji: strony z punktu 7 podsumowania, opisane według kodu z aq33/master. Gdy nie mogę od razu (brak logowania, PR scalony poza sesją), mówię to wprost i zapisuję w pamięci, które PR-y czekają na wiki. Na początku pracy po przerwie sprawdzam scalone PR-y nowsze od ostatniej edycji wiki.
## Koniec każdego zadania
Napisz:
1. Co zmieniłeś (pliki).
2. Co odbiega od oryginału lub od planu i dlaczego.
3. Co mogło się zmienić w innych miejscach.
4. Jak to przetestować w grze (w obu trybach sterowania, jeśli dotyczy kliknięć).
5. Czy `.dmb` i bundle TGUI są przebudowane.
6. Jaki zestaw komory testowej dodałeś (albo dlaczego żadnego).
7. Które strony wiki uzupełniłeś lub założyłeś (albo co jeszcze trzeba na wiki dopisać, gdy zmiana nie jest scalona).
## Audyt logów rundy
- Po każdej rundzie testowej: `python tools/round_audit/round_audit.py --porownaj poprzednia` z folderu, w którym działał serwer (domyślnie najnowsza runda z `data/logs`; `--ci` bierze ostatni przebieg testów lokalnego CI; `--out raport/<temat>_NN_audyt.md` zapisuje raport). Grupuje runtime'y (dla `stack_trace()` pokazuje wywołującego), oznacza nowe względem poprzedniej rundy, zbiera ostrzeżenia, problemy z `qdel.log` (twarde usunięcia, nieudane, bez wskazówki, spanie w `Destroy`), perf CSV, najwolniejsze podsystemy przy starcie, błędy map i configu. Kod wyjścia 1 przy nowych runtime'ach.
## Recenzje i analizy
- Przy przeglądzie kodu nie zmieniaj plików, tylko pisz raport (numery linii, ocena ryzyka).
- Raporty i analizy zapisuj w `raport/` jako `<temat>_<NN>_<opis>.md`, partiami. Nie mieszaj ich z commitami kodu.
## Błędy, których nie powtarzamy
(Dopisuj tu wnioski, np. „Nie używaj X, bo u nas psuje Y”.)
- Linki w HTML (`href`, `action`) zaczynaj od `byond://` (np. `byond://?_src_=holder;...`). Kod portowany ze starszego tg ma `?_src_=` i CI (`check_grep.sh`) go odrzuca.
- `/datum/http_response` czytaj przez `response.body`, nie `response["body"]` (runtime).
- W nadpisaniu procki nie powtarzaj `SIGNAL_HANDLER` ani `SHOULD_NOT_SLEEP` (dreamchecker: tylko w pierwszej definicji). `to_chat()` nie ma u nas argumentu `confidential`.
- `/obj/item/proc/pre_attack` u nas zwraca TRUE = idź dalej do `attackby`, FALSE = przerwij. W Bee i nowym tg jest odwrotnie, więc przy porcie odwracaj zwracane wartości (domyślnie `return ..()`). Objaw pomyłki: trzymając przedmiot, nie da się niczego kliknąć.
- `caller` to w 516 wbudowana zmienna: zmienna datumu o tej nazwie czytana bez `src.` zwraca wywołującą prockę (bez ostrzeżenia). Nie nazywaj tak zmiennych.
- W 516 liczba z jednostką czasu (`5s`, `500ms`) w stringu `/client/script` i liczbowe klucze w literale `list()` to błędy kompilacji (użyj list pozycyjnych albo `alist()`).
- `sort_list` sortuje listę asocjacyjną po kluczach. Sortowanie po wartościach: `sortTim(lista, cmp, associative = TRUE)`.
- W TSX nie rozpakowuj `Set` ani `Map` przez `[...x]`: Babel w trybie luźnym robi z tego `[].concat(x)`, czyli tablicę z jednym obiektem `Set`. Używaj `Array.from(x)`. Objaw: okno TGUI pada z „Cannot read properties of undefined”.
