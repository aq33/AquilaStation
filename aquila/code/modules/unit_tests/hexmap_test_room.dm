// AQUILA - pokój testowy dla testów mapy hex i jej eventów. Pokój jest wspólny dla wszystkich testów, a Destroy() testu
// usuwa z niego tylko obiekty, które nie są efektami: krew, szczątki, dym, iskry, ogień, mokra podłoga i zepsute powietrze
// (miazmat, para, gorąco) zostają dla następnych. Testy mapy hex zaczynają więc w posprzątanym pokoju i sprzątają po sobie.

/// Czy test sprząta pokój testowy przed i po sobie (testy mapy hex i jej eventów)
/datum/unit_test/proc/aquila_tidies_room()
	var/path = "[type]"
	return findtext(path, "/datum/unit_test/aquila_hex_") == 1 || findtext(path, "/datum/unit_test/hexmap_") == 1

/datum/unit_test/New()
	. = ..()
	if(aquila_tidies_room())
		aquila_test_tidy_room(run_loc_floor_bottom_left, run_loc_floor_top_right)

/datum/unit_test/Destroy()
	var/turf/bottom_left = run_loc_floor_bottom_left
	var/turf/top_right = run_loc_floor_top_right
	var/tidy = aquila_tidies_room()
	. = ..()
	if(tidy)
		aquila_test_tidy_room(bottom_left, top_right)

/// Usuwa z pokoju efekty (bez znaczników pokoju), osusza podłogę i przywraca początkowe powietrze
/proc/aquila_test_tidy_room(turf/bottom_left, turf/top_right)
	if(!bottom_left || !top_right)
		return
	var/list/room = block(bottom_left, top_right)
	for(var/turf/T as anything in room)
		for(var/obj/effect/leftover in T)
			if(istype(leftover, /obj/effect/landmark) || QDELETED(leftover))
				continue
			qdel(leftover)
		if(isopenturf(T))
			var/turf/open/open_turf = T
			open_turf.ClearWet()
	aquila_test_reset_air(room)
