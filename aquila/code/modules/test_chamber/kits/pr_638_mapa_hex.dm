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
		6) Antagoniści z kafli i oferty dla duchów dopiero po 60 min rundy i tylko bez żywych antagonistów; wcześniej kafel daje event środowiska albo statkowy."

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
	for(var/kind in kinds)
		if(!length(free))
			break
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
	to_chat(user, "<span class='notice'>Teren obok okrętu gotowy, otwórz konsolę nawigacji.</span>")
