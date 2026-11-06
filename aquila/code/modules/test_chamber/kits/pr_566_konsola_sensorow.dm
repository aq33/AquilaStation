// aq33/AquilaStation#566 - konsola sensorów i operator radaru (aquila/code/modules/overmap/sensor_console.dm)

/datum/test_chamber_kit/pr_566_konsola
	name = "Konsola sensorów i operator radaru"
	pr = "aq33/AquilaStation#566"
	description = "Zestaw stawia konsolę sensorów, DRADIS i konsolę taktyczną (wszystkie widzą okręt główny) oraz przywołuje dwie nieuzbrojone fregaty Syndykatu AI, około 40 i 70 pól od okrętu. Fregaty gonią, ale nie strzelają. Najlepiej we dwie osoby: operator przy konsoli sensorów, działonowy przy taktycznej. \
	1) Konsola sensorów: przełącz Nasłuch / Radar aktywny; w radarze aktywnym impulsy idą same co ustawiony odstęp (−/+), także po zamknięciu okna. Pasek impulsu ładuje się po każdym impulsie. \
	2) Kliknij fregatę na ekranie albo na liście: karta pokazuje odległość, namiar i dokładność pozycji. Ustaw Cel główny, potem drugą fregatę też jako główny: pierwsza ma zmienić się na drugorzędną. \
	3) DRADIS: brak przycisków impulsu i trybu, napis o konsoli sensorów, żółte ramki „CEL GŁÓWNY” / „CEL”, nierozpoznane kontakty jako „Kontakt N” (te same numery co na konsoli sensorów). Impuls z konsoli sensorów poszerza obraz także na DRADIS. \
	4) Konsola taktyczna: sekcja „Cele od operatora sensorów”, Namierz rozpoczyna namierzanie, po oznaczeniu przycisk zmienia się na Wybierz, a potem na „namierzony”. Działonowy i pilot dostają komunikat w czacie przy nowym celu. \
	5) Rozbierz konsolę sensorów: DRADIS odzyskuje przyciski sensorów. \
	Uwaga: okręt główny ma już konsolę sensorów z mapy; konsola z zestawu przejmuje jej rolę do końca rundy albo do rozebrania."
	items = list(
		/obj/machinery/computer/ship/dradis/sensors = 1,
		/obj/machinery/computer/ship/dradis = 1,
		/obj/machinery/computer/ship/tactical = 1,
	)

/datum/test_chamber_kit/pr_566_konsola/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		to_chat(user, "<span class='warning'>Okręt główny nie jest w systemie gwiezdnym, nie przywołano fregat.</span>")
		return
	for(var/offset in list(40, -70))
		var/turf/spot = locate(clamp(main.x + offset, 10, world.maxx - 10), clamp(main.y + offset / 2, 10, world.maxy - 10), main.z)
		var/obj/structure/overmap/enemy = new /obj/structure/overmap/syndicate/ai/gunboat/sensor_test(spot)
		main.current_system.add_ship(enemy)
		message_admins("[key_name_admin(user)] przywołał nieuzbrojoną fregatę Syndykatu do testu konsoli sensorów: [ADMIN_VERBOSEJMP(enemy)].")
