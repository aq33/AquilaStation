// aq33/AquilaStation#566 - sygnatura okrętu i niepewne kontakty DRADIS (aquila/code/modules/overmap/sensor_signature.dm)

/// Unarmed AI frigate for the sensor test: it still detects and chases you, but has nothing to shoot with
/obj/structure/overmap/syndicate/ai/gunboat/sensor_test
	name = "testowa fregata Syndykatu"
	desc = "Fregata bez uzbrojenia do testów sensorów. Wykrywa i goni, ale nie strzela."
	missiles = 0
	shots_left = 0
	torpedoes = 0

/obj/structure/overmap/syndicate/ai/gunboat/sensor_test/apply_weapons()
	return

/datum/test_chamber_kit/pr_566
	name = "Sensory i sygnatura okrętu"
	pr = "aq33/AquilaStation#566"
	description = "Zestaw stawia konsolę DRADIS i taktyczną (obie widzą okręt główny) oraz przywołuje nieuzbrojoną fregatę Syndykatu AI około 70 pól od okrętu. Fregata wykrywa i goni, ale nie strzela. \
	1) Otwórz DRADIS: fregata poza zasięgiem identyfikacji to pomarańczowy okrąg z „?” i podpowiedzią; okrąg rośnie z odległością i pływa powoli, nie skacze. \
	2) Impuls radaru: przez 5 s kontakty są dokładne (bez okręgów), a AI dostaje twoją pozycję. \
	3) Pilot: dryf bez ciągu i z wyłączonym wspomaganiem bezwładnościowym (IAS) vs pełny ciąg - z jakiej odległości fregata zaczyna cię gonić. \
	4) Źródło ostrzału (okrąg „!”) wymaga strzelającego wroga - tej fregaty to nie dotyczy. \
	5) Admin > Debug > Toggle sensor signatures wyłącza całość - DRADIS wraca do starego wyglądu."
	items = list(
		/obj/machinery/computer/ship/dradis = 1,
		/obj/machinery/computer/ship/tactical = 1,
	)

/datum/test_chamber_kit/pr_566/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		to_chat(user, "<span class='warning'>Okręt główny nie jest w systemie gwiezdnym, nie przywołano fregaty.</span>")
		return
	var/turf/spot = locate(clamp(main.x + 70, 10, world.maxx - 10), main.y, main.z)
	var/obj/structure/overmap/enemy = new /obj/structure/overmap/syndicate/ai/gunboat/sensor_test(spot)
	main.current_system.add_ship(enemy)
	message_admins("[key_name_admin(user)] przywołał nieuzbrojoną fregatę Syndykatu do testu sensorów: [ADMIN_VERBOSEJMP(enemy)].")
