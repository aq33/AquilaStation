GLOBAL_DATUM_INIT(lore_terminal_controller, /datum/lore_controller, new)

/obj/machinery/computer/lore_terminal
	name = "terminal informacyjny Seegson"
	desc = "Mały monitor CRT z wbudowanym mikrokomputerem i obszerną bazą danych. Takie terminale zawierają wszystko, od informacji o wydarzeniach historycznych po instrukcje obsługi typowych urządzeń okrętowych."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "terminal"
	pixel_y = 26 //So they snap to walls correctly
	density = FALSE
	anchored = TRUE
	idle_power_usage = 15
	var/access_tag = "ntcommon"  //Every subtype of this type will be readable by this console. Use this for away terms as seen here \/
	var/list/entries = list() //Every entry that we've got.
	var/in_use = FALSE //Stops sound spam
	var/datum/looping_sound/computer_click/soundloop_clicking // AQ EDIT
	/// AQUILA: plik otwarty w oknie TGUI przez danego gracza (REF(mob) = /datum/lore_entry)
	var/list/viewed_entries

/obj/machinery/computer/lore_terminal/command //Put sensitive information on this one
	access_tag = "ntcommand"
	req_access = list(ACCESS_HEADS)

/obj/machinery/computer/lore_terminal/awaymission //Example for having a terminal preloaded with only a set list of files.
	access_tag = "awaymission_default"

/obj/machinery/computer/lore_terminal/Initialize(mapload)
	. = ..()
	get_entries()
	soundloop_clicking = new(src) // AQ EDIT

/datum/looping_sound/computer_click
	mid_sounds = list('nsv13/sound/effects/computer/scroll1.ogg','nsv13/sound/effects/computer/scroll2.ogg','nsv13/sound/effects/computer/scroll3.ogg','nsv13/sound/effects/computer/scroll5.ogg')
	mid_length = 0.8 SECONDS
	volume = 10 // AQ EDIT

/obj/machinery/computer/lore_terminal/proc/get_entries()
	for(var/X in GLOB.lore_terminal_controller.entries)
		var/datum/lore_entry/instance = X
		if(instance.access_tag == access_tag)
			entries += instance

/obj/machinery/computer/lore_terminal/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Odmowa dostępu</span>")
		return
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)
	return ..()

// AQUILA: okno TGUI "LoreTerminal" (dawniej lista plików i plik z maszyną do pisania w HTML)
/obj/machinery/computer/lore_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!entries.len)
			get_entries()
		ui = new(user, src, "LoreTerminal", name)
		ui.open()

/obj/machinery/computer/lore_terminal/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	LAZYREMOVE(viewed_entries, REF(user))

/obj/machinery/computer/lore_terminal/ui_static_data(mob/user)
	var/list/data = list()
	var/list/entry_list = list()
	for(var/datum/lore_entry/content as anything in entries)
		entry_list += list(list("name" = content.name, "ref" = REF(content)))
	data["entries"] = entry_list
	return data

/obj/machinery/computer/lore_terminal/ui_data(mob/user)
	var/list/data = list()
	var/datum/lore_entry/content = LAZYACCESS(viewed_entries, REF(user))
	if(content)
		data["entry"] = list(
			"name" = content.name,
			"ref" = REF(content),
			"title" = content.title,
			"classified" = content.classified,
			"content" = content.content,
		)
	return data

/obj/machinery/computer/lore_terminal/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("close_entry")
			LAZYREMOVE(viewed_entries, REF(usr))
			return TRUE
		if("selectitem")
			if(in_use)
				var/sound = 'nsv13/sound/effects/computer/buzz2.ogg'
				playsound(src, sound, 100, 1)
				to_chat(usr, "<span class='warning'>BŁĄD: funkcja wejścia/wyjścia zajęta. Plik wciąż się wczytuje...</span>")
				return
			var/datum/lore_entry/content = locate(params["ref"]) in entries
			if(!content?.content)
				return
			LAZYSET(viewed_entries, REF(usr), content)
			var/clicks = length(content.content) //Split the content into characters. 1 character = 1 click
			playsound(src, pick('nsv13/sound/effects/computer/buzz.ogg','nsv13/sound/effects/computer/buzz2.ogg'), 100, TRUE)
			in_use = TRUE //Stops you from crashing the server with infinite sounds
			icon_state = "terminal_scroll"
			clicks = clicks/3
			var/loops = clicks/3 //Each click sound has 4 clicks in it, so we only need to click 1/4th of the time per character yeet.
			addtimer(CALLBACK(src, PROC_REF(stop_clicking)), loops)
			soundloop_clicking?.start()
			return TRUE

/obj/machinery/computer/lore_terminal/proc/stop_clicking()
	soundloop_clicking?.stop()
	icon_state = "terminal"
	in_use = FALSE

/datum/lore_controller
	var/name = "kontroler archiwum fabularnego"
	var/list/entries = list() //All the lore entries we have.

/datum/lore_controller/New()
	. = ..()
	instantiate_lore_entries()

/datum/lore_controller/proc/instantiate_lore_entries()
	for(var/instance in subtypesof(/datum/lore_entry))
		var/datum/lore_entry/S = new instance
		entries += S

/datum/lore_entry
	var/name = "Loredoc.txt" //"File display name" that the term shows (C://blah/yourfile.bmp)
	var/title = null //What it's all about
	var/classified = "Odtajnione" //Fluff, is this a restricted file or not?
	var/content = null //You may choose to set this here, or via a .txt. file if it's long. Newlines / Enters will break it!
	var/filename = null //The name of the actual file in the repo. Files are stored in LORE_DIR
	var/access_tag = "placeholder" //Set this to match the terminals that you want to be able to access it. EG "ntcommon" for declassified shit.

/datum/lore_entry/New()
	..()
	if(filename)
		content = file2text("[LORE_DIR]/[SANITIZE_FILENAME(filename)]")

/*

TO GET THE COOL TYPEWRITER EFFECT, I HAD TO STRIP OUT THE HTML FORMATTING STUFF.
SPECIAL KEYS RESPOND AS FOLLOWS:

` = newline (br) (AKA when you press enter)
~ = horizontal line (hr)
� = bullet point

*/

/datum/lore_entry/nt
	name = "new_employees_memo.ntmail"
	title = "Przechwycona wiadomość"
	filename = "welcome.txt"
	access_tag = "ntcommon"

/datum/lore_entry/nt/ragnarok
	name = "ragnarok_class.ntdoc"
	title = "Specyfikacja klasy Ragnarok"
	filename = "ragnarok.txt"

/datum/lore_entry/nt/firing_proceedure
	name = "firing_proceedure.ntdoc"
	title = "Amunicja do walki między statkami"
	filename = "firing_proceedure.txt"

/datum/lore_entry/nt/stormdrive_operation
	name = "stormdrive_operation.ntdoc"
	title = "Uruchamianie zasilania"
	filename = null
	content = "-Włącz zwężacze gołą ręką ` -Otwórz zawory 'plasma input' do zwężaczy i ustaw ich ciśnienie na 'MAX' ` -Zmontuj akcelerator cząstek kluczem, zwojem kabla i śrubokrętem. ` -Otwórz zawory wlotowe reaktora i ustaw ich ciśnienie na 'MAX'` `-Na konsoli sterowania akceleratorem cząstek ustaw poziom '2' i włącz zasilanie `-Gdy reaktor się uruchomi, zacznie emitować promieniowanie Czerenkowa, które daje 'niebieską poświatę' wokół rdzenia. Po włączeniu reaktora wyłącz akcelerator cząstek, żeby nie marnować energii. `-Do optymalnej produkcji energii inżynierom zaleca się ustawienie prętów sterujących na '2', ale pręty nie są przystosowane do długotrwałej pracy w temperaturze powyżej 200 stopni, więc trzeba je wzmocnić arkuszami plastali. ` Jeśli paliwo nie napływa do reaktora, doszło do skoku ciśnienia zwrotnego. Wyłącz wszystkie wloty reaktora i na konsoli reaktora otwórz zawór zrzutu odpadów, żeby wypłukać gaz z systemu. Potem zamknij zawór i ponownie włącz dopływ paliwa."

/datum/lore_entry/nt/meltdown_proceedures
	name = "meltdown_proceedures.ntmail"
	title = "Procedury awaryjne na wypadek stopienia rdzenia:"
	filename = null
	content = "SYSADMIN -> Allcrew@seegnet.nt. RE: Awaryjne procedury na wypadek stopienia rdzenia. ` Jądrowy napęd burzowy jest z natury bezpiecznym silnikiem, ale to nie znaczy, że jest odporny na głupotę. Od staranności zależy, czy dostaniesz bezpieczne, niezawodne źródło energii na dziesięciolecia, czy jądrowe piekło, które zniszczy cały statek. `Co robić w razie stopienia rdzenia: `-Reaktor ulega stopieniu, gdy rozszczepienie w jego wnętrzu wytwarza niekontrolowane ilości ciepła (ponad 300 stopni Celsjusza). Jeśli do tego dojdzie, na całym statku włączy się alarm. Gdy go usłyszysz, musisz działać szybko i spokojnie, bo do wybuchu reaktora zostaje ok. 1–2 minut. `-Żeby zapobiec stopieniu, znajdź konsolę sterowania i wybierz ustawienie 'SCRAM' (przycisk z napisem AZ-5). Natychmiast opuści to wszystkie pręty sterujące i spróbuje schłodzić reaktor. `-Jeśli pręty sterujące są uszkodzone, NATYCHMIAST wyłącz wszystkie zwężacze plazmy, pompy zasilające i filtry i NATYCHMIAST ewakuuj sekcję inżynieryjną, żeby uniknąć niepotrzebnych ofiar. `-Podczas stopienia rdzenia paliwo jądrowe rozsypuje się po całym statku i trzeba je sprzątnąć łopatą. To zużyte paliwo jest SILNIE radioaktywne i trzeba obchodzić się z nim niezwykle ostrożnie. Jeśli stanie się najgorsze, każ załodze schronić się w tunelach technicznych i natychmiast przystąp do ewakuacji statku. Żeby uniknąć komplikacji, inżynierom zaleca się założenie kombinezonów przeciwradiacyjnych i masek gazowych, a potem przekopanie łopatami drogi do ramienia ewakuacyjnego. Pamiętaj: czujność to bezpieczeństwo!"

/datum/lore_entry/nt/ship_weapon_maintenance
	name = "weapon_maintenance_proceedure.ntmail"
	title = "Konserwacja uzbrojenia okrętowego a TY"
	filename = null
	content = "SYSADMIN -> Munitions@seegnet.nt. RE: Konserwacja uzbrojenia ` STARANNA KONSERWACJA SYSTEMÓW OKRĘTOWYCH ZACZYNA SIĘ OD CIEBIE ` Całe główne uzbrojenie ofensywne do walki między statkami, w tym wyrzutnie torped i działa szynowe, wymaga regularnej konserwacji przez wykwalifikowanych pracowników, żeby pozostało w optymalnym stanie. ` Przypomnienie: przed rozpoczęciem jakiejkolwiek konserwacji uzbrojenia okrętowego upewnij się, że wszystkie odpowiednie zabezpieczenia są włączone, a broń nie jest załadowana. ` -Odkręć właz serwisowy na głównej obudowie zewnętrznej ` -Odkręć śruby wewnętrznego panelu serwisowego ` -Łomem ostrożnie podważ i wyjmij panel wewnętrzny ` -Nałóż 10 j. oleju na odsłonięte mechanizmy wewnętrzne ` -Załóż panel z powrotem, przykręć go i zamocuj właz ` JEŚLI KONSERWACJA NIE BĘDZIE PRZEPROWADZANA REGULARNIE, PODCZAS WALKI MOŻE DOJŚĆ DO AWARII, KTÓRA SKOŃCZY SIĘ OBRAŻENIAMI LUB ŚMIERCIĄ TWOJĄ I INNYCH CZŁONKÓW ZAŁOGI"


/datum/lore_entry/nt/fighter_maintenance
	name = "fighter_maintenance.ntmail"
	title = "PD: RE: Jak, do cholery, wrzucić te kupy złomu w tryb konserwacji?"
	filename = null
	content = "MAAMASTER -> Munitions@seegnet.nt PD: RE: Jak, do CHOLERY? `Uwaga, Mistrzowie Broni w całej flocie: dotarło do nas, że wasi podwładni mogą mieć kłopot z zapamiętaniem prostych procedur cyklu konserwacji. Przekażcie im tę wiadomość jako przypomnienie.` `--------------------------------` `PRZEKAZANA WIADOMOŚĆ` `--------------------------------` `REDACTED@seegnet.nt -> REDACTED@seegnet.net Jak, do CHOLERY?` `Hej, możesz mi bardzo pomóc?` `Wiem, że te nowe, wypasione myśliwce mają mieć jakiś specjalny tryb konserwacji, który daje dostęp do wszystkich podzespołów i tak dalej, ale nie mogę rozgryźć, jak, do CHOLERY, mam go włączyć.` `POMOCY!` `Szef dosłownie mnie zlinczuje, jeśli nie skończę tego przed jego powrotem.` `--------------------------------` `REDACTED@seegnet.nt -> REDACTED@seegnet.net RE: Jak, do CHOLERY?` `Wytłumaczę ci to krok po kroku:` `Najpierw znajdź panel serwisowy na brzuchu myśliwca. Tak, musisz się pod niego wczołgać. Weź ze sobą klucz i łom.` `Potem odkręć śruby panelu, tylko nie zgub nakrętek, bo będzie po tobie.` `Na koniec odsuń panel serwisowy. To powinno przełączyć myśliwiec w tryb konserwacji. Jeśli się zatnie, podważ go łomem.` `Żeby na koniec przywrócić tryb lotu, zrób to samo w odwrotnej kolejności. Proste, prawda?`"

/datum/lore_entry/nt/fighter_production
	name = "fighter_production.ntdoc"
	title = "Produkcja i montaż myśliwców – podstawy"
	filename = null
	content = "Witaj w poradniku NT: Produkcja i montaż myśliwców – podstawy `Ten poradnik krok po kroku zapozna cię z produkcją podzespołów myśliwców i składaniem ich w sprawny myśliwiec dla floty NT.` `UWAGA: ta procedura wymaga współpracy kilku działów.` `DODATKOWA UWAGA: rozpowszechnianie plotek o tej procedurze skończy się osobistym usunięciem REDACTED` `@#g#!&40((%%%% -=WYKRYTO USZKODZENIE PLIKU=- Uproszczę ci to do czytania. ~PMV` `Zacznij od upewnienia się, że wydział badawczy twojego statku ma najnowsze plany.` `Przygotuj zamówienie na potrzebne podzespoły (ZAŁĄCZNIK A) i dostarcz je do zaopatrzenia do wyprodukowania.` `Poczekaj na dostawę zamówienia w ustalonym miejscu.` `` `Procedura montażu krok po kroku:` `-Otwórz i złóż kadłub myśliwca.` `-Przykręć śruby kadłuba myśliwca kluczem.` `-Zespawaj połączenia kadłuba myśliwca.` `-Znajdź i przymocuj usterzenie myśliwca.` `-Przykręć śruby usterzenia myśliwca kluczem.` `-Zespawaj połączenia usterzenia myśliwca.` `-Znajdź i przymocuj pierwsze skrzydło myśliwca.` `-Przykręć śruby skrzydła myśliwca kluczem.` `-Zespawaj połączenia skrzydła myśliwca.` `-Znajdź i przymocuj drugie skrzydło myśliwca.` `-Przykręć śruby skrzydła myśliwca kluczem.` `-Zespawaj połączenia skrzydła myśliwca.` `-Znajdź i zamontuj podwozie myśliwca.` `-Przykręć śruby podwozia myśliwca kluczem.` `-Znajdź i zamontuj płyty pancerza myśliwca.` `-Przykręć płyty pancerza myśliwca wkrętami.` `-Zespawaj połączenia płyt pancerza myśliwca.` `-Poprowadź okablowanie w myśliwcu.` `-Skalibruj okablowanie multitoolem.` `-Znajdź i zamontuj zbiornik paliwa myśliwca.` `-Przykręć śruby zbiornika paliwa myśliwca kluczem.` `-Znajdź i zamontuj przewody paliwowe myśliwca.` `-Przykręć śruby przewodów paliwowych myśliwca kluczem.` `-Znajdź i zamontuj pierwszy silnik myśliwca.` `-Zespawaj połączenia silnika myśliwca.` `-Znajdź i zamontuj drugi silnik myśliwca.` `-Skalibruj oba silniki myśliwca multitoolem.` `-Znajdź i zamontuj kokpit myśliwca.` `-Przykręć kokpit myśliwca wkrętami.` `-Przykręć śruby kokpitu myśliwca kluczem.` `-Poprowadź dodatkowe okablowanie w myśliwcu.` `-Znajdź i zamontuj awionikę myśliwca.` `-Przykręć awionikę myśliwca wkrętami.` `-Skalibruj awionikę myśliwca multitoolem.` `-Znajdź i zamontuj czujniki celownicze myśliwca.` `-Przykręć czujniki celownicze myśliwca wkrętami.` `-Skalibruj czujniki celownicze myśliwca multitoolem.` `-Pomaluj myśliwiec w wybrany schemat barw.` `-Nadaj myśliwcowi nazwę.` `` `Twój nowy myśliwiec powinien być gotowy.` `Włącz tryb konserwacji, żeby zamontować uzbrojenie, przeprowadzić naprawy i zatankować jednostkę.` `____________` `ZAŁĄCZNIK A` `____________` `Podzespoły myśliwca:` `-Skrzynia z podzespołami kadłuba myśliwca x1` `-Pudełko z podzespołami kokpitu myśliwca x1` `-Pudełko z podzespołami skrzydła myśliwca x2` `-Pudełko z podzespołami usterzenia myśliwca x1` `-Pudełko z podzespołami podwozia myśliwca x1` `-Płyty pancerza myśliwca x1` `-Zbiornik paliwa myśliwca x1` `-Awionika myśliwca x1` `-Czujniki celownicze myśliwca x1` `-Zestaw przewodów paliwowych myśliwca x1` `-Silnik myśliwca x2`"

/datum/lore_entry/nt/fighters
	name = "fighter_operations.ntdoc"
	title = "Procedury obsługi myśliwca"
	filename = null
	content = "Lista kontrolna przed lotem:`\
	Włącz przełącznik zapłonu`\
	Przełącznik pompy paliwa`\
	Podłącz akumulator`\
	Włącz APU`\
	Zwolnij blokadę przepustnicy`\
	BARDZO delikatnie dodaj gazu przy zaciągniętych hamulcach, tak żeby silnik przejął pracę, a myśliwiec nie ruszył z miejsca.`\
	Zablokuj osłonę kokpitu, żeby nie narazić się na niebezpieczną próżnię`\
	APU wyłączy się samo, jesteś gotowy do lotu.```\
	-------------------`\
	Procedura wyłączania:`\
	Przepustnica na zero + hamulce zaciągnięte`\
	Blokada przepustnicy włączona`\
	Odłącz akumulator`\
	Wyłącz pompę paliwa (inaczej zalejesz silnik)`\
	Wyłącz zapłon```\
	Vipery, Raptory i inne małe myśliwce latają na tyrozenie. To standardowe paliwo wzbogacone dodatkowymi węglowodorami.`\
	Jeśli skończy ci się paliwo:`\
	Zaciągnij hamulce i zacznij wyłączać myśliwiec. Gdy dostaniesz więcej paliwa, uruchom go zgodnie z procedurą. Bez paliwa zostaniesz zdany na dryf. Zdecydowanie zaleca się powrót do bazy, gdy paliwa zostanie 100, bo zostaje wtedy ok. 30 sekund pracy silnika, zanim zgaśnie.`\
	Produkcja tyrozenu:`\
	1 część wodoru : 1 część węgla daje węglowodór, który podgrzewasz do 333 K. Zmieszaj węglowodór z paliwem spawalniczym, żeby uzyskać tyrozen, i wlej go do zbiorników tyrozenu, żeby móc tankować myśliwce."

/datum/lore_entry/nt/targeting
	name = "targeting_systems.ntdoc"
	title = "Użycie systemów broni kierowanej"
	filename = null
	content = "Namierzanie wrogich jednostek:`- Przełącz układ DRADIS w tryb namierzania`- Upewnij się, że blokady bezpieczeństwa uzbrojenia są wyłączone`- Najedź kursorem DRADIS na wrogi cel i naciśnij przełącznik oznaczania, żeby oznaczyć cel`Uwaga: większość dużych statków obsługuje naraz najwyżej 3 aktywne oznaczenia. Większość małych jednostek obsługuje jedno oznaczenie.```-------------------```Po oznaczeniu celu możesz go namierzyć na konsoli taktycznej, wybierając cel, który chcesz namierzyć.`Jeśli jest dostępna i cel jest w zasięgu, kamera strzelca zostanie sprzężona z radarem celowniczym i pokaże ci cel.`Małe jednostki (takie jak Rapier czy Scimitar) automatycznie namierzają pierwszy oznaczony cel.`Jeśli użyjesz uzbrojenia bez namiaru, pocisk naprowadzi się na pierwszy oznaczony cel.```-------------------```Przy użyciu uzbrojenia naprowadzanego radarowo zawsze przestrzegaj procedur kontroli emisji.`Pociski i torpedy półaktywne i aktywne zdradzają pozycję jednostki, która je odpaliła, co może skończyć się wykryciem i walką w niedogodnym momencie.`Choć niektóre bronie (takie jak pocisk Magneton FTL-1301) nie wymagają aktywnego naprowadzania przez jednostkę, która je odpaliła, do celnego rozwiązania ogniowego i tak potrzebny jest namiar.```-------------------```"

/datum/lore_entry/nt/datalink
	name = "datalink.ntdoc"
	title = "Użycie taktycznego łącza danych DRADIS"
	filename = null
	content = "Przesyłanie celów przez łącze danych:`- Przełącz układ DRADIS w tryb namierzania`- Oznacz i namierz cel`- Najedź kursorem DRADIS na sojuszniczą jednostkę, której chcesz przesłać cel, i naciśnij przełącznik oznaczania```-------------------```Cel przesłany przez łącze danych jest automatycznie traktowany jako oznaczony przez komputer celowniczy jednostki odbierającej.`Jednostka nadająca będzie wtedy nieprzerwanie przesyłać dane do jednostki odbierającej przez łącze DRADIS.`Żeby transmisja się powiodła, jednostka nadająca musi utrzymywać śledzenie celu, a jednostka odbierająca musi mieć wolne miejsce na dodatkowe oznaczenie.`Jeśli śledzenie przez łącze danych zostanie utracone, jednostka odbierająca spróbuje śledzić cel własnymi czujnikami, a jeśli to się nie uda, porzuci śledzenie.```-------------------```Właściwe użycie łączy danych jest ważne dla skutecznego łańcucha rażenia między jednostkami wczesnego ostrzegania a jednostkami uderzeniowymi.`Pozwala to małym jednostkom na uderzenia z dużej odległości lub spoza osi, a także na wykrywanie i śledzenie z daleka jednostek z systemami maskowania, które inaczej umknęłyby uwadze okrętu liniowego.`Pamiętaj, że wszystkie informacje otrzymane przez łącze danych należy traktować jako operacyjne dane wywiadowcze kategorii C6. Nie udostępniaj kodów operacyjnych nieupoważnionemu personelowi.```-------------------```"

/datum/lore_entry/away_example
	title = "Przechwycony plik dziennika"
	access_tag = "awayexample"

/datum/lore_entry/away_example/pilot_log
	name = "pilot_log.txt"
	content = "Nadlatują z impetem! Przygotować się do obrotu i odpal']###�$55%%% -=Dostęp do pliku przerwany=-"

/datum/lore_entry/away_example/weapons_log
	name = "weapon_systems_dump2259/11/25.txt"
	content = "Systemy podtrzymywania życia wyłączone. Stan systemu działa szynowego: A6E3. Stan systemu torped: ~@##6#6#^^6 -=Dostęp do pliku przerwany=-"
