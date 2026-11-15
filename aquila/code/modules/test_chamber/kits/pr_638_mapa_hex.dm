// aq33/AquilaStation#638 - mapa FTL z kafli hex (aquila/code/modules/overmap/hexmap/)

/datum/test_chamber_kit/pr_638
	name = "Mapa FTL z kafli hex"
	pr = "aq33/AquilaStation#638"
	description = "Zestaw nie zrzuca przedmiotów: ładuje do pełna napęd okrętu głównego. Testuj na konsoli nawigacji na mostku, skoki są prawdziwe. \
		1) Okno otwiera się na sektorze okrętu. Sprawdź zakładki sektorów, Przegląd, „Do okrętu” i zoom; strefy frakcji słabną z odległością, a na styku wrogów jest czerwony front. \
		2) Kliknij sąsiedni pusty kafel: trasa i koszt 34%. Skok: 10 s rozruchu i 30 s lotu. Po przylocie zostaje 67%, przez 60 s napęd stygnie bez ładowania i nie ma zielonego zasięgu. \
		3) W czasie rozruchu kliknij „Anuluj skok”: ładunek ma zostać bez zmian. \
		4) Skok, który zużyje resztę ładunku: napęd ma się wyłączyć, a włącza go inżynieria na konsoli napędu. \
		5) Brama do innego sektora (układ z ⇄, np. Feliciana) kosztuje 67%, a z bramy w układzie wroga nie da się skoczyć. \
		6) Floty AI (romby) przesuwają się o kafel co 2–5 min. Konsola astrometrii ma zostać przy starym oknie. \
		7) Server → Campaign Backups: zrób kopię ręczną i sprawdź, że jest na liście. \
		Na koniec rundy okręt ma skoczyć do najbliższej przyjaznej stacji handlowej, a następna runda zacząć się w kaflu, w którym skończyła się ta."

/datum/test_chamber_kit/pr_638/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user)
		return
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/obj/machinery/computer/ship/ftl_core/drive = main?.ftl_drive
	if(!drive)
		to_chat(user, "<span class='warning'>Okręt główny nie ma napędu FTL.</span>")
		return
	if(istype(drive))
		drive.progress = drive.req_charge
	else
		var/obj/machinery/computer/ship/ftl_computer/legacy = drive
		legacy.progress = legacy.spoolup_time
	drive.active = TRUE
	main.hex_cooldown_until = 0
	main.hex_resume_charging()
	to_chat(user, "<span class='notice'>Napęd FTL okrętu głównego naładowany do pełna.</span>")

/datum/test_chamber_kit/pr_638/teren
	name = "Mapa FTL: teren kafli i eventy"
	description = "Zestaw ładuje napęd i kładzie obok okrętu nieznany sygnał, pole asteroid, wlot tunelu (drugi koniec kilka kafli dalej) i czarną dziurę. Testuj na konsoli nawigacji na mostku. \
		1) Okno pokazuje teren ikonami, panel kafla podaje jego opis i czy zatrzymuje skok. \
		2) Skok na pole asteroid: od razu event z jego puli (admin widzi „Losowy event uruchomi się za 10 s”). Na postoju co 8–12 min kolejny, nie bliżej niż 4 min od eventu statkowego. \
		3) Trasa przez pole asteroid kończy się na nim, mgławica przepuszcza. Czarnej dziury nie da się wybrać jako celu. \
		4) Skok na sygnał: event, a po odlocie sygnał znika z mapy. \
		5) Skok do tunelu: po 5 s okręt wylatuje na drugim końcu bez zużycia ładunku i bez drugiego eventu. \
		6) Antagoniści z puli kafla losują się razem z eventami od początku rundy, jeśli starcza graczy; na jednym postoju najwyżej jeden."

/datum/test_chamber_kit/pr_638/teren/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!user)
		return
	var/datum/hex/here = SSstar_system.find_main_overmap()?.current_hex()
	if(!here)
		to_chat(user, "<span class='warning'>Okręt główny nie stoi na kaflu mapy hex.</span>")
		return
	var/list/free = GLOB.hexmap.free_neighbours(here)
	var/list/kinds = list(HEX_TERRAIN_SIGNAL, HEX_TERRAIN_ASTEROIDS, HEX_TERRAIN_WORMHOLE, HEX_TERRAIN_BLACK_HOLE)
	var/list/missing = list()
	for(var/kind in kinds)
		if(!length(free))
			missing += hex_terrain(kind).name
			continue
		var/datum/hex/H = pick_n_take(free)
		if(kind != HEX_TERRAIN_WORMHOLE)
			H.set_terrain(kind)
			continue
		var/list/far = list()
		for(var/datum/hex/other as anything in GLOB.hexmap.free_hexes(here.sector, FALSE))
			if(GLOB.hexmap.distance(H, other) >= 4)
				far += other
		if(length(far))
			GLOB.hexmap.link_wormhole(H, pick(far))
		else
			missing += hex_terrain(kind).name
			free += H // kafel nie został zajęty
	if(length(missing))
		to_chat(user, "<span class='warning'>Nie wszystko się zmieściło obok okrętu (brak wolnych kafli): [english_list(missing)]. Przeleć okrętem w inne miejsce i użyj zestawu jeszcze raz.</span>")
		return
	to_chat(user, "<span class='notice'>Teren obok okrętu gotowy, otwórz konsolę nawigacji.</span>")

/datum/test_chamber_kit/pr_638/wojna
	name = "Mapa FTL: wojna frakcji"
	description = "Zestaw ładuje napęd, stawia flotę Syndykatu z dowódcą dwa kafle od okrętu i od razu odpala turę sztabów (zwykle co 5 min). Testuj na konsoli nawigacji na mostku. \
		1) Przy układach są ikony obiektów (kopalnie, fabryki, stocznie, depoty, placówki, kwatery, stacje handlowe), w panelu kafla ich opis i magazyn. \
		2) Wrogie floty widać w zasięgu 3 kafli od okrętu, kafla od sojuszniczych układów i flot oraz 3 kafli od placówek; poza nim szary romb z ostatnią znaną pozycją. \
		3) Zakładka „Dowódcy”: dowódca floty Syndykatu z rangą; cechy są „?”, dopóki nie spotkasz jego floty. \
		4) Konwoje (kwadraty) jadą z kopalń do fabryk i ze fabryk do stoczni; piraci je łupią i napadają stacje handlowe (stacja nie handluje 10 min, ta sama stacja najwyżej raz na pół godziny). Wroga flota w sąsiednim kaflu potrafi skoczyć za konwojem i go przechwycić, a piraci czasem zajmują słabe układy i biorą z nich haracz. \
		5) Zniszcz flotę Syndykatu: dowódca może uciec z blizną i urazą, po 15–25 min wraca z nową flotą i poluje na okręt. \
		6) Floty sztabów, magazyny i dowódcy przechodzą do następnej rundy. \n		7) Kwaterę Syndykatu w Abassi zdobywa tylko okręt: rozbij jej garnizon i utrzymaj układ przez dwie tury sztabów (ok. 10 min), wtedy ogłoszenie o wygranej wojnie i nowa kampania od następnej rundy."

/datum/test_chamber_kit/pr_638/wojna/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!user || !GLOB.hex_war)
		return
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/datum/hex/here = main?.current_hex()
	if(!here)
		return
	var/datum/hex/spot
	for(var/datum/hex/H as anything in GLOB.hexmap.hexes_in_range(here, 2))
		if(GLOB.hexmap.distance(here, H) == 2 && !H.system && !GLOB.hexmap.blocks(H))
			spot = H
			break
	if(spot)
		var/datum/fleet/F = GLOB.hex_war.launch_fleet("syndicate", GLOB.hexmap.system_for(spot))
		if(F)
			to_chat(user, "<span class='notice'>Flota [F.name] stoi dwa kafle od okrętu.</span>")
	GLOB.hex_war.run_turn()

/datum/test_chamber_kit/pr_638/atomowka
	name = "Mapa FTL: atomówka i DEFCON"
	description = "Zestaw daje dwie torpedy termojądrowe, ładuje napęd i ustawia DEFCON 1 na 15 min. Załaduj atomówkę do wyrzutni torped albo VLS. \
		1) Taktycznie: strzał w okręt na overmapie jak zwykłą torpedą, wybuch nuke_impact; w okręcie z załogą błysk, huk, wstrząs, pożary i promieniowanie. \
		2) Strategicznie: na konsoli nawigacji kliknij kafel w zasięgu 9, przycisk „Odpal atomówkę w ten kafel” i potwierdź. Pocisk leci kafel co 30 s (czerwony ślad ☢), floty wroga po drodze mogą go zestrzelić; w celu floty tracą 3 okręty, obok 1, pusty kafel zostaje skażony na 50 min. \
		3) Atomówka AI w okręt: dwa kafle przed celem alarm i komunikat „Nieuchronne trafienie pociskiem”, w kaflu okrętu torpeda z krawędzi overmapy – zestrzel ją PD albo flakiem. \
		4) Na starcie rundy przy wyrzutni torped stoi skrzynia z atomówką (dostęp kapitana albo XO). DEFCON w konsoli, ogłoszenia przy zmianie."
	items = list(/obj/item/ship_weapon/ammunition/torpedo/nuke = 2)

/datum/test_chamber_kit/pr_638/atomowka/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!user || !GLOB.hex_war)
		return
	GLOB.hex_war.nuclear_detonation(null)
	to_chat(user, "<span class='notice'>DEFCON 1 na 15 minut.</span>")

/datum/test_chamber_kit/pr_638/stacje
	name = "Mapa FTL: eskorta, oferta stacji i misje"
	description = "Zestaw ładuje napęd, dodaje 30 000 kr na konto zaopatrzenia i od razu daje okrętowi fregatę eskorty. \
		1) Stocznie CzanekCorp i Minsky sprzedają fregatę i krążownik eskorty, zbrojownia White Rapids także torpedę termojądrową; najwyżej 4 okręty eskorty, piąty zakup jest odrzucany przed pobraniem pieniędzy. \
		2) Skocz o kafel: eskorta wychodzi z nadprzestrzeni razem z okrętem, trzyma się przy nim i bije jego cele. \
		3) Misje abordażu i Opuszczona stacja stoją na losowych pustych kaflach sektora neutralnego (żółty „!” na mapie); część z nich ma w nagrodę atomówkę (dopisane w opisie misji), którą przysyła kapsuła po wykonaniu. \
		4) Pola anomalii mają skupiska anomalii do skanowania (misja skanowania może je wybrać)."

/datum/test_chamber_kit/pr_638/stacje/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!user)
		return
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	D?.adjust_money(30000)
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(main?.current_system && main.hex_add_escort(/obj/structure/overmap/nanotrasen/frigate/ai))
		to_chat(user, "<span class='notice'>Fregata eskorty dołączyła do okrętu głównego.</span>")
