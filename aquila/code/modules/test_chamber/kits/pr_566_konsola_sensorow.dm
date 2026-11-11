// aq33/AquilaStation#566 - stanowisko rozpoznania i operator (aquila/code/modules/overmap/sensor_console.dm, player_sensors.dm)

/datum/test_chamber_kit/pr_566_konsola
	name = "Stanowisko rozpoznania i operator"
	pr = "aq33/AquilaStation#566"
	description = "Zestaw stawia stanowisko rozpoznania, DRADIS i konsolę taktyczną (wszystkie widzą okręt główny) oraz przywołuje dwie nieuzbrojone fregaty Syndykatu AI, około 40 i 70 pól od okrętu. Fregaty gonią, ale nie strzelają. Najlepiej we dwie osoby: operator przy stanowisku rozpoznania, działonowy przy taktycznej. \
	1) Radar: przełącz Nasłuch / Aktywny; w trybie aktywnym impulsy idą same co ustawiony odstęp (−/+), także po zamknięciu okna. Fala impulsu na ekranie rusza w chwili impulsu. \
	2) Radar kierunkowy (30°, 60°, 90°) ma własne celowanie (Cel / Kurs / Ręczny), osobne od teleskopu: wycinek sięga dalej niż impuls dookólny (100 pól), ale widzi tylko w swoim kierunku. Fregata poza wiązką impulsu nie słyszy. \
	3) Teleskop: tryby Cel / Kurs / Ręczny; w ręcznym przeciągnij myszą po ekranie (przeciąganie ustawia to, w czym ostatnio wybrano Ręczny). Zimna fregata poza zasięgiem kamery jest widoczna tylko w stożku teleskopu. \
	4) Kliknij fregatę, asteroidę, wrak albo anomalię: karta pokazuje odległość, namiar i co ją widzi. Ustaw Cel główny, potem drugą fregatę też jako główny: pierwsza ma zmienić się na drugorzędną. \
	5) DRADIS: brak przycisków impulsu i trybu, żółte ramki „CEL GŁÓWNY” / „CEL”, nierozpoznane kontakty jako „Kontakt N” (te same numery co K1, K2 na stanowisku). Podpisy nie nachodzą na siebie, zasłonięte widać po najechaniu. \
	6) Konsola taktyczna: sekcja „Cele od operatora rozpoznania”, Namierz rozpoczyna namierzanie, po oznaczeniu przycisk zmienia się na Wybierz, a potem na „namierzony”. Działonowy i pilot dostają komunikat w czacie przy nowym celu. \
	7) Rozbierz stanowisko rozpoznania: DRADIS odzyskuje przyciski sensorów. \
	Uwaga: okręt główny ma już stanowisko rozpoznania z mapy; stanowisko z zestawu przejmuje jego rolę do końca rundy albo do rozebrania."
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
		message_admins("[key_name_admin(user)] przywołał nieuzbrojoną fregatę Syndykatu do testu stanowiska rozpoznania: [ADMIN_VERBOSEJMP(enemy)].")
