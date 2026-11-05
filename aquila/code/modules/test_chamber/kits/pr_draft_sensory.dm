// Lokalny draft (bez PR) - sygnatura okrętu i niepewne kontakty DRADIS (aquila/code/modules/overmap/sensor_signature.dm)

/datum/test_chamber_kit/pr_draft_sensory
	name = "Draft: sensory i sygnatura okrętu"
	pr = "lokalny draft, bez PR"
	description = "Zestaw stawia konsolę DRADIS i taktyczną (obie widzą okręt główny) oraz przywołuje kanonierkę Syndykatu AI około 70 pól od okrętu. \
	1) Otwórz DRADIS: kanonierka poza zasięgiem identyfikacji to pomarańczowy okrąg z „?” i podpowiedzią; okrąg rośnie z odległością i pływa powoli, nie skacze. \
	2) Impuls radaru: przez 5 s kontakty są dokładne (bez okręgów), a AI dostaje twoją pozycję. \
	3) Pilot: dryf bez ciągu i z wyłączonymi tłumikami vs pełny ciąg - z jakiej odległości AI zaczyna cię gonić (log ataków/wiadomość DRADIS). \
	4) Gdy kanonierka trafi cię spoza wykrycia: okrąg „!” Źródło ostrzału na 10 s i komunikat z namiarem. \
	5) Admin > Debug > Toggle sensor signatures wyłącza całość - DRADIS wraca do starego wyglądu."
	items = list(
		/obj/machinery/computer/ship/dradis = 1,
		/obj/machinery/computer/ship/tactical = 1,
	)

/datum/test_chamber_kit/pr_draft_sensory/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		to_chat(user, "<span class='warning'>Okręt główny nie jest w systemie gwiezdnym, nie przywołano kanonierki.</span>")
		return
	var/turf/spot = locate(clamp(main.x + 70, 10, world.maxx - 10), main.y, main.z)
	var/obj/structure/overmap/enemy = new /obj/structure/overmap/syndicate/ai/gunboat(spot)
	main.current_system.add_ship(enemy)
	message_admins("[key_name_admin(user)] przywołał kanonierkę Syndykatu do testu sensorów: [ADMIN_VERBOSEJMP(enemy)].")
