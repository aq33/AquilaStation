/datum/test_chamber_kit/pr_ptl
	name = "PR PTL: laser przesyłu mocy"
	pr = "aq33/AquilaStation#PTL"
	description = "Laser strzela na południe, RTG daje 30 MW nadwyżki. W panelu włącz wejście (np. 30 MW), poczekaj na 1 MW ładunku, ustaw wyjście (np. 5 MW) i włącz strzał. \
	Sprawdź: wiązka staje na ścianie komory, kredyty spływają na konta ENG/CAR/SEC (50/25/25), po 1 MW sprzedaży leci ogłoszenie CentComu. \
	Wepchnij człowieka w wiązkę: do 25 MW pali, 26-50 MW gibuje, powyżej wybuch. Bez dostępu inżynierii panel ma odmawiać, emag zdejmuje blokadę."

/datum/test_chamber_kit/pr_ptl/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Laser patrzy na południe: środek 3x3 na center, terminal dwie kratki wyżej, RTG nad nim
	var/turf/corner = locate(center.x - 1, center.y - 1, center.z)
	var/turf/terminal_turf = locate(center.x, center.y + 2, center.z)
	var/turf/generator_turf = locate(center.x, center.y + 3, center.z)
	new /obj/structure/cable(terminal_turf)
	new /obj/structure/cable(generator_turf)
	var/obj/machinery/power/terminal/terminal = new(terminal_turf)
	terminal.connect_to_network()
	var/obj/machinery/power/rtg/generator = new(generator_turf)
	generator.power_gen = 30000000
	generator.connect_to_network()
	new /obj/machinery/power/transmission_laser(corner)
	new /mob/living/carbon/human(locate(center.x + 2, center.y - 3, center.z))
