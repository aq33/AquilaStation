// Sprint z BeeStation/BeeStation-Hornet#14750 + wywrotka na ścianie i potknięcie na schodach

/datum/test_chamber_kit/pr_512
	name = "PR 512: sprint i kondycja"
	pr = "aq33/AquilaStation#512"
	description = "W trybie biegu trzymaj Shift: postać przyspiesza (SPRINT_DELAY 1.5 zamiast RUN_DELAY 2), przy starcie leci chmurka kurzu, \
	a pionowy pasek obok błyskawicy staminy spada. Poniżej 40% zadyszka: brak sprintu, spowolnienie i nie da się mówić (emotki z * działają), mija przy 70%. \
	Leżenie podwaja regenerację. Wbiegnij sprintem z zachodu w kolumnę przeszkód po wschodniej stronie: \
	ściana, okno, zamknięte drzwi (zaryglowane) i stół zawsze przewracają (2 s, brute w głowę rośnie z rozpędem), człowiek i luźna skrzynia nie. \
	Schody wymagają wielu poziomów: sprawdź sprint w dół i w górę schodów na mapie (np. Atlas, Snake, Serendipity) albo na debugowym multiz."
	items = list(
		/obj/structure/window/fulltile = 1,
		/obj/structure/table = 1,
		/obj/machinery/door/airlock = 1,
		/obj/structure/closet/crate = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_512/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/column_x = center.x + 4
	var/list/obstacles = list(
		locate(/obj/structure/window/fulltile) in spawned,
		locate(/obj/structure/table) in spawned,
		locate(/obj/machinery/door/airlock) in spawned,
		locate(/obj/structure/closet/crate) in spawned,
		locate(/mob/living/carbon/human) in spawned,
	)
	var/y = center.y - 2
	for(var/atom/movable/thing as anything in obstacles)
		var/turf/T = locate(column_x, y, center.z)
		y++
		if(!T || !istype(T.loc, /area/test_chamber/arena) || !thing)
			continue
		thing.forceMove(T)
	// Kawałek ściany nad kolumną (reset komory ją usunie)
	var/turf/wall_turf = locate(column_x, y, center.z)
	if(wall_turf && istype(wall_turf.loc, /area/test_chamber/arena) && !is_blocked_turf(wall_turf, TRUE))
		wall_turf.ChangeTurf(/turf/closed/wall)
	var/obj/machinery/door/airlock/door = locate() in spawned
	door?.bolt()
