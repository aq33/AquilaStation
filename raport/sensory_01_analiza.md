# Sensory okrętowe w stylu Ostranauts: analiza dla Aquili

Data: 2026-11-05. Etap: ocena pomysłu, bez kodu.

Oznaczenia: **[POTW.]** znaczy potwierdzone w kodzie albo w źródle, **[NIEPOTW.]** to relacje graczy lub strony fanowskie, **[ZAŁ.]** to moje założenie lub propozycja. Wszystkie liczby w propozycjach są parametrami do testów.

---

## 1. Ostranauts: co naprawdę jest w grze

Sensory i walka okrętowa weszły w aktualizacji 0.15 „Fire in the Hold” (kwiecień 2026).

**[POTW.]** Gra ma pięć typów sensorów zewnętrznych. Każdy ujawnia inną cechę celu ([System_Components](https://ostranauts.wiki.gg/wiki/System_Components)):

| Typ | Co ujawnia o celu |
|---|---|
| Optyczny | sylwetkę okrętu |
| EM | transponder, a przez niego frakcję |
| IR (ciepło) | liczbę silników i to, czy okręt ma reaktor |
| LiDAR | liczbę broni |
| Radar | mapę ścian z dużej odległości i liczbę załogi |

- **[POTW.]** Części mają bezjednostkowe siły sygnału, na przykład Polaris Optical 25, Zhuangzi IR 600 i NASA Radar 400. Kilka sensorów tego samego typu sumuje się. Radar zużywa około 15 razy więcej energii niż pozostałe (~6,98 kWh wobec ~0,47 kWh) ([System_Components](https://ostranauts.wiki.gg/wiki/System_Components)).
- **[POTW.]** Sygnał słabnie z odległością, przy mniejszym profilu celu i przy większej prędkości poprzecznej. Optyka Polaris jest silniejsza w stożku około 30° na wprost (ta sama strona).
- **[POTW.]** Deweloper o sensorach: „Most of what we have is signal strength based on sensor type and target features”. Siła sygnału wpływa na widoczność celu i czas namierzania ([Steam, 18.12.2025](https://steamcommunity.com/app/1022980/eventcomments/691996029262859629/)). Bardziej rozbudowane ECM jest tylko w planach („we've talked about”).
- **[POTW.]** Konsola nawigacyjna ma moduł Sensors MFD: sensory pasywne i aktywne, włączanie własnych sensorów, oznaczanie jednostek. Opis funkcji wiki częściowo wnioskuje z etykiet paneli ([Navigation_Console](https://ostranauts.wiki.gg/wiki/Navigation_Console)).
- **[POTW.]** Identyfikację zapewnia transponder (IFF) z anteną. Bez nich nie da się zadokować na niektórych stacjach, a policja nakłada kary. Można podmienić transponder na rejestrację innego własnego okrętu ([Ship_Ownership](https://ostranauts.wiki.gg/wiki/Ship_Ownership)).
- **[POTW.]** Ostrzeżenia: PROX WARN (poniżej 5 km), TRACK WARN (ktoś cię namierza), XPDR/ANT FAULT ([Flying](https://ostranauts.wiki.gg/wiki/Flying)).
- **[POTW.]** Broń: PDC (12–15 km, łuk 85°), mass throwery (66–120 km, łuk 15–20°), rakiety (360°, nigdy nie strzelają same) i wabiki o skuteczności 33/75/100%. Ogień automatyczny wymaga namiaru (lock) ([Ship_Combat](https://ostranauts.wiki.gg/wiki/Ship_Combat)).
- **[NIEPOTW.]** Okręt bez IFF ma być niewidoczny powyżej około 500 km. IR ma wykrywać okręt z reaktorem z około 350 km przy 50% sygnału. Kontakt ma się pojawiać na mapie od około 50% sygnału. Źródło: wątki na Steam ([1](https://steamcommunity.com/app/1022980/discussions/2/4852155320351558591/), [2](https://steamcommunity.com/app/1022980/discussions/1/800094241558761135/)).
- **[NIEPOTW.]** To, że ciąg silników lub własny radar podbija twoją sygnaturę, podają tylko strony fanowskie (prawdopodobnie generowane). **Nie przypisuję tego grze.**

**Wniosek:** w Ostranauts sensory służą głównie do *warstwowego rozpoznania* (każdy typ odsłania inną cechę celu) i do *siły sygnału*, która decyduje o widoczności i czasie namierzania. Mechanika „emisja zdradza pozycję” nie jest tam udokumentowana, więc nie traktuję jej jako sprawdzonego wzoru z Ostranauts.

---

## 2. Aquila / NSV13: co już mamy w kodzie

Repozytorium: `aq33/AquilaStation`, fork BeeStation/NSV13. Nazwa nie budzi wątpliwości.

**[POTW.]** DRADIS, `nsv13/code/modules/overmap/radar.dm`:
- **Tryb pasywny i aktywny** (`SENSOR_MODE_PASSIVE/RADAR`, linie 4–5, 303–304). Impuls radaru (`send_radar_pulse`, linie 82–100) robi kilka rzeczy naraz:
  - na 5 s ustawia własny `sensor_range = world.maxx`, czyli widzisz całą mapę;
  - podwaja `max_tracking_range`;
  - podnosi `sensor_profile`;
  - przez 5 s czyni cię w pełni widocznym dla **wszystkich** (`is_sensor_visible`, linie 338–339);
  - puszcza dźwięk na pobliskich okrętach.

  Tryb aktywny wysyła impulsy co `radar_delay` (5–60 s), ale tylko z wnętrza `ui_data` (linie 442–443), czyli wtedy, gdy ktoś ma otwarte okno DRADIS. Impuls poszerza zasięg tylko konsoli, która go wysłała, bo każda konsola ma własny `sensor_range`.
- **Wykrycie i identyfikacja są już rozdzielone** (linie 380–412):
  - Kontakt pojawia się do `sensor_range * 2`, czyli 80 pól przy domyślnym zasięgu 40 (`SENSOR_RANGE_DEFAULT`, `__DEFINES/overmap.dm:42`).
  - Nazwa i frakcja są widoczne dopiero do `sensor_range`. Dalej kontakt jest pomarańczowy i podpisany „NIEZNANY”.
  - Sojusznicy są widoczni zawsze (IFF).
- **Maskowanie** to wartość alpha okrętu (`cloak_factor`). Daje poziomy widoczności GHOST, VERYFAINT, FAINT i FULL. Namierzenie wymaga widoczności ≥ 0,70 (`SENSOR_VISIBILITY_TARGETABLE`). Strzał na chwilę zrzuca maskowanie (`CLOAK_TEMPORARY_LOSS`, `firing.dm:17`).
- **Dane do strzelania** (`overmap.dm:643–730`):
  - oznaczenie celu (`start_lockon`) trwa 2 s;
  - można utrzymać maksymalnie 3 oznaczenia;
  - utrata śledzenia następuje po 3 s bez kontaktu;
  - oznaczenia można przekazać łączem danych sojuszniczemu okrętowi z działonowym (`datalink_transmit`).

  Do *nałożenia* namiaru trzeba widoczności ≥ 0,70 (bez sprawdzania zasięgu, `overmap.dm:661`). Do jego *utrzymania* wystarczy widoczność > 0 w zasięgu `sensor_range * 2` (`physics.dm:438–448`), więc słabo zamaskowany cel pozostaje namierzony.
- Oznaczony cel widzi oznaczającego w pełni (`is_sensor_visible`, linia 342). Gdy namierza AI, gracz słyszy ostrzeżenie (`ai-skynet.dm:1625`). **W `start_lockon` nie znalazłem ostrzeżenia dla okrętu gracza namierzanego przez innego gracza (PvP).**
- **Zasięg wzrokowy:** kamera działonowego działa tylko do `visual_range` = 40 (`tactical.dm:66`, `camera.dm:205`).
- **Podnoszenie sygnatury z zewnątrz:**
  - EMP (`weapons/projectiles_fx.dm:341`), torpeda zakłócająca (`:584`) i kuta amunicja z cechą EMP (`aquila/code/modules/munitions_forge/traits.dm:145`) dodają okrętom liniowym graczy `sensor_profile` +150 na 10 s. AI i małe jednostki dostają zamiast tego `disruption`.
  - Kadesh dodaje karę samemu sobie przy interdykcji (`syndicate.dm:518–519`).
- **Środki przeciwdziałania:**
  - chmura flar dla wszystkich `small_craft`, także desantowców: 50% na detonację rakiety albo utratę naprowadzania (`countermeasure_ammo.dm`, `general_quarters/dropship_types.dm:48–50`);
  - tryb „countermeasures” obrony przeciwrakietowej okrętów liniowych (`weapons/delta_overmap_ship_weapons/autonomy.dm:126`);
  - torpedy-wabiki z cargo („Głowice rakiet ECM”), czyli cel zastępczy dla obrony punktowej: 0 obrażeń, 500 HP (`projectiles_fx.dm:505`).
- **Konsola IFF** (`game/machinery/iff_console.dm`) przełącza frakcję okrętu, a z nią to, kto jest widoczny jako sojusznik. Używa jej cel sabotażowy zdrajcy (`aquila/.../traitor/objectives/sabotage.dm:247`).
- **Ostrzeżenie o odpaleniu rakiet** z namiarem już jest w DRADIS (`autonomy.dm:247–256`).
- **AI** śledzi do `max(max_tracking_range, sensor_profile)` (50, w niektórych typach 70–90), a nie według `sensor_range`, i wymaga widoczności ≥ 0,70 (`ai-skynet.dm:1299, 1507, 1721`). Dla niezamaskowanego okrętu widoczność zawsze wynosi FULL. Ważne dla projektu:
  - AI ustawia ciąg w każdym ticku (`ai-skynet.dm:1521`) i pulsuje radarem, gdy poluje lub nie ma celu (`:954, 991, 1120, 1149, 1220`). **AI nigdy nie leci po cichu.**
  - Flota dzieli cele (`shared_targets`), a zapasowy wybór celu w `seek_new_target` bierze cel z listy floty **bez sprawdzania widoczności** (`:1738–1739`).
- **Myśliwce** mają wewnętrzny DRADIS o zasięgu 30 (`radar.dm:190`). „AWACS” to martwy szkic: jest tylko nadpisanie procki (`radar.dm:53`), bez typu i bez użycia.
- **Ciąg** nie ma przepustnicy. To pole bitowe kierunków `user_thrust_dir`, kasowane co tick (`physics.dm:427`). Na każdej osi działa pełna moc albo zero, a wynik ląduje w `last_thrust_forward/right` (`physics.dm:257–286`). Hamulce zużywają ciąg, natomiast obrót i tłumiki inercyjne są darmowe.
- **Mapa zawija się na krawędziach** (`__HELPERS/overmap.dm:71–88`), więc największa odległość to około 170 pól. Bazowe wykrycie (80 pól) obejmuje już około połowy mapy.
- **Role:** Bridge Staff (3 etaty), ATC, piloci, a działonowy i pilot przy konsolach taktycznej i sterowej. DRADIS nie ma osobnego operatora: celować z niego mogą tylko działonowy albo pilot (linie 284, 311).

**Luki, w których sensory mogą coś dodać:**
1. **Aktywny radar działa zero-jedynkowo.** Impuls na 5 s daje widok całej mapy na żywo i całą mapę widzi ciebie. W praktyce wybór sprowadza się do „pulsuj albo nie”.
2. **Własne działanie okrętu nie wpływa na wykrywalność.** Ciąg, reaktor i ogień nie zmieniają sygnatury, z wyjątkiem zrzucenia maskowania. Opis DRADIS mówi o „śledzeniu sygnatur silników”, ale kod tego nie robi.
3. **Pozycje kontaktów są zawsze dokładne.** Nie ma niepewności ani „ostatniej znanej pozycji”.
4. **Uszkodzenia nie osłabiają sensorów.** Liczy się tylko to, czy konsola istnieje i ma zasilanie. DRADIS nie ma `emp_act`.
5. **Namierzanie przez gracza nie ostrzega celu w PvP**, w przeciwieństwie do namierzania przez AI i do rakiet.
6. **Nie ma zagłuszacza ani macierzy sensorów** jako komponentu okrętu, ani w `nsv13/`, ani w `aquila/`.

**Ważna asymetria:** większość rund to walka z flotami AI, które są zawsze głośne. Pasywna sygnatura nie zmieni więc tego, *jak gracze widzą AI*, tylko to, *jak AI widzi graczy*, i to pod warunkiem, że przerobi się wykrywanie po stronie AI. Pełną symetrię daje dopiero PvP.

---

## 3. Rozbiór czterech sensorów

Cztery etapy kontaktu, na których opieram projekt:

| Etap | Co gracz wie | Na co pozwala |
|---|---|---|
| **Wykrycie** | „coś tam jest”, z namiarem i przybliżoną odległością | uniknąć kontaktu albo podejść bliżej |
| **Śledzenie** | pozycja aktualizowana na bieżąco i wektor ruchu | manewrować, przechwycić, podać kurs pilotowi |
| **Identyfikacja** | klasa, frakcja i nazwa (w Ostranauts dodatkowo broń i załoga) | zdecydować: walka, hail, ucieczka |
| **Dane ogniowe** | rozwiązanie celownicze dokładne na tyle, że broń trafia | strzelać, przekazać cel łączem danych |

**Radar (aktywny).** Szybko i daleko daje wykrycie oraz śledzenie z dokładną pozycją i prędkością. Kosztem jest głośna emisja: przeciwnik dostaje twój namiar z odległości większej niż ta, z której ty go widzisz. Przydaje się, gdy nie musisz się ukrywać: patrol, konwój, gotowość do walki. Mamy go już. **Do zmiany [ZAŁ.]:** impuls powinien dawać *migawkę* pozycji, która potem się starzeje, zamiast 5 s widoku na żywo. Inaczej zastępuje cały pasywny obraz.

**Podczerwień (pasywna).** Wykrywa ciepło, czyli ciąg silników, pracujący reaktor, ogień broni i pożary. Daje wykrycie i zgrubne śledzenie z niepewną pozycją. Nic nie emituje, więc to sensor „cichej jazdy”. **To jedyny element, który tworzy nowe decyzje: o widoczności decyduje to, co robi przeciwnik.** Pilot, który dryfuje z wygaszonym napędem, znika z ekranu. Pilot, który pali silnikami, świeci.

**LiDAR (aktywny, wąska wiązka).** Daje dokładną odległość i prędkość pojedynczego celu, czyli dane ogniowe. **W NSV13 robi to już oznaczanie celu (`start_lockon` / `target_painted`)**, a cel już widzi oznaczającego. Osobny LiDAR byłby duplikatem. Proponuję uznać oznaczanie za „namiar ogniowy LiDAR” fabularnie i dodać brakujące ostrzeżenie dla celu w PvP.

**Optyka.** W kosmosie to pasywna obserwacja w świetle widzialnym: kamera i teleskop. Daje identyfikację, czyli sylwetkę, klasę, a także uszkodzenia i otwarte hangary. Słabo nadaje się do wykrywania z daleka, bo na tle gwiazd nic nie widać, dopóki okręt czegoś nie odbija albo nie zasłania. **Aktywne oświetlanie celu** (laser, reflektor) jest fizycznie LiDAR-em albo oznaczaniem, więc nie robię z niego osobnej funkcji. **Rozdzielenie od IR:** optyka odpowiada na pytanie „co to jest” na krótkim dystansie, IR na pytanie „gdzie coś grzeje” na średnim. Optykę mamy już jako `visual_range` i kamerę działonowego. Proponuję podpiąć pod nią *identyfikację*: pełna nazwa i klasa dopiero w zasięgu wzrokowym albo po dłuższym śledzeniu.

**Niepotrzebne lub do połączenia:**
- LiDAR łączy się z istniejącym oznaczaniem.
- Optyka łączy się z istniejącym zasięgiem wzrokowym i staje się etapem identyfikacji.
- Nowe są w praktyce **dwa kanały: aktywny radar (już jest, do przestrojenia) i pasywna sygnatura (IR)**.
- Transponder/IFF (EM w Ostranauts) to tani dodatek na później: IFF wyłączone oznacza trudniejszą identyfikację, ale też status „wrogi/nieznany” u AI i handlarzy.

---

## 4. Przełożenie na mechanikę (parametry do testów)

**Sygnatura okrętu [ZAŁ.]** to jedna liczba liczona raz na cykl okrętu i trzymana w pamięci podręcznej:

| Składnik | Wartość startowa | Uwagi |
|---|---|---|
| bazowa wg klasy | myśliwiec 0,4 · fregata 0,6 · okręt liniowy 0,8 · krążownik 1,0 · stacja 1,3 | zależna od rozmiaru |
| ciąg silników | +0 do +0,5 jako zanikająca średnia z `last_thrust_*` (pół życia ~5 s) | przepustnicy nie ma; dryf jest cichy |
| tłumiki inercyjne i obrót | +0,1, gdy aktywne | żeby cichy ostrzał z dryfu nie był darmowy |
| ogień bronią | +0,4, zanika przez 10 s | strzał zdradza |
| oznaczanie celu | cel widzi oznaczającego w pełni | jak teraz |
| impuls radaru | widoczny dla wszystkich przez 5 s, jak teraz | głośna decyzja |
| uszkodzenia kadłuba | +0 do +0,3 według ułamka utraconej integralności | ranny okręt świeci; bez skanowania pożarów |
| maskowanie | mnożnik ×(`cloak_factor`/255) | wykorzystuje istniejące maskowanie |
| trafienie EMP | +150 do `sensor_profile`, jak teraz | bez zmian |

**Zasięg pasywnego wykrycia** dla graczy = `sensor_range * 1,5 * sygnatura celu`, w granicach 15–100 pól. **Dla AI osobno:** `max_tracking_range * sygnatura celu`, bo AI nie korzysta z `sensor_range`. Przykłady przy domyślnym zasięgu 40:
- dryfująca fregata (0,6) jest widoczna z 36 pól;
- ta sama fregata przy pełnym ciągu i strzelająca (1,5) jest widoczna z 90 pól, czyli z ponad połowy zawiniętej mapy.

Cała gra toczy się w przedziale sygnatury poniżej 1. Powyżej i tak widać prawie wszystko.

**Niepewność pozycji:**
- Kontakt pasywny pokazuje okrąg o promieniu `2 + 6 × (odległość / zasięg wykrycia)` pól, czyli od 2 do 8 pól.
- Przesunięcie pozycji jest **trwałe dla pary okręt–cel i błądzi powoli** (random walk). Nie losuje się go od nowa przy każdym odświeżeniu, bo kilka próbek dałoby się uśrednić. Przesunięcie trzyma okręt, a nie konsola, więc druga konsola nie daje dodatkowych próbek.
- Pozycja kontaktu odświeża się co 2–3 s, nie przy każdym ticku.
- Kontakt z impulsu radaru jest dokładny. Po impulsie zostaje „duch” w ostatniej znanej pozycji. **Duch musi żyć krócej niż najkrótszy odstęp między impulsami** (na przykład duch 8 s przy minimum 15 s zamiast obecnych 5 s), bo inaczej ciągłe pulsowanie da stały, dokładny obraz.
- **Trafienie z niewidocznego kierunku** od razu tworzy kontakt „ostrzał z namiaru X”. Tak przegrywający gracz zawsze wie, skąd go biją.

**Utrata kontaktu:** spadek poniżej progu przez 6–8 s (dziś 3 s przy namiarze). Kontakt zmienia się wtedy w znacznik ostatniej znanej pozycji na 30 s.

**Identyfikacja:**
- W zasięgu `sensor_range` od razu, jak dziś.
- Dalej po 20–30 s nieprzerwanego śledzenia: najpierw klasa, potem frakcja, na końcu nazwa.
- W zasięgu wzrokowym (optyka) od razu i z dodatkowymi danymi, na przykład szacowanym stanem kadłuba.

**Namierzanie:**
- 2 s przy dobrym kontakcie (radar albo bliski IR).
- Do 5 s przy słabym kontakcie.
- Niemożliwe przy samym znaczniku ostatniej znanej pozycji.

**Zakłócenia (etap 2):**
- Zagłuszacz ECM powiększa okrąg niepewności celu ×2 i wydłuża namierzanie ×1,5.
- Sam zagłuszacz świeci jak radar, więc wróg wie, *że* tam jesteś, ale nie wie *dokładnie gdzie*.
- Okręty liniowe dostają wabiki: istniejące flary myśliwców w większej skali i ze zużyciem amunicji.

**Uszkodzenia (etap 2):**
- Fizyczna maszyna „macierz sensorów” na mapie, którą naprawiają inżynierowie.
- Przy 50% integralności zasięg spada o 30% i okręgi niepewności rosną ×1,5.
- Przy 0% okręt jest ślepy poza zasięgiem wzrokowym.
- Do MVP wystarczy prostsza wersja bez mapy: EMP i `disruption` chwilowo podnoszą niepewność.

---

## 5. Załoga: kto co robi

- **Oficer sensorów, czyli Bridge Staff przy DRADIS:**
  - decyduje „cisza czy radar”;
  - obserwuje kontakty IR;
  - mówi pilotowi i działonowemu, gdzie jest wróg;
  - przekazuje kontakt dalej (oznaczanie i łącze danych już istnieją).

  Dziś Bridge Staff przy DRADIS głównie patrzy. Ta zmiana daje mu realną decyzję.
- **Pilot** steruje *emisją przez sposób latania*. Cichy dolot na dryfie ze strzałem z zaskoczenia albo pełny ciąg i ucieczka kosztem tego, że świeci.
- **Działonowy (konsola taktyczna)** potrzebuje dobrego kontaktu do namiaru i wie, że oznaczenie celu ujawnia jego okręt. Decyduje, *kiedy* oświetlić cel.
- **Inżynierowie:**
  - naprawiają macierz sensorów (etap 2);
  - w PvP i misjach skrytych mogą zdławić reaktor, żeby obniżyć ciepło. To opcja na później, tylko jeśli MVP się sprawdzi.
- **Myśliwce i ATC** są wysuniętymi pasywnymi pikietami. Myśliwiec wykrywa wroga daleko od okrętu matki i podaje go łączem danych, a okręt nie musi pulsować. Łącze danych już istnieje, brakowało tylko powodu, by go używać. AWACS w kodzie jest martwym szkicem i można go dokończyć w etapie 2.
- **Mała liczba graczy:**
  - Domyślne ustawienia nie mogą wymagać obsługi. Kontakty IR pojawiają się same, a tryb „Active Radar” z automatycznym impulsem już jest.
  - Kapitan sam na mostku gra jak dziś: włącza auto-radar i jest widoczny.
  - Głębia jest nagrodą za obsadzenie stanowiska, nie warunkiem gry.

---

## 6. Interfejs i balans

- **Cztery wyglądy kontaktu w DRADIS, bez nowych okien:**
  - kontakt niepewny: półprzezroczysty okrąg ze znakiem „?”;
  - kontakt śledzony: kropka z krótkim wektorem ruchu;
  - kontakt zidentyfikowany: nazwa i kolor frakcji;
  - cel namierzony: nawias celownika.

  Do tego ostatnia znana pozycja jako przekreślony, blednący znacznik.
- **Zero dodatkowych kliknięć w podstawowym obiegu.** Wykrycie, śledzenie i identyfikacja dzieją się automatycznie. Gracz klika tylko decyzje: impuls, oznaczenie, przełączenie ciszy.
- **Kontra zawsze istnieje.** Radar widać, oznaczenie celu widać, a ogień zdradza pozycję. Nie ma stanu „niewidzialny i strzelający”, bo maskowanie znika już dziś przy strzale.
- **Ostrzeżenia czatowe** z wyciszaniem i limitem spamu, jak dziś `last_missile_warning`: „Wykryto emisję radaru, namiar 045”, „Namiar ogniowy na nasz okręt!”.
- **Ryzyko balansu:** AI musi grać według tych samych zasad, czyli tracić cię, gdy dryfujesz. Dotyczy to też dzielenia celów we flocie (`shared_targets`). Inaczej gracze uznają system za oszustwo („ucichłem, a i tak lecą prosto na mnie”).
- **Minimalny zasięg wykrycia** około 15 pól, ale nie mniejszy niż zasięg najdalej strzelającej broni. Inaczej zimny myśliwiec strzela spoza wykrycia.
- **Niewybaczalna asymetria w PvP:** w pełni obsadzony okręt Syndykatu zyska dużo na ukryciu wobec niedoobsadzonego mostka NT. Warstwę „ciszy” po stronie graczy można na start ograniczyć do trybu `pvp` (`gamemodes/pvp/pvp.dm`) albo do konfiguracji.
- **Nowi gracze:** okrąg „?” potrzebuje podpowiedzi po polsku. Znacznika ostatniej znanej pozycji nie można namierzyć i nie powinien wyglądać na klikalny.
- **Tempo:** w SS13 spotkanie trwa minuty, nie godziny. Wszystkie czasy powyżej są w sekundach i mają dać jedną albo dwie decyzje przed starciem, a nie długie podchody.

---

## 7. Wykonalność techniczna

- **Punkt zaczepienia:**
  - `is_sensor_visible()` i pętla `ui_data()` DRADIS, wykrycie w `radar.dm:380–412`;
  - śledzenie celów w `physics.dm:437–448`;
  - AI w `ai-skynet.dm:1507, 1721`.

  Wszystko da się nadpisać w `aquila/` przez wywołanie `..()` albo pełne nadpisanie z wpisem do `LEGACY_OVERRIDES.md` (`is_sensor_visible` prawdopodobnie wymaga pełnego).
- **Bez zmian map w MVP.** Macierz sensorów jako maszyna (etap 2) wymaga drobnych edycji map każdego okrętu, co jest osobną pracą, uzgadnianą z mapperem.
- **Wydajność BYOND:**
  - `ui_data` DRADIS już dziś przechodzi przez całe `GLOB.overmap_objects` dla każdego otwartego okna (także okna pilota), mniej więcej co 0,9 s (`SStgui` `wait = 9`).
  - Śledzenie namiarów działa w `process()` okrętu na SSphysics_processing (`wait = 1.5`, około 6,7 razy na sekundę). To tanie, bo obejmuje najwyżej 3 cele na okręt.
  - W systemie jest zwykle 3–10 wrogów (`ai-skynet.dm:145–170`), więc koszt par O(n²) jest mały, pod warunkiem że sygnaturę liczy się **raz na okręt na cykl**, a nie dla każdej pary obserwator–cel.
  - Impuls trybu aktywnego trzeba przenieść z `ui_data` do procesu okrętu, bo dziś działa tylko przy otwartym oknie.
  - Pozycję z niepewnością losuje się przy odświeżeniu (co 2–3 s) i przechowuje, a nie przy każdym `ui_data`. To także chroni przed „uśrednianiem” szumu przez gracza.
  - Znaczniki ostatniej znanej pozycji trzymać jako znacznik czasu (`world.time`), bez timerów.
  - Ilość danych wysyłanych do TGUI rośnie nieznacznie: promień i wiek kontaktu.
- **TGUI:** zmiana w `Dradis.tsx` (rysowanie okręgu i wektora) wymaga przebudowy bundle.

---

## 8. Czego z Ostranauts nie przenosić

- **Skala kilometrów, mechanika orbitalna i długie przeloty.** Mapa NSV13 ma ~255 pól, a starcie trwa minuty.
- **Pięć osobnych części sensorów z zasilaniem, orientacją i stożkami.** To zbyt drobiazgowe dla rund z rotacją załogi. Zostawić najwyżej jedną macierz sensorów do naprawy.
- **Osobny sensor do każdej cechy celu** (LiDAR: broń, radar: załoga, IR: silniki). Pomysł warstwowej identyfikacji jest dobry, ale lepiej, żeby dane odsłaniały się *z czasem i odległością*, niż wymagały pięciu urządzeń.
- **Wymiana plików nawigacyjnych przez PDA** i prawno-ekonomiczne skutki podmiany transpondera. Ewentualnie później jako narzędzie antagonisty Syndykatu.
- **Ręczne „railsnipowanie” poza zasięgiem namiaru.** NSV13 ma własny model broni i nie warto go ruszać.

---

## 9. Werdykt

**Warto, ale nie jako „cztery sensory”, tylko jako rozbudowa DRADIS o sygnaturę i niepewność.** NSV13 ma już radar aktywny i pasywny, rozdział wykrycia od identyfikacji, oznaczanie (czyli de facto LiDAR), zasięg wzrokowy (czyli optykę) i maskowanie. Brakuje jednej rzeczy, która tworzy grę: **tego, że twoje działania (ciąg, ogień, radar) decydują o tym, jak daleko cię widać, i że obraz przeciwnika jest niepewny.**

**Warunki:**
1. AI podlega tym samym regułom.
2. Ustawienia domyślne działają bez obsady, a gra przy jednej osobie na mostku zostaje taka jak dziś.
3. Każde ukrycie ma kontrę: emisja zawsze zdradza, a minimalny zasięg wykrycia jest gwarantowany.
4. Najpierw MVP i pomiar, dopiero potem ECM, maszyny i transponder.

**Zysk dla graczy:**
- realna rola oficera sensorów (Bridge Staff);
- pilot, który „gra emisją”;
- powód do użycia myśliwców jako zwiadu;
- w PvE przede wszystkim wybór, *kiedy* AI cię zauważy, bo samo AI zostaje głośne;
- zasadzki i ucieczki;
- PvP, w którym pierwszy strzał jest decyzją, a nie odruchem.

---

## 10. Tabela sensorów

| Sensor | Rola | Zalety | Ograniczenia | Kontra | Werdykt |
|---|---|---|---|---|---|
| Radar (aktywny) | wykrycie i dokładne śledzenie na dużym dystansie | szybki, pewny, widzi zimne cele | zdradza cię wszystkim, migawka się starzeje | cisza radiowa, ucieczka poza zasięg, ostrzał w kierunku impulsu | **zostaje**, przestroić na migawkę |
| IR / sygnatura (pasywny) | wykrycie i zgrubne śledzenie po cieple | nic nie emituje, nagradza obserwację | niepewna pozycja, nie widzi dryfującego celu z daleka | dryf, dławienie ciągu, maskowanie, wabiki cieplne | **nowy rdzeń systemu** |
| LiDAR | dane ogniowe na pojedynczy cel | dokładny, szybki namiar | wąski, ujawnia cię celowi, maks. 3 cele | ostrzeżenie o namiarze (brak w PvP), manewr, wabiki, ECM (etap 2) | **łączę z istniejącym oznaczaniem** |
| Optyka (pasywna) | identyfikacja z bliska | pełna informacja (klasa, stan) | krótki zasięg (`visual_range` 40) | trzymanie dystansu, maskowanie | **łączę z zasięgiem wzrokowym jako etap identyfikacji** |
| (EM/transponder) | identyfikacja na odległość | prosty, fabularny | ma sens tylko z konsekwencjami u AI i handlarzy | wyłączenie lub podmiana IFF | **opcjonalnie, etap 3** |

---

## 11. MVP

Zakres bez nowych maszyn i bez map:

Główna hipoteza do sprawdzenia: **„gracze, którzy latają ciszej, są później wykrywani przez AI i dzięki temu wybierają, kiedy zaczyna się walka”**. MVP testuje tylko to:

1. **Sygnatura okrętu**: klasa + zanikająca średnia ciągu + niedawny ogień + ułamek utraconej integralności, z mnożnikiem maskowania. Liczona raz na cykl okrętu.
2. **Wykrywanie po stronie AI** według sygnatury (`max_tracking_range * sygnatura`) w `seek_new_target` i przy porzucaniu pościgu, **razem ze sprawdzeniem widoczności przy wyborze celu z `shared_targets` floty**. Bez tego test w PvE nic nie zmierzy.
3. **Zasięg pasywnego wykrycia w DRADIS gracza** zależy od sygnatury celu (15–100 pól).
4. **Jeden okrąg niepewności** z trwałym przesunięciem dla kontaktów poza zasięgiem identyfikacji.
5. **Kontakt „ostrzał z namiaru X”** po trafieniu z niewidocznego kierunku.
6. **Ostrzeżenie „Namiar ogniowy”** dla okrętu gracza namierzanego przez innego gracza (PvP), wzorem ostrzeżenia od AI.
7. **DRADIS.tsx**: okrąg, „?” z podpowiedzią. Bez nowych przycisków.

**Poza MVP:** migawka radaru (wymaga zmiany minimalnego odstępu impulsów), identyfikacja z czasem, znacznik ostatniej znanej pozycji, wektor ruchu.

Do tego unit testy (sygnatura rośnie przy ciągu i strzale, kontakt ginie po czasie, AI traci zimny cel) i zestaw komory testowej z wrogim okrętem AI do sprawdzenia dryfu.

**Co mierzyć na 5–10 rundach:**
- dystans, z którego zaczyna się walka;
- jak często załogi wybierają ciszę, a jak często auto-radar;
- czas od wykrycia do pierwszego strzału;
- czy przy 1–2 osobach na mostku runda przebiega tak jak wcześniej;
- skargi typu „nie widzę wroga, a on mnie bije”.

**Etap 2:**
- migawka radaru i ostatnia znana pozycja;
- macierz sensorów do naprawy;
- zagłuszacz (ECM): wabiki i tryb przeciwrakietowy już są, brakuje aktywnego zakłócania;
- warstwowa identyfikacja;
- działający AWACS dla myśliwców (dziś to martwy szkic);
- przeniesienie automatycznego impulsu do procesu okrętu.

**Etap 3:** transponder/IFF, budowany na istniejącej konsoli IFF.

---

## 12. Przykład spotkania

Okręt Nanotrasen (gracze, 4 osoby na mostku) i rajder Syndykatu (PvP albo AI).

Przykład zakłada pełny system (MVP i etap 2) oraz PvP. W PvE strona AI zawsze jest głośna, więc decyzje „po cichu” podejmuje tylko załoga.

1. **T−90 s.** Rajder (fregata, 0,6) leci na dryfie z wyłączonym ciągiem. Z częściowym maskowaniem jego sygnatura spada do ~0,3, więc jest wykrywalny dopiero z ~18 pól. Okręt NT (0,8) leci pełnym ciągiem na punkt nawigacyjny i ma sygnaturę ~1,3, więc rajder widzi go z ~78 pól jako kontakt IR z okręgiem 6 pól. **Decyzja rajdera:** nie pulsować, zbliżyć się po cichu.
2. **T−60 s.** Oficer sensorów NT nie widzi nic. Zauważa jednak, że punkt nawigacyjny to typowe miejsce zasadzki. **Decyzja:** zamiast jednego impulsu radaru prosi ATC o wypuszczenie myśliwca zwiadowczego 30 pól do przodu. Okręt NT dalej nie pulsuje, ale pilot zdejmuje ciąg do 30%, żeby mniej świecić.
3. **T−35 s.** Pasywny DRADIS myśliwca łapie rajdera, który poprawia kurs krótkim odpaleniem silnika (+ciąg). Pojawia się kontakt „?” z okręgiem 5 pól. Myśliwiec przekazuje go łączem danych. **Decyzja oficera sensorów:** czekać na lepszy kontakt czy pulsować? Wybiera impuls, bo kontakt jest już blisko, a dokładna pozycja na 15 s jest warta zdradzenia się.
4. **T−30 s.** Impuls: rajder ma dokładną pozycję, a jego załoga dostaje komunikat „Wykryto emisję radaru, namiar 220” i wie, że została zauważona. **Decyzja rajdera:** uciekać na pełnym ciągu (świeci, ale się oddala) albo atakować pierwszy. Atakuje: oznacza okręt NT, który dostaje „Namiar ogniowy!”.
5. **T−25 s.** Działonowy NT ma migawkę z radaru i oznacza rajdera w 2 s. Pilot NT wykręca burtą do celu. Inżynier dostaje polecenie, żeby przygotować się na EMP, bo trafienie EMP podniesie ich sygnaturę na 10 s.
6. **T−15 s.** Rajder strzela, odsłania się (+ogień, maskowanie spada) i odpala rakiety. DRADIS NT pokazuje istniejące ostrzeżenie o rakietach z namiarem. NT odpowiada salwą i włącza tryb przeciwrakietowy obrony punktowej.
7. **T+20 s.** Uszkodzony rajder wyłącza ciąg i dryfuje w pole asteroid. Kontakt słabnie i po 8 s zostaje znacznik ostatniej znanej pozycji. **Decyzja NT:** gonić i pulsować co 15 s, za każdym razem zdradzając pozycję ewentualnym posiłkom wroga, czy odpuścić i dokończyć misję.
