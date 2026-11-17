// aq33/AquilaStation#657 - układy FTL w konsoli nawigacji mapy hex (aquila/code/modules/overmap/hexmap/hex_ftl_chip.dm)

/datum/test_chamber_kit/pr_nsvprzyw_warp
	name = "Układy FTL na mapie hex"
	pr = "aq33/AquilaStation#657"
	description = "Zestaw daje matrycę strumienia (poziom 2) i układ napędu warp (poziom 3) oraz ładuje do pełna napęd okrętu głównego. Testuj na konsoli nawigacji na mostku. \
		1) Włóż matrycę do konsoli nawigacji: w oknie pod napędem pojawiają się cztery bonusy, domyślnie „Tańszy skok”. Koszt kafla 25%, bramy 50%, zielony zasięg sięga 4 kafli. \
		2) Przełącz na „Dwa kafle za cenę jednego”: trasa na 2 kafle kosztuje 34%, na 4 kafle 100%. \
		3) „Krótszy rozruch i stygnięcie”: rozruch 5 s, po skoku 30 s stygnięcia. W czasie rozruchu bonusu nie da się przełączyć. \
		4) „Dłuższy zasięg skoku”: pasek napędu ładuje się do 150% (Seegson ładuje dalej po komunikacie gotowości), jeden skok sięga 4 kafli. Przełączenie na inny bonus przycina ładunek do 100%. \
		5) Włóż układ warp: matryca wypada z konsoli, bonus zostaje, liczby rosną (kafel 20%, 6 kafli za cenę 3, rozruch 2 s i stygnięcie 15 s, napęd do 200%). Drugiej matrycy konsola już nie przyjmie. \
		6) Układ włożony do komputera napędu odsyła do konsoli nawigacji. \
		7) Źródła: Minsky Heavy Engineering sprzedaje układ warp; badanie „Napęd warp” wymaga matrycy strumienia i części myśliwców; kafel tunelu ma anomalię tunelu do skanu sondą (punkty tuneli)."
	items = list(
		/obj/item/ftl_slipstream_chip = 2,
		/obj/item/ftl_slipstream_chip/warp = 1,
	)

/datum/test_chamber_kit/pr_nsvprzyw_warp/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/obj/machinery/computer/ship/ftl_core/drive = main?.ftl_drive
	if(!drive)
		if(user)
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
	if(user)
		to_chat(user, "<span class='notice'>Napęd FTL okrętu głównego naładowany do pełna.</span>")
