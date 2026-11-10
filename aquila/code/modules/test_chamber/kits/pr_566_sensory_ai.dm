// aq33/AquilaStation#566 - zestawy sensorów AI i korzystanie z nich
// (aquila/code/modules/overmap/ai_sensor_suites.dm, ai_sensor_use.dm)

/datum/test_chamber_kit/pr_566_ai_sensory
	name = "Sensory AI (szukanie, cisza radiowa, ciche podejście)"
	pr = "aq33/AquilaStation#566"
	description = "Zestaw stawia DRADIS i konsolę sensorów oraz przywołuje nieuzbrojoną fregatę Syndykatu AI około 90 pól od okrętu. Fregata wykrywa i goni, ale nie strzela, więc da się jej uciec i wrócić. \
	1) Leć pełnym ciągiem: fregata łapie cię termicznie z daleka (około 45-65 pól) i rusza w pogoń. \
	2) Zgaś silniki i tłumiki, poczekaj kilkanaście sekund: ciepło spada, kontakt termiczny wygasa i zostaje tylko optyczny, czyli około 15-20 pól. Fregata gubi cię i leci NIE tam, gdzie byłeś, tylko tam, gdzie byłbyś, gdybyś nie zmienił kursu. \
	3) Zmień kurs po zgaszeniu silników i patrz, jak mija cię bokiem, pulsuje raz radarem w punkcie, który sobie wyliczyła, i przez około 45 s przeczesuje okolicę, zanim odpuści. \
	4) Impuls radaru z konsoli sensorów w trakcie jej szukania: fregata usłyszy emisję i przyjdzie na namiar, mimo że dalej cię nie widzi. \
	5) Gdy fregata ucieka (dobij ją prawie do zera albo przywołaj drugą obok), poza twoim zasięgiem wykrycia gasi silniki i leci rozpędem - na DRADIS po prostu znika. \
	6) Admin > Debug > Toggle AI sensor tactics wyłącza same zachowania, Toggle AI sensor suites wraca do jednego zasięgu z sygnatury."
	items = list(
		/obj/machinery/computer/ship/dradis = 1,
		/obj/machinery/computer/ship/dradis/sensors = 1,
	)

/datum/test_chamber_kit/pr_566_ai_sensory/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		to_chat(user, "<span class='warning'>Okręt główny nie jest w systemie gwiezdnym, nie przywołano fregaty.</span>")
		return
	var/turf/spot = locate(clamp(main.x + 90, 10, world.maxx - 10), main.y, main.z)
	var/obj/structure/overmap/enemy = new /obj/structure/overmap/syndicate/ai/gunboat/sensor_test(spot)
	main.current_system.add_ship(enemy)
	message_admins("[key_name_admin(user)] przywołał nieuzbrojoną fregatę Syndykatu do testu sensorów AI: [ADMIN_VERBOSEJMP(enemy)].")
