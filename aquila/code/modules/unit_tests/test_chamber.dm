// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Komora testowa: ładuje się, każdy zestaw daje się zrzucić, reset przywraca pokój
/datum/unit_test/test_chamber

/datum/unit_test/test_chamber/Run()
	var/datum/test_chamber/chamber = get_test_chamber()
	TEST_ASSERT(chamber, "Test chamber failed to load")
	TEST_ASSERT(istype(chamber.arrival?.loc, /area/test_chamber), "Arrival turf is outside the chamber")
	TEST_ASSERT(istype(chamber.kit_center?.loc, /area/test_chamber/arena), "Kit center is outside the arena")
	TEST_ASSERT(!(locate(/obj/effect/landmark/test_chamber) in chamber.arrival), "Landmarks were not cleaned up")
	var/fail = check_room(chamber)
	TEST_ASSERT(!fail, "Fresh chamber: [fail]")

	for(var/name in test_chamber_kits())
		var/datum/test_chamber_kit/kit = test_chamber_kits()[name]
		// Liczymy różnicę, bo komora i wcześniejsze zestawy mogą już mieć obiekty tego typu
		var/list/before = list()
		for(var/path in kit.items)
			before[path] = count_in_chamber(chamber, path)
		chamber.spawn_kit(kit, null)
		for(var/path in kit.items)
			var/spawned = count_in_chamber(chamber, path) - before[path]
			// Podtypy z tej samej listy też pasują do istype, więc liczą się do oczekiwanej liczby
			var/expected = 0
			for(var/other in kit.items)
				if(ispath(other, path))
					expected += kit.items[other] || 1
			if(spawned != expected)
				Fail("Kit [name] spawned [spawned] of [expected] [path]")

	var/turf/open/floor/F = chamber.kit_center
	F.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	TEST_ASSERT(chamber.reset(), "Test chamber failed to reset")
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		var/mob/living/leftover = locate() in T
		TEST_ASSERT(!leftover, "Reset left [leftover?.type] at [T.x],[T.y]")
	TEST_ASSERT(istype(chamber.kit_center, /turf/open/floor/plasteel/dark), "Reset did not restore the arena floor")
	fail = check_room(chamber)
	TEST_ASSERT(!fail, "After reset: [fail]")

/datum/unit_test/test_chamber/proc/count_in_chamber(datum/test_chamber/chamber, path)
	// Zbiór, bo obiekt wielokratkowy (np. myśliwiec) jest w zawartości każdego turfu, który zajmuje
	var/list/found = list()
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		for(var/atom/movable/AM in T)
			found[AM] = TRUE
	. = 0
	for(var/atom/movable/AM as anything in found)
		if(istype(AM, path))
			.++

/datum/unit_test/test_chamber/proc/check_room(datum/test_chamber/chamber)
	var/consoles = 0
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		consoles += length(typecache_filter_list(T.contents, typecacheof(/obj/machinery/computer/test_chamber)))
	if(consoles != 1)
		return "Expected one console in the chamber, found [consoles]"
	var/datum/gas_mixture/air = chamber.arrival.return_air()
	var/pressure = air.return_pressure()
	if(pressure < 90 || pressure > 110)
		var/list/space = list()
		for(var/turf/T as anything in chamber.reservation.reserved_turfs)
			if(!isclosedturf(T) && !T.blocks_air && T.return_air()?.return_pressure() < 1)
				space += "[T.type]@[T.x],[T.y]"
		return "Chamber has unsafe pressure [pressure] kPa (arrival [chamber.arrival.type], [length(space)] empty turfs: [english_list(space.Copy(1, min(length(space), 6) + 1))])"

/// AQUILA - na niezniszczalnych ścianach komory da się zawiesić ramkę ścienną (tablica detektywa z aq33/AquilaStation#588 nie montowała się)
/datum/unit_test/test_chamber_wallmount

/datum/unit_test/test_chamber_wallmount/Run()
	var/datum/test_chamber/chamber = get_test_chamber()
	TEST_ASSERT(chamber, "Test chamber failed to load")
	var/turf/open/floor/spot
	var/turf/closed/indestructible/wall
	for(var/turf/open/floor/T in chamber.reservation.reserved_turfs)
		if(!istype(T.loc, /area/test_chamber) || T.density || locate(/obj/structure) in T)
			continue
		for(var/direction in GLOB.cardinals)
			var/turf/closed/indestructible/candidate = get_step(T, direction)
			if(istype(candidate) && istype(candidate.loc, /area/test_chamber))
				wall = candidate
				break
		if(wall)
			spot = T
			break
	TEST_ASSERT(spot && wall, "No chamber floor next to a chamber wall")
	var/mob/living/carbon/human/detective = allocate(/mob/living/carbon/human, spot)
	var/obj/item/wallframe/detectiveboard/frame = allocate(/obj/item/wallframe/detectiveboard)
	detective.put_in_active_hand(frame, forced = TRUE)
	wall.attackby(frame, detective)
	var/obj/structure/detectiveboard/board = locate() in spot
	TEST_ASSERT(board, "The detective board did not mount on the chamber wall")
	qdel(board)

/// AQUILA - zestaw zrzucony na kratkę ze stosem tego samego rodzaju (wcześniejszy zestaw na arenie) daje osobne stosy:
/// nowy stos łączył się z leżącym i znikał, więc test komory losowo widział „0 of 1” stosu
/datum/unit_test/test_chamber_kit_stacks

/datum/unit_test/test_chamber_kit_stacks/Run()
	var/turf/first = run_loc_floor_bottom_left
	var/list/turfs = list(first, get_step(first, EAST), get_step(get_step(first, EAST), EAST))
	allocate(/obj/item/stack/tile/plasteel, first)
	var/datum/test_chamber_kit/kit = new
	kit.items = list(/obj/item/stack/tile/plasteel = 2)
	kit.spawn_kit(turfs, first, null)
	var/stacks = 0
	for(var/turf/T as anything in turfs)
		for(var/obj/item/stack/tile/plasteel/tile in T)
			stacks++
			if(T != first)
				qdel(tile)
	qdel(kit)
	TEST_ASSERT(stacks == 3, "Kit stacks merged into a stack already lying in the arena: [stacks] of 3 stacks left")

#undef TEST_ASSERT
