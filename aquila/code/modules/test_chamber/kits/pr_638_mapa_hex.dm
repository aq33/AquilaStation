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
