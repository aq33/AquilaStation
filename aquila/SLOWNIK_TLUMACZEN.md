# Słownik tłumaczeń Aquili

Wspólne zasady i terminy do tłumaczenia gry na polski. Rozdział 01 jest nadrzędny. Hasła w pozostałych rozdziałach szukaj po angielskim terminie (Ctrl+F / grep).

# 01. Zasady i konwencje tłumaczenia (Aquila / NSV13)

Ten dokument jest nadrzędny wobec słowników tematycznych. Reguły spisałem na podstawie tego, jak robią to już przetłumaczone teksty w `aquila/`, `code/` i `nsv13/` (głównie commit aq33/AquilaStation#395 i późniejsze). Liczby w nawiasach podają, ile razy dany wariant występuje dziś w kodzie, czyli który wygrywa.

Repo: ``. Ścieżki `plik:linia` odnoszą się do tego drzewa.

---

## 0. Pięć rzeczy najważniejszych

1. **Tłumaczysz tylko tekst, który widzi gracz.** Klucze, id, ścieżki, nazwy akcji, wartości porównywane w kodzie i wszystko, co trafia do zapisów (prefs, DB, config), zostaje bez zmian (rozdz. 6).
2. **Czas teraźniejszy i konstrukcje bez odmiany wstawek.** `[user]`, `[src]` i `[I]` zawsze wstawiają mianownik, więc zdanie układasz tak, żeby mianownik pasował (rozdz. 2).
3. **Makra `\the`, `\a`, `\an`, `\The`, `\A` usuwasz, a `\improper` i `\proper` zostawiasz** (rozdz. 3).
4. **Nazwy reagentów tłumaczysz, ale `ckey()` usuwa polskie znaki**, przez co dwie nazwy mogą dać ten sam klucz (rozdz. 6.3). Sprawdzaj to.
5. **Nie zmieniasz `set name` ani `set category` verbów.** Polską nazwę dopisujesz w `tgui/packages/tgui-panel/stat/translations.js` (rozdz. 4).

---

## 1. Forma, styl, interpunkcja

### 1.1 Zwracanie się do gracza
- Do gracza mówimy **na „ty”, w 2. osobie liczby pojedynczej, w czasie teraźniejszym**. Zaimki „twój” i „ci” piszemy małą literą (w środku zdania „twój” 945 razy, „Twój” 1 raz; „ci/cię” 1290, „Ci/Cię” 7).
  - dobrze: `"Napełniasz [W]."`, `"Wciąż płoniesz!"`, `"Twoja ręka wpada w spazmy!"` (na początku zdania wielka litera, bo zaczyna zdanie)
  - źle: `"Napełniłeś [W]."`, `"Państwo napełniają…"`, `"Napełnij Twój [W]"`
- Formy „wy”, „Pan/Pani” i „Proszę…” są tylko w tekstach fabularnych (ogłoszenia Centrali, listy). „Wasz/Wasza” (22) odnosi się do załogi jako grupy, na przykład w `priority_announce`.
- W instrukcjach, podpowiedziach, tooltipach i na przyciskach używamy **trybu rozkazującego**: „Kliknij” (84), „Naciśnij” (14), „Użyj”, „Wysuń”. Bezosobowe „Należy” (8) stosujemy rzadko.
- Przymus wyrażamy przez „Musisz…” (205), a nie „Należy…”.
- Czas przeszły w 2. osobie: jeśli się da, zamień go na teraźniejszy („Tracisz przytomność”, a nie „Straciłeś przytomność”). Jeśli się nie da, przyjęła się forma męska `-łeś` (321 razy, `-łaś` 1 raz). Nie wstawiaj zapisu „ł(a)”, bo ten jest tylko w komunikatach dla adminów (19).

### 1.2 Komunikaty w czacie (span_*)
| span | ton | zakończenie (istniejące) |
|---|---|---|
| `span_notice` / `notice` | neutralna informacja | kropka (222 z kropką, 2 bez) |
| `span_warning` | ostrzeżenie, odmowa | `!` (174) albo `.` (120), zależnie od tonu oryginału |
| `span_danger` / `span_userdanger` | atak, obrażenia | prawie zawsze `!` (153 do 57) |
| `span_boldannounce`, `span_big`, ogłoszenia | jak w oryginale | jak w oryginale |

- Zachowaj znak końcowy oryginału: `!` zostaje `!`, `...` zostaje `...` (trzy kropki, 1847 do 4 dla `…`).
- Nie zmieniaj klasy spanu i nie dodawaj ani nie usuwaj tagów HTML.
- Para w `visible_message(widzowie, ty)`: pierwszy tekst jest w 3. osobie z `[user]`, drugi w 2. osobie:
  - `source.visible_message(span_warning("[source] rzuca się szarżą!"), span_danger("Rzucasz się szarżą!"))`
- Wstawka na początku zdania zostaje taka, jaka jest, małą literą: `"[src] wpatruje się w [commander]."` (85). Nie dopisuj `capitalize()` (użyte 2 razy).

### 1.3 Cudzysłowy, myślniki, skróty
- W nowym tekście używaj **polskich cudzysłowów „…”** (317). W DM piszesz je wprost, bez escape: `"Tę cechę można wykryć, „wyczuwając” artefakt."`
  - `\"…\"` (137) zostaje tylko tam, gdzie jest już w oryginale, czyli w nazwach własnych w `name`, na przykład `"\improper APLU MK-I \"Ripley\""`, bo kod porównuje tę nazwę (rozdz. 6).
- Myślnik w zdaniu: ` – ` (półpauza ze spacjami, 88). Wariant ` - ` (388) też występuje i jest akceptowany. Nie poprawiaj go masowo w cudzych liniach.
- Liczby i jednostki opisuje rozdział 8.

### 1.4 Wielkie litery w `name`
| co | konwencja (istniejąca) | przykłady |
|---|---|---|
| przedmioty, maszyny, struktury, rośliny, jedzenie | **mała litera**, chyba że to nazwa własna lub marka | `konsola zamówień`, `olej spożywczy`, `łamacz serc`, `reklamówka z Biedronki`, `zapalniczka Zippo` |
| obszary (`/area`) | **Każdy Wyraz Wielką** | `Korytarz Dowództwa`, `Górna Pracownia Chemiczna` |
| antagoniści, role, statusy, alerty HUD, zdolności, akcje, tytuły okien | **wielka pierwsza litera, reszta jak w zdaniu** | `Kultysta`, `Ofiara prania mózgu`, `Odwodniony`, `Zbierz armię`, `Panel gry` |
| reagenty | **wielka pierwsza litera, reszta jak w zdaniu**, marki z wielkich liter | `Bikarydyna`, `Kwas siarkowy`, `Kosmiczna Cola`, `Dylatacja czasu` |
| tablice ostrzegawcze (`signs`) | WIELKIE LITERY z `\improper` | `"\improper WYSOKIE NAPIĘCIE"` |
| emotki (`/datum/emote` name) | tryb rozkazujący, mała litera | `śmiej się`, `kiwnij głową` |

Uwaga: nazwa przedmiotu zaczynająca się od wielkiej litery jest dla BYOND-a nazwą własną (rozdz. 3).

---

## 2. Odmiana i rodzaj przy wstawkach `[src]`, `[user]`, `[target]`, `[I]`

### 2.1 Zasada główna
Wstawka `[x]` daje zawsze **nazwę w mianowniku** („konsola zamówień”, „Jan Kowalski”). Polszczyzna potrzebuje biernika, dopełniacza i narzędnika, więc zdanie układa się tak, żeby forma mianownikowa brzmiała naturalnie. Utrwaliły się cztery sposoby. Używaj ich w tej kolejności:

1. **Wstawka jako podmiot w czasie teraźniejszym.** Czasownik w 3. osobie nie zależy od rodzaju.
   - dobrze: `"[user] kończy spawać [src]."`, `"[P] odbija się od [src]!"`
   - źle: `"[user] skończył spawać [src]."` (dla kobiety to błąd)
2. **Wstawka jako dopełnienie po czasowniku lub przyimku.** Czytelnik akceptuje nazwę nieodmienioną, tak przyjęło się w całym kodzie. Najczęstsza konstrukcja to `za pomocą [I]` (223).
   - `"[user] uderza [src] za pomocą [I]!"` (`code/_onclick/item_attack.dm:230`)
   - `"[user] [message_verb] [src][message_hit_area], używając [I]!"` (`item_attack.dm:311`)
   - `"Ręka [owner] wpada w spazmy!"`, `"Skóra [L] zaczyna się nagrzewać"` (dopełniacz z nazwą w mianowniku)
3. **Dwukropek** po rzeczowniku albo czasowniku, gdy nazwa i tak brzmiałaby źle. Konstrukcja jest bardzo częsta (`na: [`, `z: [`, `w: [` po około 60 razy):
   - `"Zyskujesz zdolność: [src]."`, `"[carbon_owner] wymiotuje własnym organem: [removing_organ]!"`, `"Czujesz smak: [text_output]."`, `"pigułka: [initial(reagent.name)]"`
4. **Nawias**, gdy nazwę trzeba „przypiąć” do zaimka (598 wstawek w nawiasie):
   - `"[user] przygląda się komuś ([target]), czytając jakąś księgę."`, `"protokół osadzenia ([desired_name])"`, `"zdeformowany pocisk ([caliber])"`

### 2.2 Rodzaj: czego unikać
- **Przymiotnik lub imiesłów uzgadniany z wstawką** to zawsze błąd, bo rodzaj nazwy jest nieznany:
  - źle: `name = "główny [name]"` (`aquila/code/modules/research/master_server.dm:51`), `" <span class='warning'>zakrwawiony</span> "` (`code/datums/elements/decals/blood.dm:47`), `"Obraz [number] (wykonał: [loc.name])"` (`code/modules/photography/camera/silicon_camera.dm:51`)
  - dobrze: `"główna jednostka: [name]"`, `"Obraz [number] (autor: [loc.name])"`, `"[name] (ślady krwi)"`. Wariant `"[name] (główny)"` też odpada, bo dalej uzgadnia rodzaj.
- **Nazwy złożone z angielskiego prefiksu** (`"fried [name]"`, `"broken [name]"`, `"[name] steak"`, `"[name] core"`, `"[name] stump"`) przerabiaj na rzeczownik główny z dopowiedzeniem albo na dwukropek:
  - `"slice of [x]"` → `"plaster: [x]"`, `"[x] steak"` → `"stek: [x]"`, `"[name] core"` → `"rdzeń anomalii: [name]"`, `"fried [x]"` → `"[x] po usmażeniu"`, `"broken [x]"` → `"[x] (uszkodzenie)"` albo `"zepsute: [x]"`, `"[x] stump"` → `"pniak: [x]"`
- **Obiekty (`/obj`) mają `gender = NEUTER`** albo nic sensownego, więc `plec()` dla przedmiotu zawsze zwraca formę domyślną. Dla przedmiotów zostaje tylko szyk zdania.
- **Mob z płcią** (człowiek, `[user]`, `[H]`): jeśli przymiotnika ani czasu przeszłego nie da się obejść, użyj `plec()`:
  - `"[owner.name] [plec(owner.current, "ochronił", "ochroniła")] swoją randkę"` (`code/modules/antagonists/valentines/valentine.dm:56`)
  - `plec(ply.current, "zginął", "zginęła", "zginęło")` (`code/__HELPERS/roundend.dm:655`)
  - Istniejące opisy w `examine` człowieka są pisane w rodzaju męskim („roztrzęsiony”, „Oczy zasłania mu”). Nie przerabiaj ich masowo, ale w nowo tłumaczonych liniach wolno użyć `plec()`.

### 2.3 Polskie helpery (używaj, nie twórz nowych)
`aquila/code/__HELPERS/polish.dm` i `aquila/code/__HELPERS/pronouns.dm`:

| helper | do czego | przykład |
|---|---|---|
| `plec(atom, m, ż, n, mn)` | forma zależna od `gender`; brakujące formy przechodzą w męską | `plec(user, "zrobił", "zrobiła")` |
| `mob.p_jego(cap)` | jego/jej/ich | `"[user] traci [user.p_jego()] równowagę"`, choć zwykle lepszy jest zaimek „swój” |
| `mob.p_je(cap)` | go/ją/ich/je | `"Pomagasz [M] wstać i stawiasz [M.p_je()] na nogi."` |
| `strefa_pl(zone, biernik)` | nazwa części ciała z `BODY_ZONE_*` lub `parse_zone()` | `"w [strefa_pl(zone, TRUE)]"` daje „w lewą rękę” |
| `attack_verb_pl(verb)` | czasownik ataku gatunku (klucz angielski) | `"[user] [attack_verb_pl(verb)] [target]"` |
| `get_security_level_pl()` | polska nazwa poziomu alarmu | (`get_security_level()` zwraca klucz angielski) |
| `english_list(list)` | już po polsku: „a, b i c”, pusta lista daje „nic” | `code/__HELPERS/_lists.dm:156` |

**Nie dopisuj nowych procek do `polish.dm` w swoim kawałku.** Pracuje równolegle kilkunastu agentów, więc skończyłoby się konfliktem przy scalaniu. Potrzebny helper zgłoś koordynatorowi.

### 2.4 Angielskie helpery zaimków po tłumaczeniu
`p_they()`, `p_their()`, `p_them()`, `p_s()`, `p_es()`, `p_have()`, `p_are()`, `p_do()`, `p_were()`, `p_theyre()` (`code/__HELPERS/pronouns.dm`) **zwracają angielskie słowa**, a w polskim zdaniu są błędem:
- źle (dziś w kodzie, do poprawy przy okazji): `"[owner.p_they(TRUE)] lśni delikatną bielą."` (`aquila/code/modules/antagonists/heretic/magic/realignment.dm:60`), `"[owner.p_their(TRUE)] ciało przecinają żyły…"` (`aquila/code/datums/mutations/tg_core/golem_effects.dm:119`), `"rozcinając [victim.p_their()] obraz"` (`aquila/code/modules/antagonists/heretic/items/heretic_necks.dm:314`)
- Co z nimi zrobić:
  - `p_they()` jako podmiot usuń (podmiot domyślny) albo wstaw `[owner]`: `"[owner] lśni delikatną bielą."`
  - `p_their()` zamień na „swój/swoja/swoje”, jeśli odnosi się do podmiotu, a w pozostałych wypadkach na dopełniacz z nazwą: `"rozcinając obraz [victim] na dwoje"`. `p_jego()` zostaw na rzadkie przypadki.
  - `p_them()` zamień na `p_je()` albo przeformułuj zdanie.
  - `p_s()`, `p_es()`, `p_have()`, `p_are()`, `p_do()` **usuń**, bo polska koniugacja od nich nie zależy.
- Makra tekstowe BYOND `\he`, `\his`, `\him`, `\she`, `\her`, `\himself`, `\hers` są tak samo angielskie. Usuń je, postępując jak wyżej.
- Makro `\s` (angielska liczba mnoga po liczbie) usuń. Liczba mnoga opisana jest w rozdz. 8.

---

## 3. Makra BYOND `\the`, `\a`, `\an`, `\The`, `\A`, `\improper`, `\proper`

| makro | co robi | reguła (istniejąca praktyka) |
|---|---|---|
| `\the`, `\The` | „the” przed nazwą pospolitą | **usuń** (commit #395 usunął wszystkie; w polskich liniach jest 0 wystąpień) |
| `\a`, `\an`, `\A`, `\An` | „a/an” przed nazwą pospolitą | **usuń** |
| `\improper` | wymusza nazwę pospolitą mimo wielkiej litery | **zostaw** dokładnie tam, gdzie był (295 w `aquila/`, także przy polskich tablicach WIELKIMI LITERAMI). Nie dodawaj nowych. |
| `\proper` | wymusza nazwę własną | **zostaw** |
| `\roman`, `\Roman`, `\icon`, `\ref`, `\n`, `\t`, `\"`, `\[`, `\\` | formatowanie i escape | **zostaw**, to nie jest tekst |

- dobrze: `"Zaczynasz czytać [src]..."` zamiast `"You start reading \the [src]..."`
- dobrze: `"[deity_name] przemawia przez [src] i podpala cię…"` zamiast `"…channels through \the [src]…"`
- **Znany problem do załatwienia raz, centralnie (przez właściciela `code/game/atoms.dm`):** `get_examine_name()` (`code/game/atoms.dm:547-558`) nadal wstawia `\a [src]` i angielskie `"a"`/`"some"`/`"That's "`. Przy polskich nazwach pisanych małą literą daje to w opisie człowieka coś w rodzaju „Ma na sobie a kombinezon”. Podobnie działa `\an [dna.species.name]` w `code/modules/mob/living/carbon/human/examine.dm:20` i `"a"`/`"some"` w `code/datums/elements/decals/blood.dm:46`. Po poprawce `get_examine_name()` ma zwracać samą nazwę, a `"That's "` ma się stać `"To "`. Zmiennej `article` na atomach nie ustawiaj w polskich tekstach.

---

## 4. Verby: `set name`, `set category`, `set desc`; skróty klawiszowe

### 4.1 Reguła
- **`set name`: nie zmieniaj** w istniejących verbach (dziś 517 z 551 jest po angielsku; polskie nazwy mają tylko nowe verby Aquili i bloba). Polską nazwę do wyświetlania **dopisz do `VERB_NAMES`** w `tgui/packages/tgui-panel/stat/translations.js`. Plik ma około 274 wpisy `'English Name': 'Polska nazwa'`, a brak wpisu oznacza, że wyświetla się nazwa oryginalna.
- **`set category`: nie zmieniaj.** Jest kluczem zakładki panelu, a tłumaczenie trafia do `TAB_NAMES` w tym samym pliku.
  - Odrzucony wariant: `set category = "Działo Gaussa" // AQ EDIT` w DM. Właściwa forma to `'Gauss gun': 'Działo Gaussa'` w `TAB_NAMES`, które już istnieje.
- **`set desc` tłumacz** (44 z 272 już jest po polsku). To tylko podpowiedź.

### 4.2 Dlaczego nie wolno ruszać nazw verbów
Verby są wywoływane po nazwie w postaci komendy: małe litery, spacje zamienione na `-`:
- panel statystyk: `winset(client, null, "command=[replacetext(verb_name, " ", "-")]")` (`code/modules/mob/mob_stat.dm:305`), czyli zakładki wysyłają angielską nazwę,
- `interface/skin.dmf`: `adminhelp`, `hotkeys-help`, `changelog`, `rules`, `wiki`, `forum`, `github`, `report-issue`, `discord`, `donate`, a w przyciskach czatu `!say`, `!me`, `!ooc`,
- `code/modules/client/verbs/input_box.dm:121-122`: `say`, `.say`, `me`, `.me`, `.cancel_typing`,
- `aquila/code/modules/escape_menu/escape_menu.dm:209`: `command=Pray`,
- TGUI: `Byond.command('.quit')`, `` `wiki ${...}` ``, `.reconnect`, `.url`,
- gracze wpisują `say`, `me`, `ooc`, `looc`, `pray`, `adminhelp` z pamięci.

Verby obiektowe z menu prawego przycisku (`set src in view()` / `oview()`) dalej będą pokazywać angielskie `set name`. Na razie przyjmujemy to świadomie. Ewentualne wyjątki wymagają decyzji koordynatora i testu w grze, bo nie wiadomo, czy polskie znaki w komendzie `Nazwa-verba` działają w każdym miejscu.

### 4.3 Skróty klawiszowe (`code/datums/keybinding/`, `aquila/code/datums/keybinding/`)
- `name = "get_help"` to **klucz** (zapisany w preferencjach gracza, używany w `GLOB.keybindings_by_name`). Nie tłumacz go.
- `full_name` i `description` **tłumacz** (to już zrobiono: `full_name = "Pomoc"`, `"Ruch na północ"`).
- `key = "F1"` i `category = CATEGORY_CLIENT` to dane.

### 4.4 Emotki
- `key` i `key_third_person` (`"nod"`, `"nods"`) to komendy wpisywane przez gracza (`*nod`). **Nie tłumacz ich.**
- `message`, `message_param` (z placeholderem `%t`) i `name` (`aquila/code/datums/emote_names.dm`) **tłumacz**: `message = "kiwa głową"`, `message_param = "kiwa głową do %t"`.

---

## 5. TGUI (`tgui/packages/**/*.tsx|jsx|ts|js`)

### 5.1 Tłumaczysz
- tekst w JSX między tagami, `title=` w `<Window>` i `<Section>`, `label=` w `LabeledList.Item`, `content=`, `tooltip=`, `confirmContent=`, `placeholder=`, teksty w `NoticeBox` i `Modal`,
- stringi w obiektach, które służą tylko do wyświetlania (opisy kart, nagłówki tabel),
- czwarty argument `new(user, src, "Interfejs", "Tytuł")` w DM, czyli tytuł okna: `ui = new(user, src, "HorrorChemicals", "Chemikalia horroru")`.

### 5.2 Nie ruszasz
- nazw akcji: `act('sync_rnd')`, `act('build', { ref: …, amount })`,
- kluczy parametrów i danych: `data.selectedReagent`, `params["reagent"]`, `{ reagent_id: … }`,
- **nazwy interfejsu**, czyli trzeciego argumentu `new(user, src, "PersonalCrafting", …)`, nazw plików i nazw komponentów,
- wartości `icon="…"`, `color="…"`, `className`, `key=`, wartości `useLocalState(…, 'tab', 'Main')`, jeśli porównujesz je dalej,
- **literałów porównywanych z danymi z DM**: `value.status === 'shutdown'` (`FTLComputerModular.tsx:51`), `data.mode === 'auto'` (`SpaceHeater.tsx:120`), `data.master_mode === 'secret'` (`AdminGamePanel.tsx:191`). Tłumaczysz tylko to, co się wyświetla: `{type === 'shuttle' ? 'Odlot' : 'Zrzuć bazę'}` (`AuxBaseConsole.tsx:209`).
- Jeśli DM wysyła angielski klucz i ten sam string jest wyświetlany, w TSX dodaj mapę wyświetlania (`const STATUS_PL = { shutdown: 'Wyłączony', … }`), a wartości w DM nie zmieniaj.
- `Byond.command(\`wiki Guide_to_chemistry#${reagent.name}\`)` (`tgui/packages/tgui/interfaces/common/ReagentLookup.jsx:24`) potrzebuje angielskiej kotwicy wiki. Po tłumaczeniu nazw reagentów link przestanie trafiać w kotwicę. Zostaw to i zgłoś koordynatorowi.

### 5.3 Styl w TGUI
- Przyciski i etykiety piszemy jak zdanie: „Wysuń zlewkę”, a nie „Wysuń Zlewkę”.
- Jednostka reagentów to `j.`. W TGUI zostały resztki `u` (`unit="u"` 14 razy, `{beakerMaxVolume} u`), więc zamieniaj je na `unit="j."`. Pozostałe jednostki fizyczne (`kPa`, `K`, `%`, `s`, `kHz`) zostają.
- Liczba mnoga przy liczbie: na wzór lokalnego `pluralPL(count, one, few, many)` w `tgui/packages/tgui/interfaces/AntagInfoHeretic.tsx:47` (albo `plural` w `CTFPanel.tsx:36`) wolno skopiować helper do pliku. Wspólnego helpera w `common/` nie twórz w swoim kawałku.
- Po zmianach w TGUI trzeba przebudować paczki (`BUILD.bat`), bo bundle nie są w repo.

---

## 6. NIE TŁUMACZ: tekst jako klucz

### 6.1 Wzorce, w których string jest kluczem
| wzorzec | przykład | co robić |
|---|---|---|
| porównanie `==`, `!=`, `in`, `switch/if("…")` | `if(user.name == "Unknown")` (`code/game/machinery/camera/camera.dm:280`) | jeśli porównywana wartość jest też wyświetlana, tłumacz obie strony naraz w tym samym commicie albo nie tłumacz żadnej |
| `findtext`, `replacetext`, `regex(…)` | `regex("stop\|wait\|stand still…")` (`code/modules/surgery/organs/vocal_cords.dm:214`) | nie ruszaj. Słowa wyzwalające w mowie (voice of god i podobne) to osobne zadanie zmieniające rozgrywkę, nie tłumaczenie |
| klucze list asocjacyjnych używane w lookupach | `filtered_uplink_items[I.category][I.name] = I` (`code/modules/uplink/uplink_items.dm:18`) | wartości wyświetlane tłumacz, klucze tylko wtedy, gdy zmieniasz wszystkie miejsca użycia |
| `href_list["…"]`, `params["…"]`, `action` w `ui_act` | `if(reagent.name == action)` (`nsv13/code/game/objects/items/robot/hypo.dm:238`) | nie ruszaj |
| ścieżki plików, ikon i dźwięków, `icon_state`, `item_state`, `worn_icon_state` | `'aquila/icons/hud/radial_pets.dmi'`, `"follow"` | nie ruszaj |
| `id`, `config_tag`, `ROLE_*`, `TRAIT_*`, `BB_*`, sygnały, `category` designów i craftingu | `ROLE_TRAITOR "Traitor"`, `category = list("initial","Tools")`, `CAT_WEAPONRY "Weaponry"` | nie ruszaj (bany, prefs, DB, filtry maszyn) |
| SQL, `SSblackbox.record_feedback("…", "klucz", …)` | klucze blackboxa | nie ruszaj. Gdy wartość pochodzi z `name` (`initial(I.name)`, `uplink_items.dm:357`), statystyki zmienią klucz, co akceptujemy |
| config i wartości zapisywane w preferencjach | `#define GBACKPACK "Grey Backpack"` (`code/__DEFINES/preferences.dm:148`), `PREF_SUIT "Jumpsuit"`, `UPLINK_PDA "PDA"` | nie ruszaj; tłumacz przy wyświetlaniu |
| `name` gamemode'u i celu jako klucz | `SSticker.mode.name == "traitor"` (`code/modules/antagonists/traitor/datum_traitor.dm:418`), `objective.name == "gimmick"` (`code/datums/mind.dm:413`) | nie ruszaj |
| `name` w `/datum/keybinding` | `name = "get_help"` | nie ruszaj (rozdz. 4.3) |
| `key` emotki | `key = "nod"` | nie ruszaj (rozdz. 4.4) |
| klucze JSON w `strings/` oraz `@pick(klucz)` | `"ionspecies": [ … ]`, `@pick(add_name)` | nie ruszaj (rozdz. 7) |
| placeholdery | `%t`, `%name%`, `%SOMETHING%`, `$1`, `[...]`, `${...}`, `<br>`, `\n` | zostaw dokładnie tak, jak są |
| unit testy | rozdz. 6.4 | zmieniaj razem z tekstem |

### 6.2 `name` i `desc`, których tłumaczenie coś psuje (konkretne miejsca)
- `code/datums/components/twohanded.dm:210` i `:266`: nazwa dostaje `" (Wielded)"`, a potem kod szuka tego dopisku przez `findtext(name, " (Wielded)", -10)`. Tłumacz oba miejsca naraz (na przykład `" (oburącz)"`) i licz długość **w znakach**, przez `findtext_char`/`copytext_char`. W BYOND 515 `length("żółw")` daje 7 bajtów, a `length_char` daje 4.
- `code/game/mecha/equipment/tools/work_tools.dm:403`: `M.name != "\improper APLU MK-I \"Ripley\""` porównuje z `name` z `code/game/mecha/working/ripley.dm:3`. Te dwie linie zmieniaj razem albo żadnej.
- `code/game/machinery/firealarm.dm:371`: `A.name == "Space"` dotyczy obszaru `/area/space` (`code/game/area/areas.dm:8`). Zmiana nazwy obszaru wymaga zmiany porównania.
- `nsv13/code/modules/recycling/replicatorDS.dm:65`: `location.name == "Hydroponics"` **jest już zepsute**, bo obszar nazywa się dziś „Hydroponika”. To przykład tego, co się dzieje, gdy tłumaczy się jedną stronę. Przy okazji popraw porównanie na `istype(location, /area/hydroponics)`.
- `code/modules/antagonists/cult/runes.dm:590`: `user.name == "Herbert West"`; `code/modules/games/cas.dm:70`: `choice.name == "Blank Card"`; `aquila/code/modules/detectivework/crime_scene/chalk.dm:24`: `old.name == "obrys ciała"` (przykład porównania już po polsku).
- `"Unknown"` jako imię zamaskowanej postaci występuje w 85 miejscach, jest przypisywane i porównywane (`camera.dm:280`, `code/game/objects/items/devices/camera_bug.dm:263`). **Nie tłumacz tego literału.** W tekście wyświetlanym używamy „Nieznajomy” (`human/examine.dm:21`).
- Nazwy obszarów są kluczami w `GLOB.teleportlocs[AR.name]` (`code/game/area/areas.dm:133`) i muszą pozostać unikalne.
- Uplink: `name` przedmiotu musi być **unikalny w obrębie kategorii**, bo inaczej przedmiot znika ze sklepu. Kategorie `"Discounted Team Gear"` i `"Limited Stock Team Gear"` są literałami w `uplink_items.dm:34-43`, więc zmieniaj je razem albo wcale.
- **Wyposażenie (loadout):** `id = md5(display_name)` (`code/modules/client/loadout/loadout.dm:74`) jest kluczem zakupów w zapisach gracza. **`display_name` zostaje po angielsku**, a polska nazwa idzie do `GLOB.gear_names_pl` w `aquila/code/modules/client/loadout/loadout_names_pl.dm`.
- **Fryzury, zarost, bielizna (`sprite_accessory`):** `L[D.name] = D` (`code/modules/mob/dead/new_player/sprite_accessories.dm:37`) jest zapisywane w preferencjach. **`name` zostaje po angielsku**, a tłumaczenie trafia do `GLOB.accessory_names_pl` (`aquila/code/modules/client/accessory_names_pl.dm`).
- Programy NTOS: `filename` to klucz, `filedesc` to tekst do wyświetlenia. Węzły techweb i designy: `id` to klucz, `display_name`, `name` i `desc` to tekst. Paczki cargo: `group` jest kluczem grupowania (`code/modules/cargo/orderconsole.dm:145`), `name` i `desc` to tekst.
- Wartości `#define`, które już są po polsku i służą jednocześnie za klucz i za tekst (`JOB_NAME_* "Kapitan"`, `RADIO_CHANNEL_* "Ogólny"`, `EXOSCANNER_BAND_* "Pasmo absorpcji plazmy"`), **zostawiasz jak są**. Tytułu stanowiska nie wpisuj literałem, użyj makra.
- `alert()` i `tgui_alert()`: przyciski są zwracane i porównywane. Przyciski tłumacz razem z porównaniem: `list("Tak", "Nie")` i `!= "Tak"` (`aquila/code/datums/polls/candidate_poll.dm:70`). W 117 polskich alertach zostały przyciski `"Yes"`/`"No"`. Zamieniaj je tylko wtedy, gdy widzisz całe porównanie w tej samej procce.
- `input() in list(...)`, `tgui_input_list()`, `show_radial_menu()`: zwracają klucz wybranej opcji. Opcję tłumacz razem z każdym `if/switch` na ten wynik, tak jak w `aquila/code/modules/mob/living/simple_animal/heretic/star_gazer.dm:247` (`"Podążaj" = image(...)`).

### 6.3 Reagenty (`/datum/reagent`): szczególna ostrożność
- `GLOB.name2reagent[ckey(name)]` (`code/modules/reagents/chemistry/reagents.dm:5-10`) oraz `get_chem_id()` (`code/modules/reagents/chemistry/holder.dm:1300`) szukają reagentu po `ckey(name)`. Dispenser (`chem_dispenser.dm:270`), chem master (`chem_master.dm:241,319`), rury (`aquila/code/modules/plumbing/...`) i hypo borga (`hypo.dm:238`) liczą klucz z tej samej nazwy, więc samo tłumaczenie nazwy działa.
- **Pułapka:** `ckey()` **usuwa polskie litery** (sprawdzone na BYOND 515.1633): `ckey("Sól kuchenna")` daje `"slkuchenna"`, `ckey("Słód")` daje `"sd"`, a `ckey("Żółć")` daje `""`. Dwie nazwy różniące się tylko diakrytykami dają ten sam klucz i jeden reagent przestaje być dostępny w dispenserze bez żadnego błędu. Reguły:
  - nazwa reagentu musi mieć **co najmniej kilka liter ASCII** i być unikalna po `ckey`. Nazwy jednowyrazowe złożone głównie z polskich znaków uzupełnij drugim słowem albo wybierz inny wariant,
  - po przetłumaczeniu partii sprawdź kolizje (koordynator dopisze test na unikalność `ckey(name)` w `GLOB.name2reagent`).
- Reagent wyświetla się w mianowniku po skrócie: `"[R.volume] j. [R.name]"` (`code/game/atoms.dm:589`), `"pigułka: [initial(reagent.name)]"`. Nazwa ma więc działać w mianowniku bez kontekstu.
- `taste_description` i klucze `tastes = list("…" = 1)` w jedzeniu piszemy **w mianowniku** (`"metaforyczna sól"`, `"pomyje"`, `"soczyste mięso"`). Komunikat brzmi `"Czujesz smak: [x]."` (`code/modules/mob/living/taste.dm:31`).
  - Odrzucony wariant: biernik w kilku plikach Aquili (`"zgniłą miedź"`, `"chemiczną gorycz"`). Przy okazji zamień go na mianownik.
- `glass_name` i `glass_desc` (napoje) to tekst, tłumacz (dziś 0 z 209 jest po polsku).
- Nie ruszaj legacy id w `translate_legacy_chem_id()` (`chem_dispenser.dm:1-11`).

### 6.4 Unit testy sprawdzające tekst
Jeśli tłumaczysz tekst, który test porównuje, popraw test w tym samym commicie (uruchomienie testów opisuje `CLAUDE.md`). Przykłady:
- `aquila/code/modules/unit_tests/aquila_secret_chems.dm:49,56`: `rock_paper.name == "rock paper"`, `"gold paper"`,
- `aquila/code/modules/unit_tests/dakimakura.dm:21`: `daki.name == "Ian dakimakura"`,
- `aquila/code/modules/unit_tests/revenant.dm:82`: `!findtext(rev.name, " of ")`, czyli imię revenanta nie może być angielskie,
- teksty już polskie, których nie zmieniaj bez poprawienia testu: `aquila_screentips.dm:16-35` (`"Otwórz"`, `"Rozwałkuj"`, `"Naciśnij"`, `"Zmień tryb"`), `aquila_mouse_report.dm:23` (`"Zjedzone śmieci: 3"`), `aquila_wounds.dm:90` (`"nacięcie"`, `"skalpel"`),
- `"Nothing"` jako domyślny `explanation_text` (`break_machinery.dm:88`, `aquila_traitor_objectives.dm:59`) zostaje.

### 6.5 Logi i komunikaty dla adminów
| wywołanie | dziś po polsku | reguła |
|---|---|---|
| `log_game`, `log_admin`, `log_combat`, `log_world`, `investigate_log`, `log_runtime` | około 0 z 1900 | **nie tłumacz** |
| `stack_trace`, `CRASH`, `Fail()`, `TEST_ASSERT` (komunikat), `testing()`, `world.log` | około 0 | **nie tłumacz** |
| `message_admins` | 42 z 1300 | **tłumacz** (to czat adminów, czyli też gracze). Makra `ADMIN_LOOKUPFLW(...)`, `ADMIN_JMP(...)`, `key_name_admin(...)` zostają. Jeśli ten sam string lub zmienna idzie też do `log_*` (`var/msg = …; message_admins(msg); log_admin(msg)`), zostaw go po angielsku. |
| `priority_announce`, `minor_announce`, `notify_ghosts`, `deadchat_broadcast` | większość | **tłumacz** |
| teksty paneli admina (`code/modules/admin/topic.dm`, `randomverbs.dm`) | mało | **tłumacz** tekst linków i nagłówków, ale nie wartości `href` (`?_src_=holder;[HrefToken()];foo=bar`) |
| `addition = "…"` w `log_combat` | 2 | nie tłumacz |

---

## 7. Pliki `strings/`

`strings(plik, klucz)` (`code/__HELPERS/_string_lists.dm:22`) wczytuje JSON i zwraca `cache[plik][klucz]`. Klucz nie istnieje? Wtedy `CRASH`. Z tego wynikają trzy zasady: **klucze JSON zostają, wartości tłumaczysz**, a tokeny `@pick(klucz)` w wartościach zostawiasz bez zmian. Pliki `.txt` czyta `world.file2list()`: jedna linia to jeden wpis, więc nie łącz i nie dziel linii.

Gdy tłumaczysz listę, z której kod składa zdanie (na przykład `ion_laws.json`: `ionspecies`, `ionadjectives`, `ionobjects`), **zachowaj formę gramatyczną i wielkość liter wpisów, które w tej liście już są** (dla `ionspecies` to mianownik liczby mnogiej WIELKIMI LITERAMI).

| plik | użycie | decyzja |
|---|---|---|
| `tips.txt`, `sillytips.txt`, `dreamstrings.txt`, `science_dialogue.txt`, `abductee_objectives.txt`, `gimmick_objectives.txt`, `dept_gimmick_objectives.txt`, `target_gimmick_objectives.txt`, `anti_union_propaganda.txt` | tekst dla gracza | **tłumacz** dokończenie |
| `junkmail.txt` | treść listów-śmieci (`code/_globalvars/lists/flavor_misc.dm:234`), HTML i `%name%` | **tłumacz**, HTML i `%name%` zostają |
| `cas_white.txt`, `cas_black.txt` | karty gry „Cards Against Spess” (`code/modules/games/cas.dm`) | **tłumacz** (luźno, z zachowaniem humoru). Zostaw linię `Blank Card`, jeśli taka jest, bo `cas.dm:70` ją porównuje |
| `ion_laws.json`, `hallucination.json`, `heretic_influences.json`, `phobia.json`, `redpill.json`, `spy_objective.json`, `traumas.json`, `wanted_message.json`, `exodrone.json` | wartości to tekst | **tłumacz wartości**; klucze i `@pick(...)` zostają |
| `valentines.json` | treść walentynek (`VALENTINE_FILE`) | **tłumacz wartości** |
| `splash.json` | `desc` ekranu startowego (`code/game/turfs/closed/_closed.dm:77`) | **tłumacz wartości** |
| `exoadventures/*.json` | przygody dronów (`aquila/code/modules/explorer_drone/adventure.dm`) | tłumacz `adventure_name`, `description` węzła, `name` **wyboru** i `delay_message`. **Nie tłumacz** `name` **węzła**, bo to id, do którego odwołują się `starting_node` i `exit_node`. Nie ruszaj też `key`, `quality`, `required_site_traits` i `loot_categories`. Klucze `scan_band_mods` muszą być równe wartościom `EXOSCANNER_BAND_*` (już po polsku) |
| `revenant_names.json` | imię revenanta składane z `spirit_type` + `adverb` + `theme` (`revenant.dm:95-98`) | tłumacz razem z uzgodnieniem rodzaju (przymiotniki z `adverb` muszą pasować do każdego `spirit_type`, więc najlepiej wybrać rzeczowniki jednego rodzaju). Test `revenant.dm:82` zabrania `" of "` |
| `pirates.json` | części imion piratów i nazw statków (`PIRATE_NAMES_FILE`) | zostaw albo spolszcz ostrożnie: `beginnings` + `endings` są **sklejane bez spacji** |
| `station_names.txt`, `station_prefixes.txt`, `station_suffixes.txt` | generator nazw stacji i karta statutu (`code/__HELPERS/names.dm:55-87`) | tłumacz po uzgodnieniu formy z koordynatorem (sklejanie przymiotnik + rzeczownik) |
| `numbers_as_words.txt` | generator nazw stacji | dokończ tłumaczenie (liczebniki w mianowniku) |
| `greek_letters.txt`, `phonetic_alphabet.txt` | litery i kody (Alfa, Bravo…) | **nie tłumacz** |
| `names/*.txt` (`first*`, `last*`, `clown`, `ai`, `golem`, `moth_*`, `lizard_*` i inne) | listy imion | **nie tłumacz** (imiona; polskie listy już istnieją w `first_*`/`last_*`) |
| `names/adjectives.txt`, `adverbs.txt`, `verbs.txt`, `ing_verbs.txt` | generatory losowych nazw i haseł | **nie tłumacz** (to dane) |
| `1000_most_common.txt` | afazja: mowa ogranicza się do tych słów (`code/datums/brain_damage/mild.dm:193`) | **nie tłumacz** linia po linii. Docelowo trzeba podmienić plik na listę najczęstszych polskich słów, co jest osobnym zadaniem |
| `british_talk.json`, `canadian_replacement.json`, `french_replacement.json`, `italian_replacement.json`, `medieval_speech.json`, `owo_talk.json`, `spurdo_replacement.json` | akcenty: klucze to **angielskie słowa wyszukiwane w mowie** | **nie tłumacz** (zamienianie kluczy na polskie zmieniłoby mechanikę; to osobne zadanie) |
| `gizmo_words.txt` | sylaby głosu gizmo | **nie tłumacz** |
| `round_start_sounds.txt` | ścieżki `.ogg` | **nie ruszaj** |
| `clockwork_cult_changelog.txt` | nieużywany | pomiń |

---

## 8. Liczby, jednostki, liczba mnoga

- **Reagenty:** `[n] j.` (38 razy, wygrywa z „jednostek” 16 i „jedn.” 2). Skrót nie wymaga odmiany.
  - dobrze: `"Zawiera [volume] j. [R.name]."`, `"Objętość owocu: [total_volume] j."`
  - źle: `"[n] jednostek"` (dla 1 i 2–4 to błąd), `"[n]u"`, `"[n] units of"`
- **Inne policzalne rzeczy:** dwukropek albo skrót zamiast odmiany:
  - `"Ładunki: [charges]"`, `"Pozostało: [n]"`, `"×[amount]"` (7), `"[n] szt."` (5)
  - źle: `"Masz [n] ładunków"` (dla 2–4 to błąd)
- **Pieniądze:** `[n] kr.` (24) zamiast „kredytów” (25 wystąpień, ale ta forma się odmienia). Waluta Aquili to „aquilosy”, według słownika walut.
- **Czas:** `s`, `min`, `godz.` po liczbie (`"Czas wzrostu", "[x] s"`). Do formatowania czasu służy `DisplayTimeText()` (`code/__HELPERS/time.dm:71`). Ten helper jest **przetłumaczony tylko w części** i nadal zwraca `"second[s]"`, `"minute[s]"`, `"hour[s]"`, `"day[s]"` (linie 76, 83, 90, 96). Poprawi go raz właściciel `code/__HELPERS` (na `s`/`min`/`godz.`/`d.`), a ty nie pisz własnych wersji.
- **Wymagana pełna odmiana** (rzadko, na przykład w tekście fabularnym): reguła polska to 1, potem 2–4 (z wyjątkiem 12–14), potem 5+. W DM nie ma na to helpera, a w swoim kawałku go nie dodajesz (rozdz. 2.3), więc przeformułuj zdanie. W TGUI użyj `pluralPL` (rozdz. 5.3).
- Separatora dziesiętnego nie zmieniaj: liczby z DM wychodzą z kropką. Procenty zapisuj `[n]%` bez spacji, tak jak dziś.
- Jednostki fizyczne (`kPa`, `K`, `°C`, `W`, `kW`, `MJ`, `kHz`) zostają. „Joule” w tekście to „J”.

---

## 9. Lista kontrolna przed commitem

1. Czy w polskim zdaniu nie zostało `\the`, `\a`, `\an`, `\s`, `\his` ani `p_they()`/`p_their()`/`p_s()`? (`git diff | grep -E 'p_(they|their|them|s|es)\(|\\\\(the|a|an|s|his|he) '`)
2. Czy żaden przetłumaczony literał nie występuje gdzie indziej w `==`, `!=`, `findtext`, `switch` ani jako klucz listy? (`git grep -n '"stary angielski tekst"'` przed zmianą)
3. Czy nie zmieniłeś `set name`, `set category`, keybindingowego `name`, `key` emotki, `id`, `icon_state`, `act('…')` ani klucza JSON?
4. Czy nazwy reagentów są unikalne po `ckey()` i mają litery ASCII?
5. Czy przymiotnik albo czasownik w czasie przeszłym nie uzgadnia się z nieznanym rodzajem wstawki?
6. Czy znak na końcu, klasa spanu, HTML, `%placeholdery%` i `[wstawki]` są takie jak w oryginale?
7. Czy test, który porównuje ten tekst, jest poprawiony?
8. Czy kod się kompiluje (`dm.exe nsv13.dme`), a po zmianach w TSX czy TGUI się buduje?
9. Nie ruszaj istniejących polskich tekstów, jeśli nie łamią tych zasad (zasada z `CLAUDE.md`). Poprawki wymienione wprost w tym dokumencie (`p_they`, biernik w `taste_description`, `u` zamiast `j.`) są wyjątkiem.


# Sekcja 02: Przedmioty i technika

Zakres: narzędzia, broń i amunicja, ubrania i pancerze, plecaki i pojemniki, materiały i stacki, meble i struktury, maszyny, elektronika i energia, atmosfera i gazy, konstrukcja, górnictwo, jedzenie i napoje, botanika.

Źródła: historia gita (pary EN→PL z commitów tłumaczeniowych), obecne polskie nazwy typów w `aquila/` i core, ok. 41 tys. polskich tekstów w `.dm`/TGUI (zliczenia wariantów), porównanie drzew z korzeniem repo i `bee/master`.

Oznaczenia w kolumnie uwag:
- rodzaj: **m** (męski), **ż** (żeński), **n** (nijaki), **mn** (tylko liczba mnoga albo liczba mnoga w nazwie), **ndm** (nieodmienne).
- **istniejące**: tak już tłumaczono w kodzie. W nawiasie liczba wystąpień, jeśli była policzona. **nowe**: propozycja dla terminu, którego nikt jeszcze nie tłumaczył.
- „odrzucone: …”: warianty spotkane w kodzie, których nie używamy.

## 0. Zasady nazewnicze (obowiązują w całej sekcji)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| `name` przedmiotu | małą literą, jak w oryginale | Nazwy własne, marki i modele wielką. Prefiksy `\improper` i `\proper` zostają w ciągu bez zmian. |
| X's Y (np. captain's jacket) | Y + dopełniacz posiadacza (kurtka kapitana) | istniejące: „plecak kapitana”, „buty kapitana”, „hełm inżyniera”, „kurtka technika”. |
| departmental X (dział) | przymiotnik, jeśli jest naturalny: medyczny, inżynieryjny, górniczy, policyjny (przedmioty ochrony); w pozostałych przypadkach dopełniacz: chemii, genetyki, wirologii, botaniki, nauki, zaopatrzenia | istniejące: „plecak medyczny”, „plecak policyjny”, „plecak chemii”, „plecak genetyki”, „plecak wirologii”, „plecak botaniki”, „plecak nauki”. |
| security (dział, teksty ogólne) | ochrona; „... ochrony” | istniejące (99×): „HUD ochrony”, „akta ochrony”, „implant ochrony”. |
| security X (ubranie, sprzęt policjanta) | X policyjny / policyjna | istniejące: „plecak policyjny”, „mundur policyjny”, „Mundurownia Policyjna”, „Zbrojownia Policyjna”, „taśma policyjna”. Zawody ochrony to Policjant, Komendant, Naczelnik, Aspirant. |
| Syndicate X | X Syndykatu | m; istniejące (245×), np. „zestaw słuchawkowy Syndykatu”, „uśpiacz Syndykatu”. |
| Nanotrasen X | X Nanotrasen | nazwa firmy po rzeczowniku nieodmienna; istniejące: „kapsuła zaopatrzeniowa Nanotrasen”. W zdaniu odmiana „Nanotrasenu” dopuszczalna. |
| CentCom X | X Centrali | istniejące (111×); odrzucone: „CentComu” (11×). |
| R&D | B+R | istniejące (9×), np. „konsola B+R”. |
| AI (w nazwach przedmiotów) | SI | istniejące (132×), np. „rdzeń SI”, „konsola sterowania SI”. |
| bluespace X | X bluespace (po rzeczowniku, nieodmienne) | istniejące: „kryształ bluespace”, „pamięć bluespace”, „kieszeń bluespace”. Przymiotnik „bluespace'owy” tylko tam, gdzie już jest (botanika: „bluespace'owy banan”). |
| space X (przymiotnik) | kosmiczny X | istniejące: „hełm kosmiczny”, „skafander kosmiczny”, „Kosmiczny tytoń”. |
| Space Brand (marka) | Kosmiczna/Kosmiczny + marka, albo przedrostek Kosmo- | zasada z planu tłumaczenia: Space Cola → Kosmiczna Cola; istniejące „Kosmo-hełm”, „Kosmo-Buty”. |
| X Crate (cargo) | skrzynia z X / skrzynia: X | istniejące: „Skrzynia z cateringiem”, „Skrzynia ze złomowiska”, „Skrzynia z krzewami”. |
| X (Machine Board) | X (płytka maszyny) | istniejące, np. „analizator roślin (płytka maszyny)”. |
| X (Computer Board) | X (płytka komputera) | istniejące, np. „konsola sterowania SI (płytka komputera)”. |
| Machine Design (X Board) | Projekt maszyny (X) | istniejące: „Projekt komputera (terminal maszyn hydroponicznych)”. Odrzucone: „Płytka X” jako nazwa projektu. |
| Computer Design (X) | Projekt komputera (X) | istniejące. |
| Exosuit Weapon (X) | Broń egzoszkieletu (X) | istniejące (10×). |
| Exosuit Module (X) | Moduł egzoszkieletu (X) | istniejące (3×). |
| Cyborg Upgrade (X) | Ulepszenie cyborga (X) | nowe. |
| Nanite Program (X) | Program nanitów (X) | nowe. |
| X slice (pizza, ciasto, placek) | kawałek X | m; istniejące (47×): „kawałek pizzy mięsnej”. |
| X slice (chleb, bochenek) | kromka X | ż; nowe. |
| X slice (owoc, ser, mięso cienko) | plaster / plasterek X | m; istniejące: „plaster cytryny”, „plasterek jabłka”. |
| glass of X | szklanka X | ż; istniejące: „szklanka wody”. |
| shot of X | kieliszek X | m; istniejące: „kieliszek amareny”. |
| pint / mug of X | kufel X | m; istniejące: „kufel zielonego…”. |
| can of X | puszka X | ż; istniejące: „puszka sardynek”. |
| bottle of X | butelka X | ż; istniejące. |
| carton of X | karton X | m; istniejące: „karton pierogów”. |
| box of X | pudełko X / pudełko z X | n; istniejące: „pudełko dekoracji barowych”, „pudełko z butelkami”. |
| pack / packet of X (przyprawa) | saszetka X | ż; nowe. |
| sack of X | worek X | m; istniejące: „worek z podłożem”. |
| bunch of X | kiść X (winogrona), garść X (jagody) | ż; istniejące: „kiść wisienek”. |
| seeds (nazwa paczki) | nasiona: X / zarodniki: X | istniejące w całej botanice (np. „nasiona: pomidor”, „zarodniki: kurka”). |

## 1. Narzędzia

| EN | PL | rodzaj/uwagi |
|---|---|---|
| tool | narzędzie | n; istniejące |
| toolbox | skrzynka narzędziowa | ż; istniejące (4×); odrzucone: „skrzynka z narzędziami” (4×, dopuszczalne w opisach) |
| mechanical toolbox | mechaniczna skrzynka narzędziowa | ż; nowe |
| electrical toolbox | elektryczna skrzynka narzędziowa | ż; nowe |
| emergency toolbox | awaryjna skrzynka narzędziowa | ż; nowe |
| toolbelt | pas na narzędzia | m; istniejące (2×) |
| screwdriver | śrubokręt | m; istniejące (43×); odrzucone: wkrętak |
| wrench | klucz | m; istniejące (94×). W nazwie przedmiotu: „klucz nastawny” (nowe), w komunikatach wystarczy „klucz” |
| welding tool / welder | spawarka | ż; istniejące (50×) |
| emergency welding tool | awaryjna spawarka | ż; nowe |
| industrial welding tool | przemysłowa spawarka | ż; nowe |
| experimental welding tool | eksperymentalna spawarka | ż; nowe |
| crowbar | łom | m; istniejące (53×) |
| wirecutters | przecinak | m; istniejące (5×); w nazwie „przecinak do drutu”; odrzucone: kombinerki, szczypce |
| multitool | multitool | m; istniejące (63×), odmiana: multitoola, multitoolem |
| analyzer (gas) | analizator gazów | m; istniejące („analizator” 33×) |
| T-ray scanner | skaner T-ray | m; nowe |
| jaws of life | szczęki życia | mn; nowe |
| power drill / hand drill | wiertarka ręczna | ż; nowe |
| RCD (rapid construction device) | RCD | n/ndm (mówimy „RCD”, rodzaj m przy uzgodnieniu: „RCD jest pełny”); istniejące (63×) |
| RPD (rapid pipe dispenser) | RPD | ndm; istniejące (2×) |
| RLD / RTD | RLD / RTD | ndm; nowe |
| matter cartridge | wkład z materią | m; nowe |
| inducer | induktor | m; istniejące (1×) |
| hand labeler | etykieciarka | ż; nowe |
| tape measure | miarka | ż; nowe |
| extinguisher / fire extinguisher | gaśnica | ż; istniejące (16×) |
| fire axe | topór strażacki | m; istniejące (3×) |
| rolling pin | wałek do ciasta | m; istniejące („wałek” 4×) |
| shovel | łopata | ż; istniejące |
| spade | łopatka | ż; istniejące |
| hatchet | toporek | m; istniejące (1×) |
| scythe | kosa | ż; nowe |
| cultivator | kultywator | m; nowe |
| bucket | wiadro | n; nowe |
| mop | mop | m; istniejące (5×) |
| broom / push broom | miotła | ż; istniejące (1×) |
| soap | mydło | n; istniejące (5×) |
| plunger | przepychacz | m; nowe |
| hammer | młotek | m; nowe |
| sledgehammer | młot burzący | m; istniejące |
| forging hammer | młot kowalski | m; istniejące |
| saw / hacksaw | piła / piła do metalu | ż; nowe |
| circular saw | piła tarczowa | ż; nowe |
| chainsaw | piła łańcuchowa | ż; nowe |
| tweezers / hemostat | szczypce chirurgiczne | mn; nowe (narzędzia chirurgiczne szczegółowo w sekcji medycznej) |
| plasma cutter | przecinak plazmowy | m; nowe |

## 2. Elektronika, energia, części maszyn

| EN | PL | rodzaj/uwagi |
|---|---|---|
| power | zasilanie (sieć), energia (ilość), moc (W) | n/ż/ż; istniejące |
| APC (area power controller) | APC | ndm, uzgadniamy w r. m („APC jest wyłączony”); istniejące (139×) |
| SMES | SMES | ndm, r. m; istniejące (5×); odrzucone: akumulator |
| power cell | ogniwo zasilające | n; istniejące (138×); odrzucone: bateria (w nazwie ogniwa) |
| high-capacity power cell | ogniwo dużej pojemności | n; nowe (wzorem „Pamięć dużej pojemności”) |
| super-capacity power cell | ogniwo bardzo dużej pojemności | n; nowe |
| hyper-capacity power cell | ogniwo hiperpojemne | n; nowe (historia: „hiper-pojemna bateria”, 1×) |
| bluespace power cell | ogniwo bluespace | n; nowe |
| battery | bateria | ż; istniejące (40×), dla rzeczy, które w oryginale są „battery” |
| cable / power cable | kabel | m; istniejące (113× „kabl-”) |
| cable coil | zwój kabla | m; istniejące |
| wire (w panelu, w maszynie) | przewód | m; istniejące („przewody” 137×) |
| ethernet cable | kabel sieciowy | m; istniejące |
| power terminal | terminal zasilania | m; istniejące (5×) |
| power monitor | monitor zasilania | m; nowe |
| breaker / main breaker | wyłącznik / wyłącznik główny | m; istniejące (TGUI APC) |
| power channel | kanał zasilania | m; istniejące (TGUI) |
| equipment / lighting / environment (kanały APC) | sprzęt / oświetlenie / środowisko | m/n/n; nowe |
| light switch | włącznik światła | m; nowe |
| light fixture | oprawa oświetleniowa | ż; nowe |
| light tube | świetlówka | ż; istniejące (2×) |
| light bulb | żarówka | ż; istniejące (26×) |
| light replacer | wymieniacz żarówek | m; nowe |
| solar panel | panel słoneczny | m; istniejące (37×) |
| solar tracker | nadążnik słoneczny | m; nowe |
| solar control console | konsola paneli słonecznych | ż; nowe |
| generator | generator | m; istniejące |
| P.A.C.M.A.N. generator | generator P.A.C.M.A.N. | m; nowe (nazwa modelu bez zmian) |
| turbine | turbina | ż; istniejące (4×) |
| supermatter (crystal) | supermateria / kryształ supermaterii | ż/m; istniejące (31×) |
| supermatter sliver | odłamek supermaterii | m; istniejące |
| emitter | emiter | m; istniejące (11×) |
| field generator | generator pola | m; istniejące |
| containment field | pole izolujące | n; nowe |
| radiation collector | kolektor promieniowania | m; istniejące |
| particle accelerator | akcelerator cząstek | m; istniejące |
| singularity | osobliwość | ż; istniejące (15×) |
| tesla (energy ball) | kula Tesli | ż; istniejące („tesli” 11×) |
| tesla coil | cewka Tesli | ż; nowe |
| grounding rod | pręt uziemiający | m; nowe |
| stormdrive (reactor) | napęd burzowy | m; istniejące; „stormdrive” zostaje tylko jako nazwa własna typu |
| control rod | pręt sterujący | m; istniejące (10×) |
| nuclear reactor | reaktor jądrowy | m; istniejące (1×, równorzędnie „atomowy” 1× w nazwie obszaru) |
| FTL drive | napęd FTL | m; istniejące („napęd FTL”, „Rdzeń Napędu Nadświetlnego” w obszarach) |
| gravity generator | generator grawitacji | m; istniejące |
| shield generator | generator tarczy | m; istniejące |
| circuit board | płytka drukowana | ż; istniejące |
| machine board | płytka maszyny | ż; istniejące (14×) |
| computer board | płytka komputera | ż; istniejące |
| machine frame | rama maszyny | ż; istniejące („rama komputera”, „ramy APC”) |
| computer frame | rama komputera | ż; istniejące |
| stock part | część | ż; istniejące; w zbiorze: „części zamienne” |
| capacitor | kondensator | m; istniejące (33×) |
| scanning module | moduł skanujący | m; istniejące (5×) |
| manipulator | manipulator | m; istniejące |
| micro-laser | mikrolaser | m; istniejące (1×) |
| matter bin | zasobnik materii | m; nowe |
| basic / advanced / super / ultra / bluespace (poziomy części) | podstawowy / zaawansowany / super / ultra / bluespace | nowe; „super” i „ultra” jako przedrostki: „superkondensator”, „ultramikrolaser” |
| RAM (pamięć serwera SI) | pamięć | ż; istniejące („Pamięć standardowa”) |
| disk / data disk | dysk / dysk z danymi | m; istniejące (138×) |
| design disk | dysk z projektami | m; istniejące (TGUI) |
| technology disk | dysk z technologiami | m; nowe |
| signaler | sygnalizator | m; istniejące (10×) |
| igniter | zapalnik | m; istniejące (17×) |
| timer | zegar | m; istniejące (13×) |
| proximity sensor | czujnik zbliżeniowy | m; istniejące (8×) |
| infrared emitter | emiter podczerwieni | m; nowe |
| voice analyzer | analizator głosu | m; nowe |
| health sensor | czujnik zdrowia | m; nowe |
| assembly (zespół z części) | zespół | m; istniejące (60×), np. „zespół śluzy” |
| sensor | czujnik | m; istniejące (98×) |
| button | przycisk | m; istniejące |
| switch | przełącznik | m; istniejące |
| lever | dźwignia | ż; istniejące |
| fuse | bezpiecznik | m; istniejące |
| radio | radio | n; istniejące |
| station bounced radio | radio przenośne | n; nowe |
| intercom | interkom | m; istniejące (3×) |
| headset | słuchawki | mn; istniejące (20×), np. „słuchawki treningowe” |
| bowman headset | słuchawki nauszne | mn; nowe |
| encryption key | klucz szyfrujący | m; istniejące |
| PDA | PDA | n/ndm; istniejące (24×) |
| ID card | identyfikator | m; istniejące (35×); w UI dopuszczalne „karta ID” (12×) |
| tablet | tablet | m; istniejące |
| laptop | laptop | m; nowe |
| modular computer | komputer modułowy | m; nowe |
| camera (security) | kamera | ż; istniejące (113×) |
| camera (handheld) | aparat fotograficzny | m; istniejące |
| GPS | GPS | m/ndm; istniejące (16×) |
| pinpointer | pinpointer | m; istniejące (30×) |
| tracking beacon | nadajnik lokalizacyjny | m; istniejące |
| navigation beacon | radiolatarnia nawigacyjna | ż; istniejące (TGUI) |
| beacon (ogólnie) | nadajnik | m; istniejące (93×); „beacon” (13×) tylko tam, gdzie już jest |
| teleporter | teleporter | m; istniejące |
| teleporter hub | węzeł teleportera | m; nowe |
| teleporter station | stacja teleportera | ż; nowe |
| hand teleporter | ręczny teleporter | m; istniejące |
| telepad | telepad | m; istniejące |
| quantum pad | pad kwantowy | m; nowe |
| holopad | holopad | m; istniejące (7×) |
| server | serwer | m; istniejące |
| telecommunications relay | przekaźnik telekomunikacyjny | m; istniejące („przekaźnik”) |
| status display | wyświetlacz stanu | m; istniejące |
| display / screen | wyświetlacz / ekran | m; istniejące |
| monitor | monitor | m; istniejące |
| terminal | terminal | m; istniejące |
| console | konsola | ż; istniejące (157×) |
| computer | komputer | m; istniejące |
| newscaster | newscaster | m; istniejące (6×) |
| request console | konsola zgłoszeń | ż; nowe |
| communications console | konsola komunikacyjna | ż; istniejące |
| crew monitor | monitor załogi | m; istniejące (TGUI) |
| HUD | HUD | m; istniejące (38×) |
| emag | emag | m; istniejące (15×), czasownik: „emagujesz”, imiesłów „zemagowany” |
| MMI | MMI | n/ndm; istniejące (26×) |
| positronic brain | mózg pozytroniczny | m; istniejące (1×) |
| cyborg | cyborg | m; istniejące (89×); odrzucone: borg (dopuszczalne w potocznych komunikatach) |
| cyborg endoskeleton | endoszkielet cyborga | m; istniejące |
| cyborg module / model | moduł cyborga | m; istniejące |
| drone | dron | m; istniejące (82×) |
| bot (cleanbot, medbot) | robot | m; istniejące; nazwy botów (Beepsky, MULE) bez zmian |
| implant | implant | m; istniejące (189×) |
| implanter | implanter | m; istniejące |
| implant case | etui na implant | n; nowe |
| mindshield implant | implant ochrony umysłu | m; istniejące |
| tracking implant | implant namierzający | m; nowe |
| explosive implant | implant wybuchowy | m; nowe |
| autosurgeon | autochirurg | m; istniejące (14×) |

## 3. Konstrukcja, materiały, stacki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| sheet | arkusz | m; istniejące (97×), np. „arkuszy szkła”, „arkuszy żelaza” |
| stack (of X) | stos X | m; istniejące (42×) |
| pile | sterta | ż; istniejące („sterta śmieci”) |
| rod / metal rod | pręt / pręt metalowy | m; istniejące (79×) |
| iron | żelazo | n; istniejące (49×) |
| metal | metal | m; istniejące; w nazwach stacków używamy „żelazo” |
| glass | szkło | n; istniejące (81×) |
| reinforced glass | szkło zbrojone | n; istniejące (3×); odrzucone: „wzmocnione szkło” (3×). Zbrojone tylko dla szkła |
| plasma glass | szkło plazmowe | n; istniejące |
| reinforced plasma glass | zbrojone szkło plazmowe | n; nowe |
| titanium glass | szkło tytanowe | n; nowe |
| plastitanium glass | szkło plastytanowe | n; nowe |
| plasteel | plastal | ż; istniejące (20×); odrzucone: plaststal |
| plastitanium | plastytan | m; istniejące (3×) |
| titanium | tytan | m; istniejące |
| uranium | uran | m; istniejące |
| plasma (minerał) | plazma | ż; istniejące (136×) |
| gold | złoto | n; istniejące |
| silver | srebro | n; istniejące |
| copper | miedź | ż; istniejące |
| diamond | diament | m; istniejące |
| bananium | bananium | n/ndm; istniejące |
| adamantine | adamantyt | m; istniejące |
| mythril | mithril | m; nowe |
| runed metal | runiczny metal | m; istniejące |
| brass | mosiądz | m; istniejące (21×) |
| bronze | brąz | m; istniejące |
| wood / wooden planks | drewno / deski | n / mn; istniejące |
| log | kłoda | ż; istniejące (2×) |
| bamboo | bambus | m; istniejące |
| cloth | tkanina | ż; nowe (istniejące „materiał” zbyt ogólne) |
| durathread | duranić | ż; nowe (od istniejącej rośliny „duranitka”) |
| cotton | bawełna | ż; istniejące |
| leather | skóra | ż; istniejące |
| hide | skóra (surowa) | ż; istniejące |
| goliath hide | skóra goliata | ż; nowe |
| sinew | ścięgno | n; istniejące (1×) |
| bone | kość | ż; istniejące |
| cardboard | tektura | ż; istniejące (6×) |
| plastic | plastik | m; istniejące |
| paper (materiał) | papier | m; istniejące |
| sandstone | piaskowiec | m; nowe |
| snow | śnieg | m; istniejące |
| bluespace crystal | kryształ bluespace | m; istniejące (18×) |
| bluespace polycrystal | polikryształ bluespace | m; nowe |
| ore | ruda | ż; istniejące |
| bar (gold bar) | sztabka | ż; istniejące |
| coin | moneta | ż; istniejące |
| scrap | złom | m; istniejące |
| shard (of glass) | odłamek szkła | m; istniejące (8×) |
| floor tile | płytka podłogowa | ż; istniejące (11×) |
| carpet | wykładzina / dywan | ż / m; istniejące; płytka: „płytka wykładziny” |
| wall | ściana | ż; istniejące |
| reinforced wall | wzmocniona ściana | ż; istniejące |
| false wall | fałszywa ściana | ż; nowe |
| girder | dźwigar | m; istniejące (6×) |
| reinforced girder | wzmocniony dźwigar | m; nowe |
| floor | podłoga | ż; istniejące |
| plating | poszycie | n; istniejące (41×) |
| reinforced floor | wzmocniona podłoga | ż; istniejące |
| lattice | kratownica | ż; istniejące |
| catwalk | pomost | m; istniejące (15×) |
| grille | krata | ż; istniejące (44×) |
| window | okno | n; istniejące |
| reinforced window | wzmocnione okno | n; nowe |
| window frame | rama okienna | ż; nowe |
| airlock | śluza | ż; istniejące (201×) |
| airlock assembly | zespół śluzy | m; istniejące (12×) |
| glass airlock | przeszklona śluza | ż; nowe |
| maintenance hatch | właz techniczny | m; nowe |
| door | drzwi | mn; istniejące |
| windoor | drzwi okienne | mn; istniejące (20×) |
| blast door | drzwi przeciwwybuchowe | mn; nowe |
| shutters | rolety | mn; nowe |
| firelock | gródź przeciwpożarowa | ż; istniejące (6×); odmiana: grodzi, gródź (B.); odrzucone: „grodź” (błąd pisowni). Holograficzna wersja: „holograficzna gródź przeciwpożarowa” |
| plastic flaps | plastikowe zasłony | mn; nowe |
| railing | barierka | ż; istniejące |
| ladder | drabina | ż; istniejące |
| stairs | schody | mn; istniejące |
| turbolift / elevator | turbowinda / winda | ż; istniejące (7×) |
| hull | kadłub | m; istniejące (37×) |
| armor plates (mech) | płyty pancerza | mn; istniejące |
| construction / building | budowa | ż; istniejące |
| deconstruct | rozebrać / rozbierać | czasownik; istniejące (71×) |

## 4. Atmosfera i gazy

Nazwy gazów są widoczne w skanerach, kanistrach i oknach TGUI. Jeśli nazwa gazu służy w kodzie za klucz, tłumacz tylko wyświetlaną nazwę.

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Oxygen | tlen | m; istniejące (36×) |
| Nitrogen | azot | m; istniejące |
| Carbon Dioxide | dwutlenek węgla | m; istniejące (4×) |
| Plasma | plazma | ż; istniejące |
| Nitrous Oxide | podtlenek azotu | m; nowe |
| Water Vapor | para wodna | ż; istniejące (1×) |
| Pluoxium | pluoksium | n; istniejące (1×) |
| Tritium | tryt | m; istniejące (4×) |
| Nitryl / Nitrogen dioxide | dwutlenek azotu (nitryl) | m; nowe; „nitryl” istniejące (3×) w opisach, w nazwie gazu „dwutlenek azotu” |
| Hyper-noblium | hipernoblium | n; nowe |
| BZ | BZ | n/ndm; istniejące |
| Stimulum | stymulum | n; nowe |
| Constricted plasma | skondensowana plazma | ż; nowe |
| Nucleium | nukleium | n; nowe |
| Miasma | miazma | ż; istniejące (9×) |
| Hydrogen | wodór | m; istniejące |
| Freon | freon | m; nowe |
| air | powietrze | n; istniejące |
| pressure | ciśnienie | n; istniejące (75×) |
| output pressure | ciśnienie wyjściowe | n; istniejące (TGUI) |
| release pressure | ciśnienie wylotowe | n; nowe |
| temperature | temperatura | ż; istniejące |
| moles | mole | mn; istniejące („28 moli plazmy”) |
| flow / transfer rate | przepływ | m; istniejące (TGUI) |
| pipe | rura | ż; istniejące (56×) |
| pipe manifold | rozgałęźnik | m; nowe |
| 4-way manifold | rozgałęźnik czterodrożny | m; nowe |
| pipe junction / adapter | złączka | ż; nowe |
| layer adapter / layer manifold | adapter warstw | m; nowe |
| gas pump | pompa gazu | ż; nowe („pompa” istniejące) |
| pressure pump | pompa ciśnieniowa | ż; nowe |
| volumetric pump | pompa objętościowa | ż; istniejące (1×) |
| passive gate | regulator ciśnienia | m; nowe |
| valve / manual valve | zawór | m; istniejące (21×) |
| digital valve | zawór cyfrowy | m; nowe |
| gas filter | filtr gazów | m; istniejące (TGUI) |
| gas mixer | mieszacz gazów | m; nowe |
| connector port | port przyłączeniowy | m; istniejące („Port” w TGUI) |
| air vent / vent pump | nawiewnik | m; nowe; ogólnie „wentylacja” (istniejące) |
| scrubber (air scrubber) | oczyszczacz powietrza | m; istniejące (1×); odrzucone: scrubber |
| outlet injector | wtryskiwacz | m; nowe |
| heat exchanger | wymiennik ciepła | m; nowe |
| thermomachine | termomaszyna | ż; nowe |
| freezer | zamrażarka | ż; istniejące |
| heater | podgrzewacz | m; istniejące |
| space heater | grzejnik przenośny | m; nowe |
| canister | kanister | m; istniejące (TGUI „Kanister”) |
| gas tank (przenośna) | butla | ż; istniejące (54×) |
| oxygen tank | butla z tlenem | ż; istniejące |
| emergency oxygen tank | awaryjna butla z tlenem | ż; nowe |
| extended-capacity emergency oxygen tank | powiększona awaryjna butla z tlenem | ż; nowe |
| plasma tank | butla z plazmą | ż; istniejące |
| air tank | butla z powietrzem | ż; nowe |
| nitrogen tank | butla z azotem | ż; nowe |
| tank (zbiornik stały, np. fuel tank) | zbiornik | m; istniejące („zbiornik paliwa”) |
| jetpack | plecak odrzutowy | m; istniejące (9×); odrzucone: jetpack (3×) |
| internals | zasilanie z butli / oddychanie z butli | nowe; nie „wewnętrzne” |
| portable pump | przenośna pompa | ż; nowe |
| portable scrubber | przenośny oczyszczacz | m; nowe |
| air alarm | alarm powietrza | m; istniejące (7×) |
| fire alarm | alarm pożarowy | m; istniejące (6×) |
| atmospherics (dział) | atmosferyka | ż; istniejące („Inżynier Atmosferyki”) |
| incinerator | spalarnia | ż; nowe |
| burn chamber | komora spalania | ż; nowe |

## 5. Maszyny i urządzenia

| EN | PL | rodzaj/uwagi |
|---|---|---|
| machine | maszyna / urządzenie | ż / n; istniejące |
| vending machine | automat | m; istniejące („automat z jedzeniem”) |
| XDrobe (np. SecDrobe) | mundurownia (np. Mundurownia Policyjna) | ż; istniejące |
| autolathe | autolat | m; nowe. Odrzucone: „autolatarka” (3×, myli się z latarką) |
| protolathe | protolat | m; istniejące (1×) |
| circuit imprinter | drukarka obwodów | ż; istniejące |
| techfab | techfab | m; istniejące (3×) |
| exosuit fabricator | fabrykator egzoszkieletów | m; istniejące (TGUI) |
| destructive analyzer | analizator destrukcyjny | m; istniejące (TGUI) |
| R&D console | konsola B+R | ż; istniejące |
| research server | serwer badawczy | m; nowe |
| ore redemption machine | maszyna wymiany rudy | ż; istniejące (TGUI) |
| ore silo | silos rudy | m; istniejące (TGUI) |
| smelting console | konsola huty | ż; istniejące (TGUI) |
| recycler | recykler | m; istniejące |
| recharger | ładowarka | ż; istniejące |
| cell charger | ładowarka ogniw | ż; nowe |
| mech bay recharger | stacja ładowania mechów | ż; nowe |
| cyborg recharging station | stacja ładowania cyborgów | ż; nowe |
| conveyor belt | taśmociąg | m; istniejące (12×) |
| conveyor switch | przełącznik taśmociągu | m; nowe |
| disposal unit | zsyp | m; istniejące (15×, TGUI „Zsyp na śmieci”) |
| disposal pipe | rura zsypowa | ż; istniejące |
| mass driver | wyrzutnia masowa | ż; nowe |
| microwave | mikrofalówka | ż; istniejące (11×) |
| oven | piekarnik | m; istniejące (1×) |
| griddle | płyta grillowa | ż; nowe |
| grill | grill | m; istniejące |
| deep fryer | frytkownica | ż; nowe |
| food processor | malakser | m; nowe |
| gibber | maszynka do mięsa | ż; istniejące (2×) |
| monkey recycler | recykler małp | m; istniejące |
| smartfridge | inteligentna lodówka | ż; nowe |
| drying rack | suszarka | ż; nowe |
| ice cream vat | kadź do lodów | ż; istniejące (TGUI) |
| coffee maker | ekspres do kawy | m; istniejące (1×) |
| water cooler | dystrybutor wody | m; nowe |
| reagent grinder | młynek do odczynników | m; istniejące („młynek” 1×) |
| chem dispenser | dozownik chemikaliów | m; istniejące (2×) |
| ChemMaster | ChemMaster | m; istniejące |
| chem heater | podgrzewacz chemiczny | m; istniejące |
| centrifuge | wirówka | ż; nowe |
| PanD.E.M.I.C. 2200 | PanD.E.M.I.C. 2200 | ndm; istniejące |
| sleeper | uśpiacz | m; istniejące (2×) |
| cryo cell | kriokomora | ż; istniejące (5×) |
| cryopod / cryogenic freezer | kriokapsuła | ż; istniejące |
| cloning pod | kapsuła klonująca | ż; istniejące (5×) |
| DNA scanner | skaner DNA | m; istniejące |
| DNA console | konsola DNA | ż; istniejące (TGUI) |
| operating table | stół operacyjny | m; istniejące |
| operating computer | komputer operacyjny | m; nowe |
| defibrillator | defibrylator | m; istniejące (11×) |
| IV drip | kroplówka | ż; nowe |
| stasis bed | łóżko stazowe | n; nowe |
| holodeck | holodek | m; istniejące (TGUI) |
| turret | wieżyczka | ż; istniejące (35×) |
| turret control panel | panel sterowania wieżyczkami | m; nowe |
| jukebox | szafa grająca | ż; istniejące (TGUI) |
| arcade machine | automat do gier | m; istniejące (2×) |
| slot machine | jednoręki bandyta | m; nowe |
| photocopier | kserokopiarka | ż; nowe |
| fax machine | faks | m; istniejące (TGUI) |
| washing machine | pralka | ż; istniejące (2×) |
| bluespace artillery | artyleria bluespace | ż; istniejące (TGUI) |
| AI core | rdzeń SI | m; istniejące |
| announcement system | automatyczny system ogłoszeń | m; istniejące (TGUI) |
| camera bug | pluskwa kamerowa | ż; istniejące (TGUI) |
| fuel tank (struktura) | zbiornik paliwa | m; istniejące |
| water tank | zbiornik wody | m; nowe |
| tank dispenser | dozownik butli | m; nowe |

## 6. Meble, struktury, wystrój

| EN | PL | rodzaj/uwagi |
|---|---|---|
| table | stół | m; istniejące |
| reinforced table | wzmocniony stół | m; nowe |
| glass table | szklany stół | m; nowe |
| wooden table | drewniany stół | m; nowe |
| poker table | stół do pokera | m; nowe |
| chair | krzesło | n; istniejące |
| stool / bar stool | stołek / stołek barowy | m; nowe |
| office chair | krzesło biurowe | n; nowe |
| comfy chair | fotel | m; nowe |
| sofa | sofa | ż; nowe |
| bench | ławka | ż; nowe |
| pew | ławka kościelna | ż; nowe |
| bed | łóżko | n; istniejące |
| roller bed | łóżko na kółkach | n; istniejące (2×) |
| wheelchair | wózek inwalidzki | m; istniejące |
| stretcher | nosze | mn; nowe |
| bedsheet | prześcieradło | n; istniejące (2×) |
| rack | stojak | m; istniejące (24×) |
| shelf | półka | ż; istniejące |
| bookcase | regał na książki | m; istniejące („regał”) |
| dresser | komoda | ż; istniejące |
| closet | szafa | ż; istniejące |
| locker | szafka | ż; istniejące (28×) |
| secure locker | zabezpieczona szafka | ż; nowe |
| emergency closet | szafa awaryjna | ż; nowe |
| fire-safety closet | szafa przeciwpożarowa | ż; nowe |
| crate | skrzynia | ż; istniejące (92×) |
| secure crate | zabezpieczona skrzynia | ż; nowe |
| large crate | duża skrzynia | ż; nowe |
| coffin | trumna | ż; istniejące |
| body bag | worek na zwłoki | m; istniejące |
| morgue tray | szuflada kostnicy | ż; nowe |
| crematorium | krematorium | n; nowe |
| sink | umywalka (łazienka), zlew (kuchnia) | ż / m; istniejące |
| shower | prysznic | m; istniejące (16×) |
| toilet | toaleta | ż; istniejące |
| urinal | pisuar | m; nowe |
| mirror | lustro | n; istniejące |
| statue | posąg | m; istniejące (8×) |
| sign | znak / tabliczka | m / ż; istniejące („Znak informacyjny…”) |
| plaque | tabliczka pamiątkowa | ż; istniejące („tabliczka”) |
| poster | plakat | m; istniejące (74×) |
| painting | obraz | m; istniejące |
| canvas | płótno | n; nowe |
| easel | sztaluga | ż; nowe |
| banner | sztandar | m; istniejące (1×) |
| flag | flaga | ż; istniejące |
| curtain | zasłona | ż; nowe |
| showcase / display case | gablota | ż; nowe |
| safe | sejf | m; istniejące |
| vault | skarbiec | m; istniejące |
| barricade | barykada | ż; istniejące |
| sandbags | worki z piaskiem | mn; nowe |
| fence | ogrodzenie | n; istniejące |
| bonfire | ognisko | n; nowe |
| fireplace | kominek | m; nowe |
| altar | ołtarz | m; nowe |
| kitchen spike / meat spike | hak rzeźnicki | m; istniejące (5×, `kitchen_spike.dm`), rama: „rama haka rzeźnickiego”; odrzucone: „hak rzeźniczy”, „hak na mięso” |
| trash pile | sterta śmieci | ż; istniejące |
| desk bell | dzwonek na ladę | m; istniejące |
| holosign / holobarrier | holoznak / holobariera | m / ż; nowe; projektor: „projektor barier” (istniejące) |
| barrier tape | taśma odgradzająca | ż; istniejące |
| wet floor sign | znak „mokra podłoga” | m; nowe |
| mop bucket / janitor cart | wiadro z mopem / wózek woźnego | n / m; nowe |
| plant pot | doniczka | ż; istniejące |
| shuttle | prom | m; istniejące (383×); odrzucone: wahadłowiec (7×, tylko w nazwach obszarów) |
| escape pod | kapsuła ratunkowa | ż; istniejące |
| supply pod | kapsuła zaopatrzeniowa | ż; istniejące |

## 7. Plecaki, torby, pojemniki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| backpack | plecak | m; istniejące (47×) |
| satchel | torba na ramię | ż; nowe |
| duffel bag | torba podróżna | ż; nowe |
| explorer bag / mining bag | torba górnicza | ż; istniejące |
| bag of holding | torba bez dna | ż; istniejące (historia) |
| bag | torba / worek | ż / m; istniejące |
| trash bag | worek na śmieci | m; istniejące |
| plastic bag (zakupy) | reklamówka | ż; istniejące |
| evidence bag | torebka na dowody | ż; nowe |
| box | pudełko | n; istniejące (61×) |
| large box | pudło | n; istniejące |
| cardboard box | kartonowe pudełko | n; istniejące |
| kit | zestaw | m; istniejące (110×) |
| case | skrzynka / etui | ż / n; nowe (broń: skrzynka, implant: etui) |
| briefcase | aktówka | ż; nowe |
| wallet | portfel | m; istniejące |
| fanny pack | nerka | ż; nowe |
| pouch | sakiewka; na amunicję: ładownica | ż; nowe |
| holster | kabura | ż; istniejące (2×) |
| bandolier | bandolier | m; nowe |
| belt | pas | m; istniejące |
| utility belt | pas na narzędzia | m; istniejące |
| medical belt | pas medyczny | m; nowe |
| security belt | pas policyjny | m; nowe |
| webbing | oporządzenie | n; nowe |
| pill bottle | pojemnik na pigułki | m; nowe |
| first-aid kit / medkit | apteczka | ż; istniejące |
| lunchbox | śniadaniówka | ż; nowe |
| matchbox | pudełko zapałek | n; nowe |
| cigarette packet | paczka papierosów | ż; nowe |
| donut box | pudełko pączków | n; nowe |
| egg box | wytłaczanka na jajka | ż; nowe |
| storage implant / pocket | schowek / kieszeń | m / ż; istniejące („kieszeń bluespace”) |

## 8. Ubrania i pancerze

| EN | PL | rodzaj/uwagi |
|---|---|---|
| clothing | ubranie / odzież | n / ż; istniejące |
| jumpsuit | kombinezon | m; istniejące (79×) |
| jumpskirt | spódnica | ż; istniejące (17×); gdy obok jest kombinezon tego samego działu, „spódnica do munduru” |
| uniform | mundur | m; istniejące (12×) |
| formal suit | garnitur | m; istniejące (18×) |
| dress | sukienka | ż; istniejące |
| skirt | spódnica | ż; istniejące |
| suitskirt | garsonka | ż; nowe |
| shirt | koszula | ż; nowe |
| t-shirt | koszulka | ż; nowe |
| tank top | podkoszulek | m; nowe |
| sweater | sweter | m; nowe |
| turtleneck | golf | m; istniejące (2×) |
| hoodie | bluza z kapturem | ż; nowe |
| jacket | kurtka | ż; istniejące (17×) |
| winter coat | kurtka zimowa | ż; istniejące (4×) |
| coat | płaszcz | m; istniejące (17×) |
| trenchcoat | trencz | m; istniejące |
| labcoat | fartuch laboratoryjny | m; istniejące (1×); odrzucone: kitel |
| apron | fartuch | m; istniejące |
| overalls | ogrodniczki | mn; istniejące |
| vest | kamizelka | ż; istniejące (13×) |
| hazard vest / high-vis vest | kamizelka odblaskowa | ż; nowe |
| armor (ogólnie) | pancerz | m; istniejące (202×) |
| armor vest / bulletproof vest | kamizelka kuloodporna | ż; istniejące |
| ablative armor | pancerz ablacyjny | m; nowe |
| reactive armor | pancerz reaktywny / zbroja reaktywna | m / ż; istniejące („zbroja reaktywna”) |
| riot suit / riot armor | strój prewencyjny | m; nowe (historia: „strój do zamieszek” 1×) |
| riot helmet | hełm prewencyjny | m; nowe |
| robe | szata | ż; istniejące (20×) |
| cloak | peleryna | ż; istniejące (1×); w przypadku „cloak” dla szefów działów także peleryna |
| cape | peleryna | ż; nowe |
| poncho | ponczo | n; nowe |
| scarf | szalik | m; istniejące |
| tie | krawat | m; istniejące |
| bow tie | muszka | ż; nowe |
| necklace | naszyjnik | m; nowe |
| collar | obroża | ż; nowe |
| armband | opaska | ż; istniejące (13×) |
| medal | medal | m; istniejące |
| badge | odznaka | ż; nowe |
| pin | przypinka | ż; nowe |
| hat | kapelusz | m; istniejące (23×) |
| cap | czapka | ż; istniejące (29×) |
| baseball cap / soft cap | czapka bejsbolówka | ż; istniejące (8×) |
| beanie / winter hat | czapka zimowa | ż; istniejące (4×) |
| beret | beret | m; istniejące |
| fedora | fedora | ż; nowe |
| top hat | cylinder | m; nowe |
| bowler hat | melonik | m; nowe |
| hood | kaptur | m; nowe |
| helmet | hełm | m; istniejące (62×) |
| hard hat | kask | m; istniejące (3×) |
| welding helmet | przyłbica spawalnicza | ż; istniejące (2×) |
| bandana | bandana | ż; nowe |
| headband | opaska na głowę | ż; nowe |
| crown | korona | ż; nowe |
| wig | peruka | ż; nowe |
| earmuffs | nauszniki | mn; istniejące |
| glasses | okulary | mn; istniejące |
| sunglasses | okulary przeciwsłoneczne | mn; istniejące (7×) |
| prescription glasses | okulary korekcyjne | mn; nowe |
| goggles | gogle | mn; istniejące (7×) |
| meson scanner goggles | gogle mezonowe | mn; nowe („mezonową” 1×) |
| night vision goggles | gogle noktowizyjne | mn; istniejące (1×) |
| thermal goggles | gogle termowizyjne | mn; nowe |
| science goggles | gogle naukowe | mn; istniejące |
| welding goggles | gogle spawalnicze | mn; nowe |
| medical HUD | HUD medyczny | m; nowe |
| security HUD | HUD ochrony | m; istniejące (10×) |
| diagnostic HUD | HUD diagnostyczny | m; nowe |
| eyepatch | przepaska na oko | ż; nowe |
| blindfold | opaska na oczy | ż; nowe |
| monocle | monokl | m; nowe |
| mask | maska | ż; istniejące |
| gas mask | maska gazowa | ż; istniejące (1×) |
| breath mask | maska oddechowa | ż; istniejące (1×) |
| surgical mask / sterile mask | maseczka chirurgiczna | ż; nowe |
| balaclava | kominiarka | ż; nowe |
| muzzle | kaganiec | m; nowe |
| SecHailer | maska z megafonem | ż; nowe |
| gloves | rękawice | mn; istniejące (35×); cienkie: rękawiczki |
| latex gloves | rękawiczki lateksowe | mn; istniejące |
| nitrile gloves | rękawiczki nitrylowe | mn; istniejące |
| insulated gloves | rękawice izolacyjne | mn; nowe („rękawic izolujących” 1×) |
| budget insulated gloves | tanie rękawice izolacyjne | mn; nowe |
| combat gloves | rękawice bojowe | mn; istniejące (4×) |
| fingerless gloves | rękawiczki bez palców | mn; nowe |
| boxing gloves | rękawice bokserskie | mn; nowe |
| shoes | buty | mn; istniejące (37×) |
| sneakers | trampki | mn; nowe |
| boots | buty (wysokie) | mn; istniejące |
| combat boots | buty bojowe | mn; nowe |
| jackboots | buty wojskowe | mn; nowe |
| workboots | buty robocze | mn; nowe |
| winter boots | buty zimowe | mn; nowe |
| magboots | buty magnetyczne | mn; istniejące (1×) |
| galoshes | kalosze | mn; istniejące (1×) |
| sandals | sandały | mn; istniejące |
| slippers | kapcie | mn; nowe |
| clown shoes | buty klauna | mn; nowe |
| space suit | skafander kosmiczny | m; istniejące |
| space helmet | hełm kosmiczny | m; istniejące (2×) |
| hardsuit | hardsuit | m; istniejące (39×, „hardsuitu”, „hełm hardsuitu”); odrzucone: „wzmocniony skafander” (6×) |
| MODsuit | MODsuit | m; istniejące (20×) |
| EVA suit | skafander EVA | m; nowe |
| bio suit | kombinezon biologiczny | m; istniejące (2×) |
| bomb suit | kombinezon saperski | m; nowe |
| radiation suit | kombinezon przeciwradiacyjny | m; nowe |
| fire suit | kombinezon przeciwpożarowy | m; istniejące (3×) |
| envirosuit (plazmoludy) | kombinezon środowiskowy | m; nowe |
| envirosuit helmet | hełm środowiskowy | m; nowe |
| explorer suit | kombinezon górniczy | m; nowe (spójnie z istniejącą „torbą górniczą”) |
| chameleon X | X kameleona | istniejące („maski kameleona”) |
| costume | przebranie | n; nowe |

## 9. Broń biała, tarcze, sprzęt ochrony

| EN | PL | rodzaj/uwagi |
|---|---|---|
| weapon | broń | ż; istniejące (162×) |
| knife | nóż | m; istniejące (30×) |
| combat knife | nóż bojowy | m; nowe |
| kitchen knife | nóż kuchenny | m; istniejące |
| butcher's cleaver | tasak | m; istniejące (22×) |
| switchblade | nóż sprężynowy | m; istniejące |
| sword | miecz | m; istniejące (23×) |
| energy sword | miecz energetyczny | m; istniejące |
| katana / claymore | katana / claymore | ż / m; nowe (nazwy broni bez zmian) |
| spear | włócznia | ż; istniejące |
| baseball bat | kij bejsbolowy | m; nowe |
| baton | pałka | ż; istniejące (25×) |
| stun baton | pałka ogłuszająca | ż; istniejące |
| telescopic baton | pałka teleskopowa | ż; nowe |
| whip | bicz | m; nowe |
| shield | tarcza | ż; istniejące (33×) |
| riot shield | tarcza prewencyjna | ż; nowe |
| energy shield | tarcza energetyczna | ż; istniejące |
| handcuffs | kajdanki | mn; istniejące (14×) |
| zipties / cable restraints | opaski zaciskowe | mn; istniejące (4×) |
| flash | flash | m; istniejące (20×, „flasha”) |
| flashbang | granat hukowo-błyskowy | m; nowe; odrzucone: flashbang (1×) |
| pepper spray | gaz pieprzowy | m; istniejące (1×) |
| bola | bola | ż; nowe |
| bear trap | wnyki / sidła | mn; nowe |
| barrier tape (police) | taśma policyjna | ż; istniejące |

## 10. Broń palna i energetyczna

| EN | PL | rodzaj/uwagi |
|---|---|---|
| gun | broń / pistolet | ż / m; istniejące |
| pistol | pistolet | m; istniejące (29×) |
| revolver | rewolwer | m; istniejące |
| rifle | karabin | m; istniejące (20×) |
| assault rifle | karabin szturmowy | m; istniejące („Karabinek szturmowy wz. 96 Beryl” jako nazwa własna) |
| sniper rifle | karabin snajperski | m; nowe |
| SMG | pistolet maszynowy | m; istniejące („Pistolet maszynowy PM-98”) |
| shotgun | strzelba | ż; istniejące (10×) |
| combat shotgun | strzelba bojowa | ż; nowe |
| riot shotgun | strzelba prewencyjna | ż; nowe |
| grenade launcher | granatnik | m; istniejące (3×) |
| rocket launcher / missile launcher | wyrzutnia rakiet | ż; istniejące |
| flamethrower | miotacz ognia | m; istniejące |
| crossbow | kusza | ż; nowe |
| bow | łuk | m; nowe |
| arrow | strzała | ż; nowe |
| laser gun | karabin laserowy | m; istniejące (1×) |
| energy gun | broń energetyczna | ż; istniejące (7×) |
| disabler | disabler | m; istniejące (3×) |
| taser | paralizator | m; istniejące (8×); odrzucone: taser |
| ion rifle | karabin jonowy | m; nowe |
| pulse rifle | karabin pulsacyjny | m; istniejące (3×) |
| kinetic accelerator | kinetyczny akcelerator | m; istniejące („moduły kinetycznego akceleratora”) |
| kinetic crusher | kinetyczny miażdżyciel | m; istniejące |
| syringe gun | wyrzutnia strzykawek | ż; nowe |
| toy gun / foam force | pistolet zabawkowy | m; nowe; marka Donksoft bez zmian |
| firing pin | iglica | ż; istniejące (17×) |
| barrel | lufa | ż; istniejące (39×) |
| trigger | spust | m; istniejące |
| chamber | komora | ż; istniejące |
| suppressor | tłumik | m; istniejące |
| scope | celownik optyczny | m; istniejące („celownik”) |
| stock | kolba | ż; istniejące |
| safety (broni) | bezpiecznik | m; istniejące |
| fire mode | tryb ognia | m; istniejące (6×) |
| lethal / disable (tryby) | zabójczy / obezwładniający | nowe; „obezwładni-” istniejące (23×) |

## 11. Amunicja i materiały wybuchowe

| EN | PL | rodzaj/uwagi |
|---|---|---|
| ammo / ammunition | amunicja | ż; istniejące (75×) |
| ammo box | pojemnik z amunicją | m; istniejące |
| magazine | magazynek | m; istniejące (15×) |
| speedloader | szybkoładowacz | m; nowe |
| stripper clip | łódka nabojowa | ż; nowe |
| bullet | pocisk | m; istniejące (106×) |
| round / cartridge | nabój | m; istniejące |
| casing / bullet casing | łuska | ż; istniejące (28×) |
| shell (shotgun) | nabój do strzelby | m; istniejące („nabój” 5×) |
| buckshot | nabój śrutowy | m; istniejące („śrut-”) |
| slug | breneka | ż; nowe |
| beanbag slug | nabój z woreczkiem | m; nowe |
| rubber shot | nabój z gumowym śrutem | m; nowe |
| rubber (bullet) | gumowy | przym.; istniejące („gumową amunicję”) |
| armor-piercing (AP) | przeciwpancerny | przym.; istniejące (7×) |
| incendiary | zapalający | przym.; istniejące |
| hollow-point | z pociskiem wydrążonym | nowe |
| dragon's breath | smoczy oddech | m; nowe |
| caliber | kaliber | m; istniejące |
| grenade | granat | m; istniejące (24×) |
| chem grenade | granat chemiczny | m; nowe |
| smoke grenade | granat dymny | m; nowe |
| frag grenade | granat odłamkowy | m; nowe |
| EMP grenade | granat EMP | m; nowe |
| bomb | bomba | ż; istniejące |
| C4 / X4 | C4 / X4 | ndm; nowe |
| plastic explosive | materiał wybuchowy plastyczny | m; nowe |
| landmine | mina | ż; nowe |
| warhead | głowica | ż; istniejące |
| fuze | zapalnik | m; istniejące („forma zapalników”) |
| primer | spłonka | ż; istniejące |
| filler | wypełnienie | n; istniejące |
| EMP charge / HE charge | ładunek EMP / ładunek HE | m; istniejące |

## 12. NSV13: uzbrojenie okrętowe, myśliwce, amunicja działowa

| EN | PL | rodzaj/uwagi |
|---|---|---|
| munitions (dział) | amunicja | ż; istniejące („Technik Amunicyjny”) |
| ordnance | uzbrojenie | n; istniejące („Obsługa Uzbrojenia”) |
| torpedo | torpeda | ż; istniejące (30×) |
| missile | rakieta | ż; istniejące (20×) |
| torpedo tube / launcher | wyrzutnia torped | ż; nowe |
| railgun | railgun | m; istniejące (79×); odrzucone: „działo szynowe” (4×) |
| MAC (Magnetic Accelerator Cannon) | działo MAC | n; nowe |
| PDC (point defense cannon) | działko obrony punktowej (PDC) | n; istniejące („obrony punktowej” 3×, „PDC” 9×) |
| flak | flak | m; istniejące |
| gauss gun | działo Gaussa | n; istniejące (41× „gauss”) |
| broadside cannon | działo burtowe | n; nowe |
| deck gun | działo pokładowe | n; nowe |
| cannon | działo | n; istniejące |
| shell (artillery) | pocisk działowy | m; istniejące |
| munitions trolley | wózek amunicyjny | m; istniejące (2×) |
| fighter | myśliwiec | m; istniejące (33×) |
| hardpoint | punkt mocowania | m; nowe |
| munitions forge | kuźnia amunicji | ż; istniejące |
| DRADIS | DRADIS | m/ndm; istniejące |
| radar | radar | m; istniejące (26×) |
| squad (NSV13) | drużyna | ż; istniejące (28× przed tłumaczeniem całości, ponad 100× po nim): „pager drużyny”, „dowódca drużyny”, „Drużyna Able”, „Zarządzanie drużynami”, „Preferowana drużyna (GQ)”. Odrzucone: „oddział” (dla squad), „skład” (zostaje tylko w starym `squad_vendor.dm`: „zestaw składu”, „automat składu”). „Oddział” zostaje dla ERT i jednostek wojskowych („oddział reagowania Centrali”, „oddział HONK”). „Roster” w tabeli to „Skład” |

## 13. Górnictwo

| EN | PL | rodzaj/uwagi |
|---|---|---|
| mining | górnictwo / górniczy | n / przym.; istniejące (64×) |
| pickaxe | kilof | m; istniejące |
| mining drill | wiertło górnicze | n; istniejące |
| diamond drill | diamentowe wiertło | n; istniejące |
| jackhammer | młot pneumatyczny | m; nowe |
| sonic jackhammer | soniczny młot pneumatyczny | m; nowe |
| resonator | rezonator | m; istniejące |
| mining scanner | skaner górniczy | m; istniejące |
| automatic mining scanner | automatyczny skaner górniczy | m; nowe |
| ore satchel / mining satchel | torba na rudę | ż; nowe |
| ore box | skrzynia na rudę | ż; nowe |
| marker beacon | znacznik | m; istniejące (15×) |
| mining point | punkt górniczy | m; nowe |
| mining voucher | bon górniczy | m; nowe |
| survival capsule | kapsuła przetrwania | ż; nowe |
| minebot | robot górniczy | m; nowe |
| gibtonite | gibtonit | m; istniejące |
| asteroid | asteroida | ż; istniejące (40×) |
| Lavaland | Lavaland | m; istniejące (24×, „Lavalandu”) |
| goliath | goliat | m; nowe |
| necropolis chest | skrzynia z Nekropolii | ż; nowe |
| magnet (asteroid magnet) | magnes | m; istniejące |

## 14. Pojemniki na odczynniki i drobny sprzęt medyczny

| EN | PL | rodzaj/uwagi |
|---|---|---|
| beaker | zlewka | ż; istniejące (24×) |
| large beaker | duża zlewka | ż; nowe |
| bluespace beaker | zlewka bluespace | ż; nowe |
| bottle | butelka | ż; istniejące (47×) |
| syringe | strzykawka | ż; istniejące (20×) |
| dropper | zakraplacz | m; nowe |
| pill | pigułka | ż; istniejące (15×) |
| patch | plaster | m; nowe |
| hypospray | hypospray | m; istniejące (2×) |
| medipen | medipen | m; istniejące (2×) |
| injector / DNA injector | iniektor / iniektor DNA | m; istniejące (16×) |
| spray bottle | rozpylacz | m; istniejące |
| bucket (chem) | wiadro | n; nowe |
| gauze | gaza | ż; nowe |
| bandage | bandaż | m; istniejące |
| splint | szyna | ż; nowe |
| ointment | maść | ż; nowe |
| health analyzer | analizator zdrowia | m; istniejące (5×) |
| plant analyzer | analizator roślin | m; istniejące |
| chemical analyzer | analizator chemiczny | m; nowe |
| first-aid kit | apteczka pierwszej pomocy | ż; istniejące |
| burn treatment kit | apteczka na oparzenia | ż; nowe |
| toxin treatment kit | apteczka toksykologiczna | ż; istniejące |
| oxygen deprivation kit | apteczka na niedotlenienie | ż; nowe |
| brute trauma kit | apteczka na urazy | ż; nowe |

## 15. Biuro, drobiazgi, rozrywka

| EN | PL | rodzaj/uwagi |
|---|---|---|
| paper | kartka papieru / kartka | ż; istniejące |
| paper bin | podajnik papieru | m; nowe |
| pen | długopis | m; istniejące (31×) |
| fountain pen | pióro wieczne | n; nowe |
| crayon | kredka | ż; nowe |
| spray can | puszka ze sprayem | ż; istniejące (5× w nazwach: „puszka ze sprayem cyborga”, „cicha puszka ze sprayem”); „farba w sprayu” tylko w opisach (zawartość puszki) |
| clipboard | podkładka | ż; istniejące (TGUI) |
| folder | teczka | ż; istniejące |
| stamp | pieczątka | ż; istniejące (15×) |
| photo | zdjęcie | n; istniejące |
| book | książka | ż; istniejące |
| manual | podręcznik | m; nowe |
| envelope | koperta | ż; nowe |
| mail / letter | list | m; istniejące |
| package / parcel | paczka | ż; istniejące |
| wrapping paper | papier do pakowania | m; nowe |
| tape / duct tape | taśma / taśma klejąca | ż; istniejące |
| dice | kostka do gry | ż; nowe |
| d20 / d6 | k20 / k6 | ndm; nowe (polska konwencja RPG) |
| deck of cards | talia kart | ż; nowe |
| card (playing) | karta | ż; istniejące |
| space cash | gotówka | ż; istniejące |
| credits | kredyty | mn; istniejące (78×) |
| holochip | holoczip | m; nowe |
| toy | zabawka | ż; istniejące |
| plushie | pluszak | m; istniejące (10×) |
| action figure | figurka | ż; nowe |
| balloon | balon | m; istniejące |
| cigarette | papieros | m; istniejące |
| cigar | cygaro | n; istniejące |
| lighter | zapalniczka | ż; istniejące |
| match | zapałka | ż; istniejące |
| smoking pipe | fajka | ż; nowe |
| rolling paper | bibułka | ż; nowe |
| ashtray | popielniczka | ż; nowe |
| flashlight | latarka | ż; istniejące (25×) |
| penlight | latarka diagnostyczna | ż; nowe |
| seclite | latarka policyjna | ż; nowe |
| flare | raca | ż; nowe |
| glowstick | świetlik chemiczny | m; nowe |
| lantern | latarenka | ż; nowe |
| umbrella | parasol | m; nowe |
| cane | laska | ż; nowe |
| bedsheet (z nadrukiem) | prześcieradło X | n; istniejące |
| bike horn | trąbka | ż; nowe |
| musical instrument | instrument | m; nowe |
| guitar / violin / piano | gitara / skrzypce / pianino | ż / mn / n; nowe |
| skateboard | deskorolka | ż; nowe |

## 16. Kuchnia: sprzęt i naczynia

| EN | PL | rodzaj/uwagi |
|---|---|---|
| drinking glass | szklanka | ż; istniejące (28×) |
| shot glass | kieliszek | m; istniejące |
| mug | kubek | m; istniejące (7×) |
| cup / paper cup | kubek / kubek papierowy | m; istniejące |
| flask | piersiówka | ż; nowe; „flaszka” (istniejące 5×) dla flasks alchemicznych i ekstraktu |
| captain's flask | piersiówka kapitana | ż; nowe |
| bottle (drink) | butelka | ż; istniejące |
| soda can | puszka | ż; istniejące |
| carton | karton | m; istniejące |
| jug | dzbanek | m; istniejące (6×) |
| keg | beczka | ż; istniejące (1×) |
| shaker (cocktail) | shaker | m; nowe |
| salt shaker | solniczka | ż; nowe |
| pepper mill | młynek do pieprzu | m; nowe |
| condiment bottle | butelka na przyprawy | ż; nowe |
| condiment pack | saszetka | ż; nowe |
| dispenser (drinks) | dozownik napojów | m; istniejące („dozownik”) |
| spoon | łyżka | ż; istniejące |
| fork | widelec | m; istniejące (12×) |
| plate | talerz | m; istniejące |
| bowl | miska | ż; istniejące |
| tray | taca | ż; istniejące |
| pan / pot | patelnia / garnek | ż / m; nowe |
| straw | słomka | ż; istniejące |
| garnish | dekoracja barowa | ż; istniejące |
| drink umbrella | parasolka do drinka | ż; istniejące |

## 17. Jedzenie: stany i składniki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| food | jedzenie | n; istniejące |
| raw | surowy | przym.; istniejące (12×) |
| cooked | ugotowany / upieczony | przym.; istniejące |
| boiled | gotowany | przym.; istniejące („gotowany ryż”) |
| fried | smażony | przym.; istniejące |
| baked / roasted | pieczony | przym.; istniejące |
| grilled | grillowany | przym.; nowe |
| burnt / burned | przypalony | przym.; istniejące; „burned mess” → „spalona breja” |
| moldy | spleśniały | przym.; istniejące |
| homemade | domowy | przym.; nowe |
| meat | mięso | n; istniejące (202×) |
| slab of meat | płat mięsa | m; nowe |
| synthmeat | syntetyczne mięso | n; nowe |
| cutlet | kotlet | m; istniejące |
| patty | kotlet mielony | m; nowe (ogólnie „mielone” istniejące) |
| meatball | klopsik | m; istniejące („klopsiki”) |
| steak | stek | m; istniejące |
| bacon | boczek | m; nowe |
| sausage | kiełbasa | ż; istniejące |
| salami | salami | n/ndm; nowe |
| jerky | suszone mięso | n; istniejące |
| fish fillet | filet rybny | m; nowe („filet” istniejące) |
| carp fillet | filet z karpia | m; nowe |
| crab meat | mięso kraba | n; nowe |
| chicken | kurczak | m; nowe |
| corgi meat | mięso corgiego | n; istniejące (historia) |
| monkey meat | mięso małpy | n; nowe |
| xeno meat | mięso ksenomorfa | n; nowe |
| spider meat | mięso pająka | n; nowe |
| bear meat | mięso niedźwiedzia | n; nowe |
| egg | jajko | n; istniejące |
| boiled egg | jajko na twardo | n; nowe |
| fried egg | jajko sadzone | n; nowe |
| egg yolk | żółtko | n; nowe |
| cheese | ser | m; istniejące |
| cheese wheel | krąg sera | m; nowe |
| cheese wedge | kawałek sera | m; nowe |
| cheese mix (curd) | masa serowa | ż; nowe |
| butter | masło | n; istniejące (19×) |
| milk | mleko | n; istniejące |
| cream | śmietanka | ż; istniejące (19×) |
| flour | mąka | ż; istniejące |
| sugar | cukier | m; istniejące |
| salt | sól | ż; istniejące |
| black pepper | czarny pieprz | m; istniejące |
| rice | ryż | m; istniejące |
| dough | kula ciasta | ż; nowe |
| flat dough | rozwałkowane ciasto | n; nowe |
| dough slice | porcja ciasta | ż; nowe |
| cake batter | masa na ciasto | ż; nowe |
| pastry base / pie dough | spód do ciasta | m; nowe |
| bun | bułka | ż; istniejące (27×) |
| bread | chleb | m; istniejące |
| baguette | bagietka | ż; nowe |
| toast | tost | m; nowe |
| tofu | tofu | n/ndm; nowe |
| noodles | makaron | m; istniejące |
| oil / cooking oil | olej / olej spożywczy | m; istniejące |
| olive oil | oliwa z oliwek | ż; nowe |
| honey | miód | m; istniejące |
| ketchup | ketchup | m; istniejące |
| mayonnaise | majonez | m; nowe |
| BBQ sauce | sos barbecue | m; nowe |
| hot sauce | ostry sos | m; nowe |
| cold sauce | lodowy sos | m; nowe |
| soy sauce | sos sojowy | m; nowe |
| vinegar | ocet | m; nowe |
| syrup | syrop | m; istniejące |
| caramel | karmel | m; nowe |
| sprinkles | posypka | ż; nowe |
| vanilla | wanilia | ż; istniejące |
| cocoa powder | kakao w proszku | n; istniejące („kakao”) |
| corn starch | skrobia kukurydziana | ż; nowe |
| corn syrup | syrop kukurydziany | m; nowe |
| enzyme / universal enzyme | enzym uniwersalny | m; nowe |
| nutriment | składniki odżywcze | mn; istniejące (6×) |
| vitamin | witaminy | mn; istniejące |
| protein | białko | n; istniejące |
| ration pack | racja żywnościowa | ż; istniejące |
| snack | przekąska | ż; istniejące |
| candy | cukierek | m; istniejące |
| chocolate bar | tabliczka czekolady | ż; nowe |
| chips | chipsy | mn; nowe |
| popcorn | popcorn | m; istniejące |
| gum / bubblegum | guma do żucia | ż; nowe |
| lollipop | lizak | m; nowe |
| ice cream | lody | mn; nowe |
| snowcone | kruszony lód | m; nowe; np. „kruszony lód jabłkowy” |

## 18. Jedzenie: dania

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Donk-pocket | pieróg / pierożek | m; istniejące (np. „jagodowy pierożek”, „karton pierogów”) |
| burger | burger | m; istniejące |
| cheeseburger | cheeseburger | m; nowe |
| big bite burger | burger Wielki Kęs | m; nowe |
| pizza | pizza | ż; istniejące |
| pizza margherita | pizza margherita | ż; nowe |
| meatpizza | pizza mięsna | ż; istniejące |
| Hawaiian pizza | pizza hawajska | ż; nowe |
| mushroom pizza | pizza grzybowa | ż; nowe |
| vegetable pizza | pizza wegetariańska | ż; nowe |
| soup | zupa | ż; istniejące |
| tomato soup | zupa pomidorowa | ż; nowe |
| mushroom / chantrelle soup | zupa grzybowa / zupa kurkowa | ż; nowe |
| beet soup | barszcz | m; nowe |
| miso soup | zupa miso | ż; nowe |
| stew | gulasz | m; nowe |
| salad | sałatka | ż; istniejące |
| fruit salad | sałatka owocowa | ż; nowe |
| sandwich | kanapka | ż; istniejące |
| grilled cheese sandwich | tost z serem | m; nowe |
| hotdog | hot dog | m; nowe |
| kebab | kebab | m; istniejące |
| taco / burrito / nachos | taco / burrito / nachos | n/ndm; nowe |
| sushi / sushi roll | sushi / rolka sushi | n/ndm / ż; nowe |
| spaghetti | spaghetti | n/ndm; istniejące |
| spaghetti and meatballs | spaghetti z klopsikami | n; nowe |
| lasagna | lasagne | ż/ndm; nowe |
| omelette | omlet | m; istniejące |
| pancake | naleśnik | m; istniejące (10×) |
| waffles | gofry | mn; nowe |
| fries / space fries | frytki / kosmiczne frytki | mn; istniejące (1×) |
| onion rings | krążki cebulowe | mn; nowe |
| baked potato | pieczony ziemniak | m; nowe |
| mashed potatoes | puree ziemniaczane | n; nowe |
| cake | ciasto | n; istniejące |
| birthday cake | tort urodzinowy | m; nowe |
| cheesecake | sernik | m; nowe |
| carrot cake | ciasto marchewkowe | n; nowe |
| chocolate cake | ciasto czekoladowe | n; nowe |
| pie | placek | m; istniejące (2×) |
| apple pie | szarlotka | ż; nowe |
| cream pie (klaun) | tort z kremem | m; nowe |
| meat pie | placek z mięsem | m; nowe |
| tart | tarta | ż; istniejące (1×) |
| muffin | muffinka | ż; istniejące („muffinek”) |
| cupcake | babeczka | ż; nowe |
| donut | pączek | m; istniejące (36×) |
| jelly donut | pączek z dżemem | m; nowe |
| cookie | ciasteczko | n; istniejące (23×) |
| fortune cookie | ciasteczko z wróżbą | n; nowe |
| sugar cookie | ciasteczko cukrowe | n; nowe |
| jelly | galaretka | ż; istniejące |
| pudding | budyń | m; nowe |
| sundae | puchar lodowy | m; nowe |
| ice cream sandwich | kanapka lodowa | ż; nowe |
| candied apple | jabłko w karmelu | n; nowe |
| oatmeal | owsianka | ż; nowe |
| rice pudding | ryż na mleku | m; nowe |
| monkey cube | małpia kostka | ż; nowe; analogicznie „krowia kostka”, „kozia kostka” |
| gołąbki / żurek / kremówka | gołąbki / żurek / kremówka | istniejące (polskie dania Aquili) |

## 19. Napoje bezalkoholowe i marki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| water | woda | ż; istniejące |
| ice | lód | m; istniejące |
| soda water | woda sodowa | ż; nowe |
| tonic water | tonik | m; nowe |
| coffee | kawa | ż; istniejące |
| iced coffee | mrożona kawa | ż; nowe |
| cafe latte / soy latte | kawa latte / latte sojowe | ż / n; nowe |
| tea | herbata | ż; istniejące |
| iced tea | mrożona herbata | ż; nowe |
| hot chocolate | gorąca czekolada | ż; nowe |
| milk / soy milk | mleko / mleko sojowe | n; istniejące / nowe |
| chocolate milk | mleko czekoladowe | n; nowe |
| juice | sok | m; istniejące (33×) |
| apple / orange / tomato juice | sok jabłkowy / pomarańczowy / pomidorowy | m; istniejące („sok pomidorowy”) |
| lemon / lime juice | sok z cytryny / sok z limonki | m; nowe |
| carrot / grape / berry juice | sok marchwiowy / winogronowy / jagodowy | m; nowe |
| watermelon / pineapple / peach juice | sok arbuzowy / ananasowy / brzoskwiniowy | m; nowe |
| lemonade | lemoniada | ż; nowe |
| cola | cola | ż; nowe |
| Space Cola | Kosmiczna Cola | ż; nowe (zasada z planu) |
| Nuka Cola | Nuka Cola | ż; nowe (marka bez zmian) |
| Dr. Gibb | Dr. Gibb | m; nowe (marka bez zmian) |
| Space-Up! | Kosmo-Up! | m; nowe |
| Space Mountain Wind | Kosmiczny Górski Wiatr | m; nowe |
| Lemon Lime | Cytrynowo-Limonkowy | m; nowe |
| Grey Bull | Szary Byk | m; nowe |
| Monkey Energy | Małpia Energia | ż; nowe |
| Thirteen Loko | Trzynaście Loko | n; nowe |
| Pwr Game | Pwr Game | ż; nowe (gra słów, bez zmian) |
| orange soda / grape soda | oranżada / oranżada winogronowa | ż; nowe |
| cream soda | oranżada śmietankowa | ż; nowe |
| Shambler's Juice | Sok Shamblera | m; nowe |
| Tymbark / Helena | bez zmian | istniejące (polskie marki Aquili) |

## 20. Alkohole i koktajle

Zasada: prawdziwe koktajle z ustaloną nazwą w polskich barach zostawiamy (Margarita, Mojito, Cuba Libre, Manhattan, Martini, Pina Colada, Tequila Sunrise, B-52, Kamikaze, Sidecar, Stinger, Mai Tai). Tam, gdzie polska nazwa jest w użyciu, bierzemy ją. Fikcyjne drinki SS13 tłumaczymy dosłownie albo z grą słów.

| EN | PL | rodzaj/uwagi |
|---|---|---|
| beer | piwo | n; istniejące |
| light beer | piwo lekkie | n; nowe |
| green beer | zielone piwo | n; istniejące |
| iced beer | mrożone piwo | n; nowe |
| ale | ale | n/ndm; nowe |
| Trappist beer | piwo trapistów | n; nowe |
| wine | wino | n; istniejące |
| fruit wine | wino owocowe | n; nowe |
| lizard wine | wino jaszczurcze | n; nowe |
| champagne | szampan | m; nowe |
| vodka | wódka | ż; istniejące (12×) |
| whiskey | whisky | ż/ndm; istniejące (9×) |
| rum | rum | m; istniejące |
| gin | gin | m; istniejące |
| tequila | tequila | ż; istniejące |
| vermouth | wermut | m; nowe |
| cognac | koniak | m; nowe |
| absinthe | absynt | m; nowe |
| sake | sake | n/ndm; nowe |
| mead | miód pitny | m; istniejące |
| red mead | czerwony miód pitny | m; nowe |
| hooch | bimber | m; nowe |
| moonshine | samogon | m; nowe |
| hard cider | cydr | m; nowe |
| applejack | wódka jabłkowa | ż; nowe |
| grappa / fernet / kahlua / goldschlager | grappa / fernet / Kahlua / Goldschläger | nowe (nazwy trunków) |
| triple sec | triple sec | m; nowe |
| grenadine | grenadyna | ż; nowe |
| creme de menthe | likier miętowy | m; nowe |
| creme de cacao | likier kakaowy | m; nowe |
| creme de coconut | likier kokosowy | m; nowe |
| Irish cream | likier irlandzki | m; nowe |
| eggnog | ajerkoniak | m; nowe |
| grog / sbiten | grog / sbiteń | m; nowe |
| Bloody Mary | Krwawa Mary | ż; nowe |
| Black Russian | Czarny Rosjanin | m; nowe |
| White Russian | Biały Rosjanin | m; nowe |
| Screwdriver | Śrubokręt | m; nowe (spójnie z narzędziem) |
| Gin and Tonic | gin z tonikiem | m; nowe |
| Vodka and Tonic | wódka z tonikiem | ż; nowe |
| Rum and Coke | rum z colą | m; nowe |
| Whiskey Cola / Whiskey Soda | whisky z colą / whisky z wodą sodową | ż; nowe |
| Irish Coffee | kawa po irlandzku | ż; nowe |
| Long Island Iced Tea | Long Island Iced Tea | ż; nowe |
| Classic Martini / Vodka Martini | Martini klasyczne / Wódka Martini | n / ż; nowe |
| Alexander | Aleksander | m; nowe |
| Grasshopper | Konik Polny | m; nowe |
| Brave Bull | Dzielny Byk | m; nowe |
| Snow White | Królewna Śnieżka | ż; nowe |
| Between the Sheets | Między Prześcieradłami | nowe |
| Atomic Bomb | Bomba Atomowa | ż; nowe |
| Manhattan Project | Projekt Manhattan | m; nowe |
| Irish Car Bomb | Irlandzka Bomba Samochodowa | ż; nowe |
| Three Mile Island Iced Tea | Mrożona Herbata z Three Mile Island | ż; nowe |
| Pan-Galactic Gargle Blaster | Pangalaktyczny Gardłogrzmot | m; nowe (nazwa z polskiego przekładu Adamsa) |
| Beepsky Smash | Cios Beepsky'ego | m; nowe |
| Toxins Special | Specjał Toksyn | m; nowe |
| The Doctor's Delight | Rozkosz Doktora | ż; nowe |
| Hippie's Delight | Rozkosz Hipisa | ż; nowe |
| Demon's Blood | Krew Demona | ż; nowe |
| Devil's Kiss | Pocałunek Diabła | m; nowe |
| Changeling Sting | Żądło Zmiennokształtnego | n; nowe (spójnie z „Zmiennokształtny”) |
| Syndicate Bomb | Bomba Syndykatu | ż; nowe |
| Neurotoxin | Neurotoksyna | ż; nowe |
| Silencer | Tłumik | m; nowe |
| Hearty Punch | Pożywny Poncz | m; nowe |
| Planet Cracker | Rozłupywacz Planet | m; nowe |
| Liquid Electricity | Płynna Elektryczność | ż; nowe |
| Bacchus' Blessing | Błogosławieństwo Bachusa | n; nowe |
| Clown's Tears | Łzy Klauna | mn; nowe |
| Banana Honk | Bananowy Honk | m; nowe |
| Bilk | Mlekopiwo | n; nowe |
| Booger | Glut | m; nowe |
| Red Queen | Czerwona Królowa | ż; nowe |
| Old Timer | Staruszek | m; nowe |
| Barefoot | Na Bosaka | nowe |
| Andalusia | Andaluzja | ż; nowe |
| Allies Cocktail | Koktajl Sojuszników | m; nowe |
| Sugar Rush | Cukrowy Haj | m; nowe |
| Fourth Wall | Czwarta Ściana | ż; nowe |
| Blank Paper | Czysta Kartka | ż; nowe |
| Laughter / Super Laughter | Śmiech / Superśmiech | m; nowe |
| Nothing | Nic | n; nowe |
| The Manly Dorf | Męski Krasnolud | m; nowe |
| Amasec / Singulo / Turbo / Duplex | Amasec / Singulo / Turbo / Dupleks | nowe (nazwy własne) |
| cocktail / drink | koktajl / drink | m; istniejące |

## 21. Botanika: rośliny i plony

Wszystkie nazwy roślin i plonów są już przetłumaczone w porcie botaniki (`aquila/code/modules/botany`). Stare typy `/obj/item/food/grown/...` i nasiona w core dostają te same nazwy.

| EN | PL | rodzaj/uwagi |
|---|---|---|
| plant | roślina | ż; istniejące (131×) |
| seeds | nasiona | mn; istniejące |
| spores (grzyby) | zarodniki | mn; istniejące |
| hydroponics tray | taca hydroponiczna | ż; istniejące |
| soil plot | grządka | ż; istniejące |
| seed extractor | ekstraktor nasion | m; nowe |
| plant DNA manipulator | manipulator DNA roślin | m; nowe |
| biogenerator | biogenerator | m; istniejące (8×) |
| weeds | chwasty | mn; istniejące |
| pests | szkodniki | mn; istniejące |
| harvest / yield | plon | m; istniejące |
| nutrient (botany) | nawóz | m; istniejące (5×) |
| E-Z-Nutrient / Left 4 Zed / Robust Harvest | bez zmian | istniejące („E-Z-Nutrient”, marki nawozów) |
| weed killer / Plant-B-Gone | środek chwastobójczy | m; nowe |
| pest killer | pestycyd | m; istniejące |
| watering can | konewka | ż; nowe |
| apple / golden apple | jabłko / złote jabłko | n; istniejące |
| banana / banana peel | banan / skórka od banana | m / ż; istniejące / nowe |
| cherries / blue cherries | wiśnie / niebieskie wiśnie | mn; istniejące |
| cherry bulbs / cherry bombs | wiśnie żarówkowe / wiśniowe bomby | mn; istniejące |
| lemon / lime / orange | cytryna / limonka / pomarańcza | ż; istniejące |
| combustible lemon | wybuchowa cytryna | ż; istniejące |
| extradimensional orange | pozawymiarowa pomarańcza | ż; istniejące |
| grapes / green grapes | winogrona / zielone winogrona | mn; istniejące |
| berries / poison-berries / death-berries / glow-berries | jagody / trujące jagody / jagody śmierci / świecące jagody | mn; istniejące |
| pineapple | ananas | m; istniejące |
| watermelon / holymelon | arbuz / święty arbuz | m; istniejące |
| pumpkin / blumpkin | dynia / niebieska dynia | ż; istniejące |
| tomato | pomidor | m; istniejące |
| blue-tomato / blood-tomato / killer-tomato | niebieski pomidor / krwisty pomidor / pomidor zabójca | m; istniejące |
| bluespace tomato | bluespace'owy pomidor | m; istniejące |
| potato / sweet potato | ziemniak / batat | m; istniejące |
| carrot / parsnip | marchew / pasternak | ż / m; istniejące |
| red beet / white-beet | czerwony burak / biały burak | m; istniejące |
| onion / red onion | cebula / czerwona cebula | ż; istniejące |
| garlic | czosnek | m; istniejące |
| cabbage | kapusta | ż; istniejące |
| eggplant / egg-plant | bakłażan / bakłażan jajeczny | m; istniejące |
| chili / ice pepper / ghost chili | chili / lodowa papryka / upiorne chili | n/ndm / ż / n; istniejące |
| ear of corn | kolba kukurydzy | ż; istniejące |
| wheat / oat / rice | pszenica / owies / ryż | ż / m / m; istniejące |
| meatwheat | mięsopszenica | ż; istniejące |
| soybeans / koibean | soja / fasola koi | ż; istniejące |
| sugarcane | trzcina cukrowa | ż; istniejące |
| cocoa pod | strąk kakaowca | m; nowe („kakaowiec” istniejące) |
| vanilla pod | laska wanilii | ż; nowe |
| coffee arabica / robusta beans | ziarna kawy arabika / robusta | mn; istniejące („kawa robusta”, „ziarna kawy”) |
| tea leaves (aspera / astra) | liść herbaty / liść herbaty astra | m; istniejące |
| tobacco leaves / space tobacco | liście tytoniu / kosmiczny tytoń | mn / m; istniejące |
| cannabis leaf | liść konopi | m; istniejące („konopie”) |
| ambrosia vulgaris / deus / gaia | ambrozja pospolita / boska / Gai | ż; istniejące |
| cactus fruit | owoc kaktusa | m; nowe („kaktus popielny” istniejące) |
| bungo fruit / bungo pit | owoc bungo / pestka bungo | m / ż; istniejące („bungo”) |
| gatfruit | giwerowoc | m; istniejące |
| fly amanita / destroying angel | muchomor czerwony / muchomor jadowity | m; istniejące |
| liberty-cap | łysiczka lancetowata | ż; istniejące |
| plump-helmet | pulchny hełm | m; istniejące |
| chanterelle | kurka | ż; istniejące |
| reishi | reishi | m/ndm; istniejące |
| glowshroom / glowcap / shadowshroom | świecący grzyb / świecący kapelusz / cienisty grzyb | m; istniejące |
| walking mushroom | chodzący grzyb | m; istniejące |
| jupiter cup | czasza Jowisza | ż; istniejące |
| tower-cap / steel-cap / embershroom | grzyb wieżowy / grzyb stalowy / żarogrzyb | m; istniejące |
| poppy / lily / geranium / harebell | mak / lilia / pelargonia / dzwonek | m / ż / ż / m; istniejące |
| sunflower / moonflower / novaflower | słonecznik / kwiat księżycowy / kwiat supernowej | m; istniejące |
| rainbow flower / forget-me-not | tęczowy kwiat / niezapominajka | m / ż; istniejące |
| nettle / deathnettle | pokrzywa / pokrzywa śmierci | ż; istniejące |
| galaxythistle / starthistle | galaktyczny oset / oset gwiaździsty | m; istniejące |
| grass / fairygrass / carpet | trawa / trawa wróżek / dywan | ż / ż / m; istniejące |
| kudzu pod | strąk kudzu | m; istniejące |
| replica pod | strąk replikujący | m; istniejące |
| buttflower / corpse flower | kwiat-tyłek / kwiat trupi | m; istniejące |
| spaceman's trumpet | trąbka kosmonauty | ż; istniejące |
| cotton / durathread plant | bawełna / duranitka | ż; istniejące |
| bamboo | bambus | m; istniejące |
| tree / log | drzewo / kłoda | n / ż; istniejące |
| leaf / stem / root / branch | liść / łodyga / korzeń / gałązka | m / ż / m / ż; istniejące |
| fruit / vegetable | owoc / warzywo | m / n; istniejące |
| mimana | mimana | ż; istniejące |

## 22. Częste przymiotniki i określenia w nazwach

| EN | PL | rodzaj/uwagi |
|---|---|---|
| advanced | zaawansowany | istniejące |
| basic | podstawowy | nowe |
| standard | standardowy | nowe |
| improved / upgraded | ulepszony | nowe |
| experimental | eksperymentalny | istniejące |
| prototype | prototypowy | nowe |
| improvised / makeshift | prowizoryczny | nowe |
| reinforced | wzmocniony | istniejące (44×) |
| heavy / light | ciężki / lekki | istniejące |
| compact | kompaktowy | nowe |
| portable | przenośny | nowe |
| emergency | awaryjny | nowe |
| industrial | przemysłowy | istniejące („siewnik przemysłowy”) |
| tactical | taktyczny | istniejące |
| combat | bojowy | istniejące |
| military | wojskowy | nowe |
| civilian | cywilny | istniejące |
| elite | elitarny | nowe |
| deluxe | deluxe | nowe |
| suspicious | podejrzany | istniejące |
| strange / mysterious | dziwny / tajemniczy | istniejące |
| old / ancient | stary / starożytny | nowe |
| broken | zepsuty | nowe |
| damaged | uszkodzony | istniejące |
| burnt (elektronika) | spalony | istniejące („spalona płytka konsoli”) |
| empty / full | pusty / pełny | istniejące |
| fake / replica | replika X | istniejące („replika hełmu”) |
| toy | zabawkowy | istniejące |
| golden / silver | złoty / srebrny | istniejące |
| rainbow | tęczowy | istniejące |
| insulated | izolacyjny | nowe |
| fireproof | ognioodporny | istniejące |
| radiation (ochrona) | przeciwradiacyjny | nowe |
| energy | energetyczny | istniejące (60×) |
| plasma (przym.) | plazmowy | istniejące |
| ion | jonowy | istniejące |
| pulse | pulsacyjny | istniejące |
| kinetic | kinetyczny | istniejące |
| sonic | soniczny | nowe |
| bulletproof | kuloodporny | istniejące |
| armored | opancerzony | nowe |
| secure | zabezpieczony | istniejące (18×) |
| holographic | holograficzny | nowe |
| cybernetic | cybernetyczny | nowe |
| robotic | robotyczny | nowe |
| electric | elektryczny | nowe |
| magnetic | magnetyczny | istniejące |
| mechanical | mechaniczny | nowe |
| medical | medyczny | istniejące (94×) |
| engineering | inżynieryjny | istniejące (24×) |
| science | naukowy | istniejące (72×) |
| cargo / supply | zaopatrzenia | istniejące (101×) |
| mining | górniczy | istniejące |
| captain's | kapitana | istniejące (60×) |
| clown's / mime's | klauna / mima | istniejące („maska klauna”) |

## 23. Czynności techniczne (czasowniki w komunikatach)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| anchor / secure (wrench) | przykręcić / przykręcasz | istniejące (160×); „przymocować” (56×) dla rzeczy bez śrub |
| unanchor / unsecure | odkręcić / odkręcasz | istniejące (256×) |
| weld | zespawać / spawać | istniejące |
| unweld | odspawać | istniejące (19×); odrzucone: rozspawać (11×) |
| pry (crowbar) | podważyć | istniejące (46×) |
| cut (wirecutters) | przeciąć | istniejące |
| pulse (multitool) | wysłać impuls / pulsować przewód | istniejące („impuls” 48×) |
| screw / unscrew (panel) | przykręcić / odkręcić panel | istniejące |
| maintenance panel / wire panel | panel serwisowy | m; istniejące (52×) |
| deconstruct / disassemble | rozebrać | istniejące (71×) |
| construct / build | zbudować | istniejące |
| repair | naprawić | istniejące |
| hack | zhakować | istniejące |
| bolts (airlock) | rygle | mn; istniejące (23×) |
| bolted | zaryglowany | istniejące |
| electrified | pod napięciem | istniejące |
| turn on / off | włączyć / wyłączyć | istniejące |
| toggle | przełączyć | istniejące |
| charge / recharge | ładunek / naładować | istniejące |
| insert | włożyć | istniejące |
| eject | wyjąć | istniejące („wyjmij” 26×) |
| load / unload | załadować / rozładować | istniejące |
| fuel / welding fuel | paliwo / paliwo spawalnicze | n; istniejące |

## 24. Terminy utrwalone przy tłumaczeniu całości (październik 2026)

Hasła zgłoszone przez tłumaczy paczek i sprawdzone w kodzie. Projekt (`/datum/design`), przepis stacka i nazwa przedmiotu mają używać tej samej nazwy (projekt z wielkiej litery).

| EN | PL | rodzaj/uwagi |
|---|---|---|
| airlock electronics | elektronika śluzy | ż; projekt: „Elektronika śluzy” |
| film cartridge | kaseta z kliszą | ż; odrzucone: „wkład z kliszą do aparatu” |
| toner cartridge | kartridż z tonerem | m; duży / ogromny kartridż z tonerem |
| picture frame | ramka na zdjęcie | ż |
| paper cutter | gilotyna do papieru | ż |
| filing cabinet / chest drawer | szafka na dokumenty / komoda | ż |
| rubber stamp | pieczątka | ż; „pieczątka kapitana”, „pieczątka ZATWIERDZONO” |
| fountain pen / four-color pen | pióro wieczne / długopis czterokolorowy | n / m |
| destination tagger | znakownik adresowy | m |
| parcel / large parcel | paczka / duża paczka | ż |
| price tagger | metkownica | ż |
| hand labeler | etykieciarka | ż (już w sekcji 1) |
| evidence bag | torebka na dowody | ż; odrzucone: „torba na dowody” |
| design disk / component design disk | dysk z projektami / dysk z projektami komponentów | m; odrzucone: „dysk na projekty” |
| hard disk drive / solid state drive | dysk twardy / dysk SSD | m |
| network card | karta sieciowa | ż |
| processor board / microprocessor | płytka procesora / mikroprocesor | ż / m |
| modular microcomputer | mikrokomputer modułowy | m |
| job data disk | dysk z danymi zawodowymi | m |
| PDA (wariant stanowiska) | PDA + dopełniacz zawodu | „PDA klauna”, „wojskowe PDA” |
| microwave | mikrofalówka | ż; odrzucone: „kuchenka mikrofalowa” |
| reagent grinder (all-in-one) | młynek wielofunkcyjny | m; odrzucone: „rozdrabniacz” |
| dish drive | zbieracz naczyń | m |
| payment stand | stojak płatniczy | m |
| mining / exploration vendor | automat ze sprzętem górniczym / automat ze sprzętem odkrywców | m |
| cloning console | konsola klonowania | ż |
| inflatable wall | nadmuchiwana ściana | ż |
| transit tube | rura transportowa | ż |
| reflector | reflektor | m; rama: „podstawa reflektora” |
| notice board | tablica ogłoszeń | ż |
| trophy display case | gablota na trofea | ż |
| sign backing | podkład znaku | m |
| urinal cake / rubber ducky | kostka do pisuaru / gumowa kaczuszka | ż |
| swimming pool / pool ladder | basen / drabinka basenowa | m / ż |
| sandstone brick | cegła z piaskowca | ż |
| high-traction floor tile | antypoślizgowa płytka podłogowa | ż |
| techfloor tile | płytka techniczna | ż |
| wooden plank | drewniane deski / deska | mn / ż |
| alien X (porywacze) | obcy X | „obcy skalpel”, „obca szafka”, „obcy stół”, „zespół: obca śluza”; wyjątek: „stop obcych” (materiał) |
| tank transfer valve | zawór transferowy butli | m; odrzucone: „zawór przepustowy” |
| sticky tape / super sticky tape | taśma klejąca / superklejąca taśma | ż |
| whetstone / super whetstone | osełka / superosełka | ż |
| null rod | święty kij | m |
| riot shield / buckler | tarcza prewencyjna / puklerz | ż / m |
| telecrystal | telekryształ | m |
| space cash bill | banknot | m; „Wartość: [n] kr.” |
| skinsuit / armoured skinsuit | skafander obcisły / opancerzony skafander obcisły | m; odrzucone: „kombinezon próżniowy” |
| chronosuit | chronoskafander | m |
| envirosuit (plazmoludy) | kombinezon środowiskowy | m (już w sekcji 8); EVA: „plazmowy kombinezon środowiskowy EVA” |
| reflector vest / puffer jacket / bomber jacket | kamizelka refleksyjna / kurtka puchowa / kurtka pilotka | ż |
| cardborg suit / helmet | strój kartonborga / hełm kartonborga | m |
| welding gas mask | maska spawalnicza | ż |
| fire suit (firefighter) | kombinezon przeciwpożarowy | m; odrzucone: „kombinezon strażacki” |
| soft cap (biała) | biała czapka | ż |
| lanyard (NSV13) | smycz | ż; „smycz dowódcy drużyny” |
| MOD module (projekt) | Moduł MODsuitu: X | przedmiot: „moduł X MOD” (ten sam X w dopełniaczu, np. „moduł wiązki mikrofalowej MOD” / „Moduł MODsuitu: wiązka mikrofalowa”) |
| MOD external plating | zewnętrzne poszycie MOD | n |
| Kinetic Accelerator X Mod | Moduł kinetycznego akceleratora: X | m; odrzucone: „Mod kinetycznego…” |
| night vision X HUD/goggles | noktowizyjny X | „noktowizyjny HUD medyczny”, „noktowizyjne gogle mezonowe” |
| mech control module (płytka) | moduł sterowania uzbrojeniem i celowaniem X | m |
| railgun (okrętowy, nakładka, broń w overmapie) | railgun | m; „Współosiowe railguny”, „szyna railguna”, „podajnik railguna” |
| fighter battery | akumulator myśliwca | m; „megaakumulator myśliwca” |
| fighter canopy | osłona kokpitu | ż; „osłona kokpitu ze szkła zbrojonego” |
| hardpoint (pojazd) | punkt mocowania | m |
| torpedo warhead (bunker buster / decoy) | głowica torpedy przeciwbunkrowej / torpedy-wabika | ż |
| aircraft elevator | winda lotnicza | ż |
| boarding firing pin | iglica abordażowa | ż |
| acceleration chair | fotel przeciążeniowy | m |
| flight control console / IFF console | konsola sterowania lotem / konsola IFF | ż |
| airtight hatch | hermetyczny właz | m |
| clockwork lever / timer / pressure plate / flipper | przełącznik / mechaniczny zegar / płyta naciskowa / przerzutnik | m / m / ż / m (kult zegara) |
| cog grille / pinion airlock | zębata krata / śluza zębata | ż |
| sheetsnatcher | łapacz arkuszy | m |
| cardboard cutout | tekturowa makieta | ż |
| cookie (w nazwach) | ciasteczko | n; „ciasteczko-czaszka”, „ciasteczko przeznaczenia”; „ciastko” tylko dla biscuit/cake („maślane ciastko”) |
| liquid cooler | dystrybutor napojów | m |
| holy water flask | flaszka wody święconej | ż |


# Słownik, sekcja 03: CHEMIA I MEDYCYNA

Źródło: gałąź `tlumaczenie-calosc` (od aq33/master), stan z 27.10.2026. Część A obejmuje wszystkie 640 typów `/datum/reagent` z jawnym `name` w plikach dołączonych przez `nsv13.dme` i `aquila/aquila.dm` (core, `nsv13/`, `aquila/`). „Istniejące” znaczy, że ta polska forma (albo jej odmiana) już stoi w kodzie, w opisach, cure_text, oknach TGUI itp. „Nowe” to propozycja tego słownika.

## Zasady

- Nazwy reagentów piszemy wielką literą tylko na początku (`Kwas siarkowy`, nie `Kwas Siarkowy`). Wyjątek: nazwy własne i marki (`Krwawa Mary`, `Dr. Gibb`).
- Leki i związki o nazwach wymyślonych spolszczamy brzmieniowo: -ine → -yna/-ina (Bicaridine → Bikarydyna, Oculine → Okulina), -one/-ane → -on/-an (Rezadone → Rezadon, Kelotane → Kelotan), x → ks (Dexalin → Deksalina), c przed a/o/u → k (Calomel → Kalomel). Nazwy na -ium zostają (Teslium, Sorium, Gibbium).
- Wyjątki z istniejącego kodu mają pierwszeństwo przed regułą: Synaptizyna (nie synaptyzyna), Kriooksadon (nie kryoksadon), Spacyklina, Korazon.
- Prawdziwe substancje tłumaczymy po polsku chemicznie: Sulphuric Acid → Kwas siarkowy, Potassium Iodide → Jodek potasu, Chloral Hydrate → Wodzian chloralu.
- Nazwy organizacji: Syndicate → Syndykat (ok. 180× w kodzie), Nanotrasen bez zmian, Lavaland i bluespace bez zmian.
- Marki napojów i nawozów zostają (Space-Up, Nuka Cola, Robust Harvest). Koktajle z ustaloną nazwą międzynarodową zostają (Mojito, Cuba Libre, Long Island Iced Tea), a koktajle z grą słów tłumaczymy (Screwdriver → Śrubokręt).
- `glass_name` napojów: szklanka X, wino i mocne trunki: kieliszek X, piwo: kufel X, kawa i herbata: kubek X (wszystko już istnieje w kodzie, np. „kieliszek amareny”, „kufel zielonego piwa”). X stoi w dopełniaczu.
- W prozie opisów reagent odmieniamy normalnie (bikarydyny, kelotanu), małą literą.

## Ostrzeżenia techniczne (przeczytaj przed tłumaczeniem name)

1. **`name` reagenta jest kluczem.** `GLOB.name2reagent` (`code/modules/reagents/chemistry/reagents.dm`) mapuje `ckey(name)` na typ. Używają tego: dozownik chemiczny i jego zapisane receptury (`chem_dispenser.dm`: `dispense`, `dispense_recipe`, `save_recording`), `nsv13/.../refillable_chem_dispenser.dm`, ChemMaster (`chem_master.dm`: id w beaker_contents, `analyze`), `AutoInjectorPrinter.dm`, plumbing (`aquila/code/modules/plumbing/machinery/synthesizer.dm`, `reaction_chamber.dm`, `distributors.dm`), katalog receptur (`aquila/code/modules/reagents/recipe_catalog.dm`), `get_chem_id()` w `holder.dm`. Tłumaczenie samo w sobie nic nie psuje, bo klucze liczą się z bieżących nazw, ale dwie nazwy o tym samym ckey zleją się w jeden wpis.
2. **`ckey()` w BYOND 516 wycina polskie znaki** (sprawdzone w Dream Daemon 516.1688: `ckey("Żelazo")` = `elazo`, `ckey("Sól kuchenna")` = `slkuchenna`). Nazwy różniące się tylko ogonkami dadzą ten sam klucz. Lista z części A jest sprawdzona: nowych kolizji nie ma. Każda zmiana nazwy poza tym słownikiem wymaga ponownego sprawdzenia.
3. **Celowe duplikaty, które muszą zostać identyczne:** `/toxin/fakebeer` = `/consumable/ethanol/beer` („Piwo”, podróbka dla zemagowanych botów), `/fake_cbz` = `/concentrated_bz` („Skoncentrowane BZ”). Duplikaty odziedziczone z EN, zostawione bez zmian: `/blob/energized_jelly` i `/teslium/energized_jelly` („Naładowana galaretka”), `/mutationtoxin/zombie` i `/mutationtoxin/goofzombie` („Toksyna mutacyjna (zombie)”). Kolizja EN „Black Powder” (`/blackpowder` i `/colorful_reagent/powder/black`) znika po tłumaczeniu: „Proch strzelniczy” i „Czarny proszek”.
4. **Hardkodowane nazwy w tekstach do poprawy razem z reagentami:** `aquila/code/game/objects/items/devices/health_analyzer_ui.dm` (dexalin, synthflesh, bicaridine, styptic, kelotane, silver sulfadiazine, Pentetic acid, „potas jodowy”), `aquila/code/modules/antagonists/horror/horror_chemicals.dm` (`chemname = "epinephrine"` itd., wyświetlane graczowi), `aquila/code/modules/reagents/slime_extract_descs.dm` („frost oil”), `code/modules/mob/living/silicon/robot/robot.dm` („Restorative Nanites”), cure_text chorób po EN (`"Spaceacillin"`, `"Mutadone"`, `"Mannitol"`, `"Ethanol"`, `"Iron"`, `"Sugar"`, `"The Manly Dorf"`).
5. **Choroba „Unknown” jest kluczem.** `code/datums/diseases/advance/advance.dm` (`name = "Unknown"`, `AssignName(name = "Unknown")`), `code/modules/reagents/chemistry/machinery/pandemic.dm:87` (`disease_name == "Unknown"`) i `tgui/packages/tgui/interfaces/Pandemic/Virus.tsx:62` (`name === 'Unknown'`). Zmiana na „Nieznana” wymaga zmiany we wszystkich trzech miejscach naraz.
6. **Strefy ciała.** `parse_zone()` (`code/__HELPERS/mobs.dm`) zwraca angielskie „left arm” itd., a `strefa_pl()` (`aquila/code/__HELPERS/polish.dm`) przyjmuje te stringi jako wejście. Nie tłumaczyć `parse_zone()`, tylko w tekstach owijać strefę w `strefa_pl()`.
7. **Nazwy operacji są porównywane:** `nsv13/code/datums/components/surgery_initiator.dm:210` (`surgery.name == params["surgery_name"]`). Działa, dopóki dwie operacje dostępne na tej samej strefie nie mają tej samej polskiej nazwy.
8. `chem_master.dm` (`analyze`) ustawia stan skupienia jako „Solid/Liquid/Gas/Unknown” po EN. Okno tylko to wyświetla, więc można tłumaczyć na „Stały/Ciekły/Gazowy/Nieznany”.
9. `/datum/chemical_reaction` ma własne `name` (np. „Space Drugs”). Nie jest kluczem, w razie tłumaczenia trzymać identycznie z nazwą produktu z części A.

## Część A. Reagenty

Kolumna EN: obecne `name` i ścieżka typu bez prefiksu `/datum/reagent`. Typy bez własnego `name` dziedziczą nazwę rodzica i nie są wypisane.

### A.1 Leki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Adminordrazine (`/medicine/adminordrazine`) | Adminordrazyna | ż; nowe |
| Amphetamine (`/medicine/amphetamine`) | Amfetamina | ż; nowe |
| Anti-Toxin (`/medicine/antitoxin`) | Antytoksyna | ż; istniejące |
| Antihol (`/medicine/antihol`) | Antyhol | m; nowe |
| Atropine (`/medicine/atropine`) | Atropina | ż; nowe |
| Bicaridine (`/medicine/bicaridine`) | Bikarydyna | ż; istniejące; odrzucony wariant: bikaridyna (komentarz chemplants.dm) |
| Calomel (`/medicine/calomel`) | Kalomel | m; nowe |
| Carthatoline (`/medicine/carthatoline`) | Kartatolina | ż; istniejące |
| Changeling Adrenaline (`/medicine/changelingadrenaline`) | Adrenalina zmiennokształtnego | ż; nowe |
| Changeling Haste (`/medicine/changelinghaste`) | Pośpiech zmiennokształtnego | m; nowe |
| Charcoal (`/medicine/charcoal`) | Węgiel aktywowany | m; istniejące; health_analyzer_ui.dm; /carbon to sam „Węgiel” |
| Clonexadone (`/medicine/clonexadone`) | Klonoksadon | m; istniejące |
| Corazone (`/medicine/corazone`) | Korazon | m; istniejące; cure_text zawału |
| Cryoxadone (`/medicine/cryoxadone`) | Kriooksadon | m; istniejące; odrzucony wariant: kryoksadon |
| Dexalin (`/medicine/dexalin`) | Deksalina | ż; nowe; w health_analyzer_ui.dm jest jeszcze „dexalin” |
| Dexalin Plus (`/medicine/dexalinp`) | Deksalina Plus | ż; nowe |
| Diphen-Synaptizine (`/medicine/synaphydramine`) | Difeno-synaptizyna | ż; nowe |
| Diphenhydramine (`/medicine/diphenhydramine`) | Difenhydramina | ż; nowe |
| Earthsblood (`/medicine/earthsblood`) | Krew ziemi | ż; nowe |
| Ephedrine (`/medicine/ephedrine`) | Efedryna | ż; istniejące |
| Epinephrine (`/medicine/epinephrine`) | Epinefryna | ż; istniejące |
| Godblood (`/medicine/omnizine/godblood`) | Krew boga | ż; nowe |
| Haloperidol (`/medicine/haloperidol`) | Haloperidol | m; istniejące; bez zmian |
| Hepanephrodaxon (`/medicine/hepanephrodaxon`) | Hepanefrodakson | m; nowe |
| Inacusiate (`/medicine/inacusiate`) | Inakuzjat | m; nowe |
| Inaprovaline (`/medicine/inaprovaline`) | Inaprowalina | ż; nowe |
| Insulin (`/medicine/insulin`) | Insulina | ż; nowe |
| Kelotane (`/medicine/kelotane`) | Kelotan | m; istniejące; „kelotanu” w botanice |
| Lavaland Extract (`/medicine/lavaland_extract`) | Wyciąg z Lavalandu | m; istniejące; „Lavaland” zostaje (15× w kodzie) |
| Leporazine (`/medicine/leporazine`) | Leporazyna | ż; istniejące |
| Liquid Solder (`/medicine/liquid_solder`) | Płynny lut | m; nowe |
| Mannitol (`/medicine/mannitol`) | Mannitol | m; istniejące; bez zmian |
| Meclizine (`/medicine/meclizine`) | Meklizyna | ż; nowe |
| Medicine (`/medicine`) | Lek | m; istniejące; bazowy |
| Miner's Salve (`/medicine/mine_salve`) | Maść górnicza | ż; nowe |
| Modafinil (`/medicine/modafinil`) | Modafinil | m; nowe; bez zmian |
| Morphine (`/medicine/morphine`) | Morfina | ż; istniejące |
| Muscle Stimulant (`/medicine/muscle_stimulant`) | Stymulant mięśni | m; nowe |
| Mutadone (`/medicine/mutadone`) | Mutadon | m; istniejące |
| Neurine (`/medicine/neurine`) | Neuryna | ż; nowe |
| Oculine (`/medicine/oculine`) | Okulina | ż; istniejące |
| Omnizine (`/medicine/omnizine`) | Omnizyna | ż; istniejące |
| Oxandrolone (`/medicine/oxandrolone`) | Oksandrolon | m; nowe |
| Pentetic Acid (`/medicine/pen_acid`) | Kwas pentetowy | m; nowe; w health_analyzer_ui.dm jeszcze „Pentetic acid” |
| Perfluorodecalin (`/medicine/perfluorodecalin`) | Perfluorodekalina | ż; nowe |
| Polypyrylium Oligomers (`/medicine/polypyr`) | Oligomery polipiryliowe | mnoga; nowe |
| Potassium Iodide (`/medicine/potass_iodide`) | Jodek potasu | m; nowe; odrzucony wariant „potas jodowy” (health_analyzer_ui.dm) – błędny |
| Psicodine (`/medicine/psicodine`) | Psykodyna | ż; nowe |
| Pump-Up (`/medicine/pumpup`) | Pump-Up | m; nowe; marka; bez zmian |
| Pyroxadone (`/medicine/pyroxadone`) | Pirooksadon | m; nowe; analogicznie do kriooksadonu |
| Quantum Medicine (`/medicine/adminordrazine/quantum_heal`) | Lek kwantowy | m; nowe |
| Radioactive Disinfectant (`/medicine/radioactive_disinfectant`) | Radioaktywny środek dezynfekujący | m; nowe; plik: `nsv13/code/modules/reagents/chemistry/reagents/nsv_medicine_reagents.dm` |
| Regenerative Jelly (`/medicine/regen_jelly`) | Galaretka regeneracyjna | ż; istniejące; slime_extract_descs.dm |
| Regenerative Ooze (`/medicine/regen_ooze`) | Maź regeneracyjna | ż; nowe |
| Restorative Nanites (`/medicine/syndicate_nanites`) | Nanity naprawcze | mnoga; nowe; robot.dm (Syndykat) ma jeszcze „Restorative Nanites” |
| Rezadone (`/medicine/rezadone`) | Rezadon | m; istniejące |
| Salbutamol (`/medicine/salbutamol`) | Salbutamol | m; istniejące; bez zmian |
| Salicyclic Acid (`/medicine/sal_acid`) | Kwas salicylowy | m; nowe; w horror_chemicals.dm „salicylic acid” |
| Saline-Glucose Solution (`/medicine/salglu_solution`) | Sól fizjologiczna z glukozą | ż; nowe; „sól fizjologiczna” już w analizatorze |
| Silibinin (`/medicine/silibinin`) | Sylibinina | ż; nowe |
| Silver Sulfadiazine (`/medicine/silver_sulfadiazine`) | Sulfadiazyna srebra | ż; nowe |
| Spaceacillin (`/medicine/spaceacillin`) | Spacyklina | ż; istniejące |
| Stabilizing nanites (`/medicine/stabilizing_nanites`) | Nanity stabilizujące | mnoga; nowe |
| Stoperan (`/medicine/stoperan`) | Stoperan | m; istniejące; plik: `aquila/code/modules/reagents/chemistry/reagents/stoperan.dm`; bez zmian |
| Strange Reagent (`/medicine/strange_reagent`) | Dziwny odczynnik | m; nowe; reagent = odczynnik |
| Styptic Powder (`/medicine/styptic_powder`) | Proszek hemostatyczny | m; nowe; w analizatorze jeszcze „styptic” |
| Synaptizine (`/medicine/synaptizine`) | Synaptizyna | ż; istniejące; cure_text „Synaptizyna i siarka”; nie „synaptyzyna” |
| Synthflesh (`/medicine/synthflesh`) | Syntetyczne ciało | n; istniejące; „j. syntetycznego ciała”; analizator ma jeszcze „synthflesh” |
| System Cleaner (`/medicine/system_cleaner`) | Czyścik systemowy | m; nowe |
| Tricordrazine (`/medicine/tricordrazine`) | Trikordrazyna | ż; nowe |

### A.2 Toksyny i trucizny

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Amanitin (`/toxin/amanitin`) | Amanityna | ż; nowe |
| Amatoxin (`/toxin/amatoxin`) | Amatoksyna | ż; nowe |
| Anacea (`/toxin/anacea`) | Anacea | ż; nowe; bez zmian |
| Bad Food (`/toxin/bad_food`) | Zepsute jedzenie | n; nowe |
| Beer (`/toxin/fakebeer`) | Piwo | n; istniejące; MUSI być identyczne z /consumable/ethanol/beer (podróbka) |
| Bone Hurting Juice (`/toxin/bonehurtingjuice`) | Sok bolących kości | m; nowe |
| Bungotoxin (`/toxin/bungotoxin`) | Bungotoksyna | ż; nowe |
| Burning Spore Toxin (`/toxin/spore_burning`) | Paląca toksyna zarodników | ż; nowe |
| Carnivorous Blood (`/toxin/carnivorousblood`) | Mięsożerna krew | ż; nowe; plik: `aquila/code/modules/reagents/carnivorous_blood.dm` |
| Carpotoxin (`/toxin/carpotoxin`) | Karpotoksyna | ż; nowe |
| Chloral Hydrate (`/toxin/chloralhydrate`) | Wodzian chloralu | m; istniejące |
| Coffee Grounds (`/toxin/coffeepowder`) | Kawa mielona | ż; nowe |
| Coniine (`/toxin/coniine`) | Koniina | ż; istniejące |
| Curare (`/toxin/curare`) | Kurara | ż; nowe |
| Cyanide (`/toxin/cyanide`) | Cyjanek | m; nowe |
| Fentanyl (`/toxin/fentanyl`) | Fentanyl | m; istniejące; bez zmian |
| Formaldehyde (`/toxin/formaldehyde`) | Formaldehyd | m; istniejące |
| Ghoul Powder (`/toxin/ghoulpowder`) | Proszek ghula | m; istniejące; „ghul” już w kodzie |
| Gibbium (`/toxin/gibbium`) | Gibbium | n; istniejące; plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm`; bez zmian |
| Ground Tea Leaves (`/toxin/teapowder`) | Mielone liście herbaty | mnoga; nowe |
| Heparin (`/toxin/heparin`) | Heparyna | ż; istniejące |
| Histamine (`/toxin/histamine`) | Histamina | ż; istniejące |
| Initropidril (`/toxin/initropidril`) | Initropidryl | m; nowe |
| Itching Powder (`/toxin/itching_powder`) | Proszek swędzący | m; nowe |
| Leaper venom (`/toxin/leaper_venom`) | Jad skoczka | m; istniejące; opis już: „skoczki”; plik: `code/modules/mob/living/simple_animal/hostile/jungle/leaper.dm` |
| Lexorin (`/toxin/lexorin`) | Leksoryna | ż; nowe |
| Lipolicide (`/toxin/lipolicide`) | Lipolicyd | m; istniejące |
| Metabolism Override Toxin (`/toxin/munchyserum`) | Toksyna nadpisująca metabolizm | ż; nowe; plik: `nsv13/code/modules/recycling/replicatorDS.dm` |
| Mime's Bane (`/toxin/mimesbane`) | Zguba mima | ż; nowe |
| Mindbreaker Toxin (`/toxin/mindbreaker`) | Toksyna łamiąca umysł | ż; nowe |
| Mint Toxin (`/toxin/minttoxin`) | Toksyna miętowa | ż; nowe |
| Morph venom (`/toxin/morphvenom`) | Jad morfa | m; istniejące; „morfem” już w kodzie |
| Mute Toxin (`/toxin/mutetoxin`) | Toksyna niemoty | ż; nowe |
| Pancuronium (`/toxin/pancuronium`) | Pankuronium | n; istniejące |
| Pest Killer (`/toxin/pestkiller`) | Środek na szkodniki | m; nowe |
| Plant-B-Gone (`/toxin/plantbgone`) | Plant-B-Gone | m; nowe; marka; bez zmian |
| Rotatium (`/toxin/rotatium`) | Rotatium | n; nowe; bez zmian |
| Slime Jelly (`/toxin/slimejelly`) | Galaretka ze szlamu | ż; istniejące |
| Slime Ooze (`/toxin/slimeooze`) | Maź szlamu | ż; nowe |
| Sodium Thiopental (`/toxin/sodium_thiopental`) | Tiopental sodu | m; istniejące |
| Spewium (`/toxin/spewium`) | Rzygium | n; nowe; spew = rzygać |
| Spider Serum (`/toxin/spider_serum`) | Pajęcze serum | n; nowe; plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm` |
| Spider Toxin (`/toxin/hunterspider`) | Toksyna pajęcza | ż; nowe; plik: `aquila/code/modules/antagonists/spider/spider.dm` |
| Spore Toxin (`/toxin/spore`) | Toksyna zarodników | ż; nowe |
| Sulfonal (`/toxin/sulfonal`) | Sulfonal | m; nowe; bez zmian |
| Tirizene (`/toxin/staminatoxin`) | Tiryzen | m; nowe |
| Toxin (`/toxin`) | Toksyna | ż; istniejące; bazowy |
| Toxin Microcapsules (`/toxin/delayed`) | Mikrokapsułki toksyny | mnoga; nowe |
| Unstable Mutagen (`/toxin/mutagen`) | Niestabilny mutagen | m; istniejące |
| Venom (`/toxin/venom`) | Jad | m; nowe |
| Viper Spider Toxin (`/toxin/hunterspider/viper`) | Toksyna pająka żmii | ż; istniejące; opis już mówi o „pająku żmii”; plik: `aquila/code/modules/antagonists/spider/spider.dm` |
| Weed Killer (`/toxin/plantbgone/weedkiller`) | Środek chwastobójczy | m; istniejące |
| Zombie Powder (`/toxin/zombiepowder`) | Proszek zombie | m; nowe |

### A.3 Narkotyki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Aranesp (`/drug/aranesp`) | Aranesp | m; nowe; bez zmian |
| Bath Salts (`/drug/bath_salts`) | Sole do kąpieli | mnoga; nowe |
| Bloody Eye (`/drug/bloody_eye`) | Krwawe Oko | n; nowe; plik: `nsv13/code/game/objects/items/bloody_eye.dm` |
| Crank (`/drug/crank`) | Crank | m; nowe; bez zmian |
| Drug (`/drug`) | Narkotyk | m; istniejące; bazowy |
| Fartium (`/drug/fartium`) | Fartium | n; istniejące; plik: `aquila/code/modules/butt/buttflower.dm`; bez zmian |
| Happiness (`/drug/happiness`) | Szczęście | n; nowe |
| Highjack (`/drug/highjack`) | Highjack | m; nowe; plik: `nsv13/code/modules/reagents/chemistry/reagents/drug_reagents.dm`; bez zmian |
| Ketamine (`/drug/ketamine`) | Ketamina | ż; nowe |
| Krokodil (`/drug/krokodil`) | Krokodil | m; nowe; bez zmian |
| Methamphetamine (`/drug/methamphetamine`) | Metamfetamina | ż; nowe |
| Mushroom Hallucinogen (`/drug/mushroomhallucinogen`) | Grzybowy halucynogen | m; nowe |
| Nicotine (`/drug/nicotine`) | Nikotyna | ż; istniejące |
| Space drugs (`/drug/space_drugs`) | Kosmiczne narkotyki | mnoga; nowe |

### A.4 Pierwiastki, gazy i proste związki

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Acetone (`/acetone`) | Aceton | m; nowe |
| Aluminium (`/aluminium`) | Aluminium | n; istniejące; nie „glin”; bez zmian |
| Ammonia (`/ammonia`) | Amoniak | m; istniejące |
| Ash (`/ash`) | Popiół | m; istniejące |
| Blood (`/blood`) | Krew | ż; istniejące |
| Bluespace Dust (`/bluespace`) | Pył bluespace | m; istniejące; „bluespace” zostaje |
| Bromine (`/bromine`) | Brom | m; nowe |
| BZ metabolites (`/bz_metabolites`) | Metabolity BZ | mnoga; nowe |
| Carbon (`/carbon`) | Węgiel | m; istniejące |
| Carbon Dioxide (`/carbondioxide`) | Dwutlenek węgla | m; istniejące |
| Chlorine (`/chlorine`) | Chlor | m; istniejące |
| Concentrated BZ (`/concentrated_bz`) | Skoncentrowane BZ | n; nowe; MUSI być identyczne z /fake_cbz; plik: `aquila/code/modules/reagents/chemistry/reagents/other_reagents.dm` |
| Concentrated BZ (`/fake_cbz`) | Skoncentrowane BZ | n; nowe; podróbka, MUSI udawać /concentrated_bz; plik: `aquila/code/modules/reagents/chemistry/reagents/other_reagents.dm` |
| Copper (`/copper`) | Miedź | ż; istniejące |
| Diethylamine (`/diethylamine`) | Dietyloamina | ż; nowe |
| Ethanol (`/consumable/ethanol`) | Etanol | m; istniejące |
| Fluorine (`/fluorine`) | Fluor | m; istniejące |
| Fluorosulfuric acid (`/toxin/acid/fluacid`) | Kwas fluorosulfonowy | m; istniejące |
| Glycerol (`/glycerol`) | Glicerol | m; istniejące |
| Gold (`/gold`) | Złoto | n; istniejące |
| Hell Water (`/hellwater`) | Piekielna woda | ż; nowe |
| Holy Water (`/water/holywater`) | Woda święcona | ż; istniejące |
| Hydrogen (`/hydrogen`) | Wodór | m; istniejące |
| Iodine (`/iodine`) | Jod | m; nowe |
| Iron (`/iron`) | Żelazo | n; istniejące |
| Lead Acetate (`/mercury/lead_acetate`) | Octan ołowiu | m; nowe |
| Liquid Adamantine (`/liquidadamantine`) | Płynny adamantyt | m; istniejące; „adamantytowy golem” |
| Lithium (`/lithium`) | Lit | m; nowe |
| Lye (`/lye`) | Ług | m; nowe |
| Mercury (`/mercury`) | Rtęć | ż; istniejące |
| Methane (`/methane`) | Metan | m; nowe; plik: `nsv13/code/modules/reagents/chemistry/reagents/other_reagents.dm` |
| Methanol (`/impurity/methanol`) | Metanol | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Nanomachines (`/nanomachines`) | Nanomaszyny | mnoga; istniejące |
| Nitrogen (`/nitrogen`) | Azot | m; istniejące |
| Nitrous Oxide (`/nitrous_oxide`) | Podtlenek azotu | m; nowe |
| Nitryl (`/nitryl`) | Nitryl | m; nowe; bez zmian |
| Oil (`/oil`) | Olej | m; istniejące |
| Oxygen (`/oxygen`) | Tlen | m; istniejące |
| Phenol (`/phenol`) | Fenol | m; nowe |
| Phosphorus (`/phosphorus`) | Fosfor | m; istniejące |
| Plasma (`/toxin/plasma`) | Plazma | ż; istniejące |
| Plastic Polymers (`/plastic_polymers`) | Polimery plastiku | mnoga; nowe |
| Polonium (`/toxin/polonium`) | Polon | m; nowe |
| Potassium (`/potassium`) | Potas | m; istniejące |
| Radium (`/uranium/radium`) | Rad | m; nowe |
| Saltpetre (`/saltpetre`) | Saletra | ż; istniejące |
| Silicon (`/silicon`) | Krzem | m; istniejące |
| Silver (`/silver`) | Srebro | n; istniejące |
| Sodium (`/sodium`) | Sód | m; istniejące |
| Stable Plasma (`/stable_plasma`) | Stabilna plazma | ż; nowe |
| Stimulum (`/stimulum`) | Stimulum | n; nowe; nazwa gazu zostaje; bez zmian |
| Sulfur (`/sulfur`) | Siarka | ż; istniejące |
| Sulphuric Acid (`/toxin/acid`) | Kwas siarkowy | m; nowe |
| Unholy Water (`/fuel/unholywater`) | Nieświęta woda | ż; nowe; jak „Nieświęte siły” |
| Uranium (`/uranium`) | Uran | m; istniejące |
| Water (`/water`) | Woda | ż; istniejące |
| Welding Fuel (`/fuel`) | Paliwo spawalnicze | n; istniejące |

### A.5 Pirotechnika i piany

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Black Powder (`/blackpowder`) | Proch strzelniczy | m; istniejące; „proch” już w kodzie |
| Chlorine Trifluoride (`/clf3`) | Trifluorek chloru | m; nowe |
| Cryogenic Tyrosene" // implies there's normal Tyrosene but it sounds cooler (`/cryogenic_fuel`) | Kriogeniczny tyrozen | m; nowe; plik: `nsv13/code/modules/reagents/chemistry/reagents/pyrotechnic_reagents.dm` |
| Cryostylane (`/cryostylane`) | Kriostylan | m; istniejące |
| Energized Jelly (`/teslium/energized_jelly`) | Naładowana galaretka | ż; nowe; w EN ta sama nazwa co szczep bloba; zostawiamy wspólną |
| Energized Ooze (`/teslium/energized_jelly/energized_ooze`) | Naładowana maź | ż; nowe |
| Firefighting Foam (`/firefighting_foam`) | Piana gaśnicza | ż; nowe |
| Flash Powder (`/flash_powder`) | Proszek błyskowy | m; nowe |
| Fluorosurfactant (`/fluorosurfactant`) | Fluorosurfaktant | m; nowe |
| Foaming agent (`/foaming_agent`) | Środek pianotwórczy | m; nowe |
| Liquid Dark Matter (`/liquid_dark_matter`) | Płynna ciemna materia | ż; istniejące; „ciemna materia” |
| Napalm (`/napalm`) | Napalm | m; nowe; bez zmian |
| Nitroglycerin (`/nitroglycerin`) | Nitrogliceryna | ż; istniejące |
| Phlogiston (`/phlogiston`) | Flogiston | m; istniejące |
| Pyrosium (`/pyrosium`) | Pyrosium | n; istniejące; pisownia jak w opisie; bez zmian |
| Smart foaming agent (`/smart_foaming_agent`) | Inteligentny środek pianotwórczy | m; nowe |
| Smoke Powder (`/smoke_powder`) | Proszek dymny | m; nowe |
| Sonic Powder (`/sonic_powder`) | Proszek dźwiękowy | m; nowe |
| Sorium (`/sorium`) | Sorium | n; istniejące; bez zmian |
| Stabilizing Agent (`/stabilizing_agent`) | Środek stabilizujący | m; nowe |
| Teslium (`/teslium`) | Teslium | n; istniejące; bez zmian |
| Thermite (`/thermite`) | Termit | m; istniejące |

### A.6 Alkohole i koktajle

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Absinthe (`/consumable/ethanol/absinthe`) | Absynt | m; istniejące |
| Acid Spit (`/consumable/ethanol/acid_spit`) | Kwaśna plwocina | ż; nowe |
| Ale (`/consumable/ethanol/ale`) | Ale | n; istniejące; „kufel pysznego ale”; bez zmian |
| Alexander (`/consumable/ethanol/alexander`) | Alexander | m; nowe; nazwa koktajlu bez zmian; bez zmian |
| Allies Cocktail (`/consumable/ethanol/alliescocktail`) | Koktajl Aliantów | m; nowe |
| Aloe (`/consumable/ethanol/aloe`) | Aloes | m; nowe |
| Amarena (`/consumable/ethanol/amarena`) | Amarena | ż; istniejące; glass_name już „kieliszek amareny”; plik: `aquila/code/modules/reagents/chemistry/reagents/alcohol_reagents.dm`; bez zmian |
| Amasec (`/consumable/ethanol/amasec`) | Amasec | m; nowe; bez zmian |
| Andalusia (`/consumable/ethanol/andalusia`) | Andaluzja | ż; nowe |
| Anti-freeze (`/consumable/ethanol/antifreeze`) | Płyn niezamarzający | m; nowe |
| Applejack (`/consumable/ethanol/applejack`) | Applejack | m; nowe; brandy jabłkowa, nazwa bez zmian; bez zmian |
| Atomic Bomb (`/consumable/ethanol/atomicbomb`) | Bomba atomowa | ż; nowe |
| B-52 (`/consumable/ethanol/b52`) | B-52 | m; nowe; bez zmian |
| Bacchus' Blessing (`/consumable/ethanol/bacchus_blessing`) | Błogosławieństwo Bachusa | n; nowe |
| Bahama Mama (`/consumable/ethanol/bahama_mama`) | Bahama Mama | ż; nowe; bez zmian |
| Banana Honk (`/consumable/ethanol/bananahonk`) | Bananowy Honk | m; nowe |
| Barefoot (`/consumable/ethanol/barefoot`) | Na bosaka | m; nowe; drink |
| Bastion Bourbon (`/consumable/ethanol/bastion_bourbon`) | Burbon Bastionu | m; nowe |
| Bee's Knees (`/consumable/ethanol/beesknees`) | Pszczele kolanka | mnoga; nowe |
| Beef Fizz (`/consumable/ethanol/beeffizz`) | Wołowy fizz | m; nowe |
| Beepsky Smash (`/consumable/ethanol/beepsky_smash`) | Beepsky Smash | m; nowe; imię bota zostaje; bez zmian |
| Beer (`/consumable/ethanol/beer`) | Piwo | n; istniejące; MUSI być identyczne z /toxin/fakebeer |
| Between the Sheets (`/consumable/ethanol/between_the_sheets`) | Między prześcieradłami | m; nowe; drink |
| Bilk (`/consumable/ethanol/bilk`) | Mlekiwo | n; nowe; mleko + piwo |
| Black Russian (`/consumable/ethanol/black_russian`) | Czarny Rosjanin | m; nowe |
| Blank Paper (`/consumable/ethanol/blank_paper`) | Czysta kartka | ż; istniejące; „szklanka czystej kartki” |
| Blazaam (`/consumable/ethanol/blazaam`) | Blazaam | m; nowe; bez zmian |
| Bloody Mary (`/consumable/ethanol/bloody_mary`) | Krwawa Mary | ż; nowe |
| Booger (`/consumable/ethanol/booger`) | Glut | m; nowe |
| Branca Menta (`/consumable/ethanol/branca_menta`) | Branca Menta | ż; nowe; bez zmian |
| Brave Bull (`/consumable/ethanol/brave_bull`) | Dzielny Byk | m; nowe |
| Bug Spray (`/consumable/ethanol/bug_spray`) | Środek na owady | m; nowe |
| Champagne (`/consumable/ethanol/champagne`) | Szampan | m; nowe |
| Changeling Sting (`/consumable/ethanol/changelingsting`) | Żądło zmiennokształtnego | n; nowe; changeling = zmiennokształtny |
| Classic Martini (`/consumable/ethanol/martini`) | Klasyczne martini | n; nowe |
| Cognac (`/consumable/ethanol/cognac`) | Koniak | m; istniejące |
| Creme de Cacao (`/consumable/ethanol/creme_de_cacao`) | Likier kakaowy | m; nowe; spójnie z likierem kokosowym/miętowym |
| Creme de Coconut (`/consumable/ethanol/creme_de_coconut`) | Likier kokosowy | m; istniejące |
| Creme de Menthe (`/consumable/ethanol/creme_de_menthe`) | Likier miętowy | m; istniejące |
| Crevice Spike (`/consumable/ethanol/crevice_spike`) | Kolec szczeliny | m; nowe |
| Cuba Libre (`/consumable/ethanol/cuba_libre`) | Cuba Libre | ż; nowe; bez zmian |
| Demon's Blood (`/consumable/ethanol/demonsblood`) | Krew demona | ż; nowe |
| Devil's Kiss (`/consumable/ethanol/devilskiss`) | Pocałunek diabła | m; nowe |
| Driest Martini (`/consumable/ethanol/driestmartini`) | Najwytrawniejsze martini | n; nowe |
| Drunken Blumpkin (`/consumable/ethanol/drunkenblumpkin`) | Pijany blumpkin | m; nowe; blumpkin zostaje (botanika) |
| Duplex (`/consumable/ethanol/duplex`) | Duplex | m; nowe; bez zmian |
| Eggnog (`/consumable/ethanol/eggnog`) | Ajerkoniak | m; nowe |
| Erika Surprise (`/consumable/ethanol/erikasurprise`) | Niespodzianka Eriki | ż; nowe |
| Fanciulli (`/consumable/ethanol/fanciulli`) | Fanciulli | m; nowe; bez zmian |
| Faster-Than-Liver (`/consumable/ethanol/ftliver`) | Szybsze niż wątroba | n; nowe; gra z FTL |
| Fernet (`/consumable/ethanol/fernet`) | Fernet | m; nowe; bez zmian |
| Fernet Cola (`/consumable/ethanol/fernet_cola`) | Fernet z colą | m; nowe |
| Fetching Fizz (`/consumable/ethanol/fetching_fizz`) | Przyciągający fizz | m; nowe |
| Fourth Wall (`/consumable/ethanol/fourthwall`) | Czwarta ściana | ż; nowe |
| Fringe Weaver (`/consumable/ethanol/fringe_weaver`) | Tkacz krawędzi | m; nowe |
| Fruit Wine (`/consumable/ethanol/fruit_wine`) | Wino owocowe | n; nowe |
| Gin (`/consumable/ethanol/gin`) | Gin | m; nowe; bez zmian |
| Gin and Tonic (`/consumable/ethanol/gintonic`) | Gin z tonikiem | m; nowe |
| Gin Fizz (`/consumable/ethanol/ginfizz`) | Gin fizz | m; nowe |
| Goldschlager (`/consumable/ethanol/goldschlager`) | Goldschläger | m; nowe |
| Grappa (`/consumable/ethanol/grappa`) | Grappa | ż; nowe; bez zmian |
| Grasshopper (`/consumable/ethanol/grasshopper`) | Konik polny | m; nowe |
| Green Beer (`/consumable/ethanol/beer/green`) | Zielone piwo | n; istniejące; „kufel zielonego piwa” |
| Grog (`/consumable/ethanol/grog`) | Grog | m; nowe; bez zmian |
| Hard Cider (`/consumable/ethanol/hcider`) | Cydr | m; istniejące |
| Hearty Punch (`/consumable/ethanol/hearty_punch`) | Krzepiący poncz | m; nowe |
| Hippie's Delight (`/consumable/ethanol/hippies_delight`) | Rozkosz hipisa | ż; nowe |
| Hooch (`/consumable/ethanol/hooch`) | Bimber | m; nowe |
| Iced Beer (`/consumable/ethanol/iced_beer`) | Mrożone piwo | n; nowe |
| Icewing (`/consumable/ethanol/icewing`) | Lodowe skrzydło | n; nowe |
| Irish Car Bomb (`/consumable/ethanol/irishcarbomb`) | Irlandzka bomba samochodowa | ż; nowe |
| Irish Coffee (`/consumable/ethanol/irishcoffee`) | Kawa po irlandzku | ż; nowe |
| Irish Cream (`/consumable/ethanol/irish_cream`) | Irlandzki likier śmietankowy | m; nowe |
| Jack Rose (`/consumable/ethanol/jack_rose`) | Jack Rose | m; nowe; bez zmian |
| Kahlua (`/consumable/ethanol/kahlua`) | Kahlua | ż; istniejące; glass: likier kawowy; bez zmian |
| Kamikaze (`/consumable/ethanol/kamikaze`) | Kamikaze | m; nowe; bez zmian |
| Light Beer (`/consumable/ethanol/beer/light`) | Lekkie piwo | n; nowe |
| Lizard wine (`/consumable/ethanol/lizardwine`) | Wino jaszczurcze | n; nowe |
| Long Island Iced Tea (`/consumable/ethanol/longislandicedtea`) | Long Island Iced Tea | ż; nowe; nazwa koktajlu bez zmian; bez zmian |
| Manhattan (`/consumable/ethanol/manhattan`) | Manhattan | m; nowe; bez zmian |
| Manhattan Project (`/consumable/ethanol/manhattan_proj`) | Projekt Manhattan | m; nowe |
| Margarita (`/consumable/ethanol/margarita`) | Margarita | ż; nowe; bez zmian |
| Mauna Loa (`/consumable/ethanol/mauna_loa`) | Mauna Loa | ż; nowe; bez zmian |
| Mead (`/consumable/ethanol/mead`) | Miód pitny | m; istniejące |
| Mojito (`/consumable/ethanol/mojito`) | Mojito | n; nowe; bez zmian |
| Moonshine (`/consumable/ethanol/moonshine`) | Samogon | m; nowe |
| Nar'Sour (`/consumable/ethanol/narsour`) | Nar'Sour | m; nowe; bez zmian |
| Neurotoxin (`/consumable/ethanol/neurotoxin`) | Neurotoksyna | ż; istniejące; drink |
| Old Timer (`/consumable/ethanol/old_timer`) | Staruszek | m; nowe |
| Painkiller (`/consumable/ethanol/painkiller`) | Uśmierzacz | m; nowe; drink, nie lek |
| Pan-Galactic Gargle Blaster (`/consumable/ethanol/gargle_blaster`) | Pangalaktyczny Gardłogrzmot | m; nowe; jak w polskim „Autostopem przez Galaktykę” |
| Patron (`/consumable/ethanol/patron`) | Patron | m; nowe; bez zmian |
| Peppermint Patty (`/consumable/ethanol/peppermint_patty`) | Peppermint Patty | ż; nowe; bez zmian |
| Pina Colada (`/consumable/ethanol/pina_colada`) | Piña colada | ż; nowe |
| Planet Cracker (`/consumable/ethanol/planet_cracker`) | Łamacz planet | m; nowe |
| Plasma Flood (`/consumable/ethanol/plasmaflood`) | Powódź plazmy | ż; nowe |
| Quadruple Sec (`/consumable/ethanol/quadruple_sec`) | Quadruple Sec | m; nowe; bez zmian |
| Quintuple Sec (`/consumable/ethanol/quintuple_sec`) | Quintuple Sec | m; nowe; bez zmian |
| Rat'vander Cocktail (`/consumable/ethanol/ratvander`) | Koktajl Rat'vander | m; nowe |
| Red Mead (`/consumable/ethanol/red_mead`) | Czerwony miód pitny | m; nowe |
| Rubberneck (`/consumable/ethanol/rubberneck`) | Gapiszyja | ż; nowe |
| Rum (`/consumable/ethanol/rum`) | Rum | m; nowe; bez zmian |
| Rum and Coke (`/consumable/ethanol/rum_coke`) | Rum z colą | m; nowe |
| Sake (`/consumable/ethanol/sake`) | Sake | n; nowe; bez zmian |
| Sarsaparillian Sunset (`/consumable/ethanol/sarsaparilliansunset`) | Sarsaparylowy zachód słońca | m; nowe |
| Sbiten (`/consumable/ethanol/sbiten`) | Sbiten | m; nowe; bez zmian |
| Screwdriver (`/consumable/ethanol/screwdrivercocktail`) | Śrubokręt | m; nowe |
| Sidecar (`/consumable/ethanol/sidecar`) | Sidecar | m; nowe; bez zmian |
| Silencer (`/consumable/ethanol/silencer`) | Tłumik | m; nowe |
| Singulo (`/consumable/ethanol/singulo`) | Singulo | n; nowe; bez zmian |
| Snow White (`/consumable/ethanol/snowwhite`) | Królewna Śnieżka | ż; nowe |
| Squirt Cider (`/consumable/ethanol/squirt_cider`) | Tryskający cydr | m; nowe |
| Stinger (`/consumable/ethanol/stinger`) | Stinger | m; nowe; bez zmian |
| Sugar Rush (`/consumable/ethanol/sugar_rush`) | Cukrowy haj | m; nowe |
| Syndicate Bomb (`/consumable/ethanol/syndicatebomb`) | Bomba Syndykatu | ż; nowe; Syndicate = Syndykat |
| Tequila (`/consumable/ethanol/tequila`) | Tequila | ż; istniejące; bez zmian |
| Tequila Sunrise (`/consumable/ethanol/tequila_sunrise`) | Tequila Sunrise | ż; nowe; bez zmian |
| The Manly Dorf (`/consumable/ethanol/manly_dorf`) | Męski Krasnolud | m; nowe; cure_text w tuberculosis/innych ma „The Manly Dorf” – zmienić razem |
| Thirteen Loko (`/consumable/ethanol/thirteenloko`) | Thirteen Loko | n; istniejące; bez zmian |
| Three Mile Island Iced Tea (`/consumable/ethanol/threemileisland`) | Three Mile Island Iced Tea | ż; nowe; bez zmian |
| Toxins Special (`/consumable/ethanol/toxins_special`) | Specjał Toksykologii | m; nowe |
| Trappist Beer (`/consumable/ethanol/trappist`) | Piwo trapistów | n; nowe |
| Triple Sec (`/consumable/ethanol/triple_sec`) | Triple Sec | m; nowe; bez zmian |
| Turbo (`/consumable/ethanol/turbo`) | Turbo | n; nowe; bez zmian |
| Vermouth (`/consumable/ethanol/vermouth`) | Wermut | m; istniejące |
| Vodka (`/consumable/ethanol/vodka`) | Wódka | ż; istniejące |
| Vodka and Tonic (`/consumable/ethanol/vodkatonic`) | Wódka z tonikiem | ż; nowe |
| Vodka Martini (`/consumable/ethanol/vodkamartini`) | Wódka martini | ż; nowe |
| Whiskey (`/consumable/ethanol/whiskey`) | Whisky | ż; istniejące |
| Whiskey Cola (`/consumable/ethanol/whiskey_cola`) | Whisky z colą | ż; nowe |
| Whiskey Soda (`/consumable/ethanol/whiskeysoda`) | Whisky z wodą sodową | ż; nowe |
| Whiskey Sour (`/consumable/ethanol/whiskey_sour`) | Whisky sour | ż; istniejące |
| White Russian (`/consumable/ethanol/white_russian`) | Biały Rosjanin | m; nowe |
| Wine (`/consumable/ethanol/wine`) | Wino | n; istniejące |
| Wizz Fizz (`/consumable/ethanol/wizz_fizz`) | Wizz Fizz | m; nowe; bez zmian |

### A.7 Napoje bezalkoholowe

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Apple Juice (`/consumable/applejuice`) | Sok jabłkowy | m; nowe |
| Arnold Palmer (`/consumable/tea/arnold_palmer`) | Arnold Palmer | m; nowe; bez zmian |
| Banana Juice (`/consumable/banana`) | Sok bananowy | m; nowe |
| Beef Broth (`/consumable/beefbroth`) | Rosół wołowy | m; nowe |
| Berry Juice (`/consumable/berryjuice`) | Sok jagodowy | m; nowe |
| Blue Cheese Milk (`/consumable/milk/blue`) | Mleko na ser pleśniowy | n; nowe; mleko do zrobienia danego sera |
| Blue Cherry Shake (`/consumable/bluecherryshake`) | Koktajl z niebieskich wiśni | m; nowe |
| Blumpkin Juice (`/consumable/blumpkinjuice`) | Sok z blumpkina | m; nowe |
| Brie Cheese Milk (`/consumable/milk/brie`) | Mleko na brie | n; nowe |
| Bungo Juice (`/consumable/bungojuice`) | Sok z bungo | m; istniejące; bungo zostaje |
| Cafe Latte (`/consumable/cafe_latte`) | Kawa latte | ż; nowe |
| Carrot Juice (`/consumable/carrotjuice`) | Sok marchwiowy | m; nowe |
| Cheddar Cheese Milk (`/consumable/milk/cheddar`) | Mleko na cheddar | n; nowe |
| Cherry Shake (`/consumable/cherryshake`) | Koktajl wiśniowy | m; istniejące |
| Chocolate Milk (`/consumable/milk/chocolate_milk`) | Mleko czekoladowe | n; nowe |
| Chocolate Pudding (`/consumable/chocolatepudding`) | Budyń czekoladowy | m; nowe |
| Coffee (`/consumable/coffee`) | Kawa | ż; istniejące |
| Coffee Creamer (`/consumable/creamer`) | Zabielacz do kawy | m; nowe; plik: `nsv13/code/modules/reagents/chemistry/reagents/other_reagents.dm` |
| Cola (`/consumable/space_cola`) | Cola | ż; istniejące; name to „Cola”, nie „Space Cola”; bez zmian |
| Cream (`/consumable/cream`) | Śmietanka | ż; istniejące |
| Cream Soda (`/consumable/cream_soda`) | Oranżada śmietankowa | ż; nowe |
| Dr. Gibb (`/consumable/dr_gibb`) | Dr. Gibb | m; nowe; marka; bez zmian |
| Feta Cheese Milk (`/consumable/milk/feta`) | Mleko na fetę | n; nowe |
| Gibb Floats (`/consumable/gibbfloats`) | Dr. Gibb z lodami | m; nowe |
| Goat Cheese Milk (`/consumable/milk/goatcheese`) | Mleko na kozi ser | n; nowe |
| Goat Milk (`/consumable/milk/goat`) | Mleko kozie | n; nowe |
| Grape Juice (`/consumable/grapejuice`) | Sok winogronowy | m; nowe |
| Grape soda (`/consumable/grape_soda`) | Oranżada winogronowa | ż; nowe |
| Grenadine (`/consumable/grenadine`) | Grenadyna | ż; istniejące |
| Grey Bull (`/consumable/grey_bull`) | Grey Bull | m; nowe; marka; bez zmian |
| Halloumi Cheese Milk (`/consumable/milk/halloumi`) | Mleko na halloumi | n; nowe |
| Ice (`/consumable/ice`) | Lód | m; istniejące |
| Iced Coffee (`/consumable/icecoffee`) | Mrożona kawa | ż; nowe |
| Iced Tea (`/consumable/icetea`) | Mrożona herbata | ż; nowe |
| Laughter (`/consumable/laughter`) | Śmiech | m; nowe |
| Lemon Juice (`/consumable/lemonjuice`) | Sok z cytryny | m; nowe |
| Lemon Lime (`/consumable/lemon_lime`) | Cytryna z limonką | ż; nowe |
| Lemonade (`/consumable/lemonade`) | Lemoniada | ż; istniejące |
| Lime Juice (`/consumable/limejuice`) | Sok z limonki | m; nowe |
| Menthol (`/consumable/menthol`) | Mentol | m; nowe |
| Milk (`/consumable/milk`) | Mleko | n; istniejące |
| Monkey Energy (`/consumable/monkey_energy`) | Monkey Energy | m; nowe; marka; bez zmian |
| Mozzarella Cheese Milk (`/consumable/milk/mozzarella`) | Mleko na mozzarellę | n; nowe |
| Naval Coffee (`/consumable/navy_coffee`) | Kawa marynarki | ż; istniejące; „kubka kawy marynarki”; plik: `nsv13/code/modules/reagents/chemistry/reagents/other_reagents.dm` |
| Nothing (`/consumable/nothing`) | Nic | n; nowe; cure_text Pierrot's Throat to typ, nie tekst |
| Nuka Cola (`/consumable/nuka_cola`) | Nuka Cola | ż; nowe; marka; bez zmian |
| Orange Juice (`/consumable/orangejuice`) | Sok pomarańczowy | m; nowe |
| Parmesan Cheese Milk (`/consumable/milk/parmesan`) | Mleko na parmezan | n; nowe |
| Parsnip Juice (`/consumable/parsnipjuice`) | Sok z pasternaku | m; nowe |
| Peach Juice (`/consumable/peachjuice`) | Sok brzoskwiniowy | m; nowe |
| Pineapple Juice (`/consumable/pineapplejuice`) | Sok ananasowy | m; nowe |
| Poison Berry Juice (`/consumable/poisonberryjuice`) | Sok z trujących jagód | m; nowe |
| Potato Juice (`/consumable/potato_juice`) | Sok ziemniaczany | m; nowe |
| Pumpkin Juice (`/consumable/pumpkinjuice`) | Sok dyniowy | m; nowe |
| Pumpkin Latte (`/consumable/pumpkin_latte`) | Dyniowe latte | n; nowe |
| Pwr Game (`/consumable/pwr_game`) | Pwr Game | m; nowe; marka; bez zmian |
| Red Queen (`/consumable/red_queen`) | Czerwona Królowa | ż; nowe |
| Shambler's Juice (`/consumable/shamblers`) | Sok Shamblera | m; nowe |
| Sheep Milk (`/consumable/milk/sheep`) | Mleko owcze | n; nowe |
| Shoat Milk (`/consumable/milk/shoat`) | Mleko owczo-kozie | n; nowe; shoat = mieszaniec owcy i kozy |
| SM Wind (`/consumable/spacemountainwind`) | SM Wind | m; nowe; marka; bez zmian |
| Soda Water (`/consumable/sodawater`) | Woda sodowa | ż; istniejące |
| Soy Latte (`/consumable/soy_latte`) | Latte sojowe | n; nowe |
| Soy Milk (`/consumable/soymilk`) | Mleko sojowe | n; istniejące |
| Space-Up (`/consumable/space_up`) | Space-Up | m; nowe; marka; bez zmian |
| Super Laughter (`/consumable/superlaughter`) | Superśmiech | m; nowe |
| Swiss Cheese Milk (`/consumable/milk/swiss`) | Mleko na ser szwajcarski | n; nowe |
| Tea (`/consumable/tea`) | Herbata | ż; istniejące |
| The Doctor's Delight (`/consumable/doctor_delight`) | Rozkosz doktora | ż; nowe |
| Tomato Juice (`/consumable/tomatojuice`) | Sok pomidorowy | m; nowe |
| Tonic Water (`/consumable/tonic`) | Tonik | m; istniejące |
| Triple Citrus (`/consumable/triple_citrus`) | Potrójny cytrus | m; nowe |
| Vanilla Pudding (`/consumable/vanillapudding`) | Budyń waniliowy | m; nowe |
| Watermelon Juice (`/consumable/watermelonjuice`) | Sok arbuzowy | m; nowe |

### A.8 Jedzenie, przyprawy i nawozy

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Astrotame (`/consumable/astrotame`) | Astrotam | m; nowe |
| BBQ Sauce (`/consumable/bbqsauce`) | Sos barbecue | m; nowe |
| Black Pepper (`/consumable/blackpepper`) | Czarny pieprz | m; nowe |
| Blue Cherry Jelly (`/consumable/bluecherryjelly`) | Galaretka z niebieskich wiśni | ż; nowe |
| Capsaicin Oil (`/consumable/capsaicin`) | Olejek kapsaicynowy | m; istniejące; slime_extract_descs.dm |
| Caramel (`/consumable/caramel`) | Karmel | m; istniejące |
| Char (`/consumable/char`) | Przypalenizna | ż; nowe |
| Cherry Jelly (`/consumable/cherryjelly`) | Galaretka wiśniowa | ż; istniejące |
| Clown's Tears (`/consumable/clownstears`) | Łzy klauna | mnoga; nowe |
| Cocoa Powder (`/consumable/cocoa`) | Kakao w proszku | n; nowe |
| Condensed Capsaicin (`/consumable/condensedcapsaicin`) | Skondensowana kapsaicyna | ż; istniejące; cure_text |
| Consumable (`/consumable`) | Produkt spożywczy | m; nowe; bazowy |
| Corn Starch (`/consumable/corn_starch`) | Skrobia kukurydziana | ż; nowe |
| Corn Syrup (`/consumable/corn_syrup`) | Syrop kukurydziany | m; nowe |
| Dry Ramen (`/consumable/dry_ramen`) | Suchy ramen | m; nowe |
| E-Z-Nutrient (`/plantnutriment/eznutriment`) | E-Z-Nutrient | m; nowe; marka nawozu; bez zmian |
| Egg Yolk (`/consumable/eggyolk`) | Żółtko | n; istniejące |
| Entropic Polypnium (`/consumable/entpoly`) | Entropiczne polipnium | n; nowe |
| Fat (`/consumable/nutriment/fat`) | Tłuszcz | m; istniejące |
| Flour (`/consumable/flour`) | Mąka | ż; istniejące |
| Frost Oil (`/consumable/frostoil`) | Olej mroźny | m; istniejące; cure_text; „frost oil” w slime_extract_descs do poprawy |
| Garlic Juice (`/consumable/garlic`) | Sok czosnkowy | m; nowe |
| Generic nutriment (`/plantnutriment`) | Zwykły nawóz | m; istniejące; nutriment roślinny = nawóz |
| Hell Ramen (`/consumable/hell_ramen`) | Piekielny ramen | m; nowe |
| Honey (`/consumable/honey`) | Miód | m; istniejące |
| Hot Chocolate (`/consumable/cocoa/hot_cocoa`) | Gorąca czekolada | ż; nowe |
| Hot Ramen (`/consumable/hot_ramen`) | Gorący ramen | m; nowe |
| Ketchup (`/consumable/ketchup`) | Ketchup | m; istniejące; odrzucony wariant: keczup; bez zmian |
| Left 4 Zed (`/plantnutriment/left4zednutriment`) | Left 4 Zed | m; nowe; marka nawozu; bez zmian |
| Liquid Electricity (`/consumable/liquidelectricity`) | Płynna elektryczność | ż; nowe |
| Living Fertiliser (`/plantnutriment/slimenutriment`) | Żywy nawóz | m; nowe; plik: `aquila/code/modules/research/xenobiology/special_slimes.dm` |
| Maltodextrin (`/consumable/maltodextrin`) | Maltodekstryna | ż; nowe |
| Mayonnaise (`/consumable/mayonnaise`) | Majonez | m; nowe |
| mesophilic culture (`/consumable/mesophilicculture`) | kultura mezofilna | ż; nowe; małą literą jak w oryginale |
| Mold (`/consumable/mold`) | Pleśń | ż; istniejące |
| Nutraslop (`/consumable/nutraslop`) | Odżywcze pomyje | mnoga; nowe; plik: `aquila/code/modules/monke/loafer.dm` |
| Nutriment (`/consumable/nutriment`) | Składniki odżywcze | mnoga; istniejące; odrzucony wariant: „nutriment” |
| Olej rycynowy (`/consumable/castor_oil`) | Olej rycynowy | m; istniejące; plik: `aquila/code/modules/reagents/chemistry/reagents/food_reagents.dm`; bez zmian |
| Olive Oil (`/consumable/nutriment/fat/oil/olive`) | Oliwa z oliwek | ż; nowe |
| Parmesan Delight (`/consumable/parmesan_delight`) | Parmezanowa rozkosz | ż; nowe |
| penicillium candidum (`/consumable/penicilliumcandidum`) | penicillium candidum | n; nowe; łacina zostaje; bez zmian |
| penicillium roqueforti (`/consumable/penicilliumroqueforti`) | penicillium roqueforti | n; nowe; łacina zostaje; bez zmian |
| Protein (`/consumable/nutriment/protein`) | Białko | n; istniejące |
| Ratvarian Light (`/consumable/ratlight`) | Ratvariańskie światło | n; istniejące; „ratvariańskie” już w kodzie |
| Rice (`/consumable/rice`) | Ryż | m; istniejące |
| Robust Harvest (`/plantnutriment/robustharvestnutriment`) | Robust Harvest | m; nowe; marka nawozu; bez zmian |
| Rotten Eggyolk (`/consumable/eggrot`) | Zgniłe żółtko | n; nowe |
| Royal Honey (`/consumable/honey/special`) | Miód królewski | m; nowe |
| Secret Sauce (`/consumable/secretsauce`) | Sekretny sos | m; nowe; plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm` |
| Soysauce (`/consumable/soysauce`) | Sos sojowy | m; istniejące |
| Sprinkles (`/consumable/sprinkles`) | Posypka | ż; nowe |
| Stabilized Nutriment (`/consumable/nutriment/stabilized`) | Stabilizowane składniki odżywcze | mnoga; nowe |
| Sugar (`/consumable/sugar`) | Cukier | m; istniejące |
| Table Salt (`/consumable/sodiumchloride`) | Sól kuchenna | ż; istniejące |
| Tear Juice (`/consumable/tearjuice`) | Sok łzawiący | m; nowe |
| thermophilic culture (`/consumable/thermophilicculture`) | kultura termofilna | ż; nowe; małą literą jak w oryginale |
| Tinea Luxor (`/consumable/tinlux`) | Tinea Luxor | ż; nowe; łacina zostaje; bez zmian |
| Universal Enzyme (`/consumable/enzyme`) | Uniwersalny enzym | m; nowe |
| Vanilla Powder (`/consumable/vanilla`) | Wanilia w proszku | ż; nowe |
| Vegetable Oil (`/consumable/nutriment/fat/oil`) | Olej roślinny | m; nowe |
| Vitamin (`/consumable/nutriment/vitamin`) | Witaminy | mnoga; istniejące |
| Vitrium Froth (`/consumable/vitfro`) | Piana witrium | ż; istniejące; cure_text: „Lecznicza piana witrium” |

### A.9 Wirusologia (pożywki, kultury)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Anomolous Virus Food (`/consumable/laughter/laughtervirusfood`) | Anomalna pożywka dla wirusów | ż; nowe |
| Decaying Uranium Gel (`/uranium/uraniumvirusfood`) | Rozpadający się żel uranowy | m; nowe |
| Experimental Viral Base (`/consumable/virus_food/viralbase`) | Eksperymentalna baza wirusowa | ż; nowe |
| Highly Unstable Virus Food (`/consumable/virus_food/advvirusfood`) | Wysoce niestabilna pożywka dla wirusów | ż; nowe |
| Mutagenic Agar (`/toxin/mutagen/mutagenvirusfood`) | Agar mutagenny | m; nowe |
| Stable Uranium Gel (`/uranium/uraniumvirusfood/stable`) | Stabilny żel uranowy | m; nowe |
| Sucrose Agar (`/toxin/mutagen/mutagenvirusfood/sugar`) | Agar sacharozowy | m; nowe |
| Tubercle bacillus Cosmosis microbes (`/fungalspores`) | Mikroby Tubercle bacillus Cosmosis | mnoga; nowe; łacina zostaje |
| Unstable Uranium Gel (`/uranium/uraniumvirusfood/unstable`) | Niestabilny żel uranowy | m; nowe |
| Vaccine (`/vaccine`) | Szczepionka | ż; istniejące |
| Virus Food (`/consumable/virus_food`) | Pożywka dla wirusów | ż; nowe |
| Virus Plasma (`/toxin/plasma/plasmavirusfood`) | Plazma wirusowa | ż; nowe |
| Virus Rations (`/medicine/synaptizine/synaptizinevirusfood`) | Racje dla wirusów | mnoga; nowe |
| Weakened Virus Plasma (`/toxin/plasma/plasmavirusfood/weak`) | Osłabiona plazma wirusowa | ż; nowe |
| Xenomicrobes (`/xenomicrobes`) | Ksenomikroby | mnoga; nowe |

### A.10 Fermichem (katalizatory, bufory, izomery, odwrócone)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Benzoic Acid (`/inverse/sal_acid`) | Kwas benzoesowy | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Catalysium P (`/catalyst_precursor_ph`) | Katalizum P | n; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Catalysium T (`/catalyst_precursor_temp`) | Katalizum T | n; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Catalyst agent (`/catalyst_agent`) | Środek katalityczny | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Chemical Isomers (`/impurity`) | Izomery chemiczne | mnoga; istniejące; opisy już mówią „izomery”; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Chiral Inversing Buffer (`/reaction_agent/inversing_buffer`) | Chiralny bufor odwracający | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Chloralax (`/impurity/chloralax`) | Chloralaks | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Dulling Reagent (`/inverse/colorful_reagent`) | Odczynnik matowiący | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Epoetin Alfa (`/inverse/aranesp`) | Epoetyna alfa | ż; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Hyoscyamine (`/inverse/atropine`) | Hioscyjamina | ż; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Inreziniver (`/inverse/rezadone`) | Inrezyniwer | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Interim Product Alpha (`/prefactor_a`) | Półprodukt Alfa | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Interim Product Beta (`/prefactor_b`) | Półprodukt Beta | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Ionic Modulator (`/catalyst_agent/ph/generic`) | Modulator jonowy | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Ipecacide (`/impurity/ipecacide`) | Ipekacyd | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Neruwhine (`/inverse/neurine`) | Neurojęczyna | ż; nowe; gra słów neurine/whine; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Oculater (`/inverse/oculine`) | Okulater | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Oxymetholone (`/inverse/oxandrolone`) | Oksymetolon | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Palladium Synthate Catalyst (`/catalyst_agent/speed/medicine`) | Katalizator z syntetatu palladu | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Pendetide (`/inverse/pen_acid`) | Pendetyd | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| pH Catalyst Agent (`/catalyst_agent/ph`) | Katalizator pH | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Prohol (`/inverse/antihol`) | Prohol | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm`; bez zmian |
| Purity Tester (`/reaction_agent/purity_tester`) | Tester czystości | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Reaction Agent (`/reaction_agent`) | Środek reakcyjny | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Rosenol (`/impurity/rosenol`) | Rozenol | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Sadness (`/inverse/happiness`) | Smutek | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Speed Catalyst Agent (`/catalyst_agent/speed`) | Katalizator szybkości | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Strong Acidic Buffer (`/reaction_agent/acidic_buffer`) | Mocny bufor kwaśny | m; istniejące; fermi_items.dm: „mocnego buforu kwaśnego”; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Strong Basic Buffer (`/reaction_agent/basic_buffer`) | Mocny bufor zasadowy | m; istniejące; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Temperature Catalyst Agent (`/catalyst_agent/temperature`) | Katalizator temperatury | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Tempomyocin (`/reaction_agent/speed_agent`) | Tempomiocyna | ż; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Thermic Modulator (`/catalyst_agent/temperature/generic`) | Modulator termiczny | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Tinacusiate (`/impurity/inacusiate`) | Tinakuzjat | m; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/impure_reagents.dm` |
| Toxic Monomers (`/inverse`) | Toksyczne monomery | mnoga; nowe; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |
| Viscous Sludge (`/consumable/failed_reaction`) | Lepki szlam | m; istniejące; opis już: „Śmierdzący szlam”; plik: `aquila/code/modules/reagents/chemistry/fermi/fermi_reagents.dm` |

### A.11 Szczepy bloba (name widoczne jako nazwa szczepu)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Blazing Oil (`/blob/blazing_oil`) | Płonący olej | m; nowe; plik: `code/modules/antagonists/blob/blobstrains/blazing_oil.dm` |
| Cryogenic Poison (`/blob/cryogenic_poison`) | Trucizna kriogeniczna | ż; nowe; plik: `code/modules/antagonists/blob/blobstrains/cryogenic_poison.dm` |
| Electromagnetic Web (`/blob/electromagnetic_web`) | Sieć elektromagnetyczna | ż; nowe; plik: `code/modules/antagonists/blob/blobstrains/electromagnetic_web.dm` |
| Energized Jelly (`/blob/energized_jelly`) | Naładowana galaretka | ż; nowe; w EN ta sama nazwa co /teslium/energized_jelly; zostawiamy wspólną; plik: `code/modules/antagonists/blob/blobstrains/energized_jelly.dm` |
| Explosive Lattice (`/blob/explosive_lattice`) | Wybuchowa krata | ż; nowe; plik: `code/modules/antagonists/blob/blobstrains/explosive_lattice.dm` |
| Networked Fibers (`/blob/networked_fibers`) | Usieciowane włókna | mnoga; nowe; plik: `code/modules/antagonists/blob/blobstrains/networked_fibers.dm` |
| Pressurized Slime (`/blob/pressurized_slime`) | Sprężony szlam | m; nowe; plik: `code/modules/antagonists/blob/blobstrains/pressurized_slime.dm` |
| Reactive Spines (`/blob/reactive_spines`) | Reaktywne kolce | mnoga; nowe; plik: `code/modules/antagonists/blob/blobstrains/reactive_spines.dm` |
| Regenerative Materia (`/blob/regenerative_materia`) | Materia regeneracyjna | ż; nowe; plik: `code/modules/antagonists/blob/blobstrains/regenerative_materia.dm` |
| Replicating Foam (`/blob/replicating_foam`) | Replikująca piana | ż; nowe; plik: `code/modules/antagonists/blob/blobstrains/replicating_foam.dm` |
| Shifting Fragments (`/blob/shifting_fragments`) | Przesuwające się odłamki | mnoga; nowe; plik: `code/modules/antagonists/blob/blobstrains/shifting_fragments.dm` |
| Synchronous Mesh (`/blob/synchronous_mesh`) | Synchroniczna siatka | ż; nowe; plik: `code/modules/antagonists/blob/blobstrains/synchronous_mesh.dm` |
| Unknown (`/blob`) | Nieznany | m; nowe; bazowy, nie powinien się pojawić; plik: `code/modules/antagonists/blob/blobstrains/_reagent.dm` |
| Zombifying Pods (`/blob/zombifying_pods`) | Zombifikujące strąki | mnoga; nowe; plik: `code/modules/antagonists/blob/blobstrains/zombifying_pods.dm` |

### A.12 Toksyny mutacyjne (wzór: „Toksyna mutacyjna (rasa)”)

Nazwa rasy w nawiasie to mianownik z sekcji 04 §6, małą literą (przegląd spójności C2, 29.10.2026: ujednolicone abduktor → porywacz, ethereal → eteryk, ćmoczłowiek → ćma, plazmaczłowiek → plazmaman, roślinoczłek → roślinoczłowiek, cień → cieniak, popielny → popielny wędrowiec; nowe nazwy są unikalne po `ckey()`).

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Abductor Mutation Toxin (`/mutationtoxin/abductor`) | Toksyna mutacyjna (porywacz) | ż; nowe; odrzucony: (abduktor) |
| Advanced Mutation Toxin (`/aslimetoxin`) | Zaawansowana toksyna mutacyjna | ż; istniejące; odrzucony wariant „toksyna mutująca” (agent choroby) |
| Apid Mutation Toxin (`/mutationtoxin/apid`) | Toksyna mutacyjna (apid) | ż; nowe |
| Ash Mutation Toxin (`/mutationtoxin/ash`) | Toksyna mutacyjna (popielny wędrowiec) | ż; nowe; odrzucony: (popielny) |
| Ethereal Mutation Toxin (`/mutationtoxin/ethereal`) | Toksyna mutacyjna (eteryk) | ż; nowe; odrzucony: (ethereal) |
| Felinid Mutation Toxin (`/mutationtoxin/felinid`) | Toksyna mutacyjna (felinid) | ż; nowe |
| Fly Mutation Toxin (`/mutationtoxin/fly`) | Toksyna mutacyjna (muchoczłowiek) | ż; nowe |
| Golem Mutation Toxin (`/mutationtoxin/golem`) | Toksyna mutacyjna (golem) | ż; nowe |
| Imperfect Mutation Toxin (`/mutationtoxin/jelly`) | Niedoskonała toksyna mutacyjna | ż; nowe |
| Lizard Mutation Toxin (`/mutationtoxin/lizard`) | Toksyna mutacyjna (jaszczur) | ż; nowe |
| Moth Mutation Toxin (`/mutationtoxin/moth`) | Toksyna mutacyjna (ćma) | ż; nowe; odrzucony: (ćmoczłowiek) |
| Mutation Toxin (`/mutationtoxin/classic`) | Toksyna mutacyjna | ż; istniejące; slime_extract_descs.dm |
| Oozeling Mutation Toxin (`/mutationtoxin/oozeling`) | Toksyna mutacyjna (oozeling) | ż; nowe |
| Plasma Mutation Toxin (`/mutationtoxin/plasma`) | Toksyna mutacyjna (plazmaman) | ż; nowe; odrzucony: (plazmaczłowiek) |
| Podperson Mutation Toxin (`/mutationtoxin/pod`) | Toksyna mutacyjna (roślinoczłowiek) | ż; nowe; odrzucony: (roślinoczłek) |
| Shadow Mutation Toxin (`/mutationtoxin/shadow`) | Toksyna mutacyjna (cieniak) | ż; nowe; odrzucony: (cień) |
| Skeleton Mutation Toxin (`/mutationtoxin/skeleton`) | Toksyna mutacyjna (szkielet) | ż; nowe |
| Stable Mutation Toxin (`/mutationtoxin`) | Stabilna toksyna mutacyjna | ż; istniejące; wzór: „Toksyna mutacyjna (rasa)” |
| Unstable Mutation Toxin (`/mutationtoxin/unstable`) | Niestabilna toksyna mutacyjna | ż; istniejące; slime_extract_descs.dm |
| Zombie Mutation Toxin (`/mutationtoxin/zombie`) | Toksyna mutacyjna (zombie) | ż; nowe |
| Zombie Mutation Toxin (`/mutationtoxin/goofzombie`) | Toksyna mutacyjna (zombie) | ż; nowe; w EN ta sama nazwa co /mutationtoxin/zombie; zostawiamy wspólną |

### A.13 Pozostałe

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Agent-S (`/snail`) | Środek S | m; istniejące; agent choroby „Środek S i restrukturyzacja DNA” |
| Ants (`/ants`) | Mrówki | mnoga; nowe |
| Barber's Aid (`/barbers_aid`) | Pomoc fryzjera | ż; nowe |
| Black Crayon Powder (`/colorful_reagent/powder/black/crayon`) | Proszek z czarnej kredki | m; nowe |
| Black Powder (`/colorful_reagent/powder/black`) | Czarny proszek | m; nowe; w EN koliduje z /blackpowder; po PL rozdzielone |
| Blue Crayon Powder (`/colorful_reagent/powder/blue/crayon`) | Proszek z niebieskiej kredki | m; nowe |
| Blue Glitter (`/glitter/blue`) | Niebieski brokat | m; nowe |
| Blue Powder (`/colorful_reagent/powder/blue`) | Niebieski proszek | m; nowe |
| Carpet (`/carpet`) | Dywan | m; istniejące |
| Colorful Reagent (`/colorful_reagent`) | Kolorowy odczynnik | m; nowe |
| Concentrated Barber's Aid (`/concentrated_barbers_aid`) | Skoncentrowana pomoc fryzjera | ż; nowe |
| Corgium (`/corgium`) | Corgium | n; nowe; corgi zostaje; bez zmian |
| Cryptobiolin (`/cryptobiolin`) | Kryptobiolina | ż; nowe |
| Dizzying Solution (`/peaceborg/confuse`) | Roztwór oszałamiający | m; nowe |
| Drying agent (`/drying_agent`) | Środek osuszający | m; nowe |
| Eldritch Essence (`/eldritch`) | Pradawna esencja | ż; nowe; eldritch = pradawny (jak „pradawny horror”) |
| EZ Clean (`/space_cleaner/ez_clean`) | EZ Clean | m; nowe; marka; bez zmian |
| Flight Potion (`/flightpotion`) | Eliksir lotu | m; nowe; plik: `code/modules/mining/lavaland/necropolis_chests.dm` |
| Generic Glitter (`/glitter`) | Zwykły brokat | m; istniejące |
| Gluttony's Blessing (`/gluttonytoxin`) | Błogosławieństwo Obżarstwa | n; nowe; też nazwa choroby – trzymać identycznie |
| Gorgium (`/metalgen/gorgium`) | Gorgium | n; istniejące; plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm`; bez zmian |
| Grasp of the Mansus (`/helgrasp/heretic`) | Uchwyt Mansusa | m; istniejące; „Uchwyt Mansusa” w kodzie heretyka |
| Gravitum (`/gravitum`) | Grawitum | n; nowe; plik: `aquila/code/modules/monke/loafer.dm` |
| Green Crayon Powder (`/colorful_reagent/powder/green/crayon`) | Proszek z zielonej kredki | m; nowe |
| Green Powder (`/colorful_reagent/powder/green`) | Zielony proszek | m; nowe |
| Growth Serum (`/growthserum`) | Serum wzrostu | n; nowe |
| Helgrasp (`/helgrasp`) | Uchwyt Hel | m; nowe |
| Hull Repair Juice (`/hull_repair_juice`) | Płyn do naprawy kadłuba | m; nowe; plik: `nsv13/code/modules/overmap/hull_plating.dm` |
| Impedrezene (`/impedrezene`) | Impedrezen | m; nowe |
| Inabizine (`/peaceborg/inabizine`) | Inabizyna | ż; nowe |
| Invisible Powder (`/colorful_reagent/powder/invisible`) | Niewidzialny proszek | m; nowe |
| Liquid gibs (`/liquidgibs`) | Płynne flaki | mnoga; nowe |
| Luminol (`/luminol`) | Luminol | m; istniejące; plik: `aquila/code/modules/detectivework/luminol.dm`; bez zmian |
| Magillitis (`/magillitis`) | Magillitis | m; nowe; bez zmian |
| Metalgen (`/metalgen`) | Metalgen | m; istniejące; nazwa używana w opisach przemian (secret_reagents.dm); plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm`; bez zmian |
| Mulligan Toxin (`/mulligan`) | Toksyna Mulligana | ż; nowe |
| Mundane Powder" //the name's a bit similar to the name of colorful reagent, but hey, they're practically the same chem anyway (`/colorful_reagent/powder`) | Zwykły proszek | m; nowe |
| odd black liquid (`/darkspawn_darkness_smoke`) | dziwny czarny płyn | m; nowe; małą literą jak w oryginale; plik: `aquila/code/modules/antagonists/darkspawn/darkspawn_status_effects.dm` |
| Orange Crayon Powder (`/colorful_reagent/powder/orange/crayon`) | Proszek z pomarańczowej kredki | m; nowe |
| Orange Powder (`/colorful_reagent/powder/orange`) | Pomarańczowy proszek | m; nowe |
| Pax (`/pax`) | Pax | m; nowe; bez zmian |
| Pink Glitter (`/glitter/pink`) | Różowy brokat | m; nowe |
| Polyjuice (`/polyjuice`) | Eliksir wielosokowy | m; nowe; jak w polskim przekładzie HP; plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm` |
| Purple Crayon Powder (`/colorful_reagent/powder/purple/crayon`) | Proszek z fioletowej kredki | m; nowe |
| Purple Powder (`/colorful_reagent/powder/purple`) | Fioletowy proszek | m; nowe |
| Quantum Hair Dye (`/hair_dye`) | Kwantowa farba do włosów | ż; istniejące |
| Rat Spit (`/rat_spit`) | Szczurza ślina | ż; nowe; plik: `aquila/code/modules/mob/living/simple_animal/hostile/regalrat.dm` |
| Red Crayon Powder (`/colorful_reagent/powder/red/crayon`) | Proszek z czerwonej kredki | m; nowe |
| Red Powder (`/colorful_reagent/powder/red`) | Czerwony proszek | m; nowe |
| Romerol (`/romerol`) | Romerol | m; istniejące; bez zmian |
| Royal Bee Jelly (`/royal_bee_jelly`) | Mleczko pszczele | n; nowe |
| Serotrotium (`/serotrotium`) | Serotrotium | n; nowe; bez zmian |
| Shadowfrost (`/shadowfrost`) | Cieniomróz | m; nowe; plik: `aquila/code/modules/antagonists/darkspawn/darkspawn_status_effects.dm` |
| Space Cleaner (`/space_cleaner`) | Kosmiczny środek czyszczący | m; istniejące; „środek czyszczący” już w kodzie |
| Space Lube (`/lube`) | Kosmiczny lubrykant | m; istniejące; „butelkę kosmicznego lubrykantu” |
| Spider Extract (`/spider_extract`) | Wyciąg pajęczy | m; nowe |
| Spray Tan (`/spraytan`) | Samoopalacz w sprayu | m; nowe |
| Sterilizine (`/space_cleaner/sterilizine`) | Sterylizyna | ż; nowe |
| Super Duper Lube (`/lube/superlube`) | Super-duper lubrykant | m; nowe |
| Synthpax (`/pax/peaceborg`) | Syntpax | m; nowe |
| Tiring Solution (`/peaceborg/tire`) | Roztwór męczący | m; nowe |
| Tranquility (`/tranquility`) | Spokój | m; nowe |
| White Crayon Powder (`/colorful_reagent/powder/white/crayon`) | Proszek z białej kredki | m; nowe |
| White Glitter (`/glitter/white`) | Biały brokat | m; nowe |
| White Powder (`/colorful_reagent/powder/white`) | Biały proszek | m; nowe |
| Wittel (`/wittel`) | Wittel | m; nowe; plik: `aquila/code/modules/reagents/chemistry/reagents/secret_reagents.dm`; bez zmian |
| Yellow Crayon Powder (`/colorful_reagent/powder/yellow/crayon`) | Proszek z żółtej kredki | m; nowe |
| Yellow Powder (`/colorful_reagent/powder/yellow`) | Żółty proszek | m; nowe |

## Część B. Medycyna

### B.1 Rodzaje obrażeń i parametry zdrowia

| EN | PL | rodzaj/uwagi |
|---|---|---|
| brute damage | obrażenia fizyczne | mn; istniejące (HealthAnalyzer, MechaSleeper). Etykieta: „Obrażenia fizyczne”. W wąskich kolumnach skanera i w prozie wolno „urazy” (też istniejące, scanners.dm) |
| burn damage | oparzenia | mn; istniejące. Etykieta: „Oparzenia” |
| toxin damage | obrażenia od toksyn | mn; istniejące. Etykieta: „Toksyny”. Odrzucone: „Zatrucie” (MODsuit.tsx) |
| oxygen damage, oxyloss, suffocation damage | niedotlenienie | n; istniejące. Etykieta: „Niedotlenienie” |
| clone damage, cellular damage | uszkodzenia komórkowe | mn; istniejące. Krótka etykieta: „Komórki” (Sleeper.tsx) |
| stamina damage | obrażenia wytrzymałości | mn; istniejące |
| stamina | wytrzymałość | ż; istniejące |
| brain damage | uszkodzenia mózgu | mn; istniejące |
| organ damage | uszkodzenia organu | mn; nowe |
| genetic damage | uszkodzenia genetyczne | mn; istniejące |
| radiation (stan pacjenta) | napromieniowanie | n; istniejące |
| radiation (zjawisko) | promieniowanie | n; istniejące |
| health | zdrowie | n; istniejące |
| vitals | funkcje życiowe | mn; istniejące |
| critical condition, crit | stan krytyczny | m; istniejące |
| unconscious | nieprzytomny | przym.; istniejące |
| unconsciousness | utrata przytomności | ż; istniejące |
| dead / death (w analizatorze) | zgon | m; istniejące. W prozie: śmierć (ż) |
| husk, husked | wysuszone ciało, wysuszony | n / przym.; istniejące |
| bleeding | krwawienie | n; istniejące |
| bleed rate | tempo krwawienia | n; nowe |
| blood volume | objętość krwi | ż; nowe. Stan: „niski poziom krwi” (istniejące) |
| blood type | grupa krwi | ż; istniejące |
| body temperature | temperatura ciała | ż; istniejące |
| overheating, hyperthermia | przegrzanie | n; istniejące |
| hypothermia | wychłodzenie | n; istniejące |
| cardiac arrest | zatrzymanie akcji serca | n; istniejące |
| heart attack | zawał serca | m; istniejące |
| circulation | krążenie | n; nowe |
| oxygenation | natlenienie | n; nowe |
| consciousness | przytomność | ż; nowe |
| stun | ogłuszenie | n; istniejące |
| knockdown | powalenie | n; istniejące |
| paralysis, paralyze | paraliż, sparaliżować | m; istniejące („sparaliżowanej kończyny”) |
| immobilize | unieruchomić | czas.; istniejące |
| drowsiness | senność | ż; istniejące |
| dizziness | zawroty głowy | mn; nowe |
| confusion | dezorientacja | ż; istniejące |
| jitteriness, jitter | drżenie | n; istniejące |
| slurring | bełkot | m; nowe |
| stuttering | jąkanie | n; nowe |
| blindness | ślepota | ż; nowe |
| nearsightedness | krótkowzroczność | ż; istniejące |
| deafness | głuchota | ż; istniejące |
| muteness | niemota | ż; nowe |
| hallucinations | halucynacje | mn; istniejące |
| nausea, disgust | mdłości | mn; istniejące |
| vomit (rzecz.) / vomiting | wymiociny / wymioty | mn; istniejące |
| drunkenness | upojenie alkoholowe | n; nowe. „pijany” |
| liver cirrhosis | marskość wątroby | ż; istniejące |
| pain | ból | m; istniejące |
| shock | wstrząs | m; istniejące |
| overdose | przedawkowanie | n; istniejące |
| addiction | uzależnienie | n; istniejące |
| withdrawal | głód (odstawienie) | m; nowe. „objawy odstawienia” |
| metabolism | metabolizm | m; istniejące |
| healing | leczenie | n; istniejące |
| regeneration | regeneracja | ż; istniejące |
| slowdown (od obrażeń) | spowolnienie | n; istniejące |

### B.2 Rany i urazy

| EN | PL | rodzaj/uwagi |
|---|---|---|
| wound | rana | ż; istniejące |
| bruise | stłuczenie | n; istniejące (opisy leków). „siniak” tylko w prozie |
| cut, laceration, slash | rana cięta | ż; istniejące |
| pierce, puncture | rana kłuta | ż; istniejące |
| burn (rana) | oparzenie | n; istniejące |
| fracture, broken bone | złamanie | n; istniejące |
| compound fracture | złamanie otwarte | n; istniejące |
| dislocation | zwichnięcie | n; istniejące |
| embedded object | ciało obce (tkwi w ciele) | n; istniejące („Tkwi w ciele: X”) |
| shrapnel, bullet in body | pocisk w ciele | m; istniejące |
| infection (rany) | zakażenie | n; istniejące |
| necrosis | martwica | ż; istniejące |
| gangrene | zgorzel | ż; nowe |
| scar | blizna | ż; nowe |
| exposed organs | odsłonięte organy | mn; istniejące (nazwa operacji) |
| charred, burnt flesh | zwęglone ciało | n; istniejące |
| gibs | flaki | mn; nowe |
| dismember | odciąć (kończynę) | czas.; istniejące („odcięcie kończyny”) |
| missing limb | brak kończyny | m; istniejące |

### B.3 Części ciała (strefy celowania)

Odmianę stref daje helper `strefa_pl(zone, biernik)` z `aquila/code/__HELPERS/polish.dm`. Tłumacze używają go zamiast tłumaczyć `parse_zone()`.

| EN | PL | rodzaj/uwagi |
|---|---|---|
| head | głowa | ż; istniejące (biernik: głowę) |
| chest | klatka piersiowa | ż; istniejące (biernik: klatkę piersiową) |
| torso (cyborga/protezy) | tułów | m; istniejące |
| groin | krocze | n; istniejące |
| eyes | oczy | mn; istniejące |
| mouth | usta | mn; istniejące |
| left arm / right arm | lewa ręka / prawa ręka | ż; istniejące |
| left leg / right leg | lewa noga / prawa noga | ż; istniejące |
| left hand / right hand | lewa dłoń / prawa dłoń | ż; istniejące |
| left foot / right foot | lewa stopa / prawa stopa | ż; istniejące |
| limb | kończyna | ż; istniejące |
| bodypart | część ciała | ż; istniejące |
| arm (ogólnie) | ręka | ż; istniejące |
| leg (ogólnie) | noga | ż; istniejące |
| skull | czaszka | ż; istniejące |
| bone | kość | ż; istniejące |
| bone marrow | szpik kostny | m; istniejące |
| skin | skóra | ż; istniejące |
| flesh | ciało (tkanka), mięso | n; istniejące |
| muscle | mięsień | m; nowe |
| vein / blood vessel | żyła / naczynie krwionośne | ż / n; nowe |
| ligament | więzadło | n; nowe |
| nerve | nerw | m; nowe |
| cortex | kora mózgowa | ż; nowe |
| tissue | tkanka | ż; istniejące („tkanka nerwowa”, „tkankę mózgową”) |
| bloodstream | krwiobieg | m; istniejące |
| prosthetic limb | proteza | ż; istniejące |
| surplus prosthetic left arm (itd.) | tania proteza lewej ręki | ż; nowe |
| robotic / cyborg arm | robotyczna ręka / ręka cyborga | ż; nowe |
| cyborg head / torso | głowa cyborga / tułów cyborga | ż / m; nowe |

### B.4 Organy i implanty

„Organ” (m) jest dominujący w kodzie (ok. 120 wystąpień z odmianą), „narząd” (ok. 50) to wariant odrzucony dla nazw i etykiet. W prozie lekarskiej oba brzmią naturalnie, ale trzymajmy „organ”.

| EN | PL | rodzaj/uwagi |
|---|---|---|
| organ | organ | m; istniejące (odrzucony: narząd); także `name` bazowego `/obj/item/organ` i proza opisów („organy wewnętrzne”) |
| brain | mózg | m; istniejące |
| heart | serce | n; istniejące |
| lungs | płuca | mn; istniejące |
| liver | wątroba | ż; istniejące |
| stomach | żołądek | m; istniejące |
| appendix | wyrostek robaczkowy | m; istniejące |
| inflamed appendix | zapalony wyrostek robaczkowy | m; nowe |
| eyes | oczy | mn; istniejące |
| ears | uszy | mn; istniejące |
| tongue | język | m; istniejące |
| vocal cords | struny głosowe | mn; istniejące |
| tail | ogon | m; istniejące |
| wings, pair of wings | skrzydła, para skrzydeł | mn / ż; istniejące |
| butt | tyłek | m; istniejące |
| vacuole (oozeling) | wakuola | ż; istniejące („wakuole”) |
| proboscis | trąbka | ż; nowe |
| glands | gruczoły | mn; istniejące |
| alien X (organ obcego) | X obcego (np. wątroba obcego) | wg organu; nowe |
| cybernetic heart / liver / lungs / stomach | cybernetyczne serce / cybernetyczna wątroba / cybernetyczne płuca / cybernetyczny żołądek | wg organu; istniejące („cybernetyczne serce”) |
| upgraded cybernetic X | ulepszone cybernetyczne X | wg organu; nowe |
| robotic eyes | robotyczne oczy | mn; nowe |
| robotic voicebox | robotyczny syntezator mowy | m; nowe |
| X-ray eyes / thermal eyes | oczy rentgenowskie / oczy termowizyjne | mn; nowe |
| implant | implant | m; istniejące (odrzucony: wszczep). Czasownik: wszczepić (istniejące) |
| cybernetic implant | implant cybernetyczny | m; nowe |
| arm-mounted implant | implant w ręce | m; nowe |
| HUD implant (medical / security / diagnostic) | implant HUD (medyczny / ochrony / diagnostyczny) | m; nowe |
| nutriment pump implant | implant pompy odżywczej | m; nowe |
| reviver implant | implant reanimacyjny | m; nowe |
| CNS rebooter implant | implant restartu OUN | m; nowe |
| anti-drop implant | implant przeciw upuszczaniu | m; nowe |
| breathing tube implant | implant rurki oddechowej | m; nowe |
| autosurgeon | autochirurg | m; istniejące |
| organ storage bag | torba na organy | ż; nowe |

### B.5 Operacje

„Surgery” = operacja (ż), „surgery step” = etap operacji (m). Nazwy operacji z wielkiej litery tylko na początku, nazwy etapów małą literą (jak w EN).

| EN | PL | rodzaj/uwagi |
|---|---|---|
| surgery, operation | operacja | ż; istniejące |
| surgery step | etap operacji | m; nowe |
| advanced surgery | zaawansowana chirurgia | ż; nowe |
| surgery procedure disk | dysk z procedurą chirurgiczną | m; nowe |
| make incision | wykonaj nacięcie | etap; istniejące („nacięcie”) |
| incision | nacięcie | n; istniejące |
| retract skin | rozchyl skórę | etap; istniejące („rozwarcie skóry”) |
| clamp bleeders | zaciśnij krwawiące naczynia | etap; istniejące („zaciskać krwawiące”) |
| mend incision, cautery | zamknij nacięcie (kauteryzacja) | etap; istniejące („kauteryzacja”) |
| saw bone | przepiłuj kość | etap; nowe |
| drill bone | nawierć kość | etap; nowe |
| organ manipulation / manipulate organs | manipulacja organami / manipuluj organami | ż; istniejące |
| prosthesis organ manipulation | manipulacja organami protezy | ż; nowe |
| alien organ manipulation | manipulacja organami obcego | ż; nowe |
| amputation / sever limb | amputacja / odetnij kończynę | ż; istniejące |
| replace limb, prosthetic replacement | przyszycie kończyny, wymiana na protezę | n / ż; istniejące („Przyszycie kończyny albo proteza”) |
| add prosthetic / secure prosthetic | przyłącz protezę / umocuj protezę | etap; nowe |
| augmentation | augmentacja | ż; istniejące |
| implant removal / extract implant | usunięcie implantu / wyjmij implant | n; nowe |
| cavity implant | implant w jamie ciała | m; nowe |
| dental implant | implant dentystyczny | m; nowe |
| removal of embedded objects | usuwanie ciał obcych | n; istniejące |
| eye surgery / fix eyes | operacja oczu / napraw oczy | ż; nowe |
| ear surgery / fix ears | operacja uszu / napraw uszy | ż; nowe |
| brain surgery / fix brain | operacja mózgu / napraw mózg | ż; istniejące |
| lobotomy | lobotomia | ż; istniejące |
| brainwashing | pranie mózgu | n; istniejące |
| pacification | pacyfikacja | ż; istniejące |
| revival | ożywienie | n; istniejące („operacją ożywienia”) |
| necrotic revival | ożywienie nekrotyczne | n; nowe |
| coronary bypass | bajpas wieńcowy | m; istniejące („bajpas”) |
| lobectomy | lobektomia | ż; nowe |
| hepatectomy | hepatektomia | ż; nowe |
| gastrectomy | gastrektomia | ż; nowe |
| lipoplasty | liposukcja | ż; nowe |
| plastic surgery / reshape face | operacja plastyczna / zmień rysy twarzy | ż; nowe |
| tend wounds | opatrywanie ran | n; istniejące („opatrzyć”) |
| Tend Wounds (Bruises / Burn / Mixture, Basic / Adv. / Exp.) | Opatrywanie ran (stłuczenia / oparzenia / mieszane, podst. / zaaw. / eksp.) | n; nowe |
| dissection / experimental dissection | sekcja / sekcja eksperymentalna | ż; nowe |
| autopsy | autopsja | ż; istniejące |
| viral bonding | wiązanie wirusowe | n; istniejące |
| blood filter / filter blood | filtracja krwi / przefiltruj krew | ż; nowe |
| stomach pump | płukanie żołądka | n; istniejące |
| core removal (szlam) | usunięcie rdzenia | n; nowe |
| bioware | biomodyfikacja | ż; nowe |
| cortex folding | fałdowanie kory | n; nowe |
| cortex imprint | odcisk kory | m; nowe |
| ligament hook | hak więzadłowy | m; nowe |
| ligament reinforcement | wzmocnienie więzadeł | n; nowe |
| muscled veins / vein muscle membrane | umięśnione żyły / błona mięśniowa żył | mn / ż; nowe |
| nerve grounding | uziemienie nerwów | n; nowe |
| nerve splicing | splecenie nerwów | n; nowe |
| vein threading | przeszycie żył | n; nowe |
| operating table | stół operacyjny | m; istniejące |
| operating computer | komputer operacyjny | m; nowe |
| surgical drapes | serweta chirurgiczna | ż; nowe |
| anesthetic, anesthesia | znieczulenie | n; istniejące („znieczulający”) |
| anesthetic tank holder | uchwyt na butlę z anestetykiem | m; nowe |
| sterile / sterilize | sterylny / sterylizować | przym.; istniejące |
| botch, fail (operacji) | spartaczyć | czas.; istniejące („partaczysz”) |

### B.6 Narzędzia chirurgiczne

| EN | PL | rodzaj/uwagi |
|---|---|---|
| scalpel | skalpel | m; istniejące |
| laser scalpel | skalpel laserowy | m; nowe |
| retractor | retraktor | m; istniejące (odrzucony: rozwieracz) |
| alien retractor / scalpel / hemostat / saw / drill / cautery | obcy retraktor / obcy skalpel / obce kleszczyki / obca piła / obca wiertarka / obcy kauter | m; nowe (narzędzia porywaczy) |
| hemostat | hemostat | m; istniejące |
| cautery | kauter | m; istniejące |
| circular saw | piła tarczowa | ż; istniejące |
| surgical drill | wiertło chirurgiczne | n; nowe |
| mechanical pinches | mechaniczne szczypce | mn; nowe |
| searing tool | narzędzie przyżegające | n; nowe |
| surgical processor | procesor chirurgiczny | m; nowe |
| autopsy scanner | skaner autopsyjny | m; istniejące |
| surgical toolset implant | implant z zestawem chirurgicznym | m; nowe |
| latex gloves | rękawiczki lateksowe | mn; nowe |
| sterilizer spray | sterylizator w sprayu | m; nowe |

### B.7 Sprzęt medyczny i chemiczny

| EN | PL | rodzaj/uwagi |
|---|---|---|
| health analyzer / advanced health analyzer | analizator zdrowia / zaawansowany analizator zdrowia | m; istniejące |
| first-aid kit / medical kit | apteczka | ż; istniejące |
| advanced first aid kit | zaawansowana apteczka | ż; nowe |
| burn / brute / toxin / oxygen deprivation / radiation treatment kit | apteczka na oparzenia / na urazy / na zatrucia / na niedotlenienie / przeciwradiacyjna | ż; nowe („apteczki toksykologiczne” istniejące) |
| combat medical kit | bojowa apteczka | ż; nowe |
| doctor's bag | torba lekarska | ż; nowe |
| gauze / medical gauze | gaza / gaza medyczna | ż; istniejące |
| improvised gauze / sterilized gauze | prowizoryczna gaza / sterylna gaza | ż; nowe |
| suture / medicated suture | nici chirurgiczne / nici z lekiem | mn; istniejące („nici”) |
| regenerative mesh / advanced | siatka regeneracyjna / zaawansowana siatka regeneracyjna | ż; istniejące („siatka”) |
| ointment | maść | ż; istniejące |
| bruise pack | opatrunek na stłuczenia | m; nowe |
| bandage | bandaż | m; istniejące |
| tourniquet | opaska uciskowa | ż; nowe (nazwa z PR aq33/AquilaStation#507) |
| patch / brute patch / burn patch | plaster / plaster na urazy / plaster na oparzenia | m; istniejące („plastry”) |
| pill | pigułka | ż; istniejące (odrzucony: tabletka) |
| pill bottle | pojemnik na pigułki | m; istniejące (ChemMaster) |
| bottle of X pills | pojemnik pigułek X | m; nowe |
| syringe | strzykawka | ż; istniejące |
| bluespace / piercing / lethal injection syringe | strzykawka bluespace / przebijająca / do śmiertelnego zastrzyku | ż; nowe |
| dropper | zakraplacz | m; nowe |
| beaker / large beaker | zlewka / duża zlewka | ż; istniejące |
| bluespace / cryostasis / metamaterial beaker | zlewka bluespace / kriostatyczna / z metamateriału | ż; istniejące („zlewki bluespace”) |
| bottle | butelka | ż; istniejące |
| vial | fiolka | ż; istniejące |
| culture bottle | butelka z kulturą | ż; nowe |
| hypospray | hypospray | m; istniejące |
| medipen | medipen | m; istniejące |
| autoinjector | autoinjektor | m; istniejące (odrzucony: autoiniektor, autowstrzykiwacz) |
| injector / DNA injector | iniektor / iniektor DNA | m; istniejące; odrzucony: wstrzykiwacz (DNA). Wzór nazwy: „iniektor DNA (Hulk)”, „iniektor DNA (anty-Hulk)” |
| combat stimulant injector | bojowy iniektor stymulantów | m; nowe |
| nanite injector / lazarus injector / holoparasite injector | iniektor nanitów / iniektor Łazarza / iniektor holoparazytów | m; nowe |
| backpack chemical injector (chemtank) | plecakowy iniektor chemikaliów | m; nowe |
| cyborg hypospray / epinephrine injector / laughter injector | hypospray cyborga / iniektor epinefryny / iniektor śmiechu | m; nowe (borghypo) |
| chemical bag / blood pack | worek chemiczny / worek z krwią | m; istniejące („Worki”) |
| IV drip / saline drip | kroplówka / kroplówka z solą fizjologiczną | ż; istniejące |
| medical spray | spray medyczny | m; nowe |
| spray bottle | spryskiwacz | m; istniejące |
| chem sprayer | rozpylacz chemiczny | m; istniejące („rozpylacz”) |
| defibrillator / compact / combat | defibrylator / kompaktowy / bojowy | m; istniejące |
| defibrillator paddles | łopatki defibrylatora | mn; istniejące |
| roller bed | nosze na kółkach | mn; nowe |
| stasis unit, lifeform stasis unit | łóżko stazy | n; istniejące |
| sleeper | sleeper | m; istniejące (sleepera, sleeperem). Odrzucony: uśpiacz. **Uwaga (C2, 29.10.2026):** sekcja 02 („sleeper → uśpiacz”) mówi co innego, a w kodzie są oba: maszyna `Sleeper.dm` ma `name = "sleeper"`, płytka, projekt w R&D, sprzęt mecha i bitrunning mają „uśpiacz”. Do rozstrzygnięcia przez koordynatora, nie ujednolicałem |
| cryo cell | kriokomora | ż; istniejące |
| cryogenic freezer (cryopod) | kapsuła kriogeniczna | ż; istniejące |
| cryostasis | kriostaza | ż; istniejące |
| cloning pod / cloning | kapsuła klonująca / klonowanie | ż / n; istniejące („kapsuł klonujących”, „klonowanie”) |
| vitals monitor | monitor funkcji życiowych | m; nowe |
| straight jacket / muzzle | kaftan bezpieczeństwa / kaganiec | m; istniejące / nowe |
| chem dispenser | dozownik chemiczny | m; istniejące („dozownik”) |
| booze / soda dispenser | dozownik alkoholu / dozownik napojów | m; nowe |
| ChemMaster 3000 / CondiMaster 3000 | ChemMaster 3000 / CondiMaster 3000 | m; nazwa urządzenia zostaje |
| chemical heater | podgrzewacz chemiczny | m; istniejące („podgrzewacz”) |
| All-In-One Grinder | rozdrabniacz wielofunkcyjny | m; nowe |
| mortar / pestle | moździerz / tłuczek | m; nowe |
| PanD.E.M.I.C 2200 | PanD.E.M.I.C 2200 | m; nazwa zostaje |
| smoke machine | wytwornica dymu | ż; nowe |
| reagent synthesizer | syntezator odczynników | m; nowe |
| plumbing synthesizer | syntezator chemii | m; nowe |
| grenade casing / chem grenade | obudowa granatu / granat chemiczny | ż / m; nowe |

### B.8 Choroby (wirusologia)

Pojęcia z okna PANDEMIC są już po polsku i to one są wzorem.

| EN | PL | rodzaj/uwagi |
|---|---|---|
| disease | choroba | ż; istniejące |
| virus | wirus | m; istniejące |
| symptom | symptom | m; istniejące (PANDEMIC: „Symptomy”). „Objaw” w zwykłej prozie medycznej |
| cure | lekarstwo | n; istniejące („Możliwe lekarstwo”) |
| antibodies | przeciwciała | mn; istniejące |
| vaccine | szczepionka | ż; istniejące |
| stage | stadium | n; istniejące |
| stealth | ukrycie | n; istniejące |
| resistance | odporność | ż; istniejące |
| stage speed | szybkość stadiów | ż; istniejące |
| transmission / transmittability | transmisja | ż; istniejące |
| severity / danger | groźność / zagrożenie | ż / n; istniejące |
| spread | rozprzestrzenianie | n; istniejące |
| carrier / host | nosiciel | m; istniejące |
| infected | zarażony | przym.; istniejące |
| contagious / non-contagious | zaraźliwy / niezaraźliwy | przym.; nowe |
| Airborne | Drogą powietrzną | spread_text; nowe |
| Contact / On contact | Przez kontakt | spread_text; istniejące |
| Blood | Przez krew | spread_text; nowe |
| Fluids | Przez płyny ustrojowe | spread_text; istniejące |
| Intentional Injection | Celowy zastrzyk | spread_text; nowe |
| Paranormal | Paranormalne | spread_text; nowe |
| None / Unknown | Brak / Nieznane | spread_text; nowe. UWAGA: „Unknown” jako nazwa choroby jest kluczem (sekcja Ostrzeżenia) |
| Virus / Disease / Infection / Condition / Advance Disease | Wirus / Choroba / Infekcja / Schorzenie / Choroba zaawansowana | form; nowe |
| culture | kultura (wirusa) | ż; istniejące |
| blood sample | próbka krwi | ż; istniejące |
| Appendicitis | Zapalenie wyrostka robaczkowego | n; istniejące |
| Beesease | Pszczołoza | ż; nowe |
| Brainrot | Gnicie mózgu | n; nowe |
| Cellular Degeneration | Degeneracja komórkowa | ż; nowe |
| Exolocomotive Xenomitosis | Egzolokomotoryczna ksenomitoza | ż; nowe |
| Fungal tuberculosis | Gruźlica grzybicza | ż; nowe |
| GBS / Non-Transmissible GBS | GBS / Niezaraźliwe GBS | n; nowe |
| Gluttony's Blessing | Błogosławieństwo Obżarstwa | n; nowe, identycznie jak reagent |
| Gondola Transformation | Przemiana w gondolę | ż; nowe |
| Invasive Gastrolosis | Inwazyjna gastroloza | ż; nowe |
| Jungle Fever | Gorączka dżungli | ż; nowe |
| Magnitis | Magnitis | m; nowe, nazwa zostaje |
| Myocardial Infarction | Zawał mięśnia sercowego | m; nowe |
| Nano-Feline Assimilative Toxoplasmosis | Nanokocia toksoplazmoza asymilacyjna | ż; istniejące (agent „Nanokocia toksoplazmoza”) |
| Necropolis Infestation | Plaga Nekropolii | ż; nowe |
| Parrot Possession | Opętanie przez papugę | n; nowe |
| Pierrot's Throat | Gardło Pierrota | n; nowe |
| Retrovirus / Space Retrovirus | Retrowirus / Kosmiczny retrowirus | m; nowe |
| Robotic Transformation | Przemiana w robota | ż; nowe |
| Severe Anxiety | Silny niepokój | m; nowe |
| Spanish inquisition Flu | Grypa hiszpańskiej inkwizycji | ż; nowe |
| Symbiotic Regeneration | Regeneracja symbiotyczna | ż; nowe |
| The Barkening | Szczekawica | ż; nowe |
| The Cold | Przeziębienie | n; istniejące |
| The Flu | Grypa | ż; istniejące |
| The Rhumba Beat | Rytm rumby | m; nowe |
| Transformation / Advanced Mutation Transformation | Przemiana / Zaawansowana przemiana mutacyjna | ż; nowe |
| Wizarditis | Czarodziejowica | ż; nowe |
| Xenomorph Transformation | Przemiana w ksenomorfa | ż; nowe |
| fleshy mass / infested floor / putrid infection | mięsista masa / zainfekowana podłoga / gnilne zakażenie | ż / ż / n; nowe |

### B.9 Symptomy chorób zaawansowanych

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Acute respiratory distress syndrome | Zespół ostrej niewydolności oddechowej | m; nowe |
| Alkali Perspiration | Zasadowe pocenie | n; nowe |
| Alopecia | Łysienie | n; nowe |
| Aptotic Culling | Apoptotyczna selekcja | ż; nowe |
| Autobrewery Syndrome | Zespół autobrowaru | m; nowe |
| Autophagocytosis Necrosis | Martwica autofagocytarna | ż; nowe |
| Basic Healing | Podstawowe leczenie | n; nowe |
| Bee Infestation | Plaga pszczół | ż; nowe |
| Biometallic Replication | Replikacja biometaliczna | ż; nowe |
| Blob Spores | Zarodniki bloba | mn; istniejące („zarodniki bloba”) |
| Bubonic Infection | Zakażenie dżumowe | n; nowe |
| Confusion | Dezorientacja | ż; istniejące |
| Cornu Cutaneum | Róg skórny | m; nowe |
| Cough | Kaszel | m; istniejące |
| Deafness | Głuchota | ż; istniejące |
| Deoxyribonucleic Acid Saboteur | Sabotażysta DNA | m; nowe |
| Dermagraphic Ovulogenesis | Dermagraficzna owulogeneza | ż; nowe |
| Ducatopod | Dukatonóg | m; nowe |
| Eternal Youth | Wieczna młodość | ż; nowe |
| Facial Hypertrichosis | Nadmierne owłosienie twarzy | n; nowe |
| Fever | Gorączka | ż; istniejące |
| Fleshy Egg / Fleshy Egg Sac | Mięsiste jajo / Mięsisty worek jajowy | n / m; nowe |
| Hallucigen | Halucygen | m; nowe |
| Headache | Ból głowy | m; istniejące |
| Heart Disease | Choroba serca | ż; nowe |
| Hemetophagy | Hematofagia | ż; nowe |
| Hemorrhaging Fasciitis | Krwotoczne zapalenie powięzi | n; nowe |
| Hyperactivity | Nadpobudliwość | ż; nowe |
| Hyperperspiration | Nadmierne pocenie | n; nowe |
| Hyphema | Krwiak komory oka | m; nowe |
| Hysteria | Histeria | ż; nowe |
| Inorganic Biology | Nieorganiczna biologia | ż; nowe |
| Iraddiant Cells | Promieniujące komórki | mn; nowe |
| Itching | Swędzenie | n; istniejące |
| Macrophage | Makrofag | m; nowe |
| Metabolic Boost | Przyspieszenie metabolizmu | n; nowe |
| Mind Restoration | Odbudowa umysłu | ż; nowe |
| Nano-symbiosis | Nanosymbioza | ż; nowe |
| Narcolepsy | Narkolepsja | ż; nowe |
| Necropolis Seed | Nasienie Nekropolii | n; nowe |
| Necrotic Metabolism | Metabolizm nekrotyczny | m; nowe |
| Neural Decay | Rozpad neuronów | m; nowe |
| Organ Restoration | Odbudowa organów | ż; nowe |
| Organic Flux Induction | Indukcja przepływu organicznego | ż; nowe |
| Photosensitive muscle condensation | Światłoczuła kondensacja mięśni | ż; nowe |
| Pituitary Disruption | Zaburzenie przysadki | n; nowe |
| Polyvitiligo / Revitiligo / Vitiligo | Polibielactwo / Rebielactwo / Bielactwo | n; nowe |
| Regenerative Coma | Śpiączka regeneracyjna | ż; istniejące („śpiączkę”) |
| SBG Syndrome | Zespół SBG | m; nowe |
| Self-Respiration | Samooddychanie | n; nowe |
| Sensory Restoration | Odbudowa zmysłów | ż; nowe |
| Shivering | Dreszcze | mn; nowe |
| Silicolysis | Krzemoliza | ż; nowe |
| Sneezing | Kichanie | n; istniejące |
| Spontaneous Combustion | Samozapłon | m; istniejące |
| Superficial Healing | Powierzchowne leczenie | n; nowe |
| Sweatsplash | Chlust potu | m; nowe |
| Thermal Retrostable Displacement | Termiczne przemieszczenie retrostabilne | n; nowe |
| Toxolysis | Toksoliza | ż; nowe |
| Toxoplasmosis Sapiens | Toxoplasmosis sapiens | ż; nowe, łacina zostaje |
| Viral Aggressive Metabolism | Agresywny metabolizm wirusa | m; nowe |
| Viral Evolutionary Acceleration | Przyspieszenie ewolucji wirusa | n; nowe |
| Viral Self-Adaptation | Samoadaptacja wirusa | ż; nowe |
| Viral Suspended Animation | Wirusowe zawieszenie funkcji życiowych | n; nowe |
| Viral power multiplier | Mnożnik siły wirusa | m; nowe |
| Voice Change | Zmiana głosu | ż; nowe |
| Vomiting | Wymioty | mn; istniejące |
| Weight Loss | Utrata wagi | ż; nowe |
| Xenobiological Symbiosis | Symbioza ksenobiologiczna | ż; nowe |
| clockwork / biometallic X (organy z symptomów) | mechaniczny / biometaliczny X | wg rzeczownika; nowe |

### B.10 Słownictwo chemiczne (okna i komunikaty)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| reagent | odczynnik | m; istniejące (Sleeper.tsx „Odczynniki”, ok. 160×). Odrzucony: reagent |
| chemicals | chemikalia | mn; istniejące |
| substance | substancja | ż; istniejące |
| compound | związek chemiczny | m; istniejące |
| reaction | reakcja | ż; istniejące |
| recipe (chemiczna) | receptura | ż; istniejące |
| catalyst | katalizator | m; istniejące |
| purity | czystość | ż; istniejące |
| impurity / impure | zanieczyszczenie / nieczysty | n / przym.; istniejące |
| inverse reagent | odwrócony odczynnik | m; istniejące („odwrócone odpowiedniki”) |
| isomer / monomer | izomer / monomer | m; istniejące / nowe |
| pH, acidic, basic | pH, kwaśny, zasadowy | ; istniejące |
| buffer | bufor | m; istniejące |
| precursor | prekursor | m; istniejące |
| units (u) | jednostki (j.) | mn; istniejące |
| volume | objętość | ż; istniejące („Podział objętości”) |
| state: Solid / Liquid / Gas | stan skupienia: stały / ciekły / gazowy | ; „Stan skupienia” istniejące, wartości w chem_master.dm jeszcze po EN |
| metabolization rate | tempo metabolizmu | n; istniejące |
| overdose threshold | próg przedawkowania | m; istniejące |
| addiction threshold | próg uzależnienia | m; istniejące |
| target temperature / current temperature | docelowa temperatura / obecna temperatura | ż; istniejące |
| dispense | wydaj, wydawanie | ; istniejące |
| transfer | przelej | ; nowe |
| eject (beaker) | wysuń | ; nowe |
| contents | zawartość | ż; istniejące |
| analysis / analyze | analiza / analizuj | ż; istniejące |
| explosion / foam / smoke | wybuch / piana / dym | m / ż / m; istniejące |
| taste | smak | m; istniejące („Smakuje jak …”) |
| glass of X / cup of X / mug of X / pint of X | szklanka X / kubek X / kieliszek X / kufel X | ż / m / m / m; istniejące (napoje: szklanka, wino i mocne trunki: kieliszek, piwo: kufel, kawa i herbata: kubek) |
| drink / cocktail | napój, drink / koktajl | m; istniejące |
| booze | alkohol | m; istniejące |
| fertilizer (plant nutriment) | nawóz | m; istniejące |
| virus food | pożywka dla wirusów | ż; nowe |



# Słownik, sekcja 04: LUDZIE I ŚWIAT

Zawody, działy, rangi, obszary, frakcje, antagoniści, rasy, moby, silicony, NSV13 (okręty, uzbrojenie, myśliwce, overmapa, FTL), marki i firmy.

Oznaczenia w kolumnie uwag:
- **m / ż / n / mnoga** – rodzaj gramatyczny (mnoga = rzeczownik tylko w liczbie mnogiej albo hasło w l.mn.). Przy osobach w l.mn. podana forma mianownika, bo bywa nieregularna.
- **istniejące** – tłumaczenie już jest w kodzie (z defines, nazw `/area`, datumów antagonistów, historii commitów tłumaczeniowych albo z polskich tekstów); **nowe** – zaproponowane tutaj, bo w kodzie jeszcze go nie było.
- **odrzucone:** – warianty, które w kodzie też występują, ale są w mniejszości albo z błędem. Istniejących polskich tekstów nie poprawiamy (CLAUDE.md), ale w nowych tekstach używamy wariantu ze słownika.

## 0. Zasady ogólne dla tej sekcji

| Zasada | Ustalenie |
|---|---|
| Nazwy zawodów | Teksty z `JOB_NAME_*` w `code/__DEFINES/jobs.dm` to klucze (preferencje, bany i czas gry w bazie). **Nie zmieniamy ich.** W zdaniach odmieniamy je normalnie i piszemy małą literą: „wezwij kwatermistrza”, „Starszy Oficer” tylko jako tytuł albo nagłówek. |
| Feminatywy | Domyślnie forma męska (jak w JOB_NAME). Forma żeńska tylko wtedy, gdy kod zna płeć postaci, a zdanie jest o niej: kapitanka, lekarka, kwatermistrzyni (ta ostatnia już jest w kodzie). |
| Statek czy stacja | Aquila to okręt. W tekstach o „naszym” miejscu gry piszemy **statek** (ogólnie) albo **okręt** (wojskowo, NSV13). „Stacja” zostaje tylko tam, gdzie chodzi o prawdziwą stację (stacja handlowa, placówka Syndykatu, teksty tg o Space Station 13). |
| Space ... | Przedrostek „Space” tłumaczymy przymiotnikiem **kosmiczny**: Space Wizard → Kosmiczny czarodziej, space carp → kosmiczny karp, Space Law → Prawo kosmiczne. |
| Nazwy firm | Firmy i marki zostają w oryginale (Nanotrasen, Donk Co., Cybersun Industries). Tłumaczymy tylko człon opisowy (Gorlex Marauders → Maruderzy Gorlex, Wizard Federation → Federacja Czarodziejów). |
| Przedrostki okrętów | NSV, SSV, SGV, DMC, DLV, SBC itd. zostają. Nazwa własna okrętu też zostaje: „NSV Zorn”, „SSV Hammurabi”. Odmiana: „na pokładzie NSV Zorn”, „Hammurabiego” (to drugie już jest w kodzie). |
| Klasy okrętów | Szyk polski: typ + „klasy” + nazwa. „Mako class patrol frigate” → „fregata patrolowa klasy Mako”. Nazwa klasy zostaje w oryginale. |
| Prawa i lewa burta | W zdaniach: **lewa burta** (port), **prawa burta** (starboard), **dziób** (fore), **rufa** (aft), istniejące. W nazwach obszarów istniejący schemat to Burta / Sterburta / Dziób / Rufa (patrz §9). |
| Kody i skróty | Skróty zostają: FTL, DRADIS, PDC, MAC, NAC, VLS, IFF, APC, SMES, IPC, MMI, ERT, EVA, ATC, CAG. „AI” piszemy **SI** (istniejące, 377×). |

## 1. Działy

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Command | Dowództwo | n; istniejące (radio, manifest, latejoin) |
| Security | Ochrona | ż; istniejące jako nazwa działu w menu; kanał radiowy i ludzie to **Policja** (patrz niżej) |
| Security (radio channel) | Policja | ż; istniejące (`RADIO_CHANNEL_SECURITY`, gałąź policja) |
| security (people, in prose) | policja / policjanci | ż / mnoga (policjanci); istniejące; odrzucone: ochroniarze (13×, tylko w starych tekstach) |
| Engineering | Inżynieria | ż; istniejące (radio, manifest) |
| Medical | Medyczny (dział medyczny) | m; istniejące (radio, manifest); w zdaniu „dział medyczny”, „lekarze” |
| Science / Research | Nauka (dział naukowy) | ż; istniejące; kanał radiowy „Naukowy”; odrzucone: dział badawczy (w nazwach obszarów zostaje „Wydział Badawczy”) |
| Supply / Cargo | Zaopatrzenie | n; istniejące; kanał radiowy „Dostawy” (istniejące) |
| Service | Służba | ż; istniejące (radio); odrzucone: Serwis (karta ID, 3×), Usługi |
| Civilian | Cywile | mnoga; istniejące (latejoin) |
| Munitions | Amunicja (dział amunicji) | ż; istniejące (manifest, latejoin) |
| Silicon | Syntetyki | mnoga; istniejące (latejoin); pojedynczy: syntetyk (m) |
| Gimmick / Special | Specjalne | mnoga; istniejące (latejoin); grupa ról gimmick w defines to „Cywilne” |
| Air Traffic Control (radio) | Kontrola Lotów | ż; istniejące (`RADIO_CHANNEL_ATC`) |
| Common (radio) | Ogólny | m; istniejące |
| AI Private (radio) | Prywatny SI | m; istniejące jako „Prywatny AI”, w nowych tekstach „SI” |
| Syndicate (radio) | Syndykat | m; istniejące |
| CentCom (radio) | Centrala | ż; istniejące |
| department | dział | m; istniejące |
| head of staff / department head | szef działu | m; istniejące (szefowie działów) |
| heads of staff | szefowie działów | mnoga; istniejące |
| command staff | dowództwo | n; istniejące |
| crew | załoga | ż; istniejące |
| crewmember / crewman | członek załogi | m; istniejące |
| civilian (person) | cywil | m; nowe |

## 2. Zawody (JOB_NAME, nie zmieniać)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Captain | Kapitan | m; istniejące |
| Executive Officer / XO / Head of Personnel / HoP | Starszy Oficer | m; istniejące; odrzucone: Kadrowy (stara nazwa), Szef Personelu, Oficer Wykonawczy (w nazwach obszarów) |
| Midshipman / Assistant | Majtek | m; istniejące; l.mn. majtkowie; odrzucone: Asystent jako nazwa stanowiska. W żartach i aluzjach do „szarej fali” z tg „asystent” zostaje (tak jest w wielu starych tekstach: mood, napisy końcowe, ion_laws, phobia, plakaty), więc przegląd C2 nie zmieniał takich miejsc |
| Bartender | Barman | m; istniejące |
| Botanist | Botanik | m; istniejące |
| Cook / Chef | Kucharz | m; istniejące |
| Janitor | Woźny | m; istniejące |
| Curator | Bibliotekarz | m; istniejące; odrzucone: kurator („gabloty bibliotekarza”, „uchwyt wystawy obrazów bibliotekarza”) |
| Lawyer | Prawnik | m; istniejące |
| Chaplain | Kapłan | m; istniejące (JOB_NAME); przy ERT jest „Kapelan”, poza ERT odrzucone: kapelan |
| Mime | Mim | m; istniejące |
| Clown | Klaun | m; istniejące; l.mn. klauni |
| Stage Magician | Magik | m; istniejące |
| Barber | Fryzjer | m; istniejące |
| VIP | VIP | m; istniejące; nieodmienne |
| Psychiatrist | Psychiatra | m; istniejące |
| Quartermaster / QM | Kwatermistrz | m; istniejące; odrzucone: Kwartermistrz, Kwatermisztrz (literówki w obszarach) |
| Cargo Technician | Magazynier | m; istniejące |
| Shaft Miner / Miner | Górnik | m; istniejące |
| Bitrunner | Bitrunner | m; istniejące; odm. bitrunnera |
| Chief Engineer / CE | Główny Inżynier | m; istniejące; odrzucone: Starszy Inżynier (w nazwie obszaru) |
| Station Engineer / Engineer | Inżynier | m; istniejące |
| Atmospheric Technician | Technik Atmosferyki | m; istniejące |
| Chief Medical Officer / CMO | Ordynator | m; istniejące; odrzucone: główny lekarz (także w `dream_messages` prześcieradeł) |
| Medical Doctor | Lekarz | m; istniejące |
| Paramedic | Ratownik Medyczny | m; istniejące |
| Chemist | Chemik | m; istniejące |
| Virologist | Wirolog | m; istniejące |
| Geneticist | Genetyk | m; istniejące |
| Brig Physician | Lekarz Więzienny | m; istniejące |
| Research Director / RD | Dyrektor Naukowy | m; istniejące; odrzucone: Dyrektor Badań (obszar) |
| Scientist | Naukowiec | m; istniejące |
| Roboticist | Robotyk | m; istniejące |
| Exploration Crew / Explorer | Odkrywca | m; istniejące |
| Head of Security / HoS | Komendant | m; istniejące; odrzucone: szef ochrony (jako nazwa stanowiska) |
| Warden | Naczelnik | m; istniejące |
| Security Officer / Military Police / MP | Policjant | m; istniejące; odrzucone: Żandarm (stary tytuł, migrowany w policja.dm) |
| Detective | Detektyw | m; istniejące |
| Deputy | Aspirant | m; istniejące |
| Master at Arms / MAA | Mistrz Broni | m; istniejące |
| Bridge Staff / Bridge Officer / BO | Oficer Pokładowy | m; istniejące |
| Munitions Technician | Technik Amunicyjny | m; istniejące |
| Pilot | Pilot | m; istniejące |
| Air Traffic Controller / ATC | Kontroler Lotów | m; istniejące |
| Deck Technician / Deck Tech | Technik Pokładowy | m; istniejące |
| AI | SI Statku | ż; istniejące (JOB_NAME); w zdaniach po prostu „SI” |
| Cyborg | Cyborg | m; istniejące |
| pAI / Personal AI | Osobista SI | ż; istniejące; skrót pAI zostaje w nazwach przedmiotów |
| King | Król | m; nowe (JOB_NAME_KING jest jeszcze po angielsku, nie zmieniać bez decyzji) |
| Prisoner | Więzień | m; nowe (j.w.) |
| Space Police | Kosmiczna Policja | ż; nowe |
| Gimmick (group) | Cywilne | mnoga; istniejące |

### 2a. ERT i Centrala

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Emergency Response Team / ERT | Zespół Reagowania Kryzysowego (ZRK) | m; istniejące; skrót ERT dopuszczalny w nazwach przedmiotów |
| ERT Commander | Dowódca Zespołu Reagowania Kryzysowego | m; istniejące |
| ERT Officer / ERT Security | Operator Kryzysowego Reagowania | m; istniejące |
| ERT Engineer | Inżynier Kryzysowego Reagowania | m; istniejące |
| ERT Medic | Sanitariusz Kryzysowego Reagowania | m; istniejące (w defines literówka „SAnitariusz”) |
| ERT Chaplain | Kapelan Kryzysowego Reagowania | m; istniejące |
| ERT Janitor | Woźny Kryzysowego Reagowania | m; istniejące |
| Death Commando / Deathsquad | Komandos Śmierci / Szwadron Śmierci | m / m; istniejące |
| CentCom response team / emergency response team (proza, panel admina) | zespół reagowania Centrali / zespół reagowania kryzysowego | m; nowe; odrzucone: oddział reagowania |
| Deathsquad Officer | Oficer szwadronu śmierci | m; istniejące |
| HONK Squad | Oddział HONK | m; istniejące |
| Central Command / CentCom | Centrala | ż; istniejące (148× „Centrali”); odrzucone: Centralne Dowództwo (6×, tylko w tytułach osób) |
| CentCom Official | Przedstawiciel Centralnego Dowództwa | m; istniejące (JOB tytuł zostaje) |
| CentCom Intern | Stażysta Centrali | m; istniejące |
| Admiral | Admirał | m; istniejące |
| CentCom Commander | Komandor Centrali | m; nowe |
| VIP Guest | Gość VIP | m; nowe |
| CentCom Bartender | Barman Centrali | m; nowe |
| Custodian | Dozorca | m; nowe |
| Thunderdome Overseer | Nadzorca Thunderdome | m; nowe |
| Medical Officer (CentCom) | Oficer Medyczny | m; nowe |
| Research Officer | Oficer Naukowy | m; nowe |
| Nanotrasen Representative | Przedstawiciel Nanotrasen | m; nowe |

## 3. Rangi i stopnie

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Admiral | admirał | m; istniejące |
| Fleet Admiral | admirał floty | m; nowe |
| Vice Admiral | wiceadmirał | m; nowe |
| Rear Admiral | kontradmirał | m; istniejące |
| Commodore | komandor | m; istniejące (komandor Zot itd.) |
| Commander | komandor | m; istniejące; gdy trzeba odróżnić od Commodore: komandor porucznik (nowe) |
| Captain (rank) | kapitan | m; istniejące |
| Lieutenant Commander | komandor podporucznik | m; nowe |
| Lieutenant | porucznik | m; istniejące |
| Second Lieutenant / Sub-Lieutenant | podporucznik | m; nowe |
| Ensign | chorąży | m; nowe |
| Midshipman | majtek | m; istniejące |
| Chief Petty Officer | starszy bosman | m; nowe |
| Petty Officer | bosmanmat | m; istniejące (Biuro Bosmanmata) |
| Sergeant | sierżant | m; istniejące |
| Sergeant-at-Arms | sierżant broni | m; nowe |
| Corporal | kapral | m; istniejące |
| Private | szeregowy | m; istniejące |
| Marine | żołnierz piechoty | m; istniejące (Żołnierz piechoty Syndykatu); l.mn. piechota (ż) |
| Space Marine | kosmiczny marine | m; nowe; żartobliwe „SPESS MAHREENS” → „KOSMICZNI MAHRYNI” (istniejące) |
| Officer | oficer | m; istniejące |
| Squad | drużyna | ż; istniejące (67× „drużyny”); odrzucone: skład, oddział |
| Squad Leader | dowódca drużyny | m; nowe; odrzucone: dowódca oddziału (1×) |
| Squad Kit | zestaw drużyny | m; nowe; odrzucone: zestaw składu |
| Squad Pager | pager drużyny | m; nowe |
| Able / Baker / Charlie / Duff (squads) | Able / Baker / Charlie / Duff | nazwy własne drużyn, bez tłumaczenia |
| CAG (Commander Air Group) | CAG (dowódca grupy lotniczej) | m; istniejące „CAG Syndykatu” |
| Flight Leader | dowódca klucza | m; nowe |
| Wingman | skrzydłowy | m; nowe |
| Strategist | strateg | m; istniejące |
| Requisitions Officer | kwatermistrz | m; istniejące (Kwatermistrz Syndykatu) |
| Ringleader | przywódca | m; nowe |
| Lieutenant (gang) | porucznik | m; istniejące (Porucznik gangu) |
| Boss (gang) | szef | m; istniejące (Szef gangu) |
| Acting Captain | pełniący obowiązki kapitana | m; nowe |

## 4. Organizacje, frakcje, miejsca świata

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Nanotrasen / NT | Nanotrasen / NT | ż (korporacja); istniejące; zwykle nieodmienne (579×), dopuszczalne „Nanotrasenu” w dopełniaczu |
| Syndicate | Syndykat | m; istniejące; Syndykatu, Syndykatem |
| Syndie (slang) | syndyk | m; istniejące (1×), potocznie |
| Abassi Syndicate | Syndykat Abassi | m; nowe (Abassi istniejące) |
| Abassi Ridge | Grzbiet Abassi | m; istniejące |
| SolGov / Solar Government | SolGov | m; istniejące (SolGovu, SolGovowi) |
| Solar Federation / Sol | Federacja Słoneczna / Sol | ż; nowe |
| Tortuga Raiders | Najeźdźcy z Tortugi | mnoga (najeźdźcy); istniejące |
| Space Pirates | kosmiczni piraci | mnoga; istniejące |
| Wizard Federation / Space Wizard Federation | Federacja Czarodziejów / Kosmiczna Federacja Czarodziejów | ż; istniejące |
| Wizard Academy | Akademia Czarodziejów | ż; nowe (Nauczyciel Akademii istniejące) |
| Gorlex Marauders | Maruderzy Gorlex | mnoga; istniejące; „Własność Maruderów Gorlex”, „zaprojektowany przez Maruderów Gorlex”; odrzucone: Gorlex Marauders w polskim zdaniu |
| Tiger Cooperative | Tiger Cooperative | ż; istniejące, nieodmienne |
| Spider Clan | Klan Pająka | m; nowe |
| Cybersun Industries | Cybersun Industries | ż; istniejące |
| Interdyne Pharmaceutics | Interdyne Pharmaceutics (Interdyne) | ż; istniejące |
| MI13 | MI13 | n; nowe; nieodmienne |
| Donk Co. | Donk Co. | ż; nowe; marka, nieodmienne |
| Waffle Co. | Waffle Co. | ż; istniejące |
| White Rapids | White Rapids | nieodmienne; istniejące (Flota White Rapids, Dowództwo Floty White Rapids) |
| Fleet Command | Dowództwo Floty | n; istniejące |
| Concord | Konkord | m; nowe |
| Earth Defense Force | Siły Obrony Ziemi | mnoga; nowe |
| Lizard Empire | Imperium Jaszczurów | n; nowe |
| Mothic Fleet | Flota Ćm | ż; nowe |
| Spinward Stellar Coalition | Gwiezdna Koalicja Spinward | ż; nowe |
| Rubicon | Rubikon | m; istniejące (w nazwie systemu w kodzie „Rubicon” zostaje) |
| Dolos | Dolos | m; istniejące |
| Lavaland | Lavaland | m; istniejące (Lavalandu, na Lavalandzie) |
| Icemoon | Lodowy Księżyc | m; nowe |
| Necropolis | Nekropolia | ż; istniejące |
| Reebe | Reebe | n; nieodmienne |
| City of Cogs | Miasto Zębatek | n; nowe |
| Mansus | Mansus | m; istniejące jako nazwa obszaru |
| Space Station 13 | Stacja Kosmiczna 13 | ż; nowe (tylko gdy tekst naprawdę mówi o SS13) |
| Space Law | Prawo kosmiczne | n; istniejące |
| Thunderdome | Thunderdome | m; nieodmienne nazwy własne; nowe |
| Central Command Docks | Doki Centrali | mnoga; nowe |
| Clown Planet | Planeta Klaunów | ż; nowe |

## 5. Antagoniści i role specjalne

| EN | PL | rodzaj/uwagi |
|---|---|---|
| antagonist / antag | antagonista | m; istniejące |
| Traitor | Zdrajca | m; istniejące; l.mn. zdrajcy |
| Syndicate agent | agent Syndykatu | m; istniejące |
| Sleeper Agent | uśpiony agent Syndykatu | m; nowe |
| Internal Affairs Agent | Agent spraw wewnętrznych | m; istniejące |
| Excommunicated traitor | Wyklęty zdrajca | m; istniejące |
| Contractor | kontraktor | m; istniejące (Jednostka wsparcia kontraktora) |
| uplink | uplink | m; istniejące (uplink Syndykatu) |
| Blood Brother | Brat krwi | m; istniejące; l.mn. bracia krwi |
| Changeling | Zmiennokształtny | m; istniejące; l.mn. zmiennokształtni; odrzucone: changeling/changelingi w polskim zdaniu |
| Changeling hivemind | jaźń roju zmiennokształtnych | ż; nowe |
| Heretic | Heretyk | m; istniejące; l.mn. heretycy |
| Lunatic | Szaleniec | m; nowe |
| Cultist / Blood Cultist | Kultysta / Kultysta krwi | m; istniejące; l.mn. kultyści |
| Blood Cult | Kult krwi | m; istniejące |
| Nar'Sie | Nar'Sie | ż; istniejące, nieodmienne |
| Clock Cultist / Servant of Ratvar | Kultysta Ratvara / Sługa Ratvara | m; istniejące; kult = kult zegara (kultyści zegara) |
| Ratvar | Ratvar | m; istniejące (Ratvara) |
| Construct | konstrukt | m; istniejące |
| Juggernaut | Juggernaut | m; istniejące |
| Wraith (construct) | Widmo | n; nowe (Wraith ≠ Revenant) |
| Artificer | Rzemieślnik | m; nowe |
| Harvester | Żniwiarz | m; nowe |
| Shade | Cień | m; istniejące |
| Soulstone | kamień duszy | m; nowe |
| Wizard / Space Wizard | Czarodziej / Kosmiczny czarodziej | m; istniejące; l.mn. czarodzieje |
| Witch | czarownica | ż; istniejące |
| Apprentice | Uczeń czarodzieja | m; istniejące |
| Wizard Imposter | Fałszywy czarodziej | m; istniejące |
| Nuclear Operative / Nuke Op | Operator nuklearny | m; istniejące; l.mn. operatorzy nuklearni |
| Lone Operative | Samotny operator | m; istniejące |
| Clown Operative | Klaun-operator | m; istniejące; l.mn. klauni-operatorzy |
| Nuclear Emergency / Nuclear Assault | Zagrożenie nuklearne / Szturm nuklearny | n / m; nowe |
| nuke disk / nuclear authentication disk | dysk nuklearny | m; istniejące („DYSK”) |
| Syndicate Operative (mob, NPC) | Operator Syndykatu | m; nowe |
| Syndicate Commando | Komandos Syndykatu | m; nowe |
| Syndicate Stormtrooper | Szturmowiec Syndykatu | m; nowe |
| Syndicate Infiltrator | Infiltrator Syndykatu | m; istniejące |
| Provocateur | Prowokator | m; nowe |
| Revolutionary | Rewolucjonista | m; istniejące; l.mn. rewolucjoniści |
| Head Revolutionary | Przywódca rewolucji | m; istniejące |
| Revolution | Rewolucja | ż; istniejące |
| Enemy of the Revolution | Wróg rewolucji | m; istniejące |
| Abductor | Porywacz | m; istniejące; l.mn. porywacze; odrzucone w nowych tekstach: abduktor (zostaje w starych tekstach bitrunningu i tips.txt); „płytka maszyny porywaczy” |
| Abductor Agent / Scientist | Agent porywaczy / Naukowiec porywaczy | m; istniejące |
| Abductee | Uprowadzony | m; istniejące |
| Mothership | statek-matka | m; nowe |
| Xenomorph / Alien | Ksenomorf / obcy | m; istniejące; l.mn. ksenomorfy, obcy |
| Alien Infestation | Inwazja obcych | ż; nowe |
| alien queen | królowa ksenomorfów | ż; istniejące |
| alien empress | cesarzowa ksenomorfów | ż; nowe |
| alien praetorian | pretorianin | m; nowe |
| alien hunter | łowca | m; nowe |
| alien sentinel | strażnik | m; nowe |
| alien drone | dron obcych | m; nowe |
| larva | larwa | ż; istniejące |
| facehugger | facehugger | m; istniejące, l.mn. facehuggery |
| alien egg | jajo obcych | n; nowe |
| hive / resin | gniazdo / żywica | n / ż; „galaretowata żywica” istniejące |
| Blob | Grzyb | m; istniejące w module bloba (Grzyb cię uderza, zgrzybialec); odrzucone: Blob/bloba (nazwa datumu i stare opisy). Także panel admina („Stwórz grzyba”), zakładka statpanelu `Blob: 'Grzyb'`, verb `'Make Blob': 'Zrób grzyba'` |
| Blob Overmind | Grzybóg | m; istniejące |
| blob core / node / resource blob | rdzeń grzyba / węzeł / grzyb zasobów | m; istniejące (Węzły, rdzeń grzyba); odrzucone: Bloby zasobów |
| blob spore | zarodnik grzyba | m; nowe |
| Blobbernaut | Grzybonaut | m; istniejące |
| blob zombie | zgrzybialec | m; istniejące |
| Revenant | Upiór | m; istniejące; l.mn. upiory; odrzucone: revenant/revenanta (także w komunikatach dla adminów) |
| Morph | Morf | m; istniejące |
| Nightmare | Koszmar | m; istniejące |
| Space Dragon | Kosmiczny smok | m; istniejące |
| carp rift | szczelina karpi | ż; nowe |
| Slaughter Demon | Demon rzezi | m; istniejące |
| Laughter Demon | Demon śmiechu | m; istniejące |
| Sinful Demon | Grzeszny demon | m; istniejące |
| Pulse Demon | Demon impulsu | m; istniejące |
| Shadow Demon | Demon cieni | m; istniejące |
| Devil | Diabeł | m; istniejące; l.mn. diabły |
| Imp | Chochlik | m; istniejące |
| Sintouched | naznaczony grzechem | m; istniejące |
| Vampire | Wampir | m; istniejące |
| Vassal | Wasal | m; istniejące |
| Darkspawn | Darkspawn | m; istniejące (l.mn. darkspawni) |
| Thrall | thrall | m; istniejące (thralle) |
| Swarmer | Rojowiec | m; istniejące |
| Ninja / Space Ninja | Ninja / Kosmiczny ninja | m; istniejące; nieodmienne |
| Pirate / Space Pirate | Kosmiczny pirat | m; istniejące |
| Boarder | Abordażysta | m; istniejące; l.mn. abordażyści |
| Fugitive | Zbieg | m; istniejące; l.mn. zbiegowie |
| Fugitive Hunter | Łowca zbiegów | m; istniejące |
| Obsessed | Opętany obsesją | m; istniejące |
| Hijacked AI | Przejęta SI | ż; istniejące |
| Malfunctioning AI / Malf AI | Zbuntowana SI | ż; istniejące |
| Hivemind Host | Nosiciel roju | m; istniejące |
| Awakened Vessel | Przebudzone naczynie | n; istniejące |
| Gang / Gangster | gang / gangster | m; istniejące |
| Survivalist | Survivalowiec | m; istniejące |
| Separatists | Separatyści | mnoga; istniejące |
| Paradox Clone | Klon paradoksu | m; istniejące |
| Chrono Legionnaire | Chronolegionista | m; istniejące |
| Voidwalker | Wędrowiec pustki | m; istniejące |
| Bingle | Bingiel | m; istniejące; l.mn. bingle |
| Blood Worm | Krwawy robak | m; istniejące |
| Spy | Szpieg | m; istniejące; l.mn. szpiedzy |
| Thief | Złodziej | m; istniejące |
| Eldritch Horror / Horror | Pradawny horror | m; istniejące |
| Bloodling | Pan krwiaków / krwiak | m; istniejące |
| Teratoma | Teratoma | ż; istniejące |
| Monkey (antag) | Małpa / Przywódca małp | ż / m; istniejące |
| Brainwashed victim | Ofiara prania mózgu | ż; istniejące |
| Holoparasite / Guardian | Holoparazyt / Strażnik | m; istniejące |
| Santa | Mikołaj | m; istniejące |
| Highlander | nieśmiertelny | m; istniejące |
| Valentine | walentynka | ż; istniejące |
| Heartbreaker | Łamacz serc | m; istniejące |
| objective | cel | m; istniejące (Twoje cele) |
| Greentext | zwycięzca | m; istniejące |

## 6. Rasy (gatunki)

| EN | PL | rodzaj/uwagi |
|---|---|---|
| species / race | gatunek / rasa | m / ż; istniejące oba (rasa w preferencjach i DNA) |
| Human | Człowiek | m; istniejące; l.mn. ludzie |
| Lizardperson / Lizard | Jaszczur | m; istniejące (42×); l.mn. jaszczury; przym. jaszczurzy; odrzucone: jaszczuroczłowiek (3×, zostaje w prawach SI), jaszczuroczłek |
| Ash Walker | Popielny wędrowiec | m; istniejące |
| Mothman / Mothperson / Moth | Ćma | ż; istniejące; l.mn. ćmy, dopełniacz l.mn. ciem (też o męskich postaciach: „woźny-ćma”); odrzucone: ćmoczłowiek, ćmoludzie |
| Ethereal | Eteryk | m; istniejące; l.mn. eterycy; odrzucone: ethereal, etherealowi, etereale |
| Plasmaman | Plazmaman | m; istniejące; l.mn. plazmaludzie (istniejące); odrzucone: plazmaczłowiek, plazmoludzie, plazmoludź |
| Felinid | Felinid | m; istniejące; l.mn. felinidzi |
| Apid | Apid | m; istniejące; l.mn. apidzi |
| IPC / Integrated Positronic Chassis | IPC (zintegrowane podwozie pozytroniczne) | n; istniejące skrót, rozwinięcie nowe |
| Android | Android | m; istniejące |
| Oozeling | Oozeling | m; istniejące |
| Jellyperson | Galaretoczłowiek | m; nowe |
| Slimeperson | Szlamoczłowiek | m; istniejące; l.mn. szlamoludzie |
| Luminescent | Luminescent | m; istniejące |
| Stargazer | Gwiezdny obserwator | m; nowe |
| Podperson | Roślinoczłowiek | m; istniejące |
| Flyperson | Muchoczłowiek | m; istniejące |
| Snailperson | Ślimakoczłowiek | m; istniejące |
| Squidperson | Kałamarnicoczłowiek | m; istniejące (kałamarnicoludzie) |
| Eggperson | Jajoczłowiek | m; istniejące |
| Mushroomperson | Grzyboczłowiek | m; nowe |
| Golem | Golem | m; istniejące; „X Golem” → golem + przymiotnik materiału: plazmowy golem, diamentowy golem, plastalowy golem, golem z obcego stopu |
| Free Golem | Wolny golem | m; nowe |
| Skeleton | Szkielet | m; istniejące |
| Zombie | Zombie | n; istniejące; nieodmienne |
| High-Functioning Zombie | Wysokofunkcyjne zombie | n; nowe |
| Dullahan | Dullahan | m; istniejące |
| Abductor (species) | Porywacz | m; istniejące |
| Monkey | Małpa | ż; istniejące |
| Shadowperson | Cieniak | m; nowe |
| Super Soldier | Superżołnierz | m; nowe |
| Corporate Agent | Agent korporacyjny | m; nowe |
| Teratoma | Teratoma | ż; istniejące |
| Vox / Skrell / Tajaran / Unathi | Vox / Skrell / Tajaran / Unathi | m; nazwy własne, bez tłumaczenia |

## 7. Silicony

| EN | PL | rodzaj/uwagi |
|---|---|---|
| AI / Artificial Intelligence | SI / sztuczna inteligencja | ż; istniejące |
| AI core | rdzeń SI | m; istniejące |
| AI shell | powłoka SI | ż; istniejące (powłoka) |
| AI eye | oko SI | n; nowe |
| AI upload | przesyłanie praw (konsola przesyłania praw) | n; nowe |
| AI Satellite | satelita SI | m; istniejące |
| AI integrity restorer / intelicard | przywracacz SI / intelikarta | m / ż; nowe |
| silicon (mob) | syntetyk | m; istniejące |
| laws | prawa | mnoga; istniejące |
| law | prawo | n; istniejące |
| law zero / zeroth law | prawo zerowe | n; istniejące |
| lawset | zestaw praw | m; nowe |
| Asimov | Asimov | m; nazwa zestawu praw; istniejące |
| Crewsimov | Załogimov | m; nowe |
| hacked / emagged | zhakowany / zemagowany | przym.; nowe |
| emag | emag | m; istniejące |
| cyborg | cyborg | m; istniejące |
| borg (slang) | borg | m; istniejące |
| module (cyborg) | moduł | m; istniejące |
| Default / Standard module | moduł standardowy | m; nowe |
| Medical module | moduł medyczny | m; istniejące |
| Engineering module | moduł inżynieryjny | m; nowe |
| Security module | moduł ochrony | m; istniejące |
| Peacekeeper module | moduł rozjemcy | m; nowe; odrzucone: strażnik pokoju (1×) |
| Service module | moduł usługowy | m; istniejące (usługowy) |
| Janitor module | moduł porządkowy | m; nowe |
| Miner module | moduł górniczy | m; nowe |
| Clown module | moduł klauna | m; nowe |
| Borgi module | moduł Borgi | m; nazwa własna |
| Syndicate Assault / Medical / Saboteur | szturmowy / medyczny / sabotażowy moduł Syndykatu | m; nowe |
| Munitions module | moduł amunicyjny | m; nowe |
| cyborg upgrade | ulepszenie cyborga | n; nowe |
| recharger / recharge station | ładowarka cyborgów / stacja ładowania | ż; nowe |
| MMI / Man-Machine Interface | MMI | n; istniejące |
| positronic brain / posibrain | mózg pozytroniczny | m; istniejące (pozytroniczny dominuje) |
| drone (maintenance) | dron | m; istniejące |
| Syndrone | syndron | m; istniejące |
| pAI card | karta pAI | ż; nowe |
| holoform | holoforma | ż; nowe |
| static (camera) | zakłócenia | mnoga; nowe |
| bot | bot | m; nowe; l.mn. boty |
| Securitron | securitron | m; istniejące |
| Officer Beepsky | Oficer Beepsky | m; istniejące (Oficera Beepsky'ego) |
| ED-209 | ED-209 | m; bez zmian |
| Medibot | medibot | m; istniejące |
| Cleanbot | cleanbot | m; istniejące |
| Floorbot | floorbot | m; nowe |
| Firebot | firebot | m; nowe |
| Honkbot | honkbot | m; nowe |
| Atmosbot | atmosbot | m; nowe |
| MULEbot | MULEbot | m; istniejące |
| Hugbot | przytulobot | m; nowe |
| Hivebot | hivebot | m; nowe (odm. hivebota) |
| viscerator | wypruwacz | m; nowe |

## 8. Moby i zwierzęta

### 8a. Zwierzęta domowe i pospolite

| EN | PL | rodzaj/uwagi |
|---|---|---|
| animal | zwierzę | n; istniejące |
| creature / mob | istota | ż; istniejące (Najbliższe istoty, Skocz do istoty) |
| pet | zwierzak | m; nowe |
| corgi | corgi | m; istniejące; nieodmienne w mianowniku, dop. corgiego |
| corgi puppy | szczeniak corgi | m; nowe |
| Ian | Ian | m; istniejące (pies Starszego Oficera) |
| pug | mops | m; nowe |
| bull terrier | bulterier | m; nowe |
| dog | pies | m; istniejące |
| cat / kitten | kot / kociak | m; istniejące / nowe |
| Runtime | Runtime | ż (kotka); nazwa własna |
| space cat | kosmiczny kot | m; nowe |
| fox | lis | m; istniejące |
| mouse | mysz | ż; istniejące |
| rat | szczur | m; istniejące |
| Regal Rat / rat king | Szczurzy król | m; istniejące |
| cockroach | karaluch | m; istniejące |
| mothroach | ćmokaraluch | m; istniejące |
| cow | krowa | ż; istniejące |
| goat | koza | ż; istniejące |
| sheep | owca | ż; nowe |
| chicken / chick | kura / pisklę | ż / n; istniejące / nowe |
| turkey | indyk | m; nowe |
| pig | świnia | ż; nowe |
| crab | krab | m; istniejące |
| penguin / penguin chick | pingwin / pisklę pingwina | m / n; istniejące / nowe |
| Emperor penguin | pingwin cesarski | m; nowe |
| gorilla | goryl | m; nowe |
| monkey | małpa | ż; istniejące |
| bear / space bear | niedźwiedź / kosmiczny niedźwiedź | m; istniejące / nowe |
| polar bear | niedźwiedź polarny | m; nowe |
| bee / queen bee | pszczoła / królowa pszczół | ż; istniejące |
| killer bee | pszczoła zabójczyni | ż; nowe |
| butterfly | motyl | m; nowe |
| snake | wąż | m; istniejące |
| frog | żaba | ż; istniejące |
| bat / space bat | nietoperz / kosmiczny nietoperz | m; istniejące / nowe |
| sloth | leniwiec | m; nowe |
| hamster | chomik | m; nowe |
| lizard (animal) | jaszczurka | ż; istniejące (DNA jaszczurki); rasa to „jaszczur” |
| goose | gęś | ż; istniejące |
| parrot | papuga | ż; istniejące |
| Poly | Poly | ż (papuga); istniejące |
| dolphin | delfin | m; nowe |
| axolotl | aksolotl | m; nowe |
| turtle | żółwik | m; istniejące |
| Wojtek | Wojtek | m; istniejące (niedźwiedź) |
| Kerfuś | Kerfuś | m; istniejące |
| gondola | gondola | ż; nowe |
| ant / giant ant | mrówka / olbrzymia mrówka | ż; istniejące / nowe |
| spider / giant spider | pająk / pająk olbrzymi | m; istniejące |
| spiderling | pajączek | m; istniejące |
| tarantula | tarantula | ż; istniejące |
| slime | szlam | m; istniejące; l.mn. szlamy |
| adult / baby slime | dorosły / młody szlam | m; nowe |
| space carp | kosmiczny karp | m; istniejące |
| megacarp | megakarp | m; nowe |
| holocarp | holokarp | m; nowe |
| killer tomato | pomidor zabójca | m; nowe |
| eyeball | gałka oczna | ż; nowe |
| goldfish / fish | złota rybka / ryba | ż; nowe |

### 8b. Wrogie moby, megafauna, Lavaland

| EN | PL | rodzaj/uwagi |
|---|---|---|
| megafauna | megafauna | ż; nowe |
| goliath | goliat | m; istniejące (goliatów) |
| goliath broodmother | matka goliatów | ż; nowe |
| ancient goliath | pradawny goliat | m; nowe |
| legion | legion | m; istniejące |
| legion skull | czaszka legionu | ż; nowe |
| dwarf legion | karłowaty legion | m; nowe |
| legionnaire | legionista | m; istniejące |
| watcher | obserwator | m; nowe |
| magmawing / icewing watcher | ogniskrzydły / lodoskrzydły obserwator | m; nowe |
| hivelord | władca roju | m; istniejące (mob, rdzeń regeneracyjny, holoparazyt); odrzucone: pan roju; legowisko: „legowisko władców roju” |
| basilisk | bazyliszek | m; nowe |
| goldgrub | złoty pędrak | m; nowe |
| gutlunch / gubbuck / guthen | żarłoczek / żarłoczek samiec / żarłoczka | m / m / ż; nowe |
| ash drake | popielny smok | m; istniejące |
| bubblegum | Bubblegum | m; istniejące |
| colossus | Kolos | m; istniejące |
| hierophant | Hierofant | m; istniejące |
| blood-drunk miner | górnik upojony krwią | m; nowe |
| herald | herold | m; nowe |
| pandora | Pandora | ż; nowe |
| lightgeist | świetlik | m; nowe |
| ice skeleton / undead | lodowy szkielet / nieumarły | m; nowe |
| mi-go | mi-go | m; nowe |
| wumborian fugu | wumboriańska fugu | ż; nowe |
| headspider / headcrab | pająk-głowa | m; nowe |
| hivebot | hivebot | m; nowe |
| gremlin | gremlin | m; nowe |
| ghost | duch | m; istniejące |
| phantom / spirit | widmo / duch | n / m; istniejące |
| statue (mob) | posąg | m; nowe |
| clown (mob) / Honkling / Fleshclown | klaun / honkuś / mięsoklaun | m; nowe |
| Russian / Russian Officer | Rosjanin / rosyjski oficer | m; nowe |
| Syndicate Mecha Pilot | pilot mecha Syndykatu | m; nowe |
| Nanotrasen Private Security Officer | prywatny ochroniarz Nanotrasen | m; nowe |
| corpse (spawner) | zwłoki | mnoga; istniejące (Zwłoki [H.name]) |
| walking mushroom | chodzący grzyb | m; istniejące |
| venus human trap | ludzka muchołówka | ż; nowe |
| pine tree | sosna | ż; nowe |

## 9. Obszary i pomieszczenia (nazwy `/area`)

Nazwy obszarów są w większości przetłumaczone. Nowe nazwy budujemy z tych klocków. Wielka litera w każdym członie (jak w istniejących nazwach).

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Bridge | Mostek | m; istniejące |
| Battle Bridge | Mostek Bojowy | m; istniejące |
| CIC (Combat Information Center) | CIB (Centrum Informacji Bojowej) | n; istniejące |
| Captain's Office / Quarters | Biuro Kapitana / Kwatera Kapitana | n / ż; istniejące |
| XO / HoP Office | Biuro Starszego Oficera | n; nowe; odrzucone: Biuro Szefa Personelu, Biuro Oficera Wykonawczego |
| Heads of Staff Meeting Room / Conference Room | Sala Konferencyjna Szefów Działów | ż; istniejące jako „Sala konferencyjna szefów personelu”, w nowych „działów” |
| Council Chamber | Izba Rady | ż; istniejące |
| Vault | Skarbiec | m; istniejące; odrzucone: Krypta |
| Teleporter | Pomieszczenie z Teleportacją | n; istniejące |
| Gateway | Brama | ż; istniejące |
| EVA Storage | Magazyn EVA | m; istniejące |
| Brig | Areszt | m; istniejące; odrzucone: Bryg |
| Security Office / Precinct | Komisariat | m; istniejące |
| Security Post / Checkpoint | Posterunek Policji / Punkt Kontroli Bezpieczeństwa | m; istniejące |
| Armory | Zbrojownia | ż; istniejące |
| Warden's Office | Biuro Naczelnika | n; istniejące |
| HoS Office | Gabinet Komendanta | m; istniejące |
| Detective's Office | Biuro Detektywa | n; istniejące |
| Courtroom | Sala Sądowa | ż; istniejące |
| Lawyer's Office | Biuro Prawne | n; istniejące |
| Prison Wing / Permabrig | Skrzydło Więzienne | n; istniejące |
| Labor Camp / Gulag | Obóz Pracy / Gułag | m; nowe / istniejące |
| Interrogation | Pokój Przesłuchań | m; nowe |
| Execution Room | Komora Egzekucyjna | ż; nowe |
| Locker Room | Szatnia | ż; istniejące |
| Medbay | Ambulatorium | n; istniejące w prozie (17×); w nazwach obszarów zostaje „Placówka Medyczna” |
| Medbay Lobby | Izba Przyjęć | ż; istniejące |
| Sickbay | Izba Chorych | ż; istniejące |
| Surgery / Operating Theatre | Chirurgia / Sala Operacyjna | ż; istniejące |
| Chemistry | Pracownia Chemiczna | ż; istniejące |
| Apothecary / Pharmacy | Apteka | ż; istniejące |
| Virology | Wirusologia | ż; istniejące |
| Genetics | Laboratorium Genetyczne | n; istniejące |
| Cloning | Laboratorium Klonowania | n; istniejące |
| Morgue | Kostnica | ż; istniejące |
| Cryogenics | Kriogenika | ż; istniejące |
| Cryopod Room / Cryo Storage | Pokój Kriokapsuł | m; istniejące |
| CMO's Office | Biuro Ordynatora | n; istniejące |
| Psychologist Office | Gabinet Psychologa | m; istniejące |
| Science / Research Division | Wydział Badawczy | m; istniejące |
| Research and Development / R&D | Badania i Rozwój (B+R) | mnoga; istniejące |
| Toxins / Ordnance Lab | Laboratorium Mieszania Toksyn | n; istniejące |
| Xenobiology | Laboratorium Ksenobiologii | n; istniejące |
| Robotics | Robotyka / Laboratorium Robotyki | ż / n; istniejące |
| Mech Bay | Warsztat Mechów | m; istniejące |
| Server Room | Serwerownia | ż; istniejące |
| RD's Office | Biuro Dyrektora Naukowego | n; nowe; odrzucone: Biuro Dyrektora Badań |
| Engineering | Inżynieria | ż; istniejące |
| Engine Room | Maszynownia | ż; istniejące |
| Supermatter Engine | Maszynownia Supermaterii | ż; istniejące |
| Atmospherics | Atmosferyka | ż; istniejące |
| Telecommunications | Telekomunikacja (Serwerownia Telekomunikacji) | ż; istniejące |
| Gravity Generator | Pomieszczenie Generatora Grawitacji | n; istniejące jako „Generatora Grawitacyjnego” |
| Main Power / Power Room | Główna Rozdzielnia | ż; istniejące |
| Substation | Podstacja | ż; istniejące |
| Solars / Solar Array | Panele Słoneczne | mnoga; istniejące |
| Tech Storage | Magazyn Techniczny | m; istniejące |
| Tool Storage | Magazyn Narzędziowy | m; istniejące |
| CE's Office | Biuro Głównego Inżyniera | n; nowe; odrzucone: Biuro Starszego Inżyniera |
| Construction Area | Plac Budowy | m; istniejące |
| Cargo Bay | Ładownia | ż; istniejące (4×); odrzucone: Zatoka Ładunkowa (kalka) |
| Cargo Office | Biuro Zaopatrzenia | n; nowe forma; odrzucone: Biuro Zapoatrzeń (literówka) |
| Delivery Office | Biuro Dostaw | n; istniejące |
| QM's Office | Biuro Kwatermistrza | n; istniejące (bez literówki) |
| Mining Dock / Office | Dok Górniczy / Biuro Górnicze | m / n; istniejące |
| Bar / Lounge | Bar / Salon | m; istniejące (Bar i Salon) |
| Kitchen | Kuchnia | ż; istniejące |
| Cold Room / Freezer | Chłodnia | ż; istniejące |
| Hydroponics | Hydroponika | ż; istniejące |
| Cafeteria | Kafeteria | ż; istniejące |
| Mess Hall | Stołówka | ż; istniejące |
| Library | Biblioteka | ż; istniejące |
| Chapel / Chapel Office | Kaplica / Biuro Kaplicy | ż / n; istniejące |
| Monastery | Klasztor | m; istniejące |
| Theatre / Backstage | Teatr / Kulisy | m / mnoga; istniejące |
| Janitor's Closet / Custodial | Pomieszczenie Dla Służb Porządkowych | n; istniejące |
| Dormitories | Kwatery Załogi | mnoga; istniejące |
| Restrooms / Toilets | Toalety | mnoga; istniejące |
| Fitness Room / Gym | Pokój Fitnessu | m; istniejące jako „Fitnesu”, w nowych z „ss” |
| Recreation Area | Obszar Rekreacyjny | m; istniejące |
| Holodeck | Holodek | m; nowe |
| Laundry | Pralnia | ż; istniejące |
| Pool | Basen | m; istniejące |
| Arrivals | Przyloty | mnoga; istniejące |
| Departures / Escape | Hala Odlotów | ż; istniejące |
| Hallway | Korytarz | m; istniejące |
| Primary / Main Hallway | Główny Korytarz | m; istniejące |
| Central | Centralny | przym.; istniejące |
| Maintenance (area names) | Tunel Konserwacyjny | m; istniejące (58×) |
| maintenance / maints (prose) | tunele techniczne | mnoga; istniejące w prozie; odrzucone: tunele serwisowe |
| Waste Disposal | Utylizacja Odpadów | ż; istniejące |
| Storage | Magazyn | m; istniejące |
| Auxiliary | Pomocniczy | przym.; istniejące |
| Abandoned | Opuszczony | przym.; istniejące |
| Derelict | Wrak / zrujnowany | m / przym.; nowe |
| AI Chamber / Core | Komora SI | ż; istniejące |
| AI Upload Chamber | Komora Programowania SI | ż; istniejące |
| Space | Kosmos | m; nowe dla obszaru (w zdaniu: kosmos, przestrzeń kosmiczna) |
| Hyperspace | Nadprzestrzeń | ż; istniejące |
| Shuttle | Prom | m; istniejące; odrzucone: Wahadłowiec (tylko w kilku nazwach) |
| Emergency / Escape Shuttle | Prom Ewakuacyjny | m; istniejące (ewakuacyjny) |
| Escape Pod | Kapsuła Ratunkowa | ż; istniejące |
| Supply Shuttle | Prom Zaopatrzeniowy | m; nowe |
| Mining Shuttle | Prom Górniczy | m; nowe (NSV13 Mining Shuttle w obszarach to „Prom Wydobywczy”) |
| Labor Shuttle | Prom Więzienny | m; nowe; odrzucone: Wahadłowiec Pracy |
| Arrival Shuttle | Prom Przylotów | m; nowe |
| Dock | Dok | m; istniejące |
| Airlock | Śluza | ż; istniejące |
| Elevator / Turbolift | Winda / Turbowinda | ż; istniejące (Winda Hammurabiego) / nowe |
| Stairs | Schody | mnoga; istniejące |
| Hangar | Hangar | m; istniejące |
| Flight Deck | Pokład Lotniczy | m; istniejące |
| Air Traffic Control | Kontrola Lotów / Wieża ATC | ż; istniejące |
| Pilot Lounge | Hol Pilotów | m; istniejące |
| Munitions Bay / Ordnance Bay | Komora Uzbrojenia | ż; istniejące |
| Weapons Bay / Ordnance Handling | Obsługa Uzbrojenia | ż; istniejące |
| Magazine (ammo) | Magazyn Amunicji | m; nowe |
| Gauss Bay / Gauss Battery | Komory Gaussa / Bateria Gaussa | mnoga / ż; istniejące |
| Artillery Bay | Artyleria | ż; istniejące |
| Torpedo Bay / Launchers | Wyrzutnie | mnoga; istniejące (Wyrzutnie 1 & 2) |
| Munitions Lounge / Equipment Room | Świetlica Amunicji / Pokój Wyposażenia Amunicji | ż / m; nowe |
| Squad Equipment Room | Pokój Wyposażenia Drużyn | m; istniejące |
| Damage Control | Kontrola Uszkodzeń | ż; nowe |
| FTL Control Room | Pokój Kontroli Napędu Nadświetlnego | m; istniejące |
| FTL Drive Core | Rdzeń Napędu Nadświetlnego | m; istniejące |
| Reactor Core / Reactor Control | Rdzeń Reaktora / Kontrola Reaktora | m / ż; istniejące |
| Stormdrive | Napęd Stormdrive | m; istniejące |
| Shield Generator | Generator Tarczy | m; istniejące |
| Nuclear Silo | Silos Nuklearny | m; istniejące |
| Deck 1 / 2 / 3 | Pierwszy / Drugi / Trzeci Pokład | m; istniejące |
| Frame (ship section) | Rama | ż; istniejące |
| Fore / Forward | Dziób (dop. Dzioba) | m; istniejące |
| Aft | Rufa | ż; istniejące |
| Port (area names) | Burta | ż; istniejące w nazwach obszarów (w prozie: lewa burta) |
| Starboard | Sterburta | ż; istniejące (w prozie: prawa burta) |
| Quarter (Port/Starboard Quarter) | Bakburta | ż; istniejące w nazwach obszarów (marynarsko niepoprawne, ale konsekwentne w mapach; w prozie „rufowa część lewej/prawej burty”) |
| Bow | Dziób | m; istniejące |
| Support Vessel | Statek Wsparcia | m; istniejące |
| Mining Station / Outpost | Stacja Górnicza / Placówka | ż; nowe |
| Listening Post | Posterunek Nasłuchowy | m; nowe |
| Syndicate Base / Outpost | Baza Syndykatu / Placówka Syndykatu | ż; istniejące „placówkę Syndykatu” |
| Wizard's Den | Kryjówka Czarodzieja | ż; nowe |
| Thunderdome Arena | Arena Thunderdome | ż; nowe |
| Virtual Domain (bitrunning) | Domena Wirtualna | ż; istniejące |

## 10. NSV13: okręty i klasy

| EN | PL | rodzaj/uwagi |
|---|---|---|
| ship | statek / okręt | m; istniejące (okręt dla jednostek wojennych) |
| warship | okręt wojenny | m; istniejące |
| vessel | jednostka | ż; istniejące („Jednostka zakotwiczona przez większy okręt”) |
| flagship | okręt flagowy | m; istniejące |
| overmap ship | okręt na overmapie | m; nowe |
| player ship / main ship | okręt załogi | m; nowe |
| class (ship) | klasa | ż; „fregata klasy Mako” |
| frigate | fregata | ż; nowe |
| patrol frigate | fregata patrolowa | ż; nowe |
| light frigate | lekka fregata | ż; nowe |
| flak frigate | fregata przeciwlotnicza | ż; nowe |
| anti-air frigate | fregata przeciwlotnicza | ż; nowe |
| marine frigate | fregata desantowa | ż; nowe |
| destroyer | niszczyciel | m; nowe |
| missile destroyer | niszczyciel rakietowy | m; nowe |
| flak destroyer | niszczyciel przeciwlotniczy | m; nowe |
| torpedo destroyer | niszczyciel torpedowy | m; nowe |
| Hellfire destroyer | niszczyciel Hellfire | m; nowe |
| hellfire deterrent | odstraszacz Hellfire | m; nowe |
| cruiser | krążownik | m; nowe |
| light cruiser | lekki krążownik | m; nowe |
| medium cruiser | średni krążownik | m; nowe |
| heavy cruiser | ciężki krążownik | m; nowe |
| tactical cruiser | krążownik taktyczny | m; nowe |
| patrol cruiser | krążownik patrolowy | m; nowe |
| support cruiser | krążownik wsparcia | m; nowe |
| assault cruiser | krążownik szturmowy | m; nowe |
| advanced cruiser | zaawansowany krążownik | m; istniejące (zaawansowany krążownik Syndykatu) |
| battlecruiser | krążownik liniowy | m; istniejące |
| battleship | pancernik | m; istniejące |
| battlestar | gwiazda bojowa | ż; nowe |
| dreadnought | drednot | m; nowe |
| carrier | lotniskowiec | m; nowe |
| escort carrier | lotniskowiec eskortowy | m; nowe |
| combat carrier | lotniskowiec bojowy | m; nowe |
| corvette | korweta | ż; nowe |
| gunboat | kanonierka | ż; nowe |
| missile boat | ścigacz rakietowy | m; nowe |
| raider | rajder | m; nowe |
| sub-spacemarine | okręt podprzestrzenny | m; nowe (gra słów „submarine”) |
| scout | zwiadowca (okręt zwiadowczy) | m; nowe |
| interceptor | myśliwiec przechwytujący | m; nowe |
| interdictor | okręt przechwytujący | m; nowe |
| freighter / hauler | frachtowiec | m; nowe |
| mining hauler / mining rig | frachtowiec górniczy / platforma wydobywcza | m / ż; nowe |
| tanker / supply ship | tankowiec / statek zaopatrzeniowy | m; nowe |
| station (overmap) | stacja | ż; istniejące |
| trade station | stacja handlowa | ż; nowe |
| shipyard | stocznia | ż; nowe |
| arms depot | skład broni | m; nowe |
| outpost | placówka | ż; istniejące |
| wreck / derelict | wrak | m; istniejące (wrak okrętu pirackiego) |
| escape pod | kapsuła ratunkowa | ż; istniejące |
| drop pod | kapsuła desantowa | ż; istniejące |
| boarding pod | kapsuła abordażowa | ż; nowe |
| dropship / drop ship | statek desantowy | m; istniejące (`dropship.dm`); obszar: „Statek Desantowy”, „Statek Desantowy Syndykatu”; odrzucone: desantowiec (to osoba) |
| drop trooper | desantowiec | m; nowe („skafander desantowca”, „zostaje desantowcem Syndykatu”) |
| shuttle | prom | m; istniejące; odrzucone: wahadłowiec („fotel promu”, „zestaw do budowy kradzionego promu”) |
| Celerity class escape shuttle (Dominion of Light) | prom ewakuacyjny klasy Celerity Dominium Światła | m; nowe; szyk „typ + klasy + nazwa” także dla promów |
| interior (ship map) | wnętrze | n; nowe („fregata klasy Mako (wnętrze)”) |
| ghost ship | statek widmo | m; istniejące |

## 11. NSV13: uzbrojenie i amunicja

| EN | PL | rodzaj/uwagi |
|---|---|---|
| munitions | amunicja | ż; istniejące |
| ordnance | uzbrojenie | n; istniejące (Komora Uzbrojenia) |
| ship weapon | broń okrętowa | ż; nowe |
| weapon safeties | blokady zabezpieczające broni | mnoga; istniejące |
| railgun | działo szynowe | n; istniejące (stare komunikaty `railgun_construction.dm`, `hybrid_railgun.dm`, `weapon_datum_types.dm`); odrzucone: railgun w polskim zdaniu („railguna”, „railguny”). **Konflikt:** sekcja 02 §12 wybiera „railgun”; przegląd C2 (29.10.2026) ujednolicił dodane linie do „działa szynowego”, decyzja należy do koordynatora |
| coaxial railgun | współosiowe działo szynowe | n; nowe („współosiowe działo szynowe NT-ST049 „Sturm””, broń overmapy „Współosiowe działa szynowe”, „Hybrydowe działa szynowe”) |
| railgun rail / loading tray | szyna działa szynowego / podajnik działa szynowego | ż / m; nowe (sam przedmiot podajnika to „podajnik”) |
| fighter railgun | działo szynowe myśliwca | n; nowe |
| railgun slugs (as plural in prose) | pociski szynowe | mnoga; nowe |
| railgun canister filler / charger, forge coating / core tank | napełniarka / ładowarka kanistrów działa szynowego, zbiornik powłoki / rdzenia kuźni pocisków szynowych | ż / m; nowe (`railgun_forge.dm`) |
| railgun assembly | okrętowe stanowisko działa szynowego | n; nowe |
| railgun slug | pocisk szynowy | m; nowe |
| railgun canister | kanister | m; istniejące |
| railgun forge | kuźnia pocisków szynowych | ż; nowe |
| MAC / Magnetic Accelerator Cannon | MAC (magnetyczne działo akceleracyjne) | n; istniejące skrót, rozwinięcie nowe |
| NAC / Naval Artillery Cannon | NAC (artyleria okrętowa) | ż; istniejące („Artyleria okrętowa gotowa”) |
| naval artillery round / shell | pocisk artylerii okrętowej | m; nowe |
| deck gun / deck turret | działo pokładowe | n; nowe |
| broadside cannon | działo burtowe | n; istniejące („dział burtowych”) |
| broadside shell | pocisk burtowy | m; istniejące (pociski burtowe) |
| shell packer | pakowarka pocisków | ż; nowe |
| Gauss gun / turret | działo Gaussa / wieżyczka Gaussa | n / ż; istniejące |
| PDC / point defense cannon | PDC (działko obrony punktowej) | n; istniejące (obrony punktowej) |
| flak | flak | m; istniejące (sterowanie flakiem) |
| flak round | pocisk flak | m; nowe |
| AA turret / anti-air gun | wieżyczka przeciwlotnicza | ż; nowe |
| laser anti-missile system / AMS | laserowy system antyrakietowy (AMS) | m; nowe |
| point-defense laser | laser obrony punktowej | m; nowe |
| phaser / phase cannon | fazer / działo fazowe | m / n; nowe |
| Bluespace Artillery / BSA | artyleria bluespace (BSA) | ż; nowe |
| torpedo | torpeda | ż; istniejące |
| torpedo tube / launcher | wyrzutnia torped | ż; istniejące |
| freight torpedo | torpeda transportowa | ż; istniejące |
| missile | pocisk rakietowy / rakieta | m / ż; istniejące (rakiet, rakietowy) |
| cruise missile | pocisk manewrujący | m; nowe |
| VLS / VLS tube | VLS / wyrzutnia pionowa VLS | ż; nowe |
| VLS launch hatch | właz wyrzutni VLS | m; nowe |
| warhead | głowica (bojowa) | ż; istniejące |
| thermonuclear warhead | głowica termojądrowa | ż; nowe |
| casing | obudowa | ż; istniejące (obudowa głowicy torpedy) |
| payload | ładunek | m; istniejące (bramka ładunku) |
| guidance system | układ naprowadzania | m; istniejące |
| propulsion system | układ napędowy | m; istniejące |
| IFF card | karta IFF | ż; istniejące |
| gunpowder / powder bag | proch / worek prochu | m; istniejące / nowe |
| powder loading gate | bramka prochu | ż; istniejące |
| payload loading gate | bramka ładunku | ż; istniejące |
| ammo rack | stojak na amunicję | m; istniejące (stojak z amunicją) |
| loading tray | podajnik | m; nowe |
| ammo sorter | sortownik amunicji | m; nowe |
| munitions trolley | wózek amunicyjny | m; nowe |
| bullet casing (cartridge case) | łuska | ż; istniejące |
| round / cartridge | nabój / pocisk | m; istniejące |
| armour-piercing | przeciwpancerny | przym.; nowe |
| incendiary | zapalający | przym.; nowe |
| countermeasures / chaff / flares | środki przeciwdziałania / flary | mnoga; nowe |
| barrel | lufa | ż; istniejące |
| firing electronics | elektronika spustowa | ż; nowe |
| gunner chair | fotel działonowego | m; nowe |
| gunner | działonowy | m; nowe |
| munitions pinpointer | lokalizator amunicji | m; nowe |
| swabber | wycior | m; nowe |
| jam (weapon) | zacięcie | n; istniejące (pocisk się zaciął) |
| reload | przeładowanie | n; istniejące |
| chambered | w komorze | istniejące (Pocisk w komorze) |
| Seegson autowrench / autowelder | automatyczny klucz / automatyczna spawarka Seegson | m / ż; nowe |

## 12. NSV13: myśliwce i lotnictwo

| EN | PL | rodzaj/uwagi |
|---|---|---|
| fighter | myśliwiec | m; istniejące |
| light fighter | lekki myśliwiec | m; nowe |
| heavy fighter | ciężki myśliwiec | m; nowe |
| utility fighter / utility vessel | jednostka pomocnicza | ż; nowe |
| superiority fighter | myśliwiec przewagi powietrznej | m; nowe |
| attack fighter | myśliwiec szturmowy | m; nowe |
| strike fighter | myśliwiec uderzeniowy | m; nowe |
| bomber | bombowiec | m; nowe |
| fighter frame | rama myśliwca | ż; nowe |
| fighter component | podzespół myśliwca | m; nowe |
| cockpit | kokpit | m; istniejące |
| canopy | osłona kokpitu | ż; istniejące |
| avionics | awionika | ż; nowe |
| APU / auxiliary power unit | APU (pomocniczy zespół zasilania) | m; nowe |
| fighter battery | akumulator myśliwca | m; nowe; w zdaniu ogólnym „bateria” (istniejące) |
| fuel tank | zbiornik paliwa | m; istniejące |
| fuel / tyrosene | paliwo / tyrozen | n / m; istniejące / nowe |
| fuel hose / fuel pump | wąż paliwowy / pompa paliwa | m / ż; istniejące |
| refuel | tankować | czas.; istniejące (zatankowana) |
| engine | silnik | m; nowe |
| armour plates | płyty pancerza | mnoga; istniejące |
| primary / secondary weapon | broń główna / broń pomocnicza | ż; nowe |
| missile rack | wyrzutnia rakiet | ż; nowe |
| countermeasure dispenser | wyrzutnik flar | m; nowe |
| targeting sensors | czujniki celownicze | mnoga; nowe |
| docking computer | komputer dokowania | m; nowe |
| hardpoint | punkt montażowy | m; nowe |
| cargo hold | ładownia | ż; istniejące |
| electromagnetic catapult / mag-cat | katapulta elektromagnetyczna | ż; istniejące (katapulta) |
| arrestor | hak hamujący | m; nowe |
| launch / launch tube | start / tuba startowa | m / ż; nowe |
| landing | lądowanie | n; nowe |
| eject / ejection | katapultować się / katapultowanie | czas. / n; istniejące |
| handbrake / brakes | hamulec ręczny / hamulce | m; istniejące |
| inertial dampeners | tłumiki bezwładności | mnoga; istniejące |
| aircraft tug | holownik | m; nowe |
| squadron | eskadra | ż; istniejące |
| flight | klucz | m; nowe |
| lance (AI formation) | szyk | m; nowe |
| dogfight | walka kołowa | ż; nowe |
| combat dice | kości bojowe | mnoga; nowe |
| air-to-air refueling | tankowanie w locie | n; nowe |
| repair kit | zestaw naprawczy | m; nowe |

## 13. NSV13: overmapa, nawigacja, FTL, systemy okrętu

| EN | PL | rodzaj/uwagi |
|---|---|---|
| overmap | overmapa | ż; istniejące (overmapie, overmapy) |
| starmap | mapa gwiezdna | ż; nowe |
| star system / system | układ gwiezdny / system | m; istniejące oba; w nazwach z kodu „system” |
| sector | sektor | m; istniejące |
| FTL | FTL | m (napęd); istniejące; „napęd FTL”, „skok FTL” |
| FTL drive | napęd FTL | m; istniejące |
| FTL jump | skok FTL | m; istniejące |
| spool up / spooling (FTL) | rozkręcanie (napędu), rozkręcić napęd | n; w TGUI utrwalone („Rozkręcanie FTL:”, „Rozkręć napęd”, „Włącz autorozkręcanie”); stary komunikat radia „Rozpoczęto rozgrzewanie FTL.” zostaje |
| warmup (stan pylonu) | rozgrzewanie | n; tylko stan pylonu (`PYLON_STATUS_NAMES` w `FTLComputerModular.tsx`), bo pylon ma osobno warmup i spooling |
| jump point / destination | cel skoku | m; istniejące |
| hyperspace | nadprzestrzeń | ż; istniejące |
| bluespace | bluespace | m; istniejące; przym. bluespace'owy |
| Thirring Drive | napęd Thirringa | m; nowe |
| Stormdrive | napęd burzowy (Stormdrive) | m; istniejące oba; w nazwach własnych zostaje Stormdrive |
| warp drive / quantum slipstream drive | napęd warp / napęd kwantowego strumienia | m; nowe |
| pylon (FTL) | pylon | m; istniejące |
| helm / helm console | ster / konsola steru | m / ż; istniejące „ster” |
| helmsman | sternik | m; nowe |
| tactical console | konsola taktyczna | ż; istniejące (STEROWANIE TAKTYCZNE) |
| navigation | nawigacja | ż; istniejące (dane nawigacyjne) |
| DRADIS | DRADIS | m; istniejące (DRADIS-u) |
| cargo DRADIS | DRADIS ładunkowy | m; istniejące |
| radar / sensors | radar / czujniki | m / mnoga; istniejące |
| hull | kadłub | m; istniejące |
| hull plating | poszycie kadłuba | n; istniejące |
| armour (ship) | pancerz | m; istniejące |
| armour plating / armour quadrant | płyty pancerza / ćwiartka pancerza | mnoga / ż; istniejące / nowe |
| nano-repair pump / well | pompa / studnia nanonaprawcza | ż; nowe |
| integrity | integralność | ż; nowe |
| shields | tarcze | mnoga; istniejące |
| shield generator | generator tarczy | m; istniejące |
| PDSR / Defence Screen Reactor | PDSR (reaktor ekranu obronnego) | m; nowe |
| flux capacitor | kondensator strumienia | m; nowe |
| self-destruct | autodestrukcja | ż; nowe |
| damage control | kontrola uszkodzeń | ż; nowe |
| boarding | abordaż | m; istniejące |
| boarding party | grupa abordażowa | ż; nowe |
| interdiction | przechwycenie | n; nowe |
| beacon (capture) | radiolatarnia | ż; istniejące |
| patrol / patrol node | patrol / punkt patrolowy | m; nowe |
| fleet | flota | ż; istniejące |
| taskforce | zespół uderzeniowy | m; nowe |
| scout fleet | flota zwiadowcza | ż; nowe |
| border defense force | siły obrony granicy | mnoga; nowe |
| holding fleet | flota rezerwowa | ż; nowe |
| interdiction fleet | flota przechwytująca | ż; istniejące („flotę przechwytującą”) |
| Armada | Armada | ż; istniejące (Armada Syndykatu) |
| reinforcements | posiłki | mnoga; istniejące |
| faction | frakcja | ż; istniejące |
| influence | wpływy | mnoga; nowe |
| mission | misja | ż; istniejące |
| trader | handlarz | m; istniejące |
| supply drop / supply pod | zrzut zaopatrzenia / kapsuła zaopatrzeniowa | m / ż; istniejące „kapsuł zaopatrzeniowych” |
| Galactic Conquest (mode) | Podbój Galaktyki | m; nowe |
| combat (overmap) | starcie | n; nowe |

## 14. Marki, firmy, producenci

| EN | PL | rodzaj/uwagi |
|---|---|---|
| Nanotrasen | Nanotrasen | ż; istniejące |
| Donk Co. | Donk Co. | ż; nowe |
| Donk Pocket | pierożek Donk | m; istniejące („ciepły jagodowy pierożek”, „DONK POCKETS → PIEROGI”) |
| Donksoft | Donksoft | m; nowe |
| Waffle Co. | Waffle Co. | ż; istniejące |
| Cybersun Industries | Cybersun Industries | ż; istniejące |
| Interdyne Pharmaceutics | Interdyne Pharmaceutics | ż; istniejące |
| Gorlex Marauders | Maruderzy Gorlex | mnoga; istniejące |
| Tiger Cooperative | Tiger Cooperative | ż; istniejące |
| MI13 | MI13 | n; nowe |
| Robust Corp | Robust Corp | ż; istniejące |
| Honk Co. | Honk Co. | ż; istniejące |
| DeForest Medical Corporation | Korporacja DeForest | ż; istniejące |
| Vey-Med | Vey-Med | ż; nowe |
| Zeng-Hu Pharmaceuticals | Zeng-Hu Pharmaceuticals | ż; nowe |
| Hephaestus Industries | Hephaestus Industries | ż; nowe |
| Bishop Cybernetics | Bishop Cybernetics | ż; nowe |
| Xion Manufacturing Group | Xion Manufacturing Group | ż; nowe |
| Ward-Takahashi | Ward-Takahashi | ż; nowe |
| Nakamura Engineering | Nakamura Engineering | ż; nowe |
| Shellguard Munitions | Shellguard Munitions | ż; nowe |
| Aussec Armory | Aussec Armory | ż; istniejące |
| Seegson | Seegson | m; istniejące (napęd FTL Seegson) |
| CzanekCorp / Czanek corp | CzanekCorp | ż; istniejące |
| WhiteRapids Munitions | WhiteRapids Munitions | ż; nowe |
| DonkCo Warcrime Emporium | Emporium Zbrodni Wojennych DonkCo | n; nowe |
| Marvin's Mineral Emporium | Emporium Minerałów Marvina | n; nowe |
| Minsky Heavy Engineering | Minsky Heavy Engineering | ż; nowe |
| Getmore | Getmore | m; istniejące |
| Space Cola | Kosmiczna Cola | ż; nowe (zgodnie z zasadą spolszczania marek napojów) |
| Robust Softdrinks | Robust Softdrinks | ż; nowe |
| Discount Dan's | Discount Dan's | m; nowe |
| Space Yellow Pages | Kosmiczne Żółte Strony | mnoga; nowe |
| The Griffon (newspaper) | Gryf | m; nowe |
| Lusty Xenomorph | Lubieżny Ksenomorf | m; nowe (tytuł książki/obrazu) |
| Boringheed | Boringheed | m; nazwa własna, parodia |


